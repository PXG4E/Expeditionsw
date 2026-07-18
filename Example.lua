--!strict
-- Example.lua
-- Put this in a LocalScript (e.g. StarterPlayerScripts) and require the
-- library from wherever you placed it (ReplicatedStorage recommended).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild("MyUILib"))

local Window = Library:CreateWindow({
	Title = "Settings",
	Size = UDim2.new(0, 900, 0, 560),
})

----------------------------------------------------------------
local Audio = Window:AddCategory("Audio")
local AudioSection = Audio:AddSection("Audio")

AudioSection:AddSlider({
	Title = "Music Volume",
	Description = "Adjusts all game music volume",
	Min = 0, Max = 2, Default = 1, Rounding = 1,
	Callback = function(v) print("Music volume:", v) end,
})

AudioSection:AddSlider({
	Title = "SFX Volume",
	Description = "Adjusts all game sound effect volume",
	Min = 0, Max = 2, Default = 1, Rounding = 1,
	Callback = function(v) print("SFX volume:", v) end,
})

----------------------------------------------------------------
local Gameplay = Window:AddCategory("Gameplay")
local GameplaySection = Gameplay:AddSection("Gameplay")

GameplaySection:AddToggle({
	Title = "Show Match End Rewards",
	Description = "Show reward pop-ups after matches",
	Default = true,
	Callback = function(v) print("Show Match End Rewards:", v) end,
})

GameplaySection:AddDropdown({
	Title = "Difficulty",
	Description = "Sets the game's difficulty",
	Values = { "Easy", "Normal", "Hard", "Insane" },
	Default = "Normal",
	Callback = function(v) print("Difficulty:", v) end,
})

----------------------------------------------------------------
local Graphics = Window:AddCategory("Graphics")
local GraphicsSection = Graphics:AddSection("Graphics")

GraphicsSection:AddDropdown({
	Title = "Quality",
	Values = { "Low", "Medium", "High", "Ultra" },
	Default = "High",
	Callback = function(v) print("Graphics quality:", v) end,
})
