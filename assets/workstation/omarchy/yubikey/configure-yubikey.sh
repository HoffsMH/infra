#!/usr/bin/env bash
# YubiKey one-time HARDWARE configuration.
#
# !!! Do NOT run this on an already-configured YubiKey unless you know
# !!! you want to re-apply touch policies and reset the PIN-retry counter.
# !!!
# !!! The user's primary YubiKey is already provisioned (touch policies,
# !!! PIN retries, OpenPGP keys). This script is here for the fresh-key
# !!! / new-hardware case only. Idempotent in theory, but each run
# !!! consumes the admin PIN.
#
# Prerequisites for a fresh setup:
#   - `ykman openpgp reset`, `ykman piv reset`, `ykman oath reset`
#   - GPG keys generated/loaded onto the card (see infra/.../yubi for notes)
set -euo pipefail

if ! command -v ykman >/dev/null; then
  echo "ykman not installed. Run setup-yubikey.sh first." >&2
  exit 1
fi

if ! ykman list 2>/dev/null | grep -q YubiKey; then
  echo "No YubiKey detected. Plug it in and try again." >&2
  exit 1
fi

echo "==> disabling OTP interface (avoids accidental-touch typing nonsense)"
ykman config usb -d OTP -f

echo "==> disabling no-touch-eject"
ykman config usb --no-touch-eject -f

echo "==> setting OpenPGP touch policy: cached-fixed for SIG/AUT/ENC/ATT"
ykman openpgp keys set-touch SIG CACHED-FIXED -f
ykman openpgp keys set-touch AUT CACHED-FIXED -f
ykman openpgp keys set-touch ENC CACHED-FIXED -f
ykman openpgp keys set-touch ATT CACHED-FIXED -f

echo "==> setting OpenPGP PIN retry counts to 4 4 4"
ykman openpgp set-pin-retries 4 4 4 -f

echo "Done. Card status:"
gpg --card-status || true
