local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 5)
local RagdollRemote = CharacterEvents and CharacterEvents:WaitForChild("RagdollRemote", 5)
local ragdollLoopEnabled = false
local ragdollConnection = nil
local jumpDone = false
local antiBlobmanActive = false
local antiBlobmanTask = nil
local originalCFrame = nil

local savedCameraType = nil
local savedCameraSubject = nil
local cameraStateSaved = false

local function enableFreeThirdPersonCamera(humanoid)
    local camera = Workspace.CurrentCamera
    if not camera or not humanoid then return end

    if not cameraStateSaved then
        savedCameraType = camera.CameraType
        savedCameraSubject = camera.CameraSubject
        cameraStateSaved = true
    end

    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
end

local function restoreCameraState()
    if not cameraStateSaved then return end

    local camera = Workspace.CurrentCamera
    if camera then
        camera.CameraType = savedCameraType
        camera.CameraSubject = savedCameraSubject
    end

    savedCameraType = nil
    savedCameraSubject = nil
    cameraStateSaved = false
end

local function startRagdollLoop()
    if ragdollConnection then return end
    ragdollLoopEnabled = true
    jumpDone = false
    
    ragdollConnection = task.spawn(function()
        local startTime = tick()
        while ragdollLoopEnabled do
            local char = Player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and RagdollRemote then
                    pcall(function() RagdollRemote:FireServer(root, 1) end)
                end
                
                if not jumpDone and tick() - startTime >= 0.1 then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        jumpDone = true
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function stopRagdollLoop()
    ragdollLoopEnabled = false
    if ragdollConnection then
        task.cancel(ragdollConnection)
        ragdollConnection = nil
    end
    jumpDone = false
end

local function getInv()
    return Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
end

local function spawnToy(name, cframe)
    local success = pcall(function()
        return ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(name, cframe, Vector3.zero)
    end)
    return success
end

local function getBlobman()
    local folder = getInv()
    return folder and folder:FindFirstChild("CreatureBlobman")
end

local function trySpawnBlobman()
    if getBlobman() then return true end
    local success = spawnToy("CreatureBlobman", CFrame.new(0, 100000, 0))
    if success then
        local blob = getBlobman()
        if blob then
            task.spawn(function()
                for _, part in pairs(blob:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                        part.CFrame = CFrame.new(0, 100000, 0)
                    end
                end
            end)
            return true
        end
    end
    return false
end

local function saveOriginalPosition()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        originalCFrame = char.HumanoidRootPart.CFrame
        return true
    end
    return false
end

local function returnToOriginalPosition()
    if not originalCFrame then return false end
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    char.HumanoidRootPart.CFrame = originalCFrame
    return true
end

local function AntiBlobmanKill()
    while antiBlobmanActive do
        local char = Player.Character
        if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Sit = true
                    hum:ChangeState(Enum.HumanoidStateType.Running)

                    enableFreeThirdPersonCamera(hum)
                end
        end
        task.wait()
    end
end

local function sitOnBlobman()
    local blob = getBlobman()
    if not blob then return end
    
    local seat = blob:FindFirstChild("VehicleSeat")
    if not seat then
        for _, child in pairs(blob:GetChildren()) do
            if child:IsA("VehicleSeat") then seat = child break end
        end
    end
    if not seat then return end
    
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    enableFreeThirdPersonCamera(hum)
    saveOriginalPosition()
    hrp.CFrame = seat.CFrame + Vector3.new(0, 0.5, 0)
    pcall(function() seat:Sit(hum) end)
    
    task.wait(0.01)
    
    antiBlobmanActive = true
    if antiBlobmanTask then task.cancel(antiBlobmanTask) end
    antiBlobmanTask = task.spawn(AntiBlobmanKill)
    
    task.wait(0.5)
    returnToOriginalPosition()
end

local function enableRagdollGucci()
    startRagdollLoop()
    trySpawnBlobman()
    task.wait(0.5)
    sitOnBlobman()
end

local function disableRagdollGucci()
    stopRagdollLoop()
    restoreCameraState()
    antiBlobmanActive = false
    if antiBlobmanTask then task.cancel(antiBlobmanTask) end
    returnToOriginalPosition()
    
    local blob = getBlobman()
    if blob then
        pcall(function() ReplicatedStorage.MenuToys.DestroyToy:FireServer(blob) end)
    end
end
local Window = Library:CreateWindow({
    Title = "POLAR HUB",
    Footer = "JSON Animation Player",
    Icon = 120050296012939,
    NotifySide = "Right",
    ShowCustomCursor = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    CornerRadius = 15
})
local MainTab = Window:AddTab("Main", "target")
local MainGroup = MainTab:AddLeftGroupbox("Control")
local InfoGroup = MainTab:AddRightGroupbox("Info")
local Playing = false
local LoopPlaying = false
local PlayConnection = nil
local AnimationHeartbeatConnection = nil
local AnimationRenderStepName = "POLAR_HUB_JSON_ANIMATION"
local CurrentAnimation = nil
local SelectedFile = ""
local folderName = "Animations"

if not isfolder(folderName) then
    makefolder(folderName)
end

local function getJSONFiles()
    local files = {}
    if not isfolder(folderName) then
        makefolder(folderName)
        return files
    end
    for _, file in ipairs(listfiles(folderName)) do
        if string.match(file, "%.json$") or string.match(file, "%.txt$") then
            local fileName = string.match(file, "[/\\]([^/\\]+)$") or file
            table.insert(files, fileName)
        end
    end
    return files
end
local function loadJSON(fileName)
    if not fileName or fileName == "" then return nil end
    local filePath = folderName .. "\\" .. fileName
    if not isfile(filePath) then
        filePath = folderName .. "/" .. fileName
        if not isfile(filePath) then return nil end
    end
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(filePath))
    end)
    if not ok then return nil end
    return result
end
local function toCFrame(v)
    if typeof(v) ~= "table" or #v < 12 then return nil end
    return CFrame.new(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12])
end
local function getFileInfo(file)
    local anim = loadJSON(file)
    if not anim then return "Invalid file" end
    local frames = anim.frames and #anim.frames or anim.frameCount or 0
    local duration = 0
    if anim.frames and #anim.frames > 0 and anim.frames[#anim.frames].t then
        duration = anim.frames[#anim.frames].t
    end
    return frames .. " frames / " .. string.format("%.2f", duration) .. "s"
end
local function smootherstep(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end
local function playAnimation(isLooping, isFirstPlay)
    if Playing then return end
    
    if isFirstPlay then
        enableRagdollGucci()
        task.wait(0.5)
    end
    if not SelectedFile or SelectedFile == "" then
        Library:Notify({Title = "Error", Description = "No file selected", Duration = 3})
        return
    end
    local Animation = loadJSON(SelectedFile)
    if not Animation or not Animation.frames or #Animation.frames == 0 then
        Library:Notify({Title = "Error", Description = "Invalid or empty animation data", Duration = 3})
        return
    end
    CurrentAnimation = Animation
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not Root then
        Library:Notify({Title = "Error", Description = "Character not found", Duration = 3})
        return
    end
    if Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
        Library:Notify({Title = "Error", Description = "R6 required", Duration = 3})
        return
    end
    enableFreeThirdPersonCamera(Humanoid)
    Playing = true
    local oldAutoRotate = Humanoid.AutoRotate
    local frames = Animation.frames
    local rootRelative = Animation.rootRelative or false
    local BaseRoot = originalCFrame or Root.CFrame
        local partCache = {}
    local previousTargets = {}
    for partName in pairs(frames[1].parts) do

        if partName ~= "HumanoidRootPart" then
            local part = Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                partCache[partName] = part
            end
        end
    end
    local startTime = tick()
    local maxTime = frames[#frames].t or 0
    PlayConnection = true
    RunService:BindToRenderStep(AnimationRenderStepName, Enum.RenderPriority.Character.Value + 1, function()
        if not Playing then
            RunService:UnbindFromRenderStep(AnimationRenderStepName)
            PlayConnection = nil
            return
        end
        enableFreeThirdPersonCamera(Humanoid)

        local elapsed = tick() - startTime
        if elapsed >= maxTime then
            RunService:UnbindFromRenderStep(AnimationRenderStepName)
            PlayConnection = nil
            if AnimationHeartbeatConnection then
                AnimationHeartbeatConnection:Disconnect()
                AnimationHeartbeatConnection = nil
            end
            Humanoid.AutoRotate = oldAutoRotate
            
            if LoopPlaying then
                Playing = false
                playAnimation(true, false)
            else
                Playing = false
                local lastFrame = frames[#frames]
                for partName, part in pairs(partCache) do
                    local data = lastFrame.parts[partName]
                    if data then
                        local cf = toCFrame(data)
                        if cf then
                            part.CFrame = rootRelative and (BaseRoot * cf) or cf
                        end
                    end
                end
                disableRagdollGucci()
                Library:Notify({Title = "Animation", Description = "Finished", Duration = 2})
            end
            return
        end
        local currentIndex = 1
        for i = 1, #frames - 1 do
            if elapsed >= (frames[i].t or 0) and elapsed < (frames[i+1].t or 0) then
                currentIndex = i
                break
            end
        end
        local currentFrame = frames[currentIndex]
        local nextFrame = frames[currentIndex + 1]
        if currentFrame and nextFrame then
            local t1 = currentFrame.t or 0
            local t2 = nextFrame.t or 0
            local duration = t2 - t1
            local alpha = (duration > 0) and ((elapsed - t1) / duration) or 0
            local smoothAlpha = smootherstep(alpha)
            for partName, part in pairs(partCache) do
                local a = currentFrame.parts[partName]
                local b = nextFrame.parts[partName]
                if a and b then
                    local cf1 = toCFrame(a)
                    local cf2 = toCFrame(b)
                    if cf1 and cf2 then
                                                local target = cf1:Lerp(cf2, smoothAlpha)
                        target = rootRelative and (BaseRoot * target) or target

                        local previousTarget = previousTargets[partName]
                        if previousTarget then
                            local delta = previousTarget:ToObjectSpace(target)
                            local _, angle = delta:ToAxisAngle()
                            if delta.Position.Magnitude < 0.002 and angle < math.rad(0.15) then
                                target = previousTarget
                            else
                                target = previousTarget:Lerp(target, 0.50)
                            end
                        end
                        previousTargets[partName] = target
                        part.CFrame = target
                        -- 直接CFrameを更新した後に残る物理速度が、次フレームで
                        -- パーツを押し戻して発生する細かい振動を止める。
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero

                    end
                end
            end
        end
    end)
    -- 物理エンジンがRenderStepの間に位置を上書きしても、
    -- 直前の目標位置へ再同期してプルプルを防ぐ。
    AnimationHeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not Playing then return end
        for partName, part in pairs(partCache) do
            local target = previousTargets[partName]
            if part and part.Parent and target then
                part.CFrame = target
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
        if Root and Root.Parent then
            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end
local function stopAnimation()
    Playing = false
    LoopPlaying = false
    
    disableRagdollGucci()
    if PlayConnection then
        RunService:UnbindFromRenderStep(AnimationRenderStepName)
        PlayConnection = nil
    end
    if AnimationHeartbeatConnection then
        AnimationHeartbeatConnection:Disconnect()
        AnimationHeartbeatConnection = nil
    end
    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.AutoRotate = true
        end
    end
    Library:Notify({Title = "Animation", Description = "Stopped", Duration = 2})
end
local function updateFileList()
    local files = getJSONFiles()
    local options = {}
    for _, file in ipairs(files) do table.insert(options, file) end
    if #options == 0 then table.insert(options, "No files found") end
    return options
end
local fileDropdown = MainGroup:AddDropdown("FileSelect", {
    Text = "Select JSON File",
    Values = updateFileList(),
    Default = updateFileList()[1] or "",
    Callback = function(v)
        SelectedFile = v
        InfoGroup:Clear()
        InfoGroup:AddLabel("File: " .. SelectedFile)
        InfoGroup:AddLabel("Status: " .. getFileInfo(SelectedFile))
    end
})
MainGroup:AddButton({
    Text = "Refresh Files",
    Func = function()
        local newList = updateFileList()
        fileDropdown:SetValues(newList)
        if #newList > 0 then
            fileDropdown:SetValue(newList[1])
            SelectedFile = newList[1]
            InfoGroup:Clear()
            InfoGroup:AddLabel("File: " .. SelectedFile)
            InfoGroup:AddLabel("Status: " .. getFileInfo(SelectedFile))
        end
    end,
    DoubleClick = false
})
MainGroup:AddButton({
    Text = "Play Animation (Once)",
    Func = function() 
        LoopPlaying = false
        playAnimation(false, true) 
    end,
    DoubleClick = false
})
MainGroup:AddToggle("LoopToggle", {
    Text = "Loop Animation",
    Default = false,
    Callback = function(Value)
        LoopPlaying = Value
        if Value and not Playing then
            playAnimation(true, true)
        elseif not Value and Playing then
        end
    end
})
MainGroup:AddButton({
    Text = "Stop Animation",
    Func = function() stopAnimation() end,
    DoubleClick = false
})
local initialFiles = updateFileList()
if #initialFiles > 0 then
    SelectedFile = initialFiles[1]
    InfoGroup:AddLabel("File: " .. SelectedFile)
    InfoGroup:AddLabel("Status: " .. getFileInfo(SelectedFile))
else
    InfoGroup:AddLabel("File: No files found")
    InfoGroup:AddLabel("Status: -")
end
local UISettingsTab = Window:AddTab("UI Settings", "settings")
local MenuGroup = UISettingsTab:AddLeftGroupbox("Menu")
MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value) Library.KeybindFrame.Visible = value end,
})
MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        stopAnimation()
        Library:Unload()
    end,
    DoubleClick = false
})
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("POLAR_HUB_JSONAnim")
SaveManager:SetFolder("POLAR_HUB_JSONAnim")
SaveManager:SetSubFolder("config")
ThemeManager:ApplyToTab(UISettingsTab)
SaveManager:BuildConfigSection(UISettingsTab)
SaveManager:LoadAutoloadConfig()
Library:Notify({Title = "ダンススクリプト", Description = "Direct Interpolation Player Loaded", Duration = 3})
