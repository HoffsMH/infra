# Infra

This repository is the source of truth for workstation setup and dotfiles.

## Workstation dotfiles

The workstation tree has one common layer and one selected platform layer:

```text
assets/workstation/common/dotfiles/
assets/workstation/mac/dotfiles/
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

## Dotfile lifecycle

The commands live in `assets/workstation/common/dotfiles/bin/` and are linked
into `~/bin/` by `links.set`.

| Command | Purpose | Mutates by default |
|---------|---------|--------------------|
| `links.scan` | Audit infra symlinks and dotfile candidates | No |
| `links.prune` | Preview dangling infra symlinks; `--apply` removes them | No |
| `links.adopt FILE` | Copy one home file into the active platform overlay and link it | Yes |
| `links.set` | Link common and active-platform dotfiles into `$HOME` | Yes |

Use `links.adopt --dry-run FILE` to preview adoption and `links.set -n` to
preview linking. `links.set -f` replaces existing targets; without `-f`, it
reports and skips them.

The normal workflow is:

1. Run `links.scan` to inspect the current state.
2. Run `links.prune`, then `links.prune --apply` if its removals are correct.
3. Run `links.adopt FILE` to place a new dotfile in the active platform first.
4. Review the platform copy and manually promote it to common only when it is
   genuinely portable.
5. Run `links.set`, using `-f` only when the reported replacements are wanted.

`links.adopt` accepts one readable regular file under `$HOME`. It refuses
directories, special files, existing symlinks, files already inside infra,
and any path whose common or active-platform destination already exists. It
never promotes a file to common automatically.

`links.set` links every file in `common/dotfiles`, then selects `mac` on macOS
or `omarchy` when `/etc/os-release` identifies Omarchy. It errors on unsupported
platforms.

It processes common files first, then the selected platform files. It mirrors
files; it does not merge configuration contents. A platform file with the
same target path will not replace the common symlink unless `links.set -f` is
used. Prefer distinct overlay names when a program supports layered config,
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
- `assets/workstation/common/dotfiles/AGENTS.md` - agent boundaries and
  dotfile rules.
- `assets/workstation/omarchy/ghostty.md` - Ghostty layering and platform
  behavior.
- `assets/workstation/omarchy/xremap/config.yml` - Linux physical-key
  remapping.

## Dependencies

The setup scripts install platform-specific packages through the native
package manager. They are intentionally not interchangeable across macOS
and Omarchy Linux.
