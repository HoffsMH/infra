# HYPER chord on right-of-space

`KEY_RIGHTALT` is dual-purposed in xremap to emit a multi-modifier chord
when held:

```yaml
KEY_RIGHTALT:
  held:  [KEY_LEFTCTRL, KEY_LEFTALT, KEY_LEFTMETA]   # Ctrl+Alt+Super
  alone: KEY_RIGHTALT
  alone_timeout_millis: 150
```

This chord is what's referred to as **HYPER** throughout the spec.

## Why a chord rather than a single modifier

Hyprland identifies binds by modmask. The Win key already produces a plain
SUPER modmask, which Omarchy uses extensively. We want a *separate*
modifier-prefix for the personal layer that doesn't collide with anything
Omarchy ships. There is no `KEY_HYPER` at the kernel level (only
LEFTMETA/RIGHTMETA), and Hyprland cannot distinguish left vs right Super
at the modmask level. The pragmatic solution is to synthesize a unique
modmask -- Ctrl+Alt+Super held simultaneously is the conventional one and
Hyprland sees it as a distinct prefix.

## How to bind in Hyprland

Use `SUPER CTRL ALT, <key>` in Hyprland config. For example, `HYPER+P`
(deck mode) is:

```
bindd = SUPER CTRL ALT, P, Deck (maximize), fullscreen, 1
```

For HYPER+Shift combinations (used for "move active window to workspace"
without follow), add SHIFT:

```
bindd = SUPER CTRL ALT SHIFT, Q, Move window to ws 1, movetoworkspacesilent, 1
```

## Tap behavior

Tapping RightAlt alone (release before 150ms) emits a plain RightAlt
keystroke. This is mostly a no-op in modern apps; if it ever causes
issues, the alone behavior can be remapped (e.g., to a no-op keysym).
