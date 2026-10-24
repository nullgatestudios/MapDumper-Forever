-- Initialize the global table if it doesn't exist
MapDumperDB = MapDumperDB or {
    UiMaps = {},
    AreaIDs = {}
}

-- Map type lookup table (Enum.UIMapType)
local MAP_TYPES = {
    [0] = "Cosmic",
    [1] = "World",
    [2] = "Continent",
    [3] = "Zone",
    [4] = "Dungeon",
    [5] = "Micro",
    [6] = "Orphan",
}

-- Lightweight JSON Serializer to format the output for easy copying
local function EscapeString(str)
    return str:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r')
end

local function SerializeDumpToJSON(db)
    local parts = {}
    table.insert(parts, "{\n  \"UiMaps\": {\n")
    
    local mapEntries = {}
    for id, info in pairs(db.UiMaps) do
        local fields = {
            string.format('"name": "%s"', EscapeString(info.name))
        }
        if info.mapTypeID ~= nil then
            table.insert(fields, string.format('"mapTypeID": %d', info.mapTypeID))
        end
        if info.mapType ~= nil then
            table.insert(fields, string.format('"mapType": "%s"', EscapeString(info.mapType)))
        end
        if info.parentMapID ~= nil then
            table.insert(fields, string.format('"parentMapID": %d', info.parentMapID))
        end
        table.insert(mapEntries, string.format('    "%d": { %s }', id, table.concat(fields, ", ")))
    end
    table.insert(parts, table.concat(mapEntries, ",\n"))
    table.insert(parts, "\n  },\n  \"AreaIDs\": {\n")

    local areaEntries = {}
    for id, name in pairs(db.AreaIDs) do
        table.insert(areaEntries, string.format('    "%d": "%s"', id, EscapeString(name)))
    end
    table.insert(parts, table.concat(areaEntries, ",\n"))
    table.insert(parts, "\n  }\n}")

    return table.concat(parts)
end

-- Create the Export UI Frame
local exportFrame = CreateFrame("Frame", "MapDumperExportFrame", UIParent, "BackdropTemplate")
exportFrame:SetSize(620, 480)
exportFrame:SetPoint("CENTER")
exportFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
exportFrame:SetMovable(true)
exportFrame:EnableMouse(true)
exportFrame:RegisterForDrag("LeftButton")
exportFrame:SetScript("OnDragStart", exportFrame.StartMoving)
exportFrame:SetScript("OnDragStop", exportFrame.StopMovingOrSizing)
exportFrame:Hide()

-- Title
local title = exportFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("MapDumper Export (Press Ctrl+C to Copy)")

-- Scroll Frame & EditBox container
local scrollFrame = CreateFrame("ScrollFrame", "MapDumperScrollFrame", exportFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 24, -48)
scrollFrame:SetPoint("BOTTOMRIGHT", -44, 52)

local editBox = CreateFrame("EditBox", "MapDumperEditBox", scrollFrame)
editBox:SetMultiLine(true)
editBox:SetFontObject("GameFontHighlightSmall")
editBox:SetWidth(540)
editBox:SetAutoFocus(false)
editBox:SetScript("OnEscapePressed", function() exportFrame:Hide() end)
scrollFrame:SetScrollChild(editBox)

-- Close Button
local closeBtn = CreateFrame("Button", nil, exportFrame, "GameMenuButtonTemplate")
closeBtn:SetSize(110, 26)
closeBtn:SetPoint("BOTTOM", 0, 16)
closeBtn:SetText("Close")
closeBtn:SetScript("OnClick", function() exportFrame:Hide() end)

local function ShowExportWindow(text)
    editBox:SetText(text)
    exportFrame:Show()
    editBox:SetFocus()
    editBox:HighlightText()
end

local function RunDump()
    print("|cFF00FF00[MapDumper]|r Crawling map and area data...")

    MapDumperDB.UiMaps = {}
    MapDumperDB.AreaIDs = {}

    local mapCount = 0
    local areaCount = 0

    -- 1. Crawl UiMaps (filter nils)
    for id = 1, 3000 do
        local info = C_Map.GetMapInfo(id)
        if info and type(info.name) == "string" and info.name ~= "" then
            local mapEntry = {
                name = info.name
            }
            if info.mapType ~= nil then
                mapEntry.mapTypeID = info.mapType
                mapEntry.mapType = MAP_TYPES[info.mapType] or "Other"
            end
            if info.parentMapID and info.parentMapID > 0 then
                mapEntry.parentMapID = info.parentMapID
            end

            MapDumperDB.UiMaps[id] = mapEntry
            mapCount = mapCount + 1
        end
    end

    -- 2. Crawl AreaIDs (filter nils)
    if C_Map.GetAreaInfo then
        for areaID = 1, 5000 do
            local areaName = C_Map.GetAreaInfo(areaID)
            if areaName and type(areaName) == "string" and areaName ~= "" then
                MapDumperDB.AreaIDs[areaID] = areaName
                areaCount = areaCount + 1
            end
        end
    end

    print(string.format("|cFF00FF00[MapDumper]|r Dumped %d UiMaps and %d AreaIDs.", mapCount, areaCount))

    -- Format JSON and open copy-paste window
    local payload = SerializeDumpToJSON(MapDumperDB)
    ShowExportWindow(payload)
end

-- Slash command trigger
SLASH_MAPDUMPER1 = "/dumpmaps"
SlashCmdList["MAPDUMPER"] = function()
    RunDump()
end

-- Login notification
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    print("|cFF00FF00[MapDumper]|r Loaded. Type |cFFFFFF00/dumpmaps|r to export maps.")
end)