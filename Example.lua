-- ════════════════════════════════════════════════════════════════════════
--  CustomUI  –  FULL EXAMPLE  (mirrors Tower Defense Simulator Settings)
--  Paste this into a LocalScript, swap the URL, and run it.
-- ════════════════════════════════════════════════════════════════════════

local Library = loadstring(game:HttpGet("RAW_GITHUB_URL_HERE"))()

-- ─── Create the window ───────────────────────────────────────────────────
local Window = Library:CreateWindow({ Title = "Settings" })

-- ════════════════════════════════════════════════════════════════════════
--  Helper state (mirrors real game variables so callbacks do something)
-- ════════════════════════════════════════════════════════════════════════

local Settings = {
    -- Audio
    MusicVolume   = 0,
    SFXVolume     = 1,
    AmbientVolume = 1.2,

    -- Gameplay
    AutoSkipWaves       = false,
    AutoVoteStart       = true,
    ShowMatchEndRewards = true,
    DisplayPinnedQuests = true,
    SelectUnitOnPlace   = true,
    ShowMaxRange        = true,
    DisplayPathVis      = true,
    AutoRetry           = false,
    AutoNext            = false,
    ReducedMotion       = false,

    -- Graphics
    ShadowsEnabled  = true,
    PostProcessing   = true,
    RenderDistance   = 3,
    QualityLevel     = "Auto",
    FPSLimit         = 60,

    -- Units
    ShowUnitStats    = true,
    UnitOutlines     = true,
    PlacementGrid    = true,
    UnitShadows      = false,
    SortMode         = "Level",

    -- Enemies
    ShowHealthBars   = true,
    EnemyHighlight   = true,
    BossWarning      = true,
    HighlightColor   = "Cyan",

    -- Miscellaneous
    ChatEnabled      = true,
    NotifSound       = true,
    HideHUD          = false,
    Language         = "English",
    WebhookURL       = "",

    -- Keybinds (just printed)
    -- Testing
    DebugMode        = false,
    ShowHitboxes     = false,
    SpeedMultiplier  = 1,
}

-- ════════════════════════════════════════════════════════════════════════
--  TAB: All  (overview of every setting in one scrollable list)
-- ════════════════════════════════════════════════════════════════════════
local AllTab = Window:AddTab("⚙  All")

-- ── Audio (summary) ──────────────────────────────────────────────────────
local AllAudio = AllTab:AddSection("Audio")

AllAudio:AddSlider({
    Text     = "Music Volume",
    Desc     = "Adjusts all game music volume",
    Min      = 0, Max = 1, Default = Settings.MusicVolume,
    Rounding = 1, Suffix = "",
    Callback = function(v) Settings.MusicVolume = v end,
})

AllAudio:AddSlider({
    Text     = "SFX Volume",
    Desc     = "Adjusts all game sound effect volume",
    Min      = 0, Max = 1, Default = Settings.SFXVolume,
    Rounding = 1, Suffix = "",
    Callback = function(v) Settings.SFXVolume = v end,
})

AllAudio:AddSlider({
    Text     = "Ambient Volume",
    Desc     = "Adjusts all ambient volume",
    Min      = 0, Max = 2, Default = Settings.AmbientVolume,
    Rounding = 1, Suffix = "",
    Callback = function(v) Settings.AmbientVolume = v end,
})

-- ── Gameplay (summary) ───────────────────────────────────────────────────
local AllGameplay = AllTab:AddSection("Gameplay")

AllGameplay:AddButton({
    Text     = "Teleport To Spawn",
    Desc     = "Go to your current map's spawn point",
    Callback = function()
        -- teleport logic here
        Library:Notify({ Title = "Teleporting", Description = "Moving to spawn...", Time = 2 })
    end,
})

AllGameplay:AddToggle({
    Text     = "Auto Skip Waves",
    Desc     = "Automatically vote to skip waves",
    Default  = Settings.AutoSkipWaves,
    Callback = function(v) Settings.AutoSkipWaves = v end,
})

AllGameplay:AddToggle({
    Text     = "Auto Vote Start",
    Desc     = "Automatically vote to start games",
    Default  = Settings.AutoVoteStart,
    Callback = function(v) Settings.AutoVoteStart = v end,
})

AllGameplay:AddToggle({
    Text     = "Show Match End Rewards",
    Desc     = "Show reward pop-ups after matches",
    Default  = Settings.ShowMatchEndRewards,
    Callback = function(v) Settings.ShowMatchEndRewards = v end,
})

AllGameplay:AddToggle({
    Text     = "Display Pinned Quests",
    Desc     = "Display all pinned quest quests in-game",
    Default  = Settings.DisplayPinnedQuests,
    Callback = function(v) Settings.DisplayPinnedQuests = v end,
})

AllGameplay:AddToggle({
    Text     = "Select Unit on Placement",
    Desc     = "Automatically select placed units",
    Default  = Settings.SelectUnitOnPlace,
    Callback = function(v) Settings.SelectUnitOnPlace = v end,
})

AllGameplay:AddToggle({
    Text     = "Show Max Range on Placement",
    Desc     = "Show units' max range when placing",
    Default  = Settings.ShowMaxRange,
    Callback = function(v) Settings.ShowMaxRange = v end,
})

AllGameplay:AddToggle({
    Text     = "Display Path Visualizers",
    Desc     = "Display path visualizers in-game",
    Default  = Settings.DisplayPathVis,
    Callback = function(v) Settings.DisplayPathVis = v end,
})

AllGameplay:AddToggle({
    Text     = "Auto Retry",
    Desc     = "Automatically retry after a game over",
    Default  = Settings.AutoRetry,
    Callback = function(v) Settings.AutoRetry = v end,
})

AllGameplay:AddToggle({
    Text     = "Auto Next",
    Desc     = "Automatically move to next wave",
    Default  = Settings.AutoNext,
    Callback = function(v) Settings.AutoNext = v end,
})

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Audio
-- ════════════════════════════════════════════════════════════════════════
local AudioTab = Window:AddTab("⊜  Audio")

local AudioSection = AudioTab:AddSection("Audio")

AudioSection:AddSlider({
    Text     = "Music Volume",
    Desc     = "Adjusts all game music volume",
    Min      = 0, Max = 1, Default = Settings.MusicVolume,
    Rounding = 1, Suffix = "",
    Callback = function(v)
        Settings.MusicVolume = v
        -- game.SoundService.MusicVolume = v
    end,
})

AudioSection:AddSlider({
    Text     = "SFX Volume",
    Desc     = "Adjusts all game sound effect volume",
    Min      = 0, Max = 1, Default = Settings.SFXVolume,
    Rounding = 1, Suffix = "",
    Callback = function(v)
        Settings.SFXVolume = v
    end,
})

AudioSection:AddSlider({
    Text     = "Ambient Volume",
    Desc     = "Adjusts all ambient volume",
    Min      = 0, Max = 2, Default = Settings.AmbientVolume,
    Rounding = 1, Suffix = "",
    Callback = function(v)
        Settings.AmbientVolume = v
    end,
})

AudioSection:AddDivider()

AudioSection:AddToggle({
    Text     = "Notification Sounds",
    Desc     = "Play a sound for in-game notifications",
    Default  = Settings.NotifSound,
    Callback = function(v) Settings.NotifSound = v end,
})

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Gameplay
-- ════════════════════════════════════════════════════════════════════════
local GameplayTab = Window:AddTab("✦  Gameplay")

local GameplaySection = GameplayTab:AddSection("Gameplay")

GameplaySection:AddButton({
    Text     = "Teleport To Spawn",
    Desc     = "Go to your current map's spawn point",
    Callback = function()
        Library:Notify({ Title = "Teleporting", Description = "Moving to spawn point...", Time = 2 })
    end,
})

GameplaySection:AddToggle({
    Text     = "Auto Skip Waves",
    Desc     = "Automatically vote to skip waves",
    Default  = Settings.AutoSkipWaves,
    Callback = function(v)
        Settings.AutoSkipWaves = v
        Library:Notify({
            Title       = "Auto Skip Waves",
            Description = v and "Enabled" or "Disabled",
            Time        = 2,
        })
    end,
})

GameplaySection:AddToggle({
    Text     = "Auto Vote Start",
    Desc     = "Automatically vote to start games",
    Default  = Settings.AutoVoteStart,
    Callback = function(v) Settings.AutoVoteStart = v end,
})

GameplaySection:AddToggle({
    Text     = "Show Match End Rewards",
    Desc     = "Show reward pop-ups after matches",
    Default  = Settings.ShowMatchEndRewards,
    Callback = function(v) Settings.ShowMatchEndRewards = v end,
})

GameplaySection:AddToggle({
    Text     = "Display Pinned Quests",
    Desc     = "Display all pinned quest quests in-game",
    Default  = Settings.DisplayPinnedQuests,
    Callback = function(v) Settings.DisplayPinnedQuests = v end,
})

GameplaySection:AddToggle({
    Text     = "Select Unit on Placement",
    Desc     = "Automatically select placed units",
    Default  = Settings.SelectUnitOnPlace,
    Callback = function(v) Settings.SelectUnitOnPlace = v end,
})

GameplaySection:AddToggle({
    Text     = "Show Max Range on Placement",
    Desc     = "Show units' max range when placing",
    Default  = Settings.ShowMaxRange,
    Callback = function(v) Settings.ShowMaxRange = v end,
})

GameplaySection:AddToggle({
    Text     = "Display Path Visualizers",
    Desc     = "Display path visualizers in-game",
    Default  = Settings.DisplayPathVis,
    Callback = function(v) Settings.DisplayPathVis = v end,
})

GameplaySection:AddToggle({
    Text     = "Auto Retry",
    Desc     = "Automatically retry after a game over",
    Default  = Settings.AutoRetry,
    Callback = function(v) Settings.AutoRetry = v end,
})

GameplaySection:AddToggle({
    Text     = "Auto Next",
    Desc     = "Automatically move to the next wave",
    Default  = Settings.AutoNext,
    Callback = function(v) Settings.AutoNext = v end,
})

GameplaySection:AddToggle({
    Text     = "Reduced Motion",
    Desc     = "Reduces UI animations and screen effects",
    Default  = Settings.ReducedMotion,
    Callback = function(v) Settings.ReducedMotion = v end,
})

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Graphics
-- ════════════════════════════════════════════════════════════════════════
local GraphicsTab = Window:AddTab("◎  Graphics")

local GraphicsSection = GraphicsTab:AddSection("Graphics")

GraphicsSection:AddDropdown({
    Text     = "Quality Level",
    Desc     = "Overall render quality preset",
    Values   = { "Auto", "Low", "Medium", "High", "Ultra" },
    Default  = Settings.QualityLevel,
    Callback = function(v)
        Settings.QualityLevel = v
        Library:Notify({ Title = "Graphics", Description = "Quality set to " .. v, Time = 2 })
    end,
})

GraphicsSection:AddSlider({
    Text     = "Render Distance",
    Desc     = "How far away objects are rendered",
    Min      = 1, Max = 5, Default = Settings.RenderDistance,
    Rounding = 0, Suffix = "",
    Callback = function(v) Settings.RenderDistance = v end,
})

GraphicsSection:AddSlider({
    Text     = "FPS Limit",
    Desc     = "Cap the frame rate (0 = unlimited)",
    Min      = 0, Max = 240, Default = Settings.FPSLimit,
    Rounding = 0, Suffix = " fps",
    Callback = function(v) Settings.FPSLimit = v end,
})

GraphicsSection:AddDivider()

GraphicsSection:AddToggle({
    Text     = "Shadows Enabled",
    Desc     = "Render dynamic shadows",
    Default  = Settings.ShadowsEnabled,
    Callback = function(v)
        Settings.ShadowsEnabled = v
        -- game.Lighting.GlobalShadows = v
    end,
})

GraphicsSection:AddToggle({
    Text     = "Post Processing",
    Desc     = "Bloom, depth of field and other effects",
    Default  = Settings.PostProcessing,
    Callback = function(v) Settings.PostProcessing = v end,
})

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Units
-- ════════════════════════════════════════════════════════════════════════
local UnitsTab = Window:AddTab("◈  Units")

local UnitsSection = UnitsTab:AddSection("Units")

UnitsSection:AddDropdown({
    Text     = "Sort Mode",
    Desc     = "How units are sorted in your inventory",
    Values   = { "Level", "Rarity", "Name", "Most Used" },
    Default  = Settings.SortMode,
    Callback = function(v) Settings.SortMode = v end,
})

UnitsSection:AddToggle({
    Text     = "Show Unit Stats",
    Desc     = "Show DPS / range / cost in unit cards",
    Default  = Settings.ShowUnitStats,
    Callback = function(v) Settings.ShowUnitStats = v end,
})

UnitsSection:AddToggle({
    Text     = "Unit Outlines",
    Desc     = "Show selection outlines around placed units",
    Default  = Settings.UnitOutlines,
    Callback = function(v) Settings.UnitOutlines = v end,
})

UnitsSection:AddToggle({
    Text     = "Placement Grid",
    Desc     = "Show grid when placing units",
    Default  = Settings.PlacementGrid,
    Callback = function(v) Settings.PlacementGrid = v end,
})

UnitsSection:AddToggle({
    Text     = "Unit Shadows",
    Desc     = "Render shadows under placed units",
    Default  = Settings.UnitShadows,
    Callback = function(v) Settings.UnitShadows = v end,
})

UnitsSection:AddDivider()

local UnitInfo = UnitsSection:AddLabel("Tip: Hold R while placing to rotate a unit.")
-- you can update it later: UnitInfo:SetText("New tip text")

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Enemies
-- ════════════════════════════════════════════════════════════════════════
local EnemiesTab = Window:AddTab("☠  Enemies")

local EnemiesSection = EnemiesTab:AddSection("Enemies")

EnemiesSection:AddToggle({
    Text     = "Show Health Bars",
    Desc     = "Display HP bars above enemies",
    Default  = Settings.ShowHealthBars,
    Callback = function(v) Settings.ShowHealthBars = v end,
})

EnemiesSection:AddToggle({
    Text     = "Enemy Highlight",
    Desc     = "Highlight targeted enemies",
    Default  = Settings.EnemyHighlight,
    Callback = function(v) Settings.EnemyHighlight = v end,
})

EnemiesSection:AddDropdown({
    Text     = "Highlight Color",
    Desc     = "Color used to highlight targeted enemies",
    Values   = { "Cyan", "Yellow", "Red", "Green", "White" },
    Default  = Settings.HighlightColor,
    Callback = function(v) Settings.HighlightColor = v end,
})

EnemiesSection:AddToggle({
    Text     = "Boss Warning",
    Desc     = "Show a warning overlay when a boss spawns",
    Default  = Settings.BossWarning,
    Callback = function(v) Settings.BossWarning = v end,
})

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Miscellaneous
-- ════════════════════════════════════════════════════════════════════════
local MiscTab = Window:AddTab("···  Miscellaneous")

local MiscSection = MiscTab:AddSection("Miscellaneous")

MiscSection:AddToggle({
    Text     = "Chat Enabled",
    Desc     = "Show/hide the in-game chat",
    Default  = Settings.ChatEnabled,
    Callback = function(v)
        Settings.ChatEnabled = v
        -- game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, v)
    end,
})

MiscSection:AddToggle({
    Text     = "Hide HUD",
    Desc     = "Toggle the entire in-game HUD",
    Default  = Settings.HideHUD,
    Callback = function(v)
        Settings.HideHUD = v
        -- game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not v)
    end,
})

MiscSection:AddDropdown({
    Text     = "Language",
    Desc     = "UI display language",
    Values   = { "English", "Spanish", "French", "German", "Portuguese", "Arabic", "Japanese" },
    Default  = Settings.Language,
    Callback = function(v)
        Settings.Language = v
        Library:Notify({ Title = "Language", Description = "Changed to " .. v, Time = 2 })
    end,
})

MiscSection:AddDivider()

MiscSection:AddInput({
    Text        = "Discord Webhook URL",
    Desc        = "Paste your webhook to receive notifications",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default     = Settings.WebhookURL,
    Callback    = function(v)
        Settings.WebhookURL = v
        if v ~= "" then
            Library:Notify({ Title = "Webhook", Description = "URL saved!", Time = 2 })
        end
    end,
})

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Keybinds
-- ════════════════════════════════════════════════════════════════════════
local KeybindsTab = Window:AddTab("⚙  Keybinds")

local KeybindsSection = KeybindsTab:AddSection("Keybinds")

-- Reset button (red, like in the screenshot)
KeybindsSection:AddButton({
    Text     = "↺  Reset Keybinds",
    Desc     = "Reset all keybinds to their default",
    Callback = function()
        Library:Notify({
            Title       = "Keybinds Reset",
            Description = "All keybinds have been restored to defaults.",
            Time        = 3,
        })
    end,
})

KeybindsSection:AddDivider()

-- Display each keybind as a Label (read-only in this example)
-- In a real implementation you would use a custom Keybind picker component
local keybinds = {
    { name = "Dash",                        key = "Q"        },
    { name = "Sprint",                      key = "L Shift"  },
    { name = "Interact Prompt",             key = "E"        },
    { name = "Toggle Shift Lock",           key = "L Control"},
    { name = "Rotate Unit",                 key = "R"        },
    { name = "Cancel Unit Placement",       key = "Z"        },
    { name = "Quick Placement",             key = "L Shift"  },
    { name = "Upgrade Unit",                key = "T"        },
    { name = "Auto Upgrade Unit",           key = "—"        },
    { name = "Sell Unit",                   key = "—"        },
    { name = "Change Unit Targeting",       key = "R"        },
    { name = "Toggle Auto Skip Waves",      key = "—"        },
    { name = "Toggle Auto-Upgrade Units",   key = "—"        },
    { name = "Toggle Play Menu",            key = "—"        },
    { name = "Toggle Quests Menu",          key = "—"        },
    { name = "Toggle Areas Menu",           key = "—"        },
}

for _, kb in ipairs(keybinds) do
    KeybindsSection:AddLabel(("%-30s  [%s]"):format(kb.name, kb.key))
end

-- ════════════════════════════════════════════════════════════════════════
--  TAB: Testing
-- ════════════════════════════════════════════════════════════════════════
local TestingTab = Window:AddTab("⊙  Testing")

-- ── Debug tools ──────────────────────────────────────────────────────────
local DebugSection = TestingTab:AddSection("Debug")

DebugSection:AddToggle({
    Text     = "Debug Mode",
    Desc     = "Print debug info to the output window",
    Default  = Settings.DebugMode,
    Callback = function(v)
        Settings.DebugMode = v
        print("[CustomUI] Debug Mode:", v)
    end,
})

DebugSection:AddToggle({
    Text     = "Show Hitboxes",
    Desc     = "Visualise unit and enemy hitboxes",
    Default  = Settings.ShowHitboxes,
    Callback = function(v) Settings.ShowHitboxes = v end,
})

DebugSection:AddSlider({
    Text     = "Speed Multiplier",
    Desc     = "Walk-speed multiplier (testing only)",
    Min      = 1, Max = 10, Default = Settings.SpeedMultiplier,
    Rounding = 0, Suffix = "x",
    Callback = function(v)
        Settings.SpeedMultiplier = v
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16 * v
        end
    end,
})

-- ── Library stress-test ──────────────────────────────────────────────────
local TestSection = TestingTab:AddSection("Component Test")

TestSection:AddButton({
    Text     = "Send Test Notification",
    Callback = function()
        Library:Notify({
            Title       = "Test Notification",
            Description = "CustomUI is working correctly! 🎉",
            Time        = 4,
        })
    end,
})

local counter = 0
local CounterLabel = TestSection:AddLabel("Button presses: 0")

TestSection:AddButton({
    Text     = "Increment Counter",
    Callback = function()
        counter += 1
        CounterLabel:SetText("Button presses: " .. counter)
    end,
})

TestSection:AddDropdown({
    Text     = "Theme Variant",
    Desc     = "Switch accent color (extend CustomUI.lua to implement)",
    Values   = { "Cyan (default)", "Purple", "Gold", "Red", "Green" },
    Default  = "Cyan (default)",
    Callback = function(v)
        Library:Notify({ Title = "Theme", Description = v .. " selected (custom implementation needed)", Time = 3 })
    end,
})

TestSection:AddInput({
    Text        = "Custom Label Text",
    Placeholder = "Type something...",
    Callback    = function(v)
        if v ~= "" then
            CounterLabel:SetText(v)
        end
    end,
})

TestSection:AddDivider()
TestSection:AddLabel("All components above are functional – toggle, click, drag, type!")

-- ════════════════════════════════════════════════════════════════════════
--  Startup notification
-- ════════════════════════════════════════════════════════════════════════
Library:Notify({
    Title       = "Settings Loaded",
    Description = "CustomUI v1.0  •  All settings ready.",
    Time        = 4,
})
