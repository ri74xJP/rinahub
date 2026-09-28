--[[
    Roblox 空飛びスクリプト + UI (LocalScript / Executor 両対応)

    ■ 操作
    F        : 飛行 ON / OFF
    W A S D  : 前後左右 (カメラ基準)
    Space    : 上昇
    LCTRL    : 下降

    ■ UI
    右上のパネルで Fly トグル / 速度スライダー / 最小化
    ヘッダーをドラッグで移動可能
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ===== 設定 =====
local SPEED      = 80      -- 初期速度
local MIN_SPEED  = 10
local MAX_SPEED  = 300
local SMOOTHNESS = 10
local TOGGLE_KEY = Enum.KeyCode.F
-- =================

local flying     = false
local connection = nil
local attachment = nil
local linearVel  = nil

local keys = {
    [Enum.KeyCode.W]           = false,
    [Enum.KeyCode.A]           = false,
    [Enum.KeyCode.S]           = false,
    [Enum.KeyCode.D]           = false,
    [Enum.KeyCode.Space]       = false,
    [Enum.KeyCode.LeftControl] = false,
}

--========================================================
-- 飛行ロジック
--========================================================
local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    if flying then return end

    flying = true
    humanoid.PlatformStand = true

    attachment = Instance.new("Attachment")
    attachment.Name = "FlyAttachment"
    attachment.Parent = hrp

    linearVel = Instance.new("LinearVelocity")
    linearVel.Name = "FlyVelocity"
    linearVel.Attachment0 = attachment
    linearVel.MaxForce = math.huge
    linearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVel.VectorVelocity = Vector3.zero
    linearVel.Parent = hrp

    connection = RunService.RenderStepped:Connect(function(dt)
        if not flying or not hrp or not hrp.Parent then return end

        local camCF = camera.CFrame
        local look  = camCF.LookVector
        local right = camCF.RightVector

        local forwardFlat = Vector3.new(look.X, 0, look.Z)
        if forwardFlat.Magnitude > 0 then
            forwardFlat = forwardFlat.Unit
        end

        local move = Vector3.zero
        if keys[Enum.KeyCode.W] then move += forwardFlat end
        if keys[Enum.KeyCode.S] then move -= forwardFlat end
        if keys[Enum.KeyCode.D] then move += right end
        if keys[Enum.KeyCode.A] then move -= right end
        if keys[Enum.KeyCode.Space] then move += Vector3.yAxis end
        if keys[Enum.KeyCode.LeftControl] then move -= Vector3.yAxis end

        if move.Magnitude > 0 then
            move = move.Unit * SPEED
        end

        local current = linearVel.VectorVelocity
        linearVel.VectorVelocity = current:Lerp(move, math.clamp(dt * SMOOTHNESS, 0, 1))
    end)
end

local function stopFly()
    flying = false
    if connection then connection:Disconnect(); connection = nil end
    if linearVel  then linearVel:Destroy();       linearVel  = nil end
    if attachment then attachment:Destroy();      attachment = nil end

    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

--========================================================
-- UI 作成
--========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Executor でも表示されるように
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(screenGui) end
    if gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end
end)
if not screenGui.Parent then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 220, 0, 150)
main.Position = UDim2.new(1, -240, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 70)
mainStroke.Thickness = 1
mainStroke.Parent = main

-- ヘッダー
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

-- ヘッダー下側の角を隠すカバー
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🪱 Fly Control"
title.TextColor3 = Color3.fromRGB(230, 230, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- 最小化ボタン
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -30, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.AutoButtonColor = true
minBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

-- Fly トグルボタン
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -20, 0, 36)
flyBtn.Position = UDim2.new(0, 10, 0, 44)
flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
flyBtn.Text = "Fly: OFF"
flyBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextSize = 15
flyBtn.AutoButtonColor = false
flyBtn.Parent = main

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyBtn

-- 速度ラベル
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 88)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. SPEED
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = main

-- スライダー背景
local sliderBg = Instance.new("TextButton")
sliderBg.Size = UDim2.new(1, -20, 0, 12)
sliderBg.Position = UDim2.new(0, 10, 0, 116)
sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
sliderBg.Text = ""
sliderBg.AutoButtonColor = false
sliderBg.Parent = main

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(1, 0)
sliderBgCorner.Parent = sliderBg

-- スライダー塗り
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

--========================================================
-- UI ロジック
--========================================================
local function updateFlyButton()
    if flying then
        flyBtn.Text = "Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 90)
    else
        flyBtn.Text = "Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end
end

flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
    updateFlyButton()
end)

-- スライダードラッグ
local dragging = false

local function updateSlider(input)
    local pos = math.clamp(
        (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X,
        0, 1
    )
    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
    SPEED = math.floor(MIN_SPEED + (MAX_SPEED - MIN_SPEED) * pos)
    speedLabel.Text = "Speed: " .. SPEED
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ヘッダードラッグで移動
local draggingUI = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingUI = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingUI and (input.UserInputType == Enum.UserInputType.MouseMovement
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
        draggingUI = false
    end
end)

-- 最小化
local minimized = false
local fullHeight = 150
local miniHeight = 32

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Size = UDim2.new(0, 220, 0, minimized and miniHeight or fullHeight)
    flyBtn.Visible = not minimized
    speedLabel.Visible = not minimized
    sliderBg.Visible = not minimized
    minBtn.Text = minimized and "+" or "−"
end)

--========================================================
-- キー入力
--========================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == TOGGLE_KEY then
        if flying then
            stopFly()
        else
            startFly()
        end
        updateFlyButton()
        return
    end

    if keys[input.KeyCode] ~= nil then
        keys[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if keys[input.KeyCode] ~= nil then
        keys[input.KeyCode] = false
    end
end)

-- リスポーン時に解除
player.CharacterAdded:Connect(function()
    if flying then
        stopFly()
        updateFlyButton()
    end
end)

-- 初期表示
updateFlyButton()