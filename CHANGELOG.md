# Changelog

## [1.1] - 2026-11-24

### New

- **New `/dumpmaps check` command.** It runs a short self test in this client and opens a bug report window with the results.
- Press Ctrl+C to copy the report, then paste it into the report form at nullgatestudios.com/report?addon=mapdumper, which opens with MapDumper already picked. You can report without an account.
- **10 languages:** English, Deutsch, Español, Français, Italiano, Português do Brasil, Русский, 한국어, 简体中文 and 繁體中文. MapDumper uses your game's language automatically. The exported map and area names always come from the game client.

### Good to know

- The game doesn't let addons open a web browser, so type or copy the link into your browser yourself. The **Select link** button selects it for copying.

## [1.0] - 2026-10-24

### New

- First release: `/dumpmaps` exports every UiMapID and AreaID with names, map types and parent maps, as JSON in a copy window and as Lua tables in SavedVariables.
