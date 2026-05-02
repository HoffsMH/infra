# Mac Cmd-equivalence on Linux

After the LeftAlt -> Ctrl remap, "left-of-spacebar + key" produces
Ctrl+key, which natively means the Mac Cmd-equivalent action in most
Linux apps.

## What works without any extra config

These are all native Linux Ctrl shortcuts; the muscle memory carries over
the moment the keyboard remap is in place.

| Mac Cmd | Linux Ctrl after remap | Where it works |
|---|---|---|
| Cmd+C / Cmd+V / Cmd+X | Ctrl+C / Ctrl+V / Ctrl+X | apps with text selection (NOT shell -- see "Gotchas") |
| Cmd+A | Ctrl+A | select all in apps |
| Cmd+Z / Cmd+Shift+Z | Ctrl+Z / Ctrl+Shift+Z | undo / redo |
| Cmd+S | Ctrl+S | save |
| Cmd+F | Ctrl+F | find in apps; tmux prefix in terminal |
| Cmd+T / Cmd+Shift+T | Ctrl+T / Ctrl+Shift+T | new tab / reopen tab in browsers |
| Cmd+W | Ctrl+W | close tab in apps |
| Cmd+R | Ctrl+R | reload in browsers |
| Cmd+L | Ctrl+L | URL bar in browsers |
| Cmd+1..9 | Ctrl+1..9 | switch tabs in browsers |
| Cmd+= / Cmd+- / Cmd+0 | Ctrl+= / Ctrl+- / Ctrl+0 | zoom |
| Cmd+P | Ctrl+P | print |
| Cmd+/ | Ctrl+/ | toggle comment in editors |
| Cmd+Shift+I | Ctrl+Shift+I | dev tools in browsers |

## What requires an explicit Hyprland binding

| Action | Mac | Linux Hyprland bind |
|---|---|---|
| Close window (the Cmd+Q gesture) | Cmd+Q | `CTRL, Q -> killactive` |
| App launcher | Cmd+Space | `CTRL, SPACE -> omarchy-launch-walker` |
| Omarchy menu (system-y omnibox) | n/a | `SUPER CTRL, SPACE -> omarchy-menu` |

These live in `personal.conf`.

## Gotchas

### Ctrl+C in terminal sends SIGINT, not "copy"

There is only one Ctrl on Linux, and Ctrl+C in a shell is universally the
interrupt signal. After the remap, "left-of-space + C" interrupts the
running command rather than copying selected text. Workflow alternatives
already wired up in tmux:

1. **Mouse drag-select** -> tmux's `set-clipboard on` + `mouse on` causes
   the selection to auto-copy to the system clipboard on release.
2. **Tmux prefix + `[`** -> enter copy-mode (vi keys), select with `v`,
   yank with `y`. Selection lands in system clipboard.
3. **Tmux prefix + `u`** -> capture pane history into nvim, yank with
   full vim motions, `:q!` to discard.

### Ctrl+W intentionally not bound at the WM level

Ctrl+W is "close tab" in apps. Binding it globally in Hyprland would
intercept it before browsers/editors and close entire windows on what's
meant to be a tab close. So the Hyprland layer leaves Ctrl+W to
applications, and uses Ctrl+Q for "close window" (different gesture
deliberately).

### Ctrl+Tab is intentionally not bound

Mac Cmd+Tab is the system app switcher. The natural Linux equivalent
would be Ctrl+Tab after the remap, but Ctrl+Tab is also the standard
"next tab" inside browsers/editors -- binding it globally would steal it
from apps. The personal layer uses HYPER+J / HYPER+K for window cycling
instead, which avoids the conflict and is already a comfortable
right-hand chord.

### Cmd+H (hide app), Cmd+M (minimize)

No Linux equivalent. Not used (no muscle memory).
