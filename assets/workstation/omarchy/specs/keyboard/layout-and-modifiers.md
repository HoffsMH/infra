# Layout and modifiers

What each physical key produces, after all remap layers.

## Modifier keys (left to right)

| Physical key | Kernel sees | After xremap | Used for |
|---|---|---|---|
| Caps Lock (NuPhy firmware -> LeftCtrl) | KEY_LEFTCTRL | **Alt** | shell readline M-keys |
| Bottom-left Ctrl | KEY_LEFTCTRL | **Alt** | same as above |
| Win | KEY_LEFTMETA | **Super** (unchanged) | Omarchy SUPER vocabulary + SUPER+drag mouse |
| LeftAlt (1 left of space) | KEY_LEFTALT | tap=**Esc** / hold=**Ctrl** | Mac Cmd-equivalent for app-level shortcuts |
| Spacebar | KEY_SPACE | KEY_SPACE | |
| RightAlt (1 right of space) | KEY_RIGHTALT | tap=RightAlt / hold=**HYPER chord** (Ctrl+Alt+Super) | personal layer prefix in Hyprland |

## Source of truth

xremap config lives in `~/infra/assets/workstation/omarchy/xremap/config.yml`
and is installed to `/etc/xremap/config.yml` by `setup-xremap.sh`. The
service is `xremap.service` (systemd, system-level), watching the file
with `--watch` so config edits hot-reload without a restart.

## Why these choices

- **LeftAlt -> Ctrl with tap=Esc:** the Mac muscle memory for "left of
  spacebar" is consistent across decades. On Linux, app-level shortcut
  prefix is Ctrl, so making this key produce Ctrl gives copy/paste/find/
  new-tab/close-tab/save/select-all "for free" in every app. Tap-Esc is
  a separate ergonomic win for vim and modal interfaces.
- **LeftCtrl -> Alt:** Alt has to exist somewhere for shell readline
  M-keys, tmux M-bindings, and Hyprland's default Alt+Tab cycle. Bottom-
  left ctrl key is the natural location -- displaced by the Mac muscle
  memory remap on LeftAlt, it gets repurposed.
- **RightAlt -> HYPER chord:** see [hyper-chord.md](hyper-chord.md).
- **Win unchanged:** Omarchy's defaults all live on SUPER. Keeping the
  Win key as plain Super lets us inherit Omarchy's vocabulary without
  extra work, and SUPER+drag mouse (the only mouse-modifier we use)
  stays put for right-hand-on-mouse muscle memory.

## NuPhy firmware caveat

Caps -> LeftCtrl is done in the keyboard firmware, not in xremap. The
side effect is that the Caps physical key and the bottom-left LCtrl
physical key are indistinguishable to the kernel. If you ever want
caps to behave differently from leftctrl, undo the firmware remap
first (NuPhy software, not in scope of this repo) and then xremap can
treat them separately.
