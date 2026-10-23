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
    TargetPart = "Head",
    FOVColorIndex = 1,
    
    ESPHighlight = false,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    ESPSkeleton = false,
    ESPTracers = false,
    TeamCheckESP = false,
    TeammateColorIndex = 1,
    EnemyColorIndex = 1,

    FlyActive = false,
    FlySpeed = 50,
    FlyVerticalSpeed = 50,
    FlyNoClip = false,
    ShowKeybindsHud = false,
    
    CustomFont = Enum.Font.FredokaOne,
    
    KeyAimbot = Enum.KeyCode.V,
    KeyESP = Enum.KeyCode.C,
    KeyFly = Enum.KeyCode.X,
    KeyToggleMenu = Enum.KeyCode.LeftAlt,
    KeyUnload = Enum.KeyCode.U,
    
    ThemeIndex = 1
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local connections = {}
local listeningForKey = nil
local ignoreNextClick = false
local draggingTargetingSlider = false
local draggingTrackingSlider = false
local draggingTriggerDelaySlider = false
local draggingFOVSlider = false
local draggingFlySpeedSlider = false
local draggingFlyVertSlider = false
local lastTriggerShot = 0
local isShooting = false
local isAimbotHeld = false

local successGui, parentContainer = pcall(function()
    return CoreGui
end)
if not successGui or not parentContainer then
    parentContainer = Player:WaitForChild("PlayerGui")
end

if parentContainer:FindFirstChild("SaifsAimbotGui") then
    parentContainer.SaifsAimbotGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaifsAimbotGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentContainer

local ColorOptions = {
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Black", Color = Color3.fromRGB(15, 15, 15)},
    {Name = "Purple", Color = Color3.fromRGB(147, 51, 234)},
    {Name = "Blue", Color = Color3.fromRGB(30, 144, 255)},
    {Name = "Green", Color = Color3.fromRGB(34, 197, 94)},
    {Name = "Red", Color = Color3.fromRGB(239, 68, 68)},
    {Name = "Yellow", Color = Color3.fromRGB(234, 179, 8)},
    {Name = "Orange", Color = Color3.fromRGB(249, 115, 22)}
}

local Themes = {
    {Name = "White", Accent = Color3.fromRGB(255, 255, 255), Bg = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(26, 26, 30), Text = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(130, 130, 145), Off = Color3.fromRGB(60, 60, 70), TabActive = Color3.fromRGB(38, 38, 45), TabInactive = Color3.fromRGB(22, 22, 26)},
    {Name = "Black", Accent = Color3.fromRGB(25, 25, 25), Bg = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(26, 26, 30), Text = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(130, 130, 145), Off = Color3.fromRGB(60, 60, 70), TabActive = Color3.fromRGB(38, 38, 45), TabInactive = Color3.fromRGB(22, 22, 26)},
    {Name = "Purple", Accent = Color3.fromRGB(147, 51, 234), Bg = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(26, 26, 30), Text = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(130, 130, 145), Off = Color3.fromRGB(60, 60, 70), TabActive = Color3.fromRGB(38, 38, 45), TabInactive = Color3.fromRGB(22, 22, 26)},
    {Name = "Blue", Accent = Color3.fromRGB(30, 144, 255), Bg = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(26, 26, 30), Text = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(130, 130, 145), Off = Color3.fromRGB(60, 60, 70), TabActive = Color3.fromRGB(38, 38, 45), TabInactive = Color3.fromRGB(22, 22, 26)},
    {Name = "Green", Accent = Color3.fromRGB(34, 197, 94), Bg = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(26, 26, 30), Text = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(130, 130, 145), Off = Color3.fromRGB(60, 60, 70), TabActive = Color3.fromRGB(38, 38, 45), TabInactive = Color3.fromRGB(22, 22, 26)},
    {Name = "Red", Accent = Color3.fromRGB(239, 68, 68), Bg = Color3.fromRGB(18, 18, 20), Card = Color3.fromRGB(26, 26, 30), Text = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(130, 130, 145), Off = Color3.fromRGB(60, 60, 70), TabActive = Color3.fromRGB(38, 38, 45), TabInactive = Color3.fromRGB(22, 22, 26)}
}

local function getTheme() return Themes[Settings.ThemeIndex] end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = getTheme().Bg
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = getTheme().SubText
ResizeHandle.TextSize = 12
ResizeHandle.ZIndex = 10
ResizeHandle.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Position = UDim2.new(0, 15, 0, 12)
Title.BackgroundTransparency = 1
Title.Font = Settings.CustomFont
Title.Text = "Saif's Aimbot"
Title.TextColor3 = getTheme().Text
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

local function getKeyName(inputObj)
    if not inputObj then return "None" end
    if typeof(inputObj) == "EnumItem" then
        if inputObj.EnumType == Enum.KeyCode then
            return inputObj.Name
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
KeybindsHud.Name = "KeybindsHud"
KeybindsHud.Size = UDim2.new(0, 190, 0, 120)
KeybindsHud.Position = UDim2.new(0, 15, 1, -135)
KeybindsHud.BackgroundColor3 = getTheme().Card
KeybindsHud.BorderSizePixel = 0
KeybindsHud.Visible = false
KeybindsHud.ZIndex = 50
KeybindsHud.Parent = ScreenGui

local KeybindsHudCorner = Instance.new("UICorner")
KeybindsHudCorner.CornerRadius = UDim.new(0, 8)
KeybindsHudCorner.Parent = KeybindsHud

local function createHudStatusRow(yOffset, labelText)
    local rowLbl = Instance.new("TextLabel")
    rowLbl.Size = UDim2.new(1, -20, 0, 20)
    rowLbl.Position = UDim2.new(0, 10, 0, yOffset)
    rowLbl.BackgroundTransparency = 1
    rowLbl.Font = Settings.CustomFont
    rowLbl.Text = labelText
    rowLbl.TextColor3 = getTheme().SubText
    rowLbl.TextSize = 12
    rowLbl.TextXAlignment = Enum.TextXAlignment.Left
    rowLbl.ZIndex = 51
    rowLbl.Parent = KeybindsHud
    
    local stateLbl = Instance.new("TextLabel")
    stateLbl.Size = UDim2.new(0, 60, 0, 20)
    stateLbl.Position = UDim2.new(1, -70, 0, yOffset)
    stateLbl.BackgroundTransparency = 1
    stateLbl.Font = Settings.CustomFont
    stateLbl.Text = "OFF"
    stateLbl.TextColor3 = Color3.fromRGB(239, 68, 68)
    stateLbl.TextSize = 12
    stateLbl.TextXAlignment = Enum.TextXAlignment.Right
    stateLbl.ZIndex = 51
    stateLbl.Parent = KeybindsHud
    
    return rowLbl, stateLbl
end

local HudRowAimbot, HudStatusAimbot = createHudStatusRow(8, "Aimbot [" .. getKeyName(Settings.KeyAimbot) .. "]")
local HudRowESP, HudStatusESP = createHudStatusRow(30, "ESP [" .. getKeyName(Settings.KeyESP) .. "]")
local HudRowFly, HudStatusFly = createHudStatusRow(52, "Fly [" .. getKeyName(Settings.KeyFly) .. "]")
local HudRowMenu, HudStatusMenu = createHudStatusRow(74, "Menu [" .. getKeyName(Settings.KeyToggleMenu) .. "]")

local HudStatusUnload = Instance.new("TextLabel")
HudStatusUnload.Size = UDim2.new(1, -20, 0, 18)
HudStatusUnload.Position = UDim2.new(0, 10, 0, 96)
HudStatusUnload.BackgroundTransparency = 1
HudStatusUnload.Font = Settings.CustomFont
HudStatusUnload.Text = "Press " .. getKeyName(Settings.KeyUnload) .. " to Unload"
HudStatusUnload.TextColor3 = getTheme().SubText
HudStatusUnload.TextSize = 10
HudStatusUnload.TextXAlignment = Enum.TextXAlignment.Center
HudStatusUnload.ZIndex = 51
HudStatusUnload.Parent = KeybindsHud

local currentTab = 1

local function createTabButton(name, xPos, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 56, 0, 24)
    btn.Position = UDim2.new(0, xPos, 0, 42)
    btn.BackgroundColor3 = (currentTab == index) and getTheme().TabActive or getTheme().TabInactive
    btn.BorderSizePixel = 0
    btn.Font = Settings.CustomFont
    btn.Text = name
    btn.TextColor3 = (currentTab == index) and getTheme().Text or getTheme().SubText
    btn.TextSize = 12
    btn.ZIndex = 2
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    return btn
end

local Tab1 = createTabButton("Aimbot", 15, 1)
local Tab2 = createTabButton("ESP", 75, 2)
local Tab3 = createTabButton("Fly", 135, 3)
local Tab4 = createTabButton("Keybinds", 195, 4)
local Tab5 = createTabButton("Settings", 255, 5)

local tabContainers = {}
for i = 1, 5 do
    local scroller = Instance.new("ScrollingFrame")
    scroller.Size = UDim2.new(1, -20, 1, -85)
    scroller.Position = UDim2.new(0, 10, 0, 75)
    scroller.BackgroundTransparency = 1
    scroller.BorderSizePixel = 0
    scroller.CanvasSize = UDim2.new(0, 0, 0, 700)
    scroller.ScrollBarThickness = 4
    scroller.ScrollBarImageColor3 = getTheme().Accent
    scroller.Visible = (i == 1)
    scroller.ZIndex = 2
    scroller.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroller
    
    tabContainers[i] = scroller
end

local function createCard(tabIndex, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 34)
    card.BackgroundColor3 = getTheme().Card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 3
    card.Parent = tabContainers[tabIndex]
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card
    
    return card
end

-- TAB 1: Aimbot
local Card1 = createCard(1, 1)
local LblAimbot = Instance.new("TextLabel")
LblAimbot.Size = UDim2.new(0, 200, 0, 34); LblAimbot.Position = UDim2.new(0, 12, 0, 0); LblAimbot.BackgroundTransparency = 1
LblAimbot.Font = Settings.CustomFont; LblAimbot.Text = "Aimbot"; LblAimbot.TextColor3 = getTheme().Text; LblAimbot.TextSize = 14; LblAimbot.TextXAlignment = Enum.TextXAlignment.Left; LblAimbot.ZIndex = 4; LblAimbot.Parent = Card1

local ToggleTrack1 = Instance.new("Frame")
ToggleTrack1.Size = UDim2.new(0, 34, 0, 18); ToggleTrack1.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrack1.BackgroundColor3 = getTheme().Off; ToggleTrack1.BorderSizePixel = 0; ToggleTrack1.ZIndex = 4; ToggleTrack1.Parent = Card1
Instance.new("UICorner", ToggleTrack1).CornerRadius = UDim.new(1, 0)
local ToggleKnob1 = Instance.new("Frame", ToggleTrack1)
ToggleKnob1.Size = UDim2.new(0, 14, 0, 14); ToggleKnob1.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnob1.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnob1.BorderSizePixel = 0; ToggleKnob1.ZIndex = 5
Instance.new("UICorner", ToggleKnob1).CornerRadius = UDim.new(1, 0)

local CardTriggerbot = createCard(1, 2)
local LblTriggerbot = Instance.new("TextLabel")
LblTriggerbot.Size = UDim2.new(0, 200, 0, 34); LblTriggerbot.Position = UDim2.new(0, 12, 0, 0); LblTriggerbot.BackgroundTransparency = 1
LblTriggerbot.Font = Settings.CustomFont; LblTriggerbot.Text = "Triggerbot"; LblTriggerbot.TextColor3 = getTheme().Text; LblTriggerbot.TextSize = 14; LblTriggerbot.TextXAlignment = Enum.TextXAlignment.Left; LblTriggerbot.ZIndex = 4; LblTriggerbot.Parent = CardTriggerbot

local ToggleTrackTrigger = Instance.new("Frame")
ToggleTrackTrigger.Size = UDim2.new(0, 34, 0, 18); ToggleTrackTrigger.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackTrigger.BackgroundColor3 = getTheme().Off; ToggleTrackTrigger.BorderSizePixel = 0; ToggleTrackTrigger.ZIndex = 4; ToggleTrackTrigger.Parent = CardTriggerbot
Instance.new("UICorner", ToggleTrackTrigger).CornerRadius = UDim.new(1, 0)
local ToggleKnobTrigger = Instance.new("Frame", ToggleTrackTrigger)
ToggleKnobTrigger.Size = UDim2.new(0, 14, 0, 14); ToggleKnobTrigger.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobTrigger.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobTrigger.BorderSizePixel = 0; ToggleKnobTrigger.ZIndex = 5
Instance.new("UICorner", ToggleKnobTrigger).CornerRadius = UDim.new(1, 0)

local CardTriggerDelay = createCard(1, 3)
local LblTriggerDelay = Instance.new("TextLabel")
LblTriggerDelay.Size = UDim2.new(0, 200, 0, 34); LblTriggerDelay.Position = UDim2.new(0, 12, 0, 0); LblTriggerDelay.BackgroundTransparency = 1
LblTriggerDelay.Font = Settings.CustomFont; LblTriggerDelay.Text = "Trigger Delay"; LblTriggerDelay.TextColor3 = getTheme().Text; LblTriggerDelay.TextSize = 14; LblTriggerDelay.TextXAlignment = Enum.TextXAlignment.Left; LblTriggerDelay.ZIndex = 4; LblTriggerDelay.Parent = CardTriggerDelay

local TriggerDelayTrack = Instance.new("Frame", CardTriggerDelay)
TriggerDelayTrack.Size = UDim2.new(0, 170, 0, 14); TriggerDelayTrack.Position = UDim2.new(1, -182, 0.5, -7); TriggerDelayTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); TriggerDelayTrack.BorderSizePixel = 0; TriggerDelayTrack.ZIndex = 4
Instance.new("UICorner", TriggerDelayTrack).CornerRadius = UDim.new(1, 0)
local TriggerDelayFill = Instance.new("Frame", TriggerDelayTrack)
TriggerDelayFill.Size = UDim2.new(Settings.TriggerbotDelay / 1.0, 0, 1, 0); TriggerDelayFill.BackgroundColor3 = getTheme().Accent; TriggerDelayFill.BorderSizePixel = 0; TriggerDelayFill.ZIndex = 5
Instance.new("UICorner", TriggerDelayFill).CornerRadius = UDim.new(1, 0)
local TriggerDelayText = Instance.new("TextLabel", TriggerDelayTrack)
TriggerDelayText.Size = UDim2.new(1, 0, 1, 0); TriggerDelayText.BackgroundTransparency = 1; TriggerDelayText.Font = Settings.CustomFont; TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay); TriggerDelayText.TextColor3 = Color3.fromRGB(255, 255, 255); TriggerDelayText.TextSize = 12; TriggerDelayText.ZIndex = 6

local CardTarget = createCard(1, 4)
local LblTarget = Instance.new("TextLabel", CardTarget)
LblTarget.Size = UDim2.new(0, 200, 0, 34); LblTarget.Position = UDim2.new(0, 12, 0, 0); LblTarget.BackgroundTransparency = 1
LblTarget.Font = Settings.CustomFont; LblTarget.Text = "Target Hitbox"; LblTarget.TextColor3 = getTheme().Text; LblTarget.TextSize = 14; LblTarget.TextXAlignment = Enum.TextXAlignment.Left; LblTarget.ZIndex = 4

local ValTarget = Instance.new("TextButton", CardTarget)
ValTarget.Size = UDim2.new(0, 130, 0, 24); ValTarget.Position = UDim2.new(1, -142, 0.5, -12); ValTarget.BackgroundColor3 = Color3.fromRGB(35, 35, 42); ValTarget.BorderSizePixel = 0
ValTarget.Font = Settings.CustomFont; ValTarget.Text = Settings.TargetPart; ValTarget.TextColor3 = getTheme().Accent; ValTarget.TextSize = 13; ValTarget.ZIndex = 4
Instance.new("UICorner", ValTarget).CornerRadius = UDim.new(0, 5)

ValTarget.MouseButton1Click:Connect(function()
    Settings.TargetPart = (Settings.TargetPart == "Head") and "Chest" or "Head"
    ValTarget.Text = Settings.TargetPart
end)

local CardAimbotMode = createCard(1, 5)
local LblAimbotMode = Instance.new("TextLabel", CardAimbotMode)
LblAimbotMode.Size = UDim2.new(0, 200, 0, 34); LblAimbotMode.Position = UDim2.new(0, 12, 0, 0); LblAimbotMode.BackgroundTransparency = 1
LblAimbotMode.Font = Settings.CustomFont; LblAimbotMode.Text = "Aimbot Mode"; LblAimbotMode.TextColor3 = getTheme().Text; LblAimbotMode.TextSize = 14; LblAimbotMode.TextXAlignment = Enum.TextXAlignment.Left; LblAimbotMode.ZIndex = 4

local ValAimbotMode = Instance.new("TextButton", CardAimbotMode)
ValAimbotMode.Size = UDim2.new(0, 130, 0, 24); ValAimbotMode.Position = UDim2.new(1, -142, 0.5, -12); ValAimbotMode.BackgroundColor3 = Color3.fromRGB(35, 35, 42); ValAimbotMode.BorderSizePixel = 0
ValAimbotMode.Font = Settings.CustomFont; ValAimbotMode.Text = Settings.AimbotMode; ValAimbotMode.TextColor3 = getTheme().Accent; ValAimbotMode.TextSize = 13; ValAimbotMode.ZIndex = 4
Instance.new("UICorner", ValAimbotMode).CornerRadius = UDim.new(0, 5)

ValAimbotMode.MouseButton1Click:Connect(function()
    Settings.AimbotMode = (Settings.AimbotMode == "Toggle") and "Hold" or "Toggle"
    ValAimbotMode.Text = Settings.AimbotMode
    isAimbotHeld = false
end)

local CardTeamCheck = createCard(1, 6)
local LblTeamCheck = Instance.new("TextLabel", CardTeamCheck)
LblTeamCheck.Size = UDim2.new(0, 200, 0, 34); LblTeamCheck.Position = UDim2.new(0, 12, 0, 0); LblTeamCheck.BackgroundTransparency = 1
LblTeamCheck.Font = Settings.CustomFont; LblTeamCheck.Text = "Team Check"; LblTeamCheck.TextColor3 = getTheme().Text; LblTeamCheck.TextSize = 14; LblTeamCheck.TextXAlignment = Enum.TextXAlignment.Left; LblTeamCheck.ZIndex = 4

local ToggleTrackTeamCheck = Instance.new("Frame", CardTeamCheck)
ToggleTrackTeamCheck.Size = UDim2.new(0, 34, 0, 18); ToggleTrackTeamCheck.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackTeamCheck.BackgroundColor3 = getTheme().Off; ToggleTrackTeamCheck.BorderSizePixel = 0; ToggleTrackTeamCheck.ZIndex = 4
Instance.new("UICorner", ToggleTrackTeamCheck).CornerRadius = UDim.new(1, 0)
local ToggleKnobTeamCheck = Instance.new("Frame", ToggleTrackTeamCheck)
ToggleKnobTeamCheck.Size = UDim2.new(0, 14, 0, 14); ToggleKnobTeamCheck.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobTeamCheck.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobTeamCheck.BorderSizePixel = 0; ToggleKnobTeamCheck.ZIndex = 5
Instance.new("UICorner", ToggleKnobTeamCheck).CornerRadius = UDim.new(1, 0)

local CardWallCheck = createCard(1, 7)
local LblWallCheck = Instance.new("TextLabel", CardWallCheck)
LblWallCheck.Size = UDim2.new(0, 200, 0, 34); LblWallCheck.Position = UDim2.new(0, 12, 0, 0); LblWallCheck.BackgroundTransparency = 1
LblWallCheck.Font = Settings.CustomFont; LblWallCheck.Text = "Wall Check"; LblWallCheck.TextColor3 = getTheme().Text; LblWallCheck.TextSize = 14; LblWallCheck.TextXAlignment = Enum.TextXAlignment.Left; LblWallCheck.ZIndex = 4

local ToggleTrackWall = Instance.new("Frame", CardWallCheck)
ToggleTrackWall.Size = UDim2.new(0, 34, 0, 18); ToggleTrackWall.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackWall.BackgroundColor3 = getTheme().Off; ToggleTrackWall.BorderSizePixel = 0; ToggleTrackWall.ZIndex = 4
Instance.new("UICorner", ToggleTrackWall).CornerRadius = UDim.new(1, 0)
local ToggleKnobWall = Instance.new("Frame", ToggleTrackWall)
ToggleKnobWall.Size = UDim2.new(0, 14, 0, 14); ToggleKnobWall.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobWall.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobWall.BorderSizePixel = 0; ToggleKnobWall.ZIndex = 5
Instance.new("UICorner", ToggleKnobWall).CornerRadius = UDim.new(1, 0)

local CardTargetingSmooth = createCard(1, 8)
local LblTargetingSmooth = Instance.new("TextLabel", CardTargetingSmooth)
LblTargetingSmooth.Size = UDim2.new(0, 200, 0, 34); LblTargetingSmooth.Position = UDim2.new(0, 12, 0, 0); LblTargetingSmooth.BackgroundTransparency = 1
LblTargetingSmooth.Font = Settings.CustomFont; LblTargetingSmooth.Text = "Targeting Smoothness"; LblTargetingSmooth.TextColor3 = getTheme().Text; LblTargetingSmooth.TextSize = 14; LblTargetingSmooth.TextXAlignment = Enum.TextXAlignment.Left; LblTargetingSmooth.ZIndex = 4

local TargetingSliderTrack = Instance.new("Frame", CardTargetingSmooth)
TargetingSliderTrack.Size = UDim2.new(0, 170, 0, 14); TargetingSliderTrack.Position = UDim2.new(1, -182, 0.5, -7); TargetingSliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); TargetingSliderTrack.BorderSizePixel = 0; TargetingSliderTrack.ZIndex = 4
Instance.new("UICorner", TargetingSliderTrack).CornerRadius = UDim.new(1, 0)
local TargetingSliderFill = Instance.new("Frame", TargetingSliderTrack)
TargetingSliderFill.Size = UDim2.new(Settings.TargetingSmoothness, 0, 1, 0); TargetingSliderFill.BackgroundColor3 = getTheme().Accent; TargetingSliderFill.BorderSizePixel = 0; TargetingSliderFill.ZIndex = 5
Instance.new("UICorner", TargetingSliderFill).CornerRadius = UDim.new(1, 0)
local TargetingSliderText = Instance.new("TextLabel", TargetingSliderTrack)
TargetingSliderText.Size = UDim2.new(1, 0, 1, 0); TargetingSliderText.BackgroundTransparency = 1; TargetingSliderText.Font = Settings.CustomFont; TargetingSliderText.Text = math.floor(Settings.TargetingSmoothness * 100) .. "%"; TargetingSliderText.TextColor3 = Color3.fromRGB(255, 255, 255); TargetingSliderText.TextSize = 12; TargetingSliderText.ZIndex = 6

local CardTrackingSmooth = createCard(1, 9)
local LblTrackingSmooth = Instance.new("TextLabel", CardTrackingSmooth)
LblTrackingSmooth.Size = UDim2.new(0, 200, 0, 34); LblTrackingSmooth.Position = UDim2.new(0, 12, 0, 0); LblTrackingSmooth.BackgroundTransparency = 1
LblTrackingSmooth.Font = Settings.CustomFont; LblTrackingSmooth.Text = "Tracking Smoothness"; LblTrackingSmooth.TextColor3 = getTheme().Text; LblTrackingSmooth.TextSize = 14; LblTrackingSmooth.TextXAlignment = Enum.TextXAlignment.Left; LblTrackingSmooth.ZIndex = 4

local TrackingSliderTrack = Instance.new("Frame", CardTrackingSmooth)
TrackingSliderTrack.Size = UDim2.new(0, 170, 0, 14); TrackingSliderTrack.Position = UDim2.new(1, -182, 0.5, -7); TrackingSliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); TrackingSliderTrack.BorderSizePixel = 0; TrackingSliderTrack.ZIndex = 4
Instance.new("UICorner", TrackingSliderTrack).CornerRadius = UDim.new(1, 0)
local TrackingSliderFill = Instance.new("Frame", TrackingSliderTrack)
TrackingSliderFill.Size = UDim2.new(Settings.TrackingSmoothness, 0, 1, 0); TrackingSliderFill.BackgroundColor3 = getTheme().Accent; TrackingSliderFill.BorderSizePixel = 0; TrackingSliderFill.ZIndex = 5
Instance.new("UICorner", TrackingSliderFill).CornerRadius = UDim.new(1, 0)
local TrackingSliderText = Instance.new("TextLabel", TrackingSliderTrack)
TrackingSliderText.Size = UDim2.new(1, 0, 1, 0); TrackingSliderText.BackgroundTransparency = 1; TrackingSliderText.Font = Settings.CustomFont; TrackingSliderText.Text = math.floor(Settings.TrackingSmoothness * 100) .. "%"; TrackingSliderText.TextColor3 = Color3.fromRGB(255, 255, 255); TrackingSliderText.TextSize = 12; TrackingSliderText.ZIndex = 6

local CardFOV = createCard(1, 10)
local LblFOV = Instance.new("TextLabel", CardFOV)
LblFOV.Size = UDim2.new(0, 200, 0, 34); LblFOV.Position = UDim2.new(0, 12, 0, 0); LblFOV.BackgroundTransparency = 1
LblFOV.Font = Settings.CustomFont; LblFOV.Text = "Show FOV Circle"; LblFOV.TextColor3 = getTheme().Text; LblFOV.TextSize = 14; LblFOV.TextXAlignment = Enum.TextXAlignment.Left; LblFOV.ZIndex = 4

local ToggleTrack3 = Instance.new("Frame", CardFOV)
ToggleTrack3.Size = UDim2.new(0, 34, 0, 18); ToggleTrack3.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrack3.BackgroundColor3 = getTheme().Off; ToggleTrack3.BorderSizePixel = 0; ToggleTrack3.ZIndex = 4
Instance.new("UICorner", ToggleTrack3).CornerRadius = UDim.new(1, 0)
local ToggleKnob3 = Instance.new("Frame", ToggleTrack3)
ToggleKnob3.Size = UDim2.new(0, 14, 0, 14); ToggleKnob3.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnob3.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnob3.BorderSizePixel = 0; ToggleKnob3.ZIndex = 5
Instance.new("UICorner", ToggleKnob3).CornerRadius = UDim.new(1, 0)

local CardFOVSlider = createCard(1, 11)
local LblFOVSlider = Instance.new("TextLabel", CardFOVSlider)
LblFOVSlider.Size = UDim2.new(0, 200, 0, 34); LblFOVSlider.Position = UDim2.new(0, 12, 0, 0); LblFOVSlider.BackgroundTransparency = 1
LblFOVSlider.Font = Settings.CustomFont; LblFOVSlider.Text = "FOV Size"; LblFOVSlider.TextColor3 = getTheme().Text; LblFOVSlider.TextSize = 14; LblFOVSlider.TextXAlignment = Enum.TextXAlignment.Left; LblFOVSlider.ZIndex = 4

local FOVSliderTrack = Instance.new("Frame", CardFOVSlider)
FOVSliderTrack.Size = UDim2.new(0, 170, 0, 14); FOVSliderTrack.Position = UDim2.new(1, -182, 0.5, -7); FOVSliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); FOVSliderTrack.BorderSizePixel = 0; FOVSliderTrack.ZIndex = 4
Instance.new("UICorner", FOVSliderTrack).CornerRadius = UDim.new(1, 0)
local FOVSliderFill = Instance.new("Frame", FOVSliderTrack)
FOVSliderFill.Size = UDim2.new(100/400, 0, 1, 0); FOVSliderFill.BackgroundColor3 = getTheme().Accent; FOVSliderFill.BorderSizePixel = 0; FOVSliderFill.ZIndex = 5
Instance.new("UICorner", FOVSliderFill).CornerRadius = UDim.new(1, 0)
local FOVSliderText = Instance.new("TextLabel", FOVSliderTrack)
FOVSliderText.Size = UDim2.new(1, 0, 1, 0); FOVSliderText.BackgroundTransparency = 1; FOVSliderText.Font = Settings.CustomFont; FOVSliderText.Text = "100"; FOVSliderText.TextColor3 = Color3.fromRGB(255, 255, 255); FOVSliderText.TextSize = 12; FOVSliderText.ZIndex = 6

local CardFOVColor = createCard(1, 12)
local LblFOVColor = Instance.new("TextLabel", CardFOVColor)
LblFOVColor.Size = UDim2.new(0, 200, 0, 34); LblFOVColor.Position = UDim2.new(0, 12, 0, 0); LblFOVColor.BackgroundTransparency = 1
LblFOVColor.Font = Settings.CustomFont; LblFOVColor.Text = "FOV Circle Color"; LblFOVColor.TextColor3 = getTheme().Text; LblFOVColor.TextSize = 14; LblFOVColor.TextXAlignment = Enum.TextXAlignment.Left; LblFOVColor.ZIndex = 4

local ValFOVColor = Instance.new("TextButton", CardFOVColor)
ValFOVColor.Size = UDim2.new(0, 110, 0, 24); ValFOVColor.Position = UDim2.new(1, -122, 0.5, -12); ValFOVColor.BackgroundColor3 = Color3.fromRGB(35, 35, 42); ValFOVColor.BorderSizePixel = 0
ValFOVColor.Font = Settings.CustomFont; ValFOVColor.Text = ColorOptions[Settings.FOVColorIndex].Name; ValFOVColor.TextColor3 = ColorOptions[Settings.FOVColorIndex].Color; ValFOVColor.TextSize = 13; ValFOVColor.ZIndex = 4
Instance.new("UICorner", ValFOVColor).CornerRadius = UDim.new(0, 5)

ValFOVColor.MouseButton1Click:Connect(function()
    Settings.FOVColorIndex = Settings.FOVColorIndex + 1
    if Settings.FOVColorIndex > #ColorOptions then
        Settings.FOVColorIndex = 1
    end
    local col = ColorOptions[Settings.FOVColorIndex]
    ValFOVColor.Text = col.Name
    ValFOVColor.TextColor3 = col.Color
end)

-- TAB 2: ESP
local function createESPCard(labelText, settingName, order)
    local card = createCard(2, order)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0, 200, 0, 34); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Font = Settings.CustomFont; lbl.Text = labelText; lbl.TextColor3 = getTheme().Text; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4

    local track = Instance.new("Frame", card)
    track.Size = UDim2.new(0, 34, 0, 18); track.Position = UDim2.new(1, -46, 0.5, -9); track.BackgroundColor3 = Settings[settingName] and getTheme().Accent or getTheme().Off; track.BorderSizePixel = 0; track.ZIndex = 4
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = Settings[settingName] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.BorderSizePixel = 0; knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    return card, track, knob, lbl
end

local CardTeamCheckESP, TrackTeamCheckESP, KnobTeamCheckESP, LblTeamCheckESP = createESPCard("Team Check", "TeamCheckESP", 1)
local CardEspHighlight, TrackEspHighlight, KnobEspHighlight, LblEspHighlight = createESPCard("Highlight ESP", "ESPHighlight", 2)
local CardEspBox, TrackEspBox, KnobEspBox, LblEspBox = createESPCard("ESP Boxes", "ESPBox", 3)
local CardEspName, TrackEspName, KnobEspName, LblEspName = createESPCard("ESP Names", "ESPName", 4)
local CardEspHealth, TrackEspHealth, KnobEspHealth, LblEspHealth = createESPCard("ESP Health Bar", "ESPHealth", 5)
local CardEspSkeleton, TrackEspSkeleton, KnobEspSkeleton, LblEspSkeleton = createESPCard("ESP Skeleton", "ESPSkeleton", 6)
local CardEspTracers, TrackEspTracers, KnobEspTracers, LblEspTracers = createESPCard("ESP Tracers", "ESPTracers", 7)

local CardTeamColor = createCard(2, 8)
local LblTeamColor = Instance.new("TextLabel", CardTeamColor)
LblTeamColor.Size = UDim2.new(0, 200, 0, 34); LblTeamColor.Position = UDim2.new(0, 12, 0, 0); LblTeamColor.BackgroundTransparency = 1
LblTeamColor.Font = Settings.CustomFont; LblTeamColor.Text = "Teammate Color"; LblTeamColor.TextColor3 = getTheme().Text; LblTeamColor.TextSize = 14; LblTeamColor.TextXAlignment = Enum.TextXAlignment.Left; LblTeamColor.ZIndex = 4

local ValTeamColor = Instance.new("TextButton", CardTeamColor)
ValTeamColor.Size = UDim2.new(0, 110, 0, 24); ValTeamColor.Position = UDim2.new(1, -122, 0.5, -12); ValTeamColor.BackgroundColor3 = Color3.fromRGB(35, 35, 42); ValTeamColor.BorderSizePixel = 0
ValTeamColor.Font = Settings.CustomFont; ValTeamColor.Text = ColorOptions[Settings.TeammateColorIndex].Name; ValTeamColor.TextColor3 = ColorOptions[Settings.TeammateColorIndex].Color; ValTeamColor.TextSize = 13; ValTeamColor.ZIndex = 4
Instance.new("UICorner", ValTeamColor).CornerRadius = UDim.new(0, 5)

ValTeamColor.MouseButton1Click:Connect(function()
    Settings.TeammateColorIndex = Settings.TeammateColorIndex + 1
    if Settings.TeammateColorIndex > #ColorOptions then
        Settings.TeammateColorIndex = 1
    end
    local col = ColorOptions[Settings.TeammateColorIndex]
    ValTeamColor.Text = col.Name
    ValTeamColor.TextColor3 = col.Color
end)

local CardEnemyColor = createCard(2, 9)
local LblEnemyColor = Instance.new("TextLabel", CardEnemyColor)
LblEnemyColor.Size = UDim2.new(0, 200, 0, 34); LblEnemyColor.Position = UDim2.new(0, 12, 0, 0); LblEnemyColor.BackgroundTransparency = 1
LblEnemyColor.Font = Settings.CustomFont; LblEnemyColor.Text = "Enemy Color"; LblEnemyColor.TextColor3 = getTheme().Text; LblEnemyColor.TextSize = 14; LblEnemyColor.TextXAlignment = Enum.TextXAlignment.Left; LblEnemyColor.ZIndex = 4

local ValEnemyColor = Instance.new("TextButton", CardEnemyColor)
ValEnemyColor.Size = UDim2.new(0, 110, 0, 24); ValEnemyColor.Position = UDim2.new(1, -122, 0.5, -12); ValEnemyColor.BackgroundColor3 = Color3.fromRGB(35, 35, 42); ValEnemyColor.BorderSizePixel = 0
ValEnemyColor.Font = Settings.CustomFont; ValEnemyColor.Text = ColorOptions[Settings.EnemyColorIndex].Name; ValEnemyColor.TextColor3 = ColorOptions[Settings.EnemyColorIndex].Color; ValEnemyColor.TextSize = 13; ValEnemyColor.ZIndex = 4
Instance.new("UICorner", ValEnemyColor).CornerRadius = UDim.new(0, 5)

ValEnemyColor.MouseButton1Click:Connect(function()
    Settings.EnemyColorIndex = Settings.EnemyColorIndex + 1
    if Settings.EnemyColorIndex > #ColorOptions then
        Settings.EnemyColorIndex = 1
    end
    local col = ColorOptions[Settings.EnemyColorIndex]
    ValEnemyColor.Text = col.Name
    ValEnemyColor.TextColor3 = col.Color
end)

-- TAB 3: Fly
local CardFly = createCard(3, 1)
local LblFly = Instance.new("TextLabel", CardFly)
LblFly.Size = UDim2.new(0, 200, 0, 34); LblFly.Position = UDim2.new(0, 12, 0, 0); LblFly.BackgroundTransparency = 1
LblFly.Font = Settings.CustomFont; LblFly.Text = "Fly Mode"; LblFly.TextColor3 = getTheme().Text; LblFly.TextSize = 14; LblFly.TextXAlignment = Enum.TextXAlignment.Left; LblFly.ZIndex = 4

local ToggleTrackFly = Instance.new("Frame", CardFly)
ToggleTrackFly.Size = UDim2.new(0, 34, 0, 18); ToggleTrackFly.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackFly.BackgroundColor3 = getTheme().Off; ToggleTrackFly.BorderSizePixel = 0; ToggleTrackFly.ZIndex = 4
Instance.new("UICorner", ToggleTrackFly).CornerRadius = UDim.new(1, 0)
local ToggleKnobFly = Instance.new("Frame", ToggleTrackFly)
ToggleKnobFly.Size = UDim2.new(0, 14, 0, 14); ToggleKnobFly.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobFly.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobFly.BorderSizePixel = 0; ToggleKnobFly.ZIndex = 5
Instance.new("UICorner", ToggleKnobFly).CornerRadius = UDim.new(1, 0)

local CardFlyNoClip = createCard(3, 2)
local LblFlyNoClip = Instance.new("TextLabel", CardFlyNoClip)
LblFlyNoClip.Size = UDim2.new(0, 200, 0, 34); LblFlyNoClip.Position = UDim2.new(0, 12, 0, 0); LblFlyNoClip.BackgroundTransparency = 1
LblFlyNoClip.Font = Settings.CustomFont; LblFlyNoClip.Text = "Fly NoClip"; LblFlyNoClip.TextColor3 = getTheme().Text; LblFlyNoClip.TextSize = 14; LblFlyNoClip.TextXAlignment = Enum.TextXAlignment.Left; LblFlyNoClip.ZIndex = 4

local ToggleTrackFlyNoClip = Instance.new("Frame", CardFlyNoClip)
ToggleTrackFlyNoClip.Size = UDim2.new(0, 34, 0, 18); ToggleTrackFlyNoClip.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackFlyNoClip.BackgroundColor3 = getTheme().Off; ToggleTrackFlyNoClip.BorderSizePixel = 0; ToggleTrackFlyNoClip.ZIndex = 4
Instance.new("UICorner", ToggleTrackFlyNoClip).CornerRadius = UDim.new(1, 0)
local ToggleKnobFlyNoClip = Instance.new("Frame", ToggleTrackFlyNoClip)
ToggleKnobFlyNoClip.Size = UDim2.new(0, 14, 0, 14); ToggleKnobFlyNoClip.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobFlyNoClip.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobFlyNoClip.BorderSizePixel = 0; ToggleKnobFlyNoClip.ZIndex = 5
Instance.new("UICorner", ToggleKnobFlyNoClip).CornerRadius = UDim.new(1, 0)

local CardFlySpeed = createCard(3, 3)
local LblFlySpeed = Instance.new("TextLabel", CardFlySpeed)
LblFlySpeed.Size = UDim2.new(0, 200, 0, 34); LblFlySpeed.Position = UDim2.new(0, 12, 0, 0); LblFlySpeed.BackgroundTransparency = 1
LblFlySpeed.Font = Settings.CustomFont; LblFlySpeed.Text = "Fly Speed"; LblFlySpeed.TextColor3 = getTheme().Text; LblFlySpeed.TextSize = 14; LblFlySpeed.TextXAlignment = Enum.TextXAlignment.Left; LblFlySpeed.ZIndex = 4

local FlySpeedTrack = Instance.new("Frame", CardFlySpeed)
FlySpeedTrack.Size = UDim2.new(0, 170, 0, 14); FlySpeedTrack.Position = UDim2.new(1, -182, 0.5, -7); FlySpeedTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); FlySpeedTrack.BorderSizePixel = 0; FlySpeedTrack.ZIndex = 4
Instance.new("UICorner", FlySpeedTrack).CornerRadius = UDim.new(1, 0)
local FlySpeedFill = Instance.new("Frame", FlySpeedTrack)
FlySpeedFill.Size = UDim2.new((Settings.FlySpeed - 10) / 290, 0, 1, 0); FlySpeedFill.BackgroundColor3 = getTheme().Accent; FlySpeedFill.BorderSizePixel = 0; FlySpeedFill.ZIndex = 5
Instance.new("UICorner", FlySpeedFill).CornerRadius = UDim.new(1, 0)
local FlySpeedText = Instance.new("TextLabel", FlySpeedTrack)
FlySpeedText.Size = UDim2.new(1, 0, 1, 0); FlySpeedText.BackgroundTransparency = 1; FlySpeedText.Font = Settings.CustomFont; FlySpeedText.Text = tostring(Settings.FlySpeed); FlySpeedText.TextColor3 = Color3.fromRGB(255, 255, 255); FlySpeedText.TextSize = 12; FlySpeedText.ZIndex = 6

local CardFlyVert = createCard(3, 4)
local LblFlyVert = Instance.new("TextLabel", CardFlyVert)
LblFlyVert.Size = UDim2.new(0, 200, 0, 34); LblFlyVert.Position = UDim2.new(0, 12, 0, 0); LblFlyVert.BackgroundTransparency = 1
LblFlyVert.Font = Settings.CustomFont; LblFlyVert.Text = "Vertical Speed"; LblFlyVert.TextColor3 = getTheme().Text; LblFlyVert.TextSize = 14; LblFlyVert.TextXAlignment = Enum.TextXAlignment.Left; LblFlyVert.ZIndex = 4

local FlyVertTrack = Instance.new("Frame", CardFlyVert)
FlyVertTrack.Size = UDim2.new(0, 170, 0, 14); FlyVertTrack.Position = UDim2.new(1, -182, 0.5, -7); FlyVertTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); FlyVertTrack.BorderSizePixel = 0; FlyVertTrack.ZIndex = 4
Instance.new("UICorner", FlyVertTrack).CornerRadius = UDim.new(1, 0)
local FlyVertFill = Instance.new("Frame", FlyVertTrack)
FlyVertFill.Size = UDim2.new((Settings.FlyVerticalSpeed - 10) / 290, 0, 1, 0); FlyVertFill.BackgroundColor3 = getTheme().Accent; FlyVertFill.BorderSizePixel = 0; FlyVertFill.ZIndex = 5
Instance.new("UICorner", FlyVertFill).CornerRadius = UDim.new(1, 0)
local FlyVertText = Instance.new("TextLabel", FlyVertTrack)
FlyVertText.Size = UDim2.new(1, 0, 1, 0); FlyVertText.BackgroundTransparency = 1; FlyVertText.Font = Settings.CustomFont; FlyVertText.Text = tostring(Settings.FlyVerticalSpeed); FlyVertText.TextColor3 = Color3.fromRGB(255, 255, 255); FlyVertText.TextSize = 12; FlyVertText.ZIndex = 6

-- TAB 4: Keybinds
local CardShowKeybindsHud = createCard(4, 1)
local LblShowKeybindsHud = Instance.new("TextLabel", CardShowKeybindsHud)
LblShowKeybindsHud.Size = UDim2.new(0, 200, 0, 34); LblShowKeybindsHud.Position = UDim2.new(0, 12, 0, 0); LblShowKeybindsHud.BackgroundTransparency = 1
LblShowKeybindsHud.Font = Settings.CustomFont; LblShowKeybindsHud.Text = "Show Keybinds HUD"; LblShowKeybindsHud.TextColor3 = getTheme().Text; LblShowKeybindsHud.TextSize = 14; LblShowKeybindsHud.TextXAlignment = Enum.TextXAlignment.Left; LblShowKeybindsHud.ZIndex = 4

local ToggleTrackKeybindsHud = Instance.new("Frame", CardShowKeybindsHud)
ToggleTrackKeybindsHud.Size = UDim2.new(0, 34, 0, 18); ToggleTrackKeybindsHud.Position = UDim2.new(1, -46, 0.5, -9); ToggleTrackKeybindsHud.BackgroundColor3 = getTheme().Off; ToggleTrackKeybindsHud.BorderSizePixel = 0; ToggleTrackKeybindsHud.ZIndex = 4
Instance.new("UICorner", ToggleTrackKeybindsHud).CornerRadius = UDim.new(1, 0)
local ToggleKnobKeybindsHud = Instance.new("Frame", ToggleTrackKeybindsHud)
ToggleKnobKeybindsHud.Size = UDim2.new(0, 14, 0, 14); ToggleKnobKeybindsHud.Position = UDim2.new(0, 2, 0.5, -7); ToggleKnobKeybindsHud.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ToggleKnobKeybindsHud.BorderSizePixel = 0; ToggleKnobKeybindsHud.ZIndex = 5
Instance.new("UICorner", ToggleKnobKeybindsHud).CornerRadius = UDim.new(1, 0)

local function createKeybindCard(labelText, settingKey, order)
    local card = createCard(4, order)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0, 200, 0, 34); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Font = Settings.CustomFont; lbl.Text = labelText; lbl.TextColor3 = getTheme().Text; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4

    local val = Instance.new("TextLabel", card)
    val.Size = UDim2.new(0, 100, 0, 34); val.Position = UDim2.new(1, -112, 0, 0); val.BackgroundTransparency = 1
    val.Font = Settings.CustomFont; val.Text = "[" .. getKeyName(Settings[settingKey]) .. "]"; val.TextColor3 = getTheme().Accent; val.TextSize = 13; val.TextXAlignment = Enum.TextXAlignment.Right; val.ZIndex = 4

    return card, val
end

local CardKeyAimbot, ValKeyAimbot = createKeybindCard("Aimbot", "KeyAimbot", 2)
local CardKeyESP, ValKeyESP = createKeybindCard("Highlight ESP", "KeyESP", 3)
local CardKeyFly, ValKeyFly = createKeybindCard("Fly", "KeyFly", 4)
local CardKeyMenu, ValKeyMenu = createKeybindCard("Menu Toggle", "KeyToggleMenu", 5)
local CardUnload, ValKeyUnload = createKeybindCard("Unload", "KeyUnload", 6)

-- TAB 5: Settings
local CardTheme = createCard(5, 1)
local LblTheme = Instance.new("TextLabel", CardTheme)
LblTheme.Size = UDim2.new(0, 200, 0, 34); LblTheme.Position = UDim2.new(0, 12, 0, 0); LblTheme.BackgroundTransparency = 1
LblTheme.Font = Settings.CustomFont; LblTheme.Text = "UI Theme Color"; LblTheme.TextColor3 = getTheme().Text; LblTheme.TextSize = 14; LblTheme.TextXAlignment = Enum.TextXAlignment.Left; LblTheme.ZIndex = 4

local ValTheme = Instance.new("TextButton", CardTheme)
ValTheme.Size = UDim2.new(0, 130, 0, 24); ValTheme.Position = UDim2.new(1, -142, 0.5, -12); ValTheme.BackgroundColor3 = Color3.fromRGB(35, 35, 42); ValTheme.BorderSizePixel = 0
ValTheme.Font = Settings.CustomFont; ValTheme.Text = Themes[Settings.ThemeIndex].Name; ValTheme.TextColor3 = getTheme().Accent; ValTheme.TextSize = 13; ValTheme.ZIndex = 4
Instance.new("UICorner", ValTheme).CornerRadius = UDim.new(0, 5)

local updateThemeColors

ValTheme.MouseButton1Click:Connect(function()
    Settings.ThemeIndex = Settings.ThemeIndex + 1
    if Settings.ThemeIndex > #Themes then
        Settings.ThemeIndex = 1
    end
    local th = Themes[Settings.ThemeIndex]
    ValTheme.Text = th.Name
    updateThemeColors()
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Radius = Settings.FOVSize
fovCircle.Color = ColorOptions[Settings.FOVColorIndex].Color
fovCircle.Transparency = 0.7
fovCircle.Visible = false
fovCircle.Filled = false

local espDrawings = {}

local function createDrawingESP(player)
    if espDrawings[player] then return end
    local drawings = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBarBackground = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
        Skeleton = {},
        Highlight = Instance.new("Highlight")
    }
    
    drawings.BoxOutline.Thickness = 3; drawings.BoxOutline.Filled = false; drawings.BoxOutline.Color = Color3.fromRGB(0, 0, 0); drawings.BoxOutline.Visible = false
    drawings.Box.Thickness = 1.5; drawings.Box.Filled = false; drawings.Box.Visible = false
    drawings.Name.Size = 13; drawings.Name.Center = true; drawings.Name.Outline = true; drawings.Name.Color = Color3.fromRGB(255, 255, 255); drawings.Name.Visible = false
    drawings.HealthBarBackground.Thickness = 4; drawings.HealthBarBackground.Color = Color3.fromRGB(0, 0, 0); drawings.HealthBarBackground.Visible = false
    drawings.HealthBar.Thickness = 2; drawings.HealthBar.Visible = false
    drawings.Tracer.Thickness = 1.5; drawings.Tracer.Visible = false

    drawings.Highlight.FillTransparency = 0.5; drawings.Highlight.OutlineTransparency = 0; drawings.Highlight.Enabled = false
    
    for i = 1, 16 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Visible = false
        table.insert(drawings.Skeleton, line)
    end
    
    espDrawings[player] = drawings
end

local function removeDrawingESP(player)
    if espDrawings[player] then
        for name, obj in pairs(espDrawings[player]) do
            if type(obj) == "table" then
                for _, line in ipairs(obj) do pcall(function() line:Remove() end) end
            elseif name == "Highlight" then
                pcall(function() obj:Destroy() end)
            else
                pcall(function() obj:Remove() end)
            end
        end
        espDrawings[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= Player then createDrawingESP(p) end end
Players.PlayerAdded:Connect(createDrawingESP)
Players.PlayerRemoving:Connect(removeDrawingESP)

local menuVisible = true

local function updateSliderTextColors()
    local isWhite = (Settings.ThemeIndex == 1)
    local darkColor = Color3.fromRGB(18, 18, 20)
    local lightColor = Color3.fromRGB(255, 255, 255)
    TargetingSliderText.TextColor3 = (isWhite and Settings.TargetingSmoothness >= 0.5) and darkColor or lightColor
    TrackingSliderText.TextColor3 = (isWhite and Settings.TrackingSmoothness >= 0.5) and darkColor or lightColor
    TriggerDelayText.TextColor3 = (isWhite and (Settings.TriggerbotDelay / 1.0) >= 0.5) and darkColor or lightColor
    FOVSliderText.TextColor3 = (isWhite and (Settings.FOVSize / 400) >= 0.5) and darkColor or lightColor
    FlySpeedText.TextColor3 = (isWhite and ((Settings.FlySpeed - 10) / 290) >= 0.5) and darkColor or lightColor
    FlyVertText.TextColor3 = (isWhite and ((Settings.FlyVerticalSpeed - 10) / 290) >= 0.5) and darkColor or lightColor
end

updateThemeColors = function()
    local t = getTheme()
    MainFrame.BackgroundColor3 = t.Bg
    Title.TextColor3 = t.Text
    KeybindsHud.BackgroundColor3 = t.Card
    HudStatusUnload.TextColor3 = t.SubText
    ResizeHandle.TextColor3 = t.SubText
    
    for i, tabBtn in ipairs({Tab1, Tab2, Tab3, Tab4, Tab5}) do
        tabBtn.BackgroundColor3 = (currentTab == i) and t.TabActive or t.TabInactive
        tabBtn.TextColor3 = (currentTab == i) and t.Text or t.SubText
    end
    
    for _, scroller in ipairs(tabContainers) do
        scroller.ScrollBarImageColor3 = t.Accent
        for _, child in ipairs(scroller:GetChildren()) do
            if child:IsA("Frame") then child.BackgroundColor3 = t.Card end
        end
    end
    
    ValTarget.TextColor3 = t.Accent
    ValAimbotMode.TextColor3 = t.Accent
    ValTheme.TextColor3 = t.Accent
    TargetingSliderFill.BackgroundColor3 = t.Accent
    TrackingSliderFill.BackgroundColor3 = t.Accent
    TriggerDelayFill.BackgroundColor3 = t.Accent
    FOVSliderFill.BackgroundColor3 = t.Accent
    FlySpeedFill.BackgroundColor3 = t.Accent
    FlyVertFill.BackgroundColor3 = t.Accent
    
    ToggleTrack1.BackgroundColor3 = Settings.AimbotEnabled and t.Accent or t.Off
    ToggleTrackTrigger.BackgroundColor3 = Settings.TriggerbotEnabled and t.Accent or t.Off
    ToggleTrackTeamCheck.BackgroundColor3 = Settings.TeamCheck and t.Accent or t.Off
    ToggleTrackWall.BackgroundColor3 = Settings.WallCheck and t.Accent or t.Off
    ToggleTrack3.BackgroundColor3 = Settings.ShowFOV and t.Accent or t.Off
    TrackTeamCheckESP.BackgroundColor3 = Settings.TeamCheckESP and t.Accent or t.Off
    TrackEspHighlight.BackgroundColor3 = Settings.ESPHighlight and t.Accent or t.Off
    TrackEspBox.BackgroundColor3 = Settings.ESPBox and t.Accent or t.Off
    TrackEspName.BackgroundColor3 = Settings.ESPName and t.Accent or t.Off
    TrackEspHealth.BackgroundColor3 = Settings.ESPHealth and t.Accent or t.Off
    TrackEspSkeleton.BackgroundColor3 = Settings.ESPSkeleton and t.Accent or t.Off
    TrackEspTracers.BackgroundColor3 = Settings.ESPTracers and t.Accent or t.Off
    ToggleTrackFly.BackgroundColor3 = Settings.FlyActive and t.Accent or t.Off
    ToggleTrackFlyNoClip.BackgroundColor3 = Settings.FlyNoClip and t.Accent or t.Off
    ToggleTrackKeybindsHud.BackgroundColor3 = Settings.ShowKeybindsHud and t.Accent or t.Off
    
    updateSliderTextColors()
end

local function switchTab(tabIndex)
    currentTab = tabIndex
    for i, scroller in ipairs(tabContainers) do
        scroller.Visible = (i == tabIndex and menuVisible)
    end
    updateThemeColors()
end

local function setVisibility(state)
    MainFrame.Visible = state
    switchTab(currentTab)
end

local function updateUIStates()
    local t = getTheme()
    ToggleTrack1.BackgroundColor3 = Settings.AimbotEnabled and t.Accent or t.Off
    ToggleKnob1.Position = Settings.AimbotEnabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    
    ToggleTrackTrigger.BackgroundColor3 = Settings.TriggerbotEnabled and t.Accent or t.Off
    ToggleKnobTrigger.Position = Settings.TriggerbotEnabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    ValTarget.Text = Settings.TargetPart
    ValAimbotMode.Text = Settings.AimbotMode

    ToggleTrackTeamCheck.BackgroundColor3 = Settings.TeamCheck and t.Accent or t.Off
    ToggleKnobTeamCheck.Position = Settings.TeamCheck and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    ToggleTrackWall.BackgroundColor3 = Settings.WallCheck and t.Accent or t.Off
    ToggleKnobWall.Position = Settings.WallCheck and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    ToggleTrack3.BackgroundColor3 = Settings.ShowFOV and t.Accent or t.Off
    ToggleKnob3.Position = Settings.ShowFOV and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    TrackTeamCheckESP.BackgroundColor3 = Settings.TeamCheckESP and t.Accent or t.Off
    KnobTeamCheckESP.Position = Settings.TeamCheckESP and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    TrackEspHighlight.BackgroundColor3 = Settings.ESPHighlight and t.Accent or t.Off
    KnobEspHighlight.Position = Settings.ESPHighlight and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    
    TrackEspBox.BackgroundColor3 = Settings.ESPBox and t.Accent or t.Off
    KnobEspBox.Position = Settings.ESPBox and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    TrackEspName.BackgroundColor3 = Settings.ESPName and t.Accent or t.Off
    KnobEspName.Position = Settings.ESPName and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    TrackEspHealth.BackgroundColor3 = Settings.ESPHealth and t.Accent or t.Off
    KnobEspHealth.Position = Settings.ESPHealth and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    TrackEspSkeleton.BackgroundColor3 = Settings.ESPSkeleton and t.Accent or t.Off
    KnobEspSkeleton.Position = Settings.ESPSkeleton and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    TrackEspTracers.BackgroundColor3 = Settings.ESPTracers and t.Accent or t.Off
    KnobEspTracers.Position = Settings.ESPTracers and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    ToggleTrackFly.BackgroundColor3 = Settings.FlyActive and t.Accent or t.Off
    ToggleKnobFly.Position = Settings.FlyActive and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    ToggleTrackFlyNoClip.BackgroundColor3 = Settings.FlyNoClip and t.Accent or t.Off
    ToggleKnobFlyNoClip.Position = Settings.FlyNoClip and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    ToggleTrackKeybindsHud.BackgroundColor3 = Settings.ShowKeybindsHud and t.Accent or t.Off
    ToggleKnobKeybindsHud.Position = Settings.ShowKeybindsHud and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    KeybindsHud.Visible = Settings.ShowKeybindsHud

    ValTheme.Text = Themes[Settings.ThemeIndex].Name
    ValKeyAimbot.Text = "[" .. (listeningForKey == "KeyAimbot" and "..." or getKeyName(Settings.KeyAimbot)) .. "]"
    ValKeyESP.Text = "[" .. (listeningForKey == "KeyESP" and "..." or getKeyName(Settings.KeyESP)) .. "]"
    ValKeyFly.Text = "[" .. (listeningForKey == "KeyFly" and "..." or getKeyName(Settings.KeyFly)) .. "]"
    ValKeyMenu.Text = "[" .. (listeningForKey == "KeyToggleMenu" and "..." or getKeyName(Settings.KeyToggleMenu)) .. "]"
    ValKeyUnload.Text = "[" .. (listeningForKey == "KeyUnload" and "..." or getKeyName(Settings.KeyUnload)) .. "]"

    HudRowAimbot.Text = "Aimbot [" .. getKeyName(Settings.KeyAimbot) .. "]"
    HudRowESP.Text = "ESP [" .. getKeyName(Settings.KeyESP) .. "]"
    HudRowFly.Text = "Fly [" .. getKeyName(Settings.KeyFly) .. "]"
    HudRowMenu.Text = "Menu [" .. getKeyName(Settings.KeyToggleMenu) .. "]"
    HudStatusUnload.Text = "Press " .. getKeyName(Settings.KeyUnload) .. " to Unload"

    local isAimbotActive = (Settings.AimbotMode == "Hold") and isAimbotHeld or Settings.AimbotEnabled
    HudStatusAimbot.Text = isAimbotActive and "ON" or "OFF"
    HudStatusAimbot.TextColor3 = isAimbotActive and t.Accent or Color3.fromRGB(239, 68, 68)

    local espActive = Settings.ESPHighlight or Settings.ESPBox or Settings.ESPName or Settings.ESPHealth or Settings.ESPSkeleton or Settings.ESPTracers
    HudStatusESP.Text = espActive and "ON" or "OFF"
    HudStatusESP.TextColor3 = espActive and t.Accent or Color3.fromRGB(239, 68, 68)

    HudStatusFly.Text = Settings.FlyActive and "ON" or "OFF"
    HudStatusFly.TextColor3 = Settings.FlyActive and t.Accent or Color3.fromRGB(239, 68, 68)

    HudStatusMenu.Text = menuVisible and "ON" or "OFF"
    HudStatusMenu.TextColor3 = menuVisible and t.Accent or Color3.fromRGB(239, 68, 68)
end

local function unloadHub()
    if isShooting then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        isShooting = false
    end
    for _, conn in ipairs(connections) do conn:Disconnect() end
    pcall(function() fovCircle:Remove() end)
    for p, _ in pairs(espDrawings) do removeDrawingESP(p) end
    ScreenGui:Destroy()
    local char = Player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then 
        humanoid.PlatformStand = false 
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

local draggingMain = false
local dragStartMain, startPosMain

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingMain = false end
        end)
    end
end)

local draggingHud = false
local dragStartHud, startPosHud

KeybindsHud.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingHud = true
        dragStartHud = input.Position
        startPosHud = KeybindsHud.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingHud = false end
        end)
    end
end)

local resizingMain = false
local resizeStartPos, startSizeMain

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizingMain = true
        resizeStartPos = input.Position
        startSizeMain = MainFrame.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then resizingMain = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingMain then
            local delta = input.Position - dragStartMain
            MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        elseif draggingHud then
            local delta = input.Position - dragStartHud
            KeybindsHud.Position = UDim2.new(startPosHud.X.Scale, startPosHud.X.Offset + delta.X, startPosHud.Y.Scale, startPosHud.Y.Offset + delta.Y)
        elseif resizingMain then
            local delta = input.Position - resizeStartPos
            local newWidth = math.clamp(startSizeMain.X + delta.X, 350, 800)
            local newHeight = math.clamp(startSizeMain.Y + delta.Y, 250, 600)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end
end)

table.insert(connections, Tab1.MouseButton1Click:Connect(function() switchTab(1) end))
table.insert(connections, Tab2.MouseButton1Click:Connect(function() switchTab(2) end))
table.insert(connections, Tab3.MouseButton1Click:Connect(function() switchTab(3) end))
table.insert(connections, Tab4.MouseButton1Click:Connect(function() switchTab(4) end))
table.insert(connections, Tab5.MouseButton1Click:Connect(function() switchTab(5) end))

table.insert(connections, Card1.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.AimbotEnabled = not Settings.AimbotEnabled; updateUIStates() end end))
table.insert(connections, CardTriggerbot.InputBegan:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
        Settings.TriggerbotEnabled = not Settings.TriggerbotEnabled 
        if not Settings.TriggerbotEnabled and isShooting then
            pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
            isShooting = false
        end
        updateUIStates() 
    end 
end))
table.insert(connections, CardTeamCheck.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.TeamCheck = not Settings.TeamCheck; updateUIStates() end end))
table.insert(connections, CardWallCheck.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.WallCheck = not Settings.WallCheck; updateUIStates() end end))
table.insert(connections, CardFOV.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ShowFOV = not Settings.ShowFOV; updateUIStates() end end))

table.insert(connections, CardTeamCheckESP.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.TeamCheckESP = not Settings.TeamCheckESP; updateUIStates() end end))
table.insert(connections, CardEspHighlight.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPHighlight = not Settings.ESPHighlight; updateUIStates() end end))
table.insert(connections, CardEspBox.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPBox = not Settings.ESPBox; updateUIStates() end end))
table.insert(connections, CardEspName.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPName = not Settings.ESPName; updateUIStates() end end))
table.insert(connections, CardEspHealth.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPHealth = not Settings.ESPHealth; updateUIStates() end end))
table.insert(connections, CardEspSkeleton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPSkeleton = not Settings.ESPSkeleton; updateUIStates() end end))
table.insert(connections, CardEspTracers.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPTracers = not Settings.ESPTracers; updateUIStates() end end))

table.insert(connections, CardFly.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.FlyActive = not Settings.FlyActive; updateUIStates() end end))
table.insert(connections, CardFlyNoClip.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.FlyNoClip = not Settings.FlyNoClip; updateUIStates() end end))
table.insert(connections, CardShowKeybindsHud.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ShowKeybindsHud = not Settings.ShowKeybindsHud; updateUIStates() end end))

table.insert(connections, TargetingSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingTargetingSlider = true end end))
table.insert(connections, TrackingSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingTrackingSlider = true end end))
table.insert(connections, TriggerDelayTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingTriggerDelaySlider = true end end))
table.insert(connections, FOVSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOVSlider = true end end))
table.insert(connections, FlySpeedTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFlySpeedSlider = true end end))
table.insert(connections, FlyVertTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFlyVertSlider = true end end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingTargetingSlider = false; draggingTrackingSlider = false; draggingTriggerDelaySlider = false; draggingFOVSlider = false; draggingFlySpeedSlider = false; draggingFlyVertSlider = false; resizingMain = false
    end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        if draggingTargetingSlider then
            local absPos = TargetingSliderTrack.AbsolutePosition; local absSize = TargetingSliderTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            TargetingSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TargetingSmoothness = math.floor(pos * 100) / 100; TargetingSliderText.Text = math.floor(pos * 100) .. "%"
            updateSliderTextColors()
        elseif draggingTrackingSlider then
            local absPos = TrackingSliderTrack.AbsolutePosition; local absSize = TrackingSliderTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            TrackingSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TrackingSmoothness = math.floor(pos * 100) / 100; TrackingSliderText.Text = math.floor(pos * 100) .. "%"
            updateSliderTextColors()
        elseif draggingTriggerDelaySlider then
            local absPos = TriggerDelayTrack.AbsolutePosition; local absSize = TriggerDelayTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            TriggerDelayFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TriggerbotDelay = math.floor(pos * 100) / 100; TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay)
            updateSliderTextColors()
        elseif draggingFOVSlider then
            local absPos = FOVSliderTrack.AbsolutePosition; local absSize = FOVSliderTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            FOVSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FOVSize = math.floor(pos * 400) + 1; FOVSliderText.Text = tostring(Settings.FOVSize); fovCircle.Radius = Settings.FOVSize
            updateSliderTextColors()
        elseif draggingFlySpeedSlider then
            local absPos = FlySpeedTrack.AbsolutePosition; local absSize = FlySpeedTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            FlySpeedFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FlySpeed = math.floor(pos * 290) + 10; FlySpeedText.Text = tostring(Settings.FlySpeed)
            updateSliderTextColors()
        elseif draggingFlyVertSlider then
            local absPos = FlyVertTrack.AbsolutePosition; local absSize = FlyVertTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            FlyVertFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FlyVerticalSpeed = math.floor(pos * 290) + 10; FlyVertText.Text = tostring(Settings.FlyVerticalSpeed)
            updateSliderTextColors()
        end
    end
end))

local function setupKeybindCard(card, settingKey)
    table.insert(connections, card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            listeningForKey = settingKey
            ignoreNextClick = true
            updateUIStates()
        end
    end))
end

setupKeybindCard(CardKeyAimbot, "KeyAimbot")
setupKeybindCard(CardKeyESP, "KeyESP")
setupKeybindCard(CardKeyFly, "KeyFly")
setupKeybindCard(CardKeyMenu, "KeyToggleMenu")
setupKeybindCard(CardUnload, "KeyUnload")

local function isInputMatching(input, bind)
    if not bind then return false end
    if typeof(bind) == "EnumItem" then
        if bind.EnumType == Enum.KeyCode and input.UserInputType == Enum.UserInputType.Keyboard then
            return input.KeyCode == bind
        elseif bind.EnumType == Enum.UserInputType then
            return input.UserInputType == bind
        end
    end
    return false
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input)
    if listeningForKey then
        if ignoreNextClick then
            ignoreNextClick = false
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Settings[listeningForKey] = input.KeyCode
            listeningForKey = nil
            updateUIStates()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
            Settings[listeningForKey] = input.UserInputType
            listeningForKey = nil
            updateUIStates()
        end
        return
    end

    if isInputMatching(input, Settings.KeyToggleMenu) then
        menuVisible = not menuVisible; setVisibility(menuVisible); updateUIStates()
    elseif isInputMatching(input, Settings.KeyUnload) then
        unloadHub()
    elseif isInputMatching(input, Settings.KeyESP) then
        Settings.ESPHighlight = not Settings.ESPHighlight; updateUIStates()
    elseif isInputMatching(input, Settings.KeyFly) then
        Settings.FlyActive = not Settings.FlyActive; updateUIStates()
    elseif isInputMatching(input, Settings.KeyAimbot) then
        if Settings.AimbotMode == "Toggle" then
            Settings.AimbotEnabled = not Settings.AimbotEnabled
        else
            isAimbotHeld = true
        end
        updateUIStates()
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if isInputMatching(input, Settings.KeyAimbot) and Settings.AimbotMode == "Hold" then
        isAimbotHeld = false
        updateUIStates()
    end
end))

local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    local char = Player.Character; if not char then return false end
    local originHead = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"); if not originHead then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char, Camera, targetPart.Parent}
    
    local rayDir = (targetPart.Position - originHead.Position)
    local result = workspace:Raycast(originHead.Position, rayDir, rayParams)
    
    return result == nil
end

local function isTeammate(player)
    if player == Player then return true end
    if player.Team and Player.Team and player.Team == Player.Team then 
        return true 
    end
    return false
end

local function isWeaponAutomatic(tool)
    if not tool then return true end
    if tool:GetAttribute("Auto") ~= nil then
        return tool:GetAttribute("Auto")
    elseif tool:GetAttribute("FireMode") == "Semi" then
        return false
    end
    local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Settings") or tool:FindFirstChild("Config")
    if config then
        local autoVal = config:FindFirstChild("Auto") or config:FindFirstChild("FullyAutomatic")
        if autoVal and autoVal:IsA("BoolValue") then
            return autoVal.Value
        end
    end
    return true
end

local function getClosestTarget()
    local bestTarget = nil
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestMagnitude = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character then
            if not Settings.TeamCheck or not isTeammate(v) then
                local character = v.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = (Settings.TargetPart == "Chest") 
                        and (character:FindFirstChild("LowerTorso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")) 
                        or character:FindFirstChild("Head")
                        
                    if targetPart then
                        local rootScreenPos, rootOnScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if rootOnScreen then
                            local mag = (viewportCenter - Vector2.new(rootScreenPos.X, rootScreenPos.Y)).Magnitude
                            if mag <= Settings.FOVSize and mag < bestMagnitude then
                                if isVisible(targetPart) then
                                    bestMagnitude = mag
                                    bestTarget = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

table.insert(connections, RunService.RenderStepped:Connect(function(deltaTime)
    fovCircle.Visible = Settings.ShowFOV and (Settings.FOVSize > 0)
    if Settings.ShowFOV and Settings.FOVSize > 0 then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Settings.FOVSize
        fovCircle.Color = ColorOptions[Settings.FOVColorIndex].Color
    end

    local aimbotActive = (Settings.AimbotMode == "Hold" and isAimbotHeld) or (Settings.AimbotMode == "Toggle" and Settings.AimbotEnabled)

    local target = getClosestTarget()
    if target then
        if aimbotActive then
            local goalCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            local targetScreenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local distFromCenter = onScreen and (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - viewportCenter).Magnitude or 0
            
            local isCloseToTarget = distFromCenter < 25
            local activeSmoothness = isCloseToTarget and Settings.TrackingSmoothness or Settings.TargetingSmoothness
            
            local smoothFactor = math.clamp((1 - activeSmoothness) * (deltaTime * 60), 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, smoothFactor)
        end

        if Settings.TriggerbotEnabled then
            local character = target.Parent
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local currentTool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
                local isAuto = isWeaponAutomatic(currentTool)
                
                if isAuto then
                    if not isShooting then
                        isShooting = true
                        task.spawn(function()
                            pcall(function()
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            end)
                        end)
                    end
                else
                    local currentTime = tick()
                    if currentTime - lastTriggerShot >= Settings.SemiDelay then
                        lastTriggerShot = currentTime
                        task.spawn(function()
                            pcall(function()
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.03)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end)
                        end)
                    end
                end
            else
                if isShooting then
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                    isShooting = false
                end
            end
        end
    else
        if isShooting then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
            isShooting = false
        end
    end

    for _, v in pairs(Players:GetPlayers()) do
        local drawings = espDrawings[v]
        if v ~= Player and v.Character and drawings then
            local character = v.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            local active = hrp and head and humanoid and humanoid.Health > 0
            local teammate = isTeammate(v)
            
            if Settings.TeamCheckESP and teammate then
                drawings.Highlight.Enabled = false
                drawings.Box.Visible = false
                drawings.BoxOutline.Visible = false
                drawings.Name.Visible = false
                drawings.HealthBar.Visible = false
                drawings.HealthBarBackground.Visible = false
                drawings.Tracer.Visible = false
                for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
            else
                local targetColor = teammate and ColorOptions[Settings.TeammateColorIndex].Color or ColorOptions[Settings.EnemyColorIndex].Color
                
                if Settings.ESPHighlight and active then
                    drawings.Highlight.Parent = character
                    drawings.Highlight.FillColor = targetColor
                    drawings.Highlight.OutlineColor = targetColor
                    drawings.Highlight.Enabled = true
                else
                    drawings.Highlight.Enabled = false
                end
                
                if active then
                    local cf, size = character:GetBoundingBox()
                    local topScreen, topOnScreen = Camera:WorldToViewportPoint((cf + Vector3.new(0, size.Y / 2, 0)).Position)
                    local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint((cf - Vector3.new(0, size.Y / 2, 0)).Position)
                    
                    if topOnScreen or bottomOnScreen then
                        local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
                        local boxWidth = boxHeight / 2
                        local boxPos = Vector2.new(topScreen.X - boxWidth / 2, topScreen.Y)
                        
                        if Settings.ESPBox then
                            drawings.BoxOutline.Visible = true; drawings.Box.Visible = true
                            drawings.BoxOutline.Size = Vector2.new(boxWidth, boxHeight); drawings.BoxOutline.Position = boxPos
                            drawings.Box.Size = Vector2.new(boxWidth, boxHeight); drawings.Box.Position = boxPos; drawings.Box.Color = targetColor
                        else
                            drawings.BoxOutline.Visible = false; drawings.Box.Visible = false
                        end
                        
                        if Settings.ESPName then
                            drawings.Name.Visible = true; drawings.Name.Text = v.Name; drawings.Name.Position = Vector2.new(bottomScreen.X, bottomScreen.Y + 4); drawings.Name.Color = targetColor
                        else
                            drawings.Name.Visible = false
                        end
                        
                        if Settings.ESPHealth then
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            local barHeight = boxHeight * healthPercent
                            drawings.HealthBarBackground.Visible = true
                            drawings.HealthBarBackground.From = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                            drawings.HealthBarBackground.To = Vector2.new(boxPos.X - 6, boxPos.Y)
                            drawings.HealthBar.Visible = true
                            drawings.HealthBar.From = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                            drawings.HealthBar.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight - barHeight)
                            drawings.HealthBar.Color = (healthPercent > 0.5) and Color3.fromRGB(34, 197, 94) or (healthPercent > 0.25 and Color3.fromRGB(249, 115, 22) or Color3.fromRGB(239, 68, 68))
                        else
                            drawings.HealthBar.Visible = false; drawings.HealthBarBackground.Visible = false
                        end
                        
                        if Settings.ESPSkeleton then
                            local bonePairs = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}
                            local activeBonesCount = 0
                            for _, pair in ipairs(bonePairs) do
                                local p1 = character:FindFirstChild(pair[1]); local p2 = character:FindFirstChild(pair[2])
                                if p1 and p2 then
                                    activeBonesCount = activeBonesCount + 1
                                    local line = drawings.Skeleton[activeBonesCount]
                                    if line then
                                        local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                                        local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                                        if o1 and o2 then
                                            line.Visible = true; line.From = Vector2.new(s1.X, s1.Y); line.To = Vector2.new(s2.X, s2.Y); line.Color = targetColor
                                        else
                                            line.Visible = false
                                        end
                                    end
                                end
                            end
                        else
                            for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
                        end
                        
                        if Settings.ESPTracers then
                            drawings.Tracer.Visible = true; drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); drawings.Tracer.To = Vector2.new(bottomScreen.X, bottomScreen.Y); drawings.Tracer.Color = targetColor
                        else
                            drawings.Tracer.Visible = false
                        end
                    else
                        drawings.Box.Visible = false; drawings.BoxOutline.Visible = false; drawings.Name.Visible = false; drawings.HealthBar.Visible = false; drawings.HealthBarBackground.Visible = false; drawings.Tracer.Visible = false
                        for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
                    end
                else
                    drawings.Box.Visible = false; drawings.BoxOutline.Visible = false; drawings.Name.Visible = false; drawings.HealthBar.Visible = false; drawings.HealthBarBackground.Visible = false; drawings.Tracer.Visible = false
                    for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
                end
            end
        end
    end

    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local hrp = char.HumanoidRootPart; local humanoid = char:FindFirstChildOfClass("Humanoid")
        if Settings.FlyActive then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end)
            humanoid.PlatformStand = true
            
            local flyVel = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then flyVel = flyVel + (Camera.CFrame.LookVector * Settings.FlySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then flyVel = flyVel - (Camera.CFrame.LookVector * Settings.FlySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then flyVel = flyVel - (Camera.CFrame.RightVector * Settings.FlySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then flyVel = flyVel + (Camera.CFrame.RightVector * Settings.FlySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyVel = flyVel + (Vector3.new(0, Settings.FlyVerticalSpeed, 0)) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then flyVel = flyVel - (Vector3.new(0, Settings.FlyVerticalSpeed, 0)) end
            
            hrp.AssemblyLinearVelocity = flyVel
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            if Settings.FlyNoClip then
                for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
            end
        else
            if humanoid.PlatformStand and not Settings.FlyActive then 
                humanoid.PlatformStand = false 
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end
    end
end))
