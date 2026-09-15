#!/usr/bin/env bash
set -Eeuo pipefail

readonly INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OMARCHY_DIR="$INFRA_DIR/assets/workstation/omarchy"
readonly STATE_DIR="$HOME/.local/state/infra-bootstrap"
readonly HANDOFF="$STATE_DIR/BOOTSTRAP-NEXT.txt"

mkdir -p "$STATE_DIR"

if [[ "$(uname -s)" != "Linux" || ! -d "$HOME/.local/share/omarchy" ]]; then
  printf 'This entrypoint requires an Omarchy Linux desktop.\n' >&2
  exit 1
fi

run_phase() {
  local name="$1"
  shift
  local marker="$STATE_DIR/$name.done"

  if [[ -e "$marker" ]]; then
    printf '[skip] %s\n' "$name"
    return
  fi

  printf '[run ] %s\n' "$name"
  "$@"
  touch "$marker"
}

install_packages() {
  "$OMARCHY_DIR/install-packages.sh"
}

install_omp() {
  if command -v omp >/dev/null 2>&1; then
    printf 'OMP already installed: %s\n' "$(command -v omp)"
    return
  fi

  curl -fsSL https://omp.sh/install | sh
}

link_dotfiles() {
  "$INFRA_DIR/assets/workstation/common/dotfiles/bin/links.set" -f
}

write_handoff() {
  cat > "$HANDOFF" <<'EOF'
Omarchy bootstrap next steps
============================

1. Reboot:
     reboot

2. After login, with the YubiKey plugged in, import the public key and
   reload the GPG/SSH agent:
     ~/infra/assets/workstation/common/yubikey/import-pubkey.sh

3. Unlock Bitwarden and retrieve the email credentials and confirmation code.

4. Generate the required OTP when prompted:
     yotp <account-substring>

5. Complete the OpenRouter provider setup in OMP, then start it:
     omp

6. If you need to see these instructions again:
     cat ~/.local/state/infra-bootstrap/BOOTSTRAP-NEXT.txt
EOF

  printf '\nBootstrap complete.\n\n'
  cat "$HANDOFF"
}

run_phase packages install_packages
run_phase omp install_omp
run_phase links link_dotfiles
run_phase shell "$OMARCHY_DIR/setup-shell.sh"
run_phase scaffolding "$INFRA_DIR/assets/workstation/common/dotfiles/bin/set.scaffolding"
run_phase yubikey "$OMARCHY_DIR/setup-yubikey.sh"
run_phase xremap "$OMARCHY_DIR/setup-xremap.sh"
run_phase syncthing systemctl --user enable --now syncthing.service
write_handoff
