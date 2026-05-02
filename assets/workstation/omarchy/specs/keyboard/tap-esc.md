# Tap-Esc on left-of-space

The LeftAlt physical key is dual-purposed in xremap:

```yaml
KEY_LEFTALT:
  held:  KEY_LEFTCTRL    # acts as Ctrl when held
  alone: KEY_ESC         # acts as Esc when tapped
  alone_timeout_millis: 150
```

## Why

Esc is the most-used non-letter key for vim, modal UI flows, dismissing
overlays, and breaking out of states. The traditional Esc is a long reach.
Putting Esc under the dominant thumb (left of spacebar) makes it free.

The 150ms `alone_timeout_millis` is the window in which a tap-then-release
is interpreted as Esc. Hold longer than 150ms (or press another key during
the hold) and it acts as Ctrl. In practice the window is wide enough that
chording feels normal and short enough that intentional Esc taps are
reliable.

## Why not on Caps

Caps would be the more conventional choice for tap-Esc, but on this host
the NuPhy firmware already remaps Caps -> LeftCtrl, merging it with the
bottom-left ctrl key. Putting tap-Esc on the merged KEY_LEFTCTRL would
mean every accidental brush of either Caps or Ctrl spits out an Esc into
the focused app. Tap-Esc on LeftAlt avoids this because LeftAlt is rarely
tapped by accident in normal typing.
