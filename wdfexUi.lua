-- ============================================================
-- 自定义 UI 库（模仿 WindUI 风格，自实现）
-- ============================================================

local cloneref = cloneref or clonereference or function(i) return i end
local Players = cloneref(game:GetService("Players"))
local UIS = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
    Background     = Color3.fromRGB(22, 22, 28),
    BackgroundAlt  = Color3.fromRGB(30, 30, 38),
    Element        = Color3.fromRGB(40, 40, 50),
    ElementHover   = Color3.fromRGB(52, 52, 64),
    Text           = Color3.fromRGB(240, 240, 245),
    TextDim        = Color3.fromRGB(150, 150, 165),
    Accent         = Color3.fromRGB(120, 90, 220),
    AccentHover    = Color3.fromRGB(140, 110, 240),
    Stroke         = Color3.fromRGB(60, 60, 75),
    Danger         = Color3.fromRGB(220, 80, 80),
    Success        = Color3.fromRGB(80, 200, 120),
    ToggleOn       = Color3.fromRGB(120, 90, 220),
    ToggleOff      = Color3.fromRGB(70, 70, 85),
    Corner         = UDim.new(0, 8),
}

local function getHui()
    local hui
    pcall(function()
        if type(gethui) == "function" then hui = gethui() end
    end)
    if hui then return hui end
    pcall(function() hui = game:FindService("CoreGui") end)
    if hui then return hui end
    return PlayerGui
end

local Lib = {}
Lib.__index = Lib

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = radius or Theme.Corner }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function padding(parent, all)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, all),
        PaddingBottom = UDim.new(0, all),
        PaddingLeft = UDim.new(0, all),
        PaddingRight = UDim.new(0, all),
    }, parent)
end

local function draggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- Window
-- ============================================================
function Lib:CreateWindow(opts)
    opts = opts or {}
    local self = setmetatable({}, Lib)
    self.Tabs = {}
    self.ActiveTab = nil
    self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    self.Minimized = false

    local gui = new("ScreenGui", {
        Name = opts.Folder or "CustomUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 100,
    }, getHui())
    self.Gui = gui

    -- 主窗口
    local window = new("Frame", {
        Name = "Window",
        Size = opts.Size or UDim2.fromOffset(620, 460),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    corner(window)
    stroke(window, Theme.Stroke, 1.5)
    self.Window = window

    -- 标题栏
    local titleBar = new("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
    }, window)
    corner(titleBar)
    local titleBarFix = new("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
    }, titleBar)

    new("TextLabel", {
        Text = opts.Title or "Window",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)

    -- 最小化按钮
    local minBtn = new("TextButton", {
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.fromOffset(30, 42),
    }, titleBar)
    minBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        window.Visible = not self.Minimized
    end)

    -- 关闭按钮
    local closeBtn = new("TextButton", {
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -38, 0, 0),
        Size = UDim2.fromOffset(30, 42),
    }, titleBar)
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    draggable(window, titleBar)

    -- 侧边栏
    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, opts.SideBarWidth or 160, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
    }, window)
    new("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
    }, sidebar)

    local tabContainer = new("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -16),
        Position = UDim2.new(0, 6, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    local tabLayout = new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabContainer)
    self.TabContainer = tabContainer

    -- 内容区
    local content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -(opts.SideBarWidth or 160), 1, -42),
        Position = UDim2.new(0, opts.SideBarWidth or 160, 0, 42),
        BackgroundTransparency = 1,
    }, window)
    self.Content = content

    -- 切换键
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == self.ToggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    return self
end

-- ============================================================
-- Tab
-- ============================================================
function Lib:Tab(opts)
    opts = opts or {}
    local self = self
    local window = self

    local btn = new("TextButton", {
        Text = "  " .. (opts.Title or "Tab"),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.TextDim,
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, window.TabContainer)
    corner(btn, UDim.new(0, 6))

    -- 内容页
    local page = new("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, window.Content)
    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    local tab = {
        Button = btn,
        Page = page,
        Window = window,
        Title = opts.Title or "Tab",
        ElementCount = 0,
    }

    btn.MouseEnter:Connect(function()
        if window.ActiveTab ~= tab then
            btn.BackgroundTransparency = 0.6
        end
    end)
    btn.MouseLeave:Connect(function()
        if window.ActiveTab ~= tab then
            btn.BackgroundTransparency = 1
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if window.ActiveTab then
            window.ActiveTab.Page.Visible = false
            window.ActiveTab.Button.BackgroundTransparency = 1
            window.ActiveTab.Button.TextColor3 = Theme.TextDim
        end
        window.ActiveTab = tab
        page.Visible = true
        btn.BackgroundTransparency = 0
        btn.TextColor3 = Theme.Text
    end)

    table.insert(self.Tabs, tab)
    if not self.ActiveTab then
        btn.MouseButton1Click:Fire()
    end
    return tab
end

-- ============================================================
-- Section
-- ============================================================
function Lib:Section(parent, opts)
    opts = opts or {}
    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent.Page or parent)
    corner(holder, UDim.new(0, 6))
    stroke(holder, Theme.Stroke, 1)

    local header = new("TextButton", {
        Text = "  " .. (opts.Title or "Section"),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local arrow = new("TextLabel", {
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -26, 0, 0),
        Size = UDim2.fromOffset(20, 32),
    }, holder)

    local container = new("Frame", {
        Size = UDim2.new(1, -12, 0, 0),
        Position = UDim2.new(0, 6, 0, 34),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, holder)
    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)
    new("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
    }, container)

    local opened = opts.Opened ~= false
    local function refresh()
        container.Visible = opened
        arrow.Text = opened and "▼" or "▶"
        holder.Size = opened and UDim2.new(1, 0, 0, holder.AbsoluteSize.Y)
            or UDim2.new(1, 0, 0, 32)
        if opened then
            holder.AutomaticSize = Enum.AutomaticSize.Y
        else
            holder.AutomaticSize = Enum.AutomaticSize.None
            holder.Size = UDim2.new(1, 0, 0, 32)
        end
    end
    refresh()

    header.MouseButton1Click:Connect(function()
        opened = not opened
        refresh()
    end)

    local sec = {
        Holder = holder,
        Container = container,
        Page = container,
        Opened = opened,
    }
    sec.SetTitle = function(title)
        header.Text = "  " .. tostring(title)
    end
    return sec
end

-- ============================================================
-- 控件辅助
-- ============================================================
local function makeRow(parent, height)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, height or 28),
        BackgroundTransparency = 1,
    }, parent)
    return row
end

local function makeLabel(parent, text, color)
    return new("TextLabel", {
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = color or Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

-- ============================================================
-- Toggle
-- ============================================================
function Lib:Toggle(parent, opts)
    opts = opts or {}
    local container = parent.Page or parent.Container or parent
    local row = makeRow(container, 30)
    local label = makeLabel(row, opts.Title or "Toggle")
    label.Size = UDim2.new(0.7, 0, 1, 0)

    local track = new("Frame", {
        Size = UDim2.fromOffset(38, 20),
        Position = UDim2.new(1, -44, 0.5, -10),
        BackgroundColor3 = opts.Value and Theme.ToggleOn or Theme.ToggleOff,
        BorderSizePixel = 0,
    }, row)
    corner(track, UDim.new(1, 0))

    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = opts.Value and UDim2.new(1, -18, 0.5, -8)
            or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, track)
    corner(knob, UDim.new(1, 0))

    local state = opts.Value or false
    local function update()
        track.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
        knob.Position = state and UDim2.new(1, -18, 0.5, -8)
            or UDim2.new(0, 2, 0.5, -8)
    end
    update()

    local btn = new("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
    }, row)

    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
        if opts.Callback then pcall(opts.Callback, state) end
    end)

    return {
        Set = function(v)
            state = v and true or false
            update()
            if opts.Callback then pcall(opts.Callback, state) end
        end,
        Get = function() return state end,
    }
end

-- ============================================================
-- Slider
-- ============================================================
function Lib:Slider(parent, opts)
    opts = opts or {}
    local cfg = opts.Value or {}
    local min = cfg.Min or 0
    local max = cfg.Max or 100
    local value = cfg.Default or min
    local step = opts.Step or 1
    local decimals = opts.Decimals

    local container = parent.Page or parent.Container or parent
    local row = makeRow(container, 44)

    local label = makeLabel(row, opts.Title or "Slider")
    label.Size = UDim2.new(0.7, 0, 0, 18)
    label.Position = UDim2.new(0, 6, 0, 0)

    local valueLabel = new("TextLabel", {
        Text = tostring(value),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, -6, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local barBg = new("Frame", {
        Size = UDim2.new(1, -12, 0, 8),
        Position = UDim2.new(0, 6, 1, -14),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
    }, row)
    corner(barBg, UDim.new(1, 0))

    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    }, barBg)
    corner(fill, UDim.new(1, 0))

    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 2,
    }, barBg)
    corner(knob, UDim.new(1, 0))

    local function roundTo(v)
        if decimals then
            local m = 10 ^ decimals
            return math.floor(v * m + 0.5) / m
        end
        if step and step > 0 then
            return math.floor(v / step + 0.5) * step
        end
        return v
    end

    local function setValue(v, fire)
        v = math.clamp(roundTo(v), min, max)
        value = v
        local pct = (max > min) and ((v - min) / (max - min)) or 0
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valueLabel.Text = tostring(v)
        if fire and opts.Callback then pcall(opts.Callback, v) end
    end
    setValue(value, false)

    local dragging = false
    local function inputPos(input)
        local rel = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
        return min + (max - min) * math.clamp(rel, 0, 1)
    end

    local hit = new("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 12, 1, 12),
        Position = UDim2.new(0, -6, 0, -6),
        ZIndex = 3,
    }, barBg)

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setValue(inputPos(input), true)
        end
    end)
    hit.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setValue(inputPos(input), true)
        end
    end)

    return { Set = function(v) setValue(v, true) end, Get = function() return value end }
end

-- ============================================================
-- Button
-- ============================================================
function Lib:Button(parent, opts)
    opts = opts or {}
    local container = parent.Page or parent.Container or parent
    local btn = new("TextButton", {
        Text = opts.Title or "Button",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = opts.Danger and Theme.Danger or Theme.Text,
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        AutoButtonColor = false,
    }, container)
    corner(btn, UDim.new(0, 6))
    stroke(btn, Theme.Stroke, 1)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Theme.ElementHover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Theme.Element
    end)
    btn.MouseButton1Click:Connect(function()
        if opts.Callback then pcall(opts.Callback) end
    end)
    return btn
end

-- ============================================================
-- Dropdown
-- ============================================================
function Lib:Dropdown(parent, opts)
    opts = opts or {}
    local values = opts.Values or {}
    local current = opts.Value or values[1]

    local container = parent.Page or parent.Container or parent
    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
    }, container)

    local header = new("TextButton", {
        Text = "",
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        AutoButtonColor = false,
    }, holder)
    corner(header, UDim.new(0, 6))
    stroke(header, Theme.Stroke, 1)

    local titleLbl = new("TextLabel", {
        Text = opts.Title or "",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local valueLbl = new("TextLabel", {
        Text = tostring(current),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.45, -24, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, header)

    local arrow = new("TextLabel", {
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.fromOffset(16, 30),
    }, header)

    local list = new("Frame", {
        Size = UDim2.new(1, 0, 0, math.min(#values, 6) * 26 + 8),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
    }, holder)
    corner(list, UDim.new(0, 6))
    stroke(list, Theme.Stroke, 1)
    local listLayout = new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    }, list)

    local listScroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 10,
    }, list)
    new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, listScroll)

    local opened = false
    local function toggleList()
        opened = not opened
        list.Visible = opened
        arrow.Text = opened and "▲" or "▼"
    end

    header.MouseButton1Click:Connect(toggleList)

    local optionButtons = {}
    local function buildOptions()
        for _, b in ipairs(optionButtons) do b:Destroy() end
        optionButtons = {}
        for _, v in ipairs(values) do
            local ob = new("TextButton", {
                Text = "  " .. tostring(v),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = (v == current) and Theme.Accent or Theme.Text,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 11,
            }, listScroll)
            corner(ob, UDim.new(0, 4))
            ob.MouseButton1Click:Connect(function()
                current = v
                valueLbl.Text = tostring(v)
                toggleList()
                if opts.Callback then pcall(opts.Callback, v) end
            end)
            ob.MouseEnter:Connect(function()
                ob.BackgroundColor3 = Theme.ElementHover
            end)
            ob.MouseLeave:Connect(function()
                ob.BackgroundColor3 = Theme.Element
            end)
            table.insert(optionButtons, ob)
        end
    end
    buildOptions()

    return {
        Set = function(v) current = v; valueLbl.Text = tostring(v) end,
        Get = function() return current end,
        SetOptions = function(newVals)
            values = newVals or {}
            buildOptions()
        end,
    }
end

-- ============================================================
-- Input (Textbox)
-- ============================================================
function Lib:Input(parent, opts)
    opts = opts or {}
    local container = parent.Page or parent.Container or parent
    local row = makeRow(container, 34)

    local label = makeLabel(row, opts.Title or "Input")
    label.Size = UDim2.new(0.5, 0, 1, 0)

    local box = new("TextBox", {
        Text = opts.Value or "",
        PlaceholderText = opts.PlaceholderText or "输入...",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDim,
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, -12),
        Size = UDim2.new(0.5, -6, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = opts.ClearTextOnFocus ~= false,
    }, row)
    corner(box, UDim.new(0, 4))
    stroke(box, Theme.Stroke, 1)
    local pad = new("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
    }, box)

    box.FocusLost:Connect(function()
        if opts.Callback then pcall(opts.Callback, box.Text) end
    end)

    return { Set = function(v) box.Text = tostring(v) end, Get = function() return box.Text end }
end

-- ============================================================
-- Paragraph / Label
-- ============================================================
function Lib:Paragraph(parent, opts)
    opts = opts or {}
    local container = parent.Page or parent.Container or parent
    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, container)
    corner(holder, UDim.new(0, 6))
    stroke(holder, Theme.Stroke, 1)
    padding(holder, 8)

    new("TextLabel", {
        Text = opts.Title or "",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    new("TextLabel", {
        Text = opts.Desc or "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, holder)

    return holder
end

function Lib:Label(parent, text)
    local container = parent.Page or parent.Container or parent
    return new("TextLabel", {
        Text = text or "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)
end

function Lib:Divider(parent)
    local container = parent.Page or parent.Container or parent
    return new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
    }, container)
end

function Lib:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "通知"
    local content = opts.Content or ""
    local duration = opts.Duration or 4

    local gui = self.Gui
    local holder = new("Frame", {
        Size = UDim2.fromOffset(260, 60),
        Position = UDim2.new(1, -280, 0, 20 + (#(self._notifs or {}) * 70)),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
    }, gui)
    corner(holder, UDim.new(0, 8))
    stroke(holder, Theme.Accent, 1.5)
    padding(holder, 10)

    new("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    new("TextLabel", {
        Text = content,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 30),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, holder)

    self._notifs = self._notifs or {}
    table.insert(self._notifs, holder)

    task.delay(duration, function()
        pcall(function() holder:Destroy() end)
        for i, n in ipairs(self._notifs) do
            if n == holder then
                table.remove(self._notifs, i)
                break
            end
        end
    end)
end

-- ============================================================
-- 使用示例
-- ============================================================
local UI = Lib:CreateWindow({
    Title = "自定义 UI",
    Folder = "CustomUI",
    Size = UDim2.fromOffset(620, 460),
   : SideBarWidth = Section160,
    ToggleKey = Enum.KeyCode.RightShift,
(M})

local Main = UI:Tab({ Title = "ain主要功能", Icon = "home," })
local Combat { = UI:Tab({ Title = "战斗", Icon = "crosshair" })
local Move = UI:Tab({ Title = "移动", Icon = "move" })
local ESP = UI:Tab({ Title = "透视", Icon = "eye" })
local Settings = UI:Tab({ Title = "设置", Icon = "settings" })

local sec1 = UI Title = "基础功能", Opened = true })
UI:Toggle(sec1, { Title = "无限体力", Value = false,
    Callback = function(v) print("无限体力:", v) end })
UI:Toggle(sec1, { Title = "无限饥饿", Value = false,
    Callback = function(v) print("无限饥饿:", v) end })
UI:Slider(sec1, { Title = "速度", Value = { Min = 0, Max = 200, Default = 50 },
    Callback = function(v) print("速度:", v) end })
UI:Dropdown(sec1, { Title = "模式", Values = { "正常", "快速", "极速" }, Value = "正常",
    Callback = function(v) print("模式:", v) end })
UI:Input(sec1, { Title = "数值", PlaceholderText = "输入...",
    Callback = function(v) print("输入:", v) end })

local sec2 = UI:Section(Main, { Title = "操作", Opened = true })
UI:Button(sec2, { Title = "执行", Callback = function()
    UI:Notify({ Title = "提示", Content = "按钮已点击", Duration = 3 })
end })
UI:Button(sec2, { Title = "删除", Danger = true, Callback = function()
    UI:Notify({ Title = "危险操作", Content = "已执行", Duration = 3 })
end })

local combatSec = UI:Section(Combat, { Title = "战斗设置", Opened = true })
UI:Toggle(combatSec, { Title = "自瞄", Value = false,
    Callback = function(v) print("自瞄:", v) end })
UI:Toggle(combatSec, { Title = "子弹追踪", Value = false,
    Callback = function(v) print("子弹追踪:", v) end })

local moveSec = UI:Section(Move, { Title = "移动设置", Opened = true })
UI:Toggle(moveSec, { Title = "飞行", Value = false,
    Callback = function(v) print("飞行:", v) end })
UI:Slider(moveSec, { Title = "飞行速度", Value = { Min = 10, Max = 300, Default = 40 },
    Callback = function(v) print("飞行速度:", v) end })

local espSec = UI:Section(ESP, { Title = "透视设置", Opened = true })
UI:Toggle(espSec, { Title = "方框", Value = true,
    Callback = function(v) print("方框:", v) end })
UI:Toggle(espSec, { Title = "血量", Value = true,
    Callback = function(v) print("血量:", v) end })

UI:Button(Settings, { Title = "卸载脚本", Danger = true, Callback = function()
    UI.Gui:Destroy()
end })

return Lib