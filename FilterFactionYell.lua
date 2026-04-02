-- FilterFactionYell
-- Filters out /yell messages from the opposite faction in WotLK 3.3.5a
-- Opposite faction yells show up as garbled text anyway, so no point seeing them.
-- Usage: /ffy toggle | /ffy status

local addonName = "FilterFactionYell"
local playerFaction = nil

-- SavedVariables (persists between sessions)
FilterFactionYellDB = FilterFactionYellDB or {}

local function IsEnabled()
    -- Default to enabled if never set
    if FilterFactionYellDB.enabled == nil then
        FilterFactionYellDB.enabled = true
    end
    return FilterFactionYellDB.enabled
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff" .. addonName .. "|r " .. msg)
end

-- Determine player faction on login
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        local _, race = UnitRace("player")
        local horde = {
            Orc = true, Scourge = true, Tauren = true,
            Troll = true, BloodElf = true,
        }
        if horde[race] then
            playerFaction = "Horde"
        else
            playerFaction = "Alliance"
        end

        local state = IsEnabled() and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        Print("loaded — filter is " .. state .. ". Type |cffffffff/ffy|r for commands.")
    end
end)

-- Language tables
local ALLIANCE_LANGUAGES = {
    ["Common"]     = true,
    ["Darnassian"] = true,
    ["Dwarvish"]   = true,
    ["Gnomish"]    = true,
    ["Draenei"]    = true,
}

local HORDE_LANGUAGES = {
    ["Orcish"]      = true,
    ["Taurahe"]     = true,
    ["Gutterspeak"] = true,
    ["Thalassian"]  = true,
    ["Zandali"]     = true,
}

local function IsOppositeFactionLanguage(language)
    if not playerFaction or not language or language == "" then
        return false
    end
    if playerFaction == "Alliance" then
        return HORDE_LANGUAGES[language] or false
    else
        return ALLIANCE_LANGUAGES[language] or false
    end
end

-- Chat filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", function(self, event, msg, sender, language, ...)
    if IsEnabled() and IsOppositeFactionLanguage(language) then
        return true
    end
    return false, msg, sender, language, ...
end)

-- Slash commands: /ffy
SLASH_FILTERFACTIONYELL1 = "/ffy"
SlashCmdList["FILTERFACTIONYELL"] = function(input)
    local cmd = string.lower(string.trim(input or ""))

    if cmd == "toggle" then
        FilterFactionYellDB.enabled = not IsEnabled()
        local state = IsEnabled() and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        Print("filter is now " .. state)
    elseif cmd == "status" then
        local state = IsEnabled() and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        Print("filter is " .. state)
    else
        Print("commands:")
        Print("  |cffffffff/ffy toggle|r — turn filter on/off")
        Print("  |cffffffff/ffy status|r — show current state")
    end
end
