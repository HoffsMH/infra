#!/usr/bin/env bash
set -Eeuo pipefail

readonly MEDIA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BUNDLE="$MEDIA_DIR/infra.bundle"
readonly DESTINATION="$HOME/infra"

if [[ ! -f "$BUNDLE" ]]; then
  printf 'Missing infra bundle: %s\n' "$BUNDLE" >&2
  exit 1
fi

if [[ -f "$MEDIA_DIR/SHA256SUMS" ]]; then
  printf '[run ] verifying payload\n'
  (cd "$MEDIA_DIR" && sha256sum -c SHA256SUMS)
fi

if [[ -e "$DESTINATION" ]]; then
  printf 'Refusing to replace existing path: %s\n' "$DESTINATION" >&2
  printf 'Move it aside or use the network bootstrap instead.\n' >&2
  exit 1
fi

printf '[run ] cloning infra from offline bundle\n'
git clone "$BUNDLE" "$DESTINATION"

printf '\nSeed complete. Next command:\n\n  %s\n' "$DESTINATION/bootstrap-omarchy.sh"
