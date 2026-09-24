# Herdr

Herdr runs inside a tmux pane and maps tmux's model onto its own: tmux session
-> herdr workspace, window -> tab, pane -> pane. Its prefix is `ctrl+g`,
because tmux swallows `ctrl+f` first. The keys are commented in
`~/.config/herdr/config.toml`. The Mac needs no second config: Ghostty's
`config.mac` sends `cmd+g` as `ctrl+g`, so the same left-of-space key is the
prefix on both.

## Pane history in nvim

`prefix+e` is herdr's built-in `edit_scrollback`, the replacement for tmux's
`prefix+u`. It writes the focused pane's scrollback to a temp file and runs
`${EDITOR:-vi}` on it inside the pane. No key in `config.toml` overrides it.

It reads `EDITOR` from the herdr server process, not from the client or the
pane. `vi` is not installed here, so a server without `EDITOR` makes the key
do nothing visible. Check the server rather than a shell:

```
tr '\0' '\n' </proc/$(pgrep -f 'herdr server')/environ | grep EDITOR
```

## Where the server gets its environment

This section is Linux: the Mac has `vi` and no systemd unit.

The server can be started three ways, and each reads a different file:

| Started by | Reads | `EDITOR` comes from |
|---|---|---|
| `herdr.service` (systemd user unit, at login) | `~/.config/environment.d/*.conf` | `environment.d/editor.conf` |
| a herdr client in a local terminal | the terminal's environment | Omarchy's uwsm session, or `~/.zshenv` |
| `herdr --remote` from another machine | the non-interactive zsh that ssh runs | `~/.zshenv` |

`.zshrc` covers none of these: systemd reads no shell file, and a
non-interactive ssh command skips `.zshrc`. Omarchy's uwsm exports `EDITOR`
into systemd only when the graphical session starts, which is after
`herdr.service` has already started from `default.target`.

Omarchy's `omarchy-launch-editor --inline` still wins inside the desktop
session: `~/.zshenv` sets `EDITOR` only when it is unset, and uwsm overwrites
the `environment.d` value when the session starts.

## Two servers competing

A restart of `herdr.service` leaves the socket empty for a few seconds. A
connected `herdr --remote` client reconnects in that gap and starts its own
server over ssh. The systemd unit then fails every five seconds with
`herdr server is already running`, forever, because `Restart=on-failure`
never stops retrying. Whichever server won is the one whose environment
counts. See it with:

```
journalctl --user -u herdr.service -n 5
ps -o pid,ppid,cmd -p $(pgrep -f 'herdr server')
```

A parent of `herdr remote-client-bridge` means the ssh client won.

## Files

- `~/.config/herdr/config.toml` (common)
- `~/.zshenv` (common)
- `~/.config/systemd/user/herdr.service` (linux-arch)
- `~/.config/environment.d/editor.conf` (linux-arch)

## See also

- [tmux.md](../../../omarchy/specs/terminal/tmux.md) - the tmux `prefix+u` this replaces
- [shell.md](../../../omarchy/specs/terminal/shell.md) - zsh startup files
