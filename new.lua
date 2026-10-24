local Settings = {
    AimbotEnabled = false,
    AimbotMode = "Toggle",
    TriggerbotEnabled = false,
    TriggerbotDelay = 0.05,
    SemiDelay = 0.12,
    FOVSize = 100,
    TargetingSmoothness = 0.50,
    TrackingSmoothness = 0.50,
    TeamCheck = false,
    WallCheck = false,
    ShowFOV = false,
    FOVOrigin = "Center",
    TargetPart = "Head",
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVColorName = "Pink",

    ESPHighlight = false,
    ESPHeadDot = false,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    ESPSkeleton = false,
    ESPTracers = false,
    TeamCheckESP = false,
    ESPColor = Color3.fromRGB(255, 255, 255),
    ESPColorName = "Pink",

    FlyActive = false,
    FlySpeed = 50,
    FlyNoClip = false,

    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,

    TeleportOffset = "In Front",
    SelectedTeleportTarget = nil,

    ShowKeybindsHud = false,
    CustomFont = Enum.Font.FredokaOne,
    CurrentTheme = "Bubblegum Pink",

    KeyAimbot = Enum.KeyCode.V,
    KeyFly = Enum.KeyCode.X,
    KeyToggleMenu = Enum.KeyCode.LeftAlt,
    KeyClickTeleport = nil,
    KeyUnload = Enum.KeyCode.U,

    KeyESPHighlight = nil,
    KeyESPHeadDot = nil,
    KeyESPBox = nil,
    KeyESPName = nil,
    KeyESPHealth = nil,
    KeyESPSkeleton = nil,
    KeyESPTracers = nil,
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- ============================================================
-- 2. SAVE / LOAD SYSTEM
-- ============================================================
local SAVE_FILE = "SaifsAimbot_Settings.json"

local function saveSettings()
    if not writefile then return end
    local toSave = {}
    for k, v in pairs(Settings) do
        if typeof(v) == "EnumItem" then
            toSave[k] = {_enum = true, enumType = v.EnumType.Name, name = v.Name}
        elseif typeof(v) == "Color3" then
            toSave[k] = {_color = true, r = v.R, g = v.G, b = v.B}
        elseif typeof(v) == "Instance" then
            if v:IsA("Player") then
                toSave[k] = {_player = true, name = v.Name}
            end
        else
            toSave[k] = v
        end
    end
    pcall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode(toSave))
    end)
end

local function loadSettings()
    if not isfile or not readfile then return end
    if not isfile(SAVE_FILE) then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end)
    if not ok or type(data) ~= "table" then return end
    for k, v in pairs(data) do
        if Settings[k] ~= nil or k:match("^Key") then
            if type(v) == "table" and v._enum then
                local enumType = Enum[v.enumType]
                if enumType then
                    Settings[k] = enumType[v.name]
                end
            elseif type(v) == "table" and v._color then
                Settings[k] = Color3.new(v.r, v.g, v.b)
            elseif type(v) == "table" and v._player then
                local plr = Players:FindFirstChild(v.name)
                if plr then Settings[k] = plr end
            elseif k ~= "SelectedTeleportTarget" then
                Settings[k] = v
            end
        end
    end
end

loadSettings()

local connections = {}
local listeningForKey = nil
local ignoreNextClick = false
local draggingTargetingSlider = false
local draggingTrackingSlider = false
local draggingTriggerDelaySlider = false
local draggingFOVSlider = false
local draggingFlySpeedSlider = false
local draggingWalkSpeedSlider = false
local draggingJumpPowerSlider = false
local lastTriggerShot = 0
local isShooting = false
local isAimbotHeld = false
local allDropdowns = {}
local lastSaveTime = 0
local SAVE_INTERVAL = 2

local Themes = {
    ["Bubblegum Pink"] = {Accent = Color3.fromRGB(255, 105, 180), Bg = Color3.fromRGB(35, 18, 28), Card = Color3.fromRGB(48, 24, 38), Text = Color3.fromRGB(255, 220, 240), SubText = Color3.fromRGB(200, 140, 175), Off = Color3.fromRGB(90, 50, 75), TabActive = Color3.fromRGB(65, 32, 52), TabInactive = Color3.fromRGB(38, 19, 30), WidgetBg = Color3.fromRGB(60, 30, 48)},
    ["Neon Red"] = {Accent = Color3.fromRGB(255, 50, 50), Bg = Color3.fromRGB(25, 15, 15), Card = Color3.fromRGB(38, 20, 20), Text = Color3.fromRGB(255, 220, 220), SubText = Color3.fromRGB(200, 130, 130), Off = Color3.fromRGB(90, 45, 45), TabActive = Color3.fromRGB(55, 25, 25), TabInactive = Color3.fromRGB(28, 16, 16), WidgetBg = Color3.fromRGB(55, 30, 30)},
    ["Cyber Cyan"] = {Accent = Color3.fromRGB(0, 229, 255), Bg = Color3.fromRGB(15, 22, 26), Card = Color3.fromRGB(20, 35, 42), Text = Color3.fromRGB(220, 245, 255), SubText = Color3.fromRGB(120, 165, 185), Off = Color3.fromRGB(40, 80, 95), TabActive = Color3.fromRGB(25, 50, 62), TabInactive = Color3.fromRGB(16, 26, 32), WidgetBg = Color3.fromRGB(30, 55, 68)},
    ["Emerald Green"] = {Accent = Color3.fromRGB(46, 204, 113), Bg = Color3.fromRGB(15, 24, 19), Card = Color3.fromRGB(20, 38, 28), Text = Color3.fromRGB(220, 255, 235), SubText = Color3.fromRGB(120, 190, 150), Off = Color3.fromRGB(40, 90, 60), TabActive = Color3.fromRGB(25, 55, 38), TabInactive = Color3.fromRGB(16, 28, 20), WidgetBg = Color3.fromRGB(30, 60, 42)},
    ["Frost"] = {Accent = Color3.fromRGB(255, 255, 255), Bg = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(26, 26, 30), Text = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(130, 130, 145), Off = Color3.fromRGB(60, 60, 70), TabActive = Color3.fromRGB(38, 38, 45), TabInactive = Color3.fromRGB(22, 22, 26), WidgetBg = Color3.fromRGB(35, 35, 42)}
}

local Theme = Themes[Settings.CurrentTheme] or Themes["Bubblegum Pink"]

local successGui, parentContainer = pcall(function() return CoreGui end)
if not successGui or not parentContainer then parentContainer = Player:WaitForChild("PlayerGui") end
if parentContainer:FindFirstChild("SaifsAimbotGui") then parentContainer.SaifsAimbotGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaifsAimbotGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parentContainer

local LoadTheme = Themes["Bubblegum Pink"]

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local LoadingMenu = Instance.new("Frame")
LoadingMenu.Name = "LoadingMenu"
LoadingMenu.Size = UDim2.new(0, 320, 0, 140)
LoadingMenu.Position = UDim2.new(0.5, -160, 0.5, -70)
LoadingMenu.BackgroundColor3 = LoadTheme.Bg
LoadingMenu.BorderSizePixel = 0
LoadingMenu.ZIndex = 1000
LoadingMenu.Parent = ScreenGui
local stroke = Instance.new("UIStroke", LoadingMenu)
stroke.Color = LoadTheme.Accent
stroke.Thickness = 1.5
Instance.new("UICorner", LoadingMenu).CornerRadius = UDim.new(0, 10)

local LoadTitle = Instance.new("TextLabel", LoadingMenu)
LoadTitle.Size = UDim2.new(1, 0, 0, 30)
LoadTitle.Position = UDim2.new(0, 0, 0, 15)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Font = Settings.CustomFont
LoadTitle.Text = "Saif's Aimbot v2.5"
LoadTitle.TextColor3 = LoadTheme.Accent
LoadTitle.TextSize = 18
LoadTitle.ZIndex = 1001

local LoadStatus = Instance.new("TextLabel", LoadingMenu)
LoadStatus.Size = UDim2.new(1, 0, 0, 20)
LoadStatus.Position = UDim2.new(0, 0, 0, 55)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Font = Settings.CustomFont
LoadStatus.Text = "Initializing..."
LoadStatus.TextColor3 = LoadTheme.SubText
LoadStatus.TextSize = 12
LoadStatus.ZIndex = 1001

local LoadBarBg = Instance.new("Frame", LoadingMenu)
LoadBarBg.Size = UDim2.new(1, -40, 0, 10)
LoadBarBg.Position = UDim2.new(0, 20, 0, 85)
LoadBarBg.BackgroundColor3 = LoadTheme.WidgetBg
LoadBarBg.BorderSizePixel = 0
LoadBarBg.ZIndex = 1001
Instance.new("UICorner", LoadBarBg).CornerRadius = UDim.new(1, 0)

local LoadBarFill = Instance.new("Frame", LoadBarBg)
LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadBarFill.BackgroundColor3 = LoadTheme.Accent
LoadBarFill.BorderSizePixel = 0
LoadBarFill.ZIndex = 1002
Instance.new("UICorner", LoadBarFill).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local steps = {
        {progress = 0.2, text = "Bypassing Anticheat...", time = 0.8},
        {progress = 0.5, text = "Loading ESP Modules...", time = 1.0},
        {progress = 0.8, text = "Injecting Aimbot Hooks...", time = 1.2},
        {progress = 1.0, text = "Ready!", time = 1.0},
    }
    for _, step in ipairs(steps) do
        LoadStatus.Text = step.text
        TweenService:Create(LoadBarFill, TweenInfo.new(step.time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(step.progress, 0, 1, 0)}):Play()
        task.wait(step.time)
    end
    task.wait(0.2)
    TweenService:Create(LoadingMenu, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    for _, child in ipairs(LoadingMenu:GetChildren()) do
        if child:IsA("GuiObject") then pcall(function() TweenService:Create(child, TweenInfo.new(0.4), {Transparency = 1}):Play() end) end
    end
    task.wait(0.4)
    LoadingMenu:Destroy()
    MainFrame.Visible = true
    UserInputService.MouseIconEnabled = true
end)

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0, 24, 0, 24)
ResizeHandle.Position = UDim2.new(1, -24, 1, -24)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = Theme.SubText
ResizeHandle.TextSize = 12
ResizeHandle.ZIndex = 10
ResizeHandle.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Position = UDim2.new(0, 15, 0, 12)
Title.BackgroundTransparency = 1
Title.Font = Settings.CustomFont
Title.Text = "Saif's Aimbot"
Title.TextColor3 = Theme.Text
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

local function getKeyName(inputObj)
    if not inputObj then return "None" end
    if typeof(inputObj) == "EnumItem" then
        if inputObj.EnumType == Enum.KeyCode then return inputObj.Name
        elseif inputObj.EnumType == Enum.UserInputType then
            if inputObj == Enum.UserInputType.MouseButton1 then return "MB1" end
            if inputObj == Enum.UserInputType.MouseButton2 then return "MB2" end
            if inputObj == Enum.UserInputType.MouseButton3 then return "MB3" end
            return inputObj.Name
        end
    end
    return tostring(inputObj)
end

local KeybindsHud = Instance.new("Frame")
KeybindsHud.Size = UDim2.new(0, 190, 0, 100)
KeybindsHud.Position = UDim2.new(0, 15, 1, -115)
KeybindsHud.BackgroundColor3 = Theme.Card
KeybindsHud.BorderSizePixel = 0
KeybindsHud.Visible = false
KeybindsHud.ZIndex = 50
KeybindsHud.Parent = ScreenGui
Instance.new("UICorner", KeybindsHud).CornerRadius = UDim.new(0, 8)

local function createHudStatusRow(yOffset, labelText)
    local rowLbl = Instance.new("TextLabel", KeybindsHud)
    rowLbl.Size = UDim2.new(1, -20, 0, 20)
    rowLbl.Position = UDim2.new(0, 10, 0, yOffset)
    rowLbl.BackgroundTransparency = 1
    rowLbl.Font = Settings.CustomFont
    rowLbl.Text = labelText
    rowLbl.TextColor3 = Theme.SubText
    rowLbl.TextSize = 12
    rowLbl.TextXAlignment = Enum.TextXAlignment.Left
    rowLbl.ZIndex = 51

    local stateLbl = Instance.new("TextLabel", KeybindsHud)
    stateLbl.Size = UDim2.new(0, 60, 0, 20)
    stateLbl.Position = UDim2.new(1, -70, 0, yOffset)
    stateLbl.BackgroundTransparency = 1
    stateLbl.Font = Settings.CustomFont
    stateLbl.Text = "OFF"
    stateLbl.TextColor3 = Color3.fromRGB(239, 68, 68)
    stateLbl.TextSize = 12
    stateLbl.TextXAlignment = Enum.TextXAlignment.Right
    stateLbl.ZIndex = 51
    return rowLbl, stateLbl
end

local HudRowAimbot, HudStatusAimbot = createHudStatusRow(8, "Aimbot [" .. getKeyName(Settings.KeyAimbot) .. "]")
local HudRowFly, HudStatusFly = createHudStatusRow(30, "Fly [" .. getKeyName(Settings.KeyFly) .. "]")
local HudRowMenu, HudStatusMenu = createHudStatusRow(52, "Menu [" .. getKeyName(Settings.KeyToggleMenu) .. "]")

local HudStatusUnload = Instance.new("TextLabel", KeybindsHud)
HudStatusUnload.Size = UDim2.new(1, -20, 0, 18)
HudStatusUnload.Position = UDim2.new(0, 10, 0, 74)
HudStatusUnload.BackgroundTransparency = 1
HudStatusUnload.Font = Settings.CustomFont
HudStatusUnload.Text = "Press " .. getKeyName(Settings.KeyUnload) .. " to Unload"
HudStatusUnload.TextColor3 = Theme.SubText
HudStatusUnload.TextSize = 10
HudStatusUnload.TextXAlignment = Enum.TextXAlignment.Center
HudStatusUnload.ZIndex = 51

local currentTab = 1
local tabButtons = {}
local tabContainers = {}

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -30, 0, 24)
TabBar.Position = UDim2.new(0, 15, 0, 42)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 2
local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)

local function createTabButton(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/6, -4, 1, 0)
    btn.BackgroundColor3 = (currentTab == index) and Theme.TabActive or Theme.TabInactive
    btn.BorderSizePixel = 0
    btn.Font = Settings.CustomFont
    btn.Text = name
    btn.TextColor3 = (currentTab == index) and Theme.Text or Theme.SubText
    btn.TextSize = 11
    btn.ZIndex = 5
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    tabButtons[index] = btn
    return btn
end

local Tab1 = createTabButton("Aimbot", 1)
local Tab2 = createTabButton("ESP", 2)
local Tab3 = createTabButton("Teleport", 3)
local Tab4 = createTabButton("Movement", 4)
local Tab5 = createTabButton("Keybinds", 5)
local Tab6 = createTabButton("Settings", 6)

for i = 1, 6 do
    local scroller = Instance.new("ScrollingFrame")
    scroller.Size = UDim2.new(1, -20, 1, -85)
    scroller.Position = UDim2.new(0, 10, 0, 75)
    scroller.BackgroundTransparency = 1
    scroller.BorderSizePixel = 0
    scroller.CanvasSize = UDim2.new(0, 0, 0, 700)
    scroller.ScrollBarThickness = 4
    scroller.ScrollBarImageColor3 = Theme.Accent
    scroller.Visible = (i == 1)
    scroller.ZIndex = 2
    scroller.Parent = MainFrame
    local layout = Instance.new("UIListLayout", scroller)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    tabContainers[i] = scroller
end

local function createCard(tabIndex, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 34)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 3
    card.Parent = tabContainers[tabIndex]
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    return card
end

ToggleTrack1, ToggleKnob1, ToggleTrackTrigger, ToggleKnobTrigger = nil, nil, nil, nil
TriggerDelayTrack, TriggerDelayFill, TriggerDelayText, ResetTriggerDelay = nil, nil, nil, nil
ValTarget, ValAimbotMode, ValFOVOrigin, ValFOVColor = nil, nil, nil, nil
ToggleTrackTeamCheck, ToggleKnobTeamCheck, ToggleTrackWall, ToggleKnobWall = nil, nil, nil, nil
TargetingSliderTrack, TargetingSliderFill, TargetingSliderText, ResetTargetingSmooth = nil, nil, nil, nil
TrackingSliderTrack, TrackingSliderFill, TrackingSliderText, ResetTrackingSmooth = nil, nil, nil, nil
ToggleTrack3, ToggleKnob3, FOVSliderTrack, FOVSliderFill, FOVSliderText, ResetFOVSlider = nil, nil, nil, nil, nil, nil

TrackTeamCheckESP, KnobTeamCheckESP = nil, nil
TrackEspHighlight, KnobEspHighlight = nil, nil
TrackEspHeadDot, KnobEspHeadDot = nil, nil
TrackEspBox, KnobEspBox = nil, nil
TrackEspName, KnobEspName = nil, nil
TrackEspHealth, KnobEspHealth = nil, nil
TrackEspSkeleton, KnobEspSkeleton = nil, nil
TrackEspTracers, KnobEspTracers = nil, nil
ValKeyEspHighlight, ValKeyEspHeadDot, ValKeyEspBox, ValKeyEspName, ValKeyEspHealth, ValKeyEspSkeleton, ValKeyEspTracers = nil, nil, nil, nil, nil, nil, nil
ValESPColor = nil

ValTpOffset, BtnTpNearest, ValTpPlayer, BtnTpExecute, executeTeleport = nil, nil, nil, nil, nil

ToggleTrackFly, ToggleKnobFly, ToggleTrackFlyNoClip, ToggleKnobFlyNoClip = nil, nil, nil, nil
FlySpeedTrack, FlySpeedFill, FlySpeedText, ResetFlySpeed = nil, nil, nil, nil
WalkSpeedTrack, WalkSpeedFill, WalkSpeedText, ResetWalkSpeed = nil, nil, nil, nil
JumpPowerTrack, JumpPowerFill, JumpPowerText, ResetJumpPower = nil, nil, nil, nil
ToggleTrackInfJump, ToggleKnobInfJump = nil, nil

ToggleTrackKeybindsHud, ToggleKnobKeybindsHud = nil, nil
ValKeyAimbot, ValKeyFly, ValKeyMenu, ValKeyClickTeleport, ValKeyUnload, ValTheme = nil, nil, nil, nil, nil, nil

updateUIStates, updateSliderTextColors, switchTab, applyThemeColors = nil, nil, nil, nil
local activeDropdownList = nil

local function closeActiveDropdown()
    if activeDropdownList and activeDropdownList.Parent then
        activeDropdownList.Visible = false
        activeDropdownList = nil
    end
end

local function createDropdown(parentCard, defaultText, options, onSelect)
    local container = Instance.new("Frame", parentCard)
    container.Size = UDim2.new(0, 130, 0, 24)
    container.Position = UDim2.new(1, -142, 0.5, -12)
    container.BackgroundTransparency = 1
    container.ZIndex = 15

    local valBtn = Instance.new("TextButton", container)
    valBtn.Size = UDim2.new(1, 0, 1, 0)
    valBtn.BackgroundColor3 = Theme.WidgetBg
    valBtn.BorderSizePixel = 0
    valBtn.Font = Settings.CustomFont
    valBtn.Text = defaultText .. " ▾"
    valBtn.TextColor3 = Theme.Accent
    valBtn.TextSize = 13
    valBtn.ZIndex = 15
    Instance.new("UICorner", valBtn).CornerRadius = UDim.new(0, 5)

    local listHeight = (#options * 28) + 32
    local listFrame = Instance.new("Frame", ScreenGui)
    listFrame.Size = UDim2.new(0, 130, 0, listHeight)
    listFrame.BackgroundColor3 = Theme.Bg
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 200
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 5)

    local closeBtn = Instance.new("TextButton", listFrame)
    closeBtn.Size = UDim2.new(1, 0, 0, 28)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Settings.CustomFont
    closeBtn.Text = "Close ▴"
    closeBtn.TextColor3 = Theme.Accent
    closeBtn.TextSize = 12
    closeBtn.ZIndex = 201
    closeBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = false
        if activeDropdownList == listFrame then activeDropdownList = nil end
    end)

    local sep = Instance.new("Frame", listFrame)
    sep.Size = UDim2.new(1, -10, 0, 1)
    sep.Position = UDim2.new(0, 5, 0, 28)
    sep.BackgroundColor3 = Theme.Off
    sep.BorderSizePixel = 0
    sep.ZIndex = 201

    for idx, opt in ipairs(options) do
        local btn = Instance.new("TextButton", listFrame)
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.Position = UDim2.new(0, 0, 0, 29 + ((idx - 1) * 28))
        btn.BackgroundTransparency = 1
        btn.Font = Settings.CustomFont
        btn.Text = tostring(opt)
        btn.TextColor3 = Theme.Text
        btn.TextSize = 12
        btn.ZIndex = 201
        btn.MouseButton1Click:Connect(function()
            onSelect(opt)
            valBtn.Text = tostring(opt) .. " ▾"
            listFrame.Visible = false
            if activeDropdownList == listFrame then activeDropdownList = nil end
        end)
    end

    valBtn.MouseButton1Click:Connect(function()
        if listFrame.Visible then
            listFrame.Visible = false
            if activeDropdownList == listFrame then activeDropdownList = nil end
        else
            closeActiveDropdown()
            local absPos = valBtn.AbsolutePosition
            listFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + 30)
            listFrame.Visible = true
            activeDropdownList = listFrame
        end
    end)

    table.insert(allDropdowns, {btn = valBtn, list = listFrame, sep = sep, closeBtn = closeBtn})
    return valBtn, listFrame
end

local function buildAllTabs()
    local function buildTab1()
        local Card1 = createCard(1, 1)
        local LblAimbot = Instance.new("TextLabel", Card1)
        LblAimbot.Size = UDim2.new(0, 200, 0, 34); LblAimbot.Position = UDim2.new(0, 12, 0, 0); LblAimbot.BackgroundTransparency = 1
        LblAimbot.Font = Settings.CustomFont; LblAimbot.Text = "Aimbot"; LblAimbot.TextColor3 = Theme.Text; LblAimbot.TextSize = 14; LblAimbot.TextXAlignment = Enum.TextXAlignment.Left; LblAimbot.ZIndex = 4

        ToggleTrack1 = Instance.new("Frame", Card1)
        ToggleTrack1.Name = "ToggleTrack"; ToggleTrack1.Size = UDim2.new(0, 34, 0, 18); ToggleTrack1.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrack1.BackgroundColor3 = Theme.Off; ToggleTrack1.ZIndex = 4
        Instance.new("UICorner", ToggleTrack1).CornerRadius = UDim.new(1, 0)
        ToggleKnob1 = Instance.new("Frame", ToggleTrack1)
        ToggleKnob1.Name = "ToggleKnob"; ToggleKnob1.Size = UDim2.new(0, 14, 0, 14); ToggleKnob1.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnob1.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnob1.ZIndex = 5
        Instance.new("UICorner", ToggleKnob1).CornerRadius = UDim.new(1, 0)

        local CardTriggerbot = createCard(1, 2)
        local LblTriggerbot = Instance.new("TextLabel", CardTriggerbot)
        LblTriggerbot.Size = UDim2.new(0, 200, 0, 34); LblTriggerbot.Position = UDim2.new(0, 12, 0, 0); LblTriggerbot.BackgroundTransparency = 1
        LblTriggerbot.Font = Settings.CustomFont; LblTriggerbot.Text = "Triggerbot"; LblTriggerbot.TextColor3 = Theme.Text; LblTriggerbot.TextSize = 14; LblTriggerbot.TextXAlignment = Enum.TextXAlignment.Left; LblTriggerbot.ZIndex = 4

        ToggleTrackTrigger = Instance.new("Frame", CardTriggerbot)
        ToggleTrackTrigger.Name = "ToggleTrack"; ToggleTrackTrigger.Size = UDim2.new(0, 34, 0, 18); ToggleTrackTrigger.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackTrigger.BackgroundColor3 = Theme.Off; ToggleTrackTrigger.ZIndex = 4
        Instance.new("UICorner", ToggleTrackTrigger).CornerRadius = UDim.new(1, 0)
        ToggleKnobTrigger = Instance.new("Frame", ToggleTrackTrigger)
        ToggleKnobTrigger.Name = "ToggleKnob"; ToggleKnobTrigger.Size = UDim2.new(0, 14, 0, 14); ToggleKnobTrigger.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobTrigger.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobTrigger.ZIndex = 5
        Instance.new("UICorner", ToggleKnobTrigger).CornerRadius = UDim.new(1, 0)

        local CardTriggerDelay = createCard(1, 3)
        local LblTriggerDelay = Instance.new("TextLabel", CardTriggerDelay)
        LblTriggerDelay.Size = UDim2.new(0, 200, 0, 34); LblTriggerDelay.Position = UDim2.new(0, 12, 0, 0); LblTriggerDelay.BackgroundTransparency = 1
        LblTriggerDelay.Font = Settings.CustomFont; LblTriggerDelay.Text = "Trigger Delay"; LblTriggerDelay.TextColor3 = Theme.Text; LblTriggerDelay.TextSize = 14; LblTriggerDelay.TextXAlignment = Enum.TextXAlignment.Left; LblTriggerDelay.ZIndex = 4

        TriggerDelayTrack = Instance.new("Frame", CardTriggerDelay)
        TriggerDelayTrack.Size = UDim2.new(0, 150, 0, 14); TriggerDelayTrack.Position = UDim2.new(1, -196, 0.5, -7); TriggerDelayTrack.BackgroundColor3 = Theme.WidgetBg; TriggerDelayTrack.ZIndex = 4
        Instance.new("UICorner", TriggerDelayTrack).CornerRadius = UDim.new(1, 0)
        TriggerDelayFill = Instance.new("Frame", TriggerDelayTrack)
        TriggerDelayFill.Size = UDim2.new(Settings.TriggerbotDelay / 1.0, 0, 1, 0); TriggerDelayFill.BackgroundColor3 = Theme.Accent; TriggerDelayFill.ZIndex = 5
        Instance.new("UICorner", TriggerDelayFill).CornerRadius = UDim.new(1, 0)
        TriggerDelayText = Instance.new("TextLabel", TriggerDelayTrack)
        TriggerDelayText.Size = UDim2.new(1, 0, 1, 0); TriggerDelayText.BackgroundTransparency = 1; TriggerDelayText.Font = Settings.CustomFont; TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay); TriggerDelayText.TextColor3 = Color3.fromRGB(255, 255, 255); TriggerDelayText.TextSize = 12; TriggerDelayText.ZIndex = 6

        ResetTriggerDelay = Instance.new("TextButton", CardTriggerDelay)
        ResetTriggerDelay.Size = UDim2.new(0, 22, 0, 22); ResetTriggerDelay.Position = UDim2.new(1, -28, 0.5, -11); ResetTriggerDelay.BackgroundColor3 = Theme.WidgetBg; ResetTriggerDelay.Font = Settings.CustomFont; ResetTriggerDelay.Text = "↺"; ResetTriggerDelay.TextColor3 = Theme.Accent; ResetTriggerDelay.TextSize = 13; ResetTriggerDelay.ZIndex = 4
        Instance.new("UICorner", ResetTriggerDelay).CornerRadius = UDim.new(0, 4)
        ResetTriggerDelay.MouseButton1Click:Connect(function()
            Settings.TriggerbotDelay = 0.05
            TweenService:Create(TriggerDelayFill, TweenInfo.new(0.3), {Size = UDim2.new(Settings.TriggerbotDelay / 1.0, 0, 1, 0)}):Play()
            TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay)
            updateSliderTextColors()
        end)

        local CardTarget = createCard(1, 4)
        local LblTarget = Instance.new("TextLabel", CardTarget)
        LblTarget.Size = UDim2.new(0, 200, 0, 34); LblTarget.Position = UDim2.new(0, 12, 0, 0); LblTarget.BackgroundTransparency = 1
        LblTarget.Font = Settings.CustomFont; LblTarget.Text = "Target Hitbox"; LblTarget.TextColor3 = Theme.Text; LblTarget.TextSize = 14; LblTarget.TextXAlignment = Enum.TextXAlignment.Left; LblTarget.ZIndex = 4
        ValTarget = createDropdown(CardTarget, Settings.TargetPart, {"Head", "Chest"}, function(s) Settings.TargetPart = s end)

        local CardAimbotMode = createCard(1, 5)
        local LblAimbotMode = Instance.new("TextLabel", CardAimbotMode)
        LblAimbotMode.Size = UDim2.new(0, 200, 0, 34); LblAimbotMode.Position = UDim2.new(0, 12, 0, 0); LblAimbotMode.BackgroundTransparency = 1
        LblAimbotMode.Font = Settings.CustomFont; LblAimbotMode.Text = "Aimbot Mode"; LblAimbotMode.TextColor3 = Theme.Text; LblAimbotMode.TextSize = 14; LblAimbotMode.TextXAlignment = Enum.TextXAlignment.Left; LblAimbotMode.ZIndex = 4
        ValAimbotMode = createDropdown(CardAimbotMode, Settings.AimbotMode, {"Toggle", "Hold"}, function(s) Settings.AimbotMode = s; isAimbotHeld = false end)

        local CardTeamCheck = createCard(1, 6)
        local LblTeamCheck = Instance.new("TextLabel", CardTeamCheck)
        LblTeamCheck.Size = UDim2.new(0, 200, 0, 34); LblTeamCheck.Position = UDim2.new(0, 12, 0, 0); LblTeamCheck.BackgroundTransparency = 1
        LblTeamCheck.Font = Settings.CustomFont; LblTeamCheck.Text = "Team Check"; LblTeamCheck.TextColor3 = Theme.Text; LblTeamCheck.TextSize = 14; LblTeamCheck.TextXAlignment = Enum.TextXAlignment.Left; LblTeamCheck.ZIndex = 4
        ToggleTrackTeamCheck = Instance.new("Frame", CardTeamCheck)
        ToggleTrackTeamCheck.Name = "ToggleTrack"; ToggleTrackTeamCheck.Size = UDim2.new(0, 34, 0, 18); ToggleTrackTeamCheck.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackTeamCheck.BackgroundColor3 = Theme.Off; ToggleTrackTeamCheck.ZIndex = 4
        Instance.new("UICorner", ToggleTrackTeamCheck).CornerRadius = UDim.new(1, 0)
        ToggleKnobTeamCheck = Instance.new("Frame", ToggleTrackTeamCheck)
        ToggleKnobTeamCheck.Size = UDim2.new(0, 14, 0, 14); ToggleKnobTeamCheck.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobTeamCheck.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobTeamCheck.ZIndex = 5
        Instance.new("UICorner", ToggleKnobTeamCheck).CornerRadius = UDim.new(1, 0)

        local CardWallCheck = createCard(1, 7)
        local LblWallCheck = Instance.new("TextLabel", CardWallCheck)
        LblWallCheck.Size = UDim2.new(0, 200, 0, 34); LblWallCheck.Position = UDim2.new(0, 12, 0, 0); LblWallCheck.BackgroundTransparency = 1
        LblWallCheck.Font = Settings.CustomFont; LblWallCheck.Text = "Wall Check"; LblWallCheck.TextColor3 = Theme.Text; LblWallCheck.TextSize = 14; LblWallCheck.TextXAlignment = Enum.TextXAlignment.Left; LblWallCheck.ZIndex = 4
        ToggleTrackWall = Instance.new("Frame", CardWallCheck)
        ToggleTrackWall.Name = "ToggleTrack"; ToggleTrackWall.Size = UDim2.new(0, 34, 0, 18); ToggleTrackWall.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackWall.BackgroundColor3 = Theme.Off; ToggleTrackWall.ZIndex = 4
        Instance.new("UICorner", ToggleTrackWall).CornerRadius = UDim.new(1, 0)
        ToggleKnobWall = Instance.new("Frame", ToggleTrackWall)
        ToggleKnobWall.Size = UDim2.new(0, 14, 0, 14); ToggleKnobWall.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobWall.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobWall.ZIndex = 5
        Instance.new("UICorner", ToggleKnobWall).CornerRadius = UDim.new(1, 0)

        local CardTargetingSmooth = createCard(1, 8)
        local LblTargetingSmooth = Instance.new("TextLabel", CardTargetingSmooth)
        LblTargetingSmooth.Size = UDim2.new(0, 200, 0, 34); LblTargetingSmooth.Position = UDim2.new(0, 12, 0, 0); LblTargetingSmooth.BackgroundTransparency = 1
        LblTargetingSmooth.Font = Settings.CustomFont; LblTargetingSmooth.Text = "Targeting Smoothness"; LblTargetingSmooth.TextColor3 = Theme.Text; LblTargetingSmooth.TextSize = 14; LblTargetingSmooth.TextXAlignment = Enum.TextXAlignment.Left; LblTargetingSmooth.ZIndex = 4
        TargetingSliderTrack = Instance.new("Frame", CardTargetingSmooth)
        TargetingSliderTrack.Size = UDim2.new(0, 150, 0, 14); TargetingSliderTrack.Position = UDim2.new(1, -196, 0.5, -7); TargetingSliderTrack.BackgroundColor3 = Theme.WidgetBg; TargetingSliderTrack.ZIndex = 4
        Instance.new("UICorner", TargetingSliderTrack).CornerRadius = UDim.new(1, 0)
        TargetingSliderFill = Instance.new("Frame", TargetingSliderTrack)
        TargetingSliderFill.Size = UDim2.new(Settings.TargetingSmoothness, 0, 1, 0); TargetingSliderFill.BackgroundColor3 = Theme.Accent; TargetingSliderFill.ZIndex = 5
        Instance.new("UICorner", TargetingSliderFill).CornerRadius = UDim.new(1, 0)
        TargetingSliderText = Instance.new("TextLabel", TargetingSliderTrack)
        TargetingSliderText.Size = UDim2.new(1, 0, 1, 0); TargetingSliderText.BackgroundTransparency = 1; TargetingSliderText.Font = Settings.CustomFont; TargetingSliderText.Text = math.floor(Settings.TargetingSmoothness * 100) .. "%"; TargetingSliderText.TextSize = 12; TargetingSliderText.ZIndex = 6
        ResetTargetingSmooth = Instance.new("TextButton", CardTargetingSmooth)
        ResetTargetingSmooth.Size = UDim2.new(0, 22, 0, 22); ResetTargetingSmooth.Position = UDim2.new(1, -28, 0.5, -11); ResetTargetingSmooth.BackgroundColor3 = Theme.WidgetBg; ResetTargetingSmooth.Font = Settings.CustomFont; ResetTargetingSmooth.Text = "↺"; ResetTargetingSmooth.TextColor3 = Theme.Accent; ResetTargetingSmooth.TextSize = 13; ResetTargetingSmooth.ZIndex = 4
        Instance.new("UICorner", ResetTargetingSmooth).CornerRadius = UDim.new(0, 4)
        ResetTargetingSmooth.MouseButton1Click:Connect(function()
            Settings.TargetingSmoothness = 0.50
            TweenService:Create(TargetingSliderFill, TweenInfo.new(0.3), {Size = UDim2.new(0.50, 0, 1, 0)}):Play()
            TargetingSliderText.Text = "50%"
            updateSliderTextColors()
        end)

        local CardTrackingSmooth = createCard(1, 9)
        local LblTrackingSmooth = Instance.new("TextLabel", CardTrackingSmooth)
        LblTrackingSmooth.Size = UDim2.new(0, 200, 0, 34); LblTrackingSmooth.Position = UDim2.new(0, 12, 0, 0); LblTrackingSmooth.BackgroundTransparency = 1
        LblTrackingSmooth.Font = Settings.CustomFont; LblTrackingSmooth.Text = "Tracking Smoothness"; LblTrackingSmooth.TextColor3 = Theme.Text; LblTrackingSmooth.TextSize = 14; LblTrackingSmooth.TextXAlignment = Enum.TextXAlignment.Left; LblTrackingSmooth.ZIndex = 4
        TrackingSliderTrack = Instance.new("Frame", CardTrackingSmooth)
        TrackingSliderTrack.Size = UDim2.new(0, 150, 0, 14); TrackingSliderTrack.Position = UDim2.new(1, -196, 0.5, -7); TrackingSliderTrack.BackgroundColor3 = Theme.WidgetBg; TrackingSliderTrack.ZIndex = 4
        Instance.new("UICorner", TrackingSliderTrack).CornerRadius = UDim.new(1, 0)
        TrackingSliderFill = Instance.new("Frame", TrackingSliderTrack)
        TrackingSliderFill.Size = UDim2.new(Settings.TrackingSmoothness, 0, 1, 0); TrackingSliderFill.BackgroundColor3 = Theme.Accent; TrackingSliderFill.ZIndex = 5
        Instance.new("UICorner", TrackingSliderFill).CornerRadius = UDim.new(1, 0)
        TrackingSliderText = Instance.new("TextLabel", TrackingSliderTrack)
        TrackingSliderText.Size = UDim2.new(1, 0, 1, 0); TrackingSliderText.BackgroundTransparency = 1; TrackingSliderText.Font = Settings.CustomFont; TrackingSliderText.Text = math.floor(Settings.TrackingSmoothness * 100) .. "%"; TrackingSliderText.TextSize = 12; TrackingSliderText.ZIndex = 6
        ResetTrackingSmooth = Instance.new("TextButton", CardTrackingSmooth)
        ResetTrackingSmooth.Size = UDim2.new(0, 22, 0, 22); ResetTrackingSmooth.Position = UDim2.new(1, -28, 0.5, -11); ResetTrackingSmooth.BackgroundColor3 = Theme.WidgetBg; ResetTrackingSmooth.Font = Settings.CustomFont; ResetTrackingSmooth.Text = "↺"; ResetTrackingSmooth.TextColor3 = Theme.Accent; ResetTrackingSmooth.TextSize = 13; ResetTrackingSmooth.ZIndex = 4
        Instance.new("UICorner", ResetTrackingSmooth).CornerRadius = UDim.new(0, 4)
        ResetTrackingSmooth.MouseButton1Click:Connect(function()
            Settings.TrackingSmoothness = 0.50
            TweenService:Create(TrackingSliderFill, TweenInfo.new(0.3), {Size = UDim2.new(0.50, 0, 1, 0)}):Play()
            TrackingSliderText.Text = "50%"
            updateSliderTextColors()
        end)

        local CardFOV = createCard(1, 10)
        local LblFOV = Instance.new("TextLabel", CardFOV)
        LblFOV.Size = UDim2.new(0, 200, 0, 34); LblFOV.Position = UDim2.new(0, 12, 0, 0); LblFOV.BackgroundTransparency = 1
        LblFOV.Font = Settings.CustomFont; LblFOV.Text = "Show FOV Circle"; LblFOV.TextColor3 = Theme.Text; LblFOV.TextSize = 14; LblFOV.TextXAlignment = Enum.TextXAlignment.Left; LblFOV.ZIndex = 4
        ToggleTrack3 = Instance.new("Frame", CardFOV)
        ToggleTrack3.Name = "ToggleTrack"; ToggleTrack3.Size = UDim2.new(0, 34, 0, 18); ToggleTrack3.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrack3.BackgroundColor3 = Theme.Off; ToggleTrack3.ZIndex = 4
        Instance.new("UICorner", ToggleTrack3).CornerRadius = UDim.new(1, 0)
        ToggleKnob3 = Instance.new("Frame", ToggleTrack3)
        ToggleKnob3.Size = UDim2.new(0, 14, 0, 14); ToggleKnob3.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnob3.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnob3.ZIndex = 5
        Instance.new("UICorner", ToggleKnob3).CornerRadius = UDim.new(1, 0)

        local CardFOVColor = createCard(1, 11)
        local LblFOVColor = Instance.new("TextLabel", CardFOVColor)
        LblFOVColor.Size = UDim2.new(0, 200, 0, 34); LblFOVColor.Position = UDim2.new(0, 12, 0, 0); LblFOVColor.BackgroundTransparency = 1
        LblFOVColor.Font = Settings.CustomFont; LblFOVColor.Text = "FOV Color"; LblFOVColor.TextColor3 = Theme.Text; LblFOVColor.TextSize = 14; LblFOVColor.TextXAlignment = Enum.TextXAlignment.Left; LblFOVColor.ZIndex = 4
        local fovColors = {"White", "Pink", "Red", "Cyan", "Green", "Yellow", "Purple"}
        local fovMap = {["White"] = Color3.fromRGB(255, 255, 255), ["Pink"] = Color3.fromRGB(255, 105, 180), ["Red"] = Color3.fromRGB(255, 50, 50), ["Cyan"] = Color3.fromRGB(0, 229, 255), ["Green"] = Color3.fromRGB(46, 204, 113), ["Yellow"] = Color3.fromRGB(255, 230, 0), ["Purple"] = Color3.fromRGB(180, 50, 255)}
        ValFOVColor = createDropdown(CardFOVColor, Settings.FOVColorName or "White", fovColors, function(s)
            Settings.FOVColorName = s
            Settings.FOVColor = fovMap[s] or Color3.fromRGB(255, 255, 255)
            fovCircle.Color = Settings.FOVColor
        end)

        local CardFOVOrigin = createCard(1, 12)
        local LblFOVOrigin = Instance.new("TextLabel", CardFOVOrigin)
        LblFOVOrigin.Size = UDim2.new(0, 200, 0, 34); LblFOVOrigin.Position = UDim2.new(0, 12, 0, 0); LblFOVOrigin.BackgroundTransparency = 1
        LblFOVOrigin.Font = Settings.CustomFont; LblFOVOrigin.Text = "FOV Origin"; LblFOVOrigin.TextColor3 = Theme.Text; LblFOVOrigin.TextSize = 14; LblFOVOrigin.TextXAlignment = Enum.TextXAlignment.Left; LblFOVOrigin.ZIndex = 4
        ValFOVOrigin = createDropdown(CardFOVOrigin, Settings.FOVOrigin, {"Center", "Cursor"}, function(s) Settings.FOVOrigin = s end)

        local CardFOVSlider = createCard(1, 13)
        local LblFOVSlider = Instance.new("TextLabel", CardFOVSlider)
        LblFOVSlider.Size = UDim2.new(0, 200, 0, 34); LblFOVSlider.Position = UDim2.new(0, 12, 0, 0); LblFOVSlider.BackgroundTransparency = 1
        LblFOVSlider.Font = Settings.CustomFont; LblFOVSlider.Text = "FOV Size"; LblFOVSlider.TextColor3 = Theme.Text; LblFOVSlider.TextSize = 14; LblFOVSlider.TextXAlignment = Enum.TextXAlignment.Left; LblFOVSlider.ZIndex = 4
        FOVSliderTrack = Instance.new("Frame", CardFOVSlider)
        FOVSliderTrack.Size = UDim2.new(0, 150, 0, 14); FOVSliderTrack.Position = UDim2.new(1, -196, 0.5, -7); FOVSliderTrack.BackgroundColor3 = Theme.WidgetBg; FOVSliderTrack.ZIndex = 4
        Instance.new("UICorner", FOVSliderTrack).CornerRadius = UDim.new(1, 0)
        FOVSliderFill = Instance.new("Frame", FOVSliderTrack)
        FOVSliderFill.Size = UDim2.new(Settings.FOVSize / 400, 0, 1, 0); FOVSliderFill.BackgroundColor3 = Theme.Accent; FOVSliderFill.ZIndex = 5
        Instance.new("UICorner", FOVSliderFill).CornerRadius = UDim.new(1, 0)
        FOVSliderText = Instance.new("TextLabel", FOVSliderTrack)
        FOVSliderText.Size = UDim2.new(1, 0, 1, 0); FOVSliderText.BackgroundTransparency = 1; FOVSliderText.Font = Settings.CustomFont; FOVSliderText.Text = tostring(Settings.FOVSize); FOVSliderText.TextSize = 12; FOVSliderText.ZIndex = 6
        ResetFOVSlider = Instance.new("TextButton", CardFOVSlider)
        ResetFOVSlider.Size = UDim2.new(0, 22, 0, 22); ResetFOVSlider.Position = UDim2.new(1, -28, 0.5, -11); ResetFOVSlider.BackgroundColor3 = Theme.WidgetBg; ResetFOVSlider.Font = Settings.CustomFont; ResetFOVSlider.Text = "↺"; ResetFOVSlider.TextColor3 = Theme.Accent; ResetFOVSlider.TextSize = 13; ResetFOVSlider.ZIndex = 4
        Instance.new("UICorner", ResetFOVSlider).CornerRadius = UDim.new(0, 4)
        ResetFOVSlider.MouseButton1Click:Connect(function()
            Settings.FOVSize = 100
            TweenService:Create(FOVSliderFill, TweenInfo.new(0.3), {Size = UDim2.new(100/400, 0, 1, 0)}):Play()
            FOVSliderText.Text = "100"
            fovCircle.Radius = Settings.FOVSize
            updateSliderTextColors()
        end)
    end

    local function buildTab2()
        local CardESPColor = createCard(2, 1)
        local LblESPColor = Instance.new("TextLabel", CardESPColor)
        LblESPColor.Size = UDim2.new(0, 200, 0, 34); LblESPColor.Position = UDim2.new(0, 12, 0, 0); LblESPColor.BackgroundTransparency = 1
        LblESPColor.Font = Settings.CustomFont; LblESPColor.Text = "ESP Color"; LblESPColor.TextColor3 = Theme.Text; LblESPColor.TextSize = 14; LblESPColor.TextXAlignment = Enum.TextXAlignment.Left; LblESPColor.ZIndex = 4
        local espColors = {"White", "Pink", "Red", "Cyan", "Green", "Yellow", "Purple"}
        local espMap = {["White"] = Color3.fromRGB(255, 255, 255), ["Pink"] = Color3.fromRGB(255, 105, 180), ["Red"] = Color3.fromRGB(255, 50, 50), ["Cyan"] = Color3.fromRGB(0, 229, 255), ["Green"] = Color3.fromRGB(46, 204, 113), ["Yellow"] = Color3.fromRGB(255, 230, 0), ["Purple"] = Color3.fromRGB(180, 50, 255)}
        ValESPColor = createDropdown(CardESPColor, Settings.ESPColorName or "White", espColors, function(s)
            Settings.ESPColorName = s
            Settings.ESPColor = espMap[s] or Color3.fromRGB(255, 255, 255)
        end)

        local function createESPFeatureCard(labelText, settingName, settingKeyName, order)
            local card = createCard(2, order)
            local lbl = Instance.new("TextLabel", card)
            lbl.Size = UDim2.new(0, 120, 0, 34); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
            lbl.Font = Settings.CustomFont; lbl.Text = labelText; lbl.TextColor3 = Theme.Text; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4

            local keyVal = Instance.new("TextButton", card)
            keyVal.Size = UDim2.new(0, 65, 0, 22); keyVal.Position = UDim2.new(1, -120, 0.5, -11); keyVal.BackgroundColor3 = Theme.WidgetBg; keyVal.BorderSizePixel = 0
            keyVal.Font = Settings.CustomFont; keyVal.Text = "[" .. getKeyName(Settings[settingKeyName]) .. "]"; keyVal.TextColor3 = Theme.Accent; keyVal.TextSize = 11; keyVal.ZIndex = 4
            Instance.new("UICorner", keyVal).CornerRadius = UDim.new(0, 4)

            local resetKeyBtn = Instance.new("TextButton", card)
            resetKeyBtn.Size = UDim2.new(0, 22, 0, 22); resetKeyBtn.Position = UDim2.new(1, -28, 0.5, -11); resetKeyBtn.BackgroundColor3 = Theme.WidgetBg; resetKeyBtn.BorderSizePixel = 0
            resetKeyBtn.Font = Settings.CustomFont; resetKeyBtn.Text = "↺"; resetKeyBtn.TextColor3 = Theme.Accent; resetKeyBtn.TextSize = 13; resetKeyBtn.ZIndex = 4
            Instance.new("UICorner", resetKeyBtn).CornerRadius = UDim.new(0, 4)

            resetKeyBtn.MouseButton1Click:Connect(function()
                Settings[settingKeyName] = nil
                updateUIStates()
            end)

            keyVal.MouseButton1Click:Connect(function()
                listeningForKey = settingKeyName
                ignoreNextClick = true
                updateUIStates()
            end)

            local track = Instance.new("Frame", card)
            track.Name = "ToggleTrack"
            track.Size = UDim2.new(0, 34, 0, 18); track.Position = UDim2.new(1, -162, 0.5, -9); track.BackgroundColor3 = Settings[settingName] and Theme.Accent or Theme.Off; track.ZIndex = 4
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", track)
            knob.Name = "ToggleKnob"
            knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = Settings[settingName] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.ZIndex = 5
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            return card, track, knob, keyVal
        end

        local CardTeamCheckESP
        CardTeamCheckESP, TrackTeamCheckESP, KnobTeamCheckESP = (function()
            local card = createCard(2, 2)
            local lbl = Instance.new("TextLabel", card)
            lbl.Size = UDim2.new(0, 140, 0, 34); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
            lbl.Font = Settings.CustomFont; lbl.Text = "Team Check"; lbl.TextColor3 = Theme.Text; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4
            local track = Instance.new("Frame", card)
            track.Name = "ToggleTrack"
            track.Size = UDim2.new(0, 34, 0, 18); track.Position = UDim2.new(1, -46, 0.5, -9); track.BackgroundColor3 = Settings.TeamCheckESP and Theme.Accent or Theme.Off; track.ZIndex = 4
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
            local knob = Instance.new("Frame", track)
            knob.Name = "ToggleKnob"
            knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = Settings.TeamCheckESP and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.ZIndex = 5
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            return card, track, knob
        end)()

        local CardEspHighlight
        CardEspHighlight, TrackEspHighlight, KnobEspHighlight, ValKeyEspHighlight = createESPFeatureCard("Highlight", "ESPHighlight", "KeyESPHighlight", 3)
        local CardEspHeadDot
        CardEspHeadDot, TrackEspHeadDot, KnobEspHeadDot, ValKeyEspHeadDot = createESPFeatureCard("Head Dot", "ESPHeadDot", "KeyESPHeadDot", 4)
        local CardEspBox
        CardEspBox, TrackEspBox, KnobEspBox, ValKeyEspBox = createESPFeatureCard("ESP Boxes", "ESPBox", "KeyESPBox", 5)
        local CardEspName
        CardEspName, TrackEspName, KnobEspName, ValKeyEspName = createESPFeatureCard("ESP Names", "ESPName", "KeyESPName", 6)
        local CardEspHealth
        CardEspHealth, TrackEspHealth, KnobEspHealth, ValKeyEspHealth = createESPFeatureCard("ESP Health", "ESPHealth", "KeyESPHealth", 7)
        local CardEspSkeleton
        CardEspSkeleton, TrackEspSkeleton, KnobEspSkeleton, ValKeyEspSkeleton = createESPFeatureCard("ESP Skeleton", "ESPSkeleton", "KeyESPSkeleton", 8)
        local CardEspTracers
        CardEspTracers, TrackEspTracers, KnobEspTracers, ValKeyEspTracers = createESPFeatureCard("ESP Tracers", "ESPTracers", "KeyESPTracers", 9)
    end

    local function buildTab3()
        local CardTpOffset = createCard(3, 1)
        local LblTpOffset = Instance.new("TextLabel", CardTpOffset)
        LblTpOffset.Size = UDim2.new(0, 200, 0, 34); LblTpOffset.Position = UDim2.new(0, 12, 0, 0); LblTpOffset.BackgroundTransparency = 1
        LblTpOffset.Font = Settings.CustomFont; LblTpOffset.Text = "Teleport Position"; LblTpOffset.TextColor3 = Theme.Text; LblTpOffset.TextSize = 14; LblTpOffset.TextXAlignment = Enum.TextXAlignment.Left; LblTpOffset.ZIndex = 4
        ValTpOffset = createDropdown(CardTpOffset, Settings.TeleportOffset, {"In Front", "On Top", "Behind", "Inside"}, function(s) Settings.TeleportOffset = s end)

        local CardTpNearest = createCard(3, 2)
        BtnTpNearest = Instance.new("TextButton", CardTpNearest)
        BtnTpNearest.Size = UDim2.new(1, -24, 0, 26); BtnTpNearest.Position = UDim2.new(0, 12, 0.5, -13); BtnTpNearest.BackgroundColor3 = Theme.WidgetBg; BtnTpNearest.Font = Settings.CustomFont; BtnTpNearest.Text = "Teleport To Nearest Player"; BtnTpNearest.TextColor3 = Theme.Accent; BtnTpNearest.TextSize = 13; BtnTpNearest.ZIndex = 4
        Instance.new("UICorner", BtnTpNearest).CornerRadius = UDim.new(0, 5)

        local CardTpPlayer = createCard(3, 3)
        local LblTpPlayer = Instance.new("TextLabel", CardTpPlayer)
        LblTpPlayer.Size = UDim2.new(0, 150, 0, 34); LblTpPlayer.Position = UDim2.new(0, 12, 0, 0); LblTpPlayer.BackgroundTransparency = 1
        LblTpPlayer.Font = Settings.CustomFont; LblTpPlayer.Text = "Select Player"; LblTpPlayer.TextColor3 = Theme.Text; LblTpPlayer.TextSize = 14; LblTpPlayer.TextXAlignment = Enum.TextXAlignment.Left; LblTpPlayer.ZIndex = 4

        local function getPlayerNames()
            local names = {}
            for _, p in ipairs(Players:GetPlayers()) do if p ~= Player then table.insert(names, p.Name) end end
            if #names == 0 then table.insert(names, "None") end
            return names
        end
        ValTpPlayer = createDropdown(CardTpPlayer, "None", getPlayerNames(), function(s)
            local target = Players:FindFirstChild(s)
            if target then Settings.SelectedTeleportTarget = target end
        end)

        local CardTpExecute = createCard(3, 4)
        BtnTpExecute = Instance.new("TextButton", CardTpExecute)
        BtnTpExecute.Size = UDim2.new(1, -24, 0, 26); BtnTpExecute.Position = UDim2.new(0, 12, 0.5, -13); BtnTpExecute.BackgroundColor3 = Theme.WidgetBg; BtnTpExecute.Font = Settings.CustomFont; BtnTpExecute.Text = "Teleport To Selected Player"; BtnTpExecute.TextColor3 = Theme.Accent; BtnTpExecute.TextSize = 13; BtnTpExecute.ZIndex = 4
        Instance.new("UICorner", BtnTpExecute).CornerRadius = UDim.new(0, 5)

        executeTeleport = function(targetPlayer)
            if not targetPlayer or not targetPlayer.Character then return end
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                local targetCFrame = targetHRP.CFrame
                if Settings.TeleportOffset == "In Front" then myHRP.CFrame = targetCFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0)
                elseif Settings.TeleportOffset == "On Top" then myHRP.CFrame = targetCFrame * CFrame.new(0, 5, 0)
                elseif Settings.TeleportOffset == "Behind" then myHRP.CFrame = targetCFrame * CFrame.new(0, 0, 4)
                elseif Settings.TeleportOffset == "Inside" then myHRP.CFrame = targetCFrame end
            end
        end

        BtnTpNearest.MouseButton1Click:Connect(function()
            local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local closest, closestDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                    if dist < closestDist then closestDist = dist; closest = p end
                end
            end
            if closest then executeTeleport(closest) end
        end)
        BtnTpExecute.MouseButton1Click:Connect(function() if Settings.SelectedTeleportTarget then executeTeleport(Settings.SelectedTeleportTarget) end end)
    end

    local function buildTab4()
        local CardFly = createCard(4, 1)
        local LblFly = Instance.new("TextLabel", CardFly)
        LblFly.Size = UDim2.new(0, 200, 0, 34); LblFly.Position = UDim2.new(0, 12, 0, 0); LblFly.BackgroundTransparency = 1
        LblFly.Font = Settings.CustomFont; LblFly.Text = "Fly Mode"; LblFly.TextColor3 = Theme.Text; LblFly.TextSize = 14; LblFly.TextXAlignment = Enum.TextXAlignment.Left; LblFly.ZIndex = 4
        ToggleTrackFly = Instance.new("Frame", CardFly)
        ToggleTrackFly.Name = "ToggleTrack"; ToggleTrackFly.Size = UDim2.new(0, 34, 0, 18); ToggleTrackFly.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackFly.BackgroundColor3 = Theme.Off; ToggleTrackFly.ZIndex = 4
        Instance.new("UICorner", ToggleTrackFly).CornerRadius = UDim.new(1, 0)
        ToggleKnobFly = Instance.new("Frame", ToggleTrackFly)
        ToggleKnobFly.Size = UDim2.new(0, 14, 0, 14); ToggleKnobFly.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobFly.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobFly.ZIndex = 5
        Instance.new("UICorner", ToggleKnobFly).CornerRadius = UDim.new(1, 0)

        local CardFlyNoClip = createCard(4, 2)
        local LblFlyNoClip = Instance.new("TextLabel", CardFlyNoClip)
        LblFlyNoClip.Size = UDim2.new(0, 200, 0, 34); LblFlyNoClip.Position = UDim2.new(0, 12, 0, 0); LblFlyNoClip.BackgroundTransparency = 1
        LblFlyNoClip.Font = Settings.CustomFont; LblFlyNoClip.Text = "Fly NoClip"; LblFlyNoClip.TextColor3 = Theme.Text; LblFlyNoClip.TextSize = 14; LblFlyNoClip.TextXAlignment = Enum.TextXAlignment.Left; LblFlyNoClip.ZIndex = 4
        ToggleTrackFlyNoClip = Instance.new("Frame", CardFlyNoClip)
        ToggleTrackFlyNoClip.Name = "ToggleTrack"; ToggleTrackFlyNoClip.Size = UDim2.new(0, 34, 0, 18); ToggleTrackFlyNoClip.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackFlyNoClip.BackgroundColor3 = Theme.Off; ToggleTrackFlyNoClip.ZIndex = 4
        Instance.new("UICorner", ToggleTrackFlyNoClip).CornerRadius = UDim.new(1, 0)
        ToggleKnobFlyNoClip = Instance.new("Frame", ToggleTrackFlyNoClip)
        ToggleKnobFlyNoClip.Size = UDim2.new(0, 14, 0, 14); ToggleKnobFlyNoClip.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobFlyNoClip.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobFlyNoClip.ZIndex = 5
        Instance.new("UICorner", ToggleKnobFlyNoClip).CornerRadius = UDim.new(1, 0)

        local CardFlySpeed = createCard(4, 3)
        local LblFlySpeed = Instance.new("TextLabel", CardFlySpeed)
        LblFlySpeed.Size = UDim2.new(0, 200, 0, 34); LblFlySpeed.Position = UDim2.new(0, 12, 0, 0); LblFlySpeed.BackgroundTransparency = 1
        LblFlySpeed.Font = Settings.CustomFont; LblFlySpeed.Text = "Fly Speed"; LblFlySpeed.TextColor3 = Theme.Text; LblFlySpeed.TextSize = 14; LblFlySpeed.TextXAlignment = Enum.TextXAlignment.Left; LblFlySpeed.ZIndex = 4
        FlySpeedTrack = Instance.new("Frame", CardFlySpeed)
        FlySpeedTrack.Size = UDim2.new(0, 150, 0, 14); FlySpeedTrack.Position = UDim2.new(1, -196, 0.5, -7); FlySpeedTrack.BackgroundColor3 = Theme.WidgetBg; FlySpeedTrack.ZIndex = 4
        Instance.new("UICorner", FlySpeedTrack).CornerRadius = UDim.new(1, 0)
        FlySpeedFill = Instance.new("Frame", FlySpeedTrack)
        FlySpeedFill.Size = UDim2.new((Settings.FlySpeed - 10) / 290, 0, 1, 0); FlySpeedFill.BackgroundColor3 = Theme.Accent; FlySpeedFill.ZIndex = 5
        Instance.new("UICorner", FlySpeedFill).CornerRadius = UDim.new(1, 0)
        FlySpeedText = Instance.new("TextLabel", FlySpeedTrack)
        FlySpeedText.Size = UDim2.new(1, 0, 1, 0); FlySpeedText.BackgroundTransparency = 1; FlySpeedText.Font = Settings.CustomFont; FlySpeedText.Text = tostring(Settings.FlySpeed); FlySpeedText.TextSize = 12; FlySpeedText.ZIndex = 6
        ResetFlySpeed = Instance.new("TextButton", CardFlySpeed)
        ResetFlySpeed.Size = UDim2.new(0, 22, 0, 22); ResetFlySpeed.Position = UDim2.new(1, -28, 0.5, -11); ResetFlySpeed.BackgroundColor3 = Theme.WidgetBg; ResetFlySpeed.Font = Settings.CustomFont; ResetFlySpeed.Text = "↺"; ResetFlySpeed.TextColor3 = Theme.Accent; ResetFlySpeed.TextSize = 13; ResetFlySpeed.ZIndex = 4
        Instance.new("UICorner", ResetFlySpeed).CornerRadius = UDim.new(0, 4)
        ResetFlySpeed.MouseButton1Click:Connect(function()
            Settings.FlySpeed = 50
            TweenService:Create(FlySpeedFill, TweenInfo.new(0.3), {Size = UDim2.new((Settings.FlySpeed - 10) / 290, 0, 1, 0)}):Play()
            FlySpeedText.Text = "50"
            updateSliderTextColors()
        end)

        local CardWalkSpeed = createCard(4, 4)
        local LblWalkSpeed = Instance.new("TextLabel", CardWalkSpeed)
        LblWalkSpeed.Size = UDim2.new(0, 200, 0, 34); LblWalkSpeed.Position = UDim2.new(0, 12, 0, 0); LblWalkSpeed.BackgroundTransparency = 1
        LblWalkSpeed.Font = Settings.CustomFont; LblWalkSpeed.Text = "WalkSpeed"; LblWalkSpeed.TextColor3 = Theme.Text; LblWalkSpeed.TextSize = 14; LblWalkSpeed.TextXAlignment = Enum.TextXAlignment.Left; LblWalkSpeed.ZIndex = 4
        WalkSpeedTrack = Instance.new("Frame", CardWalkSpeed)
        WalkSpeedTrack.Size = UDim2.new(0, 150, 0, 14); WalkSpeedTrack.Position = UDim2.new(1, -196, 0.5, -7); WalkSpeedTrack.BackgroundColor3 = Theme.WidgetBg; WalkSpeedTrack.ZIndex = 4
        Instance.new("UICorner", WalkSpeedTrack).CornerRadius = UDim.new(1, 0)
        WalkSpeedFill = Instance.new("Frame", WalkSpeedTrack)
        WalkSpeedFill.Size = UDim2.new((Settings.WalkSpeed - 16) / 184, 0, 1, 0); WalkSpeedFill.BackgroundColor3 = Theme.Accent; WalkSpeedFill.ZIndex = 5
        Instance.new("UICorner", WalkSpeedFill).CornerRadius = UDim.new(1, 0)
        WalkSpeedText = Instance.new("TextLabel", WalkSpeedTrack)
        WalkSpeedText.Size = UDim2.new(1, 0, 1, 0); WalkSpeedText.BackgroundTransparency = 1; WalkSpeedText.Font = Settings.CustomFont; WalkSpeedText.Text = tostring(Settings.WalkSpeed); WalkSpeedText.TextSize = 12; WalkSpeedText.ZIndex = 6
        ResetWalkSpeed = Instance.new("TextButton", CardWalkSpeed)
        ResetWalkSpeed.Size = UDim2.new(0, 22, 0, 22); ResetWalkSpeed.Position = UDim2.new(1, -28, 0.5, -11); ResetWalkSpeed.BackgroundColor3 = Theme.WidgetBg; ResetWalkSpeed.Font = Settings.CustomFont; ResetWalkSpeed.Text = "↺"; ResetWalkSpeed.TextColor3 = Theme.Accent; ResetWalkSpeed.TextSize = 13; ResetWalkSpeed.ZIndex = 4
        Instance.new("UICorner", ResetWalkSpeed).CornerRadius = UDim.new(0, 4)
        ResetWalkSpeed.MouseButton1Click:Connect(function()
            Settings.WalkSpeed = 16
            TweenService:Create(WalkSpeedFill, TweenInfo.new(0.3), {Size = UDim2.new((Settings.WalkSpeed - 16) / 184, 0, 1, 0)}):Play()
            WalkSpeedText.Text = "16"
            updateSliderTextColors()
        end)

        local CardJumpPower = createCard(4, 5)
        local LblJumpPower = Instance.new("TextLabel", CardJumpPower)
        LblJumpPower.Size = UDim2.new(0, 200, 0, 34); LblJumpPower.Position = UDim2.new(0, 12, 0, 0); LblJumpPower.BackgroundTransparency = 1
        LblJumpPower.Font = Settings.CustomFont; LblJumpPower.Text = "JumpPower"; LblJumpPower.TextColor3 = Theme.Text; LblJumpPower.TextSize = 14; LblJumpPower.TextXAlignment = Enum.TextXAlignment.Left; LblJumpPower.ZIndex = 4
        JumpPowerTrack = Instance.new("Frame", CardJumpPower)
        JumpPowerTrack.Size = UDim2.new(0, 150, 0, 14); JumpPowerTrack.Position = UDim2.new(1, -196, 0.5, -7); JumpPowerTrack.BackgroundColor3 = Theme.WidgetBg; JumpPowerTrack.ZIndex = 4
        Instance.new("UICorner", JumpPowerTrack).CornerRadius = UDim.new(1, 0)
        JumpPowerFill = Instance.new("Frame", JumpPowerTrack)
        JumpPowerFill.Size = UDim2.new((Settings.JumpPower - 50) / 200, 0, 1, 0); JumpPowerFill.BackgroundColor3 = Theme.Accent; JumpPowerFill.ZIndex = 5
        Instance.new("UICorner", JumpPowerFill).CornerRadius = UDim.new(1, 0)
        JumpPowerText = Instance.new("TextLabel", JumpPowerTrack)
        JumpPowerText.Size = UDim2.new(1, 0, 1, 0); JumpPowerText.BackgroundTransparency = 1; JumpPowerText.Font = Settings.CustomFont; JumpPowerText.Text = tostring(Settings.JumpPower); JumpPowerText.TextSize = 12; JumpPowerText.ZIndex = 6
        ResetJumpPower = Instance.new("TextButton", CardJumpPower)
        ResetJumpPower.Size = UDim2.new(0, 22, 0, 22); ResetJumpPower.Position = UDim2.new(1, -28, 0.5, -11); ResetJumpPower.BackgroundColor3 = Theme.WidgetBg; ResetJumpPower.Font = Settings.CustomFont; ResetJumpPower.Text = "↺"; ResetJumpPower.TextColor3 = Theme.Accent; ResetJumpPower.TextSize = 13; ResetJumpPower.ZIndex = 4
        Instance.new("UICorner", ResetJumpPower).CornerRadius = UDim.new(0, 4)
        ResetJumpPower.MouseButton1Click:Connect(function()
            Settings.JumpPower = 50
            TweenService:Create(JumpPowerFill, TweenInfo.new(0.3), {Size = UDim2.new((Settings.JumpPower - 50) / 200, 0, 1, 0)}):Play()
            JumpPowerText.Text = "50"
            updateSliderTextColors()
        end)

        local CardInfJump = createCard(4, 6)
        local LblInfJump = Instance.new("TextLabel", CardInfJump)
        LblInfJump.Size = UDim2.new(0, 200, 0, 34); LblInfJump.Position = UDim2.new(0, 12, 0, 0); LblInfJump.BackgroundTransparency = 1
        LblInfJump.Font = Settings.CustomFont; LblInfJump.Text = "Infinite Jump"; LblInfJump.TextColor3 = Theme.Text; LblInfJump.TextSize = 14; LblInfJump.TextXAlignment = Enum.TextXAlignment.Left; LblInfJump.ZIndex = 4
        ToggleTrackInfJump = Instance.new("Frame", CardInfJump)
        ToggleTrackInfJump.Name = "ToggleTrack"; ToggleTrackInfJump.Size = UDim2.new(0, 34, 0, 18); ToggleTrackInfJump.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackInfJump.BackgroundColor3 = Theme.Off; ToggleTrackInfJump.ZIndex = 4
        Instance.new("UICorner", ToggleTrackInfJump).CornerRadius = UDim.new(1, 0)
        ToggleKnobInfJump = Instance.new("Frame", ToggleTrackInfJump)
        ToggleKnobInfJump.Size = UDim2.new(0, 14, 0, 14); ToggleKnobInfJump.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobInfJump.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobInfJump.ZIndex = 5
        Instance.new("UICorner", ToggleKnobInfJump).CornerRadius = UDim.new(1, 0)
    end

    local function buildTab5()
        local CardShowKeybindsHud = createCard(5, 1)
        local LblShowKeybindsHud = Instance.new("TextLabel", CardShowKeybindsHud)
        LblShowKeybindsHud.Size = UDim2.new(0, 200, 0, 34); LblShowKeybindsHud.Position = UDim2.new(0, 12, 0, 0); LblShowKeybindsHud.BackgroundTransparency = 1
        LblShowKeybindsHud.Font = Settings.CustomFont; LblShowKeybindsHud.Text = "Show Keybinds HUD"; LblShowKeybindsHud.TextColor3 = Theme.Text; LblShowKeybindsHud.TextSize = 14; LblShowKeybindsHud.TextXAlignment = Enum.TextXAlignment.Left; LblShowKeybindsHud.ZIndex = 4
        ToggleTrackKeybindsHud = Instance.new("Frame", CardShowKeybindsHud)
        ToggleTrackKeybindsHud.Name = "ToggleTrack"; ToggleTrackKeybindsHud.Size = UDim2.new(0, 34, 0, 18); ToggleTrackKeybindsHud.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackKeybindsHud.BackgroundColor3 = Theme.Off; ToggleTrackKeybindsHud.ZIndex = 4
        Instance.new("UICorner", ToggleTrackKeybindsHud).CornerRadius = UDim.new(1, 0)
        ToggleKnobKeybindsHud = Instance.new("Frame", ToggleTrackKeybindsHud)
        ToggleKnobKeybindsHud.Size = UDim2.new(0, 14, 0, 14); ToggleKnobKeybindsHud.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobKeybindsHud.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobKeybindsHud.ZIndex = 5
        Instance.new("UICorner", ToggleKnobKeybindsHud).CornerRadius = UDim.new(1, 0)

        local function createKeybindCardLocal(labelText, settingKey, order)
            local card = createCard(5, order)
            local lbl = Instance.new("TextLabel", card)
            lbl.Size = UDim2.new(0, 180, 0, 34); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
            lbl.Font = Settings.CustomFont; lbl.Text = labelText; lbl.TextColor3 = Theme.Text; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4
            local val = Instance.new("TextButton", card)
            val.Size = UDim2.new(0, 75, 0, 22); val.Position = UDim2.new(1, -60, 0.5, -11); val.BackgroundColor3 = Theme.WidgetBg; val.Font = Settings.CustomFont; val.Text = "[" .. getKeyName(Settings[settingKey]) .. "]"; val.TextColor3 = Theme.Accent; val.TextSize = 11; val.ZIndex = 4
            Instance.new("UICorner", val).CornerRadius = UDim.new(0, 4)
            local resetBtn = Instance.new("TextButton", card)
            resetBtn.Size = UDim2.new(0, 22, 0, 22); resetBtn.Position = UDim2.new(1, -88, 0.5, -11); resetBtn.BackgroundColor3 = Theme.WidgetBg; resetBtn.Font = Settings.CustomFont; resetBtn.Text = "↺"; resetBtn.TextColor3 = Theme.Accent; resetBtn.TextSize = 13; resetBtn.ZIndex = 4
            Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)
            resetBtn.MouseButton1Click:Connect(function() Settings[settingKey] = nil; updateUIStates() end)
            val.MouseButton1Click:Connect(function() listeningForKey = settingKey; ignoreNextClick = true; updateUIStates() end)
            return card, val
        end

        local CardKeyAimbot; CardKeyAimbot, ValKeyAimbot = createKeybindCardLocal("Aimbot", "KeyAimbot", 2)
        local CardKeyFly; CardKeyFly, ValKeyFly = createKeybindCardLocal("Fly", "KeyFly", 3)
        local CardKeyMenu; CardKeyMenu, ValKeyMenu = createKeybindCardLocal("Menu Toggle", "KeyToggleMenu", 4)
        local CardClickTp; CardClickTp, ValKeyClickTeleport = createKeybindCardLocal("Click Teleport", "KeyClickTeleport", 5)
        local CardUnload; CardUnload, ValKeyUnload = createKeybindCardLocal("Unload", "KeyUnload", 6)
    end

    local function buildTab6()
        local CardTheme = createCard(6, 1)
        local LblTheme = Instance.new("TextLabel", CardTheme)
        LblTheme.Size = UDim2.new(0, 200, 0, 34); LblTheme.Position = UDim2.new(0, 12, 0, 0); LblTheme.BackgroundTransparency = 1
        LblTheme.Font = Settings.CustomFont; LblTheme.Text = "Theme"; LblTheme.TextColor3 = Theme.Text; LblTheme.TextSize = 14; LblTheme.TextXAlignment = Enum.TextXAlignment.Left; LblTheme.ZIndex = 4
        ValTheme = createDropdown(CardTheme, Settings.CurrentTheme, {"Bubblegum Pink", "Neon Red", "Cyber Cyan", "Emerald Green", "Frost"}, function(selected)
            Settings.CurrentTheme = selected
            Theme = Themes[selected] or Themes["Bubblegum Pink"]
            applyThemeColors()
            updateUIStates()
        end)
    end

    buildTab1()
    buildTab2()
    buildTab3()
    buildTab4()
    buildTab5()
    buildTab6()
end

buildAllTabs()

-- ============================================================
-- 5. LOGIC & RENDER LOOP
-- ============================================================
local function setupUIAndTheme()
    applyThemeColors = function()
        MainFrame.BackgroundColor3 = Theme.Bg
        Title.TextColor3 = Theme.Text
        ResizeHandle.TextColor3 = Theme.SubText
        for i, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = (i == currentTab) and Theme.TabActive or Theme.TabInactive
            btn.TextColor3 = (i == currentTab) and Theme.Text or Theme.SubText
        end
        for _, scroller in ipairs(tabContainers) do
            scroller.ScrollBarImageColor3 = Theme.Accent
            for _, card in ipairs(scroller:GetChildren()) do
                if card:IsA("Frame") then
                    card.BackgroundColor3 = Theme.Card
                    for _, obj in ipairs(card:GetDescendants()) do
                        if obj:IsA("TextLabel") then
                            if obj ~= TargetingSliderText and obj ~= TrackingSliderText and obj ~= TriggerDelayText and obj ~= FOVSliderText and obj ~= FlySpeedText and obj ~= WalkSpeedText and obj ~= JumpPowerText then
                                obj.TextColor3 = Theme.Text
                            end
                        elseif obj:IsA("TextButton") then
                            obj.BackgroundColor3 = Theme.WidgetBg
                            obj.TextColor3 = Theme.Accent
                        elseif obj:IsA("Frame") then
                            if obj.Name == "ToggleTrack" then
                                local state = (obj.BackgroundColor3 ~= Theme.Off)
                                obj.BackgroundColor3 = state and Theme.Accent or Theme.Off
                            elseif obj == TargetingSliderFill or obj == TrackingSliderFill or obj == TriggerDelayFill or obj == FOVSliderFill or obj == FlySpeedFill or obj == WalkSpeedFill or obj == JumpPowerFill then
                                obj.BackgroundColor3 = Theme.Accent
                            elseif obj ~= MainFrame then
                                if obj.BackgroundColor3 ~= Theme.Accent then obj.BackgroundColor3 = Theme.WidgetBg end
                            end
                        end
                    end
                end
            end
        end
        KeybindsHud.BackgroundColor3 = Theme.Card
        for _, child in ipairs(KeybindsHud:GetChildren()) do
            if child:IsA("TextLabel") and child ~= HudStatusAimbot and child ~= HudStatusFly and child ~= HudStatusMenu then
                child.TextColor3 = Theme.SubText
            end
        end
        HudStatusMenu.TextColor3 = menuVisible and Theme.Accent or Color3.fromRGB(239, 68, 68)
        for _, dd in ipairs(allDropdowns) do
            dd.btn.BackgroundColor3 = Theme.WidgetBg
            dd.btn.TextColor3 = Theme.Accent
            dd.list.BackgroundColor3 = Theme.Bg
            if dd.sep then dd.sep.BackgroundColor3 = Theme.Off end
            if dd.closeBtn then dd.closeBtn.TextColor3 = Theme.Accent end
            for _, child in ipairs(dd.list:GetChildren()) do
                if child:IsA("TextButton") and child ~= dd.closeBtn then child.TextColor3 = Theme.Text end
            end
        end
        updateSliderTextColors()
    end

    local fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 60
    fovCircle.Radius = Settings.FOVSize
    fovCircle.Color = Settings.FOVColor
    fovCircle.Transparency = 0.7
    fovCircle.Visible = false
    fovCircle.Filled = false

    local espDrawings = {}
    local function createDrawingESP(player)
        if espDrawings[player] then return end
        local d = {
            BoxOutline = Drawing.new("Square"), Box = Drawing.new("Square"), Name = Drawing.new("Text"),
            HealthBarBackground = Drawing.new("Line"), HealthBar = Drawing.new("Line"), Tracer = Drawing.new("Line"),
            HeadDot = Drawing.new("Circle"), Skeleton = {}, Highlight = Instance.new("Highlight")
        }
        d.BoxOutline.Thickness = 3; d.BoxOutline.Filled = false; d.BoxOutline.Color = Color3.fromRGB(0, 0, 0); d.BoxOutline.Visible = false
        d.Box.Thickness = 1.5; d.Box.Filled = false; d.Box.Visible = false
        d.Name.Size = 13; d.Name.Center = true; d.Name.Outline = true; d.Name.Visible = false
        d.HealthBarBackground.Thickness = 4; d.HealthBarBackground.Color = Color3.fromRGB(0, 0, 0); d.HealthBarBackground.Visible = false
        d.HealthBar.Thickness = 2; d.HealthBar.Visible = false
        d.Tracer.Thickness = 1.5; d.Tracer.Visible = false
        d.HeadDot.Thickness = 1.5; d.HeadDot.Radius = 4; d.HeadDot.Filled = true; d.HeadDot.Visible = false
        d.Highlight.FillTransparency = 0.5; d.Highlight.OutlineTransparency = 0; d.Highlight.Enabled = false
        for i = 1, 16 do local line = Drawing.new("Line"); line.Thickness = 1.5; line.Visible = false; table.insert(d.Skeleton, line) end
        espDrawings[player] = d
    end

    local function removeDrawingESP(player)
        if espDrawings[player] then
            for name, obj in pairs(espDrawings[player]) do
                if type(obj) == "table" then for _, line in ipairs(obj) do pcall(function() line:Remove() end) end
                elseif name == "Highlight" then pcall(function() obj:Destroy() end)
                else pcall(function() obj:Remove() end) end
            end
            espDrawings[player] = nil
        end
    end

    for _, p in pairs(Players:GetPlayers()) do if p ~= Player then createDrawingESP(p) end end
    Players.PlayerAdded:Connect(createDrawingESP)
    Players.PlayerRemoving:Connect(removeDrawingESP)

    local menuVisible = true
    updateSliderTextColors = function()
        local function contrastColor(fillFraction) if fillFraction >= 0.5 then return Color3.fromRGB(20, 20, 20) else return Theme.Text end end
        TargetingSliderText.TextColor3 = contrastColor(Settings.TargetingSmoothness)
        TrackingSliderText.TextColor3 = contrastColor(Settings.TrackingSmoothness)
        TriggerDelayText.TextColor3 = contrastColor(Settings.TriggerbotDelay / 1.0)
        FOVSliderText.TextColor3 = contrastColor(Settings.FOVSize / 400)
        FlySpeedText.TextColor3 = contrastColor((Settings.FlySpeed - 10) / 290)
        WalkSpeedText.TextColor3 = contrastColor((Settings.WalkSpeed - 16) / 184)
        JumpPowerText.TextColor3 = contrastColor((Settings.JumpPower - 50) / 200)
    end

    switchTab = function(tabIndex)
        closeActiveDropdown()
        currentTab = tabIndex
        for i, scroller in ipairs(tabContainers) do
            local isSelected = (i == tabIndex and menuVisible)
            scroller.Visible = isSelected
            if isSelected then
                task.defer(function()
                    local layout = scroller:FindFirstChildOfClass("UIListLayout")
                    if layout then scroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20) end
                end)
            end
        end
        for i, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = (i == currentTab) and Theme.TabActive or Theme.TabInactive
            btn.TextColor3 = (i == currentTab) and Theme.Text or Theme.SubText
        end
    end

    local function setVisibility(state)
        closeActiveDropdown()
        MainFrame.Visible = state
        switchTab(currentTab)
        UserInputService.MouseIconEnabled = true
    end

    local function setToggleStateAnimated(track, knob, state)
        TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.Off}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
    end

    updateUIStates = function()
        setToggleStateAnimated(ToggleTrack1, ToggleKnob1, Settings.AimbotEnabled)
        setToggleStateAnimated(ToggleTrackTrigger, ToggleKnobTrigger, Settings.TriggerbotEnabled)
        setToggleStateAnimated(ToggleTrackTeamCheck, ToggleKnobTeamCheck, Settings.TeamCheck)
        setToggleStateAnimated(ToggleTrackWall, ToggleKnobWall, Settings.WallCheck)
        setToggleStateAnimated(ToggleTrack3, ToggleKnob3, Settings.ShowFOV)
        setToggleStateAnimated(TrackTeamCheckESP, KnobTeamCheckESP, Settings.TeamCheckESP)
        setToggleStateAnimated(TrackEspHighlight, KnobEspHighlight, Settings.ESPHighlight)
        setToggleStateAnimated(TrackEspHeadDot, KnobEspHeadDot, Settings.ESPHeadDot)
        setToggleStateAnimated(TrackEspBox, KnobEspBox, Settings.ESPBox)
        setToggleStateAnimated(TrackEspName, KnobEspName, Settings.ESPName)
        setToggleStateAnimated(TrackEspHealth, KnobEspHealth, Settings.ESPHealth)
        setToggleStateAnimated(TrackEspSkeleton, KnobEspSkeleton, Settings.ESPSkeleton)
        setToggleStateAnimated(TrackEspTracers, KnobEspTracers, Settings.ESPTracers)
        setToggleStateAnimated(ToggleTrackFly, ToggleKnobFly, Settings.FlyActive)
        setToggleStateAnimated(ToggleTrackFlyNoClip, ToggleKnobFlyNoClip, Settings.FlyNoClip)
        setToggleStateAnimated(ToggleTrackInfJump, ToggleKnobInfJump, Settings.InfJump)
        setToggleStateAnimated(ToggleTrackKeybindsHud, ToggleKnobKeybindsHud, Settings.ShowKeybindsHud)
        KeybindsHud.Visible = Settings.ShowKeybindsHud

        ValKeyAimbot.Text = "[" .. (listeningForKey == "KeyAimbot" and "..." or getKeyName(Settings.KeyAimbot)) .. "]"
        ValKeyFly.Text = "[" .. (listeningForKey == "KeyFly" and "..." or getKeyName(Settings.KeyFly)) .. "]"
        ValKeyMenu.Text = "[" .. (listeningForKey == "KeyToggleMenu" and "..." or getKeyName(Settings.KeyToggleMenu)) .. "]"
        ValKeyClickTeleport.Text = "[" .. (listeningForKey == "KeyClickTeleport" and "..." or getKeyName(Settings.KeyClickTeleport)) .. "]"
        ValKeyUnload.Text = "[" .. (listeningForKey == "KeyUnload" and "..." or getKeyName(Settings.KeyUnload)) .. "]"

        if ValKeyEspHighlight then ValKeyEspHighlight.Text = "[" .. (listeningForKey == "KeyESPHighlight" and "..." or getKeyName(Settings.KeyESPHighlight)) .. "]" end
        if ValKeyEspHeadDot then ValKeyEspHeadDot.Text = "[" .. (listeningForKey == "KeyESPHeadDot" and "..." or getKeyName(Settings.KeyESPHeadDot)) .. "]" end
        if ValKeyEspBox then ValKeyEspBox.Text = "[" .. (listeningForKey == "KeyESPBox" and "..." or getKeyName(Settings.KeyESPBox)) .. "]" end
        if ValKeyEspName then ValKeyEspName.Text = "[" .. (listeningForKey == "KeyESPName" and "..." or getKeyName(Settings.KeyESPName)) .. "]" end
        if ValKeyEspHealth then ValKeyEspHealth.Text = "[" .. (listeningForKey == "KeyESPHealth" and "..." or getKeyName(Settings.KeyESPHealth)) .. "]" end
        if ValKeyEspSkeleton then ValKeyEspSkeleton.Text = "[" .. (listeningForKey == "KeyESPSkeleton" and "..." or getKeyName(Settings.KeyESPSkeleton)) .. "]" end
        if ValKeyEspTracers then ValKeyEspTracers.Text = "[" .. (listeningForKey == "KeyESPTracers" and "..." or getKeyName(Settings.KeyESPTracers)) .. "]" end

        HudRowAimbot.Text = "Aimbot [" .. getKeyName(Settings.KeyAimbot) .. "]"
        HudRowFly.Text = "Fly [" .. getKeyName(Settings.KeyFly) .. "]"
        HudRowMenu.Text = "Menu [" .. getKeyName(Settings.KeyToggleMenu) .. "]"
        HudStatusUnload.Text = "Press " .. getKeyName(Settings.KeyUnload) .. " to Unload"

        local isAimbotActive = (Settings.AimbotMode == "Hold") and isAimbotHeld or Settings.AimbotEnabled
        HudStatusAimbot.Text = isAimbotActive and "ON" or "OFF"
        HudStatusAimbot.TextColor3 = isAimbotActive and Theme.Accent or Color3.fromRGB(239, 68, 68)
        HudStatusFly.Text = Settings.FlyActive and "ON" or "OFF"
        HudStatusFly.TextColor3 = Settings.FlyActive and Theme.Accent or Color3.fromRGB(239, 68, 68)
        HudStatusMenu.Text = menuVisible and "ON" or "OFF"
        HudStatusMenu.TextColor3 = menuVisible and Theme.Accent or Color3.fromRGB(239, 68, 68)
    end

    local function unloadHub()
        saveSettings()
        closeActiveDropdown()
        if isShooting then pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end); isShooting = false end
        for _, conn in ipairs(connections) do conn:Disconnect() end
        pcall(function() fovCircle:Remove() end)
        for p, _ in pairs(espDrawings) do removeDrawingESP(p) end
        ScreenGui:Destroy()
        UserInputService.MouseIconEnabled = true
        local char = Player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false; pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
    end

    local draggingMain = false; local dragStartMain, startPosMain
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeActiveDropdown(); draggingMain = true; dragStartMain = input.Position; startPosMain = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end)
        end
    end)

    local draggingHud = false; local dragStartHud, startPosHud
    KeybindsHud.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeActiveDropdown(); draggingHud = true; dragStartHud = input.Position; startPosHud = KeybindsHud.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingHud = false end end)
        end
    end)

    local resizingMain = false; local resizeStartPos, startSizeMain
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeActiveDropdown(); resizingMain = true; resizeStartPos = input.Position; startSizeMain = MainFrame.AbsoluteSize
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizingMain = false end end)
        end
    end)

    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingMain then
                local delta = input.Position - dragStartMain
                MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
            elseif draggingHud then
                local delta = input.Position - dragStartHud
                KeybindsHud.Position = UDim2.new(startPosHud.X.Scale, startPosHud.X.Offset + delta.X, startPosHud.Y.Scale, startPosHud.Y.Offset + delta.Y)
            elseif resizingMain then
                local delta = input.Position - resizeStartPos
                MainFrame.Size = UDim2.new(0, math.clamp(startSizeMain.X + delta.X, 400, 800), 0, math.clamp(startSizeMain.Y + delta.Y, 250, 600))
            end

            local mousePos = UserInputService:GetMouseLocation()
            if draggingTargetingSlider then
                local absPos, absSize = TargetingSliderTrack.AbsolutePosition, TargetingSliderTrack.AbsoluteSize
                local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                TargetingSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TargetingSmoothness = math.floor(pos * 100) / 100; TargetingSliderText.Text = math.floor(pos * 100) .. "%"; updateSliderTextColors()
            elseif draggingTrackingSlider then
                local absPos, absSize = TrackingSliderTrack.AbsolutePosition, TrackingSliderTrack.AbsoluteSize
                local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                TrackingSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TrackingSmoothness = math.floor(pos * 100) / 100; TrackingSliderText.Text = math.floor(pos * 100) .. "%"; updateSliderTextColors()
            elseif draggingTriggerDelaySlider then
                local absPos, absSize = TriggerDelayTrack.AbsolutePosition, TriggerDelayTrack.AbsoluteSize
                local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                TriggerDelayFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TriggerbotDelay = math.floor(pos * 100) / 100; TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay); updateSliderTextColors()
            elseif draggingFOVSlider then
                local absPos, absSize = FOVSliderTrack.AbsolutePosition, FOVSliderTrack.AbsoluteSize
                local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                FOVSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FOVSize = math.floor(pos * 400) + 1; FOVSliderText.Text = tostring(Settings.FOVSize); fovCircle.Radius = Settings.FOVSize; updateSliderTextColors()
            elseif draggingFlySpeedSlider then
                local absPos, absSize = FlySpeedTrack.AbsolutePosition, FlySpeedTrack.AbsoluteSize
                local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                FlySpeedFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FlySpeed = math.floor(pos * 290) + 10; FlySpeedText.Text = tostring(Settings.FlySpeed); updateSliderTextColors()
            elseif draggingWalkSpeedSlider then
                local absPos, absSize = WalkSpeedTrack.AbsolutePosition, WalkSpeedTrack.AbsoluteSize
                local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                WalkSpeedFill.Size = UDim2.new(pos, 0, 1, 0); Settings.WalkSpeed = math.floor(pos * 184) + 16; WalkSpeedText.Text = tostring(Settings.WalkSpeed); updateSliderTextColors()
            elseif draggingJumpPowerSlider then
                local absPos, absSize = JumpPowerTrack.AbsolutePosition, JumpPowerTrack.AbsoluteSize
                local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                JumpPowerFill.Size = UDim2.new(pos, 0, 1, 0); Settings.JumpPower = math.floor(pos * 200) + 50; JumpPowerText.Text = tostring(Settings.JumpPower); updateSliderTextColors()
            end
        end
    end))

    table.insert(connections, Tab1.MouseButton1Click:Connect(function() switchTab(1) end))
    table.insert(connections, Tab2.MouseButton1Click:Connect(function() switchTab(2) end))
    table.insert(connections, Tab3.MouseButton1Click:Connect(function() switchTab(3) end))
    table.insert(connections, Tab4.MouseButton1Click:Connect(function() switchTab(4) end))
    table.insert(connections, Tab5.MouseButton1Click:Connect(function() switchTab(5) end))
    table.insert(connections, Tab6.MouseButton1Click:Connect(function() switchTab(6) end))

    local function setupToggle(card, settingName)
        table.insert(connections, card.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                closeActiveDropdown()
                Settings[settingName] = not Settings[settingName]
                updateUIStates()
            end
        end))
    end

    setupToggle(TrackTeamCheckESP.Parent, "TeamCheckESP"); setupToggle(TrackEspHighlight.Parent, "ESPHighlight")
    setupToggle(TrackEspHeadDot.Parent, "ESPHeadDot"); setupToggle(TrackEspBox.Parent, "ESPBox")
    setupToggle(TrackEspName.Parent, "ESPName"); setupToggle(TrackEspHealth.Parent, "ESPHealth")
    setupToggle(TrackEspSkeleton.Parent, "ESPSkeleton"); setupToggle(TrackEspTracers.Parent, "ESPTracers")
    setupToggle(ToggleTrackFly.Parent, "FlyActive"); setupToggle(ToggleTrackFlyNoClip.Parent, "FlyNoClip")
    setupToggle(ToggleTrackInfJump.Parent, "InfJump"); setupToggle(ToggleTrackKeybindsHud.Parent, "ShowKeybindsHud")
    setupToggle(ToggleTrack1.Parent, "AimbotEnabled"); setupToggle(ToggleTrackTrigger.Parent, "TriggerbotEnabled")
    setupToggle(ToggleTrack3.Parent, "ShowFOV"); setupToggle(ToggleTrackTeamCheck.Parent, "TeamCheck")
    setupToggle(ToggleTrackWall.Parent, "WallCheck")

    table.insert(connections, TargetingSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then closeActiveDropdown() draggingTargetingSlider = true end end))
    table.insert(connections, TrackingSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then closeActiveDropdown() draggingTrackingSlider = true end end))
    table.insert(connections, TriggerDelayTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then closeActiveDropdown() draggingTriggerDelaySlider = true end end))
    table.insert(connections, FOVSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then closeActiveDropdown() draggingFOVSlider = true end end))
    table.insert(connections, FlySpeedTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then closeActiveDropdown() draggingFlySpeedSlider = true end end))
    table.insert(connections, WalkSpeedTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then closeActiveDropdown() draggingWalkSpeedSlider = true end end))
    table.insert(connections, JumpPowerTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then closeActiveDropdown() draggingJumpPowerSlider = true end end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingTargetingSlider = false; draggingTrackingSlider = false; draggingTriggerDelaySlider = false; draggingFOVSlider = false; draggingFlySpeedSlider = false; draggingWalkSpeedSlider = false; draggingJumpPowerSlider = false; resizingMain = false
        end
    end))

    local function isInputMatching(input, bind)
        if not bind then return false end
        if typeof(bind) == "EnumItem" then
            if bind.EnumType == Enum.KeyCode and input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode == bind
            elseif bind.EnumType == Enum.UserInputType then return input.UserInputType == bind end
        end
        return false
    end

    local function executeClickTeleport()
        local mouseLoc = UserInputService:GetMouseLocation()
        local unitRay = Camera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {Player.Character, Camera}
        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
        local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if result and myHRP then myHRP.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
    end

    table.insert(connections, UserInputService.InputBegan:Connect(function(input)
        if isInputMatching(input, Settings.KeyUnload) then unloadHub() end
    end))

    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listeningForKey then
            if ignoreNextClick then ignoreNextClick = false; return end
            if input.UserInputType == Enum.UserInputType.Keyboard then Settings[listeningForKey] = input.KeyCode; listeningForKey = nil; updateUIStates()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then Settings[listeningForKey] = input.UserInputType; listeningForKey = nil; updateUIStates() end
            return
        end
        if isInputMatching(input, Settings.KeyUnload) then return end
        if gameProcessed then return end

        if isInputMatching(input, Settings.KeyToggleMenu) then menuVisible = not menuVisible; setVisibility(menuVisible); updateUIStates()
        elseif isInputMatching(input, Settings.KeyFly) then Settings.FlyActive = not Settings.FlyActive; updateUIStates()
        elseif isInputMatching(input, Settings.KeyClickTeleport) then executeClickTeleport()
        elseif isInputMatching(input, Settings.KeyAimbot) then
            if Settings.AimbotMode == "Toggle" then Settings.AimbotEnabled = not Settings.AimbotEnabled else isAimbotHeld = true end
            updateUIStates()
        elseif isInputMatching(input, Settings.KeyESPHighlight) then Settings.ESPHighlight = not Settings.ESPHighlight; updateUIStates()
        elseif isInputMatching(input, Settings.KeyESPHeadDot) then Settings.ESPHeadDot = not Settings.ESPHeadDot; updateUIStates()
        elseif isInputMatching(input, Settings.KeyESPBox) then Settings.ESPBox = not Settings.ESPBox; updateUIStates()
        elseif isInputMatching(input, Settings.KeyESPName) then Settings.ESPName = not Settings.ESPName; updateUIStates()
        elseif isInputMatching(input, Settings.KeyESPHealth) then Settings.ESPHealth = not Settings.ESPHealth; updateUIStates()
        elseif isInputMatching(input, Settings.KeyESPSkeleton) then Settings.ESPSkeleton = not Settings.ESPSkeleton; updateUIStates()
        elseif isInputMatching(input, Settings.KeyESPTracers) then Settings.ESPTracers = not Settings.ESPTracers; updateUIStates()
        elseif input.KeyCode == Enum.KeyCode.Space and Settings.InfJump then
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if isInputMatching(input, Settings.KeyAimbot) and Settings.AimbotMode == "Hold" then isAimbotHeld = false; updateUIStates() end
    end))

    local function isVisible(targetPart)
        if not Settings.WallCheck then return true end
        local char = Player.Character; if not char then return false end
        local originHead = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"); if not originHead then return false end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char, Camera, targetPart.Parent}
        return workspace:Raycast(originHead.Position, targetPart.Position - originHead.Position, rayParams) == nil
    end

    local function isTeammate(p) return p == Player or (p.Team and Player.Team and p.Team == Player.Team) end

    local function isWeaponAutomatic(tool)
        if not tool then return true end
        if tool:GetAttribute("Auto") ~= nil then return tool:GetAttribute("Auto") end
        if tool:GetAttribute("FireMode") == "Semi" then return false end
        local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Settings") or tool:FindFirstChild("Config")
        if config then
            local autoVal = config:FindFirstChild("Auto") or config:FindFirstChild("FullyAutomatic")
            if autoVal and autoVal:IsA("BoolValue") then return autoVal.Value end
        end
        return true
    end

    local function getClosestTarget()
        local bestTarget, bestMagnitude = nil, math.huge
        local mouseLoc = UserInputService:GetMouseLocation()
        local referencePoint = (Settings.FOVOrigin == "Cursor") and mouseLoc or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and (not Settings.TeamCheck or not isTeammate(v)) then
                local character = v.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = (Settings.TargetPart == "Chest") and (character:FindFirstChild("LowerTorso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")) or character:FindFirstChild("Head")
                    if targetPart then
                        local sp, on = Camera:WorldToViewportPoint(targetPart.Position)
                        if on then
                            local mag = (referencePoint - Vector2.new(sp.X, sp.Y)).Magnitude
                            if mag <= Settings.FOVSize and mag < bestMagnitude and isVisible(targetPart) then bestMagnitude = mag; bestTarget = targetPart end
                        end
                    end
                end
            end
        end
        return bestTarget
    end

    table.insert(connections, RunService.RenderStepped:Connect(function(dt)
        fovCircle.Visible = Settings.ShowFOV and (Settings.FOVSize > 0)
        if Settings.ShowFOV then
            local mouseLoc = UserInputService:GetMouseLocation()
            fovCircle.Position = (Settings.FOVOrigin == "Cursor") and mouseLoc or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Settings.FOVSize
            fovCircle.Color = Settings.FOVColor
        end

        local target = getClosestTarget()
        if target then
            if (Settings.AimbotMode == "Hold" and isAimbotHeld) or (Settings.AimbotMode == "Toggle" and Settings.AimbotEnabled) then
                local goalCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                local sp, on = Camera:WorldToViewportPoint(target.Position)
                local mouseLoc = UserInputService:GetMouseLocation()
                local ref = (Settings.FOVOrigin == "Cursor") and mouseLoc or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = on and (Vector2.new(sp.X, sp.Y) - ref).Magnitude or 0
                local activeSmooth = (dist < 25) and Settings.TrackingSmoothness or Settings.TargetingSmoothness
                Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, math.clamp((1 - activeSmooth) * (dt * 60), 0.01, 1))
            end

            if Settings.TriggerbotEnabled then
                local char = target.Parent
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local isAuto = isWeaponAutomatic(Player.Character and Player.Character:FindFirstChildOfClass("Tool"))
                    if isAuto then
                        if not isShooting then isShooting = true; task.spawn(function() pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) end) end) end
                    else
                        if tick() - lastTriggerShot >= Settings.SemiDelay then
                            lastTriggerShot = tick()
                            task.spawn(function() pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.03); VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end) end)
                        end
                    end
                else
                    if isShooting then pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end); isShooting = false end
                end
            end
        else
            if isShooting then pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end); isShooting = false end
        end

        for _, v in pairs(Players:GetPlayers()) do
            local d = espDrawings[v]
            if v ~= Player and v.Character and d then
                local char = v.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                local active = hrp and head and hum and hum.Health > 0
                if Settings.TeamCheckESP and isTeammate(v) then
                    d.Highlight.Enabled = false; d.Box.Visible = false; d.BoxOutline.Visible = false; d.Name.Visible = false; d.HealthBar.Visible = false; d.HealthBarBackground.Visible = false; d.Tracer.Visible = false; d.HeadDot.Visible = false
                    for _, l in ipairs(d.Skeleton) do l.Visible = false end
                else
                    local tc = Settings.ESPColor
                    d.Highlight.Enabled = Settings.ESPHighlight and active
                    if active then
                        d.Highlight.Parent = char; d.Highlight.FillColor = tc; d.Highlight.OutlineColor = tc
                        local cf, size = char:GetBoundingBox()
                        local top, topOn = Camera:WorldToViewportPoint((cf + Vector3.new(0, size.Y / 2, 0)).Position)
                        local bot, botOn = Camera:WorldToViewportPoint((cf - Vector3.new(0, size.Y / 2, 0)).Position)
                        if topOn or botOn then
                            local boxH = math.abs(top.Y - bot.Y); local boxW = boxH / 2; local boxP = Vector2.new(top.X - boxW / 2, top.Y)
                            d.BoxOutline.Visible = Settings.ESPBox; d.Box.Visible = Settings.ESPBox
                            d.BoxOutline.Size = Vector2.new(boxW, boxH); d.BoxOutline.Position = boxP
                            d.Box.Size = Vector2.new(boxW, boxH); d.Box.Position = boxP; d.Box.Color = tc
                            d.Name.Visible = Settings.ESPName
                            if Settings.ESPName then d.Name.Text = v.Name; d.Name.Position = Vector2.new(bot.X, bot.Y + 4); d.Name.Color = tc end
                            d.HealthBarBackground.Visible = Settings.ESPHealth; d.HealthBar.Visible = Settings.ESPHealth
                            if Settings.ESPHealth then
                                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                d.HealthBarBackground.From = Vector2.new(boxP.X - 6, boxP.Y + boxH); d.HealthBarBackground.To = Vector2.new(boxP.X - 6, boxP.Y)
                                d.HealthBar.From = Vector2.new(boxP.X - 6, boxP.Y + boxH); d.HealthBar.To = Vector2.new(boxP.X - 6, boxP.Y + boxH - (boxH * hp))
                                d.HealthBar.Color = (hp > 0.5) and Color3.fromRGB(34, 197, 94) or (hp > 0.25 and Color3.fromRGB(249, 115, 22) or Color3.fromRGB(239, 68, 68))
                            end
                            if Settings.ESPSkeleton then
                                local bp = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}
                                local ac = 0
                                for _, p in ipairs(bp) do
                                    local p1, p2 = char:FindFirstChild(p[1]), char:FindFirstChild(p[2])
                                    if p1 and p2 then
                                        ac = ac + 1
                                        local l = d.Skeleton[ac]
                                        if l then
                                            local s1, o1 = Camera:WorldToViewportPoint(p1.Position); local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                                            l.Visible = o1 and o2
                                            if l.Visible then l.From = Vector2.new(s1.X, s1.Y); l.To = Vector2.new(s2.X, s2.Y); l.Color = tc end
                                        end
                                    end
                                end
                            else for _, l in ipairs(d.Skeleton) do l.Visible = false end end
                            d.Tracer.Visible = Settings.ESPTracers
                            if Settings.ESPTracers then d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(bot.X, bot.Y); d.Tracer.Color = tc end
                            d.HeadDot.Visible = Settings.ESPHeadDot and head ~= nil
                            if Settings.ESPHeadDot and head then
                                local hs, ho = Camera:WorldToViewportPoint(head.Position)
                                if ho then d.HeadDot.Position = Vector2.new(hs.X, hs.Y); d.HeadDot.Color = tc else d.HeadDot.Visible = false end
                            end
                        else
                            d.Box.Visible = false; d.BoxOutline.Visible = false; d.Name.Visible = false; d.HealthBar.Visible = false; d.HealthBarBackground.Visible = false; d.Tracer.Visible = false; d.HeadDot.Visible = false
                            for _, l in ipairs(d.Skeleton) do l.Visible = false end
                        end
                    else
                        d.Box.Visible = false; d.BoxOutline.Visible = false; d.Name.Visible = false; d.HealthBar.Visible = false; d.HealthBarBackground.Visible = false; d.Tracer.Visible = false; d.HeadDot.Visible = false
                        for _, l in ipairs(d.Skeleton) do l.Visible = false end
                    end
                end
            end
        end

        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
            local hrp, hum = char.HumanoidRootPart, char:FindFirstChildOfClass("Humanoid")
            hum.WalkSpeed = Settings.WalkSpeed
            if Settings.JumpPower ~= 50 then
                if not hum:GetAttribute("_saifOrig") then
                    hum:SetAttribute("_saifOrig", true)
                    hum:SetAttribute("_saifOUJP", hum.UseJumpPower); hum:SetAttribute("_saifOJP", hum.JumpPower); hum:SetAttribute("_saifOJH", hum.JumpHeight)
                end
                hum.UseJumpPower = true; hum.JumpPower = Settings.JumpPower
            else
                if hum:GetAttribute("_saifOrig") then
                    hum.UseJumpPower = hum:GetAttribute("_saifOUJP"); hum.JumpPower = hum:GetAttribute("_saifOJP"); hum.JumpHeight = hum:GetAttribute("_saifOJH")
                    hum:SetAttribute("_saifOrig", nil)
                end
            end

            if Settings.FlyActive then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
                hum.PlatformStand = true
                local fv = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then fv = fv + (Camera.CFrame.LookVector * Settings.FlySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then fv = fv - (Camera.CFrame.LookVector * Settings.FlySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then fv = fv - (Camera.CFrame.RightVector * Settings.FlySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then fv = fv + (Camera.CFrame.RightVector * Settings.FlySpeed) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then fv = fv + Vector3.new(0, Settings.FlySpeed, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then fv = fv - Vector3.new(0, Settings.FlySpeed, 0) end
                hrp.AssemblyLinearVelocity = fv; hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                if Settings.FlyNoClip then for _, pt in ipairs(char:GetDescendants()) do if pt:IsA("BasePart") then pt.CanCollide = false end end end
            else
                if hum.PlatformStand and not Settings.FlyActive then hum.PlatformStand = false; pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
            end
        end

        if tick() - lastSaveTime >= SAVE_INTERVAL then lastSaveTime = tick(); saveSettings() end
    end))

    updateUIStates()
    applyThemeColors()

    task.defer(function()
        if ValTarget then ValTarget.Text = Settings.TargetPart .. " ▾" end
        if ValAimbotMode then ValAimbotMode.Text = Settings.AimbotMode .. " ▾" end
        if ValFOVOrigin then ValFOVOrigin.Text = Settings.FOVOrigin .. " ▾" end
        if ValFOVColor then ValFOVColor.Text = (Settings.FOVColorName or "White") .. " ▾" end
        if ValESPColor then ValESPColor.Text = (Settings.ESPColorName or "White") .. " ▾" end
        if ValTpOffset then ValTpOffset.Text = Settings.TeleportOffset .. " ▾" end
        if ValTheme then ValTheme.Text = Settings.CurrentTheme .. " ▾" end
    end)
end

setupUIAndTheme()
