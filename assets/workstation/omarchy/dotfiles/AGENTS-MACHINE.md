# Machine-specific — Omarchy workstation

## Spec tree

`~/infra/assets/workstation/omarchy/specs/` — workstation (employer-
facing-adjacent). Mac/Linux dev setup, keyboard, Hyprland, terminal,
etc. `README.md` and `philosophy.md` at the root.

## Detail

Full notes (more YubiKey diagnostic recipes, the `IdentitiesOnly +
IdentityFile` gotcha, replay/bootstrap flow, etc.) live at:

- [`~/infra/assets/workstation/omarchy/specs/agent-orientation.md`](infra/assets/workstation/omarchy/specs/agent-orientation.md)

Read that before you touch anything load-bearing.

## Playbooks

### CurseForge update

The AUR `curseforge` package trails upstream, and the app's in-app
updater downloads a `.deb` it cannot install on Arch. Repackage it:

```sh
VER=<pkgver>                      # from the pending filename, hyphen -> underscore
B=/tmp/curseforge-$VER && mkdir -p "$B" && cd "$B"
cp ~/.cache/yay/curseforge/{PKGBUILD,LICENSE} .
cp ~/.cache/curseforge-updater/pending/CurseForge_${VER/_/-}_amd64.deb .
sed -i "s/^pkgver=.*/pkgver=$VER/" PKGBUILD
updpkgsums && makepkg -f
```

Verify the `.deb` against the sha512 in
`~/.cache/curseforge-updater/pending/update-info.json` first. Hand the
user the `sudo pacman -U "$B"/curseforge-$VER-1-x86_64.pkg.tar.zst`
line; he installs.

Not an AppImage. Full notes, including the direct download URL when the
app has not fetched anything:
`~/personal/omarchy-gaming/specs/curseforge-updates.md`
