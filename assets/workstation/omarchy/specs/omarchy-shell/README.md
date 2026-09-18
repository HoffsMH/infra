# Omarchy shell

The bar, notifications, OSD, settings panels and lock screen all run inside a
single Quickshell process (`omarchy-shell`, started by Hyprland). Its
configuration is one file:

```text
~/.config/omarchy/shell.json          # bar layout, position, idle/lock timers
~/.config/omarchy/plugins/<id>/       # user-owned plugins and clones of built-ins
/usr/share/omarchy/shell/             # upstream source — read freely, never edit
```

`shell.json` hot-reloads on save. Plugin code under `~/.config/omarchy/plugins/`
reloads on save too; force it with `omarchy-shell shell rescanPlugins`.

| Topic | Where to look |
|---|---|
| Status bar: layout, gestures, the no-drag patch | [bar.md](bar.md) |

## Customising a built-in

Never edit `/usr/share/omarchy/shell/` — `omarchy update` overwrites it.
`omarchy plugin clone <id>` copies a built-in into
`~/.config/omarchy/plugins/<user>.<id>/`, rewrites its manifest id, and
switches the shell to the clone. The clone is then yours and survives updates.

The cost is that a clone **stops following upstream**. Treat every clone as
derived state — upstream plus a named, re-appliable patch, rebuilt by a setup
script rather than hand-edited. See `bar.md` for the pattern.
