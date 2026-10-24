# MapDumper - Forever

[![Interface](https://img.shields.io/badge/Interface-16001%20(WoW%20Forever)-0078D7.svg?style=flat-square)](https://github.com/nullgatestudios/MapDumper-Forever)
[![Release](https://img.shields.io/badge/Release-v1.0.0-ffd100.svg?style=flat-square)](https://www.curseforge.com/wow/addons/mapdumper-forever)
[![License](https://img.shields.io/badge/License-CC%20BY%204.0-2ea44f.svg?style=flat-square)](LICENSE.md)
[![Type](https://img.shields.io/badge/Type-Developer%20Tool-8a2be2.svg?style=flat-square)](https://github.com/nullgatestudios)

**MapDumper** is a small developer tool for **World of Warcraft: Forever** (Interface 16001). It reads every `UiMapID` and `AreaID` (subzone) the game client knows about and exports them, with their names, map types and parent maps, as JSON you can copy straight out of the game.

Use it when you're building quest trackers, coordinate tools, waypoints or your own lookup tables and need the real IDs from the Forever client rather than retail data.

Made by [Nullgate Studios](https://nullgatestudios.com). Free for other addon developers to use. See the [license](#license).

---

## Contents

- [What it exports](#what-it-exports)
- [Installation](#installation)
- [Usage](#usage)
- [Output format](#output-format)
- [Reading the SavedVariables file](#reading-the-savedvariables-file)
- [How it works](#how-it-works)
- [Packaging](#packaging)
- [License](#license)

---

## What it exports

- **UiMaps**: every map ID from 1 to 3000 that `C_Map.GetMapInfo` returns, with:
  - `name`
  - `mapTypeID`, the raw `Enum.UIMapType` value
  - `mapType`, the readable type: Cosmic, World, Continent, Zone, Dungeon, Micro or Orphan
  - `parentMapID`, only when the map has a real parent
- **AreaIDs**: every area ID from 1 to 5000 that `C_Map.GetAreaInfo` returns a name for. These are the zones and subzones.

Empty names and missing records are skipped, so the output contains only entries you can use.

---

## Installation

1. Download the latest release from [CurseForge](https://www.curseforge.com/wow/addons/mapdumper-forever), or download this repository.
2. Copy the `MapDumper` folder into:
   ```
   World of Warcraft\_forever_\Interface\AddOns\
   ```
3. Restart the game, or type `/reload` if it's already running.

MapDumper has no dependencies.

---

## Usage

1. Log in to any character.
2. Type `/dumpmaps` in chat.
3. MapDumper scans the map tables and opens the **MapDumper Export** window with the JSON already selected.
4. Press **Ctrl+C** to copy it, then paste it into your editor or scripts.

Press **Esc** or **Close** to close the window. Drag the window to move it.

---

## Output format

```json
{
  "UiMaps": {
    "1411": { "name": "Durotar", "mapTypeID": 3, "mapType": "Zone", "parentMapID": 1414 }
  },
  "AreaIDs": {
    "14": "Durotar",
    "363": "Valley of Trials"
  }
}
```

JSON object keys are strings, so convert them back to numbers if your code needs numeric IDs. Entries are not sorted.

---

## Reading the SavedVariables file

Each scan is also saved to the `MapDumperDB` SavedVariable, if you'd rather work with Lua tables.

1. **Write it to disk.** The game only saves SavedVariables on a UI reload, logout or clean exit, so type `/reload` after running `/dumpmaps`.
2. **Find the file.** SavedVariables are saved per account:
   ```
   World of Warcraft\_forever_\WTF\Account\<ACCOUNT_NAME>\SavedVariables\MapDumper.lua
   ```
   If you have more than one account folder (for example `12345678#1`), use the one for the account you logged in with.
3. **Read it.** The data is in the global `MapDumperDB`:
   ```lua
   MapDumperDB = {
       ["UiMaps"] = {
           [1411] = {
               ["name"] = "Durotar",
               ["mapTypeID"] = 3,
               ["mapType"] = "Zone",
               ["parentMapID"] = 1414,
           },
       },
       ["AreaIDs"] = {
           [14] = "Durotar",
           [363] = "Valley of Trials",
       },
   }
   ```
   You can copy this table into your own addon as a static data file.

Each `/dumpmaps` clears the previous scan before it starts.

---

## How it works

Everything is in [`MapDumper/MapDumper.lua`](MapDumper/MapDumper.lua):

| Part | What it does |
| --- | --- |
| `RunDump` | Scans the map and area ID ranges and stores valid entries in `MapDumperDB` |
| `SerializeDumpToJSON` | A small JSON writer that escapes quotes, backslashes and line breaks |
| `MapDumperExportFrame` | The draggable export window with a scrolling, pre-selected text box |
| `/dumpmaps` | The slash command that runs a scan |

The ID ranges are fixed (maps 1–3000, areas 1–5000). If a future client adds IDs above those limits, raise them in `RunDump`.

---

## Packaging

`package.ps1` builds a release zip in `zips/`:

```powershell
.\package.ps1
.\package.ps1 -Version "1.0.1" -Notes "What changed"
```

---

## License

MapDumper - Forever is licensed under [CC BY 4.0](LICENSE.md). You can use, change and share it, including inside your own addons, as long as you credit Nullgate Studios.

Map names and IDs come from the World of Warcraft client and belong to Blizzard Entertainment. World of Warcraft is a trademark of Blizzard Entertainment, Inc.

Found a bug? [Open an issue](https://github.com/nullgatestudios/MapDumper-Forever/issues).
