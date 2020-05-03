local render = fatality.render
local events = csgo.interface_handler:get_events()
local cvar = csgo.interface_handler:get_cvar()
local global_vars = csgo.interface_handler:get_global_vars()
local font = render:create_font("smallest pixel-7", 18, 100, true)

events:add_event("bomb_beginplant")
events:add_event("bomb_abortplant")
events:add_event("bomb_planted")
events:add_event("bomb_exploded")
events:add_event("bomb_defused")
events:add_event("round_start")
events:add_event("bomb_begindefuse")
events:add_event("bomb_abortdefuse")

local screen_size = render:screen_size()
local event_name = ""
local bomb = {
    planted = false,
    planting = false,
    defusing = false,
    planted_time = 0,
    planting_time = 0,
    defusing_time = 0,
    haskit = false
}

local timers = {
    bomb = 0,
    planting = 0,
    defusing = 0,
    timefordef = 10
}

function on_event(event)
    event_name = event:get_name()

    if (event_name == "bomb_planted") then
        bomb.planted = true
        bomb.planting = false
        bomb.planting_time = 0
        timers.planting = 0
        bomb.planted_time = global_vars.curtime
    elseif (event_name == "bomb_beginplant") then
        bomb.planting = true
        bomb.planting_time = global_vars.curtime
    elseif (event_name == "bomb_abortplant") then
        bomb.planting = false
        bomb.planting_time = 0
        timers.planting = 0
    elseif (event_name == "bomb_exploded" or event_name == "bomb_defused") then
        bomb.planted = false
        bomb.defusing = false
        bomb.planted_time = 0
        bomb.defusing_time = 0
        timers.defusing = 0
    elseif (event_name == "round_start") then
        bomb.planted = false
        bomb.planting = false
        bomb.defusing = false
        bomb.defusing_time = 0
        bomb.planted_time = 0
        bomb.planting_time = 0
        timers.planting = 0
        timers.defusing = 0
        timers.bomb = 0
        timers.timefordef = 0
    elseif (event_name == "bomb_begindefuse") then
        bomb.defusing = true
        bomb.defusing_time = global_vars.curtime
        if (event:get_bool("haskit")) then
            bomb.haskit = true
        end
    elseif (event_name == "bomb_abortdefuse") then
        bomb.defusing = false
        bomb.defusing_time = 0
        timers.defusing = 0
    end    
end


function on_paint()
    if (bomb.planted == true) then
        if (39.8 - timers.bomb < 0) then
            timers.bomb = 40
        else
            timers.bomb = global_vars.curtime - bomb.planted_time
        end
        render:text(font, screen_size.x - timers.bomb * (screen_size.x / 40) + 2, -3, string.format("%2.2f", 40 - timers.bomb), csgo.color(255, 255, 255, 200))
        render:rect_filled(0, 0, screen_size.x - timers.bomb * (screen_size.x / 40), 12, csgo.color(224, 58, 58, 130))
    elseif (bomb.planting == true) then
        if (2.9 - timers.planting < 0) then
            timers.planting = 3
        else
            timers.planting = global_vars.curtime - bomb.planting_time
        end
        render:text(font, screen_size.x - timers.planting * (screen_size.x / 3) + 2, -3, string.format("%2.2f", 3 - timers.planting), csgo.color(255, 255, 255, 200))
        render:rect_filled(0, 0, screen_size.x - timers.planting * (screen_size.x / 3), 12, csgo.color(115, 140, 255, 100))
    end
    if (bomb.defusing == true) then
        if (bomb.haskit) then 
            timers.timefordef = 5
        end

        local def_colors = {
            r = 35,
            g = 194,
            b = 93
        }

        if (40 - timers.bomb - timers.timefordef < 0) then
            def_colors.r, def_colors.g, def_colors.b = 194, 35, 35
        end

        if (timers.timefordef - 0.1 - timers.defusing < 0) then
            timers.defusing = timers.timefordef
        else
            timers.defusing = global_vars.curtime - bomb.defusing_time
        end
        render:text(font, screen_size.x - (timers.defusing + 40 - timers.timefordef) * (screen_size.x / 40) + 2, 9, string.format("%2.2f", timers.timefordef - timers.defusing), csgo.color(255, 255, 255, 200))
        render:rect_filled(0, 12, screen_size.x - (timers.defusing + 40 - timers.timefordef) * (screen_size.x / 40), 12, csgo.color(def_colors.r, def_colors.g, def_colors.b, 130))
        cvar:print_console("BOMB:" .. ", planted:" .. tostring(bomb.planted)  .. ", planting:" .. tostring(bomb.planting)  .. ", defusing:" .. tostring(bomb.defusing)  .. ", planted_time:" .. tostring(bomb.planted_time)  .. ", planting_time:" .. tostring(bomb.planting_time)  .. ", haskit:" .. tostring(bomb.haskit)  .. "\n", csgo.color(0, 200, 255, 255))
        cvar:print_console("TIMERS:"  .. ", bomb:" .. tostring(timers.bomb)  .. ", planting:" .. tostring(timers.planting)  .. ", defusing:" .. tostring(timers.defusing)  .. ", timefordef:" .. tostring(timers.timefordef) .. "\n", csgo.color(0, 200, 255, 255))
    end
end

local callbacks = fatality.callbacks
callbacks:add("paint", on_paint)
callbacks:add("events", on_event)
