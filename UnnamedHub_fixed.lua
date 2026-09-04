````
```
-- =====================================================
-- Unnamed Hub - プレイヤー + グラブ + 防御 + ブロブマン + Loop 完全合体版
-- Orion Library 必須 / Delta Executor iOS対応
-- =====================================================

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
if not OrionLib then error("Orion Library Load Failed") end

-- ===============================================
-- Orion Library の見た目だけをカスタマイズ
-- ===============================================
task.wait(0.5)

local coreGui = game:GetService("CoreGui")
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local function getRealImageId(decalId)
    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. decalId)[1].Texture
    end)
    if success and result then
        return result
    end
    return "rbxassetid://" .. decalId
end

local function customizeOrionUI()
    local orionGui = coreGui:FindFirstChild("OrionUI") or playerGui:FindFirstChild("OrionUI")
                 or coreGui:FindFirstChild("Orion") or playerGui:FindFirstChild("Orion")
    
    if not orionGui then return end

    local mainFrame = nil
    local maxArea = 0
    for _, obj in ipairs(orionGui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("CanvasGroup") then
            local size = obj.AbsoluteSize
            local area = size.X * size.Y
            if area > maxArea and area > 5000 then
                maxArea = area
                mainFrame = obj
            end
        end
    end
    
    if not mainFrame then return end

    for _, bg in ipairs(mainFrame:GetChildren()) do
        if bg.Name == "CustomBG" or bg.Name == "DarkOverlay" or bg.Name == "CustomCorner" then
            bg:Destroy()
        end
    end

    local targetImage = getRealImageId(130145157703967)

    local darkOverlay = Instance.new("Frame")
    darkOverlay.Name = "DarkOverlay"
    darkOverlay.Size = UDim2.new(1, 0, 1, 0)
    darkOverlay.Position = UDim2.new(0, 0, 0, 0)
    darkOverlay.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    darkOverlay.BackgroundTransparency = 0.2
    darkOverlay.ZIndex = 0
    darkOverlay.Parent = mainFrame

    local mainCorner = Instance.new("UICorner")
    mainCorner.Name = "CustomCorner"
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame

    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "CustomBG"
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.Position = UDim2.new(0, 0, 0, 0)
    bgImage.Image = targetImage
    bgImage.BackgroundTransparency = 1
    bgImage.ImageTransparency = 0.15
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 0
    bgImage.Parent = mainFrame

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 16)
    bgCorner.Parent = bgImage

    local overlayCorner = Instance.new("UICorner")
    overlayCorner.CornerRadius = UDim.new(0, 16)
    overlayCorner.Parent = darkOverlay

    mainFrame.BackgroundTransparency = 1
    mainFrame.ClipsDescendants = true

    for _, child in ipairs(mainFrame:GetDescendants()) do
        if child:IsA("ImageLabel") then
            if child.AbsoluteSize.X > 100 or child.AbsoluteSize.Y > 100 then
                if child ~= bgImage then
                    child.ImageTransparency = 1
                    child.BackgroundTransparency = 1
                end
            end
        end

        if child:IsA("Frame") or child:IsA("ScrollingFrame") or child:IsA("CanvasGroup") then
            if child ~= mainFrame and child ~= darkOverlay and not child:IsDescendantOf(bgImage) then
                child.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                child.BackgroundTransparency = 0.6
            end
        end

        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextColor3 = Color3.fromRGB(255, 255, 255)
            child.TextTransparency = 0
            if not child:FindFirstChildOfClass("UIStroke") then
                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(0, 0, 0)
                stroke.Thickness = 1
                stroke.Transparency = 0.5
                stroke.Parent = child
            end
        end

        if child:IsA("TextButton") or child:IsA("ImageButton") then
            child.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            child.BackgroundTransparency = 0.2
        end
    end

    print("UIカスタマイズ完了！")
end

task.spawn(function()
    while not (coreGui:FindFirstChild("OrionUI") or playerGui:FindFirstChild("OrionUI") or 
               coreGui:FindFirstChild("Orion") or playerGui:FindFirstChild("Orion")) do
        task.wait(0.1)
    end
    task.wait(0.3)
    customizeOrionUI()
end)

-- =====================================================
-- ここからUnnamed Hub本体
-- =====================================================

local service = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Debris = game:GetService("Debris"),
}

local localPlayer = service.Players.LocalPlayer

-- =====================================================
-- >> イベント取得
-- =====================================================
local RS = service.ReplicatedStorage
local GrabEvents = RS:WaitForChild("GrabEvents")
local MenuToys = RS:WaitForChild("MenuToys")
local CharacterEvents = RS:WaitForChild("CharacterEvents")
local PlayerEvents = RS:WaitForChild("PlayerEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local RagdollRemote = CharacterEvents:FindFirstChild("RagdollRemote")
local SpawnToyRemoteFunction = MenuToys:WaitForChild("SpawnToyRemoteFunction")
local BuyToyRemoteFunction = MenuToys:WaitForChild("BuyToyRemoteFunction")
local StickyPartEvent = PlayerEvents:WaitForChild("StickyPartEvent")
local SpawnedInToys = service.Workspace:WaitForChild(localPlayer.Name .. "SpawnedInToys")

-- =====================================================
-- >> 変数
-- =====================================================
local superSpeed = false
local infiniteJump = false
local noclip = false
local noclipConn = nil
local Multiplier = 0.15
local thirdPersonEnabled = false

local Vars = {
    grabFlags = {
        KillGrab = false,
        SkyGrab = false,
        SpinGrab = false,
        FreezeGrab = false,
        FlingGrab = false,
        VoidGrab = false,
        PoisonGrab = false,
        RagdollGrab = false,
        NoclipGrab = false,
        FireGrab = false,
        StrengthEnabled = false,
    },
}
_G.strength = 500

local Config = {
    AntiGrabToggle = false,
    AntiGrabNRD = false,
    AntiSticky = false,
    GucciAntiGrab = false,
    AntiBlob = false,
    AntiBlobman = false,
    AntiKickKunai = false,
    AntiKickJointBreak = false,
    AntiKickGrab = false,
    AntiKickV2 = false,
    AntiLag = false,
    AutoAntiLag = false,
    AntiExplosion = false,
    AntiBurn = false,
    AntiVoid = false,
    AntiBananaSit = false,
    AntiBlobKill = false,
    AntiBlobRagdoll = false,
    AntiPaint = false,
    AntiAFK = false,
    AntiRagdoll = false,
    AntiWater = false,
    AntiInputLag = false,
    SelectedToy = "FoodHamburger",
    AntiInputLagCoroutine = nil,
    KillBypassActive = false,
    KillBypassPlatform = nil,
    KillBypassLoopInterval = 0.02,
    KillBypassSavedCamCFrame = nil,
    KillBypassLoopCoroutine = nil,
    antiGrabProce = false,
    ragdollCount = 0,
    originalVoidHeight = nil,
    paintPartsBackup = {},
    paintConnections = {},
    antiKickCoroutine = nil,
    notifiedNoCoins = false,
    antiblobConnection = nil,
    AntiBlobmanCoroutine = nil,
    ragdoll_blob_defense_connections = {},
    ragdoll_seat_flag = false,
    burn_conn = nil,
    struggle_event_ref = nil,
    is_held_flag = nil,
    nrd_connections = {},
    grab_defense_nrd_processing = false,
    nrd_walk_lock = false,
    gucci_cycle_id = 0,
    FLAG = {},
    antiRagdollConnections = {},
    antiRagdollCharAddedConn = nil,
    banana_sit_defense_thread = nil,
    blob_kill_defense_thread = nil,
    auto_antilag_thread = nil,
    auto_antilag_enabled = false,
    beam_count = 0,
}

local ToyList = {
    ["Coconut"] = "FoodCoconut",
    ["Banana"] = "FoodBanana",
    ["Fries"] = "FoodFrenchFries",
    ["MeatStick"] = "FoodMeatStick",
    ["Poop"] = "PoopPile",
    ["Donut"] = "FoodDonut",
    ["Cake"] = "FoodCakePink",
    ["Burger"] = "FoodHamburger",
    ["Pizza"] = "FoodPizzaCheese",
    ["Hotdog"] = "FoodHotdog",
    ["Mushroom"] = "FoodMushroomPoison",
}
local ToyDropdownValues = {}
for shortName, _ in pairs(ToyList) do table.insert(ToyDropdownValues, shortName) end
table.sort(ToyDropdownValues)

local BlobConfig = {
    FloatAmount = 16,
    selectedTarget = nil,
    ORHHi = nil,
    Running = false,
    ToyName = "CreatureBlobman",
    Range = 30,
    AutoBlobSit = false,
    blobSeat = nil,
    BlobmanESP = false,
    AIRNJIAD = {},
    RDESDG = nil,
    BLESP = false,
    BlobNoclip = false,
    BlobSpeedValue = 16,
    BlobSpeedToggle = false,
    orbitRunning = false,
    driftRadius = 19,
    driftSpeed = 12,
    driftHeightOffset = 0,
    driftAngle = 0,
    currentDriftLoopId = 0,
}

local SelectedKill = {
    isActive = false,
    connection = nil,
    auraConnection = nil,
    playerConnection = nil,
    target = nil,
}
local SELECTED_AURA_RANGE = 40

local SnipesConfig = {
    TargetPlayer = nil,
    LoopKill = false,
    LoopVoid = false,
    LoopPoison = false,
    LoopRagdoll = false,
    LoopDeath = false,
    LoopBring = false,
    LoopPull = false,
}
local LoopTimer = 0

-- =====================================================
-- >> ユーティリティ
-- =====================================================
local function getChar()
    return localPlayer.Character
end

local function getRoot()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
end

local function getHum()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local function FindChildSafe(parent, name, timeout)
    return parent:FindFirstChild(name) or parent:WaitForChild(name, timeout or 3)
end

local function StopPartMotion(part)
    if part and part:IsA("BasePart") then
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
        part.Velocity = Vector3.zero
        part.RotVelocity = Vector3.zero
    end
end

local function TakeNetworkControl(target)
    if not target or not target:IsA("BasePart") then return end
    local ge = RS:FindFirstChild("GrabEvents")
    if ge and ge:FindFirstChild("SetNetworkOwner") then
        pcall(function() ge.SetNetworkOwner:FireServer(target, target.CFrame) end)
    end
end

local function SpawnItem(item_name, cframe_pos, velocity_vec)
    local toy_folder = service.Workspace:FindFirstChild(localPlayer.Name .. 'SpawnedInToys')
    if not toy_folder then return nil end
    local spawned = nil
    local listener
    listener = toy_folder.ChildAdded:Connect(function(obj)
        if obj.Name == item_name then spawned = obj; listener:Disconnect() end
    end)
    task.spawn(function()
        local mt = RS:FindFirstChild("MenuToys")
        if mt and mt:FindFirstChild("SpawnToyRemoteFunction") then
            pcall(function() mt.SpawnToyRemoteFunction:InvokeServer(item_name, cframe_pos, velocity_vec or Vector3.new()) end)
        end
    end)
    local start_t = tick()
    while not spawned and tick() - start_t < 4 do service.RunService.Heartbeat:Wait() end
    if listener then listener:Disconnect() end
    return spawned
end

local function SNO(part)
    pcall(function()
        local r = getRoot()
        if r then SetNetworkOwner:FireServer(part, r.CFrame) end
    end)
end

local function Velocity(part, vec)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.one * math.huge
    bv.Velocity = vec
    bv.Parent = part
    service.Debris:AddItem(bv, 1)
end

local function getInv()
    return service.Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
end

local function getPoisonParts()
    local parts = {}
    pcall(function()
        local map = service.Workspace:FindFirstChild("Map")
        if map then
            for _, d in ipairs(map:GetDescendants()) do
                if d:IsA("Part") and d.Name == "PoisonHurtPart" then
                    table.insert(parts, d)
                end
            end
        end
    end)
    return parts
end
local poisonHurtParts = getPoisonParts()

local function arson(part)
    pcall(function()
        local inv = getInv()
        if not inv then return end
        if not inv:FindFirstChild("Campfire") then
            RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("Campfire", CFrame.new(part.Position), Vector3.new(0, 0, 0))
        end
        local campfire = inv:WaitForChild("Campfire", 5)
        if campfire then
            local fpp = campfire:FindFirstChild("FirePlayerPart")
            if fpp then
                fpp.Size = Vector3.new(7, 7, 7)
                fpp.Position = part.Position
                task.wait(0.3)
                fpp.Position = Vector3.new(0, -50, 0)
            end
        end
    end)
end

local function HRP()
    return localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getBlobman()
    local inv = SpawnedInToys
    local v = inv and inv:FindFirstChild("CreatureBlobman")
    if not v then
        for _, p in ipairs(service.Workspace.PlotItems:GetChildren()) do
            local m = p:FindFirstChild("CreatureBlobman")
            if m and m:FindFirstChild("PlayerValue") and m.PlayerValue.Value == localPlayer.Name then
                v = m
                break
            end
        end
    end
    return v
end

local function spawnBlobman()
    SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", HRP().CFrame, Vector3.zero)
    task.wait(1.0)
    return getBlobman()
end

local function ensureBlob()
    local blob = getBlobman()
    if not blob then blob = spawnBlobman() end
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and not hum.Sit then
        blob.VehicleSeat:Sit(hum)
        task.wait(0.22)
    end
    return getBlobman()
end

local function blobGrab(blob, target, side)
    if not blob then return end
    local detector = blob:FindFirstChild(side .. "Detector")
    if not detector then return end
    local weld = detector:FindFirstChild(side .. "Weld")
    if not weld then return end
    local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript", true)
    if not script then return end
    local remote = script:FindFirstChild("CreatureGrab")
    if remote then pcall(function() remote:FireServer(detector, target, weld) end) end
end

local function blobDrop(blob, target, side)
    if not blob then return end
    local detector = blob:FindFirstChild(side .. "Detector")
    if not detector then return end
    local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript", true)
    if not script then return end
    local remote = script:FindFirstChild("CreatureDrop")
    if remote then pcall(function() remote:FireServer(detector, target) end) end
end

local function getPlayerList()
    local list = {}
    for _, plr in pairs(service.Players:GetPlayers()) do
        if plr ~= localPlayer then
            table.insert(list, string.format("%s (ID: %s)", plr.DisplayName, plr.Name))
        end
    end
    return list
end

local function getPlayerFromSelection(selection)
    if not selection then return nil end
    for _, plr in pairs(service.Players:GetPlayers()) do
        local format = string.format("%s (ID: %s)", plr.DisplayName, plr.Name)
        if format == selection then return plr end
    end
    return nil
end

local function checkTarget()
    local target = getPlayerFromSelection(BlobConfig.selectedTarget)
    if not target then
        OrionLib:MakeNotification({Name = "Unnamed Hub", Content = "ターゲットが見つかりません", Time = 3})
        return false
    end
    return target
end

local function spawnBlobmanAtPlayer()
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.CFrame + Vector3.new(0, 3, 0)
    return SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", pos, Vector3.new(0, 59.667, 0))
end

local function LoopSetNetworkOwner(part, cframe)
    if not part then return end
    pcall(function()
        SetNetworkOwner:FireServer(part, cframe or HRP().CFrame)
    end)
end

local function LoopVelocity(part, vel)
    if not part or not part.Parent then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    bv.Velocity = vel
    bv.Parent = part
    service.Debris:AddItem(bv, 1)
end

local function LoopMoveTo(part, targetCFrame)
    if not part or not part.Parent then return end
    for _, v in ipairs(part.Parent:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
    local b = Instance.new("BodyPosition")
    b.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    b.Position = targetCFrame.Position
    b.P, b.D = 2e4, 5e3
    b.Parent = part
    task.spawn(function()
        task.wait(1)
        pcall(function()
            b:Destroy()
            for _, v in ipairs(part.Parent:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end)
    end)
end

local function LoopUngrab(part)
    pcall(function() DestroyGrabLine:FireServer(part) end)
end

local function getPlayerFromDisplayName(displayName)
    if not displayName or displayName == "" then return nil end
    for _, player in ipairs(service.Players:GetPlayers()) do
        if player.DisplayName == displayName then return player end
    end
    return nil
end

local function updatePlayerListLoop()
    local displayNames = {}
    for _, player in ipairs(service.Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(displayNames, player.DisplayName)
        end
    end
    return displayNames
end

-- =====================================================
-- >> Loop: スナイプ関数
-- =====================================================
local function Snipefunc(root, func, ...)
    if not root or not root.Parent then return end
    local pos = HRP().CFrame
    local args = {...}
    task.spawn(function()
        local parts = {"Head", "Torso", "HumanoidRootPart"}
        for _, p in pairs(parts) do
            local part = localPlayer.Character:FindFirstChild(p)
            if part then part.CanCollide = false end
        end
        local targetPos = root.Position
        HRP().CFrame = CFrame.new(targetPos.X, targetPos.Y - 6, targetPos.Z)
        task.wait(0.1)
        service.Workspace.CurrentCamera.CFrame = CFrame.lookAt(service.Workspace.CurrentCamera.CFrame.Position, root.Position)
        for _ = 1, 4 do
            LoopSetNetworkOwner(root, HRP().CFrame)
            task.wait(0.05)
        end
        local look = service.Workspace.CurrentCamera.CFrame
        task.wait(0.1)
        func(unpack(args))
        service.Workspace.CurrentCamera.CFrame = look
        task.wait(0.1)
        for _, p in pairs(parts) do
            local part = localPlayer.Character:FindFirstChild(p)
            if part then part.CanCollide = true end
        end
        HRP().CFrame = pos
        LoopVelocity(HRP(), Vector3.zero)
    end)
end

local function SnipeKill(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        LoopMoveTo(root, CFrame.new(4096, -75, 4096))
        LoopVelocity(root, Vector3.new(0, -1000, 0))
    end)
end

local function SnipeVoid(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        LoopVelocity(root, Vector3.new(0, 10000, 0))
    end)
end

local function SnipePoison(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        LoopMoveTo(root, CFrame.new(58, -70, 271))
    end)
end

local function SnipeRagdoll(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        local rpos = root.CFrame
        LoopVelocity(root, Vector3.new(0, -64, 0))
        task.wait(0.1)
        HRP().CFrame = rpos
        LoopVelocity(root, Vector3.zero)
    end)
end

local function SnipeDeath(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        task.wait(0.5)
        LoopUngrab(root)
    end)
end

local function SnipeBring(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = HRP().CFrame
    Snipefunc(root, function()
        task.wait(0.01)
        root.CFrame = pos
        task.wait(0.5)
        LoopUngrab(root)
    end)
end

local function SnipePull(target)
    local character = target.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Snipefunc(root, function()
        local bp = Instance.new("BodyPosition")
        bp.Name = "PullBodyPosition"
        bp.MaxForce = Vector3.new(1e8, 1e8, 1e8)
        bp.P, bp.D = 1e6, 1e5
        bp.Parent = root
        task.spawn(function()
            while bp and bp.Parent do
                if not root or not root.Parent then break end
                local currentMyPos = HRP().Position
                bp.Position = currentMyPos
                root.CFrame = CFrame.new(currentMyPos)
                LoopSetNetworkOwner(root)
                task.wait(0.05)
            end
        end)
        task.wait(0.1)
    end)
    task.delay(2, function()
        if root and root.Parent then
            local bp = root:FindFirstChild("PullBodyPosition")
            if bp then bp:Destroy() end
            LoopUngrab(root)
        end
    end)
end

-- =====================================================
-- >> グラブ: Noclipループ
-- =====================================================
local noclipGrabCo = nil

local function noclipGrabLoop()
    while true do
        pcall(function()
            local gp = service.Workspace:FindFirstChild("GrabParts")
            if gp then
                local grabPart = gp:FindFirstChild("GrabPart")
                if grabPart and grabPart:FindFirstChild("WeldConstraint") then
                    local char = grabPart.WeldConstraint.Part1 and grabPart.WeldConstraint.Part1.Parent
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        while service.Workspace:FindFirstChild("GrabParts") do
                            for _, p in pairs(char:GetChildren()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                            task.wait()
                        end
                        for _, p in pairs(char:GetChildren()) do
                            if p:IsA("BasePart") then p.CanCollide = true end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

-- =====================================================
-- >> グラブ: Strength用投げ判定
-- =====================================================
local strengthLastThrow = false

service.UserInputService.TouchEnded:Connect(function(touch, _)
    local screenSize = service.Workspace.CurrentCamera.ViewportSize
    if touch.Position.X > screenSize.X * 0.5 then
        strengthLastThrow = true
        task.delay(0.3, function() strengthLastThrow = false end)
    end
end)

local function isThrowInput()
    if service.UserInputService.TouchEnabled then
        return strengthLastThrow
    else
        return service.UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2
    end
end

-- =====================================================
-- >> グラブ: workspace.ChildAdded ハンドラ
-- =====================================================
service.Workspace.ChildAdded:Connect(function(model)
    if model.Name ~= "GrabParts" then return end
    task.spawn(function()
        local grabPart = model:FindFirstChild("GrabPart", 1)
        if not grabPart then return end
        task.wait()

        local wc = grabPart:FindFirstChild("WeldConstraint")
        local part1 = wc and wc.Part1

        if not part1 then
            task.wait()
            wc = grabPart:FindFirstChild("WeldConstraint")
            part1 = wc and wc.Part1
        end

        if part1 and localPlayer.Character and part1:IsDescendantOf(localPlayer.Character) then return end
        if grabPart and localPlayer.Character and grabPart:IsDescendantOf(localPlayer.Character) then return end
        if model and localPlayer.Character and model:IsDescendantOf(localPlayer.Character) then return end

        if Vars.grabFlags.KillGrab and part1 then
            pcall(function() part1.Parent:BreakJoints() end)
        end

        if Vars.grabFlags.SkyGrab and part1 then
            local bv = Instance.new("BodyVelocity", part1)
            bv.Velocity = Vector3.new(0, 100, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            service.Debris:AddItem(bv, 1.5)
        end

        if Vars.grabFlags.SpinGrab and part1 then
            pcall(function()
                local bav = Instance.new("BodyAngularVelocity", part1)
                bav.AngularVelocity = Vector3.new(0, 1000, 0)
                bav.MaxTorque = Vector3.one * math.huge
            end)
        end

        if Vars.grabFlags.FreezeGrab and part1 then
            for _, c in ipairs(model:GetDescendants()) do
                if c:IsA("BasePart") then c.Anchored = true end
            end
        end

        if Vars.grabFlags.FlingGrab and part1 then
            pcall(function()
                SNO(part1)
                Velocity(part1, Vector3.new(math.random(-100, 100), 200, math.random(-100, 100)))
            end)
        end

        if Vars.grabFlags.VoidGrab and part1 then
            pcall(function()
                SNO(part1)
                Velocity(part1, Vector3.new(0, -500, 0))
            end)
        end

        if Vars.grabFlags.PoisonGrab and part1 then
            pcall(function()
                local head = part1.Parent:FindFirstChild("Head")
                if head and #poisonHurtParts > 0 then
                    while service.Workspace:FindFirstChild("GrabParts") do
                        for _, p in pairs(poisonHurtParts) do
                            p.Size = Vector3.new(2, 2, 2)
                            p.Transparency = 1
                            p.Position = head.Position
                        end
                        task.wait()
                        for _, p in pairs(poisonHurtParts) do
                            p.Position = Vector3.new(0, -200, 0)
                        end
                    end
                end
            end)
        end

        if Vars.grabFlags.RagdollGrab and part1 and RagdollRemote then
            pcall(function() RagdollRemote:FireServer(part1, 999999) end)
        end

        if Vars.grabFlags.FireGrab and part1 then
            pcall(function()
                local head = part1.Parent:FindFirstChild("Head")
                if head then arson(head) end
            end)
        end

        if Vars.grabFlags.NoclipGrab then
            if noclipGrabCo and coroutine.status(noclipGrabCo) ~= "dead" then
                coroutine.close(noclipGrabCo)
            end
            noclipGrabCo = coroutine.create(noclipGrabLoop)
            coroutine.resume(noclipGrabCo)
        end

        if Vars.grabFlags.StrengthEnabled and part1 then
            local velocityObj = Instance.new("BodyVelocity", part1)
            model:GetPropertyChangedSignal("Parent"):Connect(function()
                if not model.Parent then
                    if isThrowInput() then
                        velocityObj.MaxForce = Vector3.one * math.huge
                        velocityObj.Velocity = service.Workspace.CurrentCamera.CFrame.LookVector * _G.strength
                        service.Debris:AddItem(velocityObj, 1)
                    else
                        velocityObj:Destroy()
                    end
                end
            end)
        end
    end)
end)

-- =====================================================
-- >> プレイヤー用ループ
-- =====================================================
service.RunService.Heartbeat:Connect(function()
    if superSpeed and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            root.CFrame = root.CFrame + hum.MoveDirection * Multiplier
        end
    end
end)

service.UserInputService.JumpRequest:Connect(function()
    if infiniteJump and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState("Jumping")
        end
    end
end)

-- =====================================================
-- >> Loop: ループ処理
-- =====================================================
service.RunService.Heartbeat:Connect(function(dt)
    LoopTimer = LoopTimer + dt
    if LoopTimer >= 1.5 then
        if SnipesConfig.TargetPlayer and SnipesConfig.TargetPlayer.Character then
            if SnipesConfig.LoopKill    then task.spawn(SnipeKill,    SnipesConfig.TargetPlayer) end
            if SnipesConfig.LoopVoid    then task.spawn(SnipeVoid,    SnipesConfig.TargetPlayer) end
            if SnipesConfig.LoopPoison  then task.spawn(SnipePoison,  SnipesConfig.TargetPlayer) end
            if SnipesConfig.LoopRagdoll then task.spawn(SnipeRagdoll, SnipesConfig.TargetPlayer) end
            if SnipesConfig.LoopDeath   then task.spawn(SnipeDeath,   SnipesConfig.TargetPlayer) end
            if SnipesConfig.LoopBring   then task.spawn(SnipeBring,   SnipesConfig.TargetPlayer) end
            if SnipesConfig.LoopPull    then task.spawn(SnipePull,    SnipesConfig.TargetPlayer) end
        end
        LoopTimer = 0
    end
end)

-- =====================================================
-- >> ブロブマン: Auto-Sit
-- =====================================================
service.RunService.Heartbeat:Connect(function()
    if BlobConfig.AutoBlobSit then
        local char = localPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        local currentBlobman = getBlobman()
        if not currentBlobman then
            spawnBlobmanAtPlayer()
            currentBlobman = getBlobman()
        end
        if currentBlobman then
            local seat = currentBlobman:FindFirstChild("VehicleSeat")
            if seat and humanoid.SeatPart ~= seat then
                seat:Sit(humanoid)
                BlobConfig.blobSeat = seat
            end
        end
    end
end)

-- =====================================================
-- >> 防御機能
-- =====================================================
local function EnableAntiSticky()
    Config.AntiSticky = true
    pcall(function() localPlayer.PlayerScripts.StickyPartsTouchDetection.Enabled = false end)
end
local function DisableAntiSticky()
    Config.AntiSticky = false
    pcall(function() localPlayer.PlayerScripts.StickyPartsTouchDetection.Enabled = true end)
end

task.spawn(function()
    local cev = RS:WaitForChild("CharacterEvents", 10)
    if cev then Config.struggle_event_ref = cev:WaitForChild("Struggle", 5) end
    Config.is_held_flag = localPlayer:WaitForChild("IsHeld", 10)
end)

local function GrabDefenseLoop()
    if not Config.AntiGrabToggle then return end
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if Config.is_held_flag and Config.is_held_flag.Value == true then
        pcall(function() if Config.struggle_event_ref then Config.struggle_event_ref:FireServer(localPlayer) end end)
        root.Velocity = Vector3.zero; root.Anchored = true
    else root.Anchored = false end
end
service.RunService.Heartbeat:Connect(GrabDefenseLoop)

local function EnableAntiGrab() Config.AntiGrabToggle = true end
local function DisableAntiGrab()
    Config.AntiGrabToggle = false
    local char = localPlayer.Character
    if char then local root = char:FindFirstChild("HumanoidRootPart"); if root then root.Anchored = false end end
end

-- アンチグラブNRD
local function PurgeNRDConnections()
    for _, c in ipairs(Config.nrd_connections) do pcall(function() c:Disconnect() end) end
    Config.nrd_connections = {}
end

local function SetupGrabNRD(char)
    if not Config.AntiGrabNRD then return end
    local root = FindChildSafe(char, "HumanoidRootPart", 5)
    local hum = FindChildSafe(char, "Humanoid", 5)
    local head = FindChildSafe(char, "Head", 5)
    if not root or not hum or not head then return end
    local po_conn = head.ChildAdded:Connect(function(obj)
        if not Config.AntiGrabNRD then return end
        if obj and obj.Name == "PartOwner" then
            if not Config.grab_defense_nrd_processing then
                Config.grab_defense_nrd_processing = true
                pcall(function() hum.Sit = false end)
                pcall(function() if Config.struggle_event_ref then Config.struggle_event_ref:FireServer(localPlayer) end end)
                task.spawn(function()
                    while Config.AntiGrabNRD and (head and head:FindFirstChild("PartOwner")) do
                        pcall(function() if Config.struggle_event_ref then Config.struggle_event_ref:FireServer(localPlayer) end end)
                        pcall(function() if RagdollRemote then RagdollRemote:FireServer(root, 0) end end)
                        task.wait()
                    end
                end)
                pcall(function() root.Anchored = true end)
                if not Config.nrd_walk_lock then
                    Config.nrd_walk_lock = true
                    while Config.AntiGrabNRD and task.wait() do
                        local hf = localPlayer:FindFirstChild("IsHeld")
                        if not hf or not hf.Value then break end
                        pcall(function() if hum and hum.MoveDirection then root.CFrame = root.CFrame + hum.MoveDirection * 0.43 end end)
                    end
                    Config.nrd_walk_lock = false
                end
                pcall(function() root.Anchored = false end)
                Config.grab_defense_nrd_processing = false
            end
        end
    end)
    table.insert(Config.nrd_connections, po_conn)
end

local function EnableAntiGrabNRD()
    Config.AntiGrabNRD = true; PurgeNRDConnections()
    if localPlayer.Character then task.defer(function() SetupGrabNRD(localPlayer.Character) end) end
end
local function DisableAntiGrabNRD()
    Config.AntiGrabNRD = false; Config.grab_defense_nrd_processing = false; Config.nrd_walk_lock = false; PurgeNRDConnections()
end

-- グッチアンチグラブ
local function ActivateGucciDefense()
    Config.gucci_cycle_id = Config.gucci_cycle_id + 1
    local my_id = Config.gucci_cycle_id
    local setup_done = false
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hum = FindChildSafe(char, "Humanoid")
    local root = FindChildSafe(char, "HumanoidRootPart")
    if not (hum and root) then return end
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    task.spawn(function()
        local t = tick()
        while tick() - t < 0.8 and my_id == Config.gucci_cycle_id do
            if root and root.Parent then root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end
            service.RunService.Heartbeat:Wait()
        end
    end)
    local blob = SpawnItem("CreatureBlobman", root.CFrame * CFrame.new(0, 0, -5), Vector3.new(0, -15.716, 0))
    if not blob then return end
    local bhead = FindChildSafe(blob, "Head")
    local hitbox = FindChildSafe(blob, "GrabbableHitbox")
    local seat = FindChildSafe(blob, "VehicleSeat")
    task.spawn(function()
        local st = tick()
        while my_id == Config.gucci_cycle_id and not setup_done and tick() - st < 1.2 do
            if hitbox and hitbox.Parent then TakeNetworkControl(hitbox) end
            if bhead and bhead.Parent then TakeNetworkControl(bhead) end
            if seat and seat.Parent and seat.Occupant ~= hum then pcall(function() seat:Sit(hum) end) end
            if RagdollRemote then pcall(function() RagdollRemote:FireServer(root, 0.09) end) end
            service.RunService.Heartbeat:Wait()
        end
    end)
    task.wait(0.45)
    if my_id ~= Config.gucci_cycle_id then if blob and blob.Parent then blob:Destroy() end; return end
    setup_done = true
    pcall(function() hum.Sit = false end)
    if seat and seat.Parent then
        seat.Disabled = true; seat.CanTouch = false; seat.CanQuery = false
        for _, v in pairs(seat:GetChildren()) do if v:IsA("Weld") or v.Name == "SeatWeld" then v:Destroy() end end
    end
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end); task.wait(0.05)
    if RagdollRemote then pcall(function() RagdollRemote:FireServer(root, false) end) end
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    blob.Name = "Gucci"
    for _, v in pairs(blob:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false; v.CanTouch = false; v.CanQuery = false; v.Massless = true end
    end
    task.spawn(function()
        while my_id == Config.gucci_cycle_id and bhead and bhead.Parent do
            if bhead and bhead.Parent then bhead.CFrame = CFrame.new(bhead.Position.X, 100000, bhead.Position.Z) end
            service.RunService.Heartbeat:Wait()
        end
    end)
end
local function DeactivateGucciDefense()
    Config.gucci_cycle_id = Config.gucci_cycle_id + 1
    local tf = service.Workspace:FindFirstChild(localPlayer.Name .. 'SpawnedInToys')
    if tf then for _, v in pairs(tf:GetChildren()) do if v.Name == "Gucci" or v.Name == "CreatureBlobman" then pcall(function() v:Destroy() end) end end end
end

-- アンチブロブ
local function createTruePospart()
    local char = localPlayer.Character
    if not char then return end
    if char:FindFirstChild("TruePositionPart") then return char.TruePositionPart end
    local tp = Instance.new("Part")
    tp.Name = "TruePositionPart"
    tp.Anchored = true
    tp.CanCollide = false
    tp.Transparency = 1
    tp.Size = Vector3.new(1, 1, 1)
    tp.CFrame = CFrame.new(0, -100, 0)
    tp.Parent = char
    return tp
end

local function dropFromBlobs()
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local plotItems = service.Workspace:FindFirstChild("PlotItems")
    if plotItems then
        for _, plot in pairs(plotItems:GetChildren()) do
            if plot.Name ~= "PlayersInPlots" then
                for _, itm in pairs(plot:GetChildren()) do
                    if itm.Name == "CreatureBlobman" then
                        pcall(function()
                            local script = itm:FindFirstChild("BlobmanSeatAndOwnerScript")
                            local detector = itm:FindFirstChild("RightDetector")
                            if script and detector then
                                local drop = script:FindFirstChild("CreatureDrop")
                                local weld = detector:FindFirstChild("RightWeld")
                                if drop and weld then
                                    drop:FireServer(weld, hrp)
                                    if Config.struggle_event_ref then Config.struggle_event_ref:FireServer(localPlayer) end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end

local function setMassless()
    local char = localPlayer.Character
    if not char then return end
    for _, prt in pairs(char:GetChildren()) do
        if prt:IsA("BasePart") and prt.Massless then
            prt.Massless = false
            dropFromBlobs()
        end
    end
end

local function moveRootAttachment()
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local truePart = char:FindFirstChild("TruePositionPart")
    if hrp and truePart then
        local rootAttachment = hrp:FindFirstChild("RootAttachment")
        if rootAttachment then
            task.wait(0.2)
            rootAttachment.Parent = truePart
        end
    end
end

local function restoreRootAttachment()
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local truePart = char:FindFirstChild("TruePositionPart")
    if hrp and truePart then
        local rootAttachment = truePart:FindFirstChild("RootAttachment")
        if rootAttachment then
            rootAttachment.Parent = hrp
        end
        truePart:Destroy()
    end
end

local function antiblobLoop()
    while Config.AntiBlob do
        pcall(function()
            if localPlayer.Character then
                createTruePospart()
                setMassless()
                local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("RootAttachment") then
                    local truePart = localPlayer.Character:FindFirstChild("TruePositionPart")
                    if truePart and not truePart:FindFirstChild("RootAttachment") then
                        moveRootAttachment()
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end

local function EnableAntiBlob()
    Config.AntiBlob = true
    if Config.antiblobConnection then Config.antiblobConnection:Disconnect() end
    task.spawn(antiblobLoop)
    Config.antiblobConnection = localPlayer.CharacterAdded:Connect(function(char)
        if Config.AntiBlob then
            task.wait(1); createTruePospart(); task.wait(0.5); moveRootAttachment()
        end
    end)
end
local function DisableAntiBlob()
    Config.AntiBlob = false
    if Config.antiblobConnection then Config.antiblobConnection:Disconnect(); Config.antiblobConnection = nil end
    restoreRootAttachment()
end

-- アンチブロブマン
local function startAntiBlobman()
    if Config.AntiBlobmanCoroutine then task.cancel(Config.AntiBlobmanCoroutine); Config.AntiBlobmanCoroutine = nil end
    Config.AntiBlobmanCoroutine = task.spawn(function()
        while Config.AntiBlobman do
            pcall(function()
                for _, p in pairs(service.Players:GetPlayers()) do
                    local st = service.Workspace:FindFirstChild(p.Name .. "SpawnedInToys")
                    if st then
                        for _, toy in ipairs(st:GetChildren()) do
                            if toy.Name == "CreatureBlobman" then
                                if toy:FindFirstChild("LeftDetector") then toy.LeftDetector:Destroy() end
                                if toy:FindFirstChild("RightDetector") then toy.RightDetector:Destroy() end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end
local function stopAntiBlobman()
    Config.AntiBlobman = false
    if Config.AntiBlobmanCoroutine then task.cancel(Config.AntiBlobmanCoroutine); Config.AntiBlobmanCoroutine = nil end
end

-- アンチキック
local function PurgeKunai()
    local inv = service.Workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
    if inv and DestroyToy then
        for _, v in pairs(inv:GetChildren()) do
            if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                pcall(function() DestroyToy:FireServer(v) end)
            end
        end
    end
end

local function EnableAntiKickKunai()
    Config.AntiKickKunai = true
    task.spawn(function()
        local sticky_evt = PlayerEvents:WaitForChild("StickyPartEvent")
        local spawn_rmt = MenuToys:WaitForChild("SpawnToyRemoteFunction")
        local can_spawn = localPlayer:WaitForChild("CanSpawnToy")
        local function GetMyRoot()
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return localPlayer.Character.HumanoidRootPart
            else
                local c = localPlayer.CharacterAdded:Wait(); return c:WaitForChild("HumanoidRootPart")
            end
        end
        local function AttachKunai(kunai)
            if not kunai or not kunai:FindFirstChild("StickyPart") then return end
            local my_root = GetMyRoot()
            if not my_root then return end
            local fire_part = my_root:FindFirstChild("FirePlayerPart") or my_root:WaitForChild("FirePlayerPart", 5)
            if not fire_part then return end
            for _, obj in pairs(kunai:GetChildren()) do
                if obj:IsA("BasePart") then
                    obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false
                    obj.AssemblyLinearVelocity = Vector3.zero; obj.AssemblyAngularVelocity = Vector3.zero
                end
            end
            sticky_evt:FireServer(kunai.StickyPart, fire_part, CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(90),math.rad(90)))
        end
        while Config.AntiKickKunai do
            task.wait(0.05)
            if not localPlayer.Character or not localPlayer.Character:FindFirstChild("Humanoid") or localPlayer.Character.Humanoid.Health <= 0 then continue end
            local inv = service.Workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
            local kunai = inv and (inv:FindFirstChild("NinjaShuriken") or inv:FindFirstChild("AntiKick"))
            if not kunai then
                local my_root = GetMyRoot()
                if my_root and can_spawn.Value then
                    pcall(function() spawn_rmt:InvokeServer("NinjaShuriken", my_root.CFrame * CFrame.new(0,2,2), Vector3.zero) end)
                    task.wait(0.5)
                    inv = service.Workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
                    kunai = inv and (inv:FindFirstChild("NinjaShuriken") or inv:FindFirstChild("AntiKick"))
                end
                if not kunai then continue end
            end
            if kunai then kunai.Name = "AntiKick"; AttachKunai(kunai) end
        end
        PurgeKunai()
    end)
end
local function DisableAntiKickKunai()
    Config.AntiKickKunai = false; PurgeKunai()
end

local joint_break_cache = {}
local joint_break_shield_conn = nil
local function EnableAntiKickJointBreak()
    Config.AntiKickJointBreak = true
    local safe_pos = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
    service.Workspace.FallenPartsDestroyHeight = 0/0
    joint_break_cache = {}
    local root_part = nil
    local function BreakJoints()
        local char = localPlayer.Character
        if not char then return end
        root_part = char:WaitForChild("HumanoidRootPart")
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then joint_break_cache[v] = v.Part0; v.Part0 = nil end
        end
        root_part.CFrame = safe_pos
        joint_break_shield_conn = service.RunService.RenderStepped:Connect(function()
            if root_part and root_part.Parent then
                root_part.AssemblyLinearVelocity = Vector3.zero; root_part.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
    local function RestoreJoints()
        if joint_break_shield_conn then joint_break_shield_conn:Disconnect(); joint_break_shield_conn = nil end
        for m, p0 in pairs(joint_break_cache) do if m and m.Parent then m.Part0 = p0 end end
        joint_break_cache = {}
    end
    local function ToggleOnce()
        if not Config.AntiKickJointBreak then return end
        if joint_break_shield_conn then RestoreJoints() else BreakJoints() end
    end
    ToggleOnce(); task.wait(0.12); ToggleOnce()
    localPlayer.CharacterAdded:Once(function()
        task.wait(0.25)
        if Config.AntiKickJointBreak then ToggleOnce(); task.wait(0.12); ToggleOnce() end
    end)
end
local function DisableAntiKickJointBreak()
    Config.AntiKickJointBreak = false
    if joint_break_shield_conn then joint_break_shield_conn:Disconnect(); joint_break_shield_conn = nil end
    for m, p0 in pairs(joint_break_cache) do if m and m.Parent then m.Part0 = p0 end end
    joint_break_cache = {}
    service.Workspace.FallenPartsDestroyHeight = -100
end

local function EnableAntiKickGrab()
    Config.AntiKickGrab = true
    Config.antiKickCoroutine = service.RunService.Heartbeat:Connect(function()
        local character = localPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart") then
            local partOwner = character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart"):FindFirstChild("PartOwner")
            if partOwner and partOwner.Value ~= localPlayer.Name then
                pcall(function()
                    if RagdollRemote then RagdollRemote:FireServer(character.HumanoidRootPart, 0) end
                    task.wait(0.1)
                    if Config.struggle_event_ref then Config.struggle_event_ref:FireServer(localPlayer) end
                end)
            end
        end
    end)
end
local function DisableAntiKickGrab()
    Config.AntiKickGrab = false
    if Config.antiKickCoroutine then Config.antiKickCoroutine:Disconnect(); Config.antiKickCoroutine = nil end
end

local function EnableAntiKickV2()
    Config.AntiKickV2 = true
    Config.notifiedNoCoins = false
    local ToyContents = localPlayer.PlayerGui:WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents")
    local function getCharPart(name)
        local char = localPlayer.Character
        return char and char:FindFirstChild(name)
    end
    local function inner_toyspn2(toyName)
        local hrp = getCharPart("HumanoidRootPart")
        if hrp then
            local cf = hrp.CFrame
            MenuToys.SpawnToyRemoteFunction:InvokeServer(toyName, cf - Vector3.new(cf.LookVector.X * 20, -15, cf.LookVector.Z * 20), Vector3.new(0, 0, 0))
        end
    end
    local function f()
        local character = localPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local hum = character:FindFirstChildOfClass("Humanoid")
        local leg = character:FindFirstChild("Right Leg")
        if not hrp or not hum or not leg or hum.Health <= 0 then return end
        if localPlayer.InPlot.Value then return end
        if not ToyContents:FindFirstChild("NinjaKunai") then
            local success = MenuToys.BuyToyRemoteFunction:InvokeServer("NinjaKunai")
            if not success then
                if not Config.notifiedNoCoins then
                    OrionLib:MakeNotification({Name = "Unnamed Hub", Content = "NinjaKunaiを購入できません（コイン不足）", Time = 3})
                    Config.notifiedNoCoins = true
                end
                return
            end
        end
        local kunai = service.Workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys"):FindFirstChild("NinjaKunai")
        if kunai then
            local sticky = kunai:WaitForChild("StickyPart", 1)
            if sticky then
                local weld = sticky:FindFirstChild("StickyWeld")
                local attachedPart = weld and weld.Part1
                if not weld or attachedPart ~= leg then
                    DestroyToy:FireServer(kunai)
                    task.wait(0.1)
                end
            else
                DestroyToy:FireServer(kunai)
                task.wait(0.1)
            end
        elseif localPlayer.CanSpawnToy.Value then
            task.spawn(inner_toyspn2, "NinjaKunai")
            local newKunai = service.Workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys"):WaitForChild("NinjaKunai", 3)
            if newKunai then
                local sticky = newKunai:WaitForChild("StickyPart", 2)
                if sticky then
                    local weld = sticky:WaitForChild("StickyWeld", 2)
                    GrabEvents.SetNetworkOwner:FireServer(sticky, sticky.CFrame)
                    local retry = 0
                    while Config.AntiKickV2 and weld.Part1 == nil and retry < 20 do
                        PlayerEvents.StickyPartEvent:FireServer(sticky, leg,
                            CFrame.new(0.0490287527, 0.5, 0, 0, 0.00739139877, -0.999561906,
                                -0.998452604, -0.0478846952, 0.0282763243, -0.0476547107, 0.99882561,
                                0) * CFrame.Angles(0, 0, 0))
                        task.wait(0.1)
                        retry = retry + 1
                    end
                end
            end
        end
    end
    task.spawn(function()
        while Config.AntiKickV2 do
            pcall(f)
            task.wait()
        end
    end)
end
local function DisableAntiKickV2()
    Config.AntiKickV2 = false
end

-- アンチラグ
local function EnableAntiLag()
    Config.AntiLag = true
    pcall(function() localPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = false end)
end
local function DisableAntiLag()
    Config.AntiLag = false
    pcall(function() localPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = true end)
end

local function EnableAutoAntiLag()
    Config.auto_antilag_enabled = true
    Config.AutoAntiLag = true
    Config.auto_antilag_thread = task.spawn(function()
        while Config.AutoAntiLag do
            task.wait(0.5)
            if Config.beam_count > 100 then
                pcall(function() localPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = false end)
                Config.beam_count = 0
            end
        end
    end)
end
local function DisableAutoAntiLag()
    Config.AutoAntiLag = false
    Config.auto_antilag_enabled = false
    if Config.auto_antilag_thread then task.cancel(Config.auto_antilag_thread); Config.auto_antilag_thread = nil end
    pcall(function() localPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = true end)
end
service.Workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "GrabBeam" then Config.beam_count = Config.beam_count + 1 end
end)

-- アンチインプットラグ
local function EnableAntiInputLag()
    Config.AntiInputLag = true
    if Config.AntiInputLagCoroutine then coroutine.close(Config.AntiInputLagCoroutine); Config.AntiInputLagCoroutine = nil end
    Config.AntiInputLagCoroutine = coroutine.create(function()
        local spawn_rmt = MenuToys:FindFirstChild("SpawnToyRemoteFunction")
        if not spawn_rmt then return end
        local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        while Config.AntiInputLag do
            local toysFolder = service.Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
            if not toysFolder then task.wait(); continue end
            local toy = toysFolder:FindFirstChild(Config.SelectedToy)
            if not toy then
                pcall(function() spawn_rmt:InvokeServer(Config.SelectedToy, hrp.CFrame * CFrame.new(0, 5, 0), Vector3.zero) end)
                local t0 = tick()
                repeat
                    service.RunService.Heartbeat:Wait()
                    toysFolder = service.Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
                    toy = toysFolder and toysFolder:FindFirstChild(Config.SelectedToy)
                until toy or tick() - t0 > 1 or not Config.AntiInputLag
                if not toy then continue end
            end
            if toy and toy.Parent then
                local holdPart = toy:FindFirstChild("HoldPart")
                if holdPart then
                    local hRemote = holdPart:FindFirstChild("HoldItemRemoteFunction")
                    local dRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
                    if hRemote and dRemote then
                        for i = 1, 80000000 do
                            if not Config.AntiInputLag then break end
                            pcall(function() hRemote:InvokeServer(toy, char) end)
                            pcall(function() dRemote:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.zero) end)
                        end
                    end
                end
            end
            task.wait()
        end
    end)
    coroutine.resume(Config.AntiInputLagCoroutine)
end
local function DisableAntiInputLag()
    Config.AntiInputLag = false
    if Config.AntiInputLagCoroutine then coroutine.close(Config.AntiInputLagCoroutine); Config.AntiInputLagCoroutine = nil end
end

-- キルバイパス
local function StartKillBypassLoop()
    while Config.KillBypassActive do
        local char = localPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local camera = service.Workspace.CurrentCamera
        if root and camera then
            if not Config.KillBypassPlatform then
                Config.KillBypassPlatform = Instance.new("Part", service.Workspace)
                Config.KillBypassPlatform.Name = "KillBypassBase"
                Config.KillBypassPlatform.Anchored = true
                Config.KillBypassPlatform.Size = Vector3.new(1500, 2, 1500)
                Config.KillBypassPlatform.CFrame = CFrame.new(0, 1000000, 0)
                Config.KillBypassPlatform.Transparency = 1
                Config.KillBypassPlatform.CanCollide = false
                service.Workspace.FallenPartsDestroyHeight = -9999999
            end
            local originalPos = root.CFrame
            Config.KillBypassSavedCamCFrame = camera.CFrame
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = Config.KillBypassSavedCamCFrame
            root.CFrame = Config.KillBypassPlatform.CFrame + Vector3.new(0, 5, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            task.wait(Config.KillBypassLoopInterval)
            if not Config.KillBypassActive then
                char = localPlayer.Character; root = char and char:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = originalPos end
                camera.CameraType = Enum.CameraType.Custom; break
            end
            char = localPlayer.Character; root = char and char:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = originalPos; root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
            camera.CameraType = Enum.CameraType.Custom
            task.wait(Config.KillBypassLoopInterval)
        else task.wait(0.05) end
    end
    local camera = service.Workspace.CurrentCamera
    if camera then camera.CameraType = Enum.CameraType.Custom end
end
local function StartKillBypass()
    if Config.KillBypassActive then return end
    Config.KillBypassActive = true
    if Config.KillBypassLoopCoroutine then coroutine.close(Config.KillBypassLoopCoroutine); Config.KillBypassLoopCoroutine = nil end
    OrionLib:MakeNotification({ Name = "キルバイパス", Content = "ON", Time = 2 })
    Config.KillBypassLoopCoroutine = coroutine.create(StartKillBypassLoop)
    coroutine.resume(Config.KillBypassLoopCoroutine)
end
local function StopKillBypass()
    if not Config.KillBypassActive then return end
    Config.KillBypassActive = false
    OrionLib:MakeNotification({ Name = "キルバイパス", Content = "OFF", Time = 2 })
    if Config.KillBypassLoopCoroutine then coroutine.close(Config.KillBypassLoopCoroutine); Config.KillBypassLoopCoroutine = nil end
    if Config.KillBypassPlatform then pcall(function() Config.KillBypassPlatform:Destroy() end); Config.KillBypassPlatform = nil end
    local camera = service.Workspace.CurrentCamera    if camera then camera.CameraType = Enum.CameraType.Custom end
end

-- 基本防御
local function EnableAntiExplosion()
    Config.AntiExplosion = true
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
    if not (root and hum and hum:FindFirstChild("Ragdolled")) then return end
    Config.FLAG["exp_def"] = service.Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == "Part" and (obj.Position - root.Position).Magnitude < 40 and hum.Ragdolled.Value == true then
            root.Anchored = true; task.wait(0.01); root.Anchored = false
            StopPartMotion(root); hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end
local function DisableAntiExplosion()
    Config.AntiExplosion = false
    if Config.FLAG["exp_def"] then Config.FLAG["exp_def"]:Disconnect(); Config.FLAG["exp_def"] = nil end
end

local extPart = nil
local originalPos = nil
local function SetupBurnExtinguishPart()
    local mapHole = service.Workspace:FindFirstChild("Map"):FindFirstChild("Hole"):FindFirstChild("PoisonBigHole")
    extPart = mapHole:FindFirstChild("ExtinguishPart")
    if not extPart then
        extPart = Instance.new("Part")
        extPart.Name = "ExtinguishPart"
        extPart.Size = Vector3.new(4, 1, 4)
        extPart.Anchored = true
        extPart.CanCollide = false
        extPart.Transparency = 1
        extPart.Position = mapHole.Position
        extPart.Parent = mapHole
    end
    originalPos = extPart.Position
end
SetupBurnExtinguishPart()

local function EnableAntiBurn()
    Config.AntiBurn = true
    if Config.burn_conn then Config.burn_conn:Disconnect() end
    Config.burn_conn = service.RunService.Heartbeat:Connect(function()
        if not Config.AntiBurn then return end
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local fireLight = hrp:FindFirstChild("FireLight")
            local fireEmitter = hrp:FindFirstChild("FireParticleEmitter")
            if fireLight or fireEmitter then extPart.CFrame = hrp.CFrame else extPart.CFrame = CFrame.new(originalPos) end
        end
    end)
end
local function DisableAntiBurn()
    Config.AntiBurn = false
    if Config.burn_conn then Config.burn_conn:Disconnect(); Config.burn_conn = nil end
    extPart.CFrame = CFrame.new(originalPos)
end

local function EnableAntiVoid()
    Config.AntiVoid = true
    if not Config.originalVoidHeight then Config.originalVoidHeight = service.Workspace.FallenPartsDestroyHeight end
    service.Workspace.FallenPartsDestroyHeight = -1e95
end
local function DisableAntiVoid()
    Config.AntiVoid = false
    service.Workspace.FallenPartsDestroyHeight = Config.originalVoidHeight or -500
end

local function EnableAntiBananaSit()
    Config.AntiBananaSit = true
    Config.banana_sit_defense_thread = task.spawn(function()
        while Config.AntiBananaSit do
            local char = localPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    hum.Sit = true; hum:ChangeState(Enum.HumanoidStateType.Running)
                    local cam = service.Workspace.CurrentCamera
                    if cam then
                        local lv = cam.CFrame.LookVector
                        root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lv.X, 0, lv.Z))
                    end
                end
            end
            task.wait()
        end
    end)
end
local function DisableAntiBananaSit()
    Config.AntiBananaSit = false
    if Config.banana_sit_defense_thread then task.cancel(Config.banana_sit_defense_thread); Config.banana_sit_defense_thread = nil end
end

local function EnableAntiBlobKill()
    Config.AntiBlobKill = true
    Config.blob_kill_defense_thread = task.spawn(function()
        while Config.AntiBlobKill do
            local char = localPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    hum.Sit = true; hum:ChangeState(Enum.HumanoidStateType.Running)
                    local cam = service.Workspace.CurrentCamera
                    if cam then
                        local lv = cam.CFrame.LookVector
                        root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lv.X, 0, lv.Z))
                    end
                end
            end
            task.wait()
        end
    end)
end
local function DisableAntiBlobKill()
    Config.AntiBlobKill = false
    if Config.blob_kill_defense_thread then task.cancel(Config.blob_kill_defense_thread); Config.blob_kill_defense_thread = nil end
end

local function CleanRagBlobConnection(key)
    if Config.ragdoll_blob_defense_connections[key] then
        Config.ragdoll_blob_defense_connections[key]:Disconnect()
        Config.ragdoll_blob_defense_connections[key] = nil
    end
end
local function SetupRagBlobCharacter(char)
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root and RagdollRemote then
        CleanRagBlobConnection("SeatWatch")
        Config.ragdoll_blob_defense_connections["SeatWatch"] = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
            if hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name == "CreatureBlobman" then
                if not Config.ragdoll_seat_flag then
                    Config.ragdoll_seat_flag = true
                    local seat = hum.SeatPart
                    while not hum.Sit do task.wait() end
                    RagdollRemote:FireServer(root, 3)
                    while not (hum:FindFirstChild("Ragdolled") and hum.Ragdolled.Value) and not hum.Sit do task.wait() end
                    task.wait(0.4); hum.Sit = false
                    if seat and seat:IsA("Part") then seat:Sit(hum) end
                    task.delay(0.25, function()
                        while hum and hum.SeatPart do
                            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                RagdollRemote:FireServer(localPlayer.Character.HumanoidRootPart, 1)
                            end
                            task.wait(0.05)
                        end
                        Config.ragdoll_seat_flag = false
                    end)
                end
            end
        end)
    end
end
local function EnableAntiBlobRagdoll()
    Config.AntiBlobRagdoll = true
    SetupRagBlobCharacter(localPlayer.Character or localPlayer.CharacterAdded:Wait())
    CleanRagBlobConnection("CharWatch")
    Config.ragdoll_blob_defense_connections["CharWatch"] = localPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5); SetupRagBlobCharacter(newChar)
    end)
end
local function DisableAntiBlobRagdoll()
    Config.AntiBlobRagdoll = false
    for _, c in pairs(Config.ragdoll_blob_defense_connections) do if c then c:Disconnect() end end
    Config.ragdoll_blob_defense_connections = {}
end

local function EnableAntiPaint()
    Config.AntiPaint = true
    local function setTouchQuery(s)
        local char = localPlayer.Character
        if char then
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanTouch = s; v.CanQuery = s end
            end
        end
    end
    for _, obj in ipairs(service.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
            local clone = obj:Clone(); clone.Archivable = true
            Config.paintPartsBackup[obj:GetDebugId()] = { clone = clone, parent = obj.Parent }
            obj:Destroy()
        end
    end
    local conn = service.Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
            task.defer(function()
                if obj and obj.Parent then
                    local clone = obj:Clone(); clone.Archivable = true
                    Config.paintPartsBackup[obj:GetDebugId()] = { clone = clone, parent = obj.Parent }
                    obj:Destroy()
                end
            end)
        end
    end)
    table.insert(Config.paintConnections, conn)
    setTouchQuery(false)
end
local function DisableAntiPaint()
    Config.AntiPaint = false
    for _, conn in ipairs(Config.paintConnections) do if conn.Connected then conn:Disconnect() end end
    Config.paintConnections = {}
    for id, data in pairs(Config.paintPartsBackup) do
        if data.clone and data.parent then data.clone.Parent = data.parent end
    end
    Config.paintPartsBackup = {}
    local function setTouchQuery(s)
        local char = localPlayer.Character
        if char then
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanTouch = s; v.CanQuery = s end
            end
        end
    end
    setTouchQuery(true)
end

local function EnableAntiAFK()
    Config.AntiAFK = true
    localPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            service.UserInputService:CaptureController()
            service.UserInputService:ClickButton2(Vector2.new())
        end
    end)
    task.spawn(function()
        while Config.AntiAFK do
            service.UserInputService:CaptureController()
            service.UserInputService:Button1Down(Vector2.new(0,0))
            task.wait(0.1)
            service.UserInputService:Button1Up(Vector2.new(0,0))
            task.wait(600)
        end
    end)
end
local function DisableAntiAFK()
    Config.AntiAFK = false
end

local function EnableAntiRagdoll()
    Config.AntiRagdoll = true
    local function clearConnections()
        for _, conn in ipairs(Config.antiRagdollConnections) do if conn then conn:Disconnect() end end
        Config.antiRagdollConnections = {}
    end
    local function protectHumanoid(humanoid)
        humanoid.BreakJointsOnDeath = false; humanoid.AutoRotate = true; humanoid.PlatformStand = false
        table.insert(Config.antiRagdollConnections, humanoid.HealthChanged:Connect(function(health)
            if Config.AntiRagdoll and health <= 0 then humanoid.Health = 1 end
        end))
        table.insert(Config.antiRagdollConnections, humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function()
            if Config.AntiRagdoll and not humanoid.AutoRotate then humanoid.AutoRotate = true end
        end))
        table.insert(Config.antiRagdollConnections, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if Config.AntiRagdoll and humanoid.PlatformStand then humanoid.PlatformStand = false end
        end))
        table.insert(Config.antiRagdollConnections, service.RunService.RenderStepped:Connect(function()
            if Config.AntiRagdoll and humanoid.Sit and humanoid.SeatPart == nil then humanoid.Sit = false end
        end))
    end
    local function onCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid and Config.AntiRagdoll then protectHumanoid(humanoid) end
    end
    local character = localPlayer.Character
    if character then onCharacter(character) end
    Config.antiRagdollCharAddedConn = localPlayer.CharacterAdded:Connect(onCharacter)
end
local function DisableAntiRagdoll()
    Config.AntiRagdoll = false
    for _, conn in ipairs(Config.antiRagdollConnections) do if conn then conn:Disconnect() end end
    Config.antiRagdollConnections = {}
    if Config.antiRagdollCharAddedConn then Config.antiRagdollCharAddedConn:Disconnect(); Config.antiRagdollCharAddedConn = nil end
end

local function EnableAntiWater()
    Config.AntiWater = true
    local oceanPath = service.Workspace:FindFirstChild("Map")
        and service.Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
        and service.Workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("Ocean")
        and service.Workspace.Map.AlwaysHereTweenedObjects.Ocean:FindFirstChild("Object")
        and service.Workspace.Map.AlwaysHereTweenedObjects.Ocean.Object:FindFirstChild("ObjectModel")
    if oceanPath then
        for _, part in pairs(oceanPath:GetChildren()) do
            if part:IsA("BasePart") and part.Name == "Ocean" then part.CanCollide = true end
        end
    end
end
local function DisableAntiWater()
    Config.AntiWater = false
    local oceanPath = service.Workspace:FindFirstChild("Map")
        and service.Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
        and service.Workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("Ocean")
        and service.Workspace.Map.AlwaysHereTweenedObjects.Ocean:FindFirstChild("Object")
        and service.Workspace.Map.AlwaysHereTweenedObjects.Ocean.Object:FindFirstChild("ObjectModel")
    if oceanPath then
        for _, part in pairs(oceanPath:GetChildren()) do
            if part:IsA("BasePart") and part.Name == "Ocean" then part.CanCollide = false end
        end
    end
end

-- =====================================================
-- >> ブロブマン: 選択キル
-- =====================================================
local function GetSeatedBlobman_Selected()
    local char = localPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local seat = humanoid.SeatPart
    if not seat or not seat:IsA("VehicleSeat") then return nil end
    local obj = seat
    while obj do
        if obj:IsA("Model") and obj.Name == "CreatureBlobman" then return obj end
        obj = obj.Parent
    end
    return nil
end

local function SpawnBlobman_Selected()
    local seatedBlobman = GetSeatedBlobman_Selected()
    if seatedBlobman then return seatedBlobman end
    local character = localPlayer.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
    pcall(function()
        if SpawnToyRemoteFunction then
            SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
        end
    end)
    local toyFolderName = localPlayer.Name .. "SpawnedInToys"
    local blobman = nil
    local startTime = tick()
    repeat
        local toyFolder = service.Workspace:FindFirstChild(toyFolderName)
        if toyFolder then blobman = toyFolder:FindFirstChild("CreatureBlobman") end
        if blobman then break end
        task.wait()
    until tick() - startTime > 2
    if not blobman then return nil end
    local seat = blobman:FindFirstChild("VehicleSeat")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if seat and humanoid then seat:Sit(humanoid) end
    task.wait(0.05)
    return blobman
end

local function KillPlayer_Selected(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    for _ = 1, 5 do
        local success = pcall(function()
            humanoid.BreakJointsOnDeath = false
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
        if success and humanoid.Health <= 0 then return true end
        task.wait(0.005)
    end
    return false
end

local function GrabRelease_Selected(blobman, targetRoot)
    if not blobman or not targetRoot then return end
    pcall(function()
        local script = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script then
            local leftDetector = blobman:FindFirstChild("LeftDetector")
            if leftDetector then
                local weld = leftDetector:FindFirstChild("LeftWeld")
                if weld then
                    script.CreatureGrab:FireServer(leftDetector, targetRoot, weld)
                    script.CreatureRelease:FireServer(weld, targetRoot)
                end
            end
        end
    end)
end

local function ProcessPlayer_Selected(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local localChar = localPlayer.Character
    if not localChar then return false end
    local myRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local originalCFrame = myRoot.CFrame
    local originalVel = myRoot.AssemblyLinearVelocity
    local originalAngVel = myRoot.AssemblyAngularVelocity
    pcall(function()
        myRoot.CFrame = targetRoot.CFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
        service.RunService.Heartbeat:Wait()
        humanoid.BreakJointsOnDeath = false
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        local blobman = GetSeatedBlobman_Selected()
        if blobman then GrabRelease_Selected(blobman, targetRoot) end
    end)
    if myRoot and myRoot.Parent then
        myRoot.CFrame = originalCFrame
        myRoot.AssemblyLinearVelocity = originalVel or Vector3.zero
        myRoot.AssemblyAngularVelocity = originalAngVel or Vector3.zero
        myRoot.Velocity = Vector3.zero
        myRoot.RotVelocity = Vector3.zero
    end
    return true
end

local function StartSelectedKillAura()
    if SelectedKill.auraConnection then SelectedKill.auraConnection:Disconnect(); SelectedKill.auraConnection = nil end
    if not SelectedKill.target then return end
    SelectedKill.auraConnection = service.RunService.Heartbeat:Connect(function()
        if not SelectedKill.isActive or not SelectedKill.target then return end
        local targetPlayer = SelectedKill.target
        if not targetPlayer.Parent then return end
        local localChar = localPlayer.Character
        if not localChar then return end
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        local targetChar = targetPlayer.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        if (localRoot.Position - targetRoot.Position).Magnitude <= SELECTED_AURA_RANGE then
            local blobman = GetSeatedBlobman_Selected()
            if not blobman then blobman = SpawnBlobman_Selected() end
            if blobman then
                KillPlayer_Selected(targetPlayer)
                GrabRelease_Selected(blobman, targetRoot)
            end
        end
    end)
end

local function StartSelectedKillLoop()
    if SelectedKill.connection then SelectedKill.connection:Disconnect(); SelectedKill.connection = nil end
    if SelectedKill.playerConnection then SelectedKill.playerConnection:Disconnect(); SelectedKill.playerConnection = nil end
    if not SelectedKill.target then return end
    task.spawn(function()
        while SelectedKill.isActive do
            if SelectedKill.target and SelectedKill.target.Parent then
                pcall(ProcessPlayer_Selected, SelectedKill.target)
            end
            service.RunService.Heartbeat:Wait()
        end
    end)
    SelectedKill.playerConnection = SelectedKill.target.CharacterAdded:Connect(function()
        if SelectedKill.isActive then
            task.spawn(function() pcall(ProcessPlayer_Selected, SelectedKill.target) end)
        end
    end)
    StartSelectedKillAura()
end

local function StopSelectedKill()
    SelectedKill.isActive = false
    if SelectedKill.connection then SelectedKill.connection:Disconnect(); SelectedKill.connection = nil end
    if SelectedKill.playerConnection then SelectedKill.playerConnection:Disconnect(); SelectedKill.playerConnection = nil end
    if SelectedKill.auraConnection then SelectedKill.auraConnection:Disconnect(); SelectedKill.auraConnection = nil end
end

-- =====================================================
-- >> UI構築
-- =====================================================
local Window = OrionLib:MakeWindow({
    Name = "Unnamed Hub",
    SaveConfig = true,
    ConfigFolder = "KobaHub_Complete",
    IntroEnabled = true,
    IntroText = "Unnamed Hub",
    IntroIcon = "rbxassetid://118739401073899",
    FreeMouse = true,
    KeyToOpenWindow = "M"
})

local ThemeColor = Color3.fromRGB(255, 255, 255)

-- プレイヤータブ
local PlayerTab = Window:MakeTab({ Name = "プレイヤー", Icon = "rbxassetid://7743871002" })

PlayerTab:AddSection({Name = "移動速度"})
PlayerTab:AddToggle({ Name = "移動速度", Default = false, Color = ThemeColor, Callback = function(v) superSpeed = v end })
PlayerTab:AddSlider({ Name = "速度倍率", Min = 0.1, Max = 5, Default = 0.15, Increment = 0.01, Color = ThemeColor, Callback = function(v) Multiplier = v end })

PlayerTab:AddSection({Name = "無限ジャンプ"})
PlayerTab:AddToggle({ Name = "無限ジャンプ", Default = false, Color = ThemeColor, Callback = function(v) infiniteJump = v end })
PlayerTab:AddSlider({ Name = "ジャンプ力", Min = 24, Max = 1000, Default = 24, Increment = 10, Color = ThemeColor, Callback = function(v)
    local hum = getHum()
    if hum then hum.JumpPower = v end
end })

PlayerTab:AddSection({Name = "壁抜け"})
PlayerTab:AddToggle({ Name = "壁抜け", Default = false, Color = ThemeColor, Callback = function(v)
    noclip = v
    if v then
        noclipConn = service.RunService.Stepped:Connect(function()
            if localPlayer.Character then
                for _, part in pairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    elseif noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end })

PlayerTab:AddSection({Name = "視点"})
PlayerTab:AddToggle({ Name = "Third Person", Default = false, Color = ThemeColor, Callback = function(state)
    thirdPersonEnabled = state
    if state then
        localPlayer.CameraMode = Enum.CameraMode.Classic
        localPlayer.CameraMaxZoomDistance = 100
        localPlayer.CameraMinZoomDistance = 0.5
    else
        localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        localPlayer.CameraMaxZoomDistance = 0.5
        localPlayer.CameraMinZoomDistance = 0.5
    end
end })

-- グラブタブ
local GrabTab = Window:MakeTab({ Name = "グラブ", Icon = "rbxassetid://130703864968637" })

GrabTab:AddToggle({ Name = "キルグラブ", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.KillGrab = v end })
GrabTab:AddToggle({ Name = "スカイグラブ（打ち上げ）", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.SkyGrab = v end })
GrabTab:AddToggle({ Name = "スピングラブ（回転）", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.SpinGrab = v end })
GrabTab:AddToggle({ Name = "フリーズグラブ（凍結）", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.FreezeGrab = v end })
GrabTab:AddToggle({ Name = "フリンググラブ（吹き飛ばし）", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.FlingGrab = v end })
GrabTab:AddToggle({ Name = "ボイドグラブ（奈落送り）", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.VoidGrab = v end })
GrabTab:AddToggle({ Name = "ポイズングラブ（毒）", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.PoisonGrab = v end })
GrabTab:AddToggle({ Name = "ラグドールグラブ", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.RagdollGrab = v end })
GrabTab:AddToggle({ Name = "ファイアグラブ（炎）", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.FireGrab = v end })
GrabTab:AddToggle({ Name = "壁抜けグラブ", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.NoclipGrab = v end })
GrabTab:AddSlider({ Name = "強さ（投擲パワー）", Min = 500, Max = 20000, Default = 500, Increment = 100, Color = ThemeColor, ValueName = "パワー", Callback = function(v) _G.strength = v end })
GrabTab:AddToggle({ Name = "投擲強度を有効化", Default = false, Color = ThemeColor, Callback = function(v) Vars.grabFlags.StrengthEnabled = v end })

-- 防御タブ
local DefenseTab = Window:MakeTab({ Name = "防御", Icon = "rbxassetid://10734951847" })

DefenseTab:AddSection({ Name = "アンチグラブ" })
DefenseTab:AddToggle({ Name = "アンチスティッキー", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiSticky() else DisableAntiSticky() end end })
DefenseTab:AddToggle({ Name = "アンチグラブ", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiGrab() else DisableAntiGrab() end end })
DefenseTab:AddToggle({ Name = "アンチグラブNRD", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiGrabNRD() else DisableAntiGrabNRD() end end })
DefenseTab:AddToggle({ Name = "グッチアンチグラブ", Default = false, Color = ThemeColor, Callback = function(v) if v then ActivateGucciDefense() else DeactivateGucciDefense() end end })
DefenseTab:AddToggle({ Name = "アンチブロブ", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiBlob() else DisableAntiBlob() end end })
DefenseTab:AddToggle({ Name = "アンチブロブマン（Detector削除）", Default = false, Color = ThemeColor, Callback = function(v) if v then startAntiBlobman() else stopAntiBlobman() end end })

DefenseTab:AddSection({ Name = "アンチキック" })
DefenseTab:AddToggle({ Name = "アンチキック（手裏剣）", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiKickKunai() else DisableAntiKickKunai() end end })
DefenseTab:AddToggle({ Name = "アンチキック（ジョイント破壊）", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiKickJointBreak() else DisableAntiKickJointBreak() end end })
DefenseTab:AddToggle({ Name = "アンチキックグラブ", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiKickGrab() else DisableAntiKickGrab() end end })
DefenseTab:AddToggle({ Name = "アンチキックV2（手裏剣連続）", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiKickV2() else DisableAntiKickV2() end end })

DefenseTab:AddSection({ Name = "アンチラグ" })
DefenseTab:AddToggle({ Name = "アンチラグ", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiLag() else DisableAntiLag() end end })
DefenseTab:AddToggle({ Name = "オートアンチラグ", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAutoAntiLag() else DisableAutoAntiLag() end end })

DefenseTab:AddSection({ Name = "アンチインプットラグ" })
DefenseTab:AddDropdown({ Name = "アイテム選択", Default = ToyDropdownValues[1], Options = ToyDropdownValues, Color = ThemeColor, Callback = function(Value) Config.SelectedToy = ToyList[Value] or "FoodHamburger" end })
DefenseTab:AddToggle({ Name = "アンチインプットラグ", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiInputLag() else DisableAntiInputLag() end end })

DefenseTab:AddSection({ Name = "キルバイパス" })
DefenseTab:AddToggle({ Name = "キルバイパス", Default = false, Color = ThemeColor, Callback = function(v) if v then StartKillBypass() else StopKillBypass() end end })
DefenseTab:AddLabel("Xキーでトグル切替")

DefenseTab:AddSection({ Name = "基本防御" })
DefenseTab:AddToggle({ Name = "アンチエクスプロージョン", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiExplosion() else DisableAntiExplosion() end end })
DefenseTab:AddToggle({ Name = "アンチバーン", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiBurn() else DisableAntiBurn() end end })
DefenseTab:AddToggle({ Name = "アンチボイド", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiVoid() else DisableAntiVoid() end end })
DefenseTab:AddToggle({ Name = "アンチバナナシット", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiBananaSit() else DisableAntiBananaSit() end end })
DefenseTab:AddToggle({ Name = "アンチブロブキル", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiBlobKill() else DisableAntiBlobKill() end end })
DefenseTab:AddToggle({ Name = "アンチブロブラグドール", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiBlobRagdoll() else DisableAntiBlobRagdoll() end end })
DefenseTab:AddToggle({ Name = "アンチペイント", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiPaint() else DisableAntiPaint() end end })
DefenseTab:AddToggle({ Name = "アンチAFK", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiAFK() else DisableAntiAFK() end end })
DefenseTab:AddToggle({ Name = "アンチラグドール", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiRagdoll() else DisableAntiRagdoll() end end })
DefenseTab:AddToggle({ Name = "アンチウォーター", Default = false, Color = ThemeColor, Callback = function(v) if v then EnableAntiWater() else DisableAntiWater() end end })

-- ブロブマンタブ
local BlobmanTab = Window:MakeTab({ Name = "ブロブマン", Icon = "rbxassetid://7733916988" })

local TargetDropdown_blob = BlobmanTab:AddDropdown({
    Name = "ターゲットを選択",
    Default = "",
    Options = getPlayerList(),
    Callback = function(Value)
        BlobConfig.selectedTarget = Value
    end
})

local function updateTargetDropdown()
    TargetDropdown_blob:Refresh(getPlayerList(), true)
end
service.Players.PlayerAdded:Connect(updateTargetDropdown)
service.Players.PlayerRemoving:Connect(updateTargetDropdown)

BlobmanTab:AddSection({ Name = "選択キル" })
BlobmanTab:AddToggle({
    Name = "選択キル (ターゲット + オーラ)",
    Default = false,
    Color = ThemeColor,
    Callback = function(Value)
        if Value then
            local target = getPlayerFromSelection(BlobConfig.selectedTarget)
            if not target then
                OrionLib:MakeNotification({ Name = "エラー", Content = "先にターゲットを選択してください", Time = 3 })
                return
            end
            if not target.Parent then
                OrionLib:MakeNotification({ Name = "エラー", Content = "ターゲットが見つかりません", Time = 3 })
                return
            end
            SelectedKill.target = target
            SelectedKill.isActive = true
            StartSelectedKillLoop()
            OrionLib:MakeNotification({ Name = "選択キル開始", Content = "キル中: " .. target.DisplayName, Time = 2 })
        else
            StopSelectedKill()
            SelectedKill.target = nil
            OrionLib:MakeNotification({ Name = "選択キル停止", Content = "停止しました", Time = 2 })
        end
    end
})

BlobmanTab:AddSection({ Name = "Driftキック & ブロブマン" })
BlobmanTab:AddButton({
    Name = "キック",
    Callback = function()
        task.spawn(function()
            local targetPlr = checkTarget()
            if not targetPlr then return end
            local target = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not target or not myRoot then return end
            local blob = ensureBlob()
            if not blob then return end
            local side = (math.random() >= 0.5) and "Left" or "Right"
            local pos = myRoot.CFrame
            task.wait(0.1)
            myRoot.CFrame = target.CFrame
            task.wait(0.08)
            blobGrab(blob, myRoot, side)
            task.wait(0.08)
            SetNetworkOwner:FireServer(target, myRoot.CFrame)
            task.wait(0.08)
            target.CFrame = target.CFrame + Vector3.new(0, BlobConfig.FloatAmount, 0)
            task.wait(0.08)
            DestroyGrabLine:FireServer(target)
            task.wait(0.08)
            blobGrab(blob, target, side)
            task.wait(0.08)
            blobDrop(blob, target, side)
            task.wait(0.08)
            DestroyGrabLine:FireServer(target)
            task.wait(0.1)
            myRoot.CFrame = pos
        end)
    end
})

BlobmanTab:AddToggle({
    Name = "Drift Kick",
    Default = false,
    Color = ThemeColor,
    Callback = function(v)
        BlobConfig.orbitRunning = v
        BlobConfig.currentDriftLoopId = BlobConfig.currentDriftLoopId + 1
        local myLoopId = BlobConfig.currentDriftLoopId
        if not v then return end
        local target = getPlayerFromSelection(BlobConfig.selectedTarget)
        if target and target ~= localPlayer then
            local blobman = ensureBlob()
            if blobman then
                local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript", true)
                local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
                local dropRemote = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
                local lDet = blobman:FindFirstChild("LeftDetector")
                local rDet = blobman:FindFirstChild("RightDetector")
                local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChild("RigidConstraint"))
                local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChild("RigidConstraint"))
                local seat = blobman:FindFirstChild("VehicleSeat")
                local hum = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
                if seat and hum and seat.Occupant ~= hum then
                    local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.2)
                        seat:Sit(hum)
                        task.wait(0.5)
                    end
                end
                if grabRemote and dropRemote and ((lDet and lWeld) or (rDet and rWeld)) then
                    OrionLib:MakeNotification({ Name = "Unnamed Hub", Content = "Driftキックを開始します", Time = 3 })
                    task.spawn(function()
                        local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
                        local Det = rDet or lDet
                        local Weld = rWeld or lWeld
                        while BlobConfig.orbitRunning do
                            if myLoopId ~= BlobConfig.currentDriftLoopId then break end
                            if not target or not target.Parent then break end
                            local tChar = target.Character
                            local tHum = tChar and tChar:FindFirstChild("Humanoid")
                            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                            if tChar and tRoot and tHum and tHum.Health > 0 then
                                local bringStart = tick()
                                while tick() - bringStart < 0.35 do
                                    if myLoopId ~= BlobConfig.currentDriftLoopId or not BlobConfig.orbitRunning or not blobman or not blobman.Parent then break end
                                    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                        local currentTRoot = target.Character.HumanoidRootPart
                                        blobRoot.CFrame = currentTRoot.CFrame
                                        blobRoot.AssemblyLinearVelocity = Vector3.zero
                                        pcall(function()
                                            if Det then grabRemote:FireServer(Det, currentTRoot, Weld) end
                                            CreateGrabLine:FireServer(currentTRoot, Vector3.zero, currentTRoot.Position, false)
                                            SetNetworkOwner:FireServer(currentTRoot, blobRoot.CFrame)
                                        end)
                                    end
                                    service.RunService.Heartbeat:Wait()
                                end
                                if myLoopId ~= BlobConfig.currentDriftLoopId or not BlobConfig.orbitRunning or not blobman or not blobman.Parent then break end
                                tChar = target.Character
                                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                tHum = tChar and tChar:FindFirstChild("Humanoid")
                                if tChar and tRoot and tHum and tHum.Health > 0 then
                                    local SavedPos = tRoot.CFrame
                                    local targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)
                                    local lastTime = tick()
                                    local lastDropTime = tick()
                                    local dropCount = 0
                                    while BlobConfig.orbitRunning and blobman and blobman.Parent do
                                        if myLoopId ~= BlobConfig.currentDriftLoopId then break end
                                        if not target or not target.Parent then break end
                                        tChar = target.Character
                                        tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                        tHum = tChar and tChar:FindFirstChild("Humanoid")
                                        if not tChar or not tRoot or not tHum or tHum.Health <= 0 then break end
                                        if dropCount < 2 and (tick() - lastDropTime) > 0.8 then
                                            dropCount = dropCount + 1
                                            pcall(function()
                                                local rightWeld = blobman:FindFirstChild("RightDetector") and blobman.RightDetector:FindFirstChild("RightWeld")
                                                if rightWeld then dropRemote:FireServer(rightWeld) end
                                                DestroyGrabLine:FireServer(tRoot)
                                            end)
                                            blobRoot.CFrame = SavedPos
                                            blobRoot.AssemblyLinearVelocity = Vector3.zero
                                            service.RunService.Heartbeat:Wait()
                                            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                                local currentTRoot = target.Character.HumanoidRootPart
                                                blobRoot.CFrame = currentTRoot.CFrame
                                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                                                pcall(function()
                                                    if Det then grabRemote:FireServer(Det, currentTRoot, Weld) end
                                                    CreateGrabLine:FireServer(currentTRoot, Vector3.zero, currentTRoot.Position, false)
                                                    SetNetworkOwner:FireServer(currentTRoot, blobRoot.CFrame)
                                                end)
                                            end
                                            lastTime = tick()
                                            lastDropTime = tick()
                                        else
                                            if tRoot and tHum and tHum.Health > 0 and blobRoot then
                                                local currentTime = tick()
                                                local dt = currentTime - lastTime
                                                lastTime = currentTime
                                                BlobConfig.driftAngle = BlobConfig.driftAngle + (BlobConfig.driftSpeed * dt)
                                                local offsetX = math.cos(BlobConfig.driftAngle) * BlobConfig.driftRadius
                                                local offsetZ = math.sin(BlobConfig.driftAngle) * BlobConfig.driftRadius
                                                local blobPos = targetCenterCFrame.Position + Vector3.new(offsetX, BlobConfig.driftHeightOffset, offsetZ)
                                                blobRoot.CFrame = CFrame.new(blobPos, targetCenterCFrame.Position)
                                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                                                blobRoot.AssemblyAngularVelocity = Vector3.zero
                                                tRoot.CFrame = targetCenterCFrame
                                                tRoot.AssemblyLinearVelocity = Vector3.zero
                                                tRoot.AssemblyAngularVelocity = Vector3.zero
                                                pcall(function()
                                                    tHum.PlatformStand = true
                                                    tHum.Sit = true
                                                    SetNetworkOwner:FireServer(tRoot, targetCenterCFrame)
                                                    local rightWeld = blobman:FindFirstChild("RightDetector") and blobman.RightDetector:FindFirstChild("RightWeld")
                                                    if rightWeld then dropRemote:FireServer(rightWeld) end
                                                    DestroyGrabLine:FireServer(tRoot)
                                                    if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                                                    CreateGrabLine:FireServer(tRoot, Vector3.zero, targetCenterCFrame.Position, false)
                                                end)
                                            else break end
                                        end
                                        service.RunService.Heartbeat:Wait()
                                    end
                                end
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end
        else
            OrionLib:MakeNotification({ Name = "Unnamed Hub", Content = "ターゲットを選択してください", Time = 3 })
        end
    end
})

BlobmanTab:AddButton({
    Name = "ブリング",
    Callback = function()
        task.spawn(function()
            local targetPlr = checkTarget()
            if not targetPlr then return end
            local target = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not target or not myRoot then return end
            local blob = ensureBlob()
            if not blob then return end
            local side = (math.random() >= 0.5) and "Left" or "Right"
            local myPos = myRoot.CFrame
            SetNetworkOwner:FireServer(target, myRoot.CFrame)
            task.wait(0.15)
            myRoot.CFrame = target.CFrame
            task.wait(0.15)
            blobGrab(blob, target, side)
            task.wait(0.2)
            myRoot.CFrame = myPos
        end)
    end
})

BlobmanTab:AddButton({
    Name = "スライド",
    Callback = function()
        task.spawn(function()
            local targetPlr = checkTarget()
            if not targetPlr then return end
            local target = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not target or not myRoot then return end
            local blob = ensureBlob()
            if not blob then return end
            local side = (math.random() >= 0.5) and "Left" or "Right"
            local pos = myRoot.CFrame
            SetNetworkOwner:FireServer(target, myRoot.CFrame)
            task.wait(0.08)
            myRoot.CFrame = target.CFrame
            task.wait(0.08)
            blobGrab(blob, myRoot, side)
            task.wait(0.08)
            SetNetworkOwner:FireServer(target, myRoot.CFrame)
            task.wait(0.08)
            target.CFrame = target.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.08)
            DestroyGrabLine:FireServer(target)
            task.wait(0.08)
            blobGrab(blob, target, side)
            task.wait(0.08)
            blobDrop(blob, target, side)
            task.wait(0.08)
            DestroyGrabLine:FireServer(target)
            task.wait(0.08)
            myRoot.CFrame = pos
        end)
    end
})

BlobmanTab:AddSection({ Name = "オーラ" })
BlobmanTab:AddToggle({
    Name = "キルオーラ",
    Default = false,
    Color = ThemeColor,
    Callback = function(Value)
        BlobConfig.Running = Value
        local function spawnBlobmanIfNeeded()
            local inv = SpawnedInToys
            if not inv then return nil end
            local existing = inv:FindFirstChild(BlobConfig.ToyName)
            if existing then return existing end
            local char = localPlayer.Character
            if char and char:FindFirstChild("Head") then
                pcall(function() SpawnToyRemoteFunction:InvokeServer(BlobConfig.ToyName, char.Head.CFrame, Vector3.zero) end)
            end
            return inv:WaitForChild(BlobConfig.ToyName, 5)
        end
        local function sitOnBlobman(blobman)
            if not blobman then return end
            local seat = blobman:FindFirstChildWhichIsA("VehicleSeat", true)
            local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if seat and hum and not seat.Occupant then
                task.wait(0.1)
                pcall(function() seat:Sit(hum) end)
            end
        end
        local function runKillAura()
            local hpToggle = false
            while BlobConfig.Running do
                task.wait(0.01)
                local char = localPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local blobman = spawnBlobmanIfNeeded()
                if not blobman then continue end
                sitOnBlobman(blobman)
                local scriptFolder = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
                local detector = blobman:FindFirstChild("LeftDetector")
                local weld = detector and detector:FindFirstChild("LeftWeld")
                if scriptFolder and detector and weld then
                    local CreatureGrab = scriptFolder:FindFirstChild("CreatureGrab")
                    local CreatureRelease = scriptFolder:FindFirstChild("CreatureRelease")
                    local CreatureDrop = scriptFolder:FindFirstChild("CreatureDrop")
                    if CreatureGrab and CreatureRelease and CreatureDrop then
                        hpToggle = not hpToggle
                        for _, plr in ipairs(service.Players:GetPlayers()) do
                            if not BlobConfig.Running then break end
                            if plr ~= localPlayer then
                                local targetChar = plr.Character
                                local thrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                                local thum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                                if thrp and thum and (hrp.Position - thrp.Position).Magnitude <= BlobConfig.Range then
                                    pcall(function()
                                        CreatureGrab:FireServer(detector, thrp, weld)
                                        CreatureRelease:FireServer(weld, thrp)
                                        CreatureDrop:FireServer(weld, thrp)
                                        thum.Health = hpToggle and 0 or 100
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        if Value then task.spawn(runKillAura) end
    end
})

BlobmanTab:AddSection({ Name = "Settings" })
BlobmanTab:AddToggle({
    Name = "Blobman RGB",
    Default = false,
    Color = ThemeColor,
    Callback = function(Value)
        BlobConfig.AIRNJIAD = BlobConfig.AIRNJIAD or {}
        if BlobConfig.BLESP == Value then return end
        BlobConfig.BLESP = Value
        local function BLBOESP(model)
            if not BlobConfig.BLESP then return end
            if model:FindFirstChild("BlobmanESP") then return end
            local highlight = Instance.new("Highlight")
            highlight.Name = "BlobmanESP"
            highlight.FillTransparency = 0.3
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Adornee = model
            highlight.Parent = model
            table.insert(BlobConfig.AIRNJIAD, highlight)
        end
        local function isValidBlobman(obj)
            return obj:IsA("Model") and obj.Name == "CreatureBlobman" and obj.Parent and obj.Parent.Name:find("SpawnedInToys")
        end
        local function SOKDOI()
            if BlobConfig.RDESDG then return end
            BlobConfig.RDESDG = service.RunService.RenderStepped:Connect(function()
                local hue = tick() % 5 / 5
                for i = #BlobConfig.AIRNJIAD, 1, -1 do
                    local hl = BlobConfig.AIRNJIAD[i]
                    if not hl or not hl.Parent then table.remove(BlobConfig.AIRNJIAD, i)
                    else hl.FillColor = Color3.fromHSV(hue, 1, 1) end
                end
            end)
        end
        local function GASGS()
            if BlobConfig.RDESDG then BlobConfig.RDESDG:Disconnect(); BlobConfig.RDESDG = nil end
        end
        local function GWGEVwgwg()
            for i = #BlobConfig.AIRNJIAD, 1, -1 do
                local hl = BlobConfig.AIRNJIAD[i]
                if hl then hl:Destroy() end
                table.remove(BlobConfig.AIRNJIAD, i)
            end
        end
        local function scan()
            for _, v in ipairs(service.Workspace:GetDescendants()) do
                if isValidBlobman(v) then BLBOESP(v) end
            end
        end
        if Value then
            if BlobConfig.BlobmanConnection then BlobConfig.BlobmanConnection:Disconnect() end
            BlobConfig.BlobmanConnection = service.Workspace.DescendantAdded:Connect(function(obj)
                if isValidBlobman(obj) then task.wait(0.2); BLBOESP(obj) end
            end)
            scan()
            SOKDOI()
        else
            if BlobConfig.BlobmanConnection then BlobConfig.BlobmanConnection:Disconnect(); BlobConfig.BlobmanConnection = nil end
            GASGS()
            GWGEVwgwg()
        end
    end
})

BlobmanTab:AddToggle({
    Name = "壁抜け(Noclip)",
    Default = false,
    Color = ThemeColor,
    Callback = function(v)
        BlobConfig.BlobNoclip = v
        if v then
            task.spawn(function()
                while BlobConfig.BlobNoclip do
                    if SpawnedInToys then
                        local count = 0
                        for _, item in ipairs(SpawnedInToys:GetChildren()) do
                            if item.Name == "CreatureBlobman" then
                                if count < 4 then
                                    count = count + 1
                                    for _, descendant in ipairs(item:GetDescendants()) do
                                        if descendant:IsA("BasePart") then
                                            descendant.CanQuery = false
                                            descendant.CanTouch = false
                                            descendant.CanCollide = false
                                        end
                                    end
                                else break end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        else
            if SpawnedInToys then
                for _, item in ipairs(SpawnedInToys:GetChildren()) do
                    if item.Name == "CreatureBlobman" then
                        for _, descendant in ipairs(item:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanQuery = true
                                descendant.CanTouch = true
                                descendant.CanCollide = true
                            end
                        end
                    end
                end
            end
        end
    end
})

BlobmanTab:AddToggle({
    Name = "Walk-Speed",
    Default = false,
    Color = ThemeColor,
    Callback = function(Value)
        BlobConfig.BlobSpeedToggle = Value
        if Value then
            task.spawn(function()
                while BlobConfig.BlobSpeedToggle do
                    local char = localPlayer.Character
                    local hum = char and char:FindFirstChild("Humanoid")
                    if hum then
                        local seat = hum.SeatPart
                        local isRiding = seat and seat.Parent and seat.Parent.Name == "CreatureBlobman"
                        if isRiding then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local moveDir = hum.MoveDirection
                                hrp.CFrame = hrp.CFrame + moveDir * (BlobConfig.BlobSpeedValue / 10)
                            end
                        else
                            hum.WalkSpeed = 16
                        end
                    end
                    task.wait()
                end
                local char = localPlayer.Character
                if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end
            end)
        end
    end
})

BlobmanTab:AddSlider({
    Name = "スピード",
    Min = 16,
    Max = 300,
    Default = 16,
    Color = ThemeColor,
    Increment = 1,
    Callback = function(Value)
        BlobConfig.BlobSpeedValue = Value
        local char = localPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            local seat = hum.SeatPart
            local isRiding = seat and seat.Parent and seat.Parent.Name == "CreatureBlobman"
            if isRiding then hum.WalkSpeed = Value else hum.WalkSpeed = 16 end
        end
    end
})

BlobmanTab:AddSlider({
    Name = "HipHeight",
    Min = -500,
    Max = 500,
    Color = ThemeColor,
    Increment = 10,
    Default = 0,
    Callback = function(value)
        local function updateHipHeight(targetValue)
            if not SpawnedInToys then return end
            local creatureBlobmanCount = 0
            for _, item in ipairs(SpawnedInToys:GetChildren()) do
                if item.Name == "CreatureBlobman" then
                    if creatureBlobmanCount < 4 then
                        creatureBlobmanCount = creatureBlobmanCount + 1
                        for _, descendant in ipairs(item:GetDescendants()) do
                            if descendant:IsA("Humanoid") then
                                if BlobConfig.ORHHi == nil then BlobConfig.ORHHi = descendant.HipHeight end
                                descendant.HipHeight = targetValue
                            end
                        end
                    else break end
                end
            end
        end
        updateHipHeight(value)
    end
})

BlobmanTab:AddSection({ Name = "Others" })
BlobmanTab:AddToggle({
    Name = "Auto-Sit",
    Default = false,
    Color = ThemeColor,
    Callback = function(Value)
        BlobConfig.AutoBlobSit = Value
        if not Value and BlobConfig.blobSeat then
            local char = localPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then humanoid.Sit = false end
            end
            BlobConfig.blobSeat = nil
        end
    end
})

BlobmanTab:AddButton({
    Name = "Spawn Blobman",
    Callback = function()
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local function checkExisting() return SpawnedInToys and SpawnedInToys:FindFirstChild("CreatureBlobman") end
        if checkExisting() then return end
        local success, blob = pcall(function()
            return SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", hrp.CFrame, Vector3.zero)
        end)
        if success and blob and typeof(blob) == "Instance" then
            task.wait(0.1)
            if blob.Parent then blob:PivotTo(hrp.CFrame * CFrame.new(0, 0, -5)) end
        end
    end
})

BlobmanTab:AddButton({
    Name = "Remove Blobman",
    Callback = function()
        local blob = SpawnedInToys and SpawnedInToys:FindFirstChild("CreatureBlobman")
        if not blob then return end
        DestroyToy:FireServer(blob)
    end
})

-- =====================================================
-- >> ブロブマン: スパムグラブキック + パレットラグドール（完全修正版）
-- =====================================================
BlobmanTab:AddSection({ Name = "スパムグラブキック + パレットラグドール" })

-- ★★★ 修正の核心：doブロックでスコープ分離 ★★★
do
    -- 各ターゲットごとの状態を管理するテーブル
    local activeGrabTasks = {}
    local activeSpamTasks = {}
    local activePlayerBodies = {}
    local savedMyPositions = {}
    local grabStates = {}
    local activePhysicsConnections = {}
    local noclipConnection = nil
    local isGrabKickActive = false
    
    -- 定数
    local CIRCLE_RADIUS = 8
    local HEIGHT_OFFSET = 15
    
    local activeDraggingPlayers = {}
    
    -- ドラッグ中のプレイヤーリスト更新
    local function updateDraggingList()
        local list = {}
        for name, state in pairs(grabStates) do
            if state.dragging then
                table.insert(list, name)
            end
        end
        table.sort(list)
        activeDraggingPlayers = list
    end
    
    -- 壁抜け設定
    local function SetNoclip(enabled)
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if enabled then
            noclipConnection = service.RunService.Stepped:Connect(function()
                if localPlayer and localPlayer.Character then
                    for _, part in pairs(localPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
    
    -- ネットワークオーナー設定
    local function SetNetworkOwnerForTarget(targetRoot)
        if not targetRoot or not targetRoot.Parent or not SetNetworkOwner then return end
        pcall(function() SetNetworkOwner:FireServer(targetRoot, targetRoot.CFrame) end)
    end
    
    -- グラブライン破棄
    local function DoDestroyGrabLine(targetRoot)
        if not targetRoot or not targetRoot.Parent or not DestroyGrabLine then return end
        pcall(function() DestroyGrabLine:FireServer(targetRoot) end)
    end
    
    -- ボディクリーンアップ
    local function CleanupPlayerBodies(playerName)
        if activePlayerBodies[playerName] then
            pcall(function()
                if activePlayerBodies[playerName].PositionObj and activePlayerBodies[playerName].PositionObj.Parent then
                    activePlayerBodies[playerName].PositionObj:Destroy()
                end
                if activePlayerBodies[playerName].GyroObj and activePlayerBodies[playerName].GyroObj.Parent then
                    activePlayerBodies[playerName].GyroObj:Destroy()
                end
            end)
            activePlayerBodies[playerName] = nil
        end
        updateDraggingList()
    end
    
    -- ボディ作成
    local function CreatePlayerBodies(playerName, targetRoot, pos)
        CleanupPlayerBodies(playerName)
        if not targetRoot or not targetRoot.Parent then return end
        for _, v in pairs(targetRoot:GetChildren()) do
            if v:IsA("BodyPosition") or v:IsA("BodyGyro") then
                pcall(function() v:Destroy() end)
            end
        end
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 1000000
        bp.D = 1000
        bp.Position = pos
        bp.Parent = targetRoot
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 1000000
        bg.D = 1000
        bg.CFrame = CFrame.new(pos)
        bg.Parent = targetRoot
        activePlayerBodies[playerName] = { PositionObj = bp, GyroObj = bg }
        updateDraggingList()
    end
    
    -- 円配置位置計算
    local function GetCirclePosition(playerName, myRootCFrame)
        local index = table.find(activeDraggingPlayers, playerName)
        if not index or #activeDraggingPlayers <= 1 then
            return myRootCFrame * CFrame.new(0, HEIGHT_OFFSET, 0)
        end
        local total = #activeDraggingPlayers
        local angle = (index - 1) * (math.pi * 2 / total)
        local relativeX = math.cos(angle) * CIRCLE_RADIUS
        local relativeZ = math.sin(angle) * CIRCLE_RADIUS
        return myRootCFrame * CFrame.new(relativeX, HEIGHT_OFFSET, relativeZ)
    end
    
    -- 単体停止
    local function StopSingleGrabKick(playerName)
        if activePhysicsConnections[playerName] then
            activePhysicsConnections[playerName]:Disconnect()
            activePhysicsConnections[playerName] = nil
        end
        if activeSpamTasks[playerName] then
            task.cancel(activeSpamTasks[playerName])
            activeSpamTasks[playerName] = nil
        end
        if activeGrabTasks[playerName] then
            task.cancel(activeGrabTasks[playerName])
            activeGrabTasks[playerName] = nil
        end
        CleanupPlayerBodies(playerName)
        grabStates[playerName] = nil
        savedMyPositions[playerName] = nil
        updateDraggingList()
    end
    
    -- 全停止
    local function StopAllGrabKicks()
        isGrabKickActive = false
        SetNoclip(false)
        for playerName, _ in pairs(activeGrabTasks) do
            StopSingleGrabKick(playerName)
        end
        activeGrabTasks = {}
        activeSpamTasks = {}
        activePlayerBodies = {}
        savedMyPositions = {}
        grabStates = {}
        activeDraggingPlayers = {}
        for name, conn in pairs(activePhysicsConnections) do
            pcall(function() conn:Disconnect() end)
        end
        activePhysicsConnections = {}
    end
    
    -- 単体実行
    local function RunSingleGrabKick(targetName)
        local targetPlayer = service.Players:FindFirstChild(targetName)
        if not targetPlayer then return end
        
        local myChar = localPlayer and localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        savedMyPositions[targetName] = myRoot.CFrame
        grabStates[targetName] = {
            dragging = false,
            grabStartTime = 0,
            checkStartTime = 0,
            spamKickRunning = false,
            rotX = 0, rotY = 0, rotZ = 0
        }
        
        -- 物理ループ（ターゲットの速度をゼロに維持）
        if activePhysicsConnections[targetName] then activePhysicsConnections[targetName]:Disconnect() end
        activePhysicsConnections[targetName] = service.RunService.Heartbeat:Connect(function()
            if not isGrabKickActive or not targetPlayer or not targetPlayer.Parent then
                if activePhysicsConnections[targetName] then
                    activePhysicsConnections[targetName]:Disconnect()
                    activePhysicsConnections[targetName] = nil
                end
                return
            end
            local tChar = targetPlayer.Character
            if tChar and tChar.Parent then
                for _, part in pairs(tChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        -- メインループ
        activeGrabTasks[targetName] = task.spawn(function()
            while isGrabKickActive and targetPlayer and targetPlayer.Parent do
                myChar = localPlayer and localPlayer.Character
                myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local tChar = targetPlayer.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                local state = grabStates[targetName]
                if not state then break end
                
                -- ★★★ ターゲットが生存している場合のみ処理 ★★★
                if tRoot and tHum and tHum.Health > 0 and myRoot and tRoot.Parent then
                    
                    -- スパムタスク（ネットワークオーナー＆グラブライン）
                    if not state.spamKickRunning then
                        state.spamKickRunning = true
                        activeSpamTasks[targetName] = task.spawn(function()
                            while isGrabKickActive and tRoot and tRoot.Parent do
                                SetNetworkOwnerForTarget(tRoot)
                                task.wait()
                                if tRoot and tRoot.Parent then
                                    DoDestroyGrabLine(tRoot)
                                end
                                task.wait()
                            end
                        end)
                    end
                    
                    -- ドラッグ状態
                    if not state.dragging then
                        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                        CleanupPlayerBodies(targetName)
                        state.checkStartTime = 0
                        SetNetworkOwnerForTarget(tRoot)
                        DoDestroyGrabLine(tRoot)
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                        myRoot.AssemblyAngularVelocity = Vector3.zero
                        if state.grabStartTime == 0 then state.grabStartTime = tick() end
                        if tick() - state.grabStartTime > 0.35 then
                            state.dragging = true
                            state.grabStartTime = 0
                            state.checkStartTime = tick()
                            updateDraggingList()
                            if savedMyPositions[targetName] then
                                myRoot.CFrame = savedMyPositions[targetName]
                                local initialLockPos = GetCirclePosition(targetName, savedMyPositions[targetName])
                                CreatePlayerBodies(targetName, tRoot, initialLockPos.Position)
                            end
                        end
                    else
                        local currentLockPos = GetCirclePosition(targetName, myRoot.CFrame)
                        state.rotX = (state.rotX + 5) % 360
                        state.rotY = (state.rotY + 7) % 360
                        state.rotZ = (state.rotZ + 3) % 360
                        local rotationCFrame = CFrame.Angles(math.rad(state.rotX), math.rad(state.rotY), math.rad(state.rotZ))
                        local finalCFrame = CFrame.new(currentLockPos.Position) * rotationCFrame
                        local bodies = activePlayerBodies[targetName]
                        if bodies and bodies.PositionObj and bodies.PositionObj.Parent and bodies.GyroObj and bodies.GyroObj.Parent then
                            bodies.PositionObj.Position = currentLockPos.Position
                            bodies.GyroObj.CFrame = finalCFrame
                        else
                            CreatePlayerBodies(targetName, tRoot, currentLockPos.Position)
                        end
                        if state.checkStartTime > 0 and tick() - state.checkStartTime > 0.30 then
                            local currentDist = (tRoot.Position - currentLockPos.Position).Magnitude
                            if currentDist > (CIRCLE_RADIUS + 15) then
                                state.dragging = false
                                state.grabStartTime = 0
                                state.checkStartTime = 0
                                CleanupPlayerBodies(targetName)
                                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                            else
                                state.checkStartTime = tick()
                            end
                        end
                    end
                else
                    -- ★★★ ターゲットが死亡または存在しない場合 ★★★
                    if state.spamKickRunning then
                        if activeSpamTasks[targetName] then
                            task.cancel(activeSpamTasks[targetName])
                            activeSpamTasks[targetName] = nil
                        end
                        state.spamKickRunning = false
                    end
                    state.dragging = false
                    state.grabStartTime = 0
                    state.checkStartTime = 0
                    CleanupPlayerBodies(targetName)
                end
                task.wait()
            end
            StopSingleGrabKick(targetName)
        end)
    end

    -- ★★★ UIトグル（ブロブマンタブに追加） ★★★
    BlobmanTab:AddToggle({
        Name = "スパムグラブキック",
        Default = false,
        Color = ThemeColor,
        Callback = function(Value)
            if Value then
                -- 既存の処理を完全に停止
                StopAllGrabKicks()
                
                -- ターゲットを取得
                local targetName = BlobConfig.selectedTarget
                if not targetName or targetName == "" then
                    OrionLib:MakeNotification({ Name = "エラー", Content = "先にターゲットを選択してください", Time = 3 })
                    return
                end
                
                local targetPlayer = getPlayerFromSelection(targetName)
                if not targetPlayer then
                    OrionLib:MakeNotification({ Name = "エラー", Content = "ターゲットが見つかりません", Time = 3 })
                    return
                end
                
                -- 開始
                isGrabKickActive = true
                SetNoclip(true)
                RunSingleGrabKick(targetPlayer.Name)
                
                OrionLib:MakeNotification({ Name = "スパムグラブキック", Content = "ON: " .. targetPlayer.DisplayName, Time = 2 })
            else
                StopAllGrabKicks()
                OrionLib:MakeNotification({ Name = "スパムグラブキック", Content = "OFF", Time = 2 })
            end
        end
    })
end

-- =====================================================
-- >> パレットラグドール（完全修正版）
-- =====================================================
do
    local ownershipRagdollActive = false

    local function PalletRagdollFunction(targetName)
        local target = service.Players:FindFirstChild(targetName)
        if not target or not target.Character then return end
        
        local skyPos = CFrame.new(0, 800000, 0)
        
        pcall(function()
            RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", skyPos, Vector3.zero)
        end)
        
        local pallet
        local attempts = 0
        repeat
            local toysFolder = service.Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
            if toysFolder then pallet = toysFolder:FindFirstChild("PalletLightBrown") end
            if not pallet then
                service.RunService.Heartbeat:Wait()
                attempts = attempts + 1
            end
            if attempts > 50 then break end
        until pallet or not ownershipRagdollActive
        
        if not pallet then return end
        
        local mainPart = pallet:FindFirstChild("SoundPart") or pallet:FindFirstChildWhichIsA("BasePart")
        if not mainPart then return end
        
        mainPart.CanCollide = false
        mainPart.Anchored = false
        
        local function claim(part)
            pcall(function()
                if SetNetworkOwner then SetNetworkOwner:FireServer(part, part.CFrame) end
                if CreateGrabLine then CreateGrabLine:FireServer(part, Vector3.zero, part.Position, false) end
                if DestroyGrabLine then DestroyGrabLine:FireServer(part) end
            end)
        end
        
        claim(mainPart)
        
        while ownershipRagdollActive do
            task.wait(0.2)
            
            if not target or not target.Parent or not target.Character then break end
            
            local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end
            
            local targetPos = rootPart.Position
            
            mainPart.CFrame = CFrame.new(targetPos.X, targetPos.Y + 2.0, targetPos.Z)
            mainPart.AssemblyLinearVelocity = Vector3.new(0, -250, 0)
            mainPart.AssemblyAngularVelocity = Vector3.zero
            
            claim(mainPart)
            
            mainPart.CanCollide = true
            for i = 1, 3 do
                service.RunService.Heartbeat:Wait()
            end
            
            mainPart.CanCollide = false
            mainPart.CFrame = skyPos
            mainPart.AssemblyLinearVelocity = Vector3.zero
        end
        
        if pallet and pallet.Parent then
            pcall(function()
                if RS and RS.MenuToys and RS.MenuToys.DestroyToy then
                    RS.MenuToys.DestroyToy:FireServer(pallet)
                end
            end)
            pcall(function() pallet:Destroy() end)
        end
    end

    BlobmanTab:AddToggle({
        Name = "パレットラグドール",
        Default = false,
        Color = ThemeColor,
        Callback = function(Value)
            ownershipRagdollActive = Value
            
            if Value then
                local targetName = BlobConfig.selectedTarget
                if not targetName or targetName == "" then
                    OrionLib:MakeNotification({ Name = "エラー", Content = "先にターゲットを選択してください", Time = 3 })
                    ownershipRagdollActive = false
                    return
                end
                
                local targetPlayer = getPlayerFromSelection(targetName)
                if not targetPlayer then
                    OrionLib:MakeNotification({ Name = "エラー", Content = "ターゲットが見つかりません", Time = 3 })
                    ownershipRagdollActive = false
                    return
                end
                
                OrionLib:MakeNotification({ Name = "パレットラグドール", Content = "ON: " .. targetPlayer.DisplayName, Time = 2 })
                
                task.spawn(function()
                    PalletRagdollFunction(targetPlayer.Name)
                end)
            else
                OrionLib:MakeNotification({ Name = "パレットラグドール", Content = "OFF", Time = 2 })
            end
        end
    })
end

-- Loopタブ
local LoopTab = Window:MakeTab({ Name = "Loop", Icon = "rbxassetid://4483362458" })

LoopTab:AddSection({ Name = "ターゲット選択" })

local LoopPlayerDropdown = LoopTab:AddDropdown({
    Name = "ターゲットリスト",
    Default = "",
    Options = updatePlayerListLoop(),
    Callback = function(selectedDisplayName)
        SnipesConfig.TargetPlayer = getPlayerFromDisplayName(selectedDisplayName)
    end
})

LoopTab:AddButton({
    Name = "🔄 プレイヤーリスト更新",
    Callback = function()
        LoopPlayerDropdown:Refresh(updatePlayerListLoop(), true)
    end
})

LoopTab:AddSection({ Name = "ループ攻撃" })

LoopTab:AddToggle({
    Name = "ループキル",
    Default = false,
    Color = ThemeColor,
    Callback = function(v) SnipesConfig.LoopKill = v end
})

LoopTab:AddToggle({
    Name = "ループボイド",
    Default = false,
    Color = ThemeColor,
    Callback = function(v) SnipesConfig.LoopVoid = v end
})

LoopTab:AddToggle({
    Name = "ループ毒",
    Default = false,
    Color = ThemeColor,
    Callback = function(v) SnipesConfig.LoopPoison = v end
})

LoopTab:AddToggle({
    Name = "ループラグドール",
    Default = false,
    Color = ThemeColor,
    Callback = function(v) SnipesConfig.LoopRagdoll = v end
})

LoopTab:AddToggle({
    Name = "ループデス",
    Default = false,
    Color = ThemeColor,
    Callback = function(v) SnipesConfig.LoopDeath = v end
})

LoopTab:AddToggle({
    Name = "ループブリング（引き寄せ）",
    Default = false,
    Color = ThemeColor,
    Callback = function(v) SnipesConfig.LoopBring = v end
})

LoopTab:AddToggle({
    Name = "ループプル（引き続ける）",
    Default = false,
    Color = ThemeColor,
    Callback = function(v) SnipesConfig.LoopPull = v end
})

service.Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if LoopPlayerDropdown then LoopPlayerDropdown:Refresh(updatePlayerListLoop(), true) end
end)

service.Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if LoopPlayerDropdown then LoopPlayerDropdown:Refresh(updatePlayerListLoop(), true) end
end)

-- ======================================================
-- ホットキー
-- ======================================================
service.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X and input.UserInputType == Enum.UserInputType.Keyboard then
        if Config.KillBypassActive then StopKillBypass() else StartKillBypass() end
    end
end)

-- ======================================================
-- 初期化
-- ======================================================
OrionLib:Init()

OrionLib:MakeNotification({
    Name = "Unnamed Hub",
    Content = "全機能が読み込まれました！\nXキーでキルバイパス切替",
    Image = "rbxassetid://118739401073899",
    Time = 6
})

print("Unnamed Hub - 完全修正版（何度でも再起動可能）ロード完了")
```
````