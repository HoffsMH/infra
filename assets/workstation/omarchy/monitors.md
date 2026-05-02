# Monitors / displays on this Omarchy host

## Layout

- **DP-1** — Gigabyte M32U (32" 4K) at `0x0`, 144Hz. Primary, in front of me.
- **HDMI-A-1** — Acer ED323QUR (32" 1440p) at `3840x0`, 144Hz. Right of DP-1.

Lives in `~/.config/hypr/monitors.conf`.

## DP-1 as the system primary

Hyprland has no built-in "primary monitor" concept (multi-monitor is first-class
and all monitors are equal), but XWayland-side primacy still matters. The default
ordering exposed Acer (HDMI-A-1) to XWayland as primary, which capped XWayland
 windows at 2560x1440 in their resolution dropdown even though the window was
on the 4K monitor. Diagnose with `xrandr` — the line marked `primary` (or, in
practice, the first `connected` line) is what most X11-era apps key off of.

Two layers of "make DP-1 primary":

1. **XWayland primary** — `xrandr --output DP-1 --primary` in
   `~/.config/hypr/autostart.conf` as `exec-once`. Fixes the games case. Required.

2. **Default workspace placement** — workspaces 1-5 default to DP-1, 6-7 to the
   Acer. Added at the bottom of `~/.config/hypr/monitors.conf`. Mirrors the old
   nix Hyprland setup so new windows open on the right screen.

## Replay

To replay on a fresh Omarchy install, append to `~/.config/hypr/autostart.conf`:

```
exec-once = xrandr --output DP-1 --primary
```

And to `~/.config/hypr/monitors.conf` after the monitor declarations:

```
workspace = 1, monitor:DP-1, default:true, persistent:true
workspace = 2, monitor:DP-1, default:true, persistent:true
workspace = 3, monitor:DP-1, default:true, persistent:true
workspace = 4, monitor:DP-1, default:true, persistent:true
workspace = 5, monitor:DP-1, default:true, persistent:true
workspace = 6, monitor:HDMI-A-1, persistent:true
workspace = 7, monitor:HDMI-A-1, persistent:true
```
