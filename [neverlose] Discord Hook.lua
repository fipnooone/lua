--https://neverlose.cc/market/item?id=gxQ6Zl
--discord rich presence and shot logs
--https://github.com/discord/discord-rpc/releases/download/v3.4.0/discord-rpc-win.zip, unpack "discord-rpc\win32-dynamic\bin\discord-rpc.dll" in C:\Windows\SysWOW64

local ffi = require("ffi")
-- < Menu
local Webhook_switch = menu.Switch("Webhook:", "On", true)
local Hits_switch = menu.Switch("Webhook:", "Hits", false)
local Mismatch_switch = menu.Switch("Webhook:", "Mismatches", true)
local Resolver_switch = menu.Switch("Webhook:", "Resolver misses", true)
local Spread_switch = menu.Switch("Webhook:", "Spread misses", true)
local Prediction_switch = menu.Switch("Webhook:", "Prediction misses", true)
local UserShow_switch = menu.Switch("Webhook:", "Log username", false)
local webhookUrl = menu.TextBox("Webhook:", "Webhook URL:", 256, "")

local DRP_switch = menu.Switch("Discord Rich Presence:", "On", false)
local RPC_Combo = menu.MultiCombo("Discord Rich Presence:", "Show:", {"Server IP", "Server Name", "Team scores", "Your score"}, 0)
-- Menu >

local username = cheat.GetCheatUserName()
-- < DRP lib
local DRPwas = false
local function loadRPC()
    DiscordRPClib = ffi.load("C:\\Windows\\SysWOW64\\discord-rpc")

    ffi.cdef[[
    typedef struct DiscordRichPresence {
        const char* state;   /* max 128 bytes */
        const char* details; /* max 128 bytes */
        int64_t startTimestamp;
        int64_t endTimestamp;
        const char* largeImageKey;  /* max 32 bytes */
        const char* largeImageText; /* max 128 bytes */
        const char* smallImageKey;  /* max 32 bytes */
        const char* smallImageText; /* max 128 bytes */
        const char* partyId;        /* max 128 bytes */
        int partySize;
        int partyMax;
        const char* matchSecret;    /* max 128 bytes */
        const char* joinSecret;     /* max 128 bytes */
        const char* spectateSecret; /* max 128 bytes */
        int8_t instance;
    } DiscordRichPresence;

    typedef struct DiscordUser {
        const char* userId;
        const char* username;
        const char* discriminator;
        const char* avatar;
    } DiscordUser;

    typedef void (*readyPtr)(const DiscordUser* request);
    typedef void (*disconnectedPtr)(int errorCode, const char* message);
    typedef void (*erroredPtr)(int errorCode, const char* message);
    typedef void (*joinGamePtr)(const char* joinSecret);
    typedef void (*spectateGamePtr)(const char* spectateSecret);
    typedef void (*joinRequestPtr)(const DiscordUser* request);

    typedef struct DiscordEventHandlers {
        readyPtr ready;
        disconnectedPtr disconnected;
        erroredPtr errored;
        joinGamePtr joinGame;
        spectateGamePtr spectateGame;
        joinRequestPtr joinRequest;
    } DiscordEventHandlers;

    void Discord_Initialize(const char* applicationId,
                            DiscordEventHandlers* handlers,
                            int autoRegister,
                            const char* optionalSteamId);

    void Discord_Shutdown(void);

    void Discord_RunCallbacks(void);

    void Discord_UpdatePresence(const DiscordRichPresence* presence);

    void Discord_ClearPresence(void);

    void Discord_Respond(const char* userid, int reply);

    void Discord_UpdateHandlers(DiscordEventHandlers* handlers);
    ]]

    DiscordRPC = {}

    local function checkArg(arg, argType, argName, func, maybeNil)
        assert(type(arg) == argType or (maybeNil and arg == nil),
            string.format("Argument \"%s\" to function \"%s\" has to be of type \"%s\"",
                argName, func, argType))
    end

    local function checkStrArg(arg, maxLen, argName, func, maybeNil)
        if maxLen then
            assert(type(arg) == "string" and arg:len() <= maxLen or (maybeNil and arg == nil),
                string.format("Argument \"%s\" of function \"%s\" has to be of type string with maximum length %d",
                    argName, func, maxLen))
        else
            checkArg(arg, "string", argName, func, true)
        end
    end

    local function checkIntArg(arg, maxBits, argName, func, maybeNil)
        maxBits = math.min(maxBits or 32, 52)
        local maxVal = 2^(maxBits-1)
        assert(type(arg) == "number" and math.floor(arg) == arg
            and arg < maxVal and arg >= -maxVal
            or (maybeNil and arg == nil),
            string.format("Argument \"%s\" of function \"%s\" has to be a whole number <= %d",
                argName, func, maxVal))
    end

    function DiscordRPC.initialize(applicationId, autoRegister, optionalSteamId)
        local func = "DiscordRPC.Initialize"
        checkStrArg(applicationId, nil, "applicationId", func)
        checkArg(autoRegister, "boolean", "autoRegister", func)
        if optionalSteamId ~= nil then
            checkStrArg(optionalSteamId, nil, "optionalSteamId", func)
        end

        local eventHandlers = ffi.new("struct DiscordEventHandlers")

        DiscordRPClib.Discord_Initialize(applicationId, eventHandlers,
            autoRegister and 1 or 0, optionalSteamId)
    end

    function DiscordRPC.shutdown()
        DiscordRPClib.Discord_Shutdown()
    end

    function DiscordRPC.runCallbacks()
        DiscordRPClib.Discord_RunCallbacks()
    end

    function DiscordRPC.updatePresence(presence)
        local func = "DiscordRPC.updatePresence"
        checkArg(presence, "table", "presence", func)
        checkStrArg(presence.state, 127, "presence.state", func, true)
        checkStrArg(presence.details, 127, "presence.details", func, true)

        checkIntArg(presence.startTimestamp, 64, "presence.startTimestamp", func, true)
        checkIntArg(presence.endTimestamp, 64, "presence.endTimestamp", func, true)

        checkStrArg(presence.largeImageKey, 31, "presence.largeImageKey", func, true)
        checkStrArg(presence.largeImageText, 127, "presence.largeImageText", func, true)
        checkStrArg(presence.smallImageKey, 31, "presence.smallImageKey", func, true)
        checkStrArg(presence.smallImageText, 127, "presence.smallImageText", func, true)
        checkStrArg(presence.partyId, 127, "presence.partyId", func, true)

        checkIntArg(presence.partySize, 32, "presence.partySize", func, true)
        checkIntArg(presence.partyMax, 32, "presence.partyMax", func, true)

        checkStrArg(presence.matchSecret, 127, "presence.matchSecret", func, true)
        checkStrArg(presence.joinSecret, 127, "presence.joinSecret", func, true)
        checkStrArg(presence.spectateSecret, 127, "presence.spectateSecret", func, true)

        checkIntArg(presence.instance, 8, "presence.instance", func, true)

        local cpresence = ffi.new("struct DiscordRichPresence")
        cpresence.state = presence.state
        cpresence.details = presence.details
        cpresence.startTimestamp = presence.startTimestamp or 0
        cpresence.endTimestamp = presence.endTimestamp or 0
        cpresence.largeImageKey = presence.largeImageKey
        cpresence.largeImageText = presence.largeImageText
        cpresence.smallImageKey = presence.smallImageKey
        cpresence.smallImageText = presence.smallImageText
        cpresence.partyId = presence.partyId
        cpresence.partySize = presence.partySize or 0
        cpresence.partyMax = presence.partyMax or 0
        cpresence.matchSecret = presence.matchSecret
        cpresence.joinSecret = presence.joinSecret
        cpresence.spectateSecret = presence.spectateSecret
        cpresence.instance = presence.instance or 0

        DiscordRPClib.Discord_UpdatePresence(cpresence)
    end

    function DiscordRPC.clearPresence()
        DiscordRPClib.Discord_ClearPresence()
    end

    DiscordRPC.initialize("771352749182418965", true)
end
-- DRP lib >
-- < Webhook
local weapons = {
    [0] = "",
    [1] = "Desert Eagle",
    [2] = "Dual Berettas",
    [3] = "Five-SeveN",
    [4] = "Glock-18",
    [64] = "R8 Revolver",
    [63] = "CZ75-Auto",
    [7] = "AK-47",
    [8] = "AUG",
    [9] = "AWP",
    [10] = "FAMAS",
    [11] = "G3SG1",
    [61] = "USP-S",
    [13] = "Galil AR",
    [14] = "M249",
    [60] = "M4A1-S",
    [16] = "M4A4",
    [17] = "MAC-10",
    [18] = "",
    [19] = "P90",
    [20] = "",
    [21] = "",
    [22] = "",
    [23] = "MP5-SD",
    [24] = "UMP-45",
    [25] = "XM1014",
    [26] = "PP-Bizon",
    [27] = "MAG-7",
    [28] = "Negev",
    [29] = "Sawed-Off",
    [30] = "Tec-9",
    [31] = "Zeus x27",
    [32] = "P2000",
    [33] = "MP7",
    [34] = "MP9",
    [35] = "Nova",
    [36] = "P250",
    [37] = "Ballistic Shield",
    [38] = "SCAR-20",
    [39] = "SG 553",
    [40] = "SSG 08",
    [41] = "Knife",
    [42] = "Knife",
    [59] = "Knife",
    [43] = "Flashbang",
    [44] = "High Explosive Grenade",
    [45] = "Smoke Grenade",
    [46] = "Molotov",
    [47] = "Decoy Grenade",
    [506] = "Gut Knife",
    [507] = "Karambit",
    [508] = "M9 Bayonet",
    [509] = "Huntsman Knife",
    [512] = "Falchion Knife",
    [514] = "Bowie Knife"
}
local hitgroups = {
    [0] = "Generic",
    [1] = "Head",
    [2] = "Chest",
    [3] = "Stomach",
    [4] = "Left arm",
    [5] = "Right arm",
    [6] = "Left leg",
    [7] = "Right leg",
    [10] = "Gear"
}

local function webhook(message)
    local embed = [[
        payload = {
            embeds: [
                {
                    title: "%s",
                    color: %s,
                    fields: [
                        {
                            name: "Target name:",
                            value: "%s"
                        },
                        {
                            name: "Damage:",
                            value: "%s"
                        },
                        {
                            name: "Hitgroup:",
                            value: "%s"
                        },
                        {
                            name: "Hitchance:",
                            value: "%s"
                        },
                        {
                            name: "Backtrack:",
                            value: "%s"
                        },%s
                        {
                            name: "Weapon:",
                            value: "%s"
                        }
                    ],
                    footer: {
                        text: "%s"
                    }
                }
            ]
        }

        $.AsyncWebRequest("%s", {
            type: "POST",
            data: {
                payload_json: JSON.stringify(payload)
            },
            headers: {
                "Content-Type": "application/json"
            }
        });
    ]]

    if Mismatch_switch:GetBool() and message["reason"] == 0 and ((message["damage"]["did"] < message["damage"]["estimated"] - 2) and message["damage"]["did"] < 101 and message["hitgroup"]["hit"] ~= message["hitgroup"]["estimated"]) then
        g_Panorama:Exec(string.format(embed, 
            "Mismatch", 39393,
            message["targetname"],
            "Estimated: "..message["damage"]["estimated"]..", Did: "..message["damage"]["did"],
            "Estimated: "..hitgroups[message["hitgroup"]["estimated"]]..", Hit: "..hitgroups[message["hitgroup"]["hit"]],
            message["hitchance"],
            message["backtrack"],
            "",
            weapons[message["weaponId"]],
            message["username"],
            webhookUrl:GetString()
        ))
    elseif Hits_switch:GetBool() and message["reason"] == 0 then
        g_Panorama:Exec(string.format(embed, 
            "Hit", 53606,
            message["targetname"],
            message["damage"]["did"],
            hitgroups[message["hitgroup"]["estimated"]],
            message["hitchance"],
            message["backtrack"],
            "",
            weapons[message["weaponId"]],
            message["username"],
            webhookUrl:GetString()
        ))
    end
    if Resolver_switch:GetBool() and message["reason"] == 1 then
        g_Panorama:Exec(string.format(embed, 
            "Missed shot due to Resolver", 16333359,
            message["targetname"],
            "Estimated: "..message["damage"]["estimated"],
            hitgroups[message["hitgroup"]["estimated"]],
            message["hitchance"],
            message["backtrack"],
            "",
            weapons[message["weaponId"]],
            message["username"],
            webhookUrl:GetString()
        ))
    end
    if Spread_switch:GetBool() and message["reason"] == 2 then
        g_Panorama:Exec(string.format(embed, 
            "Missed shot due to Spread", 16302848,
            message["targetname"],
            "Estimated: "..message["damage"]["estimated"],
            hitgroups[message["hitgroup"]["estimated"]],
            message["hitchance"],
            message["backtrack"],
            string.format("\n"..[[
                {
                    name: "Spread degree:",
                    value: "%s"
                },
            ]], message["spread_degree"]),
            weapons[message["weaponId"]],
            message["username"],
            webhookUrl:GetString()
        ))
    end
    if Spread_switch:GetBool() and message["reason"] == 3 then
        g_Panorama:Exec(string.format(embed, 
            "Missed shot due to Occlusion", 8007566,
            message["targetname"],
            "Estimated: "..message["damage"]["estimated"],
            hitgroups[message["hitgroup"]["estimated"]],
            message["hitchance"],
            message["backtrack"],
            string.format("\n"..[[
                {
                    name: "Spread degree:",
                    value: "%s"
                },
            ]], message["spread_degree"]),
            weapons[message["weaponId"]],
            message["username"],
            webhookUrl:GetString()
        ))
    end
    if Prediction_switch:GetBool() and message["reason"] == 4 then
        g_Panorama:Exec(string.format(embed, 
            "Missed shot due to Prediction error", 10887193,
            message["targetname"],
            "Estimated: "..message["damage"]["estimated"],
            hitgroups[message["hitgroup"]["estimated"]],
            message["hitchance"],
            message["backtrack"],
            "",
            weapons[message["weaponId"]],
            message["username"],
            webhookUrl:GetString()
        ))
    end
end

local shots = {}
local function ragebotShot(args)
    if not Webhook_switch:GetBool() or webhookUrl:GetString() == "" then
        return
    end
    shots = {
        targetIndex = args.index,
        damage = args.damage,
        hitgroup = args.hitgroup
    }
end

local function registeredShot(args)
    if not Webhook_switch:GetBool() or webhookUrl:GetString() == "" then
        return
    end

    local username_ = ""
    local weapodID = 0
    local hitchance_ = "no"

    local me = g_EntityList:GetClientEntity(g_EngineClient:GetLocalPlayer()):GetPlayer()
    if me:GetProp("DT_BasePlayer", "m_iHealth") > 0 then
        weapodID = me:GetActiveWeapon():GetWeaponID()
    end

    if UserShow_switch:GetBool() then
        username_ = "@"..username
    end

    if args.hitchance ~= -1 then
        hitchance_ = tostring(args.hitchance)
    end

    local message = {
        reason = args.reason,
        targetname = g_EntityList:GetClientEntity(shots["targetIndex"]):GetPlayer():GetName(),
        damage = {
            estimated = shots["damage"],
            did = args.damage
        },
        hitchance = hitchance_,
        backtrack = args.backtrack,
        spread_degree = args.spread_degree,
        hitgroup = {
            estimated = shots["hitgroup"],
            hit = args.hitgroup
        },
        weaponId = weapodID,
        color = 0,
        username = username_
    }
    webhook(message)
end
-- Webhook >
local function DRPcontrol()
    if not DRP_switch:GetBool() and DRPwas then
        DiscordRPC.clearPresence()
    end
    if DRP_switch:GetBool() and not DRPwas then
        loadRPC()
        DRPwas = true
    end
end

DRPcontrol()

local now = utils.UnixTime()

local maps = {
    "mirage", "inferno", "cache", "cobblestone", "aztec", "canals", "dust", "italy", "nuke", "rialto", "vertigo", "bank", "lake", "office", "safehouse", "marc", "train", "overpass"
}

local function forPresence(map, details_, state_)
    local presence = {
        details = string.sub(details_, 1, 127),
        startTimestamp = now,
        state = string.sub(state_, 1, 127)
    }
    presence.largeImageText = "Current map: "..string.sub(g_Panorama:Exec([[
       getMapName()
    ]]), 1, 110)
    for i = 1, table.getn(maps), 1 do
        if string.find(map, maps[i]) ~= nil then
            presence.largeImageKey = maps[i]
            presence.smallImageKey = "neverlose2"
            presence.smallImageText = "Neverlose.cc"
            return presence
        end
    end
    presence.largeImageKey = "neverlose2"
    return presence
end

g_Panorama:Exec([[
    var xuid = MyPersonaAPI.GetXuid();
    var teamdata;

    function getCTscore() {
        return teamdata.CT.score
    }
    function getTscore() {
        return teamdata.TERRORIST.score
    }
    function getServerName() {
        return GameStateAPI.GetServerName();
    }
    function IsConnectedCommunity() {
        return MatchStatsAPI.IsConnectedToCommunityServer().toString();
    }
    function getGameMode() {
        return MatchStatsAPI.GetGameMode();
    }
    function getTeam(xuid_) {
        return GameStateAPI.GetPlayerTeamName(xuid_);
    }
    function getKills(xuid_) {
        return GameStateAPI.GetPlayerKills(xuid_).toString()
    }
    function getAssists(xuid_) {
        return GameStateAPI.GetPlayerAssists(xuid_).toString()
    }
    function getDeaths(xuid_) {
        return GameStateAPI.GetPlayerDeaths(xuid_).toString()
    }
    function getMapName() {
        return GameStateAPI.GetMapName();
    }

]])

local timer_now = 0
local timer_past = utils.UnixTime()
local function interval()
    if not DRP_switch:GetBool() then
        return
    end
    timer_now = utils.UnixTime()
    if timer_now - timer_past >= 5000 then
        if g_EngineClient:IsConnected() then
            local details = ""
            local state = ""
            local servername = g_Panorama:Exec([[getServerName()]])
            if RPC_Combo:GetBool(0) and RPC_Combo:GetBool(1) then
                if string.len(servername) >= 23 then
                    servername = string.sub(servername, 8, 31).."..."
                end
                details = servername.." - IP: "..g_EngineClient:GetNetChannelInfo():GetAddress()
            elseif RPC_Combo:GetBool(0) and g_Panorama:Exec([[IsConnectedCommunity()]]) == "true" then
                details = g_EngineClient:GetNetChannelInfo():GetAddress()
            elseif RPC_Combo:GetBool(1) and g_Panorama:Exec([[IsConnectedCommunity()]]) == "true" then
                details = string.sub(servername, 8, 126)
            elseif g_Panorama:Exec([[IsConnectedCommunity()]]) == "true" then
                details = "Community server"
            else
                details = g_Panorama:Exec([[getGameMode()]])
            end

            g_Panorama:Exec([[
                teamdata = GameStateAPI.GetScoreDataJSO().teamdata
            ]])

            local team = g_Panorama:Exec([[getTeam(xuid)]])
            local CTscore = g_Panorama:Exec([[getCTscore().toString()]])
            local Tscore = g_Panorama:Exec([[getTscore().toString()]])
            local kills = g_Panorama:Exec([[getKills(xuid)]])
            local assists = g_Panorama:Exec([[getAssists(xuid)]])
            local deaths = g_Panorama:Exec([[getDeaths(xuid)]])
            if RPC_Combo:GetBool(2) and RPC_Combo:GetBool(3) then
                if team == "CT" then
                    state = "Score: CT: "..CTscore.." ["..kills.."-"..assists.."-"..deaths.."] / T: "..Tscore.." "
                elseif string.sub(team, 1, 1) == "T" then
                    state = "Score: CT: "..CTscore.." / T: "..Tscore.." ["..kills.."-"..assists.."-"..deaths.."] "
                else
                    state = "Score: CT: "..CTscore.." / T: "..Tscore.." (Spectating)"
                end
            elseif (RPC_Combo:GetBool(2)) then
                state = "Score: CT: "..CTscore.." / T: "..Tscore
            elseif (RPC_Combo:GetBool(3)) then
                state = "Score: ["..kills.."-"..assists.."-"..deaths.."]"
            end
            DiscordRPC.updatePresence(forPresence(g_EngineClient:GetLevelName(), details, state))
        else
            local presence = {
                details = "In menu",
                startTimestamp = now,
                largeImageKey = "neverlose2",
                largeImageText = "Neverlose.cc"
            }
            DiscordRPC.updatePresence(presence)
        end
        timer_past = timer_now
    end
end

local function onDestroy()
    DiscordRPC.clearPresence()
end

cheat.RegisterCallback("ragebot_shot", ragebotShot)
cheat.RegisterCallback("registered_shot", registeredShot)
cheat.RegisterCallback("draw", interval)
cheat.RegisterCallback("destroy", onDestroy)

DRP_switch:RegisterCallback(DRPcontrol)
