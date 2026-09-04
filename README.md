# Infra

This repository is the source of truth for workstation setup and dotfiles.

## Workstation dotfiles

The workstation tree has one common layer and one selected platform layer:

```text
assets/workstation/common/dotfiles/
assets/workstation/mac/dotfiles/
assets/workstation/nix/dotfiles/
assets/workstation/omarchy/dotfiles/
```

The intended model is:

1. Put behavior and appearance that should be consistent everywhere in
   `common/dotfiles`.
2. Put operating-system or desktop-stack mechanics in the selected platform
   directory.
3. Keep platform files limited to overrides and translations required to
   preserve physical-key muscle memory.

The user cares about the physical key position, not the modifier name. The
left-of-spacebar key should perform the same job on every keyboard:

- macOS normally sends Command.
- Omarchy Linux uses xremap to turn physical LeftAlt into held Control
  (tap Escape), so Linux Command-equivalent shortcuts are Ctrl-based.
- Linux-only terminal workarounds belong in the Linux overlay. For example,
  Ctrl-V paste is not a common Mac binding because Mac Command-V already
  works natively. Ctrl-C remains normal shell interrupt behavior.

## Linking dotfiles

Use `assets/workstation/common/dotfiles/bin/set.links`.

`set.links`:

- links every file in `common/dotfiles` into `$HOME`;
- selects exactly one platform directory based on `uname`;
- selects `mac` on macOS;
- selects `omarchy` on Linux when `$HOME/.local/share/omarchy` exists;
- otherwise selects `nix` on Linux.

It processes common files first, then the selected platform files. It mirrors
files; it does not merge configuration contents. A platform file with the
same target path will not replace the common symlink unless `set.links -f` is
used. Prefer distinct overlay names when a program supports layered config,
such as:

```text
~/.config/ghostty/config
~/.config/ghostty/config.mac
~/.config/ghostty/config.linux
```

The common Ghostty config is the entry point and optionally loads the platform
overlay with Ghostty's `config-file = ?...` syntax. Ghostty, not `set.links`,
performs that content layering.

Edit the infra source path, not the symlink under `$HOME`. Before trusting a
home configuration, inspect `readlink` and check for unversioned files where a
symlink should exist.

Useful references:

- `assets/workstation/common/dotfiles/bin/set.links` - linker implementation.
- `assets/workstation/common/dotfiles/AGENTS.md` - agent boundaries and
  dotfile rules.
- `assets/workstation/omarchy/ghostty.md` - Ghostty layering and platform
  behavior.
- `assets/workstation/omarchy/xremap/config.yml` - Linux physical-key
  remapping.

## Dependencies

- Ansible
- Docker
