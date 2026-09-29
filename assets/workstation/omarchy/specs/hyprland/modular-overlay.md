# Modular overlay structure

Hyprland binds are **additive**: declaring a second bind on a combo does
not replace the first; both fire when the combo is pressed. The only ways
to truly remove an inherited bind are `hl.unbind(...)` or not loading the
file that declares it.

This shapes the layout of the personal Hyprland layer.

## Files

```
~/.config/hypr/
├── hyprland.lua             # Omarchy entry point. Requires everything.
├── bindings.lua             # SYMLINK -> infra. Opt-outs, bindings, window rules.
├── monitors.lua             # Display config (ours, edited in place currently).
├── input.lua                # Input devices (ours, edited in place).
├── looknfeel.lua            # General appearance + tearing/VRR (ours, edited in place).
└── autostart.lua            # Startup entries (ours, edited in place).
```

`bindings.lua` is a symlink to
`~/infra/assets/workstation/omarchy/dotfiles/.config/hypr/`. The infra
copy is the source of truth.

## Load order in hyprland.lua

```
1. Omarchy defaults   require("default.hypr.omarchy")
2. Personal overrides require("hypr.monitors"), ("hypr.input"),
                      ("hypr.bindings"), ("hypr.looknfeel"), ("hypr.autostart")
3. Omarchy toggles    require("default.hypr.toggles")
```

Personal overrides load after the defaults, so the opt-outs in
`bindings.lua` see every default bind they remove.

## Sections of bindings.lua

- **Opt-outs** are **delta-shaped**: a list of `hl.unbind` calls against
  upstream defaults. They need auditing whenever `omarchy-update` brings
  in new defaults, so they sit together at the top of the file.
- **Bindings and window rules** are **declaration-shaped**: the world as
  we want it to behave, expressed positively. They should read as a
  standalone description of the personal layer.

Keeping the sections apart separates personal choices from
inheritance-management chores.

## Update workflow

When `omarchy-update` runs:

1. Note any newly-added or changed bindings in Omarchy's
   `default/hypr/bindings/*.lua`.
2. If a new default conflicts with the personal layer, add an
   `hl.unbind` to the opt-outs section of `bindings.lua`.
3. Reload (`hyprctl reload`); verify with
   `hyprctl configerrors` (should be empty) and `hyprctl binds`.
