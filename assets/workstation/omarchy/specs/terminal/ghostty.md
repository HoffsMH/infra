# Ghostty

## Default terminal

Ghostty is the default terminal, set via:

```
omarchy-install-terminal ghostty
```

That writes `~/.config/xdg-terminals.list` listing
`com.mitchellh.ghostty.desktop` first. Omarchy bindings like
`SUPER+RETURN`, `omarchy-launch-tui`, etc. then open Ghostty.

## Config layout

```
~/.config/ghostty/config -> infra symlink
~/.config/ghostty/config.omarchy-default.bak  (original Omarchy default, kept for reference)
```

Source of truth:
`~/infra/assets/workstation/omarchy/dotfiles/.config/ghostty/config`.

## What's in the config

- **Theme follower**: `config-file = ?"~/.config/omarchy/current/theme/ghostty.conf"`
  -- Ghostty re-reads this when the Omarchy theme changes, so the
  terminal follows the rest of the desktop.
- **Font**: JetBrainsMono Nerd Font, size 13.
- **Window**: padding 14 each side, no resize overlay, no
  confirm-close, flat GTK toolbar style.
- **Cursor**: block, no blink. Shell integration features
  `no-cursor,ssh-env`.
- **Hyprland slowness fix**: `async-backend = epoll` (per
  https://github.com/ghostty-org/ghostty/discussions/3224).
- **Bindings (Omarchy default)**: `shift+insert` paste,
  `control+insert` copy, `super+control+shift+alt+arrow_*` for split
  resize.
- **Mac Cmd port (alt -> close/reload)**: removed. After the keyboard
  remap (`leftalt -> Ctrl`), Ghostty would never see `alt+q` because
  Hyprland intercepts `Ctrl+Q` for `killactive` first. So those binds
  are dead code and not in the config.

## Reload after editing

`ghostty +reload-config` from a terminal, or close and reopen ghostty
windows. There is no in-app keybind for reload (the natural Mac
"cmd+a" shortcut would land as Ctrl+A in shells, conflicting with
beginning-of-line).

## Port notes

The original Mac config from `~/infra/assets/workstation/common/dotfiles/`
had several `cmd+<key>` bindings. Most were text-injections of
`M-<key>` escape sequences -- on Mac, Cmd+key doesn't naturally produce
the escape sequence, so they had to be wired up. On Linux, `alt+key`
(after the keyboard remap, the bottom-left "alt" key) already produces
the same escape natively, so none of those bindings need to carry
over.

The exceptions worth porting -- `cmd+q close`, `cmd+a reload` -- moved
to the Hyprland WM layer (`Ctrl+Q -> killactive`) and the CLI
(`ghostty +reload-config`) respectively.
