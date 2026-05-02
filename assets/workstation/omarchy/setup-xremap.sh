#!/usr/bin/env bash
# Idempotent installer for xremap on this Omarchy host.
# Replays what we did by hand: install pkg, drop config + unit, enable service.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! pacman -Qq xremap-hypr-bin >/dev/null 2>&1; then
  echo "==> installing xremap-hypr-bin"
  yay -S --needed --noconfirm xremap-hypr-bin
fi

echo "==> installing /etc/xremap/config.yml"
sudo install -Dm644 "$HERE/xremap/config.yml" /etc/xremap/config.yml

echo "==> installing /etc/systemd/system/xremap.service"
sudo install -Dm644 "$HERE/xremap/xremap.service" /etc/systemd/system/xremap.service

echo "==> reloading + enabling xremap.service"
sudo systemctl daemon-reload
sudo systemctl enable --now xremap.service
sudo systemctl restart xremap.service

systemctl status xremap.service --no-pager
