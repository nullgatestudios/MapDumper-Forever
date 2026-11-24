-- MapDumper: every language pack translates every string the code uses, with the
-- same %s/%d placeholders in the same order, and the game's language picks the pack.
-- Run from the repository root:  lua tests/locales.lua

local source = debug.getinfo(1, "S").source or ""
local script = source:match("^@(.*)$") or "tests/locales.lua"
local scriptDir = script:match("^(.*)[/\\][^/\\]*$") or "."
local repo = scriptDir:match("^(.*)[/\\][^/\\]*$") or "."
local folder = "MapDumper"
local root = repo .. "/" .. folder .. "/"

local checks, failures = 0, 0
local function OK(cond, name)
    checks = checks + 1
    if not cond then failures = failures + 1; io.write("FAIL " .. name .. "\n") end
end

local function Read(path) local f = assert(io.open(path, "r")); local t = f:read("*a"); f:close(); return t end
local toc = Read(root .. folder .. ".toc")

local locale = "enUS"
GetLocale = function() return locale end
local function Load()
    local BUT, registered = {}, {}
    assert(loadfile(root .. "Locale.lua"))(folder, BUT)
    local register = BUT.RegisterLanguagePack
    BUT.RegisterLanguagePack = function(code, name, strings) registered[code] = strings; register(code, name, strings) end
    for file in toc:gmatch("Locales\\(%w+%.lua)") do assert(loadfile(root .. "Locales/" .. file))(folder, BUT) end
    return BUT, registered
end
local BUT, registered = Load()

-- Every key the code looks up: L["..."], plus the toggle labels and tooltips it translates.
local used = {}
local function Unescape(s) return (s:gsub("\\\\", "\1"):gsub("\\'", "'"):gsub('\\"', '"'):gsub("\1", "\\")) end
for line in toc:gmatch("[^\r\n]+") do
    if line:match("%.lua$") and not line:match("^Locale") and not line:match("^#") then
        local text = Read(root .. line:gsub("\\", "/"))
        for key in text:gmatch('L%["(.-)"%]') do used[Unescape(key)] = true end
        for key in text:gmatch('label = "(.-)",') do used[Unescape(key)] = true end
        for key in text:gmatch('tooltip = "(.-)"') do used[Unescape(key)] = true end
    end
end
local count = 0
for _ in pairs(used) do count = count + 1 end
OK(count >= 9, "the code's strings were found (" .. count .. ")")

local function Placeholders(text) local out = {}; for p in text:gmatch("%%[sd]") do out[#out + 1] = p end; return table.concat(out) end
local packs = 0
for code, strings in pairs(registered) do
    packs = packs + 1
    for key in pairs(used) do
        local value = strings[key]
        OK(type(value) == "string" and value ~= "", code .. " translates: " .. key)
        if value then OK(Placeholders(value) == Placeholders(key), code .. " keeps the placeholders of: " .. key) end
    end
end
OK(packs == 9, "9 language packs besides English (" .. packs .. ")")
OK(#BUT.LANGUAGES == 10, "10 languages, the ones the game client runs in")

-- Selection follows the game client.
locale = "deDE"; BUT = Load()
OK(BUT.L["Close"] == "Schließen", "a German client gets German")
locale = "esMX"; BUT = Load()
OK(BUT.L["Close"] == "Cerrar", "a Mexican Spanish client gets Spanish")
locale = "enGB"; BUT = Load()
OK(BUT.L["Close"] == "Close", "British English uses English")

io.write(string.format("locales: %d checks, %d failure(s)\n", checks, failures))
if failures > 0 then os.exit(1) end
