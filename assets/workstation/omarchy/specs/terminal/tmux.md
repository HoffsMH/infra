# tmux

## Prefix

`C-f` (Ctrl+F). After the keyboard remap, "left-of-space + F" produces
Ctrl+F, so the Mac muscle memory for the prefix is preserved.

In the focused-app conflict between tmux and other apps (browsers,
editors all bind Ctrl+F to "find"), the rule of thumb works because
tmux only intercepts Ctrl+F when the focused window is a terminal
running tmux. Browser Ctrl+F still finds, terminal Ctrl+F still tmux's.

## Config

`~/.config/tmux/tmux.conf`. Currently edited in place; not yet
symlinked into infra (TODO).

The base config came from `~/infra/assets/workstation/mac/dotfiles/.tmux.conf`
with two changes:
1. `prefix C-f` instead of `prefix M-f`
2. Reload-config keybind path adjusted for `~/.config/tmux/`

The Omarchy-shipped default tmux.conf is preserved at
`~/.config/tmux/tmux.conf.omarchy.bak`.

## Helper scripts

In `~/bin/` (created if missing, expected on `$PATH` for direct shell
use; Tmux references them by absolute path so PATH membership is not
required for the keybinds):

| Script | What |
|---|---|
| `e.tmux-wrapper` | Open or focus an "edit" window in current session running nvim |
| `lzg.tmux-wrapper` | Open or focus a "lazygit" window |
| `zsh.tmux-wrapper` | Open or focus a "zsh-main" window |
| `tmux.sessionizer` | fzf over open sessions + zoxide directories; switch or create |
| `tmux.hist` | Capture pane history into nvim for vim-motion yanking |
| `tmux.import-env` | Push Wayland/Hyprland env vars (WAYLAND_DISPLAY, SSH_AUTH_SOCK, etc.) into tmux server |

`tmux.import-env tmux` should be run as `exec-once` in
`~/.config/hypr/autostart.conf` so tmux servers inherit the session
env (TODO; not yet wired up).

## Copy without Ctrl+C

Three escape hatches replace the unavailable Mac "Cmd+C copy in terminal"
gesture:

1. **Mouse drag-select** -> `set-clipboard on` + `mouse on` causes the
   selection to auto-copy to the system clipboard on mouse release.
2. **Tmux prefix + `[`** -> enters copy-mode (vi keys); `v` start
   selection, `y` yank to system clipboard.
3. **Tmux prefix + `u`** -> captures the entire pane history into nvim
   for full vim-motion yanking; `:q!` discards.

See [../keyboard/mac-cmd-equivalence.md](../keyboard/mac-cmd-equivalence.md)
for the Ctrl+C / SIGINT-in-shell gotcha.
