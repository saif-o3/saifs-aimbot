local Settings = {
    AimbotEnabled = false,
    SilentAimEnabled = false,
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
    
    ESPHighlight = false,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    ESPSkeleton = false,
    ESPTracers = false,
    ESPHeadDot = false,
    TeamCheckESP = false,

    FlyActive = false,
    FlySpeed = 50,
    FlyVerticalSpeed = 50,
    FlyNoClip = false,
    
    WalkSpeedActive = false,
    WalkSpeedValue = 16,
    JumpPowerActive = false,
    JumpPowerValue = 50,
    InfiniteJumpActive = false,

    ShowKeybindsHud = false,
    CustomFont = Enum.Font.FredokaOne,
    
    KeyAimbot = Enum.KeyCode.V,
    KeySilentAim = Enum.KeyCode.B,
    KeyFly = Enum.KeyCode.X,
    KeyToggleMenu = Enum.KeyCode.LeftAlt,
    KeyUnload = Enum.KeyCode.U,
    
    TeleportOffsetMode = "In Front"
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

local UIState = {
    draggingTargetingSlider = false,
    draggingTrackingSlider = false,
    draggingTriggerDelaySlider = false,
    draggingFOVSlider = false,
    draggingFlySpeedSlider = false,
    draggingFlyVertSlider = false,
    draggingWalkSpeedSlider = false,
    draggingJumpPowerSlider = false,
    lastTriggerShot = 0,
    isShooting = false,
    isAimbotHeld = false,
    menuVisible = true,
    currentTab = 1
}

local UI = {}

local successGui, parentContainer = pcall(function() return CoreGui end)
if not successGui or not parentContainer then parentContainer = Player:WaitForChild("PlayerGui") end
if parentContainer:FindFirstChild("SaifsAimbotGui") then parentContainer.SaifsAimbotGui:Destroy() end

UI.ScreenGui = Instance.new("ScreenGui", parentContainer)
UI.ScreenGui.Name = "SaifsAimbotGui"
UI.ScreenGui.ResetOnSpawn = false
UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Theme = {
    Accent = Color3.fromRGB(147, 51, 234),
    Bg = Color3.fromRGB(18, 18, 20),
    Card = Color3.fromRGB(26, 26, 30),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(130, 130, 145),
    Off = Color3.fromRGB(60, 60, 70),
    TabActive = Color3.fromRGB(38, 38, 45),
    TabInactive = Color3.fromRGB(22, 22, 26)
}

UI.MainFrame = Instance.new("Frame", UI.ScreenGui)
UI.MainFrame.Name = "MainFrame"
UI.MainFrame.Size = UDim2.new(0, 520, 0, 390)
UI.MainFrame.Position = UDim2.new(0.5, -260, 0.5, -195)
UI.MainFrame.BackgroundColor3 = Theme.Bg
UI.MainFrame.BorderSizePixel = 0
UI.MainFrame.ZIndex = 1
Instance.new("UICorner", UI.MainFrame).CornerRadius = UDim.new(0, 10)

UI.ResizeHandle = Instance.new("TextButton", UI.MainFrame)
UI.ResizeHandle.Name = "ResizeHandle"
UI.ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
UI.ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
UI.ResizeHandle.BackgroundTransparency = 1
UI.ResizeHandle.Text = "◢"
UI.ResizeHandle.TextColor3 = Theme.SubText
UI.ResizeHandle.TextSize = 12
UI.ResizeHandle.ZIndex = 10

UI.Title = Instance.new("TextLabel", UI.MainFrame)
UI.Title.Size = UDim2.new(0, 200, 0, 25)
UI.Title.Position = UDim2.new(0, 15, 0, 12)
UI.Title.BackgroundTransparency = 1
UI.Title.Font = Settings.CustomFont
UI.Title.Text = "Saif's Aimbot"
UI.Title.TextColor3 = Theme.Text
UI.Title.TextSize = 18
UI.Title.TextXAlignment = Enum.TextXAlignment.Left
UI.Title.ZIndex = 2

local function getKeyName(inputObj)
    if not inputObj then return "None" end
    if typeof(inputObj) == "EnumItem" then
        if inputObj.EnumType == Enum.KeyCode then return inputObj.Name end
        if inputObj.EnumType == Enum.UserInputType then
            if inputObj == Enum.UserInputType.MouseButton1 then return "MB1" end
            if inputObj == Enum.UserInputType.MouseButton2 then return "MB2" end
            if inputObj == Enum.UserInputType.MouseButton3 then return "MB3" end
            return inputObj.Name
        end
    end
    return tostring(inputObj)
end

UI.KeybindsHud = Instance.new("Frame", UI.ScreenGui)
UI.KeybindsHud.Name = "KeybindsHud"
UI.KeybindsHud.Size = UDim2.new(0, 190, 0, 120)
UI.KeybindsHud.Position = UDim2.new(0, 15, 1, -135)
UI.KeybindsHud.BackgroundColor3 = Theme.Card
UI.KeybindsHud.BorderSizePixel = 0
UI.KeybindsHud.Visible = false
UI.KeybindsHud.ZIndex = 50
Instance.new("UICorner", UI.KeybindsHud).CornerRadius = UDim.new(0, 8)

local function createHudStatusRow(yOffset, labelText)
    local rowLbl = Instance.new("TextLabel", UI.KeybindsHud)
    rowLbl.Size = UDim2.new(1, -20, 0, 20); rowLbl.Position = UDim2.new(0, 10, 0, yOffset)
    rowLbl.BackgroundTransparency = 1; rowLbl.Font = Settings.CustomFont; rowLbl.Text = labelText
    rowLbl.TextColor3 = Theme.SubText; rowLbl.TextSize = 12; rowLbl.TextXAlignment = Enum.TextXAlignment.Left; rowLbl.ZIndex = 51
    
    local stateLbl = Instance.new("TextLabel", UI.KeybindsHud)
    stateLbl.Size = UDim2.new(0, 60, 0, 20); stateLbl.Position = UDim2.new(1, -70, 0, yOffset)
    stateLbl.BackgroundTransparency = 1; stateLbl.Font = Settings.CustomFont; stateLbl.Text = "OFF"
    stateLbl.TextColor3 = Color3.fromRGB(239, 68, 68); stateLbl.TextSize = 12; stateLbl.TextXAlignment = Enum.TextXAlignment.Right; stateLbl.ZIndex = 51
    return rowLbl, stateLbl
end

UI.HudRowAimbot, UI.HudStatusAimbot = createHudStatusRow(8, "Aimbot [" .. getKeyName(Settings.KeyAimbot) .. "]")
UI.HudRowSilent, UI.HudStatusSilent = createHudStatusRow(30, "Silent [" .. getKeyName(Settings.KeySilentAim) .. "]")
UI.HudRowFly, UI.HudStatusFly = createHudStatusRow(52, "Movement [" .. getKeyName(Settings.KeyFly) .. "]")
UI.HudRowMenu, UI.HudStatusMenu = createHudStatusRow(74, "Menu [" .. getKeyName(Settings.KeyToggleMenu) .. "]")

UI.HudStatusUnload = Instance.new("TextLabel", UI.KeybindsHud)
UI.HudStatusUnload.Size = UDim2.new(1, -20, 0, 18); UI.HudStatusUnload.Position = UDim2.new(0, 10, 0, 96)
UI.HudStatusUnload.BackgroundTransparency = 1; UI.HudStatusUnload.Font = Settings.CustomFont
UI.HudStatusUnload.Text = "Press " .. getKeyName(Settings.KeyUnload) .. " to Unload"
UI.HudStatusUnload.TextColor3 = Theme.SubText; UI.HudStatusUnload.TextSize = 10; UI.HudStatusUnload.TextXAlignment = Enum.TextXAlignment.Center; UI.HudStatusUnload.ZIndex = 51

UI.tabContainers = {}
for i = 1, 5 do
    local scroller = Instance.new("ScrollingFrame", UI.MainFrame)
    scroller.Size = UDim2.new(1, -20, 1, -85); scroller.Position = UDim2.new(0, 10, 0, 75)
    scroller.BackgroundTransparency = 1; scroller.BorderSizePixel = 0
    scroller.CanvasSize = UDim2.new(0, 0, 0, 700); scroller.ScrollBarThickness = 4
    scroller.ScrollBarImageColor3 = Theme.Accent; scroller.Visible = (i == 1); scroller.ZIndex = 2
    local layout = Instance.new("UIListLayout", scroller)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 6)
    UI.tabContainers[i] = scroller
end

local function createTabButton(name, xPos, index)
    local btn = Instance.new("TextButton", UI.MainFrame)
    btn.Size = UDim2.new(0, 86, 0, 24); btn.Position = UDim2.new(0, xPos, 0, 42)
    btn.BackgroundColor3 = (UIState.currentTab == index) and Theme.TabActive or Theme.TabInactive
    btn.BorderSizePixel = 0; btn.Font = Settings.CustomFont; btn.Text = name
    btn.TextColor3 = (UIState.currentTab == index) and Theme.Text or Theme.SubText
    btn.TextSize = 11; btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

UI.Tab1 = createTabButton("Aimbot", 12, 1)
UI.Tab2 = createTabButton("ESP", 104, 2)
UI.Tab3 = createTabButton("Movement", 196, 3)
UI.Tab4 = createTabButton("Teleport", 288, 4)
UI.Tab5 = createTabButton("Keybinds", 380, 5)

local function createCard(tabIndex, order)
    local card = Instance.new("Frame", UI.tabContainers[tabIndex])
    card.Size = UDim2.new(1, 0, 0, 34); card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0; card.LayoutOrder = order; card.ZIndex = 3
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    return card
end

local function createResetButton(card, onClick)
    local rBtn = Instance.new("TextButton", card)
    rBtn.Size = UDim2.new(0, 24, 0, 24)
    rBtn.Position = UDim2.new(1, -208, 0.5, -12)
    rBtn.BackgroundTransparency = 1
    rBtn.Font = Settings.CustomFont
    rBtn.Text = "↺"
    rBtn.TextColor3 = Theme.SubText
    rBtn.TextSize = 16
    rBtn.ZIndex = 6
    rBtn.MouseButton1Click:Connect(onClick)
    return rBtn
end

-- TAB 1
do
    local Card1 = createCard(1, 1)
    local LblAimbot = Instance.new("TextLabel", Card1)
    LblAimbot.Size = UDim2.new(0, 200, 0, 34); LblAimbot.Position = UDim2.new(0, 12, 0, 0); LblAimbot.BackgroundTransparency = 1
    LblAimbot.Font = Settings.CustomFont; LblAimbot.Text = "Aimbot"; LblAimbot.TextColor3 = Theme.Text; LblAimbot.TextSize = 14; LblAimbot.TextXAlignment = Enum.TextXAlignment.Left; LblAimbot.ZIndex = 4

    UI.ToggleTrack1 = Instance.new("Frame", Card1)
    UI.ToggleTrack1.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrack1.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrack1.BackgroundColor3 = Theme.Off; UI.ToggleTrack1.BorderSizePixel = 0; UI.ToggleTrack1.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrack1).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnob1 = Instance.new("Frame", UI.ToggleTrack1)
    UI.ToggleKnob1.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnob1.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnob1.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnob1.BorderSizePixel = 0; UI.ToggleKnob1.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnob1).CornerRadius = UDim.new(1, 0)

    local CardSilent = createCard(1, 2)
    local LblSilent = Instance.new("TextLabel", CardSilent)
    LblSilent.Size = UDim2.new(0, 200, 0, 34); LblSilent.Position = UDim2.new(0, 12, 0, 0); LblSilent.BackgroundTransparency = 1
    LblSilent.Font = Settings.CustomFont; LblSilent.Text = "Silent Aim"; LblSilent.TextColor3 = Theme.Text; LblSilent.TextSize = 14; LblSilent.TextXAlignment = Enum.TextXAlignment.Left; LblSilent.ZIndex = 4

    UI.ToggleTrackSilent = Instance.new("Frame", CardSilent)
    UI.ToggleTrackSilent.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackSilent.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackSilent.BackgroundColor3 = Theme.Off; UI.ToggleTrackSilent.BorderSizePixel = 0; UI.ToggleTrackSilent.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackSilent).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobSilent = Instance.new("Frame", UI.ToggleTrackSilent)
    UI.ToggleKnobSilent.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobSilent.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobSilent.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobSilent.BorderSizePixel = 0; UI.ToggleKnobSilent.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobSilent).CornerRadius = UDim.new(1, 0)

    local CardTriggerbot = createCard(1, 3)
    local LblTriggerbot = Instance.new("TextLabel", CardTriggerbot)
    LblTriggerbot.Size = UDim2.new(0, 200, 0, 34); LblTriggerbot.Position = UDim2.new(0, 12, 0, 0); LblTriggerbot.BackgroundTransparency = 1
    LblTriggerbot.Font = Settings.CustomFont; LblTriggerbot.Text = "Triggerbot"; LblTriggerbot.TextColor3 = Theme.Text; LblTriggerbot.TextSize = 14; LblTriggerbot.TextXAlignment = Enum.TextXAlignment.Left; LblTriggerbot.ZIndex = 4

    UI.ToggleTrackTrigger = Instance.new("Frame", CardTriggerbot)
    UI.ToggleTrackTrigger.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackTrigger.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackTrigger.BackgroundColor3 = Theme.Off; UI.ToggleTrackTrigger.BorderSizePixel = 0; UI.ToggleTrackTrigger.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackTrigger).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobTrigger = Instance.new("Frame", UI.ToggleTrackTrigger)
    UI.ToggleKnobTrigger.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobTrigger.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobTrigger.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobTrigger.BorderSizePixel = 0; UI.ToggleKnobTrigger.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobTrigger).CornerRadius = UDim.new(1, 0)

    local CardTriggerDelay = createCard(1, 4)
    local LblTriggerDelay = Instance.new("TextLabel", CardTriggerDelay)
    LblTriggerDelay.Size = UDim2.new(0, 200, 0, 34); LblTriggerDelay.Position = UDim2.new(0, 12, 0, 0); LblTriggerDelay.BackgroundTransparency = 1
    LblTriggerDelay.Font = Settings.CustomFont; LblTriggerDelay.Text = "Trigger Delay"; LblTriggerDelay.TextColor3 = Theme.Text; LblTriggerDelay.TextSize = 14; LblTriggerDelay.TextXAlignment = Enum.TextXAlignment.Left; LblTriggerDelay.ZIndex = 4

    UI.TriggerDelayTrack = Instance.new("Frame", CardTriggerDelay)
    UI.TriggerDelayTrack.Size = UDim2.new(0, 140, 0, 14); UI.TriggerDelayTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.TriggerDelayTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.TriggerDelayTrack.BorderSizePixel = 0; UI.TriggerDelayTrack.ZIndex = 4
    Instance.new("UICorner", UI.TriggerDelayTrack).CornerRadius = UDim.new(1, 0)
    UI.TriggerDelayFill = Instance.new("Frame", UI.TriggerDelayTrack)
    UI.TriggerDelayFill.Size = UDim2.new(Settings.TriggerbotDelay / 1.0, 0, 1, 0); UI.TriggerDelayFill.BackgroundColor3 = Theme.Accent; UI.TriggerDelayFill.BorderSizePixel = 0; UI.TriggerDelayFill.ZIndex = 5
    Instance.new("UICorner", UI.TriggerDelayFill).CornerRadius = UDim.new(1, 0)
    UI.TriggerDelayText = Instance.new("TextLabel", UI.TriggerDelayTrack)
    UI.TriggerDelayText.Size = UDim2.new(1, 0, 1, 0); UI.TriggerDelayText.BackgroundTransparency = 1; UI.TriggerDelayText.Font = Settings.CustomFont; UI.TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay); UI.TriggerDelayText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.TriggerDelayText.TextSize = 12; UI.TriggerDelayText.ZIndex = 6

    createResetButton(CardTriggerDelay, function()
        Settings.TriggerbotDelay = 0.05
        UI.TriggerDelayFill.Size = UDim2.new(Settings.TriggerbotDelay / 1.0, 0, 1, 0)
        UI.TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay)
    end)

    local CardTarget = createCard(1, 5)
    local LblTarget = Instance.new("TextLabel", CardTarget)
    LblTarget.Size = UDim2.new(0, 200, 0, 34); LblTarget.Position = UDim2.new(0, 12, 0, 0); LblTarget.BackgroundTransparency = 1
    LblTarget.Font = Settings.CustomFont; LblTarget.Text = "Target Hitbox"; LblTarget.TextColor3 = Theme.Text; LblTarget.TextSize = 14; LblTarget.TextXAlignment = Enum.TextXAlignment.Left; LblTarget.ZIndex = 4

    UI.ValTarget = Instance.new("TextButton", CardTarget)
    UI.ValTarget.Size = UDim2.new(0, 130, 0, 24); UI.ValTarget.Position = UDim2.new(1, -142, 0.5, -12); UI.ValTarget.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.ValTarget.BorderSizePixel = 0
    UI.ValTarget.Font = Settings.CustomFont; UI.ValTarget.Text = Settings.TargetPart; UI.ValTarget.TextColor3 = Theme.Accent; UI.ValTarget.TextSize = 13; UI.ValTarget.ZIndex = 4
    Instance.new("UICorner", UI.ValTarget).CornerRadius = UDim.new(0, 5)

    UI.ValTarget.MouseButton1Click:Connect(function()
        Settings.TargetPart = (Settings.TargetPart == "Head") and "Chest" or "Head"
        UI.ValTarget.Text = Settings.TargetPart
    end)

    local CardAimbotMode = createCard(1, 6)
    local LblAimbotMode = Instance.new("TextLabel", CardAimbotMode)
    LblAimbotMode.Size = UDim2.new(0, 200, 0, 34); LblAimbotMode.Position = UDim2.new(0, 12, 0, 0); LblAimbotMode.BackgroundTransparency = 1
    LblAimbotMode.Font = Settings.CustomFont; LblAimbotMode.Text = "Aimbot Mode"; LblAimbotMode.TextColor3 = Theme.Text; LblAimbotMode.TextSize = 14; LblAimbotMode.TextXAlignment = Enum.TextXAlignment.Left; LblAimbotMode.ZIndex = 4

    UI.ValAimbotMode = Instance.new("TextButton", CardAimbotMode)
    UI.ValAimbotMode.Size = UDim2.new(0, 130, 0, 24); UI.ValAimbotMode.Position = UDim2.new(1, -142, 0.5, -12); UI.ValAimbotMode.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.ValAimbotMode.BorderSizePixel = 0
    UI.ValAimbotMode.Font = Settings.CustomFont; UI.ValAimbotMode.Text = Settings.AimbotMode; UI.ValAimbotMode.TextColor3 = Theme.Accent; UI.ValAimbotMode.TextSize = 13; UI.ValAimbotMode.ZIndex = 4
    Instance.new("UICorner", UI.ValAimbotMode).CornerRadius = UDim.new(0, 5)

    UI.ValAimbotMode.MouseButton1Click:Connect(function()
        Settings.AimbotMode = (Settings.AimbotMode == "Toggle") and "Hold" or "Toggle"
        UI.ValAimbotMode.Text = Settings.AimbotMode
        UIState.isAimbotHeld = false
    end)

    local CardTeamCheck = createCard(1, 7)
    local LblTeamCheck = Instance.new("TextLabel", CardTeamCheck)
    LblTeamCheck.Size = UDim2.new(0, 200, 0, 34); LblTeamCheck.Position = UDim2.new(0, 12, 0, 0); LblTeamCheck.BackgroundTransparency = 1
    LblTeamCheck.Font = Settings.CustomFont; LblTeamCheck.Text = "Team Check"; LblTeamCheck.TextColor3 = Theme.Text; LblTeamCheck.TextSize = 14; LblTeamCheck.TextXAlignment = Enum.TextXAlignment.Left; LblTeamCheck.ZIndex = 4

    UI.ToggleTrackTeamCheck = Instance.new("Frame", CardTeamCheck)
    UI.ToggleTrackTeamCheck.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackTeamCheck.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackTeamCheck.BackgroundColor3 = Theme.Off; UI.ToggleTrackTeamCheck.BorderSizePixel = 0; UI.ToggleTrackTeamCheck.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackTeamCheck).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobTeamCheck = Instance.new("Frame", UI.ToggleTrackTeamCheck)
    UI.ToggleKnobTeamCheck.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobTeamCheck.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobTeamCheck.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobTeamCheck.BorderSizePixel = 0; UI.ToggleKnobTeamCheck.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobTeamCheck).CornerRadius = UDim.new(1, 0)

    local CardWallCheck = createCard(1, 8)
    local LblWallCheck = Instance.new("TextLabel", CardWallCheck)
    LblWallCheck.Size = UDim2.new(0, 200, 0, 34); LblWallCheck.Position = UDim2.new(0, 12, 0, 0); LblWallCheck.BackgroundTransparency = 1
    LblWallCheck.Font = Settings.CustomFont; LblWallCheck.Text = "Wall Check"; LblWallCheck.TextColor3 = Theme.Text; LblWallCheck.TextSize = 14; LblWallCheck.TextXAlignment = Enum.TextXAlignment.Left; LblWallCheck.ZIndex = 4

    UI.ToggleTrackWall = Instance.new("Frame", CardWallCheck)
    UI.ToggleTrackWall.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackWall.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackWall.BackgroundColor3 = Theme.Off; UI.ToggleTrackWall.BorderSizePixel = 0; UI.ToggleTrackWall.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackWall).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobWall = Instance.new("Frame", UI.ToggleTrackWall)
    UI.ToggleKnobWall.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobWall.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobWall.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobWall.BorderSizePixel = 0; UI.ToggleKnobWall.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobWall).CornerRadius = UDim.new(1, 0)

    local CardTargetingSmooth = createCard(1, 9)
    local LblTargetingSmooth = Instance.new("TextLabel", CardTargetingSmooth)
    LblTargetingSmooth.Size = UDim2.new(0, 200, 0, 34); LblTargetingSmooth.Position = UDim2.new(0, 12, 0, 0); LblTargetingSmooth.BackgroundTransparency = 1
    LblTargetingSmooth.Font = Settings.CustomFont; LblTargetingSmooth.Text = "Targeting Smoothness"; LblTargetingSmooth.TextColor3 = Theme.Text; LblTargetingSmooth.TextSize = 14; LblTargetingSmooth.TextXAlignment = Enum.TextXAlignment.Left; LblTargetingSmooth.ZIndex = 4

    UI.TargetingSliderTrack = Instance.new("Frame", CardTargetingSmooth)
    UI.TargetingSliderTrack.Size = UDim2.new(0, 140, 0, 14); UI.TargetingSliderTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.TargetingSliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.TargetingSliderTrack.BorderSizePixel = 0; UI.TargetingSliderTrack.ZIndex = 4
    Instance.new("UICorner", UI.TargetingSliderTrack).CornerRadius = UDim.new(1, 0)
    UI.TargetingSliderFill = Instance.new("Frame", UI.TargetingSliderTrack)
    UI.TargetingSliderFill.Size = UDim2.new(Settings.TargetingSmoothness, 0, 1, 0); UI.TargetingSliderFill.BackgroundColor3 = Theme.Accent; UI.TargetingSliderFill.BorderSizePixel = 0; UI.TargetingSliderFill.ZIndex = 5
    Instance.new("UICorner", UI.TargetingSliderFill).CornerRadius = UDim.new(1, 0)
    UI.TargetingSliderText = Instance.new("TextLabel", UI.TargetingSliderTrack)
    UI.TargetingSliderText.Size = UDim2.new(1, 0, 1, 0); UI.TargetingSliderText.BackgroundTransparency = 1; UI.TargetingSliderText.Font = Settings.CustomFont; UI.TargetingSliderText.Text = math.floor(Settings.TargetingSmoothness * 100) .. "%"; UI.TargetingSliderText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.TargetingSliderText.TextSize = 12; UI.TargetingSliderText.ZIndex = 6

    createResetButton(CardTargetingSmooth, function()
        Settings.TargetingSmoothness = 0.50
        UI.TargetingSliderFill.Size = UDim2.new(Settings.TargetingSmoothness, 0, 1, 0)
        UI.TargetingSliderText.Text = math.floor(Settings.TargetingSmoothness * 100) .. "%"
    end)

    local CardTrackingSmooth = createCard(1, 10)
    local LblTrackingSmooth = Instance.new("TextLabel", CardTrackingSmooth)
    LblTrackingSmooth.Size = UDim2.new(0, 200, 0, 34); LblTrackingSmooth.Position = UDim2.new(0, 12, 0, 0); LblTrackingSmooth.BackgroundTransparency = 1
    LblTrackingSmooth.Font = Settings.CustomFont; LblTrackingSmooth.Text = "Tracking Smoothness"; LblTrackingSmooth.TextColor3 = Theme.Text; LblTrackingSmooth.TextSize = 14; LblTrackingSmooth.TextXAlignment = Enum.TextXAlignment.Left; LblTrackingSmooth.ZIndex = 4

    UI.TrackingSliderTrack = Instance.new("Frame", CardTrackingSmooth)
    UI.TrackingSliderTrack.Size = UDim2.new(0, 140, 0, 14); UI.TrackingSliderTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.TrackingSliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.TrackingSliderTrack.BorderSizePixel = 0; UI.TrackingSliderTrack.ZIndex = 4
    Instance.new("UICorner", UI.TrackingSliderTrack).CornerRadius = UDim.new(1, 0)
    UI.TrackingSliderFill = Instance.new("Frame", UI.TrackingSliderTrack)
    UI.TrackingSliderFill.Size = UDim2.new(Settings.TrackingSmoothness, 0, 1, 0); UI.TrackingSliderFill.BackgroundColor3 = Theme.Accent; UI.TrackingSliderFill.BorderSizePixel = 0; UI.TrackingSliderFill.ZIndex = 5
    Instance.new("UICorner", UI.TrackingSliderFill).CornerRadius = UDim.new(1, 0)
    UI.TrackingSliderText = Instance.new("TextLabel", UI.TrackingSliderTrack)
    UI.TrackingSliderText.Size = UDim2.new(1, 0, 1, 0); UI.TrackingSliderText.BackgroundTransparency = 1; UI.TrackingSliderText.Font = Settings.CustomFont; UI.TrackingSliderText.Text = math.floor(Settings.TrackingSmoothness * 100) .. "%"; UI.TrackingSliderText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.TrackingSliderText.TextSize = 12; UI.TrackingSliderText.ZIndex = 6

    createResetButton(CardTrackingSmooth, function()
        Settings.TrackingSmoothness = 0.50
        UI.TrackingSliderFill.Size = UDim2.new(Settings.TrackingSmoothness, 0, 1, 0)
        UI.TrackingSliderText.Text = math.floor(Settings.TrackingSmoothness * 100) .. "%"
    end)

    local CardFOV = createCard(1, 11)
    local LblFOV = Instance.new("TextLabel", CardFOV)
    LblFOV.Size = UDim2.new(0, 200, 0, 34); LblFOV.Position = UDim2.new(0, 12, 0, 0); LblFOV.BackgroundTransparency = 1
    LblFOV.Font = Settings.CustomFont; LblFOV.Text = "Show FOV Circle"; LblFOV.TextColor3 = Theme.Text; LblFOV.TextSize = 14; LblFOV.TextXAlignment = Enum.TextXAlignment.Left; LblFOV.ZIndex = 4

    UI.ToggleTrack3 = Instance.new("Frame", CardFOV)
    UI.ToggleTrack3.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrack3.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrack3.BackgroundColor3 = Theme.Off; UI.ToggleTrack3.BorderSizePixel = 0; UI.ToggleTrack3.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrack3).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnob3 = Instance.new("Frame", UI.ToggleTrack3)
    UI.ToggleKnob3.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnob3.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnob3.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnob3.BorderSizePixel = 0; UI.ToggleKnob3.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnob3).CornerRadius = UDim.new(1, 0)

    local CardFOVSlider = createCard(1, 12)
    local LblFOVSlider = Instance.new("TextLabel", CardFOVSlider)
    LblFOVSlider.Size = UDim2.new(0, 200, 0, 34); LblFOVSlider.Position = UDim2.new(0, 12, 0, 0); LblFOVSlider.BackgroundTransparency = 1
    LblFOVSlider.Font = Settings.CustomFont; LblFOVSlider.Text = "FOV Size"; LblFOVSlider.TextColor3 = Theme.Text; LblFOVSlider.TextSize = 14; LblFOVSlider.TextXAlignment = Enum.TextXAlignment.Left; LblFOVSlider.ZIndex = 4

    UI.FOVSliderTrack = Instance.new("Frame", CardFOVSlider)
    UI.FOVSliderTrack.Size = UDim2.new(0, 140, 0, 14); UI.FOVSliderTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.FOVSliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.FOVSliderTrack.BorderSizePixel = 0; UI.FOVSliderTrack.ZIndex = 4
    Instance.new("UICorner", UI.FOVSliderTrack).CornerRadius = UDim.new(1, 0)
    UI.FOVSliderFill = Instance.new("Frame", UI.FOVSliderTrack)
    UI.FOVSliderFill.Size = UDim2.new(100/400, 0, 1, 0); UI.FOVSliderFill.BackgroundColor3 = Theme.Accent; UI.FOVSliderFill.BorderSizePixel = 0; UI.FOVSliderFill.ZIndex = 5
    Instance.new("UICorner", UI.FOVSliderFill).CornerRadius = UDim.new(1, 0)
    UI.FOVSliderText = Instance.new("TextLabel", UI.FOVSliderTrack)
    UI.FOVSliderText.Size = UDim2.new(1, 0, 1, 0); UI.FOVSliderText.BackgroundTransparency = 1; UI.FOVSliderText.Font = Settings.CustomFont; UI.FOVSliderText.Text = "100"; UI.FOVSliderText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.FOVSliderText.TextSize = 12; UI.FOVSliderText.ZIndex = 6

    createResetButton(CardFOVSlider, function()
        Settings.FOVSize = 100
        UI.FOVSliderFill.Size = UDim2.new(100/400, 0, 1, 0)
        UI.FOVSliderText.Text = "100"
    end)
    
    UI.Card1 = Card1; UI.CardSilent = CardSilent; UI.CardTriggerbot = CardTriggerbot; UI.CardTeamCheck = CardTeamCheck; UI.CardWallCheck = CardWallCheck; UI.CardFOV = CardFOV
end

-- TAB 2 (ESP)
do
    local function createESPCard(labelText, settingName, order)
        local card = createCard(2, order)
        local lbl = Instance.new("TextLabel", card)
        lbl.Size = UDim2.new(0, 200, 0, 34); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
        lbl.Font = Settings.CustomFont; lbl.Text = labelText; lbl.TextColor3 = Theme.Text; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4

        local track = Instance.new("Frame", card)
        track.Size = UDim2.new(0, 34, 0, 18); track.Position = UDim2.new(1, -46, 0.5, -9); track.BackgroundColor3 = Settings[settingName] and Theme.Accent or Theme.Off; track.BorderSizePixel = 0; track.ZIndex = 4
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = Settings[settingName] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.BorderSizePixel = 0; knob.ZIndex = 5
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        return card, track, knob
    end

    UI.CardTeamCheckESP, UI.TrackTeamCheckESP, UI.KnobTeamCheckESP = createESPCard("Team Check", "TeamCheckESP", 1)
    UI.CardEspHighlight, UI.TrackEspHighlight, UI.KnobEspHighlight = createESPCard("Highlight ESP", "ESPHighlight", 2)
    UI.CardEspBox, UI.TrackEspBox, UI.KnobEspBox = createESPCard("ESP Boxes", "ESPBox", 3)
    UI.CardEspName, UI.TrackEspName, UI.KnobEspName = createESPCard("ESP Names", "ESPName", 4)
    UI.CardEspHealth, UI.TrackEspHealth, UI.KnobEspHealth = createESPCard("ESP Health Bar", "ESPHealth", 5)
    UI.CardEspSkeleton, UI.TrackEspSkeleton, UI.KnobEspSkeleton = createESPCard("ESP Skeleton", "ESPSkeleton", 6)
    UI.CardEspTracers, UI.TrackEspTracers, UI.KnobEspTracers = createESPCard("ESP Tracers", "ESPTracers", 7)
    UI.CardEspHeadDot, UI.TrackEspHeadDot, UI.KnobEspHeadDot = createESPCard("Head Dot ESP", "ESPHeadDot", 8)
end

-- TAB 3 (Movement)
do
    local CardFly = createCard(3, 1)
    local LblFly = Instance.new("TextLabel", CardFly)
    LblFly.Size = UDim2.new(0, 200, 0, 34); LblFly.Position = UDim2.new(0, 12, 0, 0); LblFly.BackgroundTransparency = 1
    LblFly.Font = Settings.CustomFont; LblFly.Text = "Fly Mode"; LblFly.TextColor3 = Theme.Text; LblFly.TextSize = 14; LblFly.TextXAlignment = Enum.TextXAlignment.Left; LblFly.ZIndex = 4

    UI.ToggleTrackFly = Instance.new("Frame", CardFly)
    UI.ToggleTrackFly.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackFly.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackFly.BackgroundColor3 = Theme.Off; UI.ToggleTrackFly.BorderSizePixel = 0; UI.ToggleTrackFly.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackFly).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobFly = Instance.new("Frame", UI.ToggleTrackFly)
    UI.ToggleKnobFly.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobFly.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobFly.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobFly.BorderSizePixel = 0; UI.ToggleKnobFly.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobFly).CornerRadius = UDim.new(1, 0)

    local CardFlyNoClip = createCard(3, 2)
    local LblFlyNoClip = Instance.new("TextLabel", CardFlyNoClip)
    LblFlyNoClip.Size = UDim2.new(0, 200, 0, 34); LblFlyNoClip.Position = UDim2.new(0, 12, 0, 0); LblFlyNoClip.BackgroundTransparency = 1
    LblFlyNoClip.Font = Settings.CustomFont; LblFlyNoClip.Text = "Fly NoClip"; LblFlyNoClip.TextColor3 = Theme.Text; LblFlyNoClip.TextSize = 14; LblFlyNoClip.TextXAlignment = Enum.TextXAlignment.Left; LblFlyNoClip.ZIndex = 4

    UI.ToggleTrackFlyNoClip = Instance.new("Frame", CardFlyNoClip)
    UI.ToggleTrackFlyNoClip.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackFlyNoClip.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackFlyNoClip.BackgroundColor3 = Theme.Off; UI.ToggleTrackFlyNoClip.BorderSizePixel = 0; UI.ToggleTrackFlyNoClip.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackFlyNoClip).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobFlyNoClip = Instance.new("Frame", UI.ToggleTrackFlyNoClip)
    UI.ToggleKnobFlyNoClip.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobFlyNoClip.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobFlyNoClip.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobFlyNoClip.BorderSizePixel = 0; UI.ToggleKnobFlyNoClip.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobFlyNoClip).CornerRadius = UDim.new(1, 0)

    local CardFlySpeed = createCard(3, 3)
    local LblFlySpeed = Instance.new("TextLabel", CardFlySpeed)
    LblFlySpeed.Size = UDim2.new(0, 200, 0, 34); LblFlySpeed.Position = UDim2.new(0, 12, 0, 0); LblFlySpeed.BackgroundTransparency = 1
    LblFlySpeed.Font = Settings.CustomFont; LblFlySpeed.Text = "Fly Speed"; LblFlySpeed.TextColor3 = Theme.Text; LblFlySpeed.TextSize = 14; LblFlySpeed.TextXAlignment = Enum.TextXAlignment.Left; LblFlySpeed.ZIndex = 4

    UI.FlySpeedTrack = Instance.new("Frame", CardFlySpeed)
    UI.FlySpeedTrack.Size = UDim2.new(0, 140, 0, 14); UI.FlySpeedTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.FlySpeedTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.FlySpeedTrack.BorderSizePixel = 0; UI.FlySpeedTrack.ZIndex = 4
    Instance.new("UICorner", UI.FlySpeedTrack).CornerRadius = UDim.new(1, 0)
    UI.FlySpeedFill = Instance.new("Frame", UI.FlySpeedTrack)
    UI.FlySpeedFill.Size = UDim2.new((Settings.FlySpeed - 10) / 290, 0, 1, 0); UI.FlySpeedFill.BackgroundColor3 = Theme.Accent; UI.FlySpeedFill.BorderSizePixel = 0; UI.FlySpeedFill.ZIndex = 5
    Instance.new("UICorner", UI.FlySpeedFill).CornerRadius = UDim.new(1, 0)
    UI.FlySpeedText = Instance.new("TextLabel", UI.FlySpeedTrack)
    UI.FlySpeedText.Size = UDim2.new(1, 0, 1, 0); UI.FlySpeedText.BackgroundTransparency = 1; UI.FlySpeedText.Font = Settings.CustomFont; UI.FlySpeedText.Text = tostring(Settings.FlySpeed); UI.FlySpeedText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.FlySpeedText.TextSize = 12; UI.FlySpeedText.ZIndex = 6

    createResetButton(CardFlySpeed, function()
        Settings.FlySpeed = 50
        UI.FlySpeedFill.Size = UDim2.new((Settings.FlySpeed - 10) / 290, 0, 1, 0)
        UI.FlySpeedText.Text = tostring(Settings.FlySpeed)
    end)

    local CardFlyVert = createCard(3, 4)
    local LblFlyVert = Instance.new("TextLabel", CardFlyVert)
    LblFlyVert.Size = UDim2.new(0, 200, 0, 34); LblFlyVert.Position = UDim2.new(0, 12, 0, 0); LblFlyVert.BackgroundTransparency = 1
    LblFlyVert.Font = Settings.CustomFont; LblFlyVert.Text = "Vertical Speed"; LblFlyVert.TextColor3 = Theme.Text; LblFlyVert.TextSize = 14; LblFlyVert.TextXAlignment = Enum.TextXAlignment.Left; LblFlyVert.ZIndex = 4

    UI.FlyVertTrack = Instance.new("Frame", CardFlyVert)
    UI.FlyVertTrack.Size = UDim2.new(0, 140, 0, 14); UI.FlyVertTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.FlyVertTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.FlyVertTrack.BorderSizePixel = 0; UI.FlyVertTrack.ZIndex = 4
    Instance.new("UICorner", UI.FlyVertTrack).CornerRadius = UDim.new(1, 0)
    UI.FlyVertFill = Instance.new("Frame", UI.FlyVertTrack)
    UI.FlyVertFill.Size = UDim2.new((Settings.FlyVerticalSpeed - 10) / 290, 0, 1, 0); UI.FlyVertFill.BackgroundColor3 = Theme.Accent; UI.FlyVertFill.BorderSizePixel = 0; UI.FlyVertFill.ZIndex = 5
    Instance.new("UICorner", UI.FlyVertFill).CornerRadius = UDim.new(1, 0)
    UI.FlyVertText = Instance.new("TextLabel", UI.FlyVertTrack)
    UI.FlyVertText.Size = UDim2.new(1, 0, 1, 0); UI.FlyVertText.BackgroundTransparency = 1; UI.FlyVertText.Font = Settings.CustomFont; UI.FlyVertText.Text = tostring(Settings.FlyVerticalSpeed); UI.FlyVertText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.FlyVertText.TextSize = 12; UI.FlyVertText.ZIndex = 6

    createResetButton(CardFlyVert, function()
        Settings.FlyVerticalSpeed = 50
        UI.FlyVertFill.Size = UDim2.new((Settings.FlyVerticalSpeed - 10) / 290, 0, 1, 0)
        UI.FlyVertText.Text = tostring(Settings.FlyVerticalSpeed)
    end)

    local CardWalkSpeed = createCard(3, 5)
    local LblWalkSpeed = Instance.new("TextLabel", CardWalkSpeed)
    LblWalkSpeed.Size = UDim2.new(0, 200, 0, 34); LblWalkSpeed.Position = UDim2.new(0, 12, 0, 0); LblWalkSpeed.BackgroundTransparency = 1
    LblWalkSpeed.Font = Settings.CustomFont; LblWalkSpeed.Text = "WalkSpeed Mod"; LblWalkSpeed.TextColor3 = Theme.Text; LblWalkSpeed.TextSize = 14; LblWalkSpeed.TextXAlignment = Enum.TextXAlignment.Left; LblWalkSpeed.ZIndex = 4

    UI.ToggleTrackWalkSpeed = Instance.new("Frame", CardWalkSpeed)
    UI.ToggleTrackWalkSpeed.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackWalkSpeed.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackWalkSpeed.BackgroundColor3 = Theme.Off; UI.ToggleTrackWalkSpeed.BorderSizePixel = 0; UI.ToggleTrackWalkSpeed.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackWalkSpeed).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobWalkSpeed = Instance.new("Frame", UI.ToggleTrackWalkSpeed)
    UI.ToggleKnobWalkSpeed.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobWalkSpeed.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobWalkSpeed.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobWalkSpeed.BorderSizePixel = 0; UI.ToggleKnobWalkSpeed.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobWalkSpeed).CornerRadius = UDim.new(1, 0)

    local CardWalkSpeedSlider = createCard(3, 6)
    local LblWalkSpeedSlider = Instance.new("TextLabel", CardWalkSpeedSlider)
    LblWalkSpeedSlider.Size = UDim2.new(0, 200, 0, 34); LblWalkSpeedSlider.Position = UDim2.new(0, 12, 0, 0); LblWalkSpeedSlider.BackgroundTransparency = 1
    LblWalkSpeedSlider.Font = Settings.CustomFont; LblWalkSpeedSlider.Text = "WalkSpeed Value"; LblWalkSpeedSlider.TextColor3 = Theme.Text; LblWalkSpeedSlider.TextSize = 14; LblWalkSpeedSlider.TextXAlignment = Enum.TextXAlignment.Left; LblWalkSpeedSlider.ZIndex = 4

    UI.WalkSpeedTrack = Instance.new("Frame", CardWalkSpeedSlider)
    UI.WalkSpeedTrack.Size = UDim2.new(0, 140, 0, 14); UI.WalkSpeedTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.WalkSpeedTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.WalkSpeedTrack.BorderSizePixel = 0; UI.WalkSpeedTrack.ZIndex = 4
    Instance.new("UICorner", UI.WalkSpeedTrack).CornerRadius = UDim.new(1, 0)
    UI.WalkSpeedFill = Instance.new("Frame", UI.WalkSpeedTrack)
    UI.WalkSpeedFill.Size = UDim2.new((Settings.WalkSpeedValue - 16) / 234, 0, 1, 0); UI.WalkSpeedFill.BackgroundColor3 = Theme.Accent; UI.WalkSpeedFill.BorderSizePixel = 0; UI.WalkSpeedFill.ZIndex = 5
    Instance.new("UICorner", UI.WalkSpeedFill).CornerRadius = UDim.new(1, 0)
    UI.WalkSpeedText = Instance.new("TextLabel", UI.WalkSpeedTrack)
    UI.WalkSpeedText.Size = UDim2.new(1, 0, 1, 0); UI.WalkSpeedText.BackgroundTransparency = 1; UI.WalkSpeedText.Font = Settings.CustomFont; UI.WalkSpeedText.Text = tostring(Settings.WalkSpeedValue); UI.WalkSpeedText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.WalkSpeedText.TextSize = 12; UI.WalkSpeedText.ZIndex = 6

    createResetButton(CardWalkSpeedSlider, function()
        Settings.WalkSpeedValue = 16
        UI.WalkSpeedFill.Size = UDim2.new((Settings.WalkSpeedValue - 16) / 234, 0, 1, 0)
        UI.WalkSpeedText.Text = tostring(Settings.WalkSpeedValue)
    end)

    local CardJumpPower = createCard(3, 7)
    local LblJumpPower = Instance.new("TextLabel", CardJumpPower)
    LblJumpPower.Size = UDim2.new(0, 200, 0, 34); LblJumpPower.Position = UDim2.new(0, 12, 0, 0); LblJumpPower.BackgroundTransparency = 1
    LblJumpPower.Font = Settings.CustomFont; LblJumpPower.Text = "Jump Power Mod"; LblJumpPower.TextColor3 = Theme.Text; LblJumpPower.TextSize = 14; LblJumpPower.TextXAlignment = Enum.TextXAlignment.Left; LblJumpPower.ZIndex = 4

    UI.ToggleTrackJumpPower = Instance.new("Frame", CardJumpPower)
    UI.ToggleTrackJumpPower.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackJumpPower.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackJumpPower.BackgroundColor3 = Theme.Off; UI.ToggleTrackJumpPower.BorderSizePixel = 0; UI.ToggleTrackJumpPower.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackJumpPower).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobJumpPower = Instance.new("Frame", UI.ToggleTrackJumpPower)
    UI.ToggleKnobJumpPower.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobJumpPower.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobJumpPower.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobJumpPower.BorderSizePixel = 0; UI.ToggleKnobJumpPower.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobJumpPower).CornerRadius = UDim.new(1, 0)

    local CardJumpPowerSlider = createCard(3, 8)
    local LblJumpPowerSlider = Instance.new("TextLabel", CardJumpPowerSlider)
    LblJumpPowerSlider.Size = UDim2.new(0, 200, 0, 34); LblJumpPowerSlider.Position = UDim2.new(0, 12, 0, 0); LblJumpPowerSlider.BackgroundTransparency = 1
    LblJumpPowerSlider.Font = Settings.CustomFont; LblJumpPowerSlider.Text = "Jump Height Value"; LblJumpPowerSlider.TextColor3 = Theme.Text; LblJumpPowerSlider.TextSize = 14; LblJumpPowerSlider.TextXAlignment = Enum.TextXAlignment.Left; LblJumpPowerSlider.ZIndex = 4

    UI.JumpPowerTrack = Instance.new("Frame", CardJumpPowerSlider)
    UI.JumpPowerTrack.Size = UDim2.new(0, 140, 0, 14); UI.JumpPowerTrack.Position = UDim2.new(1, -182, 0.5, -7); UI.JumpPowerTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.JumpPowerTrack.BorderSizePixel = 0; UI.JumpPowerTrack.ZIndex = 4
    Instance.new("UICorner", UI.JumpPowerTrack).CornerRadius = UDim.new(1, 0)
    UI.JumpPowerFill = Instance.new("Frame", UI.JumpPowerTrack)
    UI.JumpPowerFill.Size = UDim2.new((Settings.JumpPowerValue - 50) / 200, 0, 1, 0); UI.JumpPowerFill.BackgroundColor3 = Theme.Accent; UI.JumpPowerFill.BorderSizePixel = 0; UI.JumpPowerFill.ZIndex = 5
    Instance.new("UICorner", UI.JumpPowerFill).CornerRadius = UDim.new(1, 0)
    UI.JumpPowerText = Instance.new("TextLabel", UI.JumpPowerTrack)
    UI.JumpPowerText.Size = UDim2.new(1, 0, 1, 0); UI.JumpPowerText.BackgroundTransparency = 1; UI.JumpPowerText.Font = Settings.CustomFont; UI.JumpPowerText.Text = tostring(Settings.JumpPowerValue); UI.JumpPowerText.TextColor3 = Color3.fromRGB(255, 255, 255); UI.JumpPowerText.TextSize = 12; UI.JumpPowerText.ZIndex = 6

    createResetButton(CardJumpPowerSlider, function()
        Settings.JumpPowerValue = 50
        UI.JumpPowerFill.Size = UDim2.new((Settings.JumpPowerValue - 50) / 200, 0, 1, 0)
        UI.JumpPowerText.Text = tostring(Settings.JumpPowerValue)
    end)

    local CardInfJump = createCard(3, 9)
    local LblInfJump = Instance.new("TextLabel", CardInfJump)
    LblInfJump.Size = UDim2.new(0, 200, 0, 34); LblInfJump.Position = UDim2.new(0, 12, 0, 0); LblInfJump.BackgroundTransparency = 1
    LblInfJump.Font = Settings.CustomFont; LblInfJump.Text = "Infinite Jump"; LblInfJump.TextColor3 = Theme.Text; LblInfJump.TextSize = 14; LblInfJump.TextXAlignment = Enum.TextXAlignment.Left; LblInfJump.ZIndex = 4

    UI.ToggleTrackInfJump = Instance.new("Frame", CardInfJump)
    UI.ToggleTrackInfJump.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackInfJump.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackInfJump.BackgroundColor3 = Theme.Off; UI.ToggleTrackInfJump.BorderSizePixel = 0; UI.ToggleTrackInfJump.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackInfJump).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobInfJump = Instance.new("Frame", UI.ToggleTrackInfJump)
    UI.ToggleKnobInfJump.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobInfJump.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobInfJump.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobInfJump.BorderSizePixel = 0; UI.ToggleKnobInfJump.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobInfJump).CornerRadius = UDim.new(1, 0)
    
    UI.CardFly = CardFly; UI.CardFlyNoClip = CardFlyNoClip; UI.CardWalkSpeed = CardWalkSpeed; UI.CardJumpPower = CardJumpPower; UI.CardInfJump = CardInfJump
end

-- TAB 4 (Teleport)
do
    local CardTpMode = createCard(4, 1)
    local LblTpMode = Instance.new("TextLabel", CardTpMode)
    LblTpMode.Size = UDim2.new(0, 200, 0, 34); LblTpMode.Position = UDim2.new(0, 12, 0, 0); LblTpMode.BackgroundTransparency = 1
    LblTpMode.Font = Settings.CustomFont; LblTpMode.Text = "Teleport Position"; LblTpMode.TextColor3 = Theme.Text; LblTpMode.TextSize = 14; LblTpMode.TextXAlignment = Enum.TextXAlignment.Left; LblTpMode.ZIndex = 4

    UI.ValTpMode = Instance.new("TextButton", CardTpMode)
    UI.ValTpMode.Size = UDim2.new(0, 130, 0, 24); UI.ValTpMode.Position = UDim2.new(1, -142, 0.5, -12); UI.ValTpMode.BackgroundColor3 = Color3.fromRGB(35, 35, 42); UI.ValTpMode.BorderSizePixel = 0
    UI.ValTpMode.Font = Settings.CustomFont; UI.ValTpMode.Text = Settings.TeleportOffsetMode; UI.ValTpMode.TextColor3 = Theme.Accent; UI.ValTpMode.TextSize = 13; UI.ValTpMode.ZIndex = 4
    Instance.new("UICorner", UI.ValTpMode).CornerRadius = UDim.new(0, 5)

    local tpModes = {"In Front", "Behind", "On Top", "Below"}
    UI.ValTpMode.MouseButton1Click:Connect(function()
        for idx, m in ipairs(tpModes) do
            if m == Settings.TeleportOffsetMode then
                Settings.TeleportOffsetMode = tpModes[(idx % #tpModes) + 1]
                break
            end
        end
        UI.ValTpMode.Text = Settings.TeleportOffsetMode
    end)

    UI.TeleportScroller = Instance.new("ScrollingFrame", UI.tabContainers[4])
    UI.TeleportScroller.Size = UDim2.new(1, 0, 1, -42)
    UI.TeleportScroller.Position = UDim2.new(0, 0, 0, 42)
    UI.TeleportScroller.BackgroundTransparency = 1
    UI.TeleportScroller.BorderSizePixel = 0
    UI.TeleportScroller.CanvasSize = UDim2.new(0, 0, 0, 400)
    UI.TeleportScroller.ScrollBarThickness = 4
    UI.TeleportScroller.ScrollBarImageColor3 = Theme.Accent
    UI.TeleportScroller.ZIndex = 3

    local TeleportListLayout = Instance.new("UIListLayout", UI.TeleportScroller)
    TeleportListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TeleportListLayout.Padding = UDim.new(0, 6)

    local function refreshTeleportList()
        for _, child in ipairs(UI.TeleportScroller:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local order = 1
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player then
                local tpBtn = Instance.new("TextButton", UI.TeleportScroller)
                tpBtn.Size = UDim2.new(1, 0, 0, 36)
                tpBtn.BackgroundColor3 = Theme.Card
                tpBtn.BorderSizePixel = 0
                tpBtn.Font = Settings.CustomFont
                tpBtn.Text = " " .. p.Name
                tpBtn.TextColor3 = Theme.Text
                tpBtn.TextSize = 14
                tpBtn.TextXAlignment = Enum.TextXAlignment.Left
                tpBtn.LayoutOrder = order
                tpBtn.ZIndex = 4
                Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
                
                tpBtn.MouseButton1Click:Connect(function()
                    local char = Player.Character
                    local targetChar = p.Character
                    if char and targetChar then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                        if hrp and targetHrp then
                            local offset = CFrame.new(0, 0, 0)
                            local mode = Settings.TeleportOffsetMode
                            if mode == "In Front" then
                                offset = CFrame.new(0, 0, -5)
                            elseif mode == "Behind" then
                                offset = CFrame.new(0, 0, 5)
                            elseif mode == "On Top" then
                                offset = CFrame.new(0, 5, 0)
                            elseif mode == "Below" then
                                offset = CFrame.new(0, -5, 0)
                            end
                            hrp.CFrame = targetHrp.CFrame * offset
                        end
                    end
                end)
                order = order + 1
            end
        end
        UI.TeleportScroller.CanvasSize = UDim2.new(0, 0, 0, order * 42)
    end

    refreshTeleportList()
    table.insert(connections, Players.PlayerAdded:Connect(refreshTeleportList))
    table.insert(connections, Players.PlayerRemoving:Connect(refreshTeleportList))
end

-- TAB 5 (Keybinds)
do
    local CardShowKeybindsHud = createCard(5, 1)
    local LblShowKeybindsHud = Instance.new("TextLabel", CardShowKeybindsHud)
    LblShowKeybindsHud.Size = UDim2.new(0, 200, 0, 34); LblShowKeybindsHud.Position = UDim2.new(0, 12, 0, 0); LblShowKeybindsHud.BackgroundTransparency = 1
    LblShowKeybindsHud.Font = Settings.CustomFont; LblShowKeybindsHud.Text = "Show Keybinds HUD"; LblShowKeybindsHud.TextColor3 = Theme.Text; LblShowKeybindsHud.TextSize = 14; LblShowKeybindsHud.TextXAlignment = Enum.TextXAlignment.Left; LblShowKeybindsHud.ZIndex = 4

    UI.ToggleTrackKeybindsHud = Instance.new("Frame", CardShowKeybindsHud)
    UI.ToggleTrackKeybindsHud.Size = UDim2.new(0, 34, 0, 18); UI.ToggleTrackKeybindsHud.Position = UDim2.new(1, -46, 0.5, -9); UI.ToggleTrackKeybindsHud.BackgroundColor3 = Theme.Off; UI.ToggleTrackKeybindsHud.BorderSizePixel = 0; UI.ToggleTrackKeybindsHud.ZIndex = 4
    Instance.new("UICorner", UI.ToggleTrackKeybindsHud).CornerRadius = UDim.new(1, 0)
    UI.ToggleKnobKeybindsHud = Instance.new("Frame", UI.ToggleTrackKeybindsHud)
    UI.ToggleKnobKeybindsHud.Size = UDim2.new(0, 14, 0, 14); UI.ToggleKnobKeybindsHud.Position = UDim2.new(0, 2, 0.5, -7); UI.ToggleKnobKeybindsHud.BackgroundColor3 = Color3.fromRGB(255, 255, 255); UI.ToggleKnobKeybindsHud.BorderSizePixel = 0; UI.ToggleKnobKeybindsHud.ZIndex = 5
    Instance.new("UICorner", UI.ToggleKnobKeybindsHud).CornerRadius = UDim.new(1, 0)

    local function createKeybindCard(labelText, settingKey, order)
        local card = createCard(5, order)
        local lbl = Instance.new("TextLabel", card)
        lbl.Size = UDim2.new(0, 200, 0, 34); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
        lbl.Font = Settings.CustomFont; lbl.Text = labelText; lbl.TextColor3 = Theme.Text; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4

        local val = Instance.new("TextLabel", card)
        val.Size = UDim2.new(0, 100, 0, 34); val.Position = UDim2.new(1, -112, 0, 0); val.BackgroundTransparency = 1
        val.Font = Settings.CustomFont; val.Text = "[" .. getKeyName(Settings[settingKey]) .. "]"; val.TextColor3 = Theme.Accent; val.TextSize = 13; val.TextXAlignment = Enum.TextXAlignment.Right; val.ZIndex = 4
        return card, val
    end

    UI.CardKeyAimbot, UI.ValKeyAimbot = createKeybindCard("Aimbot", "KeyAimbot", 2)
    UI.CardKeySilent, UI.ValKeySilent = createKeybindCard("Silent Aim", "KeySilentAim", 3)
    UI.CardKeyFly, UI.ValKeyFly = createKeybindCard("Fly Toggle", "KeyFly", 4)
    UI.CardKeyMenu, UI.ValKeyMenu = createKeybindCard("Menu Toggle", "KeyToggleMenu", 5)
    UI.CardUnload, UI.ValKeyUnload = createKeybindCard("Unload", "KeyUnload", 6)
    UI.CardShowKeybindsHud = CardShowKeybindsHud
end

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Radius = Settings.FOVSize
fovCircle.Color = Color3.fromRGB(255, 255, 255)
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
        HeadDot = Drawing.new("Circle"),
        Skeleton = {},
        Highlight = Instance.new("Highlight")
    }
    
    drawings.BoxOutline.Thickness = 3; drawings.BoxOutline.Filled = false; drawings.BoxOutline.Color = Color3.fromRGB(0, 0, 0); drawings.BoxOutline.Visible = false
    drawings.Box.Thickness = 1.5; drawings.Box.Filled = false; drawings.Box.Visible = false
    drawings.Name.Size = 13; drawings.Name.Center = true; drawings.Name.Outline = true; drawings.Name.Color = Color3.fromRGB(255, 255, 255); drawings.Name.Visible = false
    drawings.HealthBarBackground.Thickness = 4; drawings.HealthBarBackground.Color = Color3.fromRGB(0, 0, 0); drawings.HealthBarBackground.Visible = false
    drawings.HealthBar.Thickness = 2; drawings.HealthBar.Visible = false
    drawings.Tracer.Thickness = 1.5; drawings.Tracer.Visible = false
    drawings.HeadDot.Radius = 5; drawings.HeadDot.Filled = true; drawings.HeadDot.NumSides = 20; drawings.HeadDot.Visible = false
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

local function updateUIStates()
    local t = Theme
    UI.ToggleTrack1.BackgroundColor3 = Settings.AimbotEnabled and t.Accent or t.Off
    UI.ToggleKnob1.Position = Settings.AimbotEnabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    
    UI.ToggleTrackSilent.BackgroundColor3 = Settings.SilentAimEnabled and t.Accent or t.Off
    UI.ToggleKnobSilent.Position = Settings.SilentAimEnabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    
    UI.ToggleTrackTrigger.BackgroundColor3 = Settings.TriggerbotEnabled and t.Accent or t.Off
    UI.ToggleKnobTrigger.Position = Settings.TriggerbotEnabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.ValTarget.Text = Settings.TargetPart
    UI.ValAimbotMode.Text = Settings.AimbotMode

    UI.ToggleTrackTeamCheck.BackgroundColor3 = Settings.TeamCheck and t.Accent or t.Off
    UI.ToggleKnobTeamCheck.Position = Settings.TeamCheck and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.ToggleTrackWall.BackgroundColor3 = Settings.WallCheck and t.Accent or t.Off
    UI.ToggleKnobWall.Position = Settings.WallCheck and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.ToggleTrack3.BackgroundColor3 = Settings.ShowFOV and t.Accent or t.Off
    UI.ToggleKnob3.Position = Settings.ShowFOV and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.TrackTeamCheckESP.BackgroundColor3 = Settings.TeamCheckESP and t.Accent or t.Off
    UI.KnobTeamCheckESP.Position = Settings.TeamCheckESP and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.TrackEspHighlight.BackgroundColor3 = Settings.ESPHighlight and t.Accent or t.Off
    UI.KnobEspHighlight.Position = Settings.ESPHighlight and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    
    UI.TrackEspBox.BackgroundColor3 = Settings.ESPBox and t.Accent or t.Off
    UI.KnobEspBox.Position = Settings.ESPBox and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.TrackEspName.BackgroundColor3 = Settings.ESPName and t.Accent or t.Off
    UI.KnobEspName.Position = Settings.ESPName and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.TrackEspHealth.BackgroundColor3 = Settings.ESPHealth and t.Accent or t.Off
    UI.KnobEspHealth.Position = Settings.ESPHealth and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.TrackEspSkeleton.BackgroundColor3 = Settings.ESPSkeleton and t.Accent or t.Off
    UI.KnobEspSkeleton.Position = Settings.ESPSkeleton and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.TrackEspTracers.BackgroundColor3 = Settings.ESPTracers and t.Accent or t.Off
    UI.KnobEspTracers.Position = Settings.ESPTracers and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.TrackEspHeadDot.BackgroundColor3 = Settings.ESPHeadDot and t.Accent or t.Off
    UI.KnobEspHeadDot.Position = Settings.ESPHeadDot and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.ToggleTrackFly.BackgroundColor3 = Settings.FlyActive and t.Accent or t.Off
    UI.ToggleKnobFly.Position = Settings.FlyActive and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    UI.ToggleTrackFlyNoClip.BackgroundColor3 = Settings.FlyNoClip and t.Accent or t.Off
    UI.ToggleKnobFlyNoClip.Position = Settings.FlyNoClip and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.ToggleTrackWalkSpeed.BackgroundColor3 = Settings.WalkSpeedActive and t.Accent or t.Off
    UI.ToggleKnobWalkSpeed.Position = Settings.WalkSpeedActive and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    UI.ToggleTrackJumpPower.BackgroundColor3 = Settings.JumpPowerActive and t.Accent or t.Off
    UI.ToggleKnobJumpPower.Position = Settings.JumpPowerActive and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    UI.ToggleTrackInfJump.BackgroundColor3 = Settings.InfiniteJumpActive and t.Accent or t.Off
    UI.ToggleKnobInfJump.Position = Settings.InfiniteJumpActive and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

    UI.ToggleTrackKeybindsHud.BackgroundColor3 = Settings.ShowKeybindsHud and t.Accent or t.Off
    UI.ToggleKnobKeybindsHud.Position = Settings.ShowKeybindsHud and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    UI.KeybindsHud.Visible = Settings.ShowKeybindsHud

    UI.ValKeyAimbot.Text = "[" .. (listeningForKey == "KeyAimbot" and "..." or getKeyName(Settings.KeyAimbot)) .. "]"
    UI.ValKeySilent.Text = "[" .. (listeningForKey == "KeySilentAim" and "..." or getKeyName(Settings.KeySilentAim)) .. "]"
    UI.ValKeyFly.Text = "[" .. (listeningForKey == "KeyFly" and "..." or getKeyName(Settings.KeyFly)) .. "]"
    UI.ValKeyMenu.Text = "[" .. (listeningForKey == "KeyToggleMenu" and "..." or getKeyName(Settings.KeyToggleMenu)) .. "]"
    UI.ValKeyUnload.Text = "[" .. (listeningForKey == "KeyUnload" and "..." or getKeyName(Settings.KeyUnload)) .. "]"

    UI.HudRowAimbot.Text = "Aimbot [" .. getKeyName(Settings.KeyAimbot) .. "]"
    UI.HudRowSilent.Text = "Silent [" .. getKeyName(Settings.KeySilentAim) .. "]"
    UI.HudRowFly.Text = "Movement [" .. getKeyName(Settings.KeyFly) .. "]"
    UI.HudRowMenu.Text = "Menu [" .. getKeyName(Settings.KeyToggleMenu) .. "]"
    UI.HudStatusUnload.Text = "Press " .. getKeyName(Settings.KeyUnload) .. " to Unload"

    local isAimbotActive = (Settings.AimbotMode == "Hold") and UIState.isAimbotHeld or Settings.AimbotEnabled
    UI.HudStatusAimbot.Text = isAimbotActive and "ON" or "OFF"
    UI.HudStatusAimbot.TextColor3 = isAimbotActive and t.Accent or Color3.fromRGB(239, 68, 68)

    UI.HudStatusSilent.Text = Settings.SilentAimEnabled and "ON" or "OFF"
    UI.HudStatusSilent.TextColor3 = Settings.SilentAimEnabled and t.Accent or Color3.fromRGB(239, 68, 68)

    UI.HudStatusMenu.Text = UIState.menuVisible and "ON" or "OFF"
    UI.HudStatusMenu.TextColor3 = UIState.menuVisible and t.Accent or Color3.fromRGB(239, 68, 68)
end

local function unloadHub()
    if UIState.isShooting then
        pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
        UIState.isShooting = false
    end
    for _, conn in ipairs(connections) do conn:Disconnect() end
    pcall(function() fovCircle:Remove() end)
    for p, _ in pairs(espDrawings) do removeDrawingESP(p) end
    UI.ScreenGui:Destroy()
    local char = Player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then 
        humanoid.PlatformStand = false 
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
end

local draggingMain = false
local dragStartMain, startPosMain

UI.Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = UI.MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingMain = false end
        end)
    end
end)

local draggingHud = false
local dragStartHud, startPosHud

UI.KeybindsHud.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingHud = true
        dragStartHud = input.Position
        startPosHud = UI.KeybindsHud.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingHud = false end
        end)
    end
end)

local resizingMain = false
local resizeStartPos, startSizeMain

UI.ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizingMain = true
        resizeStartPos = input.Position
        startSizeMain = UI.MainFrame.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then resizingMain = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingMain then
            local delta = input.Position - dragStartMain
            UI.MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        elseif draggingHud then
            local delta = input.Position - dragStartHud
            UI.KeybindsHud.Position = UDim2.new(startPosHud.X.Scale, startPosHud.X.Offset + delta.X, startPosHud.Y.Scale, startPosHud.Y.Offset + delta.Y)
        elseif resizingMain then
            local delta = input.Position - resizeStartPos
            local newWidth = math.clamp(startSizeMain.X + delta.X, 350, 800)
            local newHeight = math.clamp(startSizeMain.Y + delta.Y, 250, 600)
            UI.MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end
end)

local function switchTab(tabIndex)
    UIState.currentTab = tabIndex
    for i, scroller in ipairs(UI.tabContainers) do
        scroller.Visible = (i == tabIndex and UIState.menuVisible)
    end
    for i, tabBtn in ipairs({UI.Tab1, UI.Tab2, UI.Tab3, UI.Tab4, UI.Tab5}) do
        tabBtn.BackgroundColor3 = (i == tabIndex) and Theme.TabActive or Theme.TabInactive
        tabBtn.TextColor3 = (i == tabIndex) and Theme.Text or Theme.SubText
    end
end

local function setVisibility(state)
    UI.MainFrame.Visible = state
    switchTab(UIState.currentTab)
end

table.insert(connections, UI.Tab1.MouseButton1Click:Connect(function() switchTab(1) end))
table.insert(connections, UI.Tab2.MouseButton1Click:Connect(function() switchTab(2) end))
table.insert(connections, UI.Tab3.MouseButton1Click:Connect(function() switchTab(3) end))
table.insert(connections, UI.Tab4.MouseButton1Click:Connect(function() switchTab(4) end))
table.insert(connections, UI.Tab5.MouseButton1Click:Connect(function() switchTab(5) end))

table.insert(connections, UI.Card1.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.AimbotEnabled = not Settings.AimbotEnabled; updateUIStates() end end))
table.insert(connections, UI.CardSilent.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.SilentAimEnabled = not Settings.SilentAimEnabled; updateUIStates() end end))
table.insert(connections, UI.CardTriggerbot.InputBegan:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
        Settings.TriggerbotEnabled = not Settings.TriggerbotEnabled 
        if not Settings.TriggerbotEnabled and UIState.isShooting then
            pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
            UIState.isShooting = false
        end
        updateUIStates() 
    end 
end))
table.insert(connections, UI.CardTeamCheck.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.TeamCheck = not Settings.TeamCheck; updateUIStates() end end))
table.insert(connections, UI.CardWallCheck.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.WallCheck = not Settings.WallCheck; updateUIStates() end end))
table.insert(connections, UI.CardFOV.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ShowFOV = not Settings.ShowFOV; updateUIStates() end end))

table.insert(connections, UI.CardTeamCheckESP.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.TeamCheckESP = not Settings.TeamCheckESP; updateUIStates() end end))
table.insert(connections, UI.CardEspHighlight.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPHighlight = not Settings.ESPHighlight; updateUIStates() end end))
table.insert(connections, UI.CardEspBox.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPBox = not Settings.ESPBox; updateUIStates() end end))
table.insert(connections, UI.CardEspName.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPName = not Settings.ESPName; updateUIStates() end end))
table.insert(connections, UI.CardEspHealth.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPHealth = not Settings.ESPHealth; updateUIStates() end end))
table.insert(connections, UI.CardEspSkeleton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPSkeleton = not Settings.ESPSkeleton; updateUIStates() end end))
table.insert(connections, UI.CardEspTracers.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPTracers = not Settings.ESPTracers; updateUIStates() end end))
table.insert(connections, UI.CardEspHeadDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ESPHeadDot = not Settings.ESPHeadDot; updateUIStates() end end))

table.insert(connections, UI.CardFly.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.FlyActive = not Settings.FlyActive; updateUIStates() end end))
table.insert(connections, UI.CardFlyNoClip.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.FlyNoClip = not Settings.FlyNoClip; updateUIStates() end end))
table.insert(connections, UI.CardWalkSpeed.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.WalkSpeedActive = not Settings.WalkSpeedActive; updateUIStates() end end))
table.insert(connections, UI.CardJumpPower.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.JumpPowerActive = not Settings.JumpPowerActive; updateUIStates() end end))
table.insert(connections, UI.CardInfJump.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.InfiniteJumpActive = not Settings.InfiniteJumpActive; updateUIStates() end end))
table.insert(connections, UI.CardShowKeybindsHud.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Settings.ShowKeybindsHud = not Settings.ShowKeybindsHud; updateUIStates() end end))

table.insert(connections, UI.TargetingSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingTargetingSlider = true end end))
table.insert(connections, UI.TrackingSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingTrackingSlider = true end end))
table.insert(connections, UI.TriggerDelayTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingTriggerDelaySlider = true end end))
table.insert(connections, UI.FOVSliderTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingFOVSlider = true end end))
table.insert(connections, UI.FlySpeedTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingFlySpeedSlider = true end end))
table.insert(connections, UI.FlyVertTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingFlyVertSlider = true end end))
table.insert(connections, UI.WalkSpeedTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingWalkSpeedSlider = true end end))
table.insert(connections, UI.JumpPowerTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then UIState.draggingJumpPowerSlider = true end end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UIState.draggingTargetingSlider = false; UIState.draggingTrackingSlider = false; UIState.draggingTriggerDelaySlider = false; UIState.draggingFOVSlider = false; UIState.draggingFlySpeedSlider = false; UIState.draggingFlyVertSlider = false; UIState.draggingWalkSpeedSlider = false; UIState.draggingJumpPowerSlider = false; resizingMain = false
    end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        if UIState.draggingTargetingSlider then
            local absPos = UI.TargetingSliderTrack.AbsolutePosition; local absSize = UI.TargetingSliderTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.TargetingSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TargetingSmoothness = math.floor(pos * 100) / 100; UI.TargetingSliderText.Text = math.floor(pos * 100) .. "%"
        elseif UIState.draggingTrackingSlider then
            local absPos = UI.TrackingSliderTrack.AbsolutePosition; local absSize = UI.TrackingSliderTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.TrackingSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TrackingSmoothness = math.floor(pos * 100) / 100; UI.TrackingSliderText.Text = math.floor(pos * 100) .. "%"
        elseif UIState.draggingTriggerDelaySlider then
            local absPos = UI.TriggerDelayTrack.AbsolutePosition; local absSize = UI.TriggerDelayTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.TriggerDelayFill.Size = UDim2.new(pos, 0, 1, 0); Settings.TriggerbotDelay = math.floor(pos * 100) / 100; UI.TriggerDelayText.Text = string.format("%.2fs", Settings.TriggerbotDelay)
        elseif UIState.draggingFOVSlider then
            local absPos = UI.FOVSliderTrack.AbsolutePosition; local absSize = UI.FOVSliderTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.FOVSliderFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FOVSize = math.floor(pos * 400) + 1; UI.FOVSliderText.Text = tostring(Settings.FOVSize); fovCircle.Radius = Settings.FOVSize
        elseif UIState.draggingFlySpeedSlider then
            local absPos = UI.FlySpeedTrack.AbsolutePosition; local absSize = UI.FlySpeedTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.FlySpeedFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FlySpeed = math.floor(pos * 290) + 10; UI.FlySpeedText.Text = tostring(Settings.FlySpeed)
        elseif UIState.draggingFlyVertSlider then
            local absPos = UI.FlyVertTrack.AbsolutePosition; local absSize = UI.FlyVertTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.FlyVertFill.Size = UDim2.new(pos, 0, 1, 0); Settings.FlyVerticalSpeed = math.floor(pos * 290) + 10; UI.FlyVertText.Text = tostring(Settings.FlyVerticalSpeed)
        elseif UIState.draggingWalkSpeedSlider then
            local absPos = UI.WalkSpeedTrack.AbsolutePosition; local absSize = UI.WalkSpeedTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.WalkSpeedFill.Size = UDim2.new(pos, 0, 1, 0); Settings.WalkSpeedValue = math.floor(pos * 234) + 16; UI.WalkSpeedText.Text = tostring(Settings.WalkSpeedValue)
        elseif UIState.draggingJumpPowerSlider then
            local absPos = UI.JumpPowerTrack.AbsolutePosition; local absSize = UI.JumpPowerTrack.AbsoluteSize
            local pos = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
            UI.JumpPowerFill.Size = UDim2.new(pos, 0, 1, 0); Settings.JumpPowerValue = math.floor(pos * 200) + 50; UI.JumpPowerText.Text = tostring(Settings.JumpPowerValue)
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

setupKeybindCard(UI.CardKeyAimbot, "KeyAimbot")
setupKeybindCard(UI.CardKeySilent, "KeySilentAim")
setupKeybindCard(UI.CardKeyFly, "KeyFly")
setupKeybindCard(UI.CardKeyMenu, "KeyToggleMenu")
setupKeybindCard(UI.CardUnload, "KeyUnload")

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

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
        UIState.menuVisible = not UIState.menuVisible; setVisibility(UIState.menuVisible); updateUIStates()
    elseif isInputMatching(input, Settings.KeyUnload) then
        unloadHub()
    elseif isInputMatching(input, Settings.KeyFly) then
        Settings.FlyActive = not Settings.FlyActive; updateUIStates()
    elseif isInputMatching(input, Settings.KeyAimbot) then
        if Settings.AimbotMode == "Toggle" then
            Settings.AimbotEnabled = not Settings.AimbotEnabled
        else
            UIState.isAimbotHeld = true
        end
        updateUIStates()
    elseif isInputMatching(input, Settings.KeySilentAim) then
        Settings.SilentAimEnabled = not Settings.SilentAimEnabled
        updateUIStates()
    elseif Settings.InfiniteJumpActive and input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
        local char = Player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if isInputMatching(input, Settings.KeyAimbot) and Settings.AimbotMode == "Hold" then
        UIState.isAimbotHeld = false
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
    if player.Team and Player.Team and player.Team == Player.Team then return true end
    return false
end

local function isWeaponAutomatic(tool)
    if not tool then return true end
    if tool:GetAttribute("Auto") ~= nil then return tool:GetAttribute("Auto")
    elseif tool:GetAttribute("FireMode") == "Semi" then return false end
    local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Settings") or tool:FindFirstChild("Config")
    if config then
        local autoVal = config:FindFirstChild("Auto") or config:FindFirstChild("FullyAutomatic")
        if autoVal and autoVal:IsA("BoolValue") then return autoVal.Value end
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

local function isCursorOverPlayer()
    local mouseLoc = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local excludeList = {Player.Character, Camera}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and (not Settings.TeamCheck or not isTeammate(p)) then
            table.insert(excludeList, p.Character)
        end
    end
    rayParams.FilterDescendantsInstances = excludeList
    
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
    if raycastResult and raycastResult.Instance then
        local hitPart = raycastResult.Instance
        local hitModel = hitPart:FindFirstAncestorOfClass("Model")
        if hitModel then
            local targetPlayer = Players:GetPlayerFromCharacter(hitModel)
            if targetPlayer and targetPlayer ~= Player then
                if not Settings.TeamCheck or not isTeammate(targetPlayer) then
                    local hum = hitModel:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Silent Aim hook for raycasts / camera redirection
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Settings.SilentAimEnabled and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" or method == "Raycast") then
        local target = getClosestTarget()
        if target then
            if method == "Raycast" and typeof(args[2]) == "Vector3" then
                args[2] = (target.Position - args[1]).Unit * args[2].Magnitude
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

table.insert(connections, RunService.RenderStepped:Connect(function(deltaTime)
    fovCircle.Visible = Settings.ShowFOV and (Settings.FOVSize > 0)
    if Settings.ShowFOV and Settings.FOVSize > 0 then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Settings.FOVSize
    end

    local aimbotActive = (Settings.AimbotMode == "Hold" and UIState.isAimbotHeld) or (Settings.AimbotMode == "Toggle" and Settings.AimbotEnabled)
    local target = getClosestTarget()
    
    if target then
        if aimbotActive then
            local goalCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            local targetScreenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local distFromCenter = onScreen and (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - viewportCenter).Magnitude or 0
            local activeSmoothness = (distFromCenter < 25) and Settings.TrackingSmoothness or Settings.TargetingSmoothness
            local smoothFactor = math.clamp((1 - activeSmoothness) * (deltaTime * 60), 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, smoothFactor)
        end

        if Settings.TriggerbotEnabled then
            local character = target.Parent
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and isCursorOverPlayer() then
                local currentTool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
                if isWeaponAutomatic(currentTool) then
                    if not UIState.isShooting then
                        UIState.isShooting = true
                        task.spawn(function() pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) end) end)
                    end
                else
                    local currentTime = tick()
                    if currentTime - UIState.lastTriggerShot >= Settings.TriggerbotDelay then
                        UIState.lastTriggerShot = currentTime
                        task.spawn(function()
                            pcall(function()
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end)
                        end)
                    end
                end
            elseif UIState.isShooting then
                pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
                UIState.isShooting = false
            end
        end
    elseif UIState.isShooting then
        pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
        UIState.isShooting = false
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
                drawings.Box.Visible = false; drawings.BoxOutline.Visible = false; drawings.Name.Visible = false
                drawings.HealthBar.Visible = false; drawings.HealthBarBackground.Visible = false; drawings.Tracer.Visible = false; drawings.HeadDot.Visible = false
                for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
            else
                local targetColor = Color3.fromRGB(255, 255, 255)
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
                            drawings.HealthBar.Color = Color3.fromRGB(34, 197, 94)
                        else
                            drawings.HealthBar.Visible = false; drawings.HealthBarBackground.Visible = false
                        end
                        
                        if Settings.ESPHeadDot then
                            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                            if headOnScreen then
                                drawings.HeadDot.Visible = true
                                drawings.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                                drawings.HeadDot.Color = targetColor
                            else
                                drawings.HeadDot.Visible = false
                            end
                        else
                            drawings.HeadDot.Visible = false
                        end
                        
                        if Settings.ESPSkeleton then
                            local bonePairs = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerLeg"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}
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
                        drawings.Box.Visible = false; drawings.BoxOutline.Visible = false; drawings.Name.Visible = false; drawings.HealthBar.Visible = false; drawings.HealthBarBackground.Visible = false; drawings.Tracer.Visible = false; drawings.HeadDot.Visible = false
                        for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
                    end
                else
                    drawings.Box.Visible = false; drawings.BoxOutline.Visible = false; drawings.Name.Visible = false; drawings.HealthBar.Visible = false; drawings.HealthBarBackground.Visible = false; drawings.Tracer.Visible = false; drawings.HeadDot.Visible = false
                    for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
                end
            end
        end
    end

    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local hrp = char.HumanoidRootPart; local humanoid = char:FindFirstChildOfClass("Humanoid")
        
        if Settings.WalkSpeedActive then pcall(function() humanoid.WalkSpeed = Settings.WalkSpeedValue end) end
        if Settings.JumpPowerActive then pcall(function() humanoid.UseJumpPower = true; humanoid.JumpPower = Settings.JumpPowerValue end) end

        if Settings.FlyActive then
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Physics) end)
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
        elseif humanoid.PlatformStand and not Settings.FlyActive then
            humanoid.PlatformStand = false
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end
end))
