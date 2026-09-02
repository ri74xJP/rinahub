-- 1. WindUIの読み込み
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- 2. サービスの取得
local workspaceService = cloneref(game:GetService("Workspace"))
local runService = cloneref(game:GetService("RunService"))

-- 3. 状態管理用変数
local SpawnBreakerEnabled = false
local spawnConnection = nil

-- 4. スポーン地点のコリジョンを破壊するメイン処理
local function breakSpawnCollisions()
    if not SpawnBreakerEnabled then return end
    
    -- Workspace内から「Spawn」や「Lobby」という名前の付いたオブジェクトを検索
    for _, obj in ipairs(workspaceService:GetDescendants()) do
        if obj:IsA("BasePart") then
            if string.find(string.lower(obj.Name), "spawn") or string.find(string.lower(obj.Name), "lobby") then
                obj.CanCollide = false
            end
        end
    end
end

-- 5. WindUI ウィンドウとタブの作成
local Window = WindUI:CreateWindow({
    Title = "Fling Utility",
    Icon = "lucide:shield",
    Author = "Player",
    Folder = "FlingGameConfig"
})

local MainTab = Window:Tab({
    Title = "Main Features",
    Icon = "lucide:sliders"
})

-- 6. スポーンコリジョンブレイカーのトグルを追加
MainTab:Toggle({
    Title = "Spawn Collide Breaker",
    Desc = "スポーン地点（ロビーなど）の床や壁の衝突判定を無くします",
    Value = false,
    Callback = function(state)
        SpawnBreakerEnabled = state
        
        if SpawnBreakerEnabled then
            if not spawnConnection then
                spawnConnection = runService.Stepped:Connect(breakSpawnCollisions)
            end
            
            WindUI:Notify({
                Title = "Spawn Breaker",
                Content = "スポーンのコリジョンを無効化しました",
                Duration = 2
            })
        else
            if spawnConnection then
                spawnConnection:Disconnect()
                spawnConnection = nil
            end
            
            WindUI:Notify({
                Title = "Spawn Breaker",
                Content = "無効化されました（元に戻すには再参加が必要な場合があります）",
                Duration = 2
            })
        end
    end
})
