game.Players.LocalPlayer.PlayerScripts.CharacterAndBeamMove.Enabled = false
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/iavichbest/XOCU/refs/heads/main/UI"))()

-- Unlock MouseMouseBehavior = Enum.MouseBehavior.Default

-- Global state storage
local ToggleStates = {}
function SetToggleState(flag, value) ToggleStates[flag] = value end
function GetToggleState(flag) return ToggleStates[flag] or false end

local Options = Library.Items or Library.Flags or {}
local Toggles = Library.Flags or Library.Items or {}
local Window = Library:CreateWindow({
	Title = "XOCU",
	Theme = "Void",
	ToggleKey = Enum.KeyCode.RightShift,
	Transparency = 0.25,
	ShowWatermark = { Enabled = true, Title = true, User = true, FPS = true, Duration = false, Ping = true },
	AutoSave = true,
	ConfigFolder = "XOCU_Config"
})
local Tabs = {
	Defense = Window:CreateTab("defense", true, "7461510456"),
	Target = Window:CreateTab("target", true, "107058246184363"),
	Grab = Window:CreateTab("grab", true, "85607241723723"), -- РќРѕРІР° С–РєРѕРЅРєР° Drag
	Player = Window:CreateTab("player", true, "124871982298256"),
	Misc = Window:CreateTab("misc", true, "114167292947807"), -- РќРѕРІР° С–РєРѕРЅРєР° Sparkles
	Keybinds = Window:CreateTab("keybinds", true, "4814130203"), -- РќРѕРІР° С–РєРѕРЅРєР° BadgeLogo
	Visuals  = Window:CreateTab("visuals",  true, "7733955511"),
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local PS = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local Player = PS.LocalPlayer
local Camera = Workspace.CurrentCamera
local CE = RS:WaitForChild("CharacterEvents", 10)
local BeingHeld = Player:WaitForChild("IsHeld", 10)
local StruggleEvent = CE and CE:WaitForChild("Struggle")
function notify(title, content, duration)
	Library:Notify({ Title = title or "Notification", Content = content or "", Duration = duration or 5,
	 })
end
function sendHubLoadedMessage()
	local message = " Owner Version | XOCU loaded. "
	local sent = false
	pcall(function()
		local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
		if chatEvents then
			local say = chatEvents:FindFirstChild("SayMessageRequest")
			if say and typeof(say.FireServer) == "function" then
				say:FireServer(message, "All")
				sent = true
			end
		end
	end)
	if not sent then
		pcall(function()
			StarterGui:SetCore("ChatMakeSystemMessage", {
				Name = message;
				Color = Color3.fromRGB(255, 170, 0);
				Font = Enum.Font.SourceSansBold;
				FontSize = Enum.FontSize.Size18;
			})
		end)
	end
end
task.spawn(function()
	task.wait(1)
	sendHubLoadedMessage()
end)
local paintPartsBackup = {}
local paintConnections = {}
function deleteAllPaintParts()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
			local clone = obj:Clone()
			clone.Archivable = true
			paintPartsBackup[obj:GetDebugId()] = {
				clone = clone,
				parent = obj.Parent
			}
			obj:Destroy()
		end
	end
end
local function restorePaintParts()
	for _, data in pairs(paintPartsBackup) do
		if data.clone and data.parent then
			data.clone.Parent = data.parent
		end
	end
	paintPartsBackup = {}
end
local function watchNewPaintParts()
	table.insert(paintConnections, Workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
			task.defer(function()
				if obj and obj.Parent then
					local clone = obj:Clone()
					clone.Archivable = true
					paintPartsBackup[obj:GetDebugId()] = {
						clone = clone,
						parent = obj.Parent
					}
					obj:Destroy()
				end
			end)
		end
	end))
end
local function disconnectWatchers()
	for _, conn in ipairs(paintConnections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	paintConnections = {}
end
local function setTouchQuery(state)
	local char = Workspace:FindFirstChild(Player.Name)
	if not char then
		return
	end
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("Part") or v:IsA("BasePart") then
			v.CanTouch = state
			v.CanQuery = state
		end
	end
end
local antiGucciConnection
local safePosition
local restoreFrames = 0
local function spawnBlobman()
	local args = {
		[1] = "CreatureBlobman",
		[2] = CFrame.new(0, 5000000, 0),
		[3] = Vector3.new(0, 60, 0)
	}
	pcall(function()
		ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(unpack(args))
	end)
	local folder = Workspace:WaitForChild(Player.Name .. "SpawnedInToys", 5)
	if folder and folder:FindFirstChild("CreatureBlobman") then
		local blob = folder.CreatureBlobman
		if blob:FindFirstChild("Head") then
			blob.Head.CFrame = CFrame.new(0, 50000, 0)
			blob.Head.Anchored = true
		end
		notify("Success", "Blobman Spawned!", 3)
	end
end
local function startAntiGucci()
	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	safePosition = rootPart.Position
	local folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
	local blob = folder and folder:FindFirstChild("CreatureBlobman")
	local seat = blob and blob:FindFirstChild("VehicleSeat")
	if not blob then
		spawnBlobman()
		task.wait(0.3)
		folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
		blob = folder and folder:FindFirstChild("CreatureBlobman")
		seat = blob and blob:FindFirstChild("VehicleSeat")
	end
	if seat and seat:IsA("VehicleSeat") then
		rootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
		seat:Sit(humanoid)
	end
	humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if humanoid.Jump and humanoid.Sit then
			restoreFrames = 15
			safePosition = rootPart.Position
		end
	end)
	if antiGucciConnection then
		antiGucciConnection:Disconnect()
	end
	antiGucciConnection = R.Heartbeat:Connect(function()
		if not rootPart or not humanoid then
			return
		end
		ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(rootPart, 0)
		if restoreFrames > 0 then
			rootPart.CFrame = CFrame.new(safePosition)
			restoreFrames = restoreFrames - 1
		end
	end)
	task.spawn(function()
		while humanoid.Sit do
			task.wait(1)
		end
		task.wait(0.5)
		rootPart.CFrame = CFrame.new(safePosition)
	end)
end
local function stopAntiGucci()
	if antiGucciConnection then
		antiGucciConnection:Disconnect()
		antiGucciConnection = nil
	end
	-- Unsit humanoid first so the server releases the seat
	local char = Player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then
		hum.Sit = false
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	end
	local blobFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
	if blobFolder and blobFolder:FindFirstChild("CreatureBlobman") then
		local blob = blobFolder.CreatureBlobman
		-- Fire server-side destroy remote so it fully removes server-side
		pcall(function()
			ReplicatedStorage.MenuToys.DestroyToy:FireServer(blob)
		end)
		task.wait(0.1)
		-- Fallback local destroy in case remote didn't work
		if blob and blob.Parent then
			blob:Destroy()
		end
	end
end
local antiGucciConnectionTrain
local safePositionTrain
local restoreFramesTrain = 0
local function startAntiGucciTrain()
	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	safePositionTrain = rootPart.Position
	local folder = workspace.Map.AlwaysHereTweenedObjects
	local train = folder and folder:FindFirstChild("Train")
	local seat
	if train then
		for _, d in ipairs(train:GetDescendants()) do
			if d:IsA("Seat") then
				seat = d
				break
			end
		end
	end
	if seat then
		rootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
		seat:Sit(humanoid)
	end
	humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if humanoid.Jump and humanoid.Sit then
			restoreFramesTrain = 15
			safePositionTrain = rootPart.Position
		end
	end)
	if antiGucciConnectionTrain then
		antiGucciConnectionTrain:Disconnect()
	end
	antiGucciConnectionTrain = R.Heartbeat:Connect(function()
		if not rootPart or not humanoid then
			return
		end
		ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(rootPart, 0)
		if restoreFramesTrain > 0 then
			rootPart.CFrame = CFrame.new(safePositionTrain)
			restoreFramesTrain = restoreFramesTrain - 1
		end
	end)
	task.spawn(function()
		while humanoid.Sit do
			task.wait(1)
		end
		task.wait(0.5)
		rootPart.CFrame = CFrame.new(safePositionTrain)
	end)
end
local function stopAntiGucciTrain()
	if antiGucciConnectionTrain then
		antiGucciConnectionTrain:Disconnect()
		antiGucciConnectionTrain = nil
	end
	local trainFolder = workspace.Map.AlwaysHereTweenedObjects
	if trainFolder and trainFolder:FindFirstChild("Train") then
		ResetPlayer(game.Players.LocalPlayer)
	end
end
local DefenseGroup = Tabs.Defense:CreateBlock({Name = "Defense Main", Side = "Left"})
local DefenseExtra = Tabs.Defense:CreateBlock({Name = "Extra Defense", Side = "Right"})
local antiGrabExplosionConn, antiGrabHeldConn, antiGrabStruggleConn, antiGrabHumConn, antiGrabAnchorConn
local antiGrabRootCF, antiGrabRootPos, antiGrabHardFreeze = nil, nil, false
local function antiGrabUnfreeze(char)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.Anchored = false
		if hrp:FindFirstChild("FreezeJoint") then
			hrp.FreezeJoint:Destroy()
		end
	end
	antiGrabHardFreeze = false
	if antiGrabAnchorConn then
		antiGrabAnchorConn:Disconnect()
		antiGrabAnchorConn = nil
	end
end
local function antiGrabFreezeInPlace(char)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	antiGrabRootCF = hrp.CFrame
	antiGrabRootPos = hrp.Position
	antiGrabHardFreeze = true
	if not hrp:FindFirstChild("FreezeJoint") then
		local align = Instance.new("AlignPosition")
		align.Name = "FreezeJoint"
		align.Mode = Enum.PositionAlignmentMode.OneAttachment
		align.MaxForce = 1e6
		align.MaxVelocity = 0
		align.Responsiveness = 200
		local att = Instance.new("Attachment", hrp)
		align.Attachment0 = att
		align.Position = antiGrabRootPos
		align.Parent = hrp
	end
	antiGrabAnchorConn = R.Heartbeat:Connect(function()
		if antiGrabHardFreeze and hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.CFrame = antiGrabRootCF
		end
	end)
end
local function antiGrabReconnect()
	local char = Player.Character or Player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	local fp = hrp:FindFirstChild("FirePlayerPart")
	if fp then
		fp:Destroy()
	end
	if antiGrabHumConn then
		antiGrabHumConn:Disconnect()
	end
	antiGrabHumConn = hum.Changed:Connect(function(p)
		if p == "Sit" and hum.Sit then
			if not (hum.SeatPart and tostring(hum.SeatPart.Parent) == "CreatureBlobman") then
				hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				hum.Sit = false
			end
		end
	end)
end
local autoStruggleConn = nil
local AntiGrabEnabled = false
local HeldConnection = nil
-- Anti Grab [BETA]
do
    local AntiGrab = false
    local AntiGrabProc = false
    local AGWalk = false
    local Cons = {}
    
    local function DiscAll()
        for k, v in pairs(Cons) do
            if v then v:Disconnect() end
        end
        table.clear(Cons)
    end

    local function ApplyAntiGrab(char)
        if not char or not AntiGrab then return end
        
        -- Use WaitForChild to prevent script breaking if parts haven't loaded yet
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        local head = char:WaitForChild("Head", 5)
        if not (hrp and hum and head) then return end

        -- Initial constraint disabling
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                v.BallSocketConstraint.Enabled = false
                if v:FindFirstChild("RagdollLimbPart") then
                    v.RagdollLimbPart.WeldConstraint.Enabled = false
                end
            end
        end

        Cons["AGHead"] = head.ChildAdded:Connect(function(PartOwner)
            if PartOwner.Name == "PartOwner" then
                if not AntiGrabProc then
                    AntiGrabProc = true
                    hum.Sit = false
                    StruggleEvent:FireServer(Player)
                    
                    task.spawn(function() 
                        while (head and head:FindFirstChild("PartOwner")) or BeingHeld.Value do
                            StruggleEvent:FireServer(Player)
                            ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                            task.wait()
                        end
                    end)
                    
                    hrp.Anchored = true
                    if not AGWalk then
                        AGWalk = true
                        while BeingHeld.Value and task.wait() do
                            hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.43
                        end
                    end
                    hrp.Anchored = false
                    AntiGrabProc = false
                    AGWalk = false
                end
            end
        end)
        
        local ragdolled = hum:WaitForChild("Ragdolled", 5)
        if ragdolled then
            Cons["AGRagdoll"] = ragdolled.Changed:Connect(function()
                if hum.Ragdolled.Value then
                    for _, v in pairs(char:GetChildren()) do
                        if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                            v.BallSocketConstraint.Enabled = false
                            if v:FindFirstChild("RagdollLimbPart") then
                                v.RagdollLimbPart.WeldConstraint.Enabled = false
                            end
                        end
                    end
                end
            end)
        end
        
        local weldHRP = hrp:WaitForChild("WeldHRP", 5)
        if weldHRP then
            Cons["AGWeld"] = weldHRP.Changed:Connect(function()
                if hrp.WeldHRP.Enabled then
                    while not hum.Sit do task.wait() end
                    hum.Sit = false
                    hum.AutoRotate = true
                    hum.HipHeight = 1
                    while hrp.WeldHRP.Enabled and task.wait() do
                        head.CFrame = hrp.CFrame + Vector3.new(0, 1.35, 0)
                    end
                    hum.HipHeight = 0
                end
            end)
        end
    end

    DefenseGroup:CreateToggle({
        Name = "Anti Grab [BEST (use solo)]",
        Flag = "AntiGrab",
        Default = false,
        Callback = function(Value)
            AntiGrab = Value
            DiscAll()
            
            if AntiGrab then
                ApplyAntiGrab(Player.Character)
                Cons["AGChar"] = Player.CharacterAdded:Connect(ApplyAntiGrab)
            else
                local char = Player.Character
                if char then
                    for _, v in pairs(char:GetChildren()) do
                        if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                            v.BallSocketConstraint.Enabled = false
                            if v:FindFirstChild("RagdollLimbPart") then
                                v.RagdollLimbPart.WeldConstraint.Enabled = true
                            end
                        end
                    end
                end
            end
        end
    })
end

-- =========================================================================
-- AntiGrab V3: INTEGRATED & REINFORCED DEFENSE
-- =========================================================================
do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local plr = Players.LocalPlayer
    local Player = plr

    local antiGrabConn = nil
    local AntiGrabEnabled = false 
    local HeldConnection = nil

    local isHeld = plr:WaitForChild("IsHeld", 10)
    local BeingHeld = isHeld
    if not isHeld then return end

    local struggleEvent = ReplicatedStorage:WaitForChild("CharacterEvents", 10)
    if struggleEvent then struggleEvent = struggleEvent:WaitForChild("Struggle", 10) end
    local StruggleEvent = struggleEvent

    -- =====================================================================
    -- MODIFIED LOGIC: REMOVED POSITION SAVING/TELEPORTING
    -- =====================================================================
    local function onHeldChanged(heldState)
        if not AntiGrabEnabled then return end 
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if heldState then
            if hrp then 
                hrp.Anchored = true 
            end
            task.spawn(function()
                while isHeld.Value do 
                    StruggleEvent:FireServer(plr)
                    task.wait() 
                end
                if hrp then 
                    hrp.Anchored = false 
                end
            end)
        else
            if hrp then 
                hrp.Anchored = false 
            end
        end
    end

    antiGrabConn = isHeld.Changed:Connect(onHeldChanged)
    if isHeld.Value then onHeldChanged(true) end

    -- =====================================================================
    -- REINFORCED V3 LOGIC (CLEANED)
    -- =====================================================================
    local function StopAntiGrab()
        AntiGrabEnabled = false
        if HeldConnection then HeldConnection:Disconnect(); HeldConnection = nil end
        local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if Root then Root.Anchored = false end
        
        -- Restore Collision
        for _, part in pairs(Player.Character:GetDescendants()) do 
            if part:IsA("BasePart") then part.CanCollide = true end 
        end
    end

    local function StartAntiGrab()
        if HeldConnection then HeldConnection:Disconnect() end
        HeldConnection = BeingHeld:GetPropertyChangedSignal("Value"):Connect(function()
            if not AntiGrabEnabled or not BeingHeld.Value then return end
            local Char = Player.Character
            if not Char then return end
            
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChildOfClass("Humanoid")

            -- Collision Ghosting
            for _, part in pairs(Char:GetDescendants()) do 
                if part:IsA("BasePart") then part.CanCollide = false end 
            end

            -- LOOP 1: Server Defense
            task.spawn(function()
                while AntiGrabEnabled and BeingHeld.Value do
                    pcall(function()
                        StruggleEvent:FireServer()
                        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(Root, 0)
                        ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                    end)
                    task.wait()
                end
            end)

            -- LOOP 2: Physics State Enforcement
            task.spawn(function()
                while AntiGrabEnabled and BeingHeld.Value do
                    pcall(function()
                        Hum.Sit = false
                        Hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        Hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        if Root then
                            Root.Anchored = true
                            Root.AssemblyLinearVelocity = Vector3.zero
                            Root.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                    task.wait()
                end
                if Root then Root.Anchored = false end
            end)
            
            -- TELEPORTATION REMOVED: 
            -- The RenderStepped connection and MoveDirection loops that 
            -- forced your CFrame back have been deleted.
        end)
    end

    -- UI Integration
    DefenseGroup:CreateToggle({
        Name = "Anti Grab V2 (anti perm die)",
        Flag = "Anti Grab V2 (Full Defense)",
        Default = false,
        Callback = function(Value)
            SetToggleState("Anti Grab V2 (Full Defense)", Value)
            AntiGrabEnabled = Value
            if Value then StartAntiGrab() else StopAntiGrab() end
        end
    })
    
    -- Character Watchdog
    Player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if AntiGrabEnabled and BeingHeld.Value then StartAntiGrab() end
    end)
end

-- Anti Banana [SIT]
do
    local antibananaSit = false

    DefenseGroup:CreateToggle({
        Name = "Anti Banana [SIT]",
        Flag = "AntiBananaSit",
        Default = false,
        Callback = function(Value)
            antibananaSit = Value
            
            -- Running in a dedicated thread to ensure it doesn't yield the UI
            task.spawn(function()
                while antibananaSit do
                    local char = Player.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 then 
                            hum.Sit = true
                            hum:ChangeState(Enum.HumanoidStateType.Running)
                            local Vec = Camera.CFrame.LookVector
                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(Vec.X, 0, Vec.Z))
                        end
                    end
                    task.wait()
                end
            end)
        end
    })
end

-- Anti Ragdoll (On Blob)
do
    local AntiRagBlob = false
    local RagdolledSit = false
    local Cons = {}

    local function ApplyAntiRagdoll(char)
        if not char or not AntiRagBlob then return end
        
        local hum = char:WaitForChild("Humanoid", 5)
        local HRP = char:WaitForChild("HumanoidRootPart", 5)
        if not (hum and HRP) then return end
        
        if Cons["ARSeat"] then Cons["ARSeat"]:Disconnect() end
        Cons["ARSeat"] = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
            if hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name == "CreatureBlobman" and not RagdolledSit then
                RagdolledSit = true
                local Seat = hum.SeatPart
                while not hum.Sit do task.wait() end
                
                ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(HRP, 3)
                
                local ragdolledVal = hum:FindFirstChild("Ragdolled")
                while ragdolledVal and not ragdolledVal.Value and not hum.Sit do task.wait() end
                
                task.wait(0.4)
                hum.Sit = false
                Seat:Sit(hum)
                
                task.delay(0.25, function()
                    while hum and hum.SeatPart do
                        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(HRP, 1)
                        task.wait(0.05)
                    end
                    RagdolledSit = false
                end)
            end
        end)
    end

    DefenseGroup:CreateToggle({
        Name = "Anti Ragdoll (On Blob)",
        Flag = "AntiRagdoll",
        Default = false,
        Callback = function(Value)
            AntiRagBlob = Value
            RagdolledSit = false
            
            if Cons["ARChar"] then Cons["ARChar"]:Disconnect() end
            if Cons["ARSeat"] then Cons["ARSeat"]:Disconnect() end
            
            if AntiRagBlob then
                ApplyAntiRagdoll(Player.Character)
                Cons["ARChar"] = Player.CharacterAdded:Connect(ApplyAntiRagdoll)
            end
        end
    })
end

DefenseGroup:CreateToggle({
    Name = "anti snowball",
    Flag = "LoopRagdoll",
    Default = false,
    Callback = function(Value)
        SetToggleState("LoopRagdoll", Value)
        loopRagdoll = Value
        
        if Value then
            task.spawn(function()
                while loopRagdoll and task.wait(0.05) do
                    pcall(function()
                        local char = Player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 0.5)
                        end
                    end)
                end
            end)
        end
    end
})
antiblob = false
antiblobConnection = nil
truePosPart = nil

DefenseGroup:CreateToggle({
    Name = "Auto Reset",
        Flag = "Auto Reset",
    Default = false,
    Callback = function(v)
        SetToggleState("Auto Reset", Value)
        -- Clear old connection
        if _G.AutoResetCon then _G.AutoResetCon:Disconnect() end

        if v then
            _G.AutoResetCon = game:GetService("ReplicatedStorage").GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(r)
                if r == "Flying" then
                    local char = game:GetService("Players").LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if hum then
                        Library:Notify("Resetting to prevent Ban", 4)
                        -- Break Joint/Health is more reliable for "Defense" than ChangeState
                        char:BreakJoints() 
                        hum.Health = 0
                    end
                end
            end)
        end
    end
})
DefenseGroup:CreateToggle({
    Name = "Auto Leave ",
    Flag = "Auto Leave",
    Default = false,
    Callback = function(v)
        SetToggleState("Auto Leave", v)
        
        -- Clear old connection to prevent memory leaks or duplicate firing
        if _G.AutoLeaveCon then _G.AutoLeaveCon:Disconnect() end

        if v then
            local warnTimestamps = {} -- Table to track when warnings happen

            _G.AutoLeaveCon = game:GetService("ReplicatedStorage").GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(r)
                if r == "Flying" then
                    local currentTime = os.clock()
                    table.insert(warnTimestamps, currentTime)

                    -- Clean up timestamps that are older than 1 second
                    for i = #warnTimestamps, 1, -1 do
                        if currentTime - warnTimestamps[i] > 1 then
                            table.remove(warnTimestamps, i)
                        end
                    end

                    -- If 3 or more warnings happened in the last second, auto-leave
                    if #warnTimestamps >= 3 then
                        game:GetService("Players").LocalPlayer:Kick("XOCU Safety: Disconnected to prevent ban.")
                    end
                end
            end)
        end
    end
})
DefenseGroup:CreateToggle({
    Name = "Anti Void",
    Flag = "Anti Void",
    Default = false,
    Callback = function(v)
        SetToggleState("Anti Void", Value)
        if v then
            workspace.FallenPartsDestroyHeight = 0/0
        else
            workspace.FallenPartsDestroyHeight = -100
        end
    end
})

antiblob = false

DefenseGroup:CreateToggle({
    Name = "Anti Blob",
    Flag = "AntiBlobKick",
    Default = false,
    Callback = function(Value)
        antiblob = Value
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local workspace = game:GetService("Workspace")

        if antiblob and player.Character then
            if not player.Character:FindFirstChild("TruePositionPart") then
                local truePosPart = Instance.new("Part")
                truePosPart.Parent = player.Character
                truePosPart.Name = "TruePositionPart"
                truePosPart.Anchored = true
                truePosPart.Transparency = 0.8
                truePosPart.CanCollide = false
                truePosPart.Size = Vector3.new(0.1, 0.1, 0.1)
                truePosPart.CFrame = CFrame.new(0, -10000000, 0)
            end
        end

        -- Placed inside task.spawn so the while loop doesn't yield/freeze your UI
        task.spawn(function()
            while antiblob and task.wait() do
                if player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local truePosPart = player.Character:FindFirstChild("TruePositionPart")
                    
                    if hrp and truePosPart then
                        -- Reparent RootAttachment
                        local rootAttachment = hrp:FindFirstChild("RootAttachment")
                        if rootAttachment and rootAttachment.Parent == hrp then 
                            rootAttachment.Parent = truePosPart 
                        end
                        
                        local isGrabbed = false
                        
                        -- Check for massless parts (usually indicates you are grabbed)
                        for _, part in pairs(player.Character:GetChildren()) do
                            if part:IsA("Part") and part.Massless then
                                part.Massless = false
                                isGrabbed = true
                            end
                        end

                        -- If grabbed, apply velocity and fire remote events
                        if isGrabbed then
                            
                            -- [ADDED VELOCITY HERE]
                            -- Applies a massive upward force to break the blob's physics weld/grip.
                            -- You can change these numbers if it flings you too high or not enough.
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 15000000, 0) 

                            -- Helper function to fire the drop remotes to avoid repeating code
                            local function fireDrop(item)
                                local blobScript = item:FindFirstChild("BlobmanSeatAndOwnerScript")
                                local rightDetector = item:FindFirstChild("RightDetector")
                                local leftDetector = item:FindFirstChild("LeftDetector")

                                if blobScript and rightDetector and leftDetector then
                                    local dropEvent = blobScript:FindFirstChild("CreatureDrop")
                                    local rightWeld = rightDetector:FindFirstChild("RightWeld")
                                    local leftWeld = leftDetector:FindFirstChild("LeftWeld")
                                    
                                    if dropEvent then
                                        if rightWeld then dropEvent:FireServer(rightWeld, hrp) end
                                        if leftWeld then dropEvent:FireServer(leftWeld, hrp) end
                                    end
                                    
                                    if replicatedStorage:FindFirstChild("CharacterEvents") then
                                        local struggleEvent = replicatedStorage.CharacterEvents:FindFirstChild("Struggle")
                                        if struggleEvent then struggleEvent:FireServer(player) end
                                    end
                                end
                            end

                            -- Check Plot Items
                            for _, plot in pairs(workspace.PlotItems:GetChildren()) do
                                if plot.Name ~= "PlayersInPlots" then
                                    for _, item in pairs(plot:GetChildren()) do
                                        if item.Name == "CreatureBlobman" then
                                            fireDrop(item)
                                        end
                                    end
                                end
                            end

                            -- Check Spawned Toys
                            for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                                local toyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                                if toyFolder then
                                    for _, item in pairs(toyFolder:GetChildren()) do
                                        if item.Name == "CreatureBlobman" then
                                            fireDrop(item)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)

        -- Cleanup when turned off
        if not antiblob and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local truePosPart = player.Character:FindFirstChild("TruePositionPart")
            if hrp and truePosPart then
                local rootAttachment = truePosPart:FindFirstChild("RootAttachment")
                if rootAttachment then rootAttachment.Parent = hrp end
                truePosPart:Destroy()
            end
        end
    end,
})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Fix 1: Pull helper functions OUTSIDE the callback to prevent memory leaks
local function OAA_getCharacter(player)
    return player.Character
end

local function OAA_getHumanoidRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function OAA_getHumanoid(character)
    return character and character:FindFirstChild("Humanoid")
end

local function OAA_getDistance(part1, part2)
    return (part1.Position - part2.Position).Magnitude
end

local function OAA_setNetworkOwner(part, cframe)
    task.spawn(function()
        -- Use FindFirstChild/WaitForChild safely
        local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
        if grabEvents then
            local setNetworkOwnerRemote = grabEvents:FindFirstChild("SetNetworkOwner")
            if setNetworkOwnerRemote then
                setNetworkOwnerRemote:FireServer(part, cframe)
            end
        end
    end)
end

-- Fix 2: Prevent DescendantAdded from stacking multiple connections
local antiBlob1T = false
local blobConnection = nil

local function antiBlob1F()
    antiBlob1T = true
    if not blobConnection then
        blobConnection = workspace.DescendantAdded:Connect(function(toy)
            if toy.Name == "CreatureBlobman" and antiBlob1T then
                -- Wait for child prevents errors if the detectors haven't loaded the exact microsecond the model spawns
                local leftDetector = toy:WaitForChild("LeftDetector", 3)
                local rightDetector = toy:WaitForChild("RightDetector", 3)
                
                if leftDetector then leftDetector:Destroy() end
                if rightDetector then rightDetector:Destroy() end
            end
        end)
    end
end

-- Fix 3: Use a connection variable to cleanly start/stop the Aura loop
local auraConnection = nil

DefenseGroup:CreateToggle({
    Name = "Anti-Blobman Aura",
    Flag = "Anti-Blobman Aura",
    Default = false,
    Callback = function(enabled)
        -- Fix 4: Changed 'Value' to 'enabled'
        if SetToggleState then
            SetToggleState("Anti-Blobman Aura", enabled)
        end

        if enabled then
            -- Clean up old loop just in case
            if auraConnection then auraConnection:Disconnect() end
            
            -- Use Heartbeat for smooth, constant checking without freezing the UI thread
            auraConnection = RunService.Heartbeat:Connect(function()
                local myCharacter = OAA_getCharacter(LocalPlayer)
                local myRootPart = OAA_getHumanoidRootPart(myCharacter)

                if not myRootPart then return end -- Skip if we are dead/respawning

                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local playerCharacter = OAA_getCharacter(player)
                        local playerRootPart = OAA_getHumanoidRootPart(playerCharacter)
                        local playerHumanoid = OAA_getHumanoid(playerCharacter)

                        if playerRootPart and playerHumanoid and playerHumanoid.SeatPart then
                            local seatParent = playerHumanoid.SeatPart.Parent
                            
                            -- Check if riding Blobman and within range
                            if seatParent and seatParent.Name == "CreatureBlobman" then
                                if OAA_getDistance(playerRootPart, myRootPart) <= 19 then
                                    OAA_setNetworkOwner(playerRootPart, playerRootPart.CFrame)
                                end
                            end
                        end
                    end
                end
            end)
        else
            -- Disconnect the loop cleanly when toggled off
            if auraConnection then
                auraConnection:Disconnect()
                auraConnection = nil
            end
        end
    end,
})
local antiExplodeT = false
local function antiExplodeF()
	antiExplodeT = true
	local char = Player.Character
	if not char then
		return
	end
	local hrp = char:WaitForChild("HumanoidRootPart")
	workspace.ChildAdded:Connect(function(model)
		if model.Name == "Part" and antiExplodeT then
			local mag = (model.Position - hrp.Position).Magnitude
			if mag <= 20 then
				hrp.Anchored = true
				wait(0.01)
				while char["Right Arm"].RagdollLimbPart.CanCollide do
					wait(0.001)
				end
				hrp.Anchored = false
			end
		end
	end)
end
DefenseGroup:CreateToggle({
	Name = "Anti Explosion",
        Flag = "Anti Explosion", 
	Default = false,
	Callback = function(on)
        SetToggleState("Anti Explosion", on)
		if on then
			antiExplodeF()
		else
			antiExplodeT = false
		end
	end
})
local hookBurnConn
local function hookBurn(char)
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	char.PrimaryPart = hrp
	if hookBurnConn then
		hookBurnConn:Disconnect()
	end
	hookBurnConn = hum.FireDebounce.Changed:Connect(function(isBurning)
		if isBurning then
			local me = char
			local oldCF = hrp.CFrame
			local plots = workspace:FindFirstChild("Plots")
			if plots and plots:FindFirstChild("Plot2") then
				local plot2 = plots.Plot2
				local barrier = plot2:FindFirstChild("Barrier")
				local pb = barrier and barrier:FindFirstChild("PlotBarrier")
				if pb and pb:IsA("BasePart") then
					local safeCF = pb.CFrame * CFrame.new(0, 6, 0)
					me:SetPrimaryPartCFrame(safeCF)
					task.wait(0.3)
					local firePart = me:FindFirstChild("FirePlayerPart", true)
					if firePart then
						for _, obj in ipairs(firePart:GetChildren()) do
							if obj:IsA("Sound") then
								obj:Stop()
							end
							if obj:IsA("Light") or obj:IsA("ParticleEmitter") then
								obj.Enabled = false
							end
						end
						if firePart:FindFirstChild("CanBurn") then
							firePart.CanBurn.Value = false
						end
						if hum:FindFirstChild("FireDebounce") then
							hum.FireDebounce.Value = false
						end
					end
					task.wait(0.6)
					if me and me.PrimaryPart then
						me:SetPrimaryPartCFrame(oldCF)
					end
				end
			end
		end
	end)
end
DefenseGroup:CreateToggle({
	Name = "Anti Burn",
        Flag = "Anti Burn",
	Default = false,
	Callback = function(on)
        SetToggleState("Anti Burn", on)
		if on then
			hookBurn(Player.Character)
		elseif hookBurnConn then
			hookBurnConn:Disconnect()
		end
	end
})

local antiStickyT = false
DefenseGroup:CreateToggle({
	Name = "Anti Sticky",
        Flag = "Anti Sticky",
	Default = false,
	Callback = function(Value)
        SetToggleState("Anti Sticky", Value)
		antiStickyT = Value
		if Player.PlayerScripts:FindFirstChild("StickyPartsTouchDetection") then
			Player.PlayerScripts.StickyPartsTouchDetection.Disabled = Value
		end
	end,
})
local createGrabLineCopy, extendGrabLineCopy
local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
if grabFolder then
	local originalCreate = grabFolder:FindFirstChild("CreateGrabLine")
	local originalExtend = grabFolder:FindFirstChild("ExtendGrabLine")
	if originalCreate then
		createGrabLineCopy = originalCreate:Clone()
	end
	if originalExtend then
		extendGrabLineCopy = originalExtend:Clone()
	end
end
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
if not _G.cons then _G.cons = {} end 

DefenseGroup:CreateToggle({
    Name = "Anti Loop Kill",
        Flag = "Anti Loop Kill",
    Default = false,
    Callback = function(v)
        SetToggleState("Anti Loop Kill", Value)
        if _G.cons["antiloopkill"] then 
            _G.cons["antiloopkill"]:Disconnect() 
            _G.cons["antiloopkill"] = nil 
        end

        if v then
            _G.cons["antiloopkill"] = plr.CharacterAdded:Connect(function(char)
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp then
                    -- Р–РґРµРј Р±СѓРєРІР°Р»СЊРЅРѕ РѕРґРёРЅ РєР°РґСЂ РїРµСЂРµРґ С‚РµР»РµРїРѕСЂС‚РѕРј
                    RunService.RenderStepped:Wait()
                    
                    local target = CFrame.new(524.703979, 93.7120056, -375.040985)
                    hrp.CFrame = target
                    
                    -- Р‘С‹СЃС‚СЂР°СЏ РїРѕРґСЃС‚СЂР°С…РѕРІРєР° РЅР° СЃР»РµРґСѓСЋС‰РёРµ 2 РєР°РґСЂР°
                    for i = 1, 2 do
                        RunService.RenderStepped:Wait()
                        hrp.CFrame = target
                    end
                end
            end)
        end
    end
})

DefenseGroup:CreateToggle({
	Name = "Anti Lag",
        Flag = "Anti Lag",
	Default = false,
	Callback = function(Value)
        SetToggleState("Anti Lag", Value)
		if Value then
			local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
            -- ... (original deletion logic) ...
		else
			-- ... (original restoration logic) ...
		end
	end,
})

local PCLD_Auto_Active = false

DefenseGroup:CreateToggle({
    Name = "Auto PCLD Break",
    Flag = "AutoPCLDBreakSmart",
    Default = false,
    Callback = function(Value)
        SetToggleState("AutoPCLDBreakSmart", Value)
        PCLD_Auto_Active = Value
        
        if Value then
            task.spawn(function()
                local plr = game:GetService("Players").LocalPlayer
                local isFirstCycle = true
                
                while PCLD_Auto_Active do
                    -- 1. Get current character and wait if it's dead
                    local char = plr.Character or plr.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart", 5)
                    local hum = char:WaitForChild("Humanoid", 5)
                    
                    if not hrp or not hum then 
                        task.wait(0.5)
                        continue 
                    end

                    if hum.Health <= 0 then
                        char = plr.CharacterAdded:Wait()
                        hrp = char:WaitForChild("HumanoidRootPart", 5)
                        hum = char:WaitForChild("Humanoid", 5)
                    end
                    
                    if not hrp or not hum then continue end

                    if isFirstCycle then
                        -- ==========================================
                        -- INITIAL BREAK: Teleport High & Double Kill
                        -- ==========================================
                        local savedCFrame = hrp.CFrame
                        
                        -- Kill 1: Teleport high
                        hrp.CFrame = CFrame.new(hrp.Position.X, 50000, hrp.Position.Z)
                        task.wait(0.05)
                        hum.Health = 0

                        -- Wait for respawn
                        char = plr.CharacterAdded:Wait()
                        if not PCLD_Auto_Active then break end
                        
                        hrp = char:WaitForChild("HumanoidRootPart", 5)
                        hum = char:WaitForChild("Humanoid", 5)
                        
                        -- Kill 2: Teleport back
                        if hrp and hum then
                            task.wait(0.1)
                            hrp.CFrame = savedCFrame
                            task.wait(0.05)
                            hum.Health = 0
                        end
                        
                        isFirstCycle = false
                    else
                        -- ==========================================
                        -- NEXT TIMES: Kill 1 time on respawn
                        -- ==========================================
                        task.wait(0.1) -- Small buffer so the spawn fully registers
                        if hum then
                            hum.Health = 0
                            pcall(function() char:BreakJoints() end)
                        end
                    end

                    -- ==========================================
                    -- WAIT FOR PLAYABLE RESPAWN & NATURAL DEATH
                    -- ==========================================
                    char = plr.CharacterAdded:Wait()
                    if not PCLD_Auto_Active then break end
                    
                    hum = char:WaitForChild("Humanoid", 5)

                    if hum then
                        -- Pauses the loop here while you play. 
                        -- Once you die naturally, the loop restarts and executes the 1-time kill.
                        hum.Died:Wait()
                    end
                end
            end)
        end
    end
})
local AutoDeleteLegsActive = false
local DeleteLegsConnection = nil

local function PerformLegDeletion(char)
    -- Wait a brief moment to ensure the character is fully loaded
    task.wait(0.5) 
    
    if not AutoDeleteLegsActive then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    local torso = char:FindFirstChild("Torso")
    local ll = char:FindFirstChild("Left Leg")
    local rl = char:FindFirstChild("Right Leg")
    
    if hrp and hum and torso and ll and rl then
        local void = workspace.FallenPartsDestroyHeight
        local pos = torso.CFrame
        
        workspace.FallenPartsDestroyHeight = -100
        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 2)
        task.wait(0.5)
        
        if ll and rl then
            rl.CFrame = CFrame.new(0, -10000, 0)
            ll.CFrame = CFrame.new(0, -10000, 0)
        end
        
        task.wait(0.3)
        if torso then torso.CFrame = CFrame.new(0, -9970, 0) end
        
        task.wait(0.5)
        if torso then torso.CFrame = pos end
        
        task.wait(0.5)
        workspace.FallenPartsDestroyHeight = void
        
        -- Safe HipHeight adjustment loop
        task.spawn(function()
            while AutoDeleteLegsActive and char.Parent and hum.Health > 0 and not char:FindFirstChild("Left Leg") and not char:FindFirstChild("Right Leg") do
                pcall(function()
                    local controls = Player.PlayerGui:FindFirstChild("ControlsGui")
                    if controls and controls:FindFirstChild("PCFrame") and controls.PCFrame:FindFirstChild("Stand") then
                        if controls.PCFrame.Stand.Visible == false then
                            hum.HipHeight = 2
                        else
                            hum.HipHeight = 0
                        end
                    end
                end)
                task.wait()
            end
        end)
    end
end

DefenseGroup:CreateToggle({
    Name = "Auto Delete Legs",
    Flag = "Auto Delete Legs",
    Default = false,
    Callback = function(Value)
        SetToggleState("Auto Delete Legs", Value)
        AutoDeleteLegsActive = Value
        
        if Value then
            -- 1. Execute on the current character
            task.spawn(function()
                PerformLegDeletion(Player.Character)
            end)
            
            -- 2. Execute automatically upon respawn
            if not DeleteLegsConnection then
                DeleteLegsConnection = Player.CharacterAdded:Connect(function(newChar)
                    if AutoDeleteLegsActive then
                        task.spawn(function()
                            PerformLegDeletion(newChar)
                        end)
                    end
                end)
            end
        else
            -- Clean up the connection if toggled off
            if DeleteLegsConnection then
                DeleteLegsConnection:Disconnect()
                DeleteLegsConnection = nil
            end
            
            -- Reverting requires resetting to get your legs back
            local char = Player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and (not char:FindFirstChild("Left Leg") or not char:FindFirstChild("Right Leg")) then
                Library:Notify({ Title = "System", Content = "Legs cannot be restored locally. Reset your character.", Duration = 4 })
            end
        end
    end
})
DefenseExtra:CreateToggle({
	Name = "Anti Paint",
        Flag = "Anti Paint",
	Default = false,
	Callback = function(state)
        SetToggleState("Anti Paint", state)
		if state then
			deleteAllPaintParts()
			watchNewPaintParts()
			setTouchQuery(false)
		else
			restorePaintParts()
			disconnectWatchers()
			setTouchQuery(true)
		end
	end
})
-- =========================================================================
-- PLATFORM TP (Adapted for Script 6)
-- =========================================================================
local platformTPToggle = false
local platformTPActive = false
local platformPart = nil
local oldPlatformPos = nil

local function SetupPlatform()
    if not platformPart then
        platformPart = Instance.new("Part", workspace)
        platformPart.Name = "SkyBase"
        platformPart.Anchored = true
        platformPart.Size = Vector3.new(1500, 2, 1500)
        platformPart.CFrame = CFrame.new(0, 1000000, 0)
        workspace.FallenPartsDestroyHeight = -9999999
    end
end

DefenseExtra:CreateToggle({
    Name = "Enable Platform TP",
    Flag = "PlatformTPToggle",
    Default = false,
    Callback = function(Value)
        SetToggleState("PlatformTPToggle", Value)
        platformTPToggle = Value
        if Value then
            SetupPlatform()
        else
            platformTPActive = false
        end
    end
})

DefenseExtra:CreateKeybind({
    Name = "Platform TP Execute",
    Flag = "PlatformTPKey",
    Default = "X",
    Callback = function()
        if not platformTPToggle then return end
        
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        platformTPActive = not platformTPActive

        if platformTPActive then
            oldPlatformPos = root.CFrame
            root.CFrame = platformPart.CFrame + Vector3.new(0, 5, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        else
            if oldPlatformPos then
                root.CFrame = oldPlatformPos
            end
        end
    end
})
-- =========================================================================
-- GUCCI BINDER (Adapted for Script 6)
-- =========================================================================
local gucciRunId = 0

local function FWC(Parent, Name, Time) 
    return Parent:FindFirstChild(Name) or Parent:WaitForChild(Name, Time or 3) 
end

local function grab(prt) 
    RS.GrabEvents.SetNetworkOwner:FireServer(prt, prt.CFrame) 
end

local function toy_spawn_gucci(name, cframe, vector)
    local ToySpawn = RS.MenuToys.SpawnToyRemoteFunction
    local InPlot, InOwnerPlot, CanSpawn = Player.InPlot, Player.InOwnedPlot, Player.CanSpawnToy

    while InPlot.Value and not InOwnerPlot.Value and not CanSpawn.Value do
        task.wait(0.01)
    end

    task.spawn(function()
        ToySpawn:InvokeServer(name, cframe, vector or Vector3.new())
    end)
    
    local BackPack = workspace:FindFirstChild(Player.Name .. 'SpawnedInToys')
    local SpawnedToy
    BackPack.ChildAdded:Once(function(toy)
        if toy.Name == name and toy:IsA("Model") then
            SpawnedToy = toy
        end
    end)
    
    local time = tick()
    while not SpawnedToy do
        if tick()-time < 2 then
            task.wait(0.01)
        else
            return false
        end
    end
    return SpawnedToy
end

local function GucciAntiGrab()
    gucciRunId = gucciRunId + 1
    local MyId = gucciRunId
    
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = FWC(char, "Humanoid")
    
    hum.Sit = true
    task.wait(0.02)
    hum.Sit = false
    task.wait(0.02)
    
    task.spawn(function()
        local time = tick()
        while tick()-time < 0.8 do
            for _,v in pairs(char:GetChildren()) do
                if v:IsA('BasePart') then
                    v.Velocity = Vector3.new()
                end
            end
            task.wait(0.01)
        end
    end)
    
    local autoGucciT, sitJumpT, Blob, BHead = true, false, nil, nil
    
    task.spawn(function()
        while not Blob and MyId == gucciRunId do
            task.wait(0.01)
        end
        if MyId ~= gucciRunId then return end
        
        BHead = FWC(Blob, "Head")
        local HitBox = FWC(Blob, "GrabbableHitbox")
        
        while MyId == gucciRunId and BHead and
        (not BHead:FindFirstChild("PartOwner") or BHead.PartOwner.Value ~= Player.Name) do
            grab(HitBox)
            task.wait(0.01)
        end
    end)
    
    local hrp = FWC(char, "HumanoidRootPart")
    Blob = toy_spawn_gucci(
        "CreatureBlobman",
        hrp.CFrame * CFrame.new(0, 0, -5),
        Vector3.new(0, -15.716, 0)
    )
    
    if not Blob then return end
    
    local Seat = FWC(Blob, "VehicleSeat")
    
    task.defer(function()
        if not(char or hum) then return end
        
        local startTime = tick()
        while autoGucciT and MyId == gucciRunId and tick()-startTime < 0.3 do
            if Blob and Blob.Parent then
                if Seat and Seat.Parent and Seat.Occupant ~= hum then
                    Seat:Sit(hum)
                end
            end
            task.wait(0.03)
            if char and hum and hum.Parent then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            task.wait(0.03)
        end
        autoGucciT = false
        sitJumpT = false
    end)
    
    sitJumpT = true
    
    task.defer(function()
        while sitJumpT and MyId == gucciRunId do
            if char and hrp and hrp.Parent then
                RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0.095)
            end
            task.wait(0.01)
        end
    end)
    
    local index
    task.wait(0.4)
    if MyId ~= gucciRunId then return end
    
    hum.Sit = false
    Blob.Name = "Gucci"
    
    local BackPack = workspace:FindFirstChild(Player.Name .. 'SpawnedInToys')
    for i,v in pairs(BackPack:GetChildren()) do
        if v.Name == "Gucci" then
            index = i
            break
        end
    end
    
    for _,v in pairs(Blob:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.CanTouch = false
            v.CanQuery = false
        end
    end
    
    task.defer(function()
        while MyId == gucciRunId and Blob and BHead do
            BHead.CFrame = CFrame.new(BHead.Position.X, 1e5, BHead.Position.Z)
            task.wait(0.01)
        end
    end)
    
    local success, contents = pcall(function()
        return Player.PlayerGui.MenuGui.Menu.TabContents.ToyDestroy.Contents
    end)
    
    if success and contents and index then
        for i,v in ipairs(contents:GetChildren()) do
            if v.Name == "CreatureBlobman" and i == index then
                local view = v.ViewItemButton
                view.Text = "GUCCI"
                view.TextScaled = true
                view.LowResImage.Image = ""
            end
        end
    end
end

DefenseExtra:CreateKeybind({
    Name = "Gucci Binder",
    Flag = "GucciBinderKey",
    Default = "J",
    Callback = function()
        GucciAntiGrab()
    end
})

do
    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    local LocalPlayer = Players.LocalPlayer

    -- State Configuration
    local Type1 = {
        systemOn = false,
        autoRespawnEnabled = false,
        currentSeat = nil,
        ragdollConnection = nil,
        sitConnection = nil,
        characterAddedConnection = nil, -- Tracks the character respawn listener
        Remotes = { ragdoll = nil, spawn = nil, destroy = nil }
    }

    -- Cache Remote Events & Functions
    local function Type1_CacheRemotes()
        if not Type1.Remotes.ragdoll then
            local charEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 5)
            if charEvents then
                Type1.Remotes.ragdoll = charEvents:FindFirstChild("RagdollRemote")
            end
        end
        if not Type1.Remotes.spawn or not Type1.Remotes.destroy then
            local menuToys = ReplicatedStorage:WaitForChild("MenuToys", 5)
            if menuToys then
                Type1.Remotes.spawn = menuToys:WaitForChild("SpawnToyRemoteFunction", 5)
                Type1.Remotes.destroy = menuToys:FindFirstChild("DestroyToy")
            end
        end
    end

    -- Ragdoll Fire Event Loop
    local function Type1_StartRagdollSpam(rootPart)
        if Type1.ragdollConnection then Type1.ragdollConnection:Disconnect() end
        if not Type1.Remotes.ragdoll then return end
        
        Type1.ragdollConnection = RunService.Heartbeat:Connect(function()
            if not Type1.systemOn or not rootPart then return end
            pcall(function() Type1.Remotes.ragdoll:FireServer(rootPart, 2) end)
        end)
    end

    -- Seat Placement Loop
    local function Type1_StartSitSpam(humanoid, seat)
        if Type1.sitConnection then Type1.sitConnection:Disconnect() end
        
        Type1.sitConnection = RunService.Heartbeat:Connect(function()
            if not Type1.systemOn or not seat or not seat.Parent then return end
            seat:Sit(humanoid)
        end)
    end

    -- Clean Legacy Spawned Blobmen
    local function Type1_CleanUpOldToys()
        if not Type1.Remotes.destroy then return end
        local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if not folder then return end
        for _, toy in pairs(folder:GetChildren()) do
            if toy.Name == "CreatureBlobman" then
                pcall(function() Type1.Remotes.destroy:FireServer(toy) end)
            end
        end
    end

    -- Main Gucci Engine Sequence
    local function Type1_RunStableGucci()
        if Type1.systemOn then return end
        
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid", 3)
        local root = char:WaitForChild("HumanoidRootPart", 3)
        
        if not (hum and root) then 
            Type1.systemOn = false
            return 
        end
        
        Type1.systemOn = true
        Type1_CleanUpOldToys()
        
        local savedCFrame = root.CFrame
        
        local spawnCFrame = CFrame.new(103.85, -7.45, -538.58)
        task.spawn(function()
            if Type1.Remotes.spawn then
                Type1.Remotes.spawn:InvokeServer("CreatureBlobman", spawnCFrame, Vector3.zero)
            end
        end)
        
        local blobman = nil
        local folder = Workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 5)
        if not folder then
            Type1.systemOn = false
            return
        end
        
        local startTick = tick()
        while not blobman and tick() - startTick < 3 do
            local target = folder:FindFirstChild("CreatureBlobman")
            if target then blobman = target break end
            RunService.Heartbeat:Wait()
        end
        
        if not blobman then
            Type1.systemOn = false
            return
        end
        
        local head = blobman:FindFirstChild("Head")
        if head then head.Anchored = true end
        
        local seat = blobman:WaitForChild("VehicleSeat", 2)
        if not seat then Type1.systemOn = false return end
        Type1.currentSeat = seat
        
        Type1_StartRagdollSpam(root)
        
        root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        seat:Sit(hum)
        
        Type1_StartSitSpam(hum, seat)
        
        task.wait(0.6)
        
        hum.Sit = false
        hum.PlatformStand = true
        
        if seat then 
            seat.Disabled = true 
            pcall(function() seat:Destroy() end)
        end
        
        if blobman then
            for _, v in pairs(blobman:GetDescendants()) do
                if v:IsA("Weld") or v:IsA("Snap") then v:Destroy() end
            end
        end
        
        root.CFrame = savedCFrame
        root.Velocity = Vector3.zero
        hum.PlatformStand = false
        
        task.wait(0.5)
        
        if Type1.sitConnection then Type1.sitConnection:Disconnect() Type1.sitConnection = nil end
        if Type1.ragdollConnection then Type1.ragdollConnection:Disconnect() Type1.ragdollConnection = nil end
        
        task.wait(0.5)
        
        Type1.systemOn = false
        
        Library:Notify({ Title = "Anti Gucci", Description = "Blob Man Gucci (Automatic) 완료!", Time = 2 })
    end

    -- Stop System Execution
    local function Type1_StopSystem()
        Type1.systemOn = false
        Type1.autoRespawnEnabled = false
        Type1.currentSeat = nil
        if Type1.ragdollConnection then Type1.ragdollConnection:Disconnect() Type1.ragdollConnection = nil end
        if Type1.sitConnection then Type1.sitConnection:Disconnect() Type1.sitConnection = nil end
    end

    -- Connect Character Death Handler
    local function Type1_ConnectDeathEvent(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        hum.Died:Connect(function()
            if Type1.autoRespawnEnabled then
                Type1.systemOn = false
                Type1_CleanUpOldToys()
            end
        end)
    end

    -- Initialize Remote Caching
    Type1_CacheRemotes()

    -- Create Toggle Interface
    DefenseExtra:CreateToggle({
        Name = "Anti Gucci (Blobman)",
        Flag = "Anti Gucci (Blobman)",
        Default = false,
        Callback = function(Value)
            if Value then
                -- System Active
                Type1.autoRespawnEnabled = true
                
                if LocalPlayer.Character then
                    Type1_ConnectDeathEvent(LocalPlayer.Character)
                end
                
                task.spawn(Type1_RunStableGucci)
                
                -- Setup persistent looping upon respawning
                if not Type1.characterAddedConnection then
                    Type1.characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                        if Type1.autoRespawnEnabled then
                            Type1_ConnectDeathEvent(newChar)
                            task.wait(1) 
                            task.spawn(Type1_RunStableGucci)
                        end
                    end)
                end
            else
                -- System Deactivated
                Type1_StopSystem()
                Type1_CleanUpOldToys()
                
                if Type1.characterAddedConnection then
                    Type1.characterAddedConnection:Disconnect()
                    Type1.characterAddedConnection = nil
                end
            end
        end
    })
end
DefenseExtra:CreateToggle({
    Name = "Gucci(Invisible)",
    Flag = "Gucci(Invisible)",
    Default = false,
    Callback = function(v)
        SetToggleState("Gucci(Invisible)", Value)
        if v then
            local blobb
			local plr = game.Players.LocalPlayer
			local HRP = plr.Character:WaitForChild("HumanoidRootPart")
            pcall(function()
                local pal, pal2
                pal2 = plr.PlayerGui.MenuGui.Menu.TabContents.ToyDestroy.Contents.ChildAdded:Connect(function(c)
                    if c.Name == "TractorGreen" then
                        pal = c
                        task.wait()
                        pal2:Disconnect()
                        pal2 = nil
                    end
                end)
                spawn(function()
                    task.wait(1)
					if pal and pal:FindFirstChild("ViewItemButton") then
						local mess = pal.ViewItemButton:FindFirstChild("NewMessage")
						if mess then
							local clonedMess = mess:Clone()
							clonedMess.Name = "Gucci2"
							clonedMess.TextColor3 = Color3.fromRGB(255, 255, 255)
							clonedMess.Name = "Anti Gucci"
							clonedMess.Visible = true
							clonedMess.Parent = pal.ViewItemButton
						end
					end
                end)
            end)
            local RS_gucci = game:GetService("ReplicatedStorage")
            local RunService_gucci = game:GetService("RunService")
            -- Save player's real position before anything
            local savedGucciCF = HRP.CFrame
            -- Spawn tractor in sky
            RS_gucci.MenuToys.SpawnToyRemoteFunction:InvokeServer("TractorGreen", CFrame.new(0, 50000, 0), Vector3.new())
            local inv = workspace:WaitForChild(plr.Name .. "SpawnedInToys")
			blobb = inv:WaitForChild("TractorGreen", 3)
			if blobb then
				blobb.Name = "tractorgucci"
				local humanoid = plr.Character:WaitForChild("Humanoid")
				local seat = blobb:WaitForChild("VehicleSeat", 3)
				if seat then
					-- Teleport player to seat in sky to register sit
					seat.CFrame = CFrame.new(0, 50000, 0)
					HRP.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
					task.wait(0.05)
					seat:Sit(humanoid)
					-- Fire RagdollRemote a few times to register sit
					for _ = 1, 10 do
						RS_gucci.CharacterEvents.RagdollRemote:FireServer(HRP, 0)
						task.wait()
					end
					-- Wait until seated
					local t0 = tick()
					while seat.Occupant ~= humanoid and tick() - t0 < 3 do
						HRP.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
						seat:Sit(humanoid)
						task.wait()
					end
					-- Teleport player back to real position now that sit is registered
					HRP.CFrame = savedGucciCF
					-- Continuous Heartbeat loop: keep seat in sky, keep player at real position
					if getgenv().gucciInvisConn then getgenv().gucciInvisConn:Disconnect() end
					getgenv().gucciInvisConn = RunService_gucci.Heartbeat:Connect(function()
						if not HRP or not HRP.Parent then return end
						RS_gucci.CharacterEvents.RagdollRemote:FireServer(HRP, 0)
						-- Keep seat anchored in sky (invisible)
						if seat and seat.Parent then
							seat.CFrame = CFrame.new(0, 50000, 0)
						end
						-- Lock player back to real position so they don't drift to sky
						if humanoid and humanoid.Sit then
							HRP.CFrame = savedGucciCF
						end
					end)
				end
			end
        else
			-- Stop the Heartbeat loop first
			if getgenv().gucciInvisConn then
				getgenv().gucciInvisConn:Disconnect()
				getgenv().gucciInvisConn = nil
			end
			local plr = game.Players.LocalPlayer
			local RS = game:GetService("ReplicatedStorage")
			local DestroyToy = RS.MenuToys.DestroyToy

			-- Step 1: Force-unseat the humanoid FIRST so server allows destroy
			local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if hum then
				hum.Sit = false
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				task.wait(0.1)
			end

			-- Step 2: Destroy by known renamed name
			local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
			if inv then
				local toy = inv:FindFirstChild("tractorgucci") or inv:FindFirstChild("TractorGreen")
				if toy then
					pcall(function() DestroyToy:FireServer(toy) end)
					task.wait(0.1)
					-- If still exists, fire again
					if toy and toy.Parent then
						pcall(function() DestroyToy:FireServer(toy) end)
					end
					task.wait(0.05)
					-- Last resort: destroy locally
					if toy and toy.Parent then
						pcall(function() toy:Destroy() end)
					end
				end
			end
			-- Step 3: Final unsit cleanup in case still seated
			if hum then
				for i = 1, 10 do
					hum.Sit = false
					task.wait()
				end
			end
        end
    end
})
do
    local autoGucciEnabled = false
    local autoGucciConn = nil
    local autoGucciSpamTask = nil
    local autoGucciDestroyConn = nil

    local function cleanupGucciTasks()
        if autoGucciSpamTask then
            task.cancel(autoGucciSpamTask)
            autoGucciSpamTask = nil
        end
        if autoGucciDestroyConn then
            autoGucciDestroyConn:Disconnect()
            autoGucciDestroyConn = nil
        end
    end

    -- Native toy spawner replacing the missing 'SpawnToy' function
    local function SpawnGucciToy(toyName, hrp)
        local inv = workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
        if not inv then return nil end
        
        local spawnCF = hrp.CFrame * CFrame.new(0, 14, 20)
        task.spawn(function()
            pcall(function()
                RS.MenuToys.SpawnToyRemoteFunction:InvokeServer(toyName, spawnCF, Vector3.zero)
            end)
        end)

        local t = tick()
        local spawnedToy = nil
        repeat
            task.wait(0.1)
            spawnedToy = inv:FindFirstChild(toyName)
        until spawnedToy or (tick() - t > 3)
        
        return spawnedToy
    end

    DefenseExtra:CreateToggle({
        Name = "auto Gucci(Invisible)",
        Flag = "AutoGucci",
        Default = false,
        Callback = function(Value)
            SetToggleState("AutoGucci", Value)
            autoGucciEnabled = Value
            
            if Value then
                local GucciThing = nil
                local isActive = false
                
                local function gucci()
                    if not autoGucciEnabled then return end
                    isActive = true
                    
                    local char = Player.Character
                    if not char then isActive = false return end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChild("Humanoid")
                    local head = char:FindFirstChild("Head")
                    local inv = workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
                    
                    if not (hrp and hum and head and inv) then isActive = false return end

                    cleanupGucciTasks()
                    
                    -- Clear out any existing instances to prevent clutter
                    for _, v in pairs(inv:GetChildren()) do
                        if v.Name == "AutoGucci" or v.Name == "TractorGreen" then
                            pcall(function() RS.MenuToys.DestroyToy:FireServer(v) end)
                        end
                    end
                    
                    -- Wait for ragdoll or being held to finish
                    local ragdolled = hum:FindFirstChild("Ragdolled")
                    while (ragdolled and ragdolled.Value) or BeingHeld.Value do 
                        task.wait() 
                    end
                    
                    -- Force unsit
                    for _ = 1, 100 do hum.Sit = true end
                    task.wait(0.1)
                    hum.Sit = false
                    
                    -- Spawn the tractor
                    GucciThing = SpawnGucciToy("TractorGreen", hrp)
                    while not GucciThing and autoGucciEnabled do
                        task.wait(0.25)
                        GucciThing = SpawnGucciToy("TractorGreen", hrp)
                    end
                    
                    if not GucciThing then isActive = false return end
                    GucciThing.Name = "AutoGucci"
                    
                    local seat = GucciThing:WaitForChild("VehicleSeat", 3)
                    if not seat then isActive = false return end
                    
                    -- Anti-grab spam loop
                    autoGucciSpamTask = task.spawn(function()
                        local endTime = tick() + 0.5
                        while tick() < endTime and task.wait() and isActive do
                            pcall(function() RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0) end)
                        end
                    end)
                    
                    -- Ensure the player sits on it
                    local lastSitAttempt = 0
                    while not (hum.SeatPart or BeingHeld.Value) and autoGucciEnabled do
                        if tick() - lastSitAttempt > 0.1 then
                            seat:Sit(hum)
                            lastSitAttempt = tick()
                        end
                        task.wait()
                    end
                    
                    hum.Sit = false
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hrp.Anchored = true
                    
                    -- Banish the toy to the shadow realm (skybox)
                    task.spawn(function()
                        repeat task.wait() until not seat:FindFirstChild("SeatWeld")
                        GucciThing:PivotTo(CFrame.new(0, 1e6, 0))
                        local bodyPos = Instance.new("BodyPosition")
                        bodyPos.Position = Vector3.new(0, 1e6, 0)
                        bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyPos.Parent = GucciThing.PrimaryPart
                    end)
                    
                    hrp.Anchored = false
                    autoGucciDestroyConn = GucciThing.Destroying:Once(function()
                        if autoGucciEnabled then gucci() end
                    end)
                    
                    isActive = false
                end
                
                -- Initial execution
                gucci()
                
                -- Constant watchdog loop
                if autoGucciConn then autoGucciConn:Disconnect() end
                autoGucciConn = RunService.Heartbeat:Connect(function()
                    if not autoGucciEnabled then 
                        if autoGucciConn then autoGucciConn:Disconnect() end
                        return 
                    end
                    if isActive then return end
                    
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    -- Respawn handler
                    if not (hrp and hum) or hum.Health <= 0 then
                        isActive = true
                        local newChar = Player.CharacterAdded:Wait()
                        task.wait(0.5)
                        gucci()
                        return
                    end
                    
                    -- Failsafe: Re-execute if network ownership is stolen, grabbed, or sat anomalously
                    local isNetworkOwner = true
                    pcall(function() isNetworkOwner = isnetworkowner(hrp) end)
                    
                    if (not hrp.Anchored and not isNetworkOwner) or BeingHeld.Value or hum.Sit then
                        gucci()
                    end
                end)
                
            else
                -- Complete cleanup when toggled off
                cleanupGucciTasks()
                
                if autoGucciConn then
                    autoGucciConn:Disconnect()
                    autoGucciConn = nil
                end
                
                local inv = workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
                if inv then
                    for _, v in pairs(inv:GetChildren()) do
                        if v.Name == "AutoGucci" or v.Name == "TractorGreen" then
                            pcall(function() RS.MenuToys.DestroyToy:FireServer(v) end)
                        end
                    end
                end
            end
        end
    })
end
local autoGucciActiveTrain =  false
DefenseExtra:CreateToggle({
	Name = "Anti Gucci (Train)",
        Flag = "Anti Gucci (Train)",
	Default = false,
	Callback = function(Value)
        SetToggleState("Anti Gucci (Train)", Value)
		autoGucciActiveTrain = Value
		if Value then
			startAntiGucciTrain()
			notify("system", "Gucci active (monitoring)", 3)
			task.spawn(function()
				while autoGucciActiveTrain do
					local trainFolder = workspace.Map.AlwaysHereTweenedObjects
					local trainExists = trainFolder and trainFolder:FindFirstChild("Train")
					if not trainExists then
						stopAntiGucciTrain()
						notify("System", "Train lost", 3)
						local retries = 0
						repeat
							task.wait(0.2)
							retries = retries + 1
							trainFolder = workspace.Map.AlwaysHereTweenedObjects
						until (trainFolder and trainFolder:FindFirstChild("Train")) or retries > 25 or not autoGucciActiveTrain
						if autoGucciActiveTrain and trainFolder and trainFolder:FindFirstChild("Train") then
							startAntiGucciTrain()
							notify("System", "Train restored.", 3)
						end
					end
					task.wait(0.5)
				end
			end)
		else
			autoGucciActiveTrain = false
			stopAntiGucciTrain()
			notify("System", "Gucci disabled.", 3)
		end
	end
})
DefenseExtra:CreateButton({
    Name = "Delete Legs",
        Flag = "Delete Legs",
    Callback = function()
        local char = Player.Character
        if not char then return end
        if char:FindFirstChild("Left Leg") and char:FindFirstChild("Right Leg") then
            local ll = char:FindFirstChild("Left Leg")
            local rl = char:FindFirstChild("Right Leg")
            local void = workspace.FallenPartsDestroyHeight
            local pos = char.Torso.CFrame
            workspace.FallenPartsDestroyHeight = -100
            ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(char.HumanoidRootPart, 2)
            task.wait(0.5)
            rl.CFrame = CFrame.new(0, -10000, 0)
            ll.CFrame = CFrame.new(0, -10000, 0)
            task.wait(0.3)
            char.Torso.CFrame = CFrame.new(0, -9970, 0)
            task.wait(0.5)
            char.Torso.CFrame = pos
            task.wait(0.5)
            workspace.FallenPartsDestroyHeight = void
            task.spawn(function()
                if not char:FindFirstChild("Left Leg") and not char:FindFirstChild("Right Leg") then
                    while task.wait() do
                        if Player.PlayerGui.ControlsGui.PCFrame.Stand.Visible == false then
                            char.Humanoid.HipHeight = 2
                        else
                            char.Humanoid.HipHeight = 0
                        end
                    end
                end
            end)
        end
    end
})
-- =========================================================================
-- INPUT LAG SETTINGS
-- =========================================================================
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
    ["Banjo"] = "InstrumentGuitarBanjo",
    ["Violin"] = "InstrumentGuitarViolin",
    ["Ukulele"] = "InstrumentGuitarUkulele",
    ["Sax"] = "InstrumentWoodwindSaxophone",
    ["Vuvuzela"] = "InstrumentBrassVuvuzela",
    ["Bongos"] = "InstrumentDrumBongos",
    ["Mic"] = "InstrumentVoiceMicrophone",
    ["Pepperoni"] = "FoodPizzaPepperoni",
    ["Piano"] = "InstrumentPianoMelodica",
    ["Bread"] = "FoodBread",
    ["Egg"] = "FoodDippyEgg",
    ["Mayo"] = "FoodMayonnaise",
    ["WhiteMug"] = "CupMugWhite",
    ["Ocarina"] = "InstrumentWoodwindOcarina",
    ["SparklePoop"] = "PoopPileSparkle",
    ["BrownMug"] = "CupMugBrown",
    ["Trumpet"] = "InstrumentBrassTrumpet",
    ["Snare"] = "InstrumentDrumSnare",
    ["Lyre"] = "InstrumentGuitarLyre",
}

local DropdownValues = {}
for shortName, _ in pairs(ToyList) do
    table.insert(DropdownValues, shortName)
end
table.sort(DropdownValues)

-- Auto-selects "Burger" by default ("FoodHamburger")
local SelectedToy = ToyList["Burger"] or ToyList[DropdownValues[1]]

DefenseExtra:CreateDropdown({
    Name = "Select Input Lag Toy",
    Flag = "InputLagToyDropdown",
    Items = DropdownValues,
    Default = "Burger", -- Auto selection set to Burger
    Callback = function(Value)
        SelectedToy = ToyList[Value]
    end
})

DefenseExtra:CreateToggle({
    Name = "Anti-Input",
    Flag = "InstantInputLag",
    Default = false,
    Callback = function(Value)
        SetToggleState("InstantInputLag", Value)
        _G.InstantLagActive = Value

        if Value then
            task.spawn(function()
                local plr = game.Players.LocalPlayer
                local RS = game:GetService("ReplicatedStorage")
                local SpawnRemote = RS:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")

                local HoldDuration = 0.02
                local CycleSpeed = 0.02

                while _G.InstantLagActive do
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        local toysFolder = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
                        local name = SelectedToy 
                        local item = toysFolder and toysFolder:FindFirstChild(name)

                        -- Safe Shuriken custom collisions handler
                        for _, obj in pairs(workspace:GetChildren()) do
                            if obj.Name == "Shuriken" and obj:IsA("Model") then
                                for _, part in pairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then 
                                        part.CanCollide = false 
                                        part.Massless = true 
                                    end
                                end
                            end
                        end

                        if not item or not item.Parent then
                            task.spawn(function()
                                pcall(function()
                                    SpawnRemote:InvokeServer(name, hrp.CFrame * CFrame.new(0, -12, 0), Vector3.zero)
                                end)
                            end)
                            task.wait(0.1)
                        else
                            local holdPart = item:FindFirstChild("HoldPart")
                            if holdPart then
                                for _, v in pairs(item:GetDescendants()) do
                                    if v:IsA("BasePart") then 
                                        v.CanCollide = false 
                                        v.Massless = true 
                                    end
                                end

                                task.spawn(function()
                                    pcall(function()
                                        holdPart.HoldItemRemoteFunction:InvokeServer(item, char)
                                    end)
                                end)

                                task.wait(HoldDuration) 

                                task.spawn(function()
                                    pcall(function()
                                        holdPart.DropItemRemoteFunction:InvokeServer(
                                            item, 
                                            CFrame.new(0, 5000, 0), 
                                            Vector3.zero
                                        )
                                    end)
                                end)
                            end
                        end
                    end
                    task.wait(CycleSpeed) 
                end
            end)
        end
    end
})
do
    -- Services & Local Variables
    local Players = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local plr = Players.LocalPlayer

    -- State
    local AntiKickItemActive = false
    local MyPCLD = nil
    local pcldConn = nil
    local ToyList = {
        ["Japanese Lantern"] = "JapaneseLantern",
        ["Spray Can"]        = "SprayCanWD",
        ["Spooky Candle"]    = "SpookyCandle1",
    }

    local DropdownValues = {}
    for shortName, _ in pairs(ToyList) do
        table.insert(DropdownValues, shortName)
    end
    table.sort(DropdownValues)

    local SelectedToy = ToyList["Spooky Candle"] or ToyList[DropdownValues[1]]

    DefenseExtra:CreateDropdown({
        Name = "anti kick item",
        Flag = "Input Lag Item",
        Items = DropdownValues,
        Default = "Spooky Candle", 
        Callback = function(Value)
            SelectedToy = ToyList[Value]
        end
    })

    -- =========================================================================
    -- HELPER FUNCTIONS FOR ANTI-KICK ITEM
    -- =========================================================================
    local function GetMagnitude(Part1, Part2)
        return (Part1.Position - Part2.Position).Magnitude
    end

    local function FWD(parent, part, timeOffset)
        return parent:FindFirstChild(part) or parent:WaitForChild(part, timeOffset or 1)
    end

    local function CFP(parent, part)
        return parent:FindFirstChild(part) ~= nil  
    end

    local function CheckNetworkOwnerOnPart(Part) 
        local po = Part:FindFirstChild("PartOwner")
        return po and po.Value == plr.Name
    end

    local function sno(part)
        pcall(function()
            local grabEvents = RS:FindFirstChild("GrabEvents")
            local setNetOwner = grabEvents and grabEvents:FindFirstChild("SetNetworkOwner")
            if setNetOwner then
                setNetOwner:FireServer(part, part.CFrame)
            end
        end)
    end

    local function CheckForHome()
        local plotItems = workspace:FindFirstChild("PlotItems")
        local plots = workspace:FindFirstChild("Plots")
        
        if plots and plotItems then
            for i = 1, 5 do 
                local Plot = plots:FindFirstChild("Plot"..i)
                if Plot then
                    local sign = Plot:FindFirstChild("PlotSign")
                    local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
                    if owners then
                        for _,v in pairs(owners:GetChildren()) do 
                            if v.Value == plr.Name then 
                                return plotItems:FindFirstChild("Plot"..i)
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local function SpawnToy(ToyName)
        local InPlot = plr:FindFirstChild("InPlot")
        local InOwnedPlot = plr:FindFirstChild("InOwnedPlot")
        local CanSpawnToy = plr:FindFirstChild("CanSpawnToy")
        local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")

        if InPlot and InPlot.Value and InOwnedPlot and not InOwnedPlot.Value then 
            InPlot:GetPropertyChangedSignal("Value"):Wait()
        end 
        if CanSpawnToy and not CanSpawnToy.Value then 
            CanSpawnToy:GetPropertyChangedSignal("Value"):Wait()
        end

        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end

        local SpawnCF = (MyPCLD or hrp).CFrame * CFrame.new(0, 14, 20)
        local Container = (InOwnedPlot and InOwnedPlot.Value) and CheckForHome() or inv
        if not Container then return nil end

        local spawnedObject = nil
        local connection
        connection = Container.ChildAdded:Connect(function(child)
            if child.Name == ToyName then
                spawnedObject = child
            end
        end)

        task.spawn(function()
            pcall(function()
                local menuToys = RS:FindFirstChild("MenuToys")
                local spawnRemote = menuToys and menuToys:FindFirstChild("SpawnToyRemoteFunction")
                if spawnRemote then
                    spawnRemote:InvokeServer(ToyName, SpawnCF, Vector3.zero)
                end
            end)
        end)

        local start = tick()
        repeat task.wait() until spawnedObject or (tick() - start) > 2.5

        if connection then connection:Disconnect() end
        return spawnedObject
    end

    local function FindPCLD(hrp)
        if pcldConn then pcldConn:Disconnect() end
        MyPCLD = nil
        pcldConn = RunService.Heartbeat:Connect(function()
            if MyPCLD or not hrp or not hrp.Parent then 
                if pcldConn then pcldConn:Disconnect() pcldConn = nil end
                return
            end
            for _, v in pairs(workspace:GetChildren()) do 
                if v.Name == "PlayerCharacterLocationDetector" and v:IsA("BasePart") then
                    if GetMagnitude(v, hrp) <= 2 then 
                        MyPCLD = v
                        break
                    end
                end
            end
        end)
    end

    -- =========================================================================
    -- ANTI-KICK ITEM TOGGLE
    -- =========================================================================
    DefenseExtra:CreateToggle({
        Name = "Anti Kick [ITEM]",
        Flag = "AntiKickItemFlag",
        Default = false,
        Callback = function(Val)
            if SetToggleState then SetToggleState("AntiKickItemFlag", Val) end
            AntiKickItemActive = Val 
            
            if Val then
                task.spawn(function()
                    local Item, SoundPart
                    while AntiKickItemActive and task.wait() do 
                        local char = plr.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChild("Humanoid")
                        local inPlot = plr:FindFirstChild("InPlot")
                        local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
                        local destroyToy = RS:FindFirstChild("MenuToys") and RS.MenuToys:FindFirstChild("DestroyToy")
                        
                        -- Safety Checks
                        if not hrp or not hum or hum.Health <= 0 or not inv then continue end  
                        if inPlot and inPlot.Value then continue end 
                        
                        -- Initiate PCLD Tracking if needed
                        if not MyPCLD and not pcldConn then
                            FindPCLD(hrp)
                        end

                        Item = inv:FindFirstChild("AntiKickItem") 
                        SoundPart = Item and Item:FindFirstChild("Hitbox")
                        
                        -- Spawning Logic
                        if not Item or not SoundPart then
                            for _,v in pairs(inv:GetChildren()) do 
                                if v.Name == "AntiKickItem" then 
                                    pcall(function() destroyToy:FireServer(v) end)
                                end
                            end
                            
                            Item = SpawnToy(SelectedToy)
                            if not Item then continue end 
                            
                            SoundPart = Item and FWD(Item, "Hitbox", 0.5)
                            if SoundPart then sno(SoundPart) end
                            
                            for _,v in pairs(Item:GetChildren()) do 
                                if v:IsA("BasePart") then 
                                    v.CanCollide = false 
                                    v.Transparency = 0.8
                                    v.Color = Color3.fromRGB(0, 255, 255) -- Makes the item Cyan
                                end
                            end
                            
                            Item.Name = "AntiKickItem"
                        end
                        
                        -- Ownership Maintenance
                        if SoundPart and not CheckNetworkOwnerOnPart(SoundPart) then 
                            sno(SoundPart)
                        end
                        
                        -- Server-Synced Movement Logic
                        local targetPart = MyPCLD or hrp:FindFirstChild("FirePlayerPart") or hrp
                        if SoundPart and targetPart then
                            SoundPart.CFrame = targetPart.CFrame
                            SoundPart.AssemblyLinearVelocity = Vector3.zero
                            SoundPart.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end)
            else
                -- Cleanup when toggled off
                if pcldConn then pcldConn:Disconnect() pcldConn = nil end
                MyPCLD = nil
                
                task.spawn(function()
                    local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
                    local destroyToy = RS:FindFirstChild("MenuToys") and RS.MenuToys:FindFirstChild("DestroyToy")
                    if inv and destroyToy then
                        for _,v in pairs(inv:GetChildren()) do 
                            if v.Name == "AntiKickItem" then 
                                pcall(function() destroyToy:FireServer(v) end)
                            end
                        end
                    end
                end)
            end
        end
    })

    -- Watchdog to reset PCLD tracker when character dies/respawns
    plr.CharacterAdded:Connect(function(char)
        if AntiKickItemActive then
            MyPCLD = nil
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then FindPCLD(hrp) end
        end
    end)
end

-- =========================================================================
-- SHURIKEN ANTI KICK (Adapted for Script 6)
-- =========================================================================
DefenseExtra:CreateToggle({
    Name = "Anti Kick",
    Flag = "ShurikenAntiKick",
    Default = false,
    Callback = function(Value)
        SetToggleState("ShurikenAntiKick", Value)
        _G.ShurikenAntiKick = Value
        
        local function ClearKunai()
            local inv = workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
            local destroyrem = RS:FindFirstChild("MenuToys") and RS.MenuToys:FindFirstChild("DestroyToy")
            if inv and destroyrem then
                for _, v in pairs(inv:GetChildren()) do
                    if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                        pcall(function() destroyrem:FireServer(v) end)
                    end
                end
            end
        end

        if Value then
            task.spawn(function()
                local setOwner = RS:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
                local stickyEvent = RS:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
                local spawnRemote = RS:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
                local canSpawn = Player:WaitForChild("CanSpawnToy")

                local function getHRP()
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        return Player.Character.HumanoidRootPart
                    else
                        return Player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
                    end
                end

                local function CheckForHome()
                    if not workspace.PlotItems.PlayersInPlots:FindFirstChild(Player.Name) then return false end
                    for _, v in pairs(workspace.Plots:GetChildren()) do
                        local sign = v:FindFirstChild("PlotSign")
                        local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
                        if owners then
                            for _, b in pairs(owners:GetChildren()) do
                                if b.Value == Player.Name then
                                    local folder = workspace.PlotItems:FindFirstChild(v.Name)
                                    if folder then return true, folder end
                                end
                            end
                        end
                    end
                    return false
                end

                local function StickKunai(kunai)
                    if not kunai or not kunai:FindFirstChild("StickyPart") then return end
                    local currentHRP = getHRP()
                    if not currentHRP then return end
                    
                    if kunai:FindFirstChild("SoundPart") then
                        if not kunai.SoundPart:FindFirstChild("PartOwner") or kunai.SoundPart.PartOwner.Value ~= Player.Name then 
                            setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame)
                        end
                    end
                    
                    local firePart = currentHRP:FindFirstChild("FirePlayerPart") or currentHRP:WaitForChild("FirePlayerPart", 5)
                    if firePart then
                        stickyEvent:FireServer(kunai.StickyPart, firePart, CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(90),math.rad(90)))
                    end
                    
                    for _, obj in pairs(kunai:GetChildren()) do
                        if obj.Name == "Pyramid" then
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                            if not obj:FindFirstChild("Highlight") then
                                local high = Instance.new("Highlight", obj)
                                high.FillColor = Color3.fromRGB(0, 0, 0)
                            end
                        elseif obj.Name == "Main" then
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                            if not obj:FindFirstChild("Highlight") then
                                local high = Instance.new("Highlight", obj)
                                high.FillColor = Color3.fromRGB(255, 255, 255)
                            end
                        elseif obj:IsA("BasePart") then
                            obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 1
                        end
                    end
                end

                local function SpawnToy(name)
                    local t = tick()
                    while not canSpawn.Value do
                        if not _G.ShurikenAntiKick or tick() - t > 5 then return nil end
                        task.wait(0.1)
                    end
                    local currentHRP = getHRP()
                    if currentHRP then
                        task.spawn(function()
                            pcall(function()
                                spawnRemote:InvokeServer(name, currentHRP.CFrame * CFrame.new(0, 12, 20), Vector3.new(0,0,0))
                            end)
                        end)
                    end
                    local boolik, house = CheckForHome()
                    local inv = workspace:FindFirstChild(Player.Name.."SpawnedInToys")
                    if boolik and house then 
                        return house:WaitForChild(name, 2)
                    elseif not workspace.PlotItems.PlayersInPlots:FindFirstChild(Player.Name) and inv then 
                        return inv:WaitForChild(name, 2)
                    end
                    return nil
                end

                while _G.ShurikenAntiKick do 
                    task.wait(0.005)
                    if not Player.Character or not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then 
                        continue 
                    end
                    
                    local inv = workspace:FindFirstChild(Player.Name.."SpawnedInToys")
                    local kunai = inv and inv:FindFirstChild("NinjaShuriken")
                    
                    if workspace.PlotItems.PlayersInPlots:FindFirstChild(Player.Name) then 
                        local boolik, house = CheckForHome()
                        if boolik and house and workspace.Plots:FindFirstChild(house.Name) then
                            local sign = workspace.Plots[house.Name]:FindFirstChild("PlotSign")
                            if sign and sign.ThisPlotsOwners.Value.TimeRemainingNum.Value > 89 then 
                                kunai = SpawnToy("NinjaShuriken")
                                if kunai == nil then continue end
                                kunai.Name = "AntiKick" 
                                StickKunai(kunai)
                            end
                        end
                    end
                    
                    if not kunai then
                        if workspace.PlotItems.PlayersInPlots:FindFirstChild(Player.Name) then continue end 
                        kunai = SpawnToy("NinjaShuriken")
                        if kunai == nil then continue end 
                        kunai.Name = "AntiKick"
                        if not kunai then continue end 
                    end
                    
                    repeat
                        if kunai and kunai:FindFirstChild("StickyPart") and kunai.StickyPart.CanTouch == true then
                            StickKunai(kunai)
                            kunai.Name = "AntiKick"
                        end
                        task.wait(0.3)
                    until not kunai or not _G.ShurikenAntiKick or not kunai:FindFirstChild("StickyPart") or kunai.StickyPart.CanTouch == false 
                        or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") 
                        or not kunai:FindFirstChild("StickyPart") 
                        or (Player.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20
                        
                    if not kunai or not kunai:FindFirstChild("StickyPart") or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or (Player.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20 then 
                        ClearKunai()
                    end 
                    
                    pcall(function()
                        repeat task.wait(0.05) until not _G.ShurikenAntiKick or not Player.Character or not Player.Character:FindFirstChild("Humanoid") or not kunai or not kunai:FindFirstChild("StickyPart") or not kunai.StickyPart:FindFirstChild("StickyWeld") or not kunai.StickyPart.StickyWeld.Part1
                        if not kunai or not kunai:FindFirstChild("StickyPart") or (Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health <= 0) or not kunai["StickyPart"]:FindFirstChild("StickyWeld").Part1 then 
                            ClearKunai()
                        end
                    end)
                end
                ClearKunai()
            end)
        else
            _G.ShurikenAntiKick = false
            ClearKunai()
        end
    end
})

Player.CharacterAdded:Connect(function()
    if _G.ShurikenAntiKick then
        task.wait(1)
    end
end)

-- AUTO-RESPAWN LOGIC: Re-runs the script loop when you die and respawn
plr.CharacterAdded:Connect(function()
    if _G.ShurikenAntiKick then
        task.wait(1) -- Wait for character to load properly
        -- The loop in the toggle will naturally pick up the new HRP
    end
end)
DefenseExtra:CreateToggle({
	Name = "Loop TP",
        Flag = "Loop TP",
	Default = false,
	Callback = function(Value)
        SetToggleState("Loop TP", Value)
		tpActive = Value
		local char = Player.Character or Player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if Value then
			if hum then
				hum.PlatformStand = true
			end
			task.spawn(function()
				while tpActive and hrp do
					local x = math.random(-500, 500)
					local y = math.random(30, 480)
					local z = math.random(-500, 500)
					hrp.CFrame = CFrame.new(x, y, z)
					task.wait(0.03)
				end
			end)
		else
			if hum then
				hum.PlatformStand = false
			end
		end
	end,
})
local PS = game:GetService("Players")
local Player = PS.LocalPlayer

-- Variables to store state
local selectedKickPlayer = nil
local kickLoopEnabled = false
local kickLoopConnection = nil
local savedKickPos = nil
local currentKickTargetChar = nil

-- // Helper Functions \ --

-- Formats the list as "Display Name (@Username)"
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(PS:GetPlayers()) do
        if plr ~= Player then
            table.insert(list, plr.DisplayName .. " (@" .. plr.Name .. ")")
        end
    end
    return list
end

-- Extracts the username from the "Display Name (@Username)" string
local function getPlayerFromSelection(selection)
    if not selection or selection == "" then return nil end
    local username = selection:match("@(.-)%)")
    if username then
        return PS:FindFirstChild(username)
    end
    return nil
end

-- // UI Setup \ --

-- Assuming 'Tabs' is defined in your main script setup
local TargetGroup = Tabs.Target:CreateBlock({Name = "Target Interaction", Side = "Left"})
local BlobGroup = Tabs.Target:CreateBlock({Name = "Blobman Kick", Side = "Right"})
local TelekinesisGroup = Tabs.Target:CreateBlock({Name = "Telekinesis", Side = "Right"})


local vu390 = {
    localPlayer = game:GetService("Players").LocalPlayer,
    Players = game:GetService("Players"),
    auraRadius = 25,
    SetNetworkOwner = game:GetService("ReplicatedStorage"):WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
}

local vu12 = { CurrentCamera = workspace.CurrentCamera }

vu390.localPlayer.CharacterAdded:Connect(function(p403)
    vu390.playerCharacter = p403
end)

local function startHellSendAura()
    vu390.gravityCoroutine = coroutine.create(function()
        while true do
            local v421, v422 = pcall(function()
                local v404 = vu390.localPlayer.Character
                if v404 and v404:FindFirstChild("HumanoidRootPart") then
                    local v405 = v404.HumanoidRootPart
                    local v406 = vu12.CurrentCamera
                    for _, v410 in pairs(vu390.Players:GetPlayers()) do
                        if v410 ~= vu390.localPlayer and v410.Character then
                            local v411 = v410.Character
                            local v412 = v411:FindFirstChild("Torso") or v411:FindFirstChild("UpperTorso")
                            if v412 and (v412.Position - v405.Position).Magnitude <= vu390.auraRadius then
                                vu390.SetNetworkOwner:FireServer(v412, v405.CFrame)
                                for _, v416 in ipairs(v411:GetDescendants()) do
                                    if v416:IsA("BasePart") then
                                        v416.CanCollide = false
                                    end
                                end
                                local v417 = v412:FindFirstChild("HellAuraPos") or Instance.new("BodyPosition")
                                v417.Name = "HellAuraPos"
                                v417.MaxForce = Vector3.new(100000, 100000, 100000)
                                v417.D = 500
                                v417.P = 50000
                                v417.Parent = v412
                                local v418 = v412:FindFirstChild("HellAuraGyro") or Instance.new("BodyGyro")
                                v418.Name = "HellAuraGyro"
                                v418.MaxTorque = Vector3.new(100000, 100000, 100000)
                                v418.D = 500
                                v418.P = 50000
                                v418.Parent = v412
                                local v419 = v406.CFrame.LookVector
                                local v420 = Vector3.new(0, 5, 0)
                                v417.Position = v405.Position + v419 * 15 + v420
                                v418.CFrame = CFrame.new(v412.Position, v405.Position)
                            end
                        end
                    end
                end
            end)
            if not v421 then
                warn("Error in Hell Send Aura: " .. tostring(v422))
            end
            task.wait(0.05)
        end
    end)
    coroutine.resume(vu390.gravityCoroutine)
end

local function stopHellSendAura()
    if vu390.gravityCoroutine then
        coroutine.close(vu390.gravityCoroutine)
        vu390.gravityCoroutine = nil
    end
end

TelekinesisGroup:CreateToggle({
    Name = "Telekinesis Aura",
        Flag = "Telekinesis Aura",
    Default = false,
    Callback = function(Value)
        SetToggleState("Telekinesis Aura", Value)
        if Value then
            startHellSendAura()
        else
            stopHellSendAura()
        end
    end
})

local deathConnection = nil
local vu29 = { Death_Aura = false }
local vu6 = {
    SetNetworkOwner = game:GetService("ReplicatedStorage"):WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner"),
    DestroyGrabLine = game:GetService("ReplicatedStorage"):WaitForChild("GrabEvents"):WaitForChild("DestroyGrabLine")
}

local function death(p424)
    if deathConnection then
        deathConnection:Disconnect()
        deathConnection = nil
    end
    if p424 then
        vu29.Death_Aura = true
        deathConnection = game:GetService("RunService").Heartbeat:Connect(function()
            for _, v429 in ipairs(game:GetService("Players"):GetPlayers()) do
                if v429 ~= LocalPlayer and v429.Character then
                    local vu430 = v429.Character:FindFirstChild("HumanoidRootPart")
                    local vu431 = v429.Character:FindFirstChild("Head")
                    local vu432 = v429.Character:FindFirstChildOfClass("Humanoid")
                    if vu430 and vu431 and vu432 and vu432.Health > 0 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        if (vu430.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 25 then
                            pcall(function()
                                vu6.SetNetworkOwner:FireServer(vu430, vu430.CFrame)
                                task.wait(0.1)
                                vu6.DestroyGrabLine:FireServer(vu430)
                                if vu431:FindFirstChild("PartOwner") and vu431.PartOwner.Value == LocalPlayer.Name then
                                    for _, v436 in pairs(vu432.Parent:GetChildren()) do
                                        if v436:IsA("BasePart") then
                                            v436.CFrame = CFrame.new(-1000000000, 1000000000, -1000000000)
                                        end
                                    end
                                    task.wait()
                                    for _, v440 in pairs(vu432.Parent:GetChildren()) do
                                        if v440:IsA("BasePart") then
                                            v440.CFrame = CFrame.new(-1000000000, 1000000000, -1000000000)
                                        end
                                    end
                                    local vu441 = Instance.new("BodyVelocity")
                                    vu441.Velocity = Vector3.new(0, -9999999, 0)
                                    vu441.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                                    vu441.P = 100000075
                                    vu441.Parent = vu430
                                    vu432.Sit = false
                                    vu432.Jump = true
                                    vu432.BreakJointsOnDeath = false
                                    vu432:ChangeState(Enum.HumanoidStateType.Dead)
                                    task.delay(2, function()
                                        if vu441 and vu441.Parent then
                                            vu441:Destroy()
                                        end
                                    end)
                                end
                            end)
                        end
                    end
                end
            end
        end)
    else
        vu29.Death_Aura = false
    end
end

TelekinesisGroup:CreateToggle({
    Name = "Death Aura",
    Flag = "Death Aura",
    Default = false,
    Callback = death
})
-- [Kick Aura OP PREMIUM removed]
do
    -- // Services & Variables \ --
    local playersService = game:GetService("Players")
    local workspaceService = game:GetService("Workspace")
    local debrisService = game:GetService("Debris")
    local localPlayer = playersService.LocalPlayer

    -- Remote Events required for network ownership
    local setNetworkOwnerEvent = game:GetService("ReplicatedStorage"):WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")

    -- Global Variables used by the Fling Aura UI
    _G.FlingAura = false
    _G.FlingStrength = 400
    _G.FlingTarget = 1 -- 1 = Players, 2 = Objects, 3 = Players and Objects

    -- // Helper Functions \ --
    
    -- Calculates the CFrame needed to point the fling velocity at the target
    local function lookAt(startPosition, targetPosition)
        local directionVector = (targetPosition - startPosition).Unit
        local rightVector = directionVector:Cross((Vector3.new(0, 1, 0)))
        local upVector = rightVector:Cross(directionVector)
        return CFrame.fromMatrix(startPosition, rightVector, upVector)
    end

    local function GetPlayerCharacter()
        if localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChildOfClass("Humanoid")) then
            return localPlayer.Character
        end
    end

    local function GetPlayerRoot()
        local playerHumanoidRootPart = GetPlayerCharacter()
        if playerHumanoidRootPart then
            return playerHumanoidRootPart.HumanoidRootPart
        end
    end

    -- Network Ownership Checks
    local function CheckNetworkOwnerShipOnPart(potentialPart, condition)
        if typeof(potentialPart) == "Instance" and (potentialPart:FindFirstChild("PartOwner") and potentialPart.PartOwner.Value == localPlayer.Name) then
            return not condition and true or potentialPart.PartOwner
        end
    end

    local function CheckNetworkOwnerShipOnPlayer(potentialPlayer, condition)
        if typeof(potentialPlayer) == "Instance" and (potentialPlayer:IsA("Player") and potentialPlayer.Character) and (potentialPlayer.Character:FindFirstChild("Head") and (potentialPlayer.Character.Head:FindFirstChild("PartOwner") and potentialPlayer.Character.Head.PartOwner.Value == localPlayer.Name)) then
            return not condition and true or potentialPlayer.Character.Head.PartOwner
        end
    end

    local function SNOWshipPlayer(otherPlayer, callbackFunction)
        if localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") and (typeof(otherPlayer) == "Instance" and (otherPlayer:IsA("Player") and otherPlayer.Character)) and otherPlayer.Character:FindFirstChild("HumanoidRootPart")) then
            local otherPlayerHumanoidRootPart = otherPlayer.Character.HumanoidRootPart
            local distanceFromOtherPlayer = localPlayer:DistanceFromCharacter(otherPlayerHumanoidRootPart.Position)
            if CheckNetworkOwnerShipOnPlayer(otherPlayer) then
                if type(callbackFunction) == "function" then
                    callbackFunction()
                end
                return true
            end
            if distanceFromOtherPlayer <= 30 then
                setNetworkOwnerEvent:FireServer(otherPlayerHumanoidRootPart, lookAt(localPlayer.Character.HumanoidRootPart.Position, otherPlayerHumanoidRootPart.Position))
            end
        end
    end

    local function SNOWshipTrack(targetPart)
        if targetPart.Parent and targetPart.Parent:IsA("Model") then
            local targetModel = targetPart.Parent
            local isOwnershipTrackConnected = targetModel:GetAttribute("OwnershipTrackConnected")
            local isCreatedConnected2 = targetModel:GetAttribute("CreatedConnected2")
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distanceFromCharacter = localPlayer:DistanceFromCharacter(targetPart.Position)
                if isCreatedConnected2 then
                    if isOwnershipTrackConnected then
                        return true
                    end
                    if distanceFromCharacter <= 30 then
                        setNetworkOwnerEvent:FireServer(targetPart, lookAt(localPlayer.Character.HumanoidRootPart.Position, targetPart.Position))
                    end
                else
                    targetModel:SetAttribute("CreatedConnected2", true)
                    targetModel.DescendantAdded:Connect(function(attribute)
                        if attribute.Name ~= "PartOwner" or attribute.Value ~= localPlayer.Name then
                            if attribute.Name == "PartOwner" and attribute.Value ~= localPlayer.Name then
                                targetModel:SetAttribute("OwnershipTrackConnected", false)
                            end
                        else
                            targetModel:SetAttribute("OwnershipTrackConnected", true)
                        end
                    end)
                end
            end
        end
    end

    -- Target Validation Checks
    local function CheckPlayer(potentialPlayer)
        if typeof(potentialPlayer) == "Instance" and (potentialPlayer ~= localPlayer and potentialPlayer.Character) and (potentialPlayer.Character:IsDescendantOf(workspaceService) and (potentialPlayer.Character:FindFirstChild("HumanoidRootPart") and (potentialPlayer.Character:FindFirstChildOfClass("Humanoid") and potentialPlayer.Character.Humanoid.Health > 0))) then
            return true
        end
    end

    local function CheckPlayerAuras(potentialKickedPlayer1)
        if CheckPlayer(potentialKickedPlayer1) and not potentialKickedPlayer1.Character:GetAttribute("Kicking") then
            return true
        end
    end

    -- Spatial parameters for finding loose objects
    local COAroundPParams = OverlapParams.new()
    COAroundPParams.FilterType = Enum.RaycastFilterType.Exclude

    local function CheckObjectsAroundPlayer()
        -- Ensure this list dynamically updates locally within the function
        COAroundPParams.FilterDescendantsInstances = { }
