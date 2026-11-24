**MapDumper** is a lightweight developer tool for **World of Warcraft: Forever**. It reads every `UiMapID` and `AreaID` (subzone) from the game client and exports them, with names, map types and parent maps, as JSON in an in-game copy window and as Lua tables in your SavedVariables.

Use it when you're building quest trackers, coordinate tools, waypoints or your own lookup tables.

---

## Features

- **Map hierarchy scan**: reads every map with `C_Map.GetMapInfo`, including its name, its type (World, Continent, Zone, Dungeon, Micro or Orphan) and its parent map.
- **Area and subzone scan**: reads every named `AreaID` with `C_Map.GetAreaInfo`.
- **Clean output**: skips empty names, missing records and parent links that don't exist.
- **Copy window**: opens a scrolling window with the JSON already selected, ready for **Ctrl+C**.
- **SavedVariables**: also saves the scan to `MapDumperDB` when you `/reload` or log out.

---

## Usage

1. Log in to any character.
2. Type `/dumpmaps` in chat.
3. Press **Ctrl+C** to copy the JSON from the export window.

If something doesn't work, type `/dumpmaps check`. It opens a bug report window to copy into the report form on our website.

To use the SavedVariables copy instead, type `/reload`, then open:

```
World of Warcraft\_forever_\WTF\Account\<ACCOUNT_NAME>\SavedVariables\MapDumper.lua
```

---

## Supported Languages

All 10 languages the game client runs in:

- English
- Deutsch (German)
- Español (Spanish)
- Français (French)
- Italiano (Italian)
- Português do Brasil (Brazilian Portuguese)
- Русский (Russian)
- 한국어 (Korean)
- 简体中文 (Simplified Chinese)
- 繁體中文 (Traditional Chinese)

The addon uses your game's language automatically. The translations were made with machine assistance, so some wording may not be quite right. Corrections are welcome: send a message here on CurseForge or [report on our website](https://nullgatestudios.com/report?addon=mapdumper).

---

Source, documentation and issues: https://github.com/nullgatestudios/MapDumper-Forever

Licensed under CC BY 4.0: free to use in your own addons with credit to Nullgate Studios.
