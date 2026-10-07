-- WindUI 风格 UI 库（自研实现）
-- 用法: local UI = loadstring(game:HttpGet("你的链接"))()
-- local Win = UI:CreateWindow({ Title = "标题", Size = UDim2.fromOffset(620, 480) })

local WindUI = {}
WindUI.__index = WindUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function getParent()
    local ok, hui = pcall(function() return gethui and gethui() or nil end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local Themes = {
    Dark = {
        Main        = Color3.fromRGB(22, 22, 28),
        Sidebar     = Color3.fromRGB(18, 18, 23),
        Element     = Color3.fromRGB(32, 32, 40),
        ElementHover= Color3.fromRGB(40, 40, 50),
        Accent      = Color3.fromRGB(138, 92, 246),
        Text        = Color3.fromRGB(240, 240, 245),
        SubText     = Color3.fromRGB(150, 150, 165),
        Stroke      = Color3.fromRGB(48, 48, 60),
        Outline     = Color3.fromRGB(60, 60, 75),
        Danger      = Color3.fromRGB(230, 70, 70),
    },
    Light = {
        Main        = Color3.fromRGB(245, 245, 250),
        Sidebar     = Color3.fromRGB(235, 235, 242),
        Element     = Color3.fromRGB(255, 255, 255),
        ElementHover= Color3.fromRGB(240, 240, 248),
        Accent      = Color3.fromRGB(120, 80, 230),
        Text        = Color3.fromRGB(25, 25, 35),
        SubText     = Color3.fromRGB(110, 110, 125),
        Stroke      = Color3.fromRGB(210, 210, 220),
        Outline     = Color3.fromRGB(190, 190, 205),
        Danger      = Color3.fromRGB(210, 55, 55),
    },
    Indigo = {
        Main        = Color3.fromRGB(20, 22, 40),
        Sidebar     = Color3.fromRGB(16, 18, 34),
        Element     = Color3.fromRGB(30, 34, 58),
        ElementHover= Color3.fromRGB(38, 42, 72),
        Accent      = Color3.fromRGB(99, 102, 241),
        Text        = Color3.fromRGB(235, 238, 255),
        SubText     = Color3.fromRGB(150, 155, 185),
        Stroke      = Color3.fromRGB(46, 50, 80),
        Outline     = Color3.fromRGB(60, 65, 100),
        Danger      = Color3.fromRGB(230, 70, 70),
    },
}

local Theme = Themes.Dark
WindUI.Theme = Theme
WindUI.Themes = Themes

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or t or 0)
    p.PaddingBottom = UDim.new(0, b or t or 0)
    p.PaddingLeft = UDim.new(0, l or r or t or 0)
    p.Parent = parent
    return p
end

local function create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, c in ipairs(children or {}) do
        c.Parent = inst
    end
    return inst
end

-- ============ 通知系统 ============
local NotifyHolder
local function ensureNotifyHolder()
    if NotifyHolder and NotifyHolder.Parent then return NotifyHolder end
    NotifyHolder = create("ScreenGui", {
        Name = "WindUI_Notify",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 9999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getParent(),
    })
    return NotifyHolder
end

function WindUI:Notify(opts)
    opts = opts or {}
    local holder = ensureNotifyHolder()
    local title = opts.Title or "通知"
    local content = opts.Content or ""
    local duration = opts.Duration or 4

    local card = create("Frame", {
        Size = UDim2.fromOffset(280, 62),
        Position = UDim2.new(1, -300, 1, -20),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Parent = holder,
    })
    corner(card, UDim.new(0, 10))
    stroke(card, Theme.Accent, 1)
    padding(card, 10, 12, 10, 12)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        Parent = card,
    })
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = content,
        Parent = card,
    })

    local targetY = -20
    local index = 0
    for _, c in ipairs(holder:GetChildren()) do
        if c:IsA("Frame") and c ~= card then index = index + 1 end
    end
    targetY = -20 - (index * 72)
    card.Position = UDim2.new(1, 320, 1, targetY)
    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -300, 1, targetY),
    }):Play()

    task.delay(duration, function()
        TweenService:Create(card, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 320, 1, targetY),
        }):Play()
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ============ 控件构造 ============

-- Toggle
local function makeToggle(parent, data)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = data.Title or "Toggle",
        Parent = row,
    })
    local btn = create("TextButton", {
        Size = UDim2.fromOffset(44, 22),
        Position = UDim2.new(1, -44, 0.5, -11),
        BackgroundColor3 = data.Value and Theme.Accent or Theme.Element,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    corner(btn, UDim.new(1, 0))
    stroke(btn, Theme.Outline, 1)
    local dot = create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = data.Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = btn,
    })
    corner(dot, UDim.new(1, 0))

    local state = data.Value and true or false
    local function render()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Theme.Accent or Theme.Element,
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        if data.Callback then task.spawn(data.Callback, state) end
    end)
    render()
    return { Set = function(_, v) state = v; render() end }
end

-- Button
local function makeButton(parent, data)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = data.Danger and Theme.Danger or Theme.Element,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        Text = data.Title or "按钮",
        Parent = parent,
    })
    corner(btn, UDim.new(0, 8))
    stroke(btn, Theme.Outline, 1)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.ElementHover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = data.Danger and Theme.Danger or Theme.Element
        }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if data.Callback then task.spawn(data.Callback) end
    end)
    return btn
end

-- Slider
local function makeSlider(parent, data)
    local conf = data.Value or {}
    local minV = conf.Min or 0
    local maxV = conf.Max or 100
    local cur = conf.Default or minV
    local step = data.Step or 1

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = data.Title or "Slider",
        Parent = holder,
    })
    local valText = create("TextLabel", {
        Size = UDim2.fromOffset(60, 18),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(cur),
        Parent = holder,
    })
    local bar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Parent = holder,
    })
    corner(bar, UDim.new(1, 0))
    local fill = create("Frame", {
        Size = UDim2.new((cur - minV) / (maxV - minV), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar,
    })
    corner(fill, UDim.new(1, 0))
    local knob = create("Frame", {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((cur - minV) / (maxV - minV), 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = bar,
    })
    corner(knob, UDim.new(1, 0))
    stroke(knob, Theme.Accent, 2)

    local dragging = false
    local function updateFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minV + (maxV - minV) * rel
        val = math.floor(val / step + 0.5) * step
        cur = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valText.Text = tostring(val)
        if data.Callback then task.spawn(data.Callback, val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return { Set = function(_, v) updateFromX(bar.AbsolutePosition.X + bar.AbsoluteSize.X * ((v - minV) / (maxV - minV))) end }
end

-- Input
local function makeInput(parent, data)
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = data.Title or "输入",
        Parent = holder,
    })
    local box = create("TextBox", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        PlaceholderText = data.PlaceholderText or "输入...",
        PlaceholderColor3 = Theme.SubText,
        Text = data.Value or "",
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = data.ClearTextOnFocus ~= false,
        Parent = holder,
    })
    corner(box, UDim.new(0, 6))
    stroke(box, Theme.Outline, 1)
    padding(box, 0, 8, 0, 8)
    box.FocusLost:Connect(function()
        if data.Callback then task.spawn(data.Callback, box.Text) end
    end)
    return box
end

-- Dropdown
local function makeDropdown(parent, data)
    local values = data.Values or {}
    local multi = data.Multi == true
    local selected = data.Value
    local open = false

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = data.Title or "选择",
        Parent = holder,
    })
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = type(selected) == "string" and selected or (type(selected) == "table" and (#selected > 0 and selected[1] or "选择...") or "选择..."),
        Parent = holder,
    })
    corner(btn, UDim.new(0, 6))
    stroke(btn, Theme.Outline, 1)
    padding(btn, 0, 8, 0, 8)

    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.Sidebar,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = btn,
    })
    corner(list, UDim.new(0, 6))
    stroke(list, Theme.Outline, 1)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list
    padding(list, 4)

    local selectedSet = {}
    if multi and type(selected) == "table" then
        for _, v in ipairs(selected) do selectedSet[v] = true end
    end

    for _, v in ipairs(values) do
        local item = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Theme.Element,
            AutoButtonColor = false,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = tostring(v),
            Parent = list,
        })
        corner(item, UDim.new(0, 4))
        padding(item, 0, 8, 0, 8)
        item.MouseButton1Click:Connect(function()
            if multi then
                selectedSet[v] = not selectedSet[v]
                item.BackgroundColor3 = selectedSet[v] and Theme.Accent or Theme.Element
                local out = {}
                for k, on in pairs(selectedSet) do if on then table.insert(out, k) end end
                btn.Text = #out > 0 and table.concat(out, ", ") or "选择..."
                if data.Callback then task.spawn(data.Callback, out) end
            else
                btn.Text = tostring(v)
                if data.Callback then task.spawn(data.Callback, v) end
                open = false
                list.Visible = false
                list.Size = UDim2.new(1, 0, 0, 0)
            end
        end)
        if multi and selectedSet[v] then
            item.BackgroundColor3 = Theme.Accent
        elseif not multi and selected == v then
            item.BackgroundColor3 = Theme.Accent
        end
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        list.Visible = open
        TweenService:Create(list, TweenInfo.new(0.2), {
            Size = open and UDim2.new(1, 0, 0, math.min(#values * 24 + 8, 200)) or UDim2.new(1, 0, 0, 0),
        }):Play()
    end)
    return btn
end

-- Colorpicker
local function makeColorpicker(parent, data)
    local color = data.Default or Color3.fromRGB(255, 255, 255)
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = data.Title or "颜色",
        Parent = holder,
    })
    local preview = create("TextButton", {
        Size = UDim2.fromOffset(28, 22),
        Position = UDim2.new(1, -28, 0.5, -11),
        BackgroundColor3 = color,
        Text = "",
        AutoButtonColor = false,
        Parent = holder,
    })
    corner(preview, UDim.new(0, 6))
    stroke(preview, Theme.Outline, 1)

    local palette = {
        Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 170, 60),
        Color3.fromRGB(255, 240, 80), Color3.fromRGB(120, 230, 120),
        Color3.fromRGB(80, 220, 220), Color3.fromRGB(90, 140, 255),
        Color3.fromRGB(160, 110, 255), Color3.fromRGB(255, 110, 200),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 120, 130),
    }
    local panel = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.Sidebar,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = preview,
    })
    corner(panel, UDim.new(0, 6))
    stroke(panel, Theme.Outline, 1)
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.fromOffset(24, 24)
    grid.CellPadding = UDim2.fromOffset(4, 4)
    grid.Parent = panel
    padding(panel, 4)

    local open = false
    for _, c in ipairs(palette) do
        local sw = create("TextButton", {
            BackgroundColor3 = c,
            Text = "",
            AutoButtonColor = false,
            Parent = panel,
        })
        corner(sw, UDim.new(0, 4))
        stroke(sw, Theme.Outline, 1)
        sw.MouseButton1Click:Connect(function()
            color = c
            preview.BackgroundColor3 = c
            if data.Callback then task.spawn(data.Callback, c) end
        end)
    end
    preview.MouseButton1Click:Connect(function()
        open = not open
        panel.Visible = open
        TweenService:Create(panel, TweenInfo.new(0.2), {
            Size = open and UDim2.new(0, 280, 0, 90) or UDim2.new(0, 0, 0, 0),
        }):Play()
    end)
    return preview
end

-- Keybind
local function makeKeybind(parent, data)
    local key = data.Value or "None"
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = data.Title or "按键",
        Parent = holder,
    })
    local btn = create("TextButton", {
        Size = UDim2.fromOffset(72, 24),
        Position = UDim2.new(1, -72, 0.5, -12),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        Text = key,
        Parent = holder,
    })
    corner(btn, UDim.new(0, 6))
    stroke(btn, Theme.Outline, 1)

    local waiting = false
    btn.MouseButton1Click:Connect(function()
        waiting = true
        btn.Text = "..."
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
            waiting = false
            key = input.KeyCode.Name
            btn.Text = key
            if data.Callback then task.spawn(data.Callback, key) end
        end
    end)
    return btn
end

-- Section + Tab + Window
function WindUI:CreateWindow(opts)
    opts = opts or {}
    Theme = Themes[opts.Theme or "Dark"] or Themes.Dark
    self.Theme = Theme

    local gui = create("ScreenGui", {
        Name = "WindUI_" .. (opts.Title or "Window"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getParent(),
    })

    local main = create("Frame", {
        Size = opts.Size or UDim2.fromOffset(620, 480),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Parent = gui,
    })
    corner(main, UDim.new(0, 12))
    stroke(main, Theme.Stroke, 1)

    -- 标题栏
    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(titleBar, UDim.new(0, 12))
    local fix = create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Title or "WindUI",
        Parent = titleBar,
    })

    -- 关闭按钮
    local close = create("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = Theme.Danger,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.new(1, 1, 1),
        Text = "×",
        Parent = titleBar,
    })
    corner(close, UDim.new(0, 6))
    close.MouseButton1Click:Connect(function()
        gui.Enabled = not gui.Enabled
    end)

    -- 拖动
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- 侧边栏
    local sidebar = create("Frame", {
        Size = UDim2.new(0, opts.SideBarWidth or 160, 1, -50),
        Position = UDim2.new(0, 8, 0, 46),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(sidebar, UDim.new(0, 10))
    stroke(sidebar, Theme.Stroke, 1)
    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 4)
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Parent = sidebar
    padding(sidebar, 6)

    -- 内容区
    local content = create("Frame", {
        Size = UDim2.new(1, -(opts.SideBarWidth or 160) - 24, 1, -58),
        Position = UDim2.new(0, (opts.SideBarWidth or 160) + 16, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = main,
    })

    local tabs = {}
    local tabButtons = {}
    local currentTab

    local function selectTab(name)
        for n, page in pairs(tabs) do
            page.Visible = (n == name)
        end
        for n, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = (n == name) and Theme.Accent or Theme.Element
            btn.TextColor3 = (n == name) and Color3.new(1, 1, 1) or Theme.Text
        end
        currentTab = name
    end

    local window = {
        Gui = gui,
        Main = main,
        Content = content,
        Sidebar = sidebar,
        Tabs = tabs,
        TabButtons = tabButtons,
        Theme = Theme,
        SelectTab = selectTab,
    }
    setmetatable(window, WindUI)

    function window:Tab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Title or "标签"

        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Element,
            AutoButtonColor = false,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "  " .. name,
            Parent = sidebar,
        })
        corner(btn, UDim.new(0, 8))
        btn.MouseButton1Click:Connect(function() selectTab(name) end)
        tabButtons[name] = btn

        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = content,
        })
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = page
        padding(page, 4, 6, 8, 4)
        tabs[name] = page

        local tabObj = { Page = page, Name = name }
        setmetatable(tabObj, WindUI)

        function tabObj:Section(secOpts)
            secOpts = secOpts or {}
            local holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = page,
            })
            local header = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Theme.Element,
                AutoButtonColor = false,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "  " .. (secOpts.Title or "分区"),
                Parent = holder,
            })
            corner(header, UDim.new(0, 8))
            stroke(header, Theme.Stroke, 1)

            local body = create("Frame", {
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.new(0, 5, 0, 34),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                Parent = holder,
            })
            corner(body, UDim.new(0, 8))
            stroke(body, Theme.Stroke, 1)
            local bodyLayout = Instance.new("UIListLayout")
            bodyLayout.Padding = UDim.new(0, 6)
            bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
            bodyLayout.Parent = body
            padding(body, 8, 10, 8, 10)

            local bodyConn
            local function layout()
                body.Size = UDim2.new(1, -10, 0, bodyLayout.AbsoluteContentSize.Y + 16)
                holder.Size = UDim2.new(1, 0, 0, body.Size.Y.Offset + 40)
            end
            layout()
            bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(layout)

            local openState = secOpts.Opened ~= false
            body.Visible = openState
            if not openState then
                holder.Size = UDim2.new(1, 0, 0, 30)
            end
            header.MouseButton1Click:Connect(function()
                openState = not openState
                body.Visible = openState
                if openState then
                    layout()
                else
                    holder.Size = UDim2.new(1, 0, 0, 30)
                end
            end)

            local sec = { Body = body, Holder = holder }
            setmetatable(sec, WindUI)

            function sec:Toggle(d) return makeToggle(body, d) end
            function sec:Button(d) return makeButton(body, d) end
            function sec:Slider(d) return makeSlider(body, d) end
            function sec:Input(d) return makeInput(body, d) end
            function sec:Dropdown(d) return makeDropdown(body, d) end
            function sec:Colorpicker(d) return makeColorpicker(body, d) end
            function sec:Keybind(d) return makeKeybind(body, d) end
            function sec:Divider()
                local div = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Stroke,
                    BorderSizePixel = 0,
                    Parent = body,
                })
                return div
            end
            function sec:Label(text)
                local l = create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = text or "",
                    Parent = body,
                })
                return l
            end

            return sec
        end

        return tabObj
    end

    function window:SetTheme(name)
        local newTheme = Themes[name]
        if not newTheme then return end
        Theme = newTheme
        self.Theme = Theme
        main.BackgroundColor3 = Theme.Main
        titleBar.BackgroundColor3 = Theme.Sidebar
        fix.BackgroundColor3 = Theme.Sidebar
        sidebar.BackgroundColor3 = Theme.Sidebar
        for _, btn in pairs(tabButtons) do
            if btn.BackgroundColor3 ~= Theme.Accent then
                btn.BackgroundColor3 = Theme.Element
            end
            btn.TextColor3 = Theme.Text
        end
    end

    function window:Toggle()
        gui.Enabled = not gui.Enabled
    end

    function window:Destroy()
        gui:Destroy()
    end

    -- 默认选中第一个标签
    local firstTab = next(tabs)
    if firstTab then selectTab(firstTab) end

    return window
end

return WindUI