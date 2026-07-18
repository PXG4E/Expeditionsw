--!strict
--[[
	Library.lua

	A standalone Roblox UI ModuleScript for building settings menus /
	control panels inside your OWN game. Plain require()-based module —
	no loadstring, no HttpGet, no remote code execution.

	Components: Window, Category (sidebar tab), Section (card),
	Toggle, Slider, Dropdown, Label, Divider. Live search filtering
	within the active category.
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--============================================================
-- THEME
--============================================================

local Theme = {
	Background    = Color3.fromRGB(10, 14, 20),
	Panel         = Color3.fromRGB(18, 22, 30),
	PanelAlt      = Color3.fromRGB(14, 18, 25),
	Sidebar       = Color3.fromRGB(16, 20, 27),
	SidebarActive = Color3.fromRGB(0, 170, 220),
	Accent        = Color3.fromRGB(0, 200, 255),
	Text          = Color3.fromRGB(235, 240, 245),
	SubText       = Color3.fromRGB(140, 150, 165),
	Stroke        = Color3.fromRGB(35, 42, 54),
	Green         = Color3.fromRGB(60, 200, 100),
	Red           = Color3.fromRGB(220, 60, 60),
	Font          = Enum.Font.GothamBold,
	FontRegular   = Enum.Font.Gotham,
	CornerRadius  = UDim.new(0, 8),
}

--============================================================
-- HELPERS
--============================================================

local function new(className: string, props: {[string]: any}): Instance
	local inst = Instance.new(className)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			(inst :: any)[k] = v
		end
	end
	if props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(parent: Instance, radius: UDim?)
	return new("UICorner", { CornerRadius = radius or Theme.CornerRadius, Parent = parent })
end

local function stroke(parent: Instance, color: Color3?, thickness: number?)
	return new("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function tween(inst: Instance, props: {[string]: any}, time: number?)
	local t = TweenService:Create(inst, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad), props)
	t:Play()
	return t
end

--============================================================
-- LIBRARY
--============================================================

local Library = {}
Library.__index = Library

--============================================================
-- ROW SHELL
--============================================================

local Controls = {}

function Controls.CreateRowFrame(parent: Instance, title: string, desc: string?)
	local Row = new("Frame", {
		BackgroundColor3 = Theme.PanelAlt,
		Size = UDim2.new(1, 0, 0, 62),
		ClipsDescendants = false,
		Parent = parent,
	})
	corner(Row)
	stroke(Row)

	local TextHolder = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0),
		Size = UDim2.new(1, -90, 1, 0),
		Parent = Row,
	})

	new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 0, 0, desc and 8 or 0),
		Size = UDim2.new(1, 0, 0, 18),
		Parent = TextHolder,
	})

	if desc then
		new("TextLabel", {
			BackgroundTransparency = 1,
			Font = Theme.FontRegular,
			Text = desc,
			TextColor3 = Theme.SubText,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 0, 0, 28),
			Size = UDim2.new(1, 0, 0, 24),
			Parent = TextHolder,
		})
	end

	-- searchable text used by the Window's search box
	(Row :: any):SetAttribute("SearchText", (title .. " " .. (desc or "")):lower())

	return Row
end

--============================================================
-- TOGGLE
--============================================================

function Controls.AddToggle(parent: Instance, opts: {[string]: any})
	local Row = Controls.CreateRowFrame(parent, opts.Title or "Toggle", opts.Description)

	local state = opts.Default == true

	local Btn = new("TextButton", {
		BackgroundColor3 = state and Theme.Green or Theme.Red,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(1, -50, 0.5, -18),
		Parent = Row,
	})
	corner(Btn, UDim.new(0, 6))

	local Icon = new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = state and "\u{2714}" or "\u{2715}",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 16,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = Btn,
	})

	local api = {}

	local function setState(value: boolean, fire: boolean?)
		state = value
		tween(Btn, { BackgroundColor3 = state and Theme.Green or Theme.Red })
		Icon.Text = state and "\u{2714}" or "\u{2715}"
		if fire ~= false and opts.Callback then
			opts.Callback(state)
		end
	end

	Btn.MouseButton1Click:Connect(function()
		setState(not state)
	end)

	function api:SetValue(value: boolean)
		setState(value, false)
	end

	function api:GetValue(): boolean
		return state
	end

	api.Instance = Row
	return api
end

--============================================================
-- SLIDER
--============================================================

function Controls.AddSlider(parent: Instance, opts: {[string]: any})
	local Row = Controls.CreateRowFrame(parent, opts.Title or "Slider", opts.Description)

	local min = opts.Min or 0
	local max = opts.Max or 1
	local rounding = opts.Rounding or 1
	local value = opts.Default or min

	local function roundVal(v: number): number
		local mult = 10 ^ rounding
		return math.floor(v * mult + 0.5) / mult
	end

	local ValueBox = new("TextLabel", {
		BackgroundColor3 = Theme.Panel,
		Font = Theme.FontRegular,
		Text = tostring(roundVal(value)),
		TextColor3 = Theme.Text,
		TextSize = 12,
		Size = UDim2.new(0, 40, 0, 22),
		Position = UDim2.new(1, -300, 0.5, -11),
		Parent = Row,
	})
	corner(ValueBox, UDim.new(0, 4))
	stroke(ValueBox)

	local Track = new("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(0, 220, 0, 6),
		Position = UDim2.new(1, -250, 0.5, -3),
		Parent = Row,
	})
	corner(Track, UDim.new(1, 0))

	local Fill = new("Frame", {
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		Parent = Track,
	})
	corner(Fill, UDim.new(1, 0))

	local Handle = new("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0, 14, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
		Parent = Track,
	})
	corner(Handle, UDim.new(1, 0))

	local dragging = false

	local function updateFromAlpha(alpha: number, fire: boolean?)
		alpha = math.clamp(alpha, 0, 1)
		value = roundVal(min + (max - min) * alpha)
		local realAlpha = (value - min) / (max - min)
		Fill.Size = UDim2.new(realAlpha, 0, 1, 0)
		Handle.Position = UDim2.new(realAlpha, 0, 0.5, 0)
		ValueBox.Text = tostring(value)
		if fire ~= false and opts.Callback then
			opts.Callback(value)
		end
	end

	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local alpha = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
			updateFromAlpha(alpha)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local alpha = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
			updateFromAlpha(alpha)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local api = {}

	function api:SetValue(v: number)
		updateFromAlpha((v - min) / (max - min), false)
	end

	function api:GetValue(): number
		return value
	end

	api.Instance = Row
	return api
end

--============================================================
-- DROPDOWN
--============================================================

function Controls.AddDropdown(parent: Instance, opts: {[string]: any})
	local Row = Controls.CreateRowFrame(parent, opts.Title or "Dropdown", opts.Description)

	local values: {string} = opts.Values or {}
	local selected: string = opts.Default or values[1] or ""
	local open = false

	local Btn = new("TextButton", {
		BackgroundColor3 = Theme.Panel,
		AutoButtonColor = false,
		Font = Theme.FontRegular,
		Text = "  " .. selected,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0, 180, 0, 32),
		Position = UDim2.new(1, -195, 0.5, -16),
		ZIndex = 5,
		Parent = Row,
	})
	corner(Btn, UDim.new(0, 6))
	stroke(Btn)

	new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = "\u{25BE}",
		TextColor3 = Theme.SubText,
		TextSize = 12,
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -22, 0, 0),
		ZIndex = 5,
		Parent = Btn,
	})

	local List = new("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(0, 180, 0, math.min(#values, 6) * 28 + 8),
		Position = UDim2.new(1, -195, 1, 4),
		Visible = false,
		ZIndex = 10,
		Parent = Row,
	})
	corner(List, UDim.new(0, 6))
	stroke(List)

	local ListLayout = new("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = List,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		Parent = List,
	})

	local api = {}

	local function setOpen(state: boolean)
		open = state
		List.Visible = state
	end

	local function select(value: string, fire: boolean?)
		selected = value
		Btn.Text = "  " .. value
		setOpen(false)
		if fire ~= false and opts.Callback then
			opts.Callback(value)
		end
	end

	for _, v in ipairs(values) do
		local Opt = new("TextButton", {
			BackgroundColor3 = Theme.PanelAlt,
			AutoButtonColor = true,
			Font = Theme.FontRegular,
			Text = v,
			TextColor3 = Theme.Text,
			TextSize = 12,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 11,
			Parent = List,
		})
		corner(Opt, UDim.new(0, 4))
		Opt.MouseButton1Click:Connect(function()
			select(v)
		end)
	end

	Btn.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)

	function api:SetValue(v: string)
		select(v, false)
	end

	function api:GetValue(): string
		return selected
	end

	api.Instance = Row
	return api
end

function Controls.AddLabel(parent: Instance, text: string)
	return new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.FontRegular,
		Text = text,
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 24),
		Parent = parent,
	})
end

--============================================================
-- SECTION
--============================================================

local Section = {}
Section.__index = Section

function Section.new(parent: Instance, title: string)
	local self = setmetatable({}, Section)

	local Holder = new("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,
	})

	new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = title,
		TextColor3 = Theme.Accent,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 24),
		Parent = Holder,
	})

	local Grid = new("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 0, 0),
		Parent = Holder,
	})

	new("UIGridLayout", {
		CellPadding = UDim2.new(0, 12, 0, 12),
		CellSize = UDim2.new(0.5, -6, 0, 62),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Grid,
	})

	self._holder = Holder
	self._grid = Grid
	return self
end

function Section:AddToggle(opts) return Controls.AddToggle(self._grid, opts) end
function Section:AddSlider(opts) return Controls.AddSlider(self._grid, opts) end
function Section:AddDropdown(opts) return Controls.AddDropdown(self._grid, opts) end
function Section:AddLabel(text: string) return Controls.AddLabel(self._grid, text) end

--============================================================
-- CATEGORY
--============================================================

local Category = {}
Category.__index = Category

function Category.new(window, name: string, iconId: string?)
	local self = setmetatable({}, Category)
	self._window = window
	self.Name = name

	local Btn = new("TextButton", {
		BackgroundColor3 = Theme.Sidebar,
		AutoButtonColor = false,
		Text = "",
		Size = UDim2.new(1, 0, 0, 38),
		Parent = window._sidebarList,
	})
	corner(Btn, UDim.new(0, 6))

	if iconId and iconId ~= "" then
		new("ImageLabel", {
			BackgroundTransparency = 1,
			Image = iconId,
			ImageColor3 = Theme.Text,
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 10, 0.5, -9),
			Parent = Btn,
		})
	end

	new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.FontRegular,
		Text = name,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, iconId and 36 or 12, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Parent = Btn,
	})

	local Page = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Accent,
		Visible = false,
		Parent = window._content,
	})

	new("UIListLayout", {
		Padding = UDim.new(0, 18),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Page,
	})

	new("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		Parent = Page,
	})

	self._button = Btn
	self._page = Page

	Btn.MouseButton1Click:Connect(function()
		window:SelectCategory(self)
	end)

	return self
end

function Category:AddSection(title: string)
	return Section.new(self._page, title)
end

function Category:SetActive(active: boolean)
	self._page.Visible = active
	tween(self._button, { BackgroundColor3 = active and Theme.SidebarActive or Theme.Sidebar })
end

--============================================================
-- WINDOW
--============================================================

local Window = {}
Window.__index = Window

function Window.new(opts: {[string]: any})
	local self = setmetatable({}, Window)

	local ScreenGui = new("ScreenGui", {
		Name = "Library",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})

	local Main = new("Frame", {
		BackgroundColor3 = Theme.Background,
		Size = opts.Size or UDim2.new(0, 900, 0, 560),
		Position = UDim2.new(0.5, -450, 0.5, -280),
		Parent = ScreenGui,
	})
	corner(Main, UDim.new(0, 12))
	stroke(Main, Theme.Stroke, 1)

	local Header = new("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 50),
		Parent = Main,
	})
	corner(Header, UDim.new(0, 12))

	new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.Font,
		Text = opts.Title or "Settings",
		TextColor3 = Theme.Accent,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 20, 0, 0),
		Size = UDim2.new(0, 300, 1, 0),
		Parent = Header,
	})

	local SearchBox = new("TextBox", {
		BackgroundColor3 = Theme.Background,
		PlaceholderText = "Search...",
		Text = "",
		Font = Theme.FontRegular,
		TextColor3 = Theme.Text,
		PlaceholderColor3 = Theme.SubText,
		TextSize = 13,
		ClearTextOnFocus = false,
		Size = UDim2.new(0, 260, 0, 32),
		Position = UDim2.new(1, -330, 0.5, -16),
		Parent = Header,
	})
	corner(SearchBox, UDim.new(0, 6))
	stroke(SearchBox)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = SearchBox })

	local CloseBtn = new("TextButton", {
		BackgroundColor3 = Theme.Red,
		AutoButtonColor = false,
		Text = "\u{2715}",
		Font = Theme.Font,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 16,
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -50, 0.5, -16),
		Parent = Header,
	})
	corner(CloseBtn, UDim.new(1, 0))
	CloseBtn.MouseButton1Click:Connect(function()
		Main.Visible = false
	end)

	local Body = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 1, -50),
		Parent = Main,
	})

	local Sidebar = new("Frame", {
		BackgroundColor3 = Theme.Sidebar,
		Size = UDim2.new(0, 190, 1, 0),
		Parent = Body,
	})

	local SidebarList = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		Parent = Sidebar,
	})
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = SidebarList,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = SidebarList,
	})

	local Content = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 190, 0, 0),
		Size = UDim2.new(1, -190, 1, 0),
		Parent = Body,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 16),
		Parent = Content,
	})

	self._gui = ScreenGui
	self._main = Main
	self._sidebarList = SidebarList
	self._content = Content
	self._categories = {}
	self._search = SearchBox

	-- Live search: filters rows within the currently active category
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = SearchBox.Text:lower()
		for _, cat in ipairs(self._categories) do
			if cat._page.Visible then
				for _, holder in ipairs(cat._page:GetChildren()) do
					if holder:IsA("Frame") then
						local grid = holder:FindFirstChildOfClass("Frame")
						if grid then
							local anyVisible = false
							for _, row in ipairs(grid:GetChildren()) do
								if row:IsA("Frame") then
									local searchText = (row :: any):GetAttribute("SearchText") or ""
									local match = query == "" or searchText:find(query, 1, true) ~= nil
									row.Visible = match
									anyVisible = anyVisible or match
								end
							end
							holder.Visible = anyVisible
						end
					end
				end
			end
		end
	end)

	return self
end

function Window:AddCategory(name: string, iconId: string?)
	local cat = Category.new(self, name, iconId)
	table.insert(self._categories, cat)
	if #self._categories == 1 then
		self:SelectCategory(cat)
	end
	return cat
end

function Window:SelectCategory(target)
	for _, cat in ipairs(self._categories) do
		cat:SetActive(cat == target)
	end
end

function Window:Toggle()
	self._main.Visible = not self._main.Visible
end

function Window:Destroy()
	self._gui:Destroy()
end

--============================================================
-- PUBLIC ENTRY POINT
--============================================================

function Library:CreateWindow(opts: {[string]: any}?)
	return Window.new(opts or {})
end

return Library
