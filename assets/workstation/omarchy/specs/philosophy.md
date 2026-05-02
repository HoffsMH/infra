# Philosophy

The principles below explain why the rest of the spec tree is the shape it
is. When something here conflicts with a leaf spec, it usually means a leaf
spec needs updating, not the other way around.

## 1. Mac muscle memory wins

Migrated from macOS to Linux long ago. The "left of spacebar + key" Mac
Cmd-pattern is permanent muscle memory. On Linux this is enforced by remap
layers: pressing the physical key 1-left-of-spacebar produces Ctrl, which
is the Linux Cmd-equivalent for app-level shortcuts (copy, paste, find,
new tab, close tab, save, etc.).

**Implication:** when a Mac Cmd shortcut conflicts with a Linux/Omarchy
default, the Mac muscle memory wins and the default is overridden or
shadowed.

## 2. Adjustments beat defaults

This setup is not a stock Omarchy install with a few tweaks; it's a
deliberate layering of personal choices on top of Omarchy. When defaults
collide with the layered setup, the layered setup wins. There is no plan
to fall back to a more vanilla Omarchy.

**Implication:** new Omarchy defaults arriving via `omarchy-update` are
audited against the personal layer and either inherited (silent fall-
through) or explicitly opted out of via `omarchy-unbinds.conf`.

## 3. Declarative over imperative

The infra repo (`~/infra/`) is the source of truth. Files in `~/.config/`
should be symlinks into the infra repo wherever practical, so:

- a fresh machine bootstraps by cloning infra and replaying symlinks
- changes are version-controlled and diffable
- two machines stay in sync by default

**Implication:** prefer writing config to `~/infra/.../omarchy/dotfiles/`
and symlinking, over editing `~/.config/` files in place.

## 4. Don't fork upstream; overlay it

Omarchy ships configs in `~/.local/share/omarchy/` (read-only, owned by
the package). The right way to customize is the overlay pattern: source
the upstream defaults in `~/.config/hypr/hyprland.conf`, then source
personal opt-outs and additions afterward. Never edit upstream files;
they get clobbered on update.

**Implication:** keeping the personal layer clean enough to read at a
glance is a goal in itself. Two-file split: opt-outs in one file,
declarative additions in another. See `hyprland/modular-overlay.md`.

## 5. Every adjustment leaves an artifact in infra

Every customization made on top of a stock Omarchy install -- a config
edit, a package install, a service tweak -- gets a corresponding
artifact in `~/infra/assets/workstation/omarchy/`. Concrete forms:

- Config files: live in `dotfiles/` and are symlinked to `~/.config/`.
- System files (e.g., `/etc/xremap/config.yml`): kept as a copy in the
  repo plus an idempotent `setup-*.sh` that installs them.
- Package additions: tracked in `packages.txt` (or the per-topic spec).
- Behavioral decisions: documented in the relevant spec file.

**Implication:** as the artifact set grows, a fresh Omarchy install
becomes progressively less work to bootstrap -- ideally one day a
single script can replay the entire personal layer. We're not chasing
that today, but every adjustment is one step closer.

## 6. Right-of-spacebar is a personal layer; left-of-spacebar is "Cmd"

- **Left-of-space** (LeftAlt physical) -> Ctrl (Mac Cmd-equivalent).
  Dual-purpose: tap = Esc.
- **Right-of-space** (RightAlt physical) -> HYPER chord (Ctrl+Alt+Super).
  Personal layer prefix; bind with `SUPER CTRL ALT, <key>` in Hyprland.
- **Win key** (LeftMeta) -> plain SUPER. Used for Omarchy default
  vocabulary (terminal launch, browser, scratchpad, etc.) and for
  SUPER+drag mouse (right-hand-on-mouse muscle memory).
- **Bottom-left + caps** (KEY_LEFTCTRL, the NuPhy firmware merges these)
  -> Alt. Used for shell readline M-keys.

This split means the three modifier-prefix vocabularies (app-level Ctrl,
WM-level personal HYPER, omarchy SUPER vocabulary) coexist without
collision.
