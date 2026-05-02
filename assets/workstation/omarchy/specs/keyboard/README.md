# Keyboard

The keyboard story has three layers stacked on top of each other:

1. **NuPhy firmware** (hardware) — the keyboard does its own remapping
   before the kernel sees anything. Currently configured to send
   `KEY_LEFTCTRL` for the Caps physical key. Result: kernel sees Caps and
   the bottom-left LCtrl key as the same scancode.
2. **xremap** (kernel evdev layer) — runs as a system service, intercepts
   keyboard events, dual-purposes/swaps modifier keys, and emits to a
   uinput device the rest of the system reads from.
3. **Hyprland and apps** (Wayland/X clients) — see only what xremap
   re-emits and act on it. Most personal keybindings live here.

| Topic | File |
|---|---|
| Who sends what after all the remapping | [layout-and-modifiers.md](layout-and-modifiers.md) |
| Tap-Esc on left-of-space | [tap-esc.md](tap-esc.md) |
| HYPER chord on right-of-space | [hyper-chord.md](hyper-chord.md) |
| Mac Cmd shortcut equivalence on Linux | [mac-cmd-equivalence.md](mac-cmd-equivalence.md) |
| Key-combo contract: walk this after changes to catch regressions | [contract.md](contract.md) |
