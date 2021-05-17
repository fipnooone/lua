--https://neverlose.cc/market/item?id=gxQ6Zl
--discord rich presence
--https://github.com/discord/discord-rpc/releases/download/v3.4.0/discord-rpc-win.zip, unpack "discord-rpc\win32-dynamic\bin\discord-rpc.dll" in C:\Windows\SysWOW64

local DRPwas = false
local ffi = require("ffi")
local rpcMenu = {
    main = {
        on = menu.Switch("Discord Rich Presence:", "On", false),
        show = menu.MultiCombo("Discord Rich Presence:", "Show in game:", {"Server IP", "Server Name", "Team scores", "Your score"}, 0)
    },
    images = {
        largeNeverloseImage = menu.Combo("Images:", "Large image", {"CS:GO NL Logo", "CS:GO Logo", "NL logo with text", "NL Logo", "\"NL\""}, 0),
        largeNeverloseImageColor = menu.Combo("Images:", "Color (Large image)", {""}, 0),
        smallNeverloseImage = menu.Combo("Images:", "Small image", {"CS:GO NL Logo", "CS:GO Logo", "NL logo with text", "NL Logo", "\"NL\"", "None"}, 2),
        smallNeverloseImageColor = menu.Combo("Images:", "Color (Small image)", {""}, 0),
    },
    custom = {
        on = menu.Switch("Customize:", "On", false),
        largeNeverloseImageText = menu.TextBox("Customize:", "Large icon text:", 126, "Neverlose.cc"),
        smallNeverloseImageText = menu.TextBox("Customize:", "Small icon text:", 126, "Neverlose.cc"),
        largeMapImageText = menu.TextBox("Customize:", "Map image text:", 95, "Current map:"),
        inMenuText = menu.TextBox("Customize:", "In menu text:", 126, "In main menu"),
        gameMode = menu.TextBox("Customize:", "Game mode:", 126, "Game mode:"),
        playersInLobby = menu.TextBox("Customize:", "Players in lobby:", 126, "Players in lobby:"),
        inSearch = menu.TextBox("Customize:", "In search:", 126, "In search:"),
        loadingIn = menu.TextBox("Customize:", "Loading in:", 126, "Loading in:"),
        communityServer = menu.TextBox("Customize:", "Community server:", 126, "Community server /"),
        valveServer = menu.TextBox("Customize:", "Valve server:", 126, "Valve server /"),
        localServer = menu.TextBox("Customize:", "Local server:", 126, "Local server /"),
        scoresText = menu.TextBox("Customize:", "Score:", 85, "Score:"),
        update_button = menu.Button("Customize:", "                                  Update                                  "),
        reset_button = menu.Button("Customize:", "                             Set defaults                              ")
    },
    lobby = {
        on = menu.Switch("Lobby:", "On", true),
        showPlayers = menu.Switch("Lobby:", "Show number of players in lobby:", true),
        showSearch = menu.Switch("Lobby:", "Show if you're in game search:", true),
        showMode = menu.Switch("Lobby:", "Show game mode:", true)
    }
}

g_Panorama:Exec([[
    var xuid = MyPersonaAPI.GetXuid();
    var lobbyMode = "";
    var currPlayers = 1;
    var maxPlayers = 5;
    var waitForUpdateEventHandler_Upd = null;
    var mmqueue = "";
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
    function getMapName() {
        return GameStateAPI.GetMapName();
    }
    function updateLobbyInfo() {
        var lobbySettings = LobbyAPI.GetSessionSettings();
        if (lobbySettings.game) {
            lobbyMode = lobbySettings.game.mode;
            currPlayers = lobbySettings.members.numPlayers;
            if (lobbySettings.game.mmqueue) {
                if (lobbySettings.game.mmqueue == "searching"){
                    mmqueue = "searching";
                }
                else if (lobbySettings.game.mmqueue == "connect") {
                    mmqueue = "connect";
                }  
            }
            else {
                mmqueue = "";
                if ((lobbyMode == "scrimcomp2v2") || (lobbyMode == "survival")) {
                    maxPlayers = 2;
                }
                else {
                    maxPlayers = 5;
                }
            }
        }
        else {
            mmqueue = "";
        }
    }
    waitForUpdateEventHandler_Upd = $.RegisterForUnhandledEvent("PanoramaComponent_Lobby_MatchmakingSessionUpdate", function() {
        updateLobbyInfo();
    });
    updateLobbyInfo();
]])

local maps = {"mirage", "inferno", "cache", "cbble", "cobblestone", "aztec", "canals", "dust", "italy", "nuke", "vertigo", "bank", "lake",
    "office", "safehouse", "bot_aimtrain_v4c", "train", "overpass", "agency", "assault", "zoo", "milita", "mocha", "pitstop", "calavera"}
local colors = {
    nlCSGOlogo = {"Orange", "Red", "Pink", "Purple", "Blue", "Light blue", "Green", "Iridescent", "White"},
    nlLogoText = {"Orange", "Red", "Pink", "Purple", "Blue", "Green", "Iridescent", "White"}
}
local rpcSettingsDefault = {
    smallNeverloseImageText = "Neverlose.cc",
    largeNeverloseImageText = "Neverlose.cc",
    largeMapImageText = "Current map:",
    inMenuText = "In main menu",
    gameMode = "Game mode:",
    playersInLobby = "Players in lobby:",
    inSearch = "In search:",
    loadingIn = "Loading in:",
    communityServer = "Community server /",
    valveServer = "Valve server /",
    localServer = "Local server /",
    scoresText = "Score:"
}

-- < DRP lib
local function loadRPC()
    DiscordRPClib = ffi.load("C:\\Windows\\SysWOW64\\discord-rpc")
    ffi.cdef[[
        typedef struct DiscordRichPresence {
            const char* state;
            const char* details;
            int64_t startTimestamp;
            int64_t endTimestamp;
            const char* largeImageKey;
            const char* largeImageText;
            const char* smallImageKey;
            const char* smallImageText;
            const char* partyId;
            int partySize;
            int partyMax;
            const char* matchSecret;
            const char* joinSecret;
            const char* spectateSecret;
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
    DiscordRPC.initialize("835071507943129119", true)
end
-- DRP lib >

local function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    return copy
end

local function getMode(mode)
    if mode == "scrimcomp2v2" then
        return "Wingman"
    elseif mode == "survival" then
        return "Danger Zone"
    elseif mode == "skirmish" then
        return "War Games"
    else
        return mode:gsub("^%l", string.upper)
    end
end

local function DRPcontrol()
    if not rpcMenu.main.on:GetBool() and DRPwas then
        DiscordRPC.clearPresence()
    end
    if rpcMenu.main.on:GetBool() and not DRPwas then
        loadRPC()
        DRPwas = true
    end
end

local imagesRPC = {
    [0] = "nl_logo_csgo",
    [1] = "csgo_logo",
    [2] = "nl_logo_ico_text",
    [3] = "nl_logo_ico",
    [4] = "nl_logo_nl",
    [5] = ""
}

local function getImageKey(s)
    local image = 0
    local color = 0
    if s == 2 then
        image = rpcMenu.images.largeNeverloseImage:GetInt()
        color = rpcMenu.images.largeNeverloseImageColor:GetInt()
    elseif s == 1 then
        image = rpcMenu.images.smallNeverloseImage:GetInt()
        color = rpcMenu.images.smallNeverloseImageColor:GetInt()
    end
    if image == 0 then
        return "nl_logo_csgo_"..string.gsub(colors.nlCSGOlogo[color + 1]:lower(), " ", "_")
    elseif image == 2 then
        return "nl_logo_ico_text_"..colors.nlLogoText[color + 1]:lower()
    else return imagesRPC[image] end
end

local now = utils.UnixTime()
local presence = { startTimestamp = now }

local function updateLargeImage() 
    if not g_EngineClient:IsConnected() then presence.largeImageKey = getImageKey(2) end 
end
local function updateSmallImage()
    if g_EngineClient:IsConnected() then presence.smallImageKey = getImageKey(1) end 
end

local function showLargeColor()
    local value = rpcMenu.images.largeNeverloseImage:GetInt()
    if value == 0 then
        rpcMenu.images.largeNeverloseImageColor:UpdateList(colors.nlCSGOlogo)
        rpcMenu.images.largeNeverloseImageColor:SetVisible(true)
    elseif value == 2 then
        rpcMenu.images.largeNeverloseImageColor:UpdateList(colors.nlLogoText)
        rpcMenu.images.largeNeverloseImageColor:SetVisible(true)
    else rpcMenu.images.largeNeverloseImageColor:SetVisible(false) end
    updateLargeImage()
end
local function showSmallColor()
    local value = rpcMenu.images.smallNeverloseImage:GetInt()
    if value == 0 then
        rpcMenu.images.smallNeverloseImageColor:UpdateList(colors.nlCSGOlogo)
        rpcMenu.images.smallNeverloseImageColor:SetVisible(true)
    elseif value == 2 then
        rpcMenu.images.smallNeverloseImageColor:UpdateList(colors.nlLogoText)
        rpcMenu.images.smallNeverloseImageColor:SetVisible(true)
    else rpcMenu.images.smallNeverloseImageColor:SetVisible(false) end
    updateSmallImage()
end

local function onDestroy()
    DiscordRPC.clearPresence()
    g_Panorama:Exec([[
        if (waitForUpdateEventHandler_Upd != null) {
            $.UnregisterForUnhandledEvent("PanoramaComponent_Lobby_MatchmakingSessionUpdate", waitForUpdateEventHandler_Upd);
        }
    ]])
end

local rpcSettings = deepcopy(rpcSettingsDefault)

local function updateCustomRPC()
    for key, value in pairs(rpcSettings) do if key ~= "largeNeverloseImage" and key ~= "smallNeverloseImage" then rpcSettings[key] = rpcMenu.custom[key]:GetString() end end
end
local function showCustomRPC()
    local newT = rpcMenu.custom["on"]:GetBool()
    rpcMenu.custom.reset_button:SetVisible(newT)
    rpcMenu.custom.update_button:SetVisible(newT)
    for key, value in pairs(rpcSettings) do if key ~= "largeNeverloseImage" and key ~= "smallNeverloseImage" then rpcMenu.custom[key]:SetVisible(newT) end end
    if newT then updateCustomRPC() else rpcSettings = deepcopy(rpcSettingsDefault) end
end
local function resetCustomRPC()
    for key, value in pairs(rpcSettings) do if key ~= "largeNeverloseImage" and key ~= "smallNeverloseImage" then rpcMenu.custom[key]:SetString(rpcSettingsDefault[key]) end end
    rpcSettings = deepcopy(rpcSettingsDefault)
end

local function getServerIp()
    return g_EngineClient:GetNetChannelInfo():GetAddress()
end

local map_old = ""
local map_now = ""
local timer_now = 0
local timer_past = now + 5000
local server_now = ""
local server_past = ""
local gotTeamScores = false

local teamScores = {ct = 0, t = 0}

local function interval()
    if not rpcMenu.main.on:GetBool() then
        return
    end
    timer_now = utils.UnixTime()
    if timer_now - timer_past >= 5000 then
        if g_EngineClient:IsConnected() then
            if presence.partyMax ~= nil then
                presence.partyMax = nil
                presence.partySize = nil
            end
            server_now = getServerIp()
            local servername = ""
            if server_now ~= server_past then
                if g_Panorama:Exec([[ IsConnectedCommunity(); ]]) == "true" then
                    if rpcMenu.main.show:GetBool(1) then
                        local servernamePanorama = g_Panorama:Exec([[ getServerName(); ]])
                        local symbolServerString = string.find(servernamePanorama, ":") + 1

                        if symbolServerString ~= nil then
                            if string.len(servernamePanorama) > 27 and symbolServerString ~= nil then servername = string.sub(servernamePanorama, symbolServerString, 27 + symbolServerString).."..."
                            else servername = string.sub(servernamePanorama, symbolServerString, 27 + symbolServerString) end
                        else 
                            if string.len(servernamePanorama) > 27 and symbolServerString ~= nil then servername = string.sub(servernamePanorama, 0, 27).."..."
                            else servername = servernamePanorama end
                        end

                        if rpcMenu.main.show:GetBool(0) then presence.details = servername.." - IP: "..server_now
                        else presence.details = servername end
                    elseif rpcMenu.main.show:GetBool(0) then presence.details = server_now 
                    else presence.details = rpcSettings.communityServer.." "..getMode(g_Panorama:Exec([[ getGameMode(); ]])) end
                elseif server_now == "loopback" then presence.details = rpcSettings.localServer.." "..getMode(g_Panorama:Exec([[ getGameMode(); ]]))
                else presence.details = rpcSettings.valveServer.." "..getMode(g_Panorama:Exec([[ getGameMode(); ]])) end
                gotTeamScores = false
                server_past = servername
            end
            
            map_now = g_EngineClient:GetLevelName()

            if map_now ~= map_old then
                presence.largeImageText = rpcSettings.largeMapImageText.." "..string.sub(g_Panorama:Exec([[ getMapName(); ]]), 1, 110)
                for i = 1, table.getn(maps), 1 do
                    if string.find(map_now, maps[i]) ~= nil then
                        presence.largeImageKey = maps[i]
                        break
                    end
                end
                presence.smallImageKey = getImageKey(1)
                presence.smallImageText = rpcSettings.smallNeverloseImageText
                gotTeamScores = false
                map_old = map_now
            end

            local function updateTeamScores()
                g_Panorama:Exec([[ teamdata = GameStateAPI.GetScoreDataJSO().teamdata; ]])
                teamScores.ct = g_Panorama:Exec([[ getCTscore().toString(); ]])
                teamScores.t = g_Panorama:Exec([[ getTscore().toString(); ]])
            end

            local player_resource = g_EntityList:GetPlayerResource()
            local e_player = g_EngineClient:GetLocalPlayer() + 1
            local table_kills = player_resource:GetProp("DT_PlayerResource", "m_iKills")
            local table_assists = player_resource:GetProp("DT_PlayerResource", "m_iAssists")
            local table_deaths = player_resource:GetProp("DT_PlayerResource", "m_iDeaths")
            local team = player_resource:GetProp("DT_PlayerResource", "m_iTeam")

            if rpcMenu.main.show:GetBool(2) and rpcMenu.main.show:GetBool(3) then
                if not gotTeamScores then
                    updateTeamScores()
                    gotTeamScores = true
                end
                local CTscore = teamScores.ct
                local Tscore = teamScores.t
                if team[e_player] == 3 then presence.state = rpcSettings.scoresText.." CT: "..CTscore.." ["..table_kills[e_player].."-"..table_assists[e_player].."-"..table_deaths[e_player].."] / T: "..Tscore.." "
                elseif team[e_player] == 2 then presence.state = rpcSettings.scoresText.." CT: "..CTscore.." / T: "..Tscore.." ["..table_kills[e_player].."-"..table_assists[e_player].."-"..table_deaths[e_player].."] "
                else presence.state = rpcSettings.scoresText.." CT: "..CTscore.." / T: "..Tscore.." (Spectating)" end
            elseif (rpcMenu.main.show:GetBool(2)) then
                if not gotTeamScores then
                    updateTeamScores()
                    gotTeamScores = true
                end
                local CTscore = teamScores.ct
                local Tscore = teamScores.t
                presence.state = rpcSettings.scoresText.." CT: "..CTscore.." / T: "..Tscore
            elseif (rpcMenu.main.show:GetBool(3)) then presence.state = rpcSettings.scoresText.."  ["..table_kills[e_player].."-"..table_assists[e_player].."-"..table_deaths[e_player].."]" 
            elseif presence.partyMax ~= nil then presence.state = nil end

            presence.startTimestamp = now
        else
            local mmqueue = g_Panorama:Exec([[ mmqueue ]])
            local currPlayersPanorama = g_Panorama:Exec([[ currPlayers.toString(); ]])
            if currPlayersPanorama ~= "" then
                local currPlayers = tonumber(currPlayersPanorama)
                if rpcMenu.lobby.on:GetBool() and mmqueue ~= "" then
                    local lobbyMode = getMode(g_Panorama:Exec(([[ lobbyMode; ]])))
                    local maxPlayers = tonumber(g_Panorama:Exec([[ maxPlayers.toString(); ]]))

                    if rpcMenu.lobby.on:GetBool() then
                        if mmqueue == "searching" then
                            presence.details = rpcSettings.inSearch
                        elseif mmqueue == "connect" then
                            presence.details = rpcSettings.loadingIn
                        elseif lobbyMode ~= "" then
                            presence.details = rpcSettings.gameMode
                        end
                        if rpcMenu.lobby.showMode:GetBool() then presence.details = presence.details.." "..lobbyMode end
                    end

                    if rpcMenu.lobby.showPlayers:GetBool() and currPlayers ~= 1 then
                        presence.state = rpcSettings.playersInLobby
                        presence.partySize = currPlayers
                        presence.partyMax = maxPlayers
                        if presence.details ~= nil then presence.details = nil end
                    end
                    presence.largeImageKey = getImageKey(2)
                    presence.largeImageText = rpcSettings.largeNeverloseImageText
                else
                    presence.details = rpcSettings.inMenuText
                    presence.largeImageKey = getImageKey(2)
                    presence.largeImageText = rpcSettings.largeNeverloseImageText
                end  
            end
        end

        DiscordRPC.updatePresence(presence)
        timer_past = timer_now
    end
end

local function events(event)
    if event:GetName() == "cs_game_disconnected" then
        presence.state = ""
        presence.smallImageKey = ""
        presence.smallImageText = ""
        map_old = ""
        server_past = ""
        g_Panorama:Exec([[ updateLobbyInfo(); ]])
        gotTeamScores = false
    end
    if event:GetName() == "round_end" then
        local winner = event:GetInt("winner")
        if winner == 3 then teamScores.ct = teamScores.ct + 1 end
        if winner == 2 then teamScores.t = teamScores.t + 1 end
    end
end

showLargeColor()
showSmallColor()
DRPcontrol()
showCustomRPC()
if rpcMenu.custom.on:GetBool() then updateCustomRPC() end

rpcMenu.images.largeNeverloseImage:RegisterCallback(showLargeColor)
rpcMenu.images.smallNeverloseImage:RegisterCallback(showSmallColor)
rpcMenu.images.largeNeverloseImageColor:RegisterCallback(updateLargeImage)
rpcMenu.images.smallNeverloseImageColor:RegisterCallback(updateSmallImage)
rpcMenu.main.on:RegisterCallback(DRPcontrol)
rpcMenu.custom.on:RegisterCallback(showCustomRPC)
rpcMenu.custom.update_button:RegisterCallback(updateCustomRPC)
rpcMenu.custom.reset_button:RegisterCallback(resetCustomRPC)

cheat.RegisterCallback("draw", interval)
cheat.RegisterCallback("events", events)
cheat.RegisterCallback("destroy", onDestroy)
