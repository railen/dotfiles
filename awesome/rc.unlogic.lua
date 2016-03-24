-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Widget and layout library
require("wibox")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Logging library
require("log")
-- Awesome MPD widget
require("awesompd/awesompd")
-- Vicious widget library
require("vicious")
-- Scratchpad
require("scratch")
-- Blingbling widget library
require("blingbling")
-- Menubar
require("menubar")
-- Hideable minitray
require("minitray")
-- Utility
require("utility")
-- Launchbar
require("launchbar")

-- Map useful functions outside
calc = utility.calc
nprint = utility.nprint
dprint = utility.dprint
notify_at = utility.notify_at

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- Autorun programs
autorun = true

autorunApps =  
   { 
   "setxkbmap -layout 'us,ua,ru' -variant ',winkeys,winkeys' -option grp:alt_shift_toggle -option compose:ralt -option terminate:ctrl_alt_bksp",
   "kbdd"
}

runOnceApps = {
   "emacs --daemon",
   "thunderbird",
   "mpd",
   "xrdb -merge /home/unlogic/.Xresources"
}

if autorun then
   for app = 1, #autorunApps do
      awful.util.spawn(autorunApps[app])
   end
   for app = 1, #runOnceApps do
      utility.run_once(runOnceApps[app])
   end
end

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/conscience/theme.lua")
beautiful.onscreen.init()

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
   {
   awful.layout.suit.floating, 	        -- 1
   awful.layout.suit.tile, 		-- 2
   awful.layout.suit.tile.bottom,	-- 3
   awful.layout.suit.max		-- 4
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
   tags[s] = awful.tag({ "α", "β", "δ", "λ", "θ", "Ω"}, s, {layouts[1], layouts[4], layouts[2], layouts[1], layouts[1], layouts[1]})
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
local mainmenu = { items = { 
                      { 'awesome', { { "restart", awesome.restart },
                                     { "quit", awesome.quit } }, 
                        beautiful.awesome_icon , width = 300 },
                   },
                   theme = { width = 150 } }

mymainmenu = awful.menu(mainmenu)

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M ")

-- Awesompd widget
musicwidget = awesompd:create()
musicwidget.font = "Liberation Mono"
musicwidget.scrolling = true
musicwidget.output_size = 30
musicwidget.update_interval = 10
musicwidget.path_to_icons = beautiful.icon_dir
musicwidget.debug_mode = true
musicwidget.jamendo_format = awesompd.FORMAT_MP3
musicwidget.show_album_cover = true
musicwidget.browser = "firefox"
musicwidget.mpd_config = "/home/unlogic/.mpdconf"
musicwidget.album_cover_size = 50
musicwidget.ldecorator = "| "
musicwidget.rdecorator = " |"
musicwidget.servers = {
   { server = "localhost",
     port = 6600 }
}
musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_toggle() },
 			       { "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
 			       { "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
 			       { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
 			       { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
 			       { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
                               { "", "XF86AudioLowerVolume", musicwidget:command_volume_down() },
                               { "", "XF86AudioRaiseVolume", musicwidget:command_volume_up() },
                               { modkey, "Pause", musicwidget:command_playpause() } })
musicwidget:run()

-- CPU widget
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu,
		 function (widget, args)
--                    infojets.update_cpu(args[1])
		    if string.len(args[1]) == 1 then
		       return "☢  " .. args[1] .. "% "
		    else
		       return "☢ " .. args[1] .. "% "
		    end
		 end)
cpuwidget:buttons(
   awful.util.table.join(awful.button({ }, 1, 
				      function ()
					 awful.util.spawn(terminal .. " -e htop")
				      end),
                         awful.button({ }, 3,
				      function ()
                                         cpuwidget.width = 1
				      end)))

-- CPU temperature widget
cputempwidget = wibox.widget.textbox()
vicious.register(cputempwidget, vicious.widgets.thermal,
		 function (widget, args)
--                    infojets.update_temp(args[1])
		    return args[1] .. "°C"
		 end, 19, "thermal_zone0" )

-- Memory widget
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, 
                 function (widget, args)
--                    infojets.update_ram(args[2], args[4])
                    return "♻ " ..args[1].."%"
                 end, 13)

-- Battery widget
batcharge_label = wibox.widget.textbox()
batcharge_label:set_markup("⚡ ")

battery_charge=blingbling.progress_bar.new() 
battery_charge:set_height(19)
battery_charge:set_width(13)
battery_charge:set_v_margin(3)
battery_charge:add_value(0.5)
battery_charge:set_show_text(true)
battery_charge:set_horizontal(false)
battery_charge:set_graph_color(beautiful.motive)
battery_charge:set_text_color(beautiful.bg_focus_color)
battery_charge:set_background_text_color("#00000000")
battery_charge:set_label("")
battery_charge.info_path = "/sys/class/power_supply/BAT0/"

function if_battery_present(w)
   if not w.info_path then 
      return false 
   end
   local fr = awful.util.file_readable
   return fr(w.info_path .. "status") 
   and fr(w.info_path .. "energy_now") and fr(w.info_path .. "energy_full")
end

function update_battery(w, readfunc)
   local st = readfunc(w.info_path .. "status", "*line")
   local ch = readfunc(w.info_path .. "energy_now", "*line")
   local max = readfunc(w.info_path .. "energy_full", "*line")
   local battery = ch / max
   if st:match("Charging") then 
      w:set_label("▲")
   elseif st:match("Discharging") then
      w:set_label("▼")
      if battery <= 0.1 then
	 naughty.notify({ title      = "Battery Warning"
			  , text       = "Battery low! " .. battery * 100 .."%" .. " left!"
			  , timeout    = 5
			  , position   = "top_right"
		       })
      end
   else
      w:set_label("")
   end
   w:add_value(battery)
end

if if_battery_present(battery_charge) then
   utility.repeat_every(function () 
                           update_battery(battery_charge, utility.slurp)
                        end, 10)
end

-- Quick launch bar widget
launchbar.icon_dirs = { beautiful.icon_dir }
w_launchbar = launchbar.new(awful.util.getdir("config") .. "/launchbar/")

-- Keyboard widget
kbdwidget = wibox.widget.textbox()
kbdwidget:set_markup(" ✡ US")
dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
    local data = {...}
    local layout = data[2]
    lts = {[0] = "✡ US", [1] = "★ UA", [2] = "☭ RU"}
    kbdwidget:set_markup(" " .. lts[layout])
    end
)

-- Volume widget
require('blingbling')
volume_label = wibox.widget.textbox()
volume_label:set_markup('♫ ')
my_volume=blingbling.volume.new()
my_volume:set_height(18)
my_volume:set_v_margin(4)
my_volume:set_width(20)
my_volume:update_master()
my_volume:set_master_control()
my_volume:set_bar(true)
my_volume:set_background_graph_color("#444444")--beautiful.bg_focus)
my_volume:set_graph_color(beautiful.motive)--beautiful.fg_normal)

-- Menubar widget
menubar.cache_entries = true
menubar.app_folders = { "/usr/share/applications/" }
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ }, 4, awful.tag.viewnext),
   awful.button({ }, 5, awful.tag.viewprev)
)
mytasklist = {}
instance = nil
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
			   if not c:isvisible() then
			      awful.tag.viewonly(c:tags()[1])
			   end
			   client.focus = c
			   c:raise()
			end),
   awful.button({ }, 3, function ()
                           if instance then
                              instance:hide()
                              instance = nil
                           else
                              instance = awful.menu.clients({ width=250 }, 
                                                            { callback = function()
                                                                            instance = nil
                                                                         end})
                           end
                        end),
   awful.button({ }, 4, function ()
                           awful.client.focus.byidx(1)
                           if client.focus then client.focus:raise() end
                        end),
   awful.button({ }, 5, function ()
                           awful.client.focus.byidx(-1)
                           if client.focus then client.focus:raise() end
                        end))

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
                             awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s })

   -- Widgets that are aligned to the left

   local separator = wibox.widget.textbox()
   separator:set_markup(" | ")
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mylauncher)
   left_layout:add(mytaglist[s])
   left_layout:add(separator) ---
   left_layout:add(w_launchbar)
   left_layout:add(separator) ---
--   if s == 1 then left_layout:add(wibox.widget.systray()) end
--   left_layout:add(separator) ---
   left_layout:add(mypromptbox[s])

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   right_layout:add(musicwidget.widget)
   right_layout:add(kbdwidget)
   right_layout:add(separator)
   right_layout:add(cpuwidget)
   right_layout:add(cputempwidget)
   right_layout:add(separator) ---
   right_layout:add(memwidget)
   right_layout:add(separator) ---
   right_layout:add(volume_label)
   right_layout:add(my_volume.widget)
   right_layout:add(separator) ---
   right_layout:add(batcharge_label)
   right_layout:add(battery_charge.widget)
   right_layout:add(separator) ---
   right_layout:add(mytextclock)
   right_layout:add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
-- root.buttons(awful.util.table.join(
--     awful.button({ }, 3, function () mymainmenu:toggle() end),
--     awful.button({ }, 4, awful.tag.viewnext),
--     awful.button({ }, 5, awful.tag.viewprev)
-- ))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ modkey,           }, "p",   function()  menubar.show() end ),
   awful.key({ modkey, "Control" }, "p",   function()  minitray.toggle() end ),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore),

    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () scratch.drop("urxvt -pe tabbed", "top", "center", 1, 0.5) end),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    awful.key({ }, "Print", function () awful.util.spawn("scrot -e 'mv $f ~/.cache/scrot/'") end),
    awful.key({ "Control" }, "Print", function () awful.util.spawn("scrot -s -e 'mv $f ~/.cache/scrot/'") end),
    awful.key({ modkey }, "Print", function () awful.util.spawn("scrot -d 5 -e 'mv $f ~/.cache/scrot/'") end),
    awful.key({ modkey }, "b", function ()
				  mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
                                  local clients = client.get()
                                  local curtagclients = {}
                                  local tags = screen[mouse.screen]:tags()
                                  for _, c in ipairs(clients) do
                                     for k, t in ipairs(tags) do
                                        if t.selected then
                                           local ctags = c:tags()
                                           for _, v in ipairs(ctags) do
                                              if v == t then
                                                 table.insert(curtagclients, c)
                                              end
                                           end
                                        end
                                     end
                                  end
                                  for _, c in ipairs(curtagclients) do
                                     if c.maximized_vertical then
                                        c.maximized_vertical = false
                                        c.maximized_vertical = true
                                     end
                                  end
			       end),
    -- Prompt
    awful.key({ modkey }, "r", function () 
                                  local promptbox = mypromptbox[mouse.screen]
                                  awful.prompt.run({ prompt = promptbox.prompt,
                                                     bg_cursor = beautiful.bg_focus_color },
                                                   promptbox.widget,
                                                   function (...)
                                                      local result = awful.util.spawn(...)
                                                      if type(result) == "string" then
                                                         promptbox.widget:set_text(result)
                                                      end
                                                   end,
                                                   awful.completion.shell,
                                                   awful.util.getdir("cache") .. "/history")
                               end),
    awful.key({ modkey }, "x", function ()
                                  awful.prompt.run({ prompt = "Run Lua code: ", 
                                                     bg_cursor = beautiful.bg_focus_color },
                                                   mypromptbox[mouse.screen].widget,
                                                   awful.util.eval, nil,
                                                   awful.util.getdir("cache") .. "/history_eval")
                               end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey, "Control" }, "Return", function (c) scratch.drop.toggle_droppable(c, "urxvt -pe tabbed", "top", "center", 1, 0.5) end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
musicwidget:append_global_keys()
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true,
                     tag = tags[1][6]} },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Chromium-browser" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Iceweasel" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][5], 
                     floating = true } },
    { rule = { class = "Skype" },
      properties = { tag = tags[1][5], 
                     floating = true } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
