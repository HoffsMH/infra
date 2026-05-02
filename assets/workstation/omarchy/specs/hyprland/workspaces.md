# Workspaces

## Assignment

| Workspace | Monitor | Default | Persistent |
|---|---|---|---|
| 1 | DP-1 (4K) | yes | yes |
| 2 | DP-1 | yes | yes |
| 3 | DP-1 | yes | yes |
| 4 | DP-1 | yes | yes |
| 5 | DP-1 | yes | yes |
| 6 | HDMI-A-1 (1440p) | no | yes |
| 7 | HDMI-A-1 | no | yes |

Declared in `~/.config/hypr/monitors.conf`. New windows open on whatever
workspace is current on the focused monitor.

## Switching and moving

All workspace switching and "move active window to workspace" lives on
HYPER (right-of-spacebar). Omarchy's `SUPER+1..0` workspace bindings are
opted out via `omarchy-unbinds.conf` so SUPER stays unencumbered.

| Combo | Action |
|---|---|
| HYPER + Q / W / E / R | Switch to workspace 1 / 2 / 3 / 4 |
| HYPER + 5 / 6 / 7 | Switch to workspace 5 / 6 / 7 |
| HYPER + Shift + same | Move active window to that workspace, **without following** (`movetoworkspacesilent`) |

The "without following" part is deliberate: it preserves focus, which is
useful when sweeping windows out of a current workspace into others.

`SUPER+drag mouse` (move window) and `SUPER+right-drag mouse` (resize)
are kept (Omarchy defaults survive the unbind block, since `bindm` is
distinct from `bind`).

## Tab-style workspace nav also off SUPER

Omarchy's `SUPER+TAB`, `SUPER+SHIFT+TAB`, and `SUPER+CTRL+TAB` workspace
nav are also unbound for consistency with the "all workspace work on
HYPER" rule. There is no HYPER equivalent today; if needed, HYPER+Tab
could be added.

## Why this layout

- The 4K Gigabyte is the primary work surface, directly in front. Five
  workspaces fits the "primary monitor for active context" pattern.
- The Acer is for ambient context (reference docs, monitoring, chat
  spillover). Two workspaces is enough.
- HYPER+QWER puts four workspaces under the left-hand home row, which
  is a faster reach than the number row.
