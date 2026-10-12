-- ==============================================================================
-- 🍓🍼 いちごミルク Hub
-- プレイヤー TEST
-- ==============================================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ==============================================================================
-- 設定
-- ==============================================================================

local SpeedValue = 16
local JumpValue = 50

local SpeedEnabled = true
local JumpEnabled = true
local InfiniteJumpEnabled = false
local HPEnabled = true

-- ==============================================================================
-- Window
-- ==============================================================================

local Window = Rayfield:CreateWindow({
    Name = "いちごミルク 🍓🍼",
    LoadingTitle = "いちごミルク",
    LoadingSubtitle = "制作者いちごミルク🍓🍼おもちHUB",

    Theme = {
        TextColor = Color3.fromRGB(180, 100, 130),
        Background = Color3.fromRGB(255, 240, 245),
        Topbar = Color3.fromRGB(255, 210, 220),
        Shadow = Color3.fromRGB(220, 150, 170),
        NotificationBackground = Color3.fromRGB(255, 240, 245),
        NotificationActionsBackground = Color3.fromRGB(255, 210, 220),
        TabBackground = Color3.fromRGB(255, 225, 235),
        TabStroke = Color3.fromRGB(220, 160, 180),
        TabBackgroundSelected = Color3.fromRGB(255, 180, 200),
        TabTextColor = Color3.fromRGB(200, 130, 155),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(255, 225, 235),
        ElementBackgroundHover = Color3.fromRGB(255, 200, 215),
        SecondaryElementBackground = Color3.fromRGB(255, 240, 245),
        ElementStroke = Color3.fromRGB(220, 160, 180),
        SecondaryElementStroke = Color3.fromRGB(200, 150, 170),
        SliderBackground = Color3.fromRGB(255, 225, 235),
        SliderProgress = Color3.fromRGB(255, 150, 180),
        SliderStroke = Color3.fromRGB(220, 160, 180),
        ToggleBackground = Color3.fromRGB(255, 200, 215),
        ToggleEnabled = Color3.fromRGB(255, 150, 180),
        ToggleDisabled = Color3.fromRGB(200, 160, 170),
        ToggleEnabledStroke = Color3.fromRGB(255, 150, 180),
        ToggleDisabledStroke = Color3.fromRGB(200, 160, 170),
        ToggleEnabledOuterStroke = Color3.fromRGB(255, 150, 180),
        ToggleDisabledOuterStroke = Color3.fromRGB(200, 160, 170),
        DropdownSelected = Color3.fromRGB(255, 200, 215),
        DropdownUnselected = Color3.fromRGB(255, 225, 235),
        InputBackground = Color3.fromRGB(255, 240, 245),
        InputStroke = Color3.fromRGB(220, 160, 180),
        PlaceholderColor = Color3.fromRGB(200, 150, 170),
    },

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "IchigoMilkHub",
        FileName = "Config"
    },

    KeySystem = false
})

-- ==============================================================================
-- プレイヤータブ
-- ==============================================================================

local PlayerTab = Window:CreateTab("プレイヤー", 4483362458)

PlayerTab:CreateSection("🏃 プレイヤー")

-- ==============================================================================
-- Character
-- ==============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character
local Humanoid

local function GetCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    return Humanoid
end

local function ApplySettings()
    if not Humanoid or Humanoid.Health <= 0 then
        return
    end

    if SpeedEnabled then
        Humanoid.WalkSpeed = SpeedValue
    else
        Humanoid.WalkSpeed = 16
    end

    if JumpEnabled then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = JumpValue
    else
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = 50
    end
end

GetCharacter()

-- ==============================================================================
-- Speed
-- ==============================================================================

PlayerTab:CreateToggle({
    Name = "🏃 スピード ON / OFF",
    CurrentValue = true,
    Flag = "SpeedEnabled",

    Callback = function(Value)
        SpeedEnabled = Value
        ApplySettings()
    end,
})

PlayerTab:CreateSlider({
    Name = "🏃 スピード調整",
    Range = {16, 100},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "SpeedValue",

    Callback = function(Value)
        SpeedValue = Value
        ApplySettings()
    end,
})

-- ==============================================================================
-- Jump Power
-- ==============================================================================

PlayerTab:CreateToggle({
    Name = "🦘 ジャンプ力 ON / OFF",
    CurrentValue = true,
    Flag = "JumpEnabled",

    Callback = function(Value)
        JumpEnabled = Value
        ApplySettings()
    end,
})

PlayerTab:CreateSlider({
    Name = "🦘 ジャンプ力調整",
    Range = {50, 100},
    Increment = 1,
    Suffix = " Jump",
    CurrentValue = 50,
    Flag = "JumpValue",

    Callback = function(Value)
        JumpValue = Value
        ApplySettings()
    end,
})

-- ==============================================================================
-- Infinite Jump
-- ==============================================================================

PlayerTab:CreateToggle({
    Name = "♾️ 無限ジャンプ",
    CurrentValue = false,
    Flag = "InfiniteJump",

    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and Humanoid and Humanoid.Health > 0 then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ==============================================================================
-- HP Gauge
-- ==============================================================================

local HPGui = Instance.new("ScreenGui")
HPGui.Name = "IchigoMilkHP"
HPGui.ResetOnSpawn = false
HPGui.IgnoreGuiInset = true
HPGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local HPBackground = Instance.new("Frame")
HPBackground.Name = "HPBackground"
HPBackground.AnchorPoint = Vector2.new(0.5, 1)
HPBackground.Position = UDim2.new(0.5, 0, 1, -25)
HPBackground.Size = UDim2.new(0, 300, 0, 25)
HPBackground.BackgroundColor3 = Color3.fromRGB(70, 45, 55)
HPBackground.BorderSizePixel = 0
HPBackground.Parent = HPGui

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(1, 0)
BGCorner.Parent = HPBackground

local HPBar = Instance.new("Frame")
HPBar.Name = "HPBar"
HPBar.Size = UDim2.new(1, 0, 1, 0)
HPBar.BackgroundColor3 = Color3.fromRGB(255, 150, 190)
HPBar.BorderSizePixel = 0
HPBar.Parent = HPBackground

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = HPBar

local HPText = Instance.new("TextLabel")
HPText.BackgroundTransparency = 1
HPText.Size = UDim2.new(1, 0, 1, 0)
HPText.TextColor3 = Color3.fromRGB(255, 255, 255)
HPText.TextSize = 14
HPText.Font = Enum.Font.GothamBold
HPText.Text = "🍓 HP 100 / 100"
HPText.Parent = HPBackground

-- HP色を決める
local function GetHPColor(Percent)
    if Percent > 0.5 then
        -- ピンク
        return Color3.fromRGB(255, 150, 190)
    elseif Percent > 0.25 then
        -- オレンジ
        local T = (Percent - 0.25) / 0.25

        return Color3.new(
            1,
            0.35 + (0.25 * T),
            0.05
        )
    else
        -- 赤
        return Color3.fromRGB(255, 40, 40)
    end
end

local function UpdateHP()
    if not Humanoid then
        return
    end

    local MaxHP = math.max(Humanoid.MaxHealth, 1)
    local HP = math.clamp(Humanoid.Health, 0, MaxHP)
    local Percent = HP / MaxHP

    HPBar.Size = UDim2.new(Percent, 0, 1, 0)
    HPBar.BackgroundColor3 = GetHPColor(Percent)

    HPText.Text = string.format(
        "🍓 HP %.0f / %.0f",
        HP,
        MaxHP
    )
end

local function ConnectHP()
    if not Humanoid then
        return
    end

    Humanoid.HealthChanged:Connect(UpdateHP)
    Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(UpdateHP)

    UpdateHP()
end

ConnectHP()

-- ==============================================================================
-- HP ON / OFF
-- ==============================================================================

PlayerTab:CreateToggle({
    Name = "🍓 HPゲージ",
    CurrentValue = true,
    Flag = "HPGauge",

    Callback = function(Value)
        HPEnabled = Value
        HPBackground.Visible = Value
    end,
})

-- ==============================================================================
-- Character Reset
-- ==============================================================================

PlayerTab:CreateButton({
    Name = "🔄 キャラクターリセット",

    Callback = function()
        if Humanoid then
            Humanoid.Health = 0
        end
    end,
})

-- ==============================================================================
-- Respawn
-- ==============================================================================

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = NewCharacter:WaitForChild("Humanoid")

    task.wait(0.2)

    -- リスポーンしても設定を維持
    ApplySettings()

    -- HPゲージを再接続
    ConnectHP()

    HPBackground.Visible = HPEnabled
end)

-- 初回適用
ApplySettings()

Rayfield:Notify({
    Title = "🍓🍼 いちごミルク",
    Content = "プレイヤーページを読み込みました！",
    Duration = 3
})