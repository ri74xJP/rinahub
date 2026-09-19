-- ============================================================
-- 修正版: Kick spam (Ragdoll & Lag)
-- by Jailbreak Ai
-- OrionLib 安定版 / エラーハンドリング付き
-- ============================================================

-- ★ 安定版 OrionLib をロード
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
if not OrionLib then
    warn("OrionLib のロードに失敗しました。")
    return
end

local Window = OrionLib:MakeWindow({
    Name = "Kick spam",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "KickSpam"
})

-- ============================================================
-- サービス取得
-- ============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- GrabEvents
local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
if not GrabEvents then
    warn("GrabEvents が見つかりません。")
    return
end

local CreateGrabLine = GrabEvents:FindFirstChild("CreateGrabLine")
local DestroyGrabLine = GrabEvents:FindFirstChild("DestroyGrabLine")
local SetNetworkOwner = GrabEvents:FindFirstChild("SetNetworkOwner")

-- MenuToys
local MenuToys = ReplicatedStorage:FindFirstChild("MenuToys")
local SpawnToyRemoteFunction = MenuToys and MenuToys:FindFirstChild("SpawnToyRemoteFunction")

-- ============================================================
-- タブ
-- ============================================================
local ConfigTab = Window:MakeTab({
    Name = "ターゲット",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ============================================================
-- 変数
-- ============================================================
local Config = {
    PlayerList = {},   -- 選択されたターゲット名
    isActive = false,
    distance = 25,
    ragdollActive = false,
    lagRunning = false,
    palletRagdoll = nil,
    connections = {}
}

-- ============================================================
-- プレイヤーリスト取得
-- ============================================================
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then
        table.insert(list, "他のプレイヤーがいません")
    end
    return list
end

-- ============================================================
-- キャラクター取得
-- ============================================================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ============================================================
-- パレットラグドール生成
-- ============================================================
local function spawnPallet()
    if not SpawnToyRemoteFunction then return nil end
    
    local char = GetCharacter()
    local root = char:WaitForChild("HumanoidRootPart")
    if not root then return nil end
    
    -- 条件待ち
    local waitCount = 0
    while LocalPlayer.InPlot and LocalPlayer.InPlot.Value and 
          LocalPlayer.InOwnedPlot and not LocalPlayer.InOwnedPlot.Value and 
          waitCount < 50 do
        task.wait(0.1)
        waitCount = waitCount + 1
    end
    
    waitCount = 0
    while LocalPlayer.CanSpawnToy and not LocalPlayer.CanSpawnToy.Value and waitCount < 50 do
        task.wait(0.1)
        waitCount = waitCount + 1
    end
    
    local spawnCF = root.CFrame * CFrame.new(0, 14, 20)
    local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if not folder then
        folder = Workspace:FindFirstChild("PlotItems")
        if folder then folder = folder:FindFirstChild("Plot1") end
    end
    if not folder then folder = Workspace end
    
    local result = nil
    local conn = folder.ChildAdded:Connect(function(child)
        if child.Name == "PalletLightBrown" then
            result = child
        end
    end)
    
    pcall(function()
        SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", spawnCF, Vector3.zero)
    end)
    
    local start = tick()
    repeat task.wait(0.05) until result or (tick() - start) > 5
    conn:Disconnect()
    return result
end

-- ============================================================
-- ラグスパム
-- ============================================================
local function startLagSpam()
    if Config.lagRunning then return end
    Config.lagRunning = true
    
    task.spawn(function()
        while Config.lagRunning do
            local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
                or Workspace:FindFirstChild("Spawn")
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
            
            if spawnLocation and CreateGrabLine then
                pcall(function()
                    CreateGrabLine:FireServer(spawnLocation, CFrame.new(
                        math.random(-1e9, 1e9), 0, math.random(-1e9, 1e9)
                    ))
                end)
            end
            task.wait(0.001)
        end
    end)
end

local function stopLagSpam()
    Config.lagRunning = false
end

-- ============================================================
-- ターゲットにテレポート
-- ============================================================
local function teleportToTarget(targetPlayer, myRoot)
    if not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not myRoot then return end
    
    local savedCF = myRoot.CFrame
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
    
    for i = 1, 15 do
        if SetNetworkOwner then
            pcall(function() SetNetworkOwner:FireServer(targetRoot, targetRoot.CFrame) end)
        end
        task.wait()
    end
    
    myRoot.CFrame = savedCF
end

-- ============================================================
-- メイントグル
-- ============================================================
ConfigTab:AddDropdown({
    Name = "Select Target (複数選択可)",
    Default = "",
    Options = getPlayerList(),
    Multi = true,
    Callback = function(Values)
        Config.PlayerList = {}
        if type(Values) == "table" then
            for _, name in ipairs(Values) do
                if Players:FindFirstChild(name) then
                    table.insert(Config.PlayerList, name)
                end
            end
        elseif type(Values) == "string" then
            if Players:FindFirstChild(Values) then
                table.insert(Config.PlayerList, Values)
            end
        end
    end
})

ConfigTab:AddToggle({
    Name = "Kick spam (Ragdoll & Lag)",
    Default = false,
    Callback = function(Value)
        Config.isActive = Value
        Config.ragdollActive = Value
        
        if not Value then
            -- 停止処理
            stopLagSpam()
            if Config.palletRagdoll then
                pcall(function() Config.palletRagdoll:Destroy() end)
                Config.palletRagdoll = nil
            end
            for _, conn in ipairs(Config.connections) do
                pcall(function() conn:Disconnect() end)
            end
            Config.connections = {}
            return
        end
        
        if #Config.PlayerList == 0 then
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "ターゲットを選択してください",
                Time = 2
            })
            return
        end
        
        -- ラグ開始
        startLagSpam()
        
        -- メインループ
        task.spawn(function()
            while Config.isActive do
                for _, targetName in ipairs(Config.PlayerList) do
                    local targetPlayer = Players:FindFirstChild(targetName)
                    if not targetPlayer then continue end
                    
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local tChar = targetPlayer.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar and tChar:FindFirstChild("Humanoid")
                    
                    if myRoot and tRoot and tHum and tHum.Health > 0 then
                        -- 距離チェック
                        local dist = (myRoot.Position - tRoot.Position).Magnitude
                        if dist > Config.distance then
                            teleportToTarget(targetPlayer, myRoot)
                        end
                        
                        -- 所有権奪取＆ライン破棄
                        if SetNetworkOwner then
                            pcall(function() SetNetworkOwner:FireServer(tRoot, tRoot.CFrame) end)
                        end
                        if DestroyGrabLine then
                            pcall(function() DestroyGrabLine:FireServer(tRoot) end)
                        end
                        
                        -- 速度リセット
                        tRoot.AssemblyLinearVelocity = Vector3.zero
                        tRoot.AssemblyAngularVelocity = Vector3.zero
                        
                        -- 固定
                        local bp = tRoot:FindFirstChild("ControlBP") or Instance.new("BodyPosition")
                        bp.Name = "ControlBP"
                        bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                        bp.P = 800000
                        bp.Parent = tRoot
                        bp.Position = myRoot.Position + Vector3.new(0, 15, 0)
                    end
                end
                task.wait(0.001)
            end
        end)
        
        -- パレットラグドール
        local pallet = nil
        Config.connections["ragdoll"] = RunService.RenderStepped:Connect(function()
            if not Config.ragdollActive or #Config.PlayerList == 0 then return end
            
            local targetName = Config.PlayerList[1]
            local targetPlayer = Players:FindFirstChild(targetName)
            if not targetPlayer or not targetPlayer.Character then return end
            
            local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tHum = targetPlayer.Character:FindFirstChild("Humanoid")
            if not tRoot or not tHum then return end
            
            -- パレット管理
            if pallet and pallet:IsDescendantOf(Workspace) then
                local sp = pallet:FindFirstChild("SoundPart")
                if not sp or not sp:FindFirstChild("PartOwner") then
                    pallet:Destroy()
                    pallet = nil
                end
            end
            
            if not Config.ragdollActive and (not pallet or not pallet:IsDescendantOf(Workspace)) then
                pallet = spawnPallet()
                if pallet then
                    pallet.Name = "RagdollPallet"
                    Config.palletRagdoll = pallet
                end
            end
            
            if pallet and pallet:FindFirstChild("SoundPart") then
                local ragdolled = tHum:FindFirstChild("Ragdolled")
                if ragdolled and not ragdolled.Value then
                    pallet.SoundPart.Position = tRoot.Position
                end
            end
        end)
    end
})

-- ============================================================
-- プレイヤーリスト更新
-- ============================================================
local function updatePlayerList()
    -- ドロップダウン更新（OrionLibの仕様に合わせて）
end

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(plr)
    task.wait(0.2)
    -- 退出したプレイヤーをターゲットから削除
    for i, name in ipairs(Config.PlayerList) do
        if name == plr.Name then
            table.remove(Config.PlayerList, i)
            break
        end
    end
    updatePlayerList()
end)

-- ============================================================
-- 初期化
-- ============================================================
OrionLib:Init()

print("✅ Kick spam (Ragdoll & Lag) ロード完了")