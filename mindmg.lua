-- beta // by fipnooone

local globals = csgo.interface_handler:get_global_vars( );

local menu = fatality.menu;
local config = fatality.config;
local input = fatality.input;

local render = fatality.render;

local options = config:add_item("options", 0);
local options_combo = menu:add_combo("Min-damage bind", "Rage", "Aimbot", "Aimbot", options);
options_combo:add_item("Hold", options);
options_combo:add_item("Toggle", options);

local auto_cfg, awp_cfg, pistols_cfg, scout_cfg, heavyp_cfg, other_cfg =
    {
        dmg = config:add_item("auto_dmg", 0),
        htc = config:add_item("auto_htc", 0)
    },
    {
        dmg = config:add_item("awp_dmg", 0),
        htc = config:add_item("awp_htc", 0)
    },
    {
        dmg = config:add_item("pistols_dmg", 0),
        htc = config:add_item("pistols_htc", 0)
    },
    {
        dmg = config:add_item("scout_dmg", 0),
        htc = config:add_item("scout_htc", 0)
    },
    {
        dmg = config:add_item("heavyp_dmg", 0),
        htc = config:add_item("heavyp_htc", 0)
    },
    {
        dmg = config:add_item("other_dmg", 0),
        htc = config:add_item("other_htc", 0)
    }

local backups = {
    auto = {
        dmg = config:get_weapon_setting("autosniper", "mindmg"):get_int(),
        htc = config:get_weapon_setting("autosniper", "hitchance"):get_int()
    },
    awp = {
        dmg = config:get_weapon_setting("awp", "mindmg"):get_int(),
        htc = config:get_weapon_setting("awp", "hitchance"):get_int()
    },
    pistols = {
        dmg = config:get_weapon_setting("pistol", "mindmg"):get_int(),
        htc = config:get_weapon_setting("pistol", "hitchance"):get_int()
    },
    scout = {
        dmg = config:get_weapon_setting("scout", "mindmg"):get_int(),
        htc = config:get_weapon_setting("scout", "hitchance"):get_int()
    },
    heavyp = {
        dmg = config:get_weapon_setting("heavy_pistol", "mindmg"):get_int(),
        htc = config:get_weapon_setting("heavy_pistol", "hitchance"):get_int()
    },
    other = {
        dmg = config:get_weapon_setting("other", "mindmg"):get_int(),
        htc = config:get_weapon_setting("other", "hitchance"):get_int()
    }
};


local auto_menu, awp_menu, pistols_menu, scout_menu, heavyp_menu, other_menu =
    {
        menu:add_slider("[damage] -- Auto", "Rage", "Aimbot", "Aimbot", auto_cfg.dmg, 0, 100, 0),
        menu:add_slider("[hitchance]", "Rage", "Aimbot", "Aimbot", auto_cfg.htc, 0, 100, 0)
    },
    {
        menu:add_slider("[damage] -- Scout", "Rage", "Aimbot", "Aimbot", scout_cfg.dmg, 0, 100, 0),
        menu:add_slider("[hitchance]", "Rage", "Aimbot", "Aimbot", scout_cfg.htc, 0, 100, 0)
    },
    {
        menu:add_slider("[damage] -- Awp", "Rage", "Aimbot", "Aimbot", awp_cfg.dmg, 0, 100, 0),
        menu:add_slider("[hitchance]", "Rage", "Aimbot", "Aimbot", awp_cfg.htc, 0, 100, 0)
    },
    {
        menu:add_slider("[damage] -- Heavy", "Rage", "Aimbot", "Aimbot", heavyp_cfg.dmg, 0, 100, 0),
        menu:add_slider("[hitchance]", "Rage", "Aimbot", "Aimbot", heavyp_cfg.htc, 0, 100, 0)
    },
    {
        menu:add_slider("[damage] -- Pistol", "Rage", "Aimbot", "Aimbot", pistols_cfg.dmg, 0, 100, 0),
        menu:add_slider("[hitchance]", "Rage", "Aimbot", "Aimbot", pistols_cfg.htc, 0, 100, 0)
    },
    {
        menu:add_slider("[damage] -- Other", "Rage", "Aimbot", "Aimbot", other_cfg.dmg, 0, 100, 0),
        menu:add_slider("[hitchance]", "Rage", "Aimbot", "Aimbot", other_cfg.htc, 0, 100, 0)
    }


function paint_mindamage_indicator()
    render:indicator(10, 600, "DMG", true , -1);
end

function manage_menu(toggle)
    if (toggle) then
        if (config:get_weapon_setting("autosniper", "mindmg"):get_int() ~= auto_cfg.dmg:get_int() or config:get_weapon_setting("autosniper", "hitchance"):get_int() ~= auto_cfg.htc:get_int() or
        config:get_weapon_setting("awp", "mindmg"):get_int() ~= awp_cfg.dmg:get_int() or config:get_weapon_setting("awp", "hitchance"):get_int() ~= awp_cfg.htc:get_int() or
        config:get_weapon_setting("pistol", "mindmg"):get_int() ~= pistols_cfg.dmg:get_int() or config:get_weapon_setting("pistol", "hitchance"):get_int() ~= pistols_cfg.htc:get_int() or
        config:get_weapon_setting("scout", "mindmg"):get_int() ~= scout_cfg.dmg:get_int() or config:get_weapon_setting("scout", "hitchance"):get_int() ~= scout_cfg.htc:get_int() or
        config:get_weapon_setting("heavy_pistol", "mindmg"):get_int() ~= heavyp_cfg.dmg:get_int() or config:get_weapon_setting("heavy_pistol", "hitchance"):get_int() ~= heavyp_cfg.htc:get_int() or
        config:get_weapon_setting("other", "mindmg"):get_int() ~= other_cfg.dmg:get_int() or config:get_weapon_setting("other", "hitchance"):get_int() ~= other_cfg.htc:get_int()) then
            backups = {
                auto = {
                    dmg = config:get_weapon_setting("autosniper", "mindmg"):get_int(),
                    htc = config:get_weapon_setting("autosniper", "hitchance"):get_int()
                },
                awp = {
                    dmg = config:get_weapon_setting("awp", "mindmg"):get_int(),
                    htc = config:get_weapon_setting("awp", "hitchance"):get_int()
                },
                pistols = {
                    dmg = config:get_weapon_setting("pistol", "mindmg"):get_int(),
                    htc = config:get_weapon_setting("pistol", "hitchance"):get_int()
                },
                scout = {
                    dmg = config:get_weapon_setting("scout", "mindmg"):get_int(),
                    htc = config:get_weapon_setting("scout", "hitchance"):get_int()
                },
                heavyp = {
                    dmg = config:get_weapon_setting("heavy_pistol", "mindmg"):get_int(),
                    htc = config:get_weapon_setting("heavy_pistol", "hitchance"):get_int()
                },
                other = {
                    dmg = config:get_weapon_setting("other", "mindmg"):get_int(),
                    htc = config:get_weapon_setting("other", "hitchance"):get_int()
                }
            };
        end
        paint_mindamage_indicator();
        config:get_weapon_setting("autosniper", "mindmg"):set_int(auto_cfg.dmg:get_int());
        config:get_weapon_setting("autosniper", "hitchance"):set_int(auto_cfg.htc:get_int());
        config:get_weapon_setting("awp", "mindmg"):set_int(awp_cfg.dmg:get_int());
        config:get_weapon_setting("awp", "hitchance"):set_int(awp_cfg.htc:get_int());
        config:get_weapon_setting("pistol", "mindmg"):set_int(pistols_cfg.dmg:get_int());
        config:get_weapon_setting("pistol", "hitchance"):set_int(pistols_cfg.htc:get_int());
        config:get_weapon_setting("scout", "mindmg"):set_int(scout_cfg.dmg:get_int());
        config:get_weapon_setting("scout", "hitchance"):set_int(scout_cfg.htc:get_int());
        config:get_weapon_setting("heavy_pistol", "mindmg"):set_int(heavyp_cfg.dmg:get_int());
        config:get_weapon_setting("heavy_pistol", "hitchance"):set_int(heavyp_cfg.htc:get_int());
        config:get_weapon_setting("other", "mindmg"):set_int(other_cfg.dmg:get_int());
        config:get_weapon_setting("other", "hitchance"):set_int(other_cfg.htc:get_int());
    else
        if (config:get_weapon_setting("autosniper", "mindmg"):get_int() == auto_cfg.dmg:get_int() or config:get_weapon_setting("autosniper", "hitchance"):get_int() == auto_cfg.htc:get_int() or
        config:get_weapon_setting("awp", "mindmg"):get_int() == awp_cfg.dmg:get_int() or config:get_weapon_setting("awp", "hitchance"):get_int() == awp_cfg.htc:get_int() or
        config:get_weapon_setting("pistol", "mindmg"):get_int() == pistols_cfg.dmg:get_int() or config:get_weapon_setting("pistol", "hitchance"):get_int() == pistols_cfg.htc:get_int() or
        config:get_weapon_setting("scout", "mindmg"):get_int() == scout_cfg.dmg:get_int() or config:get_weapon_setting("scout", "hitchance"):get_int() == scout_cfg.htc:get_int() or
        config:get_weapon_setting("heavy_pistol", "mindmg"):get_int() == heavyp_cfg.dmg:get_int() or config:get_weapon_setting("heavy_pistol", "hitchance"):get_int() == heavyp_cfg.htc:get_int() or
        config:get_weapon_setting("other", "mindmg"):get_int() == other_cfg.dmg:get_int() or config:get_weapon_setting("other", "hitchance"):get_int() == other_cfg.htc:get_int()) then
            config:get_weapon_setting("autosniper", "mindmg"):set_int(backups.auto.dmg);
            config:get_weapon_setting("autosniper", "hitchance"):set_int(backups.auto.htc);
            config:get_weapon_setting("awp", "mindmg"):set_int(backups.awp.dmg);
            config:get_weapon_setting("awp", "hitchance"):set_int(backups.awp.htc);
            config:get_weapon_setting("pistol", "mindmg"):set_int(backups.pistols.dmg);
            config:get_weapon_setting("pistol", "hitchance"):set_int(backups.pistols.htc);
            config:get_weapon_setting("scout", "mindmg"):set_int(backups.scout.dmg);
            config:get_weapon_setting("scout", "hitchance"):set_int(backups.scout.htc);
            config:get_weapon_setting("heavy_pistol", "mindmg"):set_int(backups.heavyp.dmg);
            config:get_weapon_setting("heavy_pistol", "hitchance"):set_int(backups.heavyp.htc);
            config:get_weapon_setting("other", "mindmg"):set_int(backups.other.dmg);
            config:get_weapon_setting("other", "hitchance"):set_int(backups.other.htc);
        end
    end
end

local key = 0x06; -- change here
local last_timer = globals.tickcount;

function on_paint()
    local hold = options:get_int() == 0;

    if (hold) then
        if ( input:is_key_down(key)) then
            manage_menu(true);
        else
            manage_menu(false);
        end
    else
        if ( input:is_key_down(key) and globals.tickcount - last_timer > 20) then
            toggled = not toggled;
            last_timer = globals.tickcount;
        end
        if (toggled) then
            manage_menu(true);
        else
            manage_menu(false);
        end
    end
end

local callbacks = fatality.callbacks;
callbacks:add("paint", on_paint);
