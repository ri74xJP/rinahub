-- 1. WindUIの読み込み
local WindUI = loadstring(game:HttpGet("https://github.com"))()

-- 2. サービスの取得
local workspaceService = cloneref(game:GetService("Workspace"))
local runService = cloneref(game:GetService("RunService"))

-- 3. 状態管理用変数
local SpawnBreakerEnabled = false
local spawnConnection = nil

-- 4. 「SpawnLocation」のコリジョンを破壊するメイン処理
local function breakSpawnCollisions()
    if not SpawnBreakerEnabled then return end

    for _, obj in ipairs(workspaceService:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "SpawnLocation" then
            obj.CanCollide = false
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
    Desc = "SpawnLocation の床や壁の衝突判定を無くします",
    Value = false,
    Callback = function(state)
        SpawnBreakerEnabled = state

        if SpawnBreakerEnabled then
            if not spawnConnection then
                spawnConnection = runService.Stepped:Connect(breakSpawnCollisions)
            end

            WindUI:Notify({
                Title = "Spawn Breaker",
                Content = "SpawnLocationのコリジョンを無効化しました",
                Duration = 2
            })
        else
            if spawnConnection then
                spawnConnection:Disconnect()
                spawnConnection = nil
            end

            WindUI:Notify({
                Title = "Spawn Breaker",
                Content = "無効化されました",
                Duration = 2
            })
        end
    end
})
