-- MapDumper: text lookup. Every user-facing string goes through ns.L["English text"]. Each language
-- pack in Locales\<code>.lua registers a table keyed by the English text. The game client's language
-- picks the pack (Mexican Spanish uses Spanish, British English uses English); a missing key falls
-- back to English.
local _, ns = ...

local packs = {}
local active

ns.LANGUAGES = { "enUS" }

function ns.RegisterLanguagePack(code, name, strings)
    if not packs[code] then ns.LANGUAGES[#ns.LANGUAGES + 1] = code end
    packs[code] = strings
end

local function Active()
    if not active then
        local locale = (GetLocale and GetLocale()) or "enUS"
        if locale == "esMX" then locale = "esES" end
        active = packs[locale] or {}
    end
    return active
end

ns.L = setmetatable({}, {
    __index = function(_, key)
        local value = Active()[key]
        if type(value) ~= "string" or value == "" then return key end
        return value
    end,
})
