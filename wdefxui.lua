local WindUI = {}
WindUI.__index = WindUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
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
        Main=Color3.fromRGB(20,20,26), Sidebar=Color3.fromRGB(16,16,22),
        Card=Color3.fromRGB(30,30,38), CardHover=Color3.fromRGB(38,38,48),
        Accent=Color3.fromRGB(138,92,246), AccentDark=Color3.fromRGB(100,60,200),
        Text=Color3.fromRGB(240,240,245), SubText=Color3.fromRGB(150,150,165),
        Stroke=Color3.fromRGB(45,45,58), Outline=Color3.fromRGB(60,60,78),
        Danger=Color3.fromRGB(230,70,70), Success=Color3.fromRGB(60,200,120),
    },
    Light = {
        Main=Color3.fromRGB(245,245,250), Sidebar=Color3.fromRGB(235,235,242),
        Card=Color3.fromRGB(255,255,255), CardHover=Color3.fromRGB(240,240,248),
        Accent=Color3.fromRGB(120,80,230), AccentDark=Color3.fromRGB(90,60,180),
        Text=Color3.fromRGB(25,25,35), SubText=Color3.fromRGB(110,110,125),
        Stroke=Color3.fromRGB(215,215,225), Outline=Color3.fromRGB(190,190,205),
        Danger=Color3.fromRGB(210,55,55), Success=Color3.fromRGB(40,180,100),
    },
    Indigo = {
        Main=Color3.fromRGB(18,20,38), Sidebar=Color3.fromRGB(14,16,32),
        Card=Color3.fromRGB(28,32,56), CardHover=Color3.fromRGB(36,40,70),
        Accent=Color3.fromRGB(99,102,241), AccentDark=Color3.fromRGB(70,72,200),
        Text=Color3.fromRGB(235,238,255), SubText=Color3.fromRGB(150,155,185),
        Stroke=Color3.fromRGB(44,48,78), Outline=Color3.fromRGB(58,62,100),
        Danger=Color3.fromRGB(230,70,70), Success=Color3.fromRGB(60,200,120),
    },
    Rose = {
        Main=Color3.fromRGB(28,18,26), Sidebar=Color3.fromRGB(22,14,22),
        Card=Color3.fromRGB(40,26,38), CardHover=Color3.fromRGB(52,34,50),
        Accent=Color3.fromRGB(244,114,182), AccentDark=Color3.fromRGB(200,80,150),
        Text=Color3.fromRGB(250,240,248), SubText=Color3.fromRGB(180,150,175),
        Stroke=Color3.fromRGB(60,40,58), Outline=Color3.fromRGB(80,55,78),
        Danger=Color3.fromRGB(230,70,70), Success=Color3.fromRGB(60,200,120),
    },
}

local Theme = Themes.Dark
WindUI.Theme = Theme
WindUI.Themes = Themes
WindUI.DPIScale = 1

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 8)
    c.Parent = p
    return c
end

local function stroke(p, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function padding(p, t, r, b, l)
    local pd = Instance.new("UIPadding")
    pd.PaddingTop = UDim.new(0, t or 0)
    pd.PaddingRight = UDim.new(0, r or t or 0)
    pd.PaddingBottom = UDim.new(0, b or t or 0)
    pd.PaddingLeft = UDim.new(0, l or r or t or 0)
    pd.Parent = p
    return pd
end

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- ========== 通知 ==========
local NotifyHolder
local function notifyHolder()
    if NotifyHolder and NotifyHolder.Parent then return NotifyHolder end
    NotifyHolder = create("ScreenGui", {
        Name = "WindUI_Notify", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 99999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getParent(),
    })
    return NotifyHolder
end

function WindUI:Notify(opts)
    opts = opts or {}
    local holder = notifyHolder()
    local title = opts.Title or "通知"
    local content = opts.Content or ""
    local duration = opts.Duration or 4
    local icon = opts.Icon

    local card = create("Frame", {
        Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(1, 340, 1, -20),
        BackgroundColor3 = Theme.Main, BorderSizePixel = 0,
        Parent = holder,
    })
    corner(card, UDim.new(0, 10))
    stroke(card, Theme.Accent, 1.2)
    padding(card, 12, 14, 12, 14)

    local bar = create("Frame", {
        Size = UDim2.new(1, -28, 0, 3), Position = UDim2.new(0, 14, 1, -4),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = card,
    })
    corner(bar, UDim.new(1, 0))

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left, Text = title, Parent = card,
    })
    if content ~= "" then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, Text = content, Parent = card,
        })
    end

    local idx = 0
    for _, c in ipairs(holder:GetChildren()) do
        if c:IsA("Frame") then idx = idx + 1 end
    end
    local yOffset = -20 - idx * 92
    card.Position = UDim2.new(1, 340, 1, yOffset)
    tween(card, 0.4, { Position = UDim2.new(1, -20, 1, yOffset) })
    bar.Size = UDim2.new(1, -28, 0, 3)
    tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) })

    task.delay(duration, function()
        tween(card, 0.3, { Position = UDim2.new(1, 340, 1, yOffset) })
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ========== 控件 ==========
local function makeToggle(parent, data)
    local state = data.Value and true or false
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = data.Title or "开关",
        Parent = row,
    })
    local btn = create("TextButton", {
        Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -42, 0.5, -11),
        BackgroundColor3 = state and Theme.Accent or Theme.Card, Text = "",
        AutoButtonColor = false, Parent = row,
    })
    corner(btn, UDim.new(1, 0))
    stroke(btn, Theme.Outline, 1)
    local dot = create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1), Parent = btn,
    })
    corner(dot, UDim.new(1, 0))

    local function render()
        tween(btn, 0.15, { BackgroundColor3 = state and Theme.Accent or Theme.Card })
        tween(dot, 0.15, {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        })
    end
    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        if data.Callback then task.spawn(data.Callback, state) end
    end)
    render()
    return { Set = function(_, v) state = v; render() end }
end

local function makeButton(parent, data)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = data.Danger and Theme.Danger or Theme.Card,
        AutoButtonColor = false, Font = Enum.Font.GothamMedium,
        TextSize = 13, TextColor3 = Theme.Text, Text = data.Title or "按钮",
        Parent = parent,
    })
    corner(btn, UDim.new(0, 8))
    stroke(btn, Theme.Outline, 1)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = data.Danger and Theme.Danger or Theme.CardHover })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = data.Danger and Theme.Danger or Theme.Card })
    end)
    btn.MouseButton1Click:Connect(function()
        if data.Callback then task.spawn(data.Callback) end
    end)
    return btn
end

local function makeSlider(parent, data)
    local c = data.Value or {}
    local minV, maxV = c.Min or 0, c.Max or 100
    local cur = c.Default or minV
    local step = data.Step or 1

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = data.Title or "滑块",
        Parent = holder,
    })
    local valText = create("TextLabel", {
        Size = UDim2.fromOffset(60, 18), Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(cur), Parent = holder,
    })
    local bar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Parent = holder,
    })
    corner(bar, UDim.new(1, 0))
    local fill = create("Frame", {
        Size = UDim2.new((cur-minV)/(maxV-minV), 0, 1, 0),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = bar,
    })
    corner(fill, UDim.new(1, 0))
    local knob = create("Frame", {
        Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((cur-minV)/(maxV-minV), 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1,1,1), Parent = bar,
    })
    corner(knob, UDim.new(1, 0))
    stroke(knob, Theme.Accent, 2)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minV + (maxV - minV) * rel
        val = math.floor(val / step + 0.5) * step
        cur = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valText.Text = tostring(val)
        if data.Callback then task.spawn(data.Callback, val) end
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return {
        Set = function(_, v)
            v = math.clamp(v, minV, maxV)
            local rel = (v - minV) / (maxV - minV)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            valText.Text = tostring(v)
            cur = v
        end
    }
end

local function makeInput(parent, data)
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = data.Title or "输入",
        Parent = holder,
    })
    local box = create("TextBox", {
        Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Font = Enum.Font.Gotham,
        TextSize = 12, TextColor3 = Theme.Text,
        PlaceholderText = data.PlaceholderText or "输入...",
        PlaceholderColor3 = Theme.SubText, Text = data.Value or "",
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = data.ClearTextOnFocus ~= false, Parent = holder,
    })
    corner(box, UDim.new(0, 6))
    stroke(box, Theme.Outline, 1)
    padding(box, 0, 8, 0, 8)
    box.Focused:Connect(function()
        tween(box, 0.15, { BackgroundColor3 = Theme.CardHover })
    end)
    box.FocusLost:Connect(function()
        tween(box, 0.15, { BackgroundColor3 = Theme.Card })
        if data.Callback then task.spawn(data.Callback, box.Text) end
    end)
    return box
end

local function makeDropdown(parent, data)
    local values = data.Values or {}
    local multi = data.Multi == true
    local selected = data.Value
    local open = false

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1,
        ClipsDescendants = false, ZIndex = 5, Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = data.Title or "选择",
        Parent = holder,
    })

    local label = "选择..."
    if type(selected) == "string" then label = selected
    elseif type(selected) == "table" and #selected > 0 then label = table.concat(selected, ", ") end

    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Card, AutoButtonColor = false,
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = label,
        ClipsDescendants = false, ZIndex = 6, Parent = holder,
    })
    corner(btn, UDim.new(0, 6))
    stroke(btn, Theme.Outline, 1)
    padding(btn, 0, 8, 0, 8)

    local arrow = create("TextLabel", {
        Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -20, 0.5, -7),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Theme.SubText, Text = "▼", Parent = btn,
    })

    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.Sidebar, Visible = false,
        ClipsDescendants = true, ZIndex = 20, Parent = btn,
    })
    corner(list, UDim.new(0, 6))
    stroke(list, Theme.Outline, 1)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list
    padding(list, 4)

    local selSet = {}
    if multi and type(selected) == "table" then
        for _, v in ipairs(selected) do selSet[v] = true end
    end

    for _, v in ipairs(values) do
        local item = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Theme.Card,
            AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            Text = tostring(v), ZIndex = 21, Parent = list,
        })
        corner(item, UDim.new(0, 4))
        padding(item, 0, 8, 0, 8)
        if multi and selSet[v] then item.BackgroundColor3 = Theme.Accent end
        if not multi and selected == v then item.BackgroundColor3 = Theme.Accent end
        item.MouseButton1Click:Connect(function()
            if multi then
                selSet[v] = not selSet[v]
                item.BackgroundColor3 = selSet[v] and Theme.Accent or Theme.Card
                local out = {}
                for k, on in pairs(selSet) do if on then table.insert(out, k) end end
                btn.Text = #out > 0 and table.concat(out, ", ") or "选择..."
                if data.Callback then task.spawn(data.Callback, out) end
            else
                btn.Text = tostring(v)
                if data.Callback then task.spawn(data.Callback, v) end
                open = false
                list.Visible = false
                list.Size = UDim2.new(1, 0, 0, 0)
                arrow.Text = "▼"
            end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        list.Visible = open
        arrow.Text = open and "▲" or "▼"
        tween(list, 0.2, {
            Size = open and UDim2.new(1, 0, 0, math.min(#values * 26 + 8, 200)) or UDim2.new(1, 0, 0, 0),
        })
    end)
    return btn
end

local function makeColorpicker(parent, data)
    local color = data.Default or Color3.fromRGB(255,255,255)
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
        ClipsDescendants = false, ZIndex = 5, Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = data.Title or "颜色",
        Parent = holder,
    })
    local preview = create("TextButton", {
        Size = UDim2.fromOffset(28, 22), Position = UDim2.new(1, -28, 0.5, -11),
        BackgroundColor3 = color, Text = "", AutoButtonColor = false,
        ZIndex = 6, Parent = holder,
    })
    corner(preview, UDim.new(0, 6))
    stroke(preview, Theme.Outline, 1)

    local palette = {
        Color3.fromRGB(255,80,80), Color3.fromRGB(255,170,60),
        Color3.fromRGB(255,240,80), Color3.fromRGB(120,230,120),
        Color3.fromRGB(80,220,220), Color3.fromRGB(90,140,255),
        Color3.fromRGB(160,110,255), Color3.fromRGB(255,110,200),
        Color3.fromRGB(255,255,255), Color3.fromRGB(180,180,190),
        Color3.fromRGB(120,120,130), Color3.fromRGB(40,40,50),
    }
    local panel = create("Frame", {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(1, 0, 1, 4),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Sidebar, Visible = false,
        ClipsDescendants = true, ZIndex = 20, Parent = preview,
    })
    corner(panel, UDim.new(0, 6))
    stroke(panel, Theme.Outline, 1)
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.fromOffset(22, 22)
    grid.CellPadding = UDim2.fromOffset(4, 4)
    grid.Parent = panel
    padding(panel, 4)

    local open = false
    for _, c in ipairs(palette) do
        local sw = create("TextButton", {
            BackgroundColor3 = c, Text = "", AutoButtonColor = false,
            ZIndex = 21, Parent = panel,
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
        tween(panel, 0.2, {
            Size = open and UDim2.new(0, 172, 0, 110) or UDim2.new(0, 0, 0, 0),
        })
    end)
    return preview
end

local function makeKeybind(parent, data)
    local key = data.Value or "None"
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = data.Title or "按键",
        Parent = holder,
    })
    local btn = create("TextButton", {
        Size = UDim2.fromOffset(72, 24), Position = UDim2.new(1, -72, 0.5, -12),
        BackgroundColor3 = Theme.Card, AutoButtonColor = false,
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text,
        Text = key, Parent = holder,
    })
    corner(btn, UDim.new(0, 6))
    stroke(btn, Theme.Outline, 1)

    local waiting = false
    btn.MouseButton1Click:Connect(function()
        waiting = true
        btn.Text = "..."
        btn.BackgroundColor3 = Theme.Accent
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
            waiting = false
            key = input.KeyCode.Name
            btn.Text = key
            btn.BackgroundColor3 = Theme.Card
            if data.Callback then task.spawn(data.Callback, key) end
        end
    end)
    return btn
end

-- ========== 主窗口 ==========
function WindUI:CreateWindow(opts)
    opts = opts or {}
    Theme = Themes[opts.Theme or "Dark"] or Themes.Dark
    self.Theme = Theme

    local gui = create("ScreenGui", {
        Name = "WindUI_" .. (opts.Title or "Window"),
        ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = getParent(),
    })

    local main = create("Frame", {
        Size = opts.Size or UDim2.fromOffset(640, 480),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Main, BorderSizePixel = 0,
        Parent = gui,
    })
    corner(main, UDim.new(0, 12))
    stroke(main, Theme.Stroke, 1)

    -- 标题栏
    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0,
        Parent = main,
    })
    corner(titleBar, UDim.new(0, 12))
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0,
        Parent = titleBar,
    })

    local iconLabel = create("TextLabel", {
        Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 14, 0.5, -12),
        BackgroundColor3 = Theme.Accent, Text = opts.Icon or "★",
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.new(1,1,1), Parent = titleBar,
    })
    corner(iconLabel, UDim.new(0, 6))

    create("TextLabel", {
        Size = UDim2.new(1, -160, 0, 18), Position = UDim2.new(0, 46, 0, 6),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text pairsSize = 14,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Title or "WindUI", Parent = titleBar,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -160, 0, 14), Position = UDim2.new(0, 46, 0, 23),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Author or "by WindUI", Parent = titleBar,
    })

    -- 最小化按钮
    local minBtn = create("TextButton", {
        Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -70, 0.5, -12),
        BackgroundColor3 = Theme.Card, AutoButtonColor = false,
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text,
        Text = "─", Parent = titleBar,
    })
    corner(minBtn, UDim.new(0, 6))

    -- 关闭按钮
    local closeBtn = create("TextButton", {
        Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -36, 0.5, -12),
        BackgroundColor3 = Theme.Danger, AutoButtonColor = false,
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1),
        Text = "×", Parent = titleBar,
    })
    corner(closeBtn, UDim.new(0, 6))

    -- 拖动
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Mouse(tMovement or input.UserInputabType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- 侧边栏
    local sidebar = create("Frame", {
        Size = UDim2.new(0, opts.SideBarWidth or 160, 1, -58),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0,
        Parent = main,
    })
    corner(sidebar, UDim.new(0, 10))
    stroke(sidebar, Theme.Stroke, 1)
    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 4)
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Parent = sidebar
Buttons    padding(sidebar, 6)

    -- 内容)区
    local content = create("Frame", {
        Size = UDim2.new(1, -(opts.SideBarWidth or 160) - 30, 1, -62),
        Position = UDim2.new(0, (opts.SideBarWidth or 160) + 20, 0, 54),
        BackgroundTransparency = 1, ClipsDescendants = true,
        Parent = main,
    })

    -- 悬浮窗（最小化后）
    local minimized = false
    local miniHolder = create("ScreenGui", {
        Name = "WindUI_Mini", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9998,
        Parent = getParent(),
    })
    local miniBtn = create("TextButton", {
        Size = UDim2.fromOffset(48, 48),
        Position = UDim2.new(0, 20, 0.5, -24),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
        Text = opts.Icon or "★", Font = Enum.Font.GothamBold,
        TextSize = 18, TextColor3 = Color3.new(1,1,1),
        AutoButtonColor = false,
        Visible = false,
        Parent = miniHolder,
    })
    corner(miniBtn, UDim.new(1, 0))
    stroke(miniBtn, Theme.AccentDark, 2)

    local miniDragging, miniStart, miniPos
    miniBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = true
            miniStart = input.Position
            miniPos = miniBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - miniStart
            miniBtn.Position = UDim2.new(miniPos.X.Scale, miniPos.X.Offset + d.X, miniPos.Y.Scale, miniPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = false
        end
    end)

    local function setMinimize(state)
        minimized = state
        if state then
            tween(main, 0.25, { Position = UDim2.new(0.5, 0, 1.5, 0) })
            task.delay(0.25, function()
                main.Visible = false
            end)
            task.delay(0.3, function()
                miniBtn.Visible = true
                miniBtn.Size = UDim2.fromOffset(0, 0)
                tween(miniBtn, 0.25, { Size = UDim2.fromOffset(48, 48) })
            end)
        else
            miniBtn.Visible = false
            main.Visible = true
            main.Position = UDim2.new(0.5, 0, 0.5, 0)
            main.Size = UDim2.fromOffset(0, 0)
            tween(main, 0.25, { Size = opts.Size or UDim2.fromOffset(640, 480) })
        end
    end

    minBtn.MouseButton1Click:Connect(function() setMinimize(true) end)
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
        miniHolder.Enabled = false
    end)
    miniBtn.MouseButton1Click:Connect(function()
        if miniDragging then return end
        setMinimize(false)
    end)

    -- 状态
    local tabs, tabButtons = {}, {}
    local currentTab

    local function selectTab(name)
        for n, page in pairs(tabs) do page.Visible = (n == name) end
        for n, btn in do
            if n == name then
                tween(btn, 0.15, { BackgroundColor3 = Theme.Accent })
                tween(btn.IconLabel, 0.15, { TextColor3 = Color3.new(1,1,1) })
                tween(btn.TitleLabel, 0.15, { TextColor3 = Color3.new(1,1,1) })
            else
                tween(btn, 0.15, { BackgroundColor3 = Theme.Card })
                tween(btn.IconLabel, 0.15, { TextColor3 = Theme.Accent })
                tween(btn.TitleLabel, 0.15, { TextColor3 = Theme.Text })
            end
        end
        currentTab = name
    end

    local window = {
        Gui = gui, Main = main, Content = content, Sidebar = sidebar,
        MiniBtn = miniBtn, Theme = Theme, Tabs = tabs,
        SelectTab = selectTab, SetMinimize = setMinimize,
    }
    setmetatable(window, WindUI)

    function window:Tab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Title or "标签"
        local icon = tabOpts.Icon or "●"

        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Card, AutoButtonColor = false,
            Text = "", Parent = sidebar,
        })
        corner(btn, UDim.new(0, 8))
        local iconLbl = create("TextLabel", {
            Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 8, 0.5, -10),
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            TextSize = 13, TextColor3 = Theme.Accent,
            Text = icon, Parent = btn,
        })
        iconLbl.Name = "IconLabel"
        local titleLbl = create("TextLabel", {
            Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
            TextSize = 13, TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left, Text = name,
            Parent = btn,
        })
        titleLbl.Name = "TitleLabel"
        btn.IconLabel = iconLbl
        btn.TitleLabel = titleLbl

        btn.MouseButton1Click:Connect(function() selectTab(name) end)
        tabButtons[name] = btn

        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
            Parent = content,
        })
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = page
        padding(page, 4, 6, 12, 4)
        tabs[name] = page

        local tabObj = { Page = page, Name = name }
        setmetatable(tabObj, WindUI)

        function tabObj:Section(secOpts)
            secOpts = secOpts or {}
            local holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
                Parent = page,
            })
            local header = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Theme.Card, AutoButtonColor = false,
                Text = "", Parent = holder,
            })
            corner(header, UDim.new(0, 8))
            stroke(header, Theme.Stroke, 1)
            create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
                TextSize = 13, TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = secOpts.Title or "分区", Parent = header,
            })
            local arrowLbl = create("TextLabel", {
                Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -22, 0.5, -8),
                BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
                TextSize = 12, TextColor3 = Theme.SubText, Text = "▼",
                Parent = header,
            })

            local body = create("Frame", {
                Size = UDim2.new(1, -12, 0, 0), Position = UDim2.new(0, 6, 0, 40),
                BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0,
                Parent = holder,
            })
            corner(body, UDim.new(0, 8))
            stroke(body, Theme.Stroke, 1)
            local bodyLayout = Instance.new("UIListLayout")
            bodyLayout.Padding = UDim.new(0, 6)
            bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
            bodyLayout.Parent = body
            padding(body, 10, 12, 10, 12)

            local function layout()
                body.Size = UDim2.new(1, -12, 0, bodyLayout.AbsoluteContentSize.Y + 20)
                holder.Size = UDim2.new(1, 0, 0, body.Size.Y.Offset + 46)
            end
            layout()
            bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(layout)

            local open = secOpts.Opened ~= false
            body.Visible = open
            arrowLbl.Text = open and "▼" or "▶"
            if not open then holder.Size = UDim2.new(1, 0, 0, 34) end

            header.MouseButton1Click:Connect(function()
                open = not open
                arrowLbl.Text = open and "▼" or "▶"
                if open then
                    body.Visible = true
                    layout()
                else
                    body.Visible = false
                    holder.Size = UDim2.new(1, 0, 0, 34)
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
                return create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Stroke,
                    BorderSizePixel = 0, Parent = body,
                })
            end
            function sec:Label(text)
                return create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left, Text = text or "",
                    Parent = body,
                })
            end
            function sec:Paragraph(p)
                local card = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Parent = body,
                })
                corner(card, UDim.new(0, 8))
                padding(card, 10, 12, 10, 12)
                create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left, Text = p.Title or "",
                    Parent = card,
                })
                create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
                    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top, Text = p.Desc or "",
                    Parent = card,
                })
                return card
            end

            return sec
        end

        return tabObj
    end

    function window:SetTheme(name)
        local nt = Themes[name]
        if not nt then return end
        Theme = nt
        self.Theme = Theme
        tween(main, 0.2, { BackgroundColor3 = Theme.Main })
        tween(titleBar, 0.2, { BackgroundColor3 = Theme.Sidebar })
        tween(sidebar, 0.2, { BackgroundColor3 = Theme.Sidebar })
        for _, btn in pairs(tabButtons) do
            if btn.BackgroundColor3 ~= Theme.Accent then
                tween(btn, 0.2, { BackgroundColor3 = Theme.Card })
            end
            btn.TitleLabel.TextColor3 = Theme.Text
            btn.IconLabel.TextColor3 = Theme.Accent
        end
        tween(miniBtn, 0.2, { BackgroundColor3 = Theme.Accent })
    end

    function window:Toggle()
        gui.Enabled = not gui.Enabled
        miniHolder.Enabled = gui.Enabled
    end

    function window:Destroy()
        gui:Destroy()
        miniHolder:Destroy()
        if NotifyHolder then NotifyHolder:Destroy() end
    end

    -- 快捷键
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            window:Toggle()
        end
    end)

    local first = next(tabs)
    if first then selectTab(first) end

    return window
end

return WindUI