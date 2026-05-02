# Omarchy workstation specs

This is a spec tree, not docs. It describes **how this Omarchy workstation
is intended to behave**, what's been done, and what's still open. It's the
reference future-me (and assistants) read before making changes, so the
"why" behind decisions doesn't get lost.

Scope: workstation for software work.

## Layout

| Topic | Where to look |
|---|---|
| Why we make the choices we make | [philosophy.md](philosophy.md) |
| Cross-agent orientation (what trips other agents up) | [agent-orientation.md](agent-orientation.md) |
| Keyboard remap, modifiers, Mac muscle memory | [keyboard/](keyboard/) |
| Hyprland (WM): monitors, workspaces, overlay structure, window rules | [hyprland/](hyprland/) |
| Terminal stack: ghostty, tmux, zsh, neovim | [terminal/](terminal/) |
| Mouse + other input devices | [input-devices/](input-devices/) |
| AI tooling, default-app choices | [applications/](applications/) |
| Recovering from forked/abandoned conversation transcripts | [transcript-recovery.md](transcript-recovery.md) |
| What's still open | [todo.md](todo.md) |
| Audit trail of completed work | [done.md](done.md) |

## How to use this

- Before changing how something behaves, read the relevant spec file. If
  the spec is silent, it's a hint that the area is unintentional.
- When you make a deliberate change, **update the spec in the same edit
  as the code/config**. The spec lags reality only if we're sloppy.
- Open questions and parked ideas go in `todo.md`. When done, move them
  to `done.md` with the date.
- Pure narrative belongs nowhere; if you find yourself writing it,
  rewrite as a rule + a short reason (`Why:`).
