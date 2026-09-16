# Status bar

## Intended behaviour

- **The bar sits on top and does not move.** Position, widget order and
  transparency are set in config, never by pointer gesture.
- **Layout is Omarchy stock, with one deviation: a 12-hour clock**
  (`format: "dddd h:mm AP"`). Everything else is whatever upstream ships.
- **Widgets stay clickable.** Disabling gestures must not cost clicks,
  tooltips or right-click menus.

Why: this host has a touchscreen. Every bar gesture below fires by accident
when a palm or a stray tap lands on the bar, and each one silently rewrites
`~/.config/omarchy/shell.json`. The bar ended up docked to the left edge with
a reshuffled centre section before anyone noticed a gesture existed.

## The three gestures, and where they live

Upstream has no config flag for any of them. The only lever is the bar
plugin's QML, in `/usr/share/omarchy/shell/plugins/bar/Bar.qml`.

| Gesture | Writes | Code |
|---|---|---|
| Press-and-hold 200ms, or a 4px slide, on the bar background | `bar.position` | `CenterGestureArea` (a MouseArea filling the bar) |
| Drag a widget | `bar.layout` | `ModuleSlot`'s MouseArea, gated on `canReorder` |
| Double-click the bar background | `bar.transparent` | `CenterGestureArea.onDoubleClicked` |

## How it is disabled

`assets/workstation/omarchy/setup-bar.sh` clones `omarchy.bar` into
`~/.config/omarchy/plugins/<user>.bar` — which replaces the stock bar — and
applies three one-line edits to the clone's `Bar.qml`:

0. Drop `required` from `omarchyPath`, `barWidgetRegistry` and `barConfig`.
   This is not a customisation, it works around an upstream bug — see below.
1. `enabled: false` on both `CenterGestureArea` instantiations. Kills the edge
   drag and the double-click transparency toggle together. Widget clicks are
   unaffected: each widget has its own MouseArea stacked above this one.
2. `canReorder: false` in `ModuleSlot`. Kills only the drag path; the MouseArea
   stays live, so clicks and menus keep working.

## Upstream bug: a cloned bar never loads (Omarchy 4.0.2)

**`omarchy plugin clone omarchy.bar` produces a bar that does not draw at all** —
with or without any edits of ours. Confirmed on 4.0.2-1.

`Bar.qml` declares three `required` properties. `shell.qml` satisfies them for
the built-in bar by instantiating it declaratively:

```qml
Component { id: defaultBarComponent
  Bar { omarchyPath: ...; barWidgetRegistry: ...; barConfig: ... } }
```

A *plugin* bar goes through a different path — `Loader { source: url }` — which
creates the component first and only assigns properties afterwards, in
`onLoaded` via `configureBar()`. QML requires `required` properties at creation
time, so the component is never created:

```text
WARN scene: .../mh.bar/Bar.qml[15:3]: Required property omarchyPath was not initialized
```

The Loader's fallback is broken too. `shell.qml:256` reads
`errorString && errorString()` inside `onStatusChanged`, where `errorString` is
not in scope, so the `Loader.Error` branch throws instead of reverting to the
built-in bar:

```text
WARN scene: @shell.qml[256:-1]: ReferenceError: errorString is not defined
```

Net effect: a broken plugin bar means **no bar and no fallback**. Hence edit 0,
and hence the health check below.

Worth reporting upstream. The minimal fix on their side is either
`setInitialProperties` on the plugin Loader, or `errorString` -> `pluginBarLoader.errorString`.

Every patched line carries an `infra/setup-bar:` marker. The script counts
anchors before editing: N unpatched anchors means patch, 0 anchors and N
markers means already done, **anything else aborts** rather than guessing.

```text
setup-bar.sh             clone if missing, patch, activate, install hook
setup-bar.sh --reclone   rebuild the clone from current upstream, then patch
setup-bar.sh --layout    also reset to stock layout, top, 12-hour clock
setup-bar.sh --revert    drop the clone, return to the stock bar, drop hook
```

## Keeping up with upstream

A clone does not follow `omarchy update`. The script installs
`~/.config/omarchy/hooks/post-update.d/10-setup-bar`, which re-runs it with
`--reclone` so the clone is rebuilt from the new upstream `Bar.qml` and
re-patched.

The script preflights the patch against a scratch copy of upstream **before**
touching the existing clone. So if Omarchy reshapes the gesture code, the
reclone aborts, the previous clone stays in place and keeps working (just built
against the older shell), the update still succeeds, and a notification says
the patch needs attention. Fix by re-reading `Bar.qml` and updating the anchors
in `setup-bar.sh`.

## Health check

Because upstream will not fall back, `setup-bar.sh` owns the safety net. After
activating the clone it restarts the shell, polls `hyprctl layers` for the
`omarchy-bar` layer surface for up to 10s, and if it never appears, reverts to
the stock bar and exits non-zero. A bad patch costs a flicker, not a desktop.

There is still a ~1s window during `--reclone` where the running shell
hot-reloads the freshly cloned, not-yet-patched `Bar.qml` and briefly drops the
bar. The restart at the end of the health check clears it.

## Rules

- **Never hand-edit the clone.** It is derived state: upstream plus the three
  edits above. Change `setup-bar.sh` and re-run with `--reclone`.
- **Never back a clone up inside `~/.config/omarchy/plugins/`.** The shell
  scans that directory and would discover the backup as a second plugin.
- **`omarchy bar defaults` drops `bar.id`**, reverting to the stock bar. Any
  layout reset has to run *before* the clone is selected as the active bar —
  `setup-bar.sh` orders it that way.
- Changing layout deliberately is still fine — `omarchy bar move|put|set`
  writes `shell.json` the same way the gestures did. Only the *accidental*
  path is closed.
