# Misc Hyprland behaviors

Settings that don't belong to a specific keybind/monitor/window-rule.

## Click-to-focus (no follow_mouse)

`~/.config/hypr/input.conf`:

```
input {
  follow_mouse = 0
}
```

Hovering over windows does not steal focus; you have to click. Reduces
accidental focus changes when the cursor crosses windows during typing
or while reading something on a different monitor.

## SUPER+drag mouse

Omarchy default. Kept intentionally; not unbound by `omarchy-unbinds`.
Right-hand-on-mouse muscle memory for moving and resizing tiled or
floating windows. Specifically:

- `bindm = SUPER, mouse:272, movewindow`
- `bindm = SUPER, mouse:273, resizewindow`

These survive the `unbind = SUPER, code:N` block because `bindm` is
distinct from `bind`.

## Drag-to-group (dwindle layout footgun)

Dropping a moved tiled window onto another tiled window can group them
into a tab container. There is no built-in "never group on drop" config
flag in dwindle. Mitigation: drop windows in the *gap between* tiles
when rearranging, and remember `SUPER+G` (Omarchy default) toggles
group on the active window — fastest way to dissolve an accidental
group.

## Tearing / VRR

See [window-rules.md](window-rules.md). Tearing is enabled globally via
`allow_tearing = true` in `looknfeel.conf`; per-window `immediate = 1`
opts specific windows in. VRR mode 2 (fullscreen-only) avoids
compositor-side jitter on the desktop.
