-- FilterFactionYell
-- Filters out /yell messages from the opposite faction in WotLK 3.3.5a
-- Opposite faction yells show up as garbled text anyway, so no point seeing them.

local addonName = "FilterFactionYell"
local playerFaction = nil

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        local _, race = UnitRace("player")
        -- Determine player faction from race
        local horde = {
            Orc = true, Scourge = true, Tauren = true,
            Troll = true, BloodElf = true,
        }
        if horde[race] then
            playerFaction = "Horde"
        else
            playerFaction = "Alliance"
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff" .. addonName .. "|r loaded — filtering opposite faction yells.")
    end
end)

-- Chat filter for YELL messages
-- In 3.3.5a the filter signature is: function(self, event, msg, sender, language, ...)
-- language is the in-game language string (e.g. "Orcish", "Common", "Gutterspeak", etc.)
-- Opposite faction yells arrive in a language you can't understand.

local ALLIANCE_LANGUAGES = {
    ["Common"]   = true,
    ["Darnassian"] = true,
    ["Dwarvish"] = true,
    ["Gnomish"]  = true,
    ["Draenei"]  = true,
}

local HORDE_LANGUAGES = {
    ["Orcish"]      = true,
    ["Taurahe"]     = true,
    ["Gutterspeak"] = true,
    ["Thalassian"]  = true,
    ["Zandali"]     = true,
    ["Forsaken"]    = true,
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

-- Register the chat message filter for CHAT_MSG_YELL
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", function(self, event, msg, sender, language, ...)
    if IsOppositeFactionLanguage(language) then
        return true -- block the message
    end
    return false, msg, sender, language, ...
end)
