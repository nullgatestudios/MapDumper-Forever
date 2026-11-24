-- MapDumper: /dumpmaps check, a short self test. Its report opens in the report window every
-- Nullgate addon shares (NullgateReport.lua), ready to copy and paste into the report form on our
-- website.
local _, ns = ...

local Check = {}
ns.Check = Check

local SLUG = "mapdumper"
local log = {}

local function Log(text)
    log[#log + 1] = tostring(text)
    if NullgateReport then NullgateReport.Update(SLUG) end
end

local function Exists(path)
    local value = _G
    for part in path:gmatch("[^.]+") do
        if type(value) ~= "table" then return false end
        value = value[part]
    end
    return type(value) == "function"
end

local function Count(t)
    local n = 0
    for _ in pairs(type(t) == "table" and t or {}) do n = n + 1 end
    return n
end

function Check.ShowReport()
    local L = ns.L
    return NullgateReport.Show({
        slug = SLUG, name = "MapDumper", addon = "MapDumper", command = "/dumpmaps check",
        lines = log,
        title = L["Bug report"], selectAll = L["Select all"], selectLink = L["Select link"],
        help = L["Press Ctrl+C to copy this report, then paste it into a new report at the link below, with a few words on what happened."],
    })
end

function Check.Run()
    for i = #log, 1, -1 do log[i] = nil end
    local client, build, _, interface = "?", "?", nil, "?"
    if GetBuildInfo then client, build, _, interface = GetBuildInfo() end
    Log(string.format("client %s, build %s, interface %s", tostring(client), tostring(build), tostring(interface)))
    local calls = {}
    for _, name in ipairs({ "C_Map.GetMapInfo", "C_Map.GetAreaInfo", "C_Map.GetBestMapForUnit" }) do
        calls[#calls + 1] = name .. "=" .. (Exists(name) and "yes" or "no")
    end
    Log("calls: " .. table.concat(calls, " "))
    local db = MapDumperDB or {}
    Log(string.format("last dump: %d UiMaps, %d AreaIDs", Count(db.UiMaps), Count(db.AreaIDs)))
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local info = mapID and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    Log(string.format("current map %s (%s)", tostring(mapID), tostring(info and info.name)))
    Check.ShowReport()
end
