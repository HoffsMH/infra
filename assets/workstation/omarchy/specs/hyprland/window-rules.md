# Window rules

Generic patterns for `windowrule { ... }` blocks live here. Specific
rules for individual applications are in `personal.conf` next to the
keybindings.

## Hyprland 0.54 syntax

The window rule syntax changed in modern Hyprland (0.45+). Block style
(used in this repo):

```
windowrule {
  name = <descriptive>
  match:class = ^(<regex>)$
  match:title = ^(<regex>)$
  fullscreen = 1
  idle_inhibit = fullscreen
  immediate = 1
  tag = -default-opacity
  opacity = 1 1
}
```

Notes:

- Matchers are `match:class`, `match:title`, `match:tag`, `match:float`,
  `match:fullscreen`, `match:namespace`, `match:pin`, `match:xwayland`.
- **There is no `match:initialClass` / `match:initialTitle`** in 0.54.3.
  Match by current `match:title` and accept that titles can change at
  runtime.
- Boolean rules take `on` / `off` or `1` / `0`, not bare keywords. So
  `fullscreen on` (or `fullscreen = 1` in block form), not `fullscreen`.
- The flat-style equivalent is
  `windowrule = fullscreen on, match:class ^(foo)$`.

## Matcher precision

A `match:class` alone is rarely specific enough; many apps share generic
class names (Wine apps, browser PWAs, electron apps). Combine with
`match:title` for a stable pin. Anchor regexes with `^...$` to avoid
partial matches on similarly-named windows.

To find the right matcher for an app, run
`hyprctl clients | grep -i -E 'class|title'` while the app is open.

## Common rule recipes

- **Auto-fullscreen on launch:** `fullscreen = 1` (true fullscreen,
  exclusive). Use `fullscreen = 2` for "maximize without removing
  borders/gaps" if the app should stay tiled-looking.
- **Idle inhibit while fullscreen:** `idle_inhibit = fullscreen` -
  prevents screen lock / screensaver while the app is fullscreen.
- **Allow tearing for the window:** `immediate = 1`. Requires global
  `general { allow_tearing = true }` (set in `looknfeel.conf`).
- **Force opacity, override theme transparency:** `opacity = 1 1` plus
  `tag = -default-opacity` to remove Omarchy's global opacity tag.
- **Send to specific workspace at launch silently:**
  `workspace = N silent` (window appears on workspace N, focus stays).

## Tearing and VRR (set globally, not per rule)

In `~/.config/hypr/looknfeel.conf`:

```
general { allow_tearing = true }
misc    { vrr = 2 }    # fullscreen-only VRR
```

`allow_tearing` enables the per-window `immediate` rule to take effect.
`vrr = 2` engages variable refresh rate only for fullscreen surfaces,
which avoids odd compositor behavior on the desktop.
