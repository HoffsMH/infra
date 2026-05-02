# Key-combo contract

A checklist of key combos that should produce specific behaviors on this
host. Walk through it after any change to:

- `~/infra/assets/workstation/omarchy/xremap/config.yml`
- `~/infra/assets/workstation/omarchy/dotfiles/.config/hypr/personal.conf`
- `~/infra/assets/workstation/omarchy/dotfiles/.config/hypr/omarchy-unbinds.conf`
- The NuPhy firmware (rare, but if caps remap changes everything downstream
  has to be rechecked)

When something here breaks silently, that's a regression. The checklist
is short on purpose -- only combos that have caused trouble or are
load-bearing for muscle memory.

## Modifier mapping (sanity)

| Press | Should produce |
|---|---|
| Tap **left-of-spacebar** (LeftAlt physical) | `Esc` -- visible in vim / dismisses overlays |
| Hold **left-of-spacebar** + letter | Ctrl+letter -- e.g. left-of-space + C copies, + V pastes (NB: Ctrl+C in shell is SIGINT, that's expected) |
| **Caps Lock** + letter | Acts as Alt+letter (caps -> leftctrl via NuPhy firmware -> Alt via xremap modmap) |
| **Bottom-left ctrl** + letter | Same as Caps + letter (also Alt+letter) |
| Hold **right-of-spacebar** (RightAlt physical) + letter | HYPER chord: `SUPER+CTRL+ALT+letter` reaches Hyprland |
| **Win** key + letter | Plain `SUPER+letter` (Omarchy default vocabulary) |

## Arrow layers (the regression-prone ones)

| Press | Should produce |
|---|---|
| **left-of-spacebar + H/J/K/L** (= Ctrl+hjkl) | Left / Down / Up / Right arrow |
| **Caps + H/J/K/L** (= Alt+hjkl) | Left / Down / Up / Right arrow |
| **Bottom-left ctrl + H/J/K/L** (= Alt+hjkl) | Same as Caps |
| **HYPER + H/J/K/L** (= Ctrl+Alt+Super+hjkl) | reaches Hyprland untransformed -- so HYPER+J/K cycle windows |

The last row is the regression hotspot. xremap's keymap subset-matches
modifiers, so without an explicit `HYPER+hjkl passthrough` block the
Alt+hjkl rule fires for the HYPER chord (because the chord contains
Alt) and turns HYPER+J into Down. The xremap config has a passthrough
block specifically to prevent this; **don't remove it** when refactoring.

## Tmux prefix

| Press | Should produce |
|---|---|
| left-of-spacebar + F (= Ctrl+F) | tmux prefix mode in a tmux'd terminal; "find" in browser/editor (context-dependent) |
| Tmux prefix, then a key | tmux command (window navigation, copy-mode, etc.) |

## Mac-muscle-memory bindings

| Press | Should produce |
|---|---|
| left-of-space + C / V / X | Ctrl+C / V / X (copy / paste / cut in apps; SIGINT / Ctrl+V in shell) |
| left-of-space + Q | Hyprland kills the focused window (`killactive`) |
| left-of-space + Space | Walker app launcher |
| Win + left-of-space + Space (= Super+Ctrl+Space) | Omarchy menu |

## HYPER personal layer in Hyprland

| Press | Should produce |
|---|---|
| HYPER + Q / W / E / R | Switch to workspace 1 / 2 / 3 / 4 |
| HYPER + 5 / 6 / 7 | Switch to workspace 5 / 6 / 7 |
| HYPER + Shift + same | Move active window to workspace **without following** (movetoworkspacesilent) |
| HYPER + P | Deck (maximize, fullscreen mode 1) |
| HYPER + J / K | Cycle next / previous window in workspace |
| HYPER + Return | Spawn terminal |

## YubiKey + SSH

| Action | Should produce |
|---|---|
| First `ssh -T git@github.com` of the session | pinentry-gnome3 dialog asking for OpenPGP card PIN; YubiKey blinks for touch; "Hi HoffsMH! ..." |
| Subsequent ssh ops within touch-cache window (~15s for hardware, 600s for PIN cache) | Silent auth (no PIN prompt, no touch flash) |

## When to walk this list

- After editing `xremap/config.yml`
- After editing any file under `~/.config/hypr/` (or via the infra symlinks)
- After running `omarchy-update` if it touched `~/.local/share/omarchy/default/hypr/bindings/`
- When a key combo "feels off" -- this list is the source of truth for what's intentional
