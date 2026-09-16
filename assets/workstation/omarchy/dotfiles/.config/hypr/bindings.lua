-- Personal keybinding layer. Ported from
-- ~/infra/assets/workstation/omarchy/dotfiles/.config/hypr/{omarchy-unbinds,personal}.conf
-- (conf form, older Omarchy) to the Omarchy 4.0.2 lua API.
--
-- Modifier vocabulary (via xremap, /etc/xremap/config.yml):
--   left-of-spacebar  -> Ctrl (Mac Cmd-equivalent; tap = Esc)
--   bottom-left ctrl / caps -> Alt (shell readline M-keys, Alt+hjkl)
--   right-of-spacebar -> HYPER chord = SUPER+CTRL+ALT held
--   Win key           -> plain SUPER (omarchy default vocabulary)

-- ===== Opt-outs from omarchy defaults (delta-shaped; audit on omarchy-update) =====

-- Workspace switching/moving moved to the HYPER layer
for code = 10, 19 do
  hl.unbind("SUPER + code:" .. code)
  hl.unbind("SUPER + SHIFT + code:" .. code)
  hl.unbind("SUPER + SHIFT + ALT + code:" .. code)
end

-- Tab-style workspace nav moved to HYPER
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + CTRL + TAB")

-- SUPER+CTRL+SPACE becomes the omarchy menu (rebind below)
hl.unbind("SUPER + CTRL + SPACE")

-- Drop SUPER+SHIFT+SPACE (toggle top bar): too easy to fatfinger
hl.unbind("SUPER + SHIFT + SPACE")

-- Terminal launch moves to HYPER+RETURN (rebind below)
hl.unbind("SUPER + RETURN")

-- HYPER+W is workspace 2; drop the default weather notification on this chord
hl.unbind("SUPER + CTRL + ALT + W")

-- ===== Mac muscle-memory layer (left-of-spacebar = Ctrl) =====
o.bind("CTRL + Q", "Close window", hl.dsp.window.close())

-- App launcher on the Cmd+Space chord. omarchy-launch-walker was the
-- pre-4.0 launcher; fall forward to the quickshell apps menu on 4.0.2.
if o.cmd_present("omarchy-launch-walker") then
  o.bind("CTRL + SPACE", "Launch apps", "omarchy-launch-walker")
else
  o.bind("CTRL + SPACE", "Launch apps", "omarchy-menu toggle apps")
end
o.bind("SUPER + CTRL + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Mac Cmd+Shift+4 region screenshot = Ctrl+Shift+4 after the keyboard remap
o.bind("CTRL + SHIFT + code:13", "Screenshot (region to snip history)",
  'OMARCHY_SCREENSHOT_DIR="$HOME/personal/00-cap-md/snip-screenshot" omarchy-capture-screenshot region')

-- ===== HYPER (right-of-spacebar) personal layer =====

-- Window actions
o.bind("SUPER + CTRL + ALT + P", "Deck (maximize)", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + CTRL + ALT + J", "Cycle next window", hl.dsp.window.cycle_next())
o.bind("SUPER + CTRL + ALT + K", "Cycle previous window", hl.dsp.window.cycle_next({ next = false }))

-- Terminal on HYPER+RETURN (preserves pane cwd via omarchy-cmd-terminal-cwd)
o.bind("SUPER + CTRL + ALT + RETURN", "Terminal",
  'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"')

-- Workspaces 1-7: HYPER+Q/W/E/R then 5/6/7; +SHIFT moves without following
local hyper_workspaces = {
  Q = "1", W = "2", E = "3", R = "4",
  ["code:14"] = "5", ["code:15"] = "6", ["code:16"] = "7",
}
for key, ws in pairs(hyper_workspaces) do
  o.bind("SUPER + CTRL + ALT + " .. key, "Workspace " .. ws,
    hl.dsp.focus({ workspace = ws }))
  o.bind("SUPER + CTRL + ALT + SHIFT + " .. key, "Move window to ws " .. ws,
    hl.dsp.window.move({ workspace = ws, follow = false }))
end


-- ===== Window rules (from personal.conf; inert where the apps are absent) =====

-- WoW (Battle.net via Lutris/umu/Proton; Hyprland sees class=steam_app_default)
o.window({ class = "^(steam_app_default)$", title = "^(World of Warcraft)$" }, {
  name = "wow",
  workspace = "5 silent",
  fullscreen = 1,
  idle_inhibit = "fullscreen",
  immediate = 1,
  tag = "-default-opacity",
  opacity = "1 1",
})

-- Tile the main Steam launcher (omarchy defaults float it)
o.window({ class = "^(steam)$", title = "^(Steam)$" }, {
  name = "steam-tiled",
  float = false,
})
