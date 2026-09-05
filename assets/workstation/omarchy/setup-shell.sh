#!/usr/bin/env bash
set -Eeuo pipefail

readonly SHELL_CONFIG="$HOME/.config/omarchy/shell.json"
readonly CLOCK_FORMAT="dddd h:mm AP"

if [[ ! -f "$SHELL_CONFIG" ]]; then
  printf 'Missing Omarchy shell config: %s\n' "$SHELL_CONFIG" >&2
  exit 1
fi

if ! jq -e '[.bar.layout[]?[]? | select(.id == "omarchy.clock")] | length == 1' "$SHELL_CONFIG" >/dev/null; then
  printf 'Expected exactly one omarchy.clock entry in %s\n' "$SHELL_CONFIG" >&2
  exit 1
fi

tmp=$(mktemp "${SHELL_CONFIG}.tmp.XXXXXX")
trap 'command rm -f "$tmp"' EXIT

jq --arg format "$CLOCK_FORMAT" '
  .bar.layout |= with_entries(
    .value |= map(if .id == "omarchy.clock" then .format = $format else . end)
  )
' "$SHELL_CONFIG" >"$tmp"

chmod --reference="$SHELL_CONFIG" "$tmp"
mv "$tmp" "$SHELL_CONFIG"
trap - EXIT

printf 'Omarchy clock format: %s\n' "$CLOCK_FORMAT"
