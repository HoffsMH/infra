-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- @DOC_REQUIRE_SECTION@
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")

local tile_deck = require("tile_deck")

-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local battery_widget = require("battery-widget.battery")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
-- @DOC_ERROR_HANDLING@
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Variable definitions
-- @DOC_LOAD_THEME@
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme.lua")


-- local bling = require("bling")

terminal = "kitty"
-- @DOC_DEFAULT_APPLICATIONS@
-- This is used later as the default terminal and editor to run.
scratchterminal = "kitty --class scratch scratch"
capterminal = "ecap"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod3"
-- }}}

-- {{{ Menu
-- @DOC_MENU@
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", scratchterminal }
                                  }
                        })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag
-- @DOC_LAYOUT@
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        tile_deck,
        awful.layout.suit.max,
    })
end)


-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %I:%M %p ")
mytextclock.forced_width = 90


-- @DOC_FOR_EACH_SCREEN@
screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag({ "", "", "", "", "", "", "scratch", "mpv", "cap" }, s, awful.layout.layouts[1])

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        disable_icon = true,

        filter  = function (t)
            return not (t.name == "scratch") and not (t.name == "mpv") and not (t.name == "cap")
        end,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- @TASKLIST_BUTTON@
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),

            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        },
        layout = {
            layout = wibox.layout.fixed.horizontal
        }
    }

    -- @DOC_WIBAR@
    -- Create the wibox
    s.mywibox = awful.wibar({
			position = "top",
			screen = s,
			height = 40,
			layout = wibox.layout.align.horizontal,
			shape = function(cr, width, height)
					gears.shape.rounded_rect(cr, width, height, 10)
			end,
			margins = {
					top   = 14,
					right = 14,
					left = 14
			},
		})

    -- @DOC_SETUP_WIDGETS@
    -- Add widgets to the wibox
     s.mywibox.widget = {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- wibox.widget.systray(),
            battery_widget({ show_current_level = true, font = "IBM Plex Sans Cond SmBld 7" }),
            mytextclock,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
-- @DOC_ROOT_BUTTONS@
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
})
-- }}}

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({

    awful.key({ modkey,           }, "a",
        function ()
            current = client.focus
            master = awful.client.getmaster()

            if current == master then
                awful.client.focus.history.previous ()
            else
                client.focus = awful.client.getmaster()
            end
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey,           }, "e", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),

    awful.key({ modkey,           }, "space", function ()
            local screen = awful.screen.focused()
            local scratchtag = screen.tags[7]
            local scratch = scratchtag:clients()[1]

            if scratch then
                awful.tag.viewtoggle(scratchtag)
                scratch:activate()
            else
                awful.spawn(scratchterminal)
            end
        end,
        {description = "open scratch"}),

    awful.key({ modkey,           }, "c", function ()
            local screen = awful.screen.focused()
            local captag = screen.tags[9]
            local cap = captag:clients()[1]

            if cap then
                awful.tag.viewtoggle(captag)
                cap:activate()
            else
                awful.spawn(capterminal)
            end
        end,
        {description = "open cap"}),

    awful.key({ modkey,           }, "m", function ()
            local screen = awful.screen.focused()
            local mpvtag = screen.tags[8]
            local mpv = mpvtag:clients()[1]

            if mpv then
                awful.tag.viewtoggle(mpvtag)
            end
        end,
        {description = "open mpv"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:activate { raise = true, context = "key.unminimize" }
                  end
              end,
              {description = "restore minimized", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "i",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey,           }, "d",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),

    awful.key({ modkey,  }, "p",
        function ()
            awful.layout.set(tile_deck)
            local t = awful.screen.focused().selected_tag
            t.master_count = 0
        end,
              {description = "set monocle", group = "layout"}),

    awful.key({ modkey,  }, "t",
        function ()
            awful.layout.set(tile_deck)
            local t = awful.screen.focused().selected_tag
            t.master_count = 1
        end,
              {description = "set tile", group = "layout"}),

    awful.key({ modkey,  }, ",",
        function ()
            local t = awful.screen.focused().selected_tag
            t.gap = t.gap -  10
            beautiful.useless_gap = t.gap
        end,
              {description = "decrement gaps on current tag", group = "layout"}),

    awful.key({ modkey,  }, ".",
        function ()
            local t = awful.screen.focused().selected_tag
            t.gap = t.gap + 10
            beautiful.useless_gap = t.gap
        end,
              {description = "decrement gaps on current tag", group = "layout"}),
})

-- @DOC_NUMBER_KEYBINDINGS@

awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            -- should go to screen 1 every time
            awful.screen.focus(screen.primary)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
})

-- @DOC_CLIENT_BUTTONS@
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),

        awful.button({ modkey }, 2, function (c)
            c.floating = not c.floating
        end),

        awful.button({ modkey }, 3, function (c)
            c.floating = true
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

-- @DOC_CLIENT_KEYBINDINGS@
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ "Control",         }, "q",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),

        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),

        awful.key({ modkey }, "Return",
            function (c)
                local master = awful.client.getmaster()

                if c.window == master.window then
                    awful.client.swap.byidx( 1)
                else
                    c:swap(awful.client.getmaster())
                end
            end,
                {description = "move to master", group = "client"}),

        awful.key({ modkey, "Shift"    }, "e",
            function (c)
                c:move_to_screen()
            end,
                {description = "move to screen", group = "client"}),

        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey, "Control", "Shift"}, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
-- @DOC_RULES@
ruled.client.connect_signal("request::rules", function()
    -- @DOC_GLOBAL_RULE@
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        }
    }

    ruled.client.append_rule {
        -- @DOC_CSD_TITLEBARS@
        id         = "titlebars",
        rule_any   = { type = { "normal", } },
        properties = { titlebars_enabled = false      }
    }

    -- @DOC_DIALOG_RULE@
    -- Add titlebars to dialogs
    ruled.client.append_rule {
        -- @DOC_CSD_TITLEBARS@
        id         = "titlebars",
        rule_any   = { type = { "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    -- @DOC_FLOATING_RULE@
    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {
            floating = true,
            titlebars_enabled = true,
            placement = awful.placement.centered,
         }
    }

    ruled.client.append_rule {
        rule       = { class = "Google-chrome", role = "pop-up"  },
        properties = { floating = false }
    }

    ruled.client.append_rule {
        rule       = { name = "Open Files"  },
        properties = {
            floating = true,
            placement = awful.placement.centered,
            width = "900",
            height = "700"
        }
    }

    ruled.client.append_rule {
        rule       = { name = "Save File"  },
        properties = {
            floating = true,
            placement = awful.placement.centered,
            width = "900",
            height = "700"
        }
    }

    ruled.client.append_rule {
        rule       = { class = "Subl"     },
        properties = { screen = screen.primary,
        tag = "" }
    }

    ruled.client.append_rule {
        rule       = { class = "Google-chrome"     },
        properties = { screen = screen.primary, tag = "" }
    }

-- awful.tag({ "", "", "", "", "", "", "scratch" }, s, awful.layout.layouts[1])
    ruled.client.append_rule {
        rule       = { class = "Brave-browser"     },
        properties = { screen = screen.primary, tag = "" }
    }


    ruled.client.append_rule {
        rule       = { class = "Slack"     },
        properties = { screen = screen.count()>1 and 2 or 1, tag = screen.count()>1 and "" or "" }
    }

    ruled.client.append_rule {
        rule       = { class = "scratch"     },
        properties = { floating = false, focus = false, tag = "scratch" }
    }

    ruled.client.append_rule {
        rule       = { class = "cap"     },
        properties = {
            titlebars_enabled = false,
            floating = true,
            focus = false,
            tag = "cap",
            placement = awful.placement.centered,
        }
    }

    ruled.client.append_rule {
        rule       = { class = "mpv"     },
        properties = { focus = false, tag = "mpv" }
    }
end)

-- }}}

-- {{{ Titlebars
-- @DOC_TITLEBARS@
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({ }, 1, function()
            c:activate { context = "titlebar", action = "mouse_move"  }
        end),
        awful.button({ }, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize"}
        end),
    }

    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("property::floating", function(c)
    if c.floating  and c.class ~= "cap" then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end)

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

