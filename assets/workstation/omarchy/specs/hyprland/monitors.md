# Monitors

## Layout

| Slot | Output | Display | Resolution | Position |
|---|---|---|---|---|
| Primary | `DP-1` | Gigabyte M32U (32" 4K) | 3840x2160@144 | `0x0` (left) |
| Secondary | `HDMI-A-1` | Acer ED323QUR (32" 1440p) | 2560x1440@144 | `3840x0` (right) |

Lives in `~/.config/hypr/monitors.conf`.

## DP-1 as system primary

Hyprland has no built-in "primary monitor" concept (multi-monitor is
first-class and all monitors are equal), but XWayland-side primacy still
matters: XWayland clients (especially older X11 apps) ask the X server
"which monitor is primary?" and key off that for default geometry, and
some apps cap their resolution dropdown to that monitor's mode list.

Without intervention, XWayland reports the first-enumerated monitor as
primary, which on this host is HDMI-A-1 (1440p). This caps XWayland app
resolution dropdowns at 2560x1440 even when the focused window is on
DP-1.

Fix: `~/.config/hypr/autostart.conf` runs

```
exec-once = xrandr --output DP-1 --primary
```

at session start, which tells XWayland (and the X11 protocol generally)
that DP-1 is primary. Verify with `xrandr | grep primary`.

## Workspace placement

Workspaces 1-5 default to DP-1, 6-7 to HDMI-A-1. See
[workspaces.md](workspaces.md).
