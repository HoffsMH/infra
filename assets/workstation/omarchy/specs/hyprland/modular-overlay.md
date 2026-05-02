# Modular overlay structure

Hyprland binds are **additive**: declaring `bind = MOD, K, action2` does
not replace an earlier `bind = MOD, K, action1`; both fire when the combo
is pressed. The only ways to truly remove an inherited bind are
`unbind = MOD, K` or stop sourcing the file that declares it.

This shapes the file layout of the personal Hyprland layer.

## Files

```
~/.config/hypr/
├── hyprland.conf            # Omarchy entry point. Sources everything.
├── bindings.conf            # Omarchy-shipped overlay (extra app launchers). Untouched by us.
├── monitors.conf            # Display config (ours, edited in place currently).
├── input.conf               # Input devices (ours, edited in place).
├── looknfeel.conf           # General appearance + tearing/VRR (ours, edited in place).
├── autostart.conf           # exec-once entries (ours, edited in place).
├── omarchy-unbinds.conf     # SYMLINK -> infra. Opt-outs only.
└── personal.conf            # SYMLINK -> infra. Declarative bindings + window rules.
```

`omarchy-unbinds.conf` and `personal.conf` are symlinks to
`~/infra/assets/workstation/omarchy/dotfiles/.config/hypr/`. The infra
copies are the source of truth.

## Source order in hyprland.conf

The order matters because of bind additivity:

```
1. Omarchy defaults              (sourced from ~/.local/share/omarchy/...)
2. Omarchy-shipped user overlay  (~/.config/hypr/bindings.conf)
3. Personal opt-outs             (~/.config/hypr/omarchy-unbinds.conf)
4. Personal additions            (~/.config/hypr/personal.conf)
```

Personal additions are sourced last so they always win.

## Why two personal files instead of one

- `omarchy-unbinds.conf` is **delta-shaped**: a list of opt-outs from
  upstream defaults. It needs auditing whenever `omarchy-update` brings
  in new defaults. Keeping it isolated makes the audit trivial.
- `personal.conf` is **declaration-shaped**: the world as we want it to
  behave, expressed positively. It should be readable as a standalone
  description of the personal layer.

Mixing the two would obscure what's a personal choice vs. what's an
inheritance-management chore.

## Update workflow

When `omarchy-update` runs:

1. Note any newly-added or changed bindings in
   `~/.local/share/omarchy/default/hypr/bindings/*.conf`.
2. If a new default conflicts with the personal layer, add an `unbind`
   to `omarchy-unbinds.conf`.
3. Reload (`hyprctl reload`); verify with
   `hyprctl configerrors` (should be empty) and `hyprctl binds`.
