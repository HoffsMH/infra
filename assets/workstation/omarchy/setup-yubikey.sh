#!/usr/bin/env bash
# Idempotent installer for the YubiKey + gpg-agent + SSH stack on this
# Omarchy host. Replays the nix/legacy setup pattern.
#
# What this script does:
#   1. Installs yubikey-manager, yubikey-personalization, pcsc-tools, libfido2
#   2. Enables and starts pcscd.service (smartcard daemon)
#   3. Symlinks ~/.gnupg/gpg-agent.conf and ~/.ssh/config from infra
#   4. Creates a gitignored ~/.ssh/config.local skeleton (if missing)
#   5. Sets correct permissions on ~/.gnupg and ~/.ssh
#
# Run yubikey/configure-yubikey.sh and yubikey/import-pubkey.sh once the
# YubiKey is plugged in.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> ensuring required packages are installed"
yay -S --needed --noconfirm \
  yubikey-manager \
  yubikey-personalization \
  pcsc-tools \
  libfido2

echo "==> enabling + starting pcscd.service"
sudo systemctl enable --now pcscd.service

echo "==> ~/.gnupg with correct permissions"
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"

echo "==> symlinking gpg-agent.conf"
ln -sf "$HERE/dotfiles/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"

echo "==> ~/.ssh with correct permissions"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

echo "==> symlinking ~/.ssh/config"
# If a real (non-symlink) ssh config exists, back it up first
if [ -e "$HOME/.ssh/config" ] && [ ! -L "$HOME/.ssh/config" ]; then
  mv "$HOME/.ssh/config" "$HOME/.ssh/config.bak.$(date +%s)"
fi
ln -sf "$HERE/dotfiles/.ssh/config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"

echo "==> ensure per-machine ~/.ssh/config.local exists (gitignored)"
if [ ! -f "$HOME/.ssh/config.local" ]; then
  cat > "$HOME/.ssh/config.local" <<'EOF'
# Per-machine SSH overrides. NOT in infra. Add work / throwaway / private
# Host entries here. Loaded first by ~/.ssh/config so its Host entries
# take precedence over the shared defaults.
EOF
  chmod 600 "$HOME/.ssh/config.local"
fi

echo
echo "Done. Next step with YubiKey plugged in:"
echo "  $HERE/yubikey/import-pubkey.sh        # imports pubkey, learns card, reloads agent"
echo
echo "Verify with:  ssh -T git@github.com     (should auth as you)"
echo
echo "(yubikey/configure-yubikey.sh is for FRESH-key hardware provisioning"
echo " only -- skip it unless the YubiKey is unconfigured.)"
