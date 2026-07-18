--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              CustomUI  –  Roblox UI Library             ║
    ║  Replaces Obsidian. Same API, fully custom visuals.     ║
    ╚══════════════════════════════════════════════════════════╝

    HOW TO USE IN YOUR SCRIPT:
    ─────────────────────────────────────────────────────────
    local Library = loadstring(game:HttpGet("RAW_URL_HERE"))()

    local Window  = Library:CreateWindow({ Title = "mspaint" })
    local Tab     = Window:AddTab("Main")
    local Section = Tab:AddSection("Auto Farm")

    Section:AddToggle({
        Text     = "Auto Farm Selected",
        Default  = false,
        Callback = function(Value)
            if Value then startFarm() else stopFarm() end
        end
    })

    Section:AddButton({
        Text     = "Teleport",
        Callback = function()
            teleport()
        end
    })

    Section:AddSlider({
        Text    = "Attack Distance",
        Min     = 1, Max = 30, Default = 7,
        Suffix  = " studs",
        Callback = function(Value)
            attackDistance = Value
        end
    })
    ─────────────────────────────────────────────────────────
]]

local Library = {}
Library.__index = Library

-- ─── Services ──────────────────────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer
local PlayerGui       = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Theme ─────────────────────────────────────────────────────────────────
local Theme = {
    Background    = Color3.fromRGB(13,  13,  13),   -- main window
    Sidebar       = Color3.fromRGB(20,  20,  20),   -- sidebar
    Section       = Color3.fromRGB(17,  17,  17),   -- section area
    Border        = Color3.fromRGB(35,  35,  35),
    Accent        = Color3.fromRGB(0,  180, 230),   -- cyan
    AccentDark    = Color3.fromRGB(0,  140, 190),
    ToggleOn      = Color3.fromRGB(34, 197,  78),   -- green
    ToggleOff     = Color3.fromRGB(220, 50,  50),   -- red
    TextPrimary   = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(130, 130, 130),
    TextAccent    = Color3.fromRGB(0,  200, 248),
    TabActive     = Color3.fromRGB(0,  180, 230),
    TabInactive   = Color3.fromRGB(28,  28,  28),
    ButtonBg      = Color3.fromRGB(28,  28,  28),
    InputBg       = Color3.fromRGB(22,  22,  22),
    SliderFill    = Color3.fromRGB(0,  200, 248),
    SliderTrack   = Color3.fromRGB(40,  40,  40),
}

-- ─── Helpers ───────────────────────────────────────────────────────────────

local function Tween(obj, props, duration)
    duration = duration or 0.15
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad), props):Play()
end

local function Make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function AddCorner(parent, radius)
    return Make("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, parent)
end

local function AddStroke(parent, color, thickness)
    return Make("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function AddPadding(parent, top, right, bottom, left)
    return Make("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 6),
        PaddingRight  = UDim.new(0, right  or 10),
        PaddingBottom = UDim.new(0, bottom or 6),
        PaddingLeft   = UDim.new(0, left   or 10),
    }, parent)
end

local function AddListLayout(parent, dir, padding, align)
    return Make("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, padding or 0),
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
    }, parent)
end

-- auto-resize a frame to fit its UIListLayout
local function AutoSize(frame, layout)
    local function resize()
        frame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    resize()
end

-- ─── NOTIFY ────────────────────────────────────────────────────────────────

local NotifyGui = Make("ScreenGui", {
    Name = "CustomUI_Notify",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local NotifyHolder = Make("Frame", {
    Name = "Holder",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -10, 0, 10),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 280, 1, -20),
}, NotifyGui)

AddListLayout(NotifyHolder, Enum.FillDirection.Vertical, 6)

function Library:Notify(options)
    local title = options.Title or "Notification"
    local desc  = options.Description or ""
    local time  = options.Time or 3

    local toast = Make("Frame", {
        Name = "Toast",
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        Size = UDim2.new(1, 0, 0, 60),
        ClipsDescendants = true,
    }, NotifyHolder)
    AddCorner(toast, 7)
    AddStroke(toast, Theme.Border)

    -- left accent bar
    Make("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
    }, toast)
    AddCorner(Make("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
    }, toast), 3)

    local inner = Make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -15, 1, 0),
    }, toast)
    AddListLayout(inner, Enum.FillDirection.Vertical, 2)
    AddPadding(inner, 8, 6, 8, 0)

    Make("TextLabel", {
        Text = title,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, inner)

    Make("TextLabel", {
        Text = desc,
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, inner)

    -- progress bar
    local bar = Make("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
    }, toast)

    Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, time)

    task.delay(time, function()
        Tween(toast, { BackgroundTransparency = 1 }, 0.3)
        task.delay(0.3, function()
            toast:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════
--  COMPONENTS
-- ═══════════════════════════════════════════════════════════

local ComponentMixin = {}

-- ── DIVIDER ────────────────────────────────────────────────
function ComponentMixin:AddDivider()
    Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = self._order,
    }, self._content)
    self._order += 1
end

-- ── LABEL ──────────────────────────────────────────────────
function ComponentMixin:AddLabel(text)
    local lbl = Make("TextLabel", {
        Text = text or "",
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = self._order,
    }, self._content)
    AddPadding(lbl, 0, 10, 0, 14)
    self._order += 1

    -- returns a handle with :SetText()
    return {
        SetText = function(_, newText)
            lbl.Text = newText
        end
    }
end

-- ── TOGGLE ─────────────────────────────────────────────────
--[[
    Section:AddToggle({
        Text     = "Auto Farm",
        Desc     = "Description here",   -- optional
        Default  = false,
        Callback = function(Value) end,
    })

    returned handle:
        toggle:Set(true/false)   -- set value from code
        toggle.Value             -- read current value
]]
function ComponentMixin:AddToggle(opts)
    opts = opts or {}
    local text     = opts.Text     or "Toggle"
    local desc     = opts.Desc     or opts.Description or nil
    local default  = opts.Default  ~= nil and opts.Default or false
    local callback = opts.Callback or function() end
    local value    = default

    local height = desc and 46 or 34

    local row = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = self._order,
    }, self._content)
    self._order += 1

    -- separator line at bottom
    Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
    }, row)

    -- label
    local labelFrame = Make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
    }, row)
    AddListLayout(labelFrame, Enum.FillDirection.Vertical, 2)
    AddPadding(labelFrame, desc and 6 or 9, 0, 0, 0)

    Make("TextLabel", {
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, labelFrame)

    if desc then
        Make("TextLabel", {
            Text = desc,
            TextColor3 = Theme.TextSecondary,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        }, labelFrame)
    end

    -- toggle button
    local btn = Make("TextButton", {
        Text = "",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -44, 0.5, -16),
        BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
        AutoButtonColor = false,
    }, row)
    AddCorner(btn, 7)

    -- icon (checkmark / X)
    local icon = Make("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.5, -9, 0.5, -9),
        Image = value
            and "rbxassetid://7072706620"   -- checkmark
            or  "rbxassetid://7072725342",  -- X
        ImageColor3 = Color3.fromRGB(255, 255, 255),
    }, btn)

    local handle = { Value = value }

    local function setState(newVal, silent)
        value = newVal
        handle.Value = newVal
        Tween(btn, { BackgroundColor3 = newVal and Theme.ToggleOn or Theme.ToggleOff })
        icon.Image = newVal
            and "rbxassetid://7072706620"
            or  "rbxassetid://7072725342"
        if not silent then
            callback(newVal)
        end
    end

    btn.MouseButton1Click:Connect(function()
        setState(not value)
    end)

    function handle:Set(v)
        setState(v, false)
    end

    return handle
end

-- ── BUTTON ─────────────────────────────────────────────────
--[[
    Section:AddButton({
        Text     = "Teleport",
        Desc     = "optional subtitle",
        Callback = function() end,
    })
]]
function ComponentMixin:AddButton(opts)
    opts = opts or {}
    local text     = opts.Text     or "Button"
    local callback = opts.Callback or function() end

    local container = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 44),
        LayoutOrder = self._order,
    }, self._content)
    self._order += 1

    Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
    }, container)

    local btn = Make("TextButton", {
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BackgroundColor3 = Theme.ButtonBg,
        AutoButtonColor = false,
        Size = UDim2.new(1, -28, 0, 30),
        Position = UDim2.new(0, 14, 0.5, -15),
    }, container)
    AddCorner(btn, 7)
    AddStroke(btn, Theme.Border)

    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.ButtonBg })
    end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.Accent })
        task.delay(0.15, function()
            Tween(btn, { BackgroundColor3 = Theme.ButtonBg })
        end)
        callback()
    end)
end

-- ── SLIDER ─────────────────────────────────────────────────
--[[
    Section:AddSlider({
        Text     = "Attack Distance",
        Desc     = "optional",
        Min      = 1,
        Max      = 30,
        Default  = 7,
        Rounding = 1,       -- decimal places (0 = integer)
        Suffix   = " studs",
        Callback = function(Value) end,
    })

    returned handle:
        slider:Set(15)   -- set from code
        slider.Value     -- read current value
]]
function ComponentMixin:AddSlider(opts)
    opts = opts or {}
    local text     = opts.Text     or "Slider"
    local desc     = opts.Desc     or opts.Description or nil
    local min      = opts.Min      or 0
    local max      = opts.Max      or 100
    local default  = opts.Default  or min
    local rounding = opts.Rounding or 1
    local suffix   = opts.Suffix   or ""
    local callback = opts.Callback or function() end
    local value    = default

    local height = desc and 64 or 54

    local container = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = self._order,
        ClipsDescendants = false,
    }, self._content)
    self._order += 1

    Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
    }, container)

    -- label row
    local labelY = desc and 10 or 8
    Make("TextLabel", {
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, labelY),
        Size = UDim2.new(0.6, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)

    if desc then
        Make("TextLabel", {
            Text = desc,
            TextColor3 = Theme.TextSecondary,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 28),
            Size = UDim2.new(0.8, 0, 0, 13),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, container)
    end

    -- value display box
    local valBox = Make("TextLabel", {
        Text = tostring(value) .. suffix,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        Position = UDim2.new(0, 14, 0, height - 26),
        Size = UDim2.new(0, 46, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, container)
    AddCorner(valBox, 4)
    AddStroke(valBox, Theme.Border)

    -- track
    local trackY = height - 22
    local track = Make("Frame", {
        BackgroundColor3 = Theme.SliderTrack,
        Position = UDim2.new(0, 68, 0, trackY),
        Size = UDim2.new(1, -82, 0, 6),
    }, container)
    AddCorner(track, 3)

    -- fill
    local pct = (default - min) / (max - min)
    local fill = Make("Frame", {
        BackgroundColor3 = Theme.SliderFill,
        Size = UDim2.new(pct, 0, 1, 0),
    }, track)
    AddCorner(fill, 3)

    -- thumb
    local thumb = Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(pct, -8, 0.5, -8),
        ZIndex = 2,
    }, track)
    AddCorner(thumb, 8)

    -- shadow on thumb
    Make("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, thumb)

    local handle = { Value = value }
    local dragging = false

    local function updateSlider(input)
        local trackPos    = track.AbsolutePosition.X
        local trackWidth  = track.AbsoluteSize.X
        local relX        = math.clamp(input.Position.X - trackPos, 0, trackWidth)
        local rawPct      = relX / trackWidth
        local rawVal      = min + (max - min) * rawPct
        local factor      = 10 ^ rounding
        local rounded     = math.round(rawVal * factor) / factor

        value = math.clamp(rounded, min, max)
        handle.Value = value

        local newPct = (value - min) / (max - min)
        fill.Size  = UDim2.new(newPct, 0, 1, 0)
        thumb.Position = UDim2.new(newPct, -8, 0.5, -8)
        valBox.Text = tostring(value) .. suffix

        callback(value)
    end

    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(i)
        end
    end)

    function handle:Set(v)
        value = math.clamp(v, min, max)
        handle.Value = value
        local p = (value - min) / (max - min)
        fill.Size = UDim2.new(p, 0, 1, 0)
        thumb.Position = UDim2.new(p, -8, 0.5, -8)
        valBox.Text = tostring(value) .. suffix
        callback(value)
    end

    return handle
end

-- ── DROPDOWN ───────────────────────────────────────────────
--[[
    Section:AddDropdown({
        Text     = "Select Enemy",
        Values   = { "N/A", "Pirate", "Sea Beast" },
        Default  = "N/A",
        Callback = function(Value) end,
    })

    returned handle:
        dropdown:Set("Pirate")
        dropdown.Value
]]
function ComponentMixin:AddDropdown(opts)
    opts = opts or {}
    local text     = opts.Text     or "Dropdown"
    local values   = opts.Values   or {}
    local default  = opts.Default  or (values[1] or "")
    local callback = opts.Callback or function() end
    local current  = default
    local open     = false

    local container = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 54),
        LayoutOrder = self._order,
        ClipsDescendants = false,
        ZIndex = 3,
    }, self._content)
    self._order += 1

    Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
    }, container)

    Make("TextLabel", {
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -28, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)

    local btn = Make("TextButton", {
        Text = current,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        BackgroundColor3 = Theme.InputBg,
        AutoButtonColor = false,
        Position = UDim2.new(0, 14, 0, 28),
        Size = UDim2.new(1, -28, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, container)
    AddCorner(btn, 5)
    AddStroke(btn, Theme.Border)
    AddPadding(btn, 0, 24, 0, 8)

    -- chevron
    local chevron = Make("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://6034818372",
        ImageColor3 = Theme.TextSecondary,
        Rotation = 0,
        ZIndex = 5,
    }, btn)

    -- dropdown list (appears below)
    local listFrame = Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        Position = UDim2.new(0, 14, 1, 2),
        Size = UDim2.new(1, -28, 0, 0),
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
    }, container)
    AddCorner(listFrame, 5)
    AddStroke(listFrame, Theme.Border)

    local listLayout = AddListLayout(listFrame, Enum.FillDirection.Vertical, 0)

    for _, v in ipairs(values) do
        local item = Make("TextButton", {
            Text = v,
            TextColor3 = v == current and Theme.TextAccent or Theme.TextPrimary,
            Font = v == current and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = 13,
            BackgroundColor3 = v == current
                and Color3.fromRGB(0, 180, 230, 0.1)
                or Color3.fromRGB(22, 22, 22),
            BackgroundTransparency = v == current and 0.9 or 1,
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 28),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
        }, listFrame)
        AddPadding(item, 0, 0, 0, 10)

        Make("Frame", {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BorderSizePixel = 0,
            ZIndex = 11,
        }, item)

        item.MouseButton1Click:Connect(function()
            current = v
            btn.Text = v
            for _, child in ipairs(listFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = child.Text == v and Theme.TextAccent or Theme.TextPrimary
                    child.Font = child.Text == v and Enum.Font.GothamBold or Enum.Font.Gotham
                end
            end
            open = false
            listFrame.Visible = false
            Tween(chevron, { Rotation = 0 })
            callback(v)
        end)
    end

    -- size list to content
    listFrame.Size = UDim2.new(1, -28, 0, #values * 28)

    btn.MouseButton1Click:Connect(function()
        open = not open
        listFrame.Visible = open
        Tween(chevron, { Rotation = open and 180 or 0 })
    end)

    local handle = { Value = current }
    function handle:Set(v)
        current = v
        handle.Value = v
        btn.Text = v
        callback(v)
    end
    return handle
end

-- ── INPUT ──────────────────────────────────────────────────
--[[
    Section:AddInput({
        Text        = "Webhook URL",
        Placeholder = "https://discord.com/...",
        Default     = "",
        Callback    = function(Value) end,   -- fires on FocusLost
    })
]]
function ComponentMixin:AddInput(opts)
    opts = opts or {}
    local text        = opts.Text        or "Input"
    local placeholder = opts.Placeholder or ""
    local default     = opts.Default     or ""
    local callback    = opts.Callback    or function() end

    local container = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 54),
        LayoutOrder = self._order,
    }, self._content)
    self._order += 1

    Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
    }, container)

    Make("TextLabel", {
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -28, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)

    local box = Make("TextBox", {
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        BackgroundColor3 = Theme.InputBg,
        ClearTextOnFocus = false,
        Position = UDim2.new(0, 14, 0, 28),
        Size = UDim2.new(1, -28, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
    AddCorner(box, 5)
    AddStroke(box, Theme.Border)
    AddPadding(box, 0, 8, 0, 8)

    box.FocusLost:Connect(function()
        callback(box.Text)
    end)

    local handle = { Value = default }
    function handle:Set(v)
        box.Text = v
        handle.Value = v
    end
    function handle:Get()
        return box.Text
    end
    return handle
end

-- ═══════════════════════════════════════════════════════════
--  SECTION
-- ═══════════════════════════════════════════════════════════

local SectionClass = {}
SectionClass.__index = SectionClass
for k, v in pairs(ComponentMixin) do SectionClass[k] = v end

function SectionClass.new(parent, title, layoutOrder)
    local self = setmetatable({}, SectionClass)
    self._order = 1

    -- section wrapper
    local wrapper = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = layoutOrder,
    }, parent)

    -- header
    local header = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        LayoutOrder = 0,
    }, wrapper)

    Make("TextLabel", {
        Text = title,
        TextColor3 = Theme.TextAccent,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 2),
        Size = UDim2.new(1, -28, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    -- wave line under header (simplified as gradient frame)
    local wave = Make("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, -28, 0, 1),
        Position = UDim2.new(0, 14, 1, -1),
    }, header)
    Make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.1, Theme.Accent),
            ColorSequenceKeypoint.new(0.9, Theme.Accent),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 0, 0)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   1),
            NumberSequenceKeypoint.new(0.2, 0),
            NumberSequenceKeypoint.new(0.8, 0),
            NumberSequenceKeypoint.new(1,   1),
        }),
    }, wave)

    -- content area (auto-sizes)
    local content = Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 28),
    }, wrapper)
    local layout = AddListLayout(content, Enum.FillDirection.Vertical, 0)

    -- auto-resize wrapper to header + content
    local function resize()
        local h = 28 + layout.AbsoluteContentSize.Y
        wrapper.Size = UDim2.new(1, 0, 0, h)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    resize()

    self._content = content
    return self
end

-- ═══════════════════════════════════════════════════════════
--  TAB
-- ═══════════════════════════════════════════════════════════

local TabClass = {}
TabClass.__index = TabClass

function TabClass.new(contentParent, name, layoutOrder)
    local self = setmetatable({}, TabClass)
    self._name = name
    self._sectionOrder = 1

    -- scrolling content frame for this tab
    self._frame = Make("ScrollingFrame", {
        Name = name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        LayoutOrder = layoutOrder,
    }, contentParent)
    AddListLayout(self._frame, Enum.FillDirection.Vertical, 0)
    AddPadding(self._frame, 4, 0, 8, 0)

    return self
end

function TabClass:AddSection(title)
    local section = SectionClass.new(self._frame, title, self._sectionOrder)
    self._sectionOrder += 1
    return section
end

-- ═══════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════

local WindowClass = {}
WindowClass.__index = WindowClass

function Library:CreateWindow(opts)
    opts = opts or {}
    local title  = opts.Title or "Script"
    local self   = setmetatable({}, WindowClass)
    self._tabs   = {}
    self._tabOrder = 1

    -- ── ScreenGui ──────────────────────────────────────────
    local gui = Make("ScreenGui", {
        Name = "CustomUI_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)

    -- ── Window frame ───────────────────────────────────────
    local win = Make("Frame", {
        Name = "Window",
        BackgroundColor3 = Theme.Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 880, 0, 530),
    }, gui)
    AddCorner(win, 10)

    -- outer cyan glow stroke
    Make("UIStroke", {
        Color = Theme.Accent,
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, win)

    -- shadow
    Make("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.7,
        ZIndex = 0,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
    }, win)

    -- ── Title badge (top-left, overlaps border) ────────────
    local badge = Make("Frame", {
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, -2, 0, -18),
        Size = UDim2.new(0, 180, 0, 36),
        ZIndex = 5,
    }, win)
    Make("UICorner", { CornerRadius = UDim.new(0, 8) }, badge)
    Make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.AccentDark),
            ColorSequenceKeypoint.new(1, Theme.Accent),
        }),
        Rotation = 90,
    }, badge)

    Make("TextLabel", {
        Text = "⚙  " .. title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, badge)

    -- ── Search bar + Close ─────────────────────────────────
    local header = Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        Size = UDim2.new(1, 0, 0, 42),
        BorderSizePixel = 0,
        ZIndex = 3,
    }, win)
    Make("Frame", {
        BackgroundColor3 = Theme.Border,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
    }, header)

    -- search box (starts at x=200 to leave room for badge)
    local searchBox = Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        Position = UDim2.new(0, 200, 0.5, -13),
        Size = UDim2.new(1, -248, 0, 26),
        ZIndex = 3,
    }, header)
    AddCorner(searchBox, 6)
    AddStroke(searchBox, Theme.Border)

    Make("TextLabel", {
        Text = "🔍",
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        ZIndex = 4,
    }, searchBox)

    Make("TextBox", {
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        ZIndex = 4,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, searchBox)

    -- close button
    local closeBtn = Make("TextButton", {
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(200, 40, 40),
        AutoButtonColor = false,
        Position = UDim2.new(1, -42, 0.5, -13),
        Size = UDim2.new(0, 26, 0, 26),
        ZIndex = 3,
    }, header)
    AddCorner(closeBtn, 13)

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- ── Body (sidebar + content) ───────────────────────────
    local body = Make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 1, -42),
    }, win)

    -- sidebar
    local sidebar = Make("ScrollingFrame", {
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 210, 1, 0),
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, body)
    AddListLayout(sidebar, Enum.FillDirection.Vertical, 0)
    AddPadding(sidebar, 8, 8, 8, 8)
    Make("Frame", {
        BackgroundColor3 = Theme.Border,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0,
    }, sidebar)

    -- content area
    local contentArea = Make("Frame", {
        BackgroundColor3 = Color3.fromRGB(11, 11, 11),
        Position = UDim2.new(0, 210, 0, 0),
        Size = UDim2.new(1, -210, 1, 0),
        BorderSizePixel = 0,
    }, body)

    -- ── Dragging ───────────────────────────────────────────
    local dragging, dragStart, startPos
    win.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    self._sidebar     = sidebar
    self._contentArea = contentArea
    self._activeTab   = nil

    return self
end

function WindowClass:AddTab(name)
    local tab = TabClass.new(self._contentArea, name, self._tabOrder)

    -- sidebar button
    local btn = Make("TextButton", {
        Text = name,
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        BackgroundColor3 = Theme.TabInactive,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 34),
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = self._tabOrder,
    }, self._sidebar)
    AddCorner(btn, 6)
    AddPadding(btn, 0, 0, 0, 12)
    Make("UIStroke", {
        Color = Theme.TabActive,
        Thickness = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, btn)

    local function activate()
        for _, t in ipairs(self._tabs) do
            t.frame.Visible = false
            Tween(t.btn, {
                BackgroundColor3 = Theme.TabInactive,
                BackgroundTransparency = 1,
                TextColor3 = Theme.TextSecondary,
            })
            t.btn.Font = Enum.Font.Gotham
        end
        tab._frame.Visible = true
        Tween(btn, {
            BackgroundColor3 = Theme.TabActive,
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromRGB(255, 255, 255),
        })
        btn.Font = Enum.Font.GothamBold
        self._activeTab = tab
    end

    btn.MouseButton1Click:Connect(activate)
    btn.MouseEnter:Connect(function()
        if self._activeTab ~= tab then
            Tween(btn, { BackgroundTransparency = 0.85, TextColor3 = Theme.TextPrimary })
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._activeTab ~= tab then
            Tween(btn, { BackgroundTransparency = 1, TextColor3 = Theme.TextSecondary })
        end
    end)

    table.insert(self._tabs, { frame = tab._frame, btn = btn })
    self._tabOrder += 1

    -- auto-select first tab
    if #self._tabs == 1 then
        activate()
    end

    return tab
end

return Library
