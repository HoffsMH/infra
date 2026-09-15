#!/usr/bin/env bash
# Import the personal GPG public key, set ultimate trust, learn the
# YubiKey-resident secret subkeys, and reload gpg-agent so the SSH side
# picks up the AUT subkey immediately. Idempotent.
#
# Platform-neutral: every command here is gnupg or curl, so this works the
# same on macOS (brew install gnupg) and on any Linux. That is why it lives
# in common/ rather than beside the arch-only setup-yubikey.sh, which
# installs the packages this assumes are already present.
set -euo pipefail

PUBKEY_URL="https://mhkr.xyz/key.pub"

for cmd in curl gpg gpg-connect-agent gpgconf; do
  command -v "$cmd" >/dev/null || {
    echo "$cmd is required. On macOS: brew install gnupg curl" >&2
    exit 1
  }
done

echo "==> importing public key from $PUBKEY_URL"
curl -fsSL "$PUBKEY_URL" | gpg --import

echo "==> setting ultimate trust on the imported key"
fpr=$(curl -fsSL "$PUBKEY_URL" | gpg --with-fingerprint --with-colons \
       | awk -F: '$1=="fpr" {print $10; exit}')
if [ -z "$fpr" ]; then
  echo "Could not extract fingerprint from $PUBKEY_URL" >&2
  exit 1
fi
echo "$fpr:6:" | gpg --import-ownertrust

echo "==> registering YubiKey-resident secret subkeys with the agent"
gpg-connect-agent "scd serialno" "learn --force" /bye

echo "==> reloading gpg-agent"
gpg-connect-agent updatestartuptty /bye
gpg-connect-agent reloadagent /bye

echo
echo "Done. SSH identity check:"
SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)" ssh-add -L || true
