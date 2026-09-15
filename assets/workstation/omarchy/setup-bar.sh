#!/usr/bin/env bash
# Idempotent Omarchy bar setup for this host: a bar that cannot be dragged.
#
# The stock Omarchy bar has three gestures that fire by accident on a
# touchscreen, and each one writes straight into ~/.config/omarchy/shell.json:
#
#   1. Press-and-hold 200ms, or a 4px slide, on the bar background
#      -> moves the whole bar to another screen edge (bar.position)
#   2. Drag a widget
#      -> reorders it within or between sections (bar.layout)
#   3. Double-click the bar background
#      -> toggles transparency (bar.transparent)
#
# Omarchy exposes no config flag for any of them. The only lever is the bar
# plugin's own QML, so this script clones the built-in bar into
# ~/.config/omarchy/plugins/<user>.bar -- which replaces the stock bar -- and
# neuters the gesture handlers in the clone.
#
# The clone is derived state: upstream Bar.qml plus two one-line edits. It is
# never hand-edited and never backed up into the plugins directory (the shell
# would discover the backup as a plugin). Rebuild it at will with --reclone.
#
# A clone does not follow `omarchy update`, so this script installs a
# post-update hook that re-runs itself with --reclone. If upstream ever
# reshapes the code the patch anchors to, the patch fails loudly, the existing
# clone is left in place, and the update still succeeds.
#
# Usage:
#   setup-bar.sh             clone if missing, patch, activate, install hook
#   setup-bar.sh --reclone   rebuild the clone from current upstream, then patch
#   setup-bar.sh --layout    also reset the layout to Omarchy defaults, bar on
#                            top, 12-hour clock (the baseline this host wants)
#   setup-bar.sh --revert    drop the clone, return to the stock bar, drop hook

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF="$HERE/$(basename "${BASH_SOURCE[0]}")"

SOURCE_ID="omarchy.bar"
CLONE_ID="${USER:-$(id -un)}.bar"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
CLONE_DIR="$PLUGINS_DIR/$CLONE_ID"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
HOOK="$HOME/.config/omarchy/hooks/post-update.d/10-setup-bar"

# The bar layout this host wants: Omarchy defaults, on top, 12-hour clock.
CLOCK_FORMAT="dddd h:mm AP"

# Stamped into every patched line so re-runs can tell patched from unpatched.
MARKER="infra/setup-bar"

TMP=""
cleanup() { [[ -n $TMP && -d $TMP ]] && rm -rf "$TMP"; return 0; }
trap cleanup EXIT

fail() {
  echo "setup-bar: $*" >&2
  exit 1
}

upstream_dir() {
  omarchy-plugin-catalog |
    jq -r --arg id "$SOURCE_ID" '.[] | select(.firstParty and .id == $id) | .sourceDir'
}

# ------------------------------------------------------------------- patching
#
# Each edit is anchored on a distinctive upstream line and rewritten to a form
# that no longer matches its own anchor, so counting anchors tells us whether a
# file is unpatched (want N), patched (0 anchors, N markers), or something we
# do not recognise (anything else -> abort rather than guess).

apply_edit() {
  local file=$1 label=$2 want=$3 anchor=$4 expr=$5
  local unpatched patched

  unpatched=$(grep -cE -- "$anchor" "$file" || true)
  patched=$(grep -cF -- "$MARKER: $label" "$file" || true)

  if (( unpatched == 0 && patched == want )); then
    echo "    ok       $label"
    return
  fi

  (( unpatched == want )) ||
    fail "$label: expected $want anchor(s) in ${file##*/}, found $unpatched (patched: $patched).
       Upstream Bar.qml changed shape. Re-read the gesture code and update this
       script's anchors before trusting the bar again."

  sed -i -- "$expr" "$file"

  patched=$(grep -cF -- "$MARKER: $label" "$file" || true)
  (( patched == want )) || fail "$label: applied the edit but found $patched marker(s), expected $want"
  echo "    patched  $label"
}

patch_bar_qml() {
  local qml=$1

  # (0) Work around an upstream bug, present in Omarchy 4.0.2: a cloned bar
  # never loads at all.
  #
  # shell.qml instantiates the built-in bar declaratively, as
  # `Bar { omarchyPath: ...; barWidgetRegistry: ...; barConfig: ... }`, which
  # satisfies Bar.qml's three `required` properties at creation time. A *plugin*
  # bar goes through `Loader { source: url }` instead and only assigns those
  # properties afterwards, in onLoaded -> QML refuses to create the component
  # ("Required property X was not initialized") and the bar is simply absent.
  # The Loader's own error path is broken too (shell.qml calls errorString()
  # out of scope, raising a ReferenceError), so it never falls back to the
  # built-in bar either.
  #
  # Dropping `required` lets the component create with empty values; onLoaded
  # then fills them in microseconds later. Bar.qml already tolerates this --
  # its config reader falls back to fallbackBarConfig when barConfig is not a
  # plain object.
  apply_edit "$qml" "clone-load" 1 \
    '^[[:space:]]*required property string omarchyPath[[:space:]]*$' \
    "s|^\\([[:space:]]*\\)required property string omarchyPath[[:space:]]*\$|\\1property string omarchyPath: \"\" // $MARKER: clone-load (host injects in onLoaded)|"

  apply_edit "$qml" "clone-load-var" 2 \
    '^[[:space:]]*required property var (barWidgetRegistry|barConfig)[[:space:]]*$' \
    "s@^\\([[:space:]]*\\)required property var \\(barWidgetRegistry\\|barConfig\\)[[:space:]]*\$@\\1property var \\2: null // $MARKER: clone-load-var (host injects in onLoaded)@"

  # (1) bar-move drag and (3) double-click transparency both live in
  # CenterGestureArea, the MouseArea filling the bar background. Disabling the
  # MouseArea drops both; widget clicks are unaffected, they have their own
  # MouseArea stacked above this one.
  apply_edit "$qml" "bar-gestures" 2 \
    'CenterGestureArea \{ anchors\.fill: parent \}' \
    "s|CenterGestureArea { anchors.fill: parent }|CenterGestureArea { anchors.fill: parent; enabled: false } // $MARKER: bar-gestures (no edge drag, no double-click transparency)|g"

  # (2) widget reordering is gated behind one property in ModuleSlot's
  # MouseArea. Pinning it false keeps the MouseArea live -- clicks, tooltips and
  # right-click menus all still work -- and only the drag path goes away.
  apply_edit "$qml" "widget-reorder" 1 \
    '^[[:space:]]*readonly property bool canReorder: root\.shell' \
    "s|^\\([[:space:]]*\\)readonly property bool canReorder: root\\.shell.*\$|\\1readonly property bool canReorder: false // $MARKER: widget-reorder (no drag between sections)|"
}

# Prove the patch still applies to today's upstream before destroying anything.
preflight() {
  local src=$1
  TMP=$(mktemp -d)
  cp -- "$src/Bar.qml" "$TMP/Bar.qml"
  echo "==> preflight: patching a scratch copy of upstream Bar.qml"
  patch_bar_qml "$TMP/Bar.qml"
  rm -rf "$TMP"
  TMP=""
}

# --------------------------------------------------------------------- pieces

reset_layout() {
  echo "==> resetting bar layout to Omarchy defaults"
  # `bar defaults` rewrites .bar wholesale and drops .bar.id, so it has to run
  # before the clone is selected as the active bar.
  omarchy bar defaults
  omarchy bar position top
  omarchy bar transparent false
  omarchy bar set omarchy.clock format "$CLOCK_FORMAT"
}

make_clone() {
  local reclone=$1

  if [[ -e $CLONE_DIR || -L $CLONE_DIR ]]; then
    if (( ! reclone )); then
      echo "==> clone present: $CLONE_DIR"
      return
    fi
    echo "==> rebuilding clone from upstream"
    # Release the clone first: removing the active bar out from under the shell
    # leaves .bar.id pointing at nothing.
    omarchy bar use "$SOURCE_ID" >/dev/null
    rm -rf -- "$CLONE_DIR"
  fi

  echo "==> cloning $SOURCE_ID -> $CLONE_ID"
  omarchy plugin clone "$SOURCE_ID"
}

install_hook() {
  echo "==> installing post-update hook: ${HOOK/#$HOME/\~}"
  mkdir -p -- "$(dirname "$HOOK")"
  cat >"$HOOK" <<HOOK_EOF
#!/usr/bin/env bash
# Installed by infra: assets/workstation/omarchy/setup-bar.sh
#
# A cloned bar plugin does not follow \`omarchy update\`. Rebuild it against the
# freshly updated upstream Bar.qml and re-apply the no-drag patch.
#
# Never fail the update: on error the previous clone is still in place and still
# patched, just built against the older upstream.

SCRIPT="$SELF"
[[ -x \$SCRIPT ]] || exit 0

if ! "\$SCRIPT" --reclone; then
  omarchy-notification-send -g 󰐱 \\
    "Bar patch needs attention" \\
    "setup-bar.sh --reclone failed; the bar still works but is built against the previous Omarchy shell." 2>/dev/null || true
fi
exit 0
HOOK_EOF
  chmod 755 -- "$HOOK"
}

# A bar that does not draw is worse than a bar you can drag. Omarchy's own
# fallback-to-built-in path is broken (see the clone-load note above), so this
# script owns the safety net: restart the shell, confirm the bar really mapped
# its layer surface, and put the stock bar back if it did not.
bar_is_mapped() {
  hyprctl layers -j 2>/dev/null |
    jq -e 'any(.. | objects | select(has("namespace")); .namespace == "omarchy-bar")' >/dev/null 2>&1
}

health_check() {
  echo "==> restarting the shell and checking the bar actually draws"
  omarchy restart shell >/dev/null 2>&1 || true

  local waited=0
  while (( waited < 100 )); do
    bar_is_mapped && { echo "    bar surface is mapped"; return 0; }
    sleep 0.1
    waited=$((waited + 1))
  done

  echo "setup-bar: the patched bar did not draw within 10s -- reverting" >&2
  revert
  fail "reverted to the stock bar. Check for QML errors with:
       journalctl --user --since '-2 min' | grep -iE 'WARN scene|Required property'"
}

verify() {
  local active
  active=$(jq -r '.bar.id // "omarchy.bar"' "$SHELL_JSON")
  [[ $active == "$CLONE_ID" ]] || fail "active bar is '$active', expected '$CLONE_ID'"

  grep -qF -- "$MARKER: bar-gestures" "$CLONE_DIR/Bar.qml" || fail "bar-gestures marker missing from the clone"
  grep -qF -- "$MARKER: widget-reorder" "$CLONE_DIR/Bar.qml" || fail "widget-reorder marker missing from the clone"

  echo
  echo "Bar is $CLONE_ID, position $(jq -r '.bar.position' "$SHELL_JSON"), clock '$(jq -r '.bar.layout.center[] | select(.id=="omarchy.clock") | .format' "$SHELL_JSON")'."
  echo "Edge drag, widget drag and double-click transparency are all off."
}

revert() {
  echo "==> returning to the stock bar"
  omarchy bar use "$SOURCE_ID"
  rm -rf -- "$CLONE_DIR"
  rm -f -- "$HOOK"
  # A rescan is not enough to swap the bar back: the shell keeps the dead
  # plugin bar selected and draws nothing. Restart it.
  omarchy restart shell >/dev/null 2>&1 || true
  echo "Stock bar restored. Drag gestures are live again."
}

# ----------------------------------------------------------------------- main

do_reclone=0
do_layout=0
do_revert=0

while (( $# > 0 )); do
  case "$1" in
    --reclone) do_reclone=1 ;;
    --layout) do_layout=1 ;;
    --revert) do_revert=1 ;;
    -h|--help) sed -n '2,40p' "$SELF"; exit 0 ;;
    *) fail "unknown option: $1 (try --help)" ;;
  esac
  shift
done

command -v omarchy >/dev/null || fail "omarchy is not on PATH; this script is Omarchy-only"
[[ -f $SHELL_JSON ]] || fail "missing $SHELL_JSON"

if (( do_revert )); then
  revert
  exit 0
fi

SRC=$(upstream_dir)
[[ -n $SRC && -f $SRC/Bar.qml ]] || fail "could not locate the built-in $SOURCE_ID plugin"

preflight "$SRC"
(( do_layout )) && reset_layout
make_clone "$do_reclone"
echo "==> patching $CLONE_ID"
patch_bar_qml "$CLONE_DIR/Bar.qml"
omarchy bar use "$CLONE_ID" >/dev/null
install_hook
health_check
verify
