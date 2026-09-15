#!/usr/bin/env bash
set -Eeuo pipefail

readonly HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PACKAGE_FILE="$HERE/packages.txt"

if [[ "$(uname -s)" != "Linux" || ! -d "$HOME/.local/share/omarchy" ]]; then
  printf 'This installer requires an Omarchy Linux desktop.\n' >&2
  exit 1
fi

if ! command -v yay >/dev/null 2>&1; then
  printf 'yay is required before installing the Omarchy package set.\n' >&2
  exit 1
fi

mapfile -t packages < <(
  sed -E 's/[[:space:]]*#.*$//' "$PACKAGE_FILE" | awk 'NF'
)

if (( ${#packages[@]} == 0 )); then
  printf 'No packages found in %s.\n' "$PACKAGE_FILE" >&2
  exit 1
fi

printf 'Installing %d Omarchy packages from %s\n' "${#packages[@]}" "$PACKAGE_FILE"
yay -S --needed --noconfirm "${packages[@]}"
