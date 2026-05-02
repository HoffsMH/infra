# Ghostty

## Layout

`~/.config/ghostty/config` is a symlink to
`~/infra/assets/workstation/omarchy/dotfiles/.config/ghostty/config` so the
dotfiles repo is the source of truth. The omarchy-default config lives next
to the symlink as `config.omarchy-default.bak` for reference.

## Default terminal

Ghostty is set as the system default terminal via:

```
omarchy-install-terminal ghostty
```

That command wrote `~/.config/xdg-terminals.list` listing
`com.mitchellh.ghostty.desktop` first, so omarchy's `SUPER+RETURN`,
`omarchy-launch-tui`, etc. all open ghostty.

## Port notes (Mac config -> Linux)

Source: `~/infra/assets/workstation/common/dotfiles/.config/ghostty/config`
(Mac, with `cmd+<key>` bindings).

Translation rule for muscle memory: **cmd -> alt** (left-of-spacebar key on
each platform). See user memory note about Mac->Linux muscle memory.

Most of the Mac config was *text-injection* of `M-<key>` escape sequences,
because on Mac `cmd+<key>` doesn't naturally produce `\x1b<key>`. On Linux,
`alt+<key>` already does, so those bindings are unnecessary and intentionally
left out here. Only the functional bindings carry over:

| Mac binding                                | Linux equivalent                | Outcome                       |
|--------------------------------------------|---------------------------------|-------------------------------|
| `cmd+a = reload_config`                    | `alt+a = reload_config`         | reload ghostty config         |
| `cmd+q` (close window — Mac OS-level)      | `alt+q = close_surface`         | close ghostty surface         |
| `cmd+f = text:\x1bf` (tmux prefix)         | (native: alt+f sends M-f)       | dropped, no rebind needed     |
| `cmd+d = text:\x1bd` (readline kill-word)  | (native: alt+d)                 | dropped                       |
| `cmd+u = text:\x1bu` (readline upcase)     | (native: alt+u)                 | dropped                       |
| `cmd+y = text:\x1by` (readline yank-pop)   | (native: alt+y)                 | dropped                       |
| `cmd+e = text:\x1be`                       | (native: alt+e)                 | dropped                       |
| `cmd+enter = text:\x1b\r`                  | (native: alt+enter)             | dropped                       |
| `cmd+grave_accent = toggle_quick_terminal` | (no Linux equivalent)           | dropped                       |

The Linux config keeps the omarchy defaults (theme follower, fonts, padding,
clipboard binds, split-resize binds, hyprland async-backend slowness fix).

## Reload

After editing the file in infra:

```
ghostty +reload-config
```

…or the in-app `alt+a` binding, or restart any open ghostty windows.
