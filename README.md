# Infra

This repository is the source of truth for workstation setup and dotfiles.

## Workstation dotfiles

The workstation tree is a stack of layers, least specific first. A machine
uses common plus every platform layer that matches it:

```text
assets/workstation/common/dotfiles/       every machine
assets/workstation/mac/dotfiles/          macOS
assets/workstation/linux-arch/dotfiles/   any Arch-family Linux, Omarchy included
assets/workstation/omarchy/dotfiles/      Omarchy only, on top of linux-arch
```

The intended model is:

1. Put behavior and appearance that should be consistent everywhere in
   `common/dotfiles`.
2. Put operating-system mechanics in the platform layer: `mac`, or
   `linux-arch` for anything a non-Omarchy Arch machine would also want
   (systemd user units, `environment.d`, shell environment).
3. Put only Omarchy desktop customization in `omarchy`: Hyprland unbinds, the
   top bar, and menus. Older files there have not all been sorted yet; new
   files follow this rule.
4. Keep platform files limited to overrides and translations required to
   preserve physical-key muscle memory.

The user cares about the physical key position, not the modifier name. The
left-of-spacebar key should perform the same job on every keyboard:

- macOS normally sends Command.
- Omarchy Linux uses xremap to turn physical LeftAlt into held Control
  (tap Escape), so Linux Command-equivalent shortcuts are Ctrl-based.
- Linux-only terminal workarounds belong in the Linux overlay. For example,
  Ctrl-V paste is not a common Mac binding because Mac Command-V already
  works natively. Ctrl-C remains normal shell interrupt behavior.

## Dotfile lifecycle

The commands live in `assets/workstation/common/dotfiles/bin/` and are linked
into `~/bin/` by `links.set`.

| Command | Purpose | Mutates by default |
|---------|---------|--------------------|
| `links.scan` | Audit infra symlinks and dotfile candidates | No |
| `links.prune` | Preview dangling infra symlinks; `--apply` removes them | No |
| `links.adopt FILE` | Copy one home file into a platform layer and link it | Yes |
| `links.set` | Link every active layer's dotfiles into `$HOME` | Yes |

Use `links.adopt --dry-run FILE` to preview adoption and `links.set -n` to
preview linking. `links.set -f` replaces existing targets; without `-f`, it
reports and skips them.

The normal workflow is:

1. Run `links.scan` to inspect the current state.
2. Run `links.prune`, then `links.prune --apply` if its removals are correct.
3. Run `links.adopt FILE` to place a new dotfile in the generic platform layer
   (`linux-arch` or `mac`). Use `links.adopt -l omarchy FILE` only for Omarchy
   desktop customization.
4. Review the platform copy and manually promote it to common only when it is
   genuinely portable.
5. Run `links.set`, using `-f` only when the reported replacements are wanted.

`links.adopt` accepts one readable regular file under `$HOME`. It refuses
directories, special files, existing symlinks, files already inside infra,
and any path that already exists in any active layer. It never adopts into
common; promotion is a manual decision.

`links.scan`, `links.set`, and `links.adopt` pick layers the same way from
`uname` and `/etc/os-release`: `common mac` on macOS, `common linux-arch` when
`ID` or `ID_LIKE` is `arch`, plus `omarchy` when `ID=omarchy`. They error on
anything else. A layer without a `dotfiles/` directory is skipped.

`links.set` processes layers in that order. It mirrors files; it does not
merge configuration contents. A later layer's file with the same target path
will not replace an earlier layer's symlink unless `links.set -f` is used. Prefer distinct overlay names when a program supports layered config,
such as:

```text
~/.config/ghostty/config
~/.config/ghostty/config.mac
~/.config/ghostty/config.linux
```

The common Ghostty config is the entry point and optionally loads the platform
overlay with Ghostty's `config-file = ?...` syntax. Ghostty, not `links.set`,
performs that content layering.

Edit the infra source path, not the symlink under `$HOME`. Before trusting a
home configuration, inspect `readlink` and check for unversioned files where a
symlink should exist.

Useful references:

- `assets/workstation/common/dotfiles/bin/links.set` - linker implementation.
- `assets/workstation/common/dotfiles/bin/links.scan` - symlink and candidate audit.
- `assets/workstation/common/dotfiles/bin/links.prune` - dangling infra-link cleanup.
- `assets/workstation/common/dotfiles/bin/links.adopt` - platform-first dotfile adoption.
- `assets/workstation/linux-arch/dotfiles/` - generic Arch Linux layer.
- `assets/workstation/common/dotfiles/AGENTS.md` - agent boundaries and
  dotfile rules.
- `assets/workstation/omarchy/ghostty.md` - Ghostty layering and platform
  behavior.
- `assets/workstation/omarchy/xremap/config.yml` - Linux physical-key
  remapping.
- `assets/workstation/omarchy/setup-bar.sh` - idempotent Omarchy bar setup:
  clones and patches the bar plugin so it cannot be dragged. See
  `assets/workstation/omarchy/specs/omarchy-shell/bar.md`.

## Dependencies

The setup scripts install platform-specific packages through the native
package manager. They are intentionally not interchangeable across macOS
and Omarchy Linux.
