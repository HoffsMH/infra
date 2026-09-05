#!/usr/bin/env bash
set -euo pipefail

url="${1:-}"
if [[ -z "$url" ]]; then
  url=$(uclip 2>/dev/null || true)
fi

if [[ -z "$url" ]]; then
  printf 'Usage: yt.v [url] [subdirectory]\n' >&2
  exit 1
fi

subdirectory="${2:-}"
queue="${XDG_STATE_HOME:-$HOME/.local/state}/ytgo/queue.zsh"
mkdir -p "$(dirname "$queue")"
if [[ -n "$subdirectory" ]]; then
  printf 'ytdlv %q %q\n' "$url" "$subdirectory" >> "$queue"
else
  printf 'ytdlv %q\n' "$url" >> "$queue"
fi

notify 'YouTube queued' "$url"
printf 'Queued video: %s\n' "$url"
