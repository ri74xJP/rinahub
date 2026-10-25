local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local SPEED = 60
local Flying = false

local Character
local Humanoid
local RootPart
local Attachment
local LinearVelocity

local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")
end

SetupCharacter(Player.Character or Player.CharacterAdded:Wait())

Player.CharacterAdded:Connect(function(char)
	Flying = false
	SetupCharacter(char)
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyController"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(190, 70)
Main.Position = UDim2.new(0.5, -95, 0.82, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 65, 75)
Stroke.Thickness = 1.5
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -85, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "FLY"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(65, 38)
Toggle.Position = UDim2.new(1, -78, 0.5, -19)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(220, 220, 225)
Toggle.TextSize = 14
Toggle.Font = Enum.Font.GothamBold
Toggle.AutoButtonColor = false
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = Toggle

local function StartFlying()
	if not RootPart or not RootPart.Parent then
		return
	end

	if Attachment then
		Attachment:Destroy()
	end

	Attachment = Instance.new("Attachment")
	Attachment.Name = "FlyAttachment"
	Attachment.Parent = RootPart

	LinearVelocity = Instance.new("LinearVelocity")
	LinearVelocity.Name = "FlyVelocity"
	LinearVelocity.Attachment0 = Attachment
	LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	LinearVelocity.MaxForce = math.huge
	LinearVelocity.VectorVelocity = Vector3.zero
	LinearVelocity.Parent = RootPart

	Flying = true

	Toggle.Text = "ON"
	Toggle.BackgroundColor3 = Color3.fromRGB(70, 200, 120)
	Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
end

local function StopFlying()
	Flying = false

	if LinearVelocity then
		LinearVelocity:Destroy()
		LinearVelocity = nil
	end

	if Attachment then
		Attachment:Destroy()
		Attachment = nil
	end

	Toggle.Text = "OFF"
	Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	Toggle.TextColor3 = Color3.fromRGB(220, 220, 225)
end

Toggle.MouseButton1Click:Connect(function()
	if Flying then
		StopFlying()
	else
		StartFlying()
	end
end)

RunService.RenderStepped:Connect(function()
	if not Flying or not LinearVelocity or not RootPart then
		return
	end

	local Camera = workspace.CurrentCamera
	local Direction = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		Direction += Camera.CFrame.LookVector
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		Direction -= Camera.CFrame.LookVector
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		Direction -= Camera.CFrame.RightVector
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		Direction += Camera.CFrame.RightVector
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		Direction += Vector3.new(0, 1, 0)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		Direction -= Vector3.new(0, 1, 0)
	end

	if Direction.Magnitude > 0 then
		Direction = Direction.Unit
	end

	LinearVelocity.VectorVelocity = Direction * SPEED
end)
