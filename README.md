# MyUILib

A small, dependency-free Roblox UI library (ModuleScript) for building
settings menus and control panels — dark theme, cyan accent, sidebar
navigation, live search. Toggle / Slider / Dropdown components out of the
box.

Plain `require()`. No `loadstring`, no `HttpGet`, no remote execution —
this is meant to be built into your own game via Rojo/Wally or copy-pasted
into Studio.

## Install

### Option A — Rojo (recommended)
1. Clone this repo.
2. `rojo build -o game.rbxlx` or sync it into an existing project — the
   included `default.project.json` maps `src/` to
   `ReplicatedStorage.MyUILib`.

### Option B — Manual
1. Copy `src/init.lua` and `src/Library.lua` into Studio as `init.lua` →
   a `ModuleScript` named `MyUILib`, with `Library.lua` as a child
   `ModuleScript`.
2. Put `MyUILib` in `ReplicatedStorage`.

### Option C — Wally
```toml
# wally.toml
[dependencies]
MyUILib = "yourname/myuilib@0.1.0"
```

## Quick start

```lua
local Library = require(ReplicatedStorage:WaitForChild("MyUILib"))

local Window = Library:CreateWindow({ Title = "Settings" })

local Audio = Window:AddCategory("Audio")
local Section = Audio:AddSection("Audio")

Section:AddSlider({
    Title = "Music Volume",
    Description = "Adjusts all game music volume",
    Min = 0, Max = 2, Default = 1, Rounding = 1,
    Callback = function(value) end,
})

Section:AddToggle({
    Title = "Show Match End Rewards",
    Default = true,
    Callback = function(value) end,
})

Section:AddDropdown({
    Title = "Difficulty",
    Values = { "Easy", "Normal", "Hard" },
    Default = "Normal",
    Callback = function(value) end,
})
```

See `Example.lua` for a fuller example.

## API

### `Library:CreateWindow(opts) -> Window`
`opts.Title: string`, `opts.Size: UDim2?`

### `Window:AddCategory(name: string, iconId: string?) -> Category`
Adds a sidebar tab. The first category added is selected by default.

### `Category:AddSection(title: string) -> Section`
Adds a titled card with a two-column grid of controls.

### `Section:AddToggle(opts)`
`Title, Description?, Default: boolean, Callback(value: boolean)`
Returns `{ SetValue(self, bool), GetValue(self) -> bool }`.

### `Section:AddSlider(opts)`
`Title, Description?, Min, Max, Default, Rounding?, Callback(value: number)`
Returns `{ SetValue(self, number), GetValue(self) -> number }`.

### `Section:AddDropdown(opts)`
`Title, Description?, Values: {string}, Default?, Callback(value: string)`
Returns `{ SetValue(self, string), GetValue(self) -> string }`.

### `Window:Toggle()`
Shows/hides the whole menu.

## Roadmap
- Keybind picker
- Color picker
- Config save/load (JSON via `DataStoreService` or plugin `Settings`)
- Multi-select dropdown

## License
MIT — do whatever you want with it.
