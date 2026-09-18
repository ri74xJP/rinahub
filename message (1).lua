local OrionLib = loadstring(game:HttpGet(('https://pastefy.app/H3pBfBVT/raw')))()
local Window = OrionLib:MakeWindow({
    Name = "ダイスでお絵描き😅- ゆざまい作",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DiceCanvasConfig"
})


local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")


local plr = Players.LocalPlayer


local GrabEvents = RS:WaitForChild("GrabEvents", 5)
local DataEvents = RS:WaitForChild("DataEvents", 5)
local SetOwnerEvent = GrabEvents and GrabEvents:WaitForChild("SetNetworkOwner", 5)
local LineColorEvent = DataEvents and DataEvents:WaitForChild("UpdateLineColorsEvent", 5)

local BLUE = Color3.fromRGB(0, 56, 168)
local WHITE = Color3.fromRGB(255, 255, 255)
local RED = Color3.fromRGB(200, 16, 46)
local BLACK = Color3.fromRGB(0, 0, 0)
local GRAY = Color3.fromRGB(160, 160, 160)
local YELLOW = Color3.fromRGB(255, 210, 0)
local PINK = Color3.fromRGB(255, 105, 180)
local BROWN = Color3.fromRGB(120, 60, 20)

local rowColors = { BLUE, BLUE, WHITE, RED, RED, RED, WHITE, BLUE, BLUE }
local blackCells = { {4,3}, {5,3}, {4,7}, {5,7}, {7,5} }
local eyeCells = { {4,3}, {5,3}, {4,7}, {5,7} }
local whiteCells = { {5,1} }

local function isBlackCell(r,c)
    for _,v in ipairs(blackCells) do if v[1]==r and v[2]==c then return true end end return false
end
local function isEyeCell(r,c)
    for _,v in ipairs(eyeCells) do if v[1]==r and v[2]==c then return true end end return false
end
local function isWhiteCell(r,c)
    for _,v in ipairs(whiteCells) do if v[1]==r and v[2]==c then return true end end return false
end

local AllDice = {}
local hoveringObjects = {}
local MainEnabled = false
local ColorSyncEnabled = false
local SelectedColorMode = "ゆざまい"

local BotModeEnabled = false
local botCFrame = CFrame.new()
local botAction = "GHAST_FLOAT"
local botTimer = 0
local botActionDuration = 8
local botMoveTarget = Vector3.new()
local botFollowPlayer = nil
local currentRotationY = 0
local isLookingAtPlayer = false

local botDefaultHeight = 12.0  
local botHighOffset = 22.0     
local botCurrentHeight = 12.0


local isExecutingSpecialAction = false
local specialActionProgress = 0
local orbitAngle = 0
local loopPitch = 0


local SineWaveEnabled = false
local AnimMode = "Sin波"
local animSpeed = 4
local animHeight = 4
local animTime = 0


local ShapeMode = "2D平面"
local FaceFrontOnly = true


local EyeTrackEnabled = false
local SelectedTargetPlayer = nil
local playerDropdown = nil
local eyeOffset = Vector2.new(0, 0)
local FollowTargetEnabled = false
local StayInPlaceEnabled = false
local fixedCFrame = nil
local settings = {
    gridSize = 4,
    height = 20,
    targetHeight = 20,
    depth = -15,
    wingRange = 100
}


local currentColorForPaint = Color3.new(1,1,1)
local currentHue, currentSat, currentVal = 0, 1, 1


local activeToolMode = "PEN"
local brushSize = "1x1"
local isGridVisible = true


local shapeStartPos = nil


local gradStartColor = Color3.fromRGB(0, 0, 0)
local gradEndColor = Color3.fromRGB(255, 255, 255)
local gradType = "RGB2"
local gradDirection = "左→右"
local gradAngle = 45


local recentColors = {}


local CurrentWorkingGrid = {}
local activeCustomFace = {}
for i=1, 69 do
    CurrentWorkingGrid[i] = WHITE
    activeCustomFace[i] = WHITE
end

local undoStack = {}
local redoStack = {}

local function cloneGrid(g)
    local c = {}
    for i=1, 69 do c[i] = g[i] end
    return c
end

local function pushUndo()
    table.insert(undoStack, cloneGrid(CurrentWorkingGrid))
    redoStack = {}
    if #undoStack > 50 then table.remove(undoStack, 1) end
end

local customFaces = {}
local saveFileName = "DiceFacesData.json"

local function loadFacesFromFile()
    if readfile and isfile and pcall(function() return isfile(saveFileName) end) then
        local s, data = pcall(function() return readfile(saveFileName) end)
        if s and data then
            local s2, decoded = pcall(function() return HttpService:JSONDecode(data) end)
            if s2 and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    local t = {}
                    for i=1, 69 do
                        if v[i] then
                            t[i] = Color3.fromRGB(v[i][1] or 255, v[i][2] or 255, v[i][3] or 255)
                        else
                            t[i] = WHITE
                        end
                    end
                    customFaces[k] = t
                end
            end
        end
    end
end
loadFacesFromFile()

local function saveFacesToFile()
    if writefile then
        local data = {}
        for k, v in pairs(customFaces) do
            local t = {}
            for i=1, 69 do
                local c = v[i] or WHITE
                table.insert(t, {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)})
            end
            data[k] = t
        end
        pcall(function() writefile(saveFileName, HttpService:JSONEncode(data)) end)
    end
end


local gridMap = {
    {0,0,1,1,1,1,1,0,0},
    {0,1,1,1,1,1,1,1,0},
    {1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1},
    {0,1,1,1,1,1,1,1,0},
    {0,0,1,1,1,1,1,0,0},
}

local relativePositions = {}
local gridLookup = {}
for row=1,9 do
    for col=1,9 do
        if gridMap[row][col]==1 then
            table.insert(relativePositions,{ x = 5-col, y = 5-row, row = row, col = col })
            gridLookup[row .. "_" .. col] = #relativePositions
        end
    end
end


local function getRainbowColorByPosition(row, col)
    local progress = ((col - 1) + (9 - row)) / 16
    return Color3.fromHSV(progress, 1, 1)
end

local function getColor(slot, idx)
    if SelectedColorMode == "カスタム" then
        return activeCustomFace[idx] or WHITE
    end

    if isBlackCell(slot.row, slot.col) then return BLACK end

    if SelectedColorMode == "ゆざまい" then
        if isWhiteCell(slot.row, slot.col) then return WHITE end
        return rowColors[slot.row] or WHITE
    elseif SelectedColorMode == "いもすけ" then
        return getRainbowColorByPosition(slot.row, slot.col)
    elseif SelectedColorMode == "ゆずぴー" then
        return WHITE
    else
        return WHITE
    end
end


local function isSelectableDice(part, char)
    if not part:IsA("BasePart") or part.Anchored then return false end
    if char and part:IsDescendantOf(char) then return false end
    if part.Name ~= "DiceBig" and (not part.Parent or part.Parent.Name ~= "DiceBig") then return false end
    return true
end

local function setupPhysics(part)
    part.CanCollide = false
    local bv = part:FindFirstChild("DiceForce") or Instance.new("BodyVelocity")
    bv.Name = "DiceForce" bv.MaxForce = Vector3.new(1,1,1)*1e7 bv.Parent = part
    
    local bg = part:FindFirstChild("DiceGyro") or Instance.new("BodyGyro")
    bg.Name = "DiceGyro" bg.MaxTorque = Vector3.new(1,1,1)*1e7 bg.Parent = part
end

local function disablePhysicsAndDrop()
    for _, part in ipairs(AllDice) do
        if part and part.Parent then
            local bv = part:FindFirstChild("DiceForce")
            local bg = part:FindFirstChild("DiceGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            part.CanCollide = true
        end
    end
end


local function cleanupDiceList()
    for i = #AllDice, 1, -1 do
        local part = AllDice[i]
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            hoveringObjects[part] = nil
            table.remove(AllDice, i)
        end
    end
end

local function addDiceToList(part)
    cleanupDiceList() 
    if hoveringObjects[part] then return end
    if #AllDice >= #relativePositions then return end
    hoveringObjects[part] = true
    setupPhysics(part)
    table.insert(AllDice, part)
end


local function getCrowdCenterPosition()
    local totalPos = Vector3.new()
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            totalPos = totalPos + p.Character.HumanoidRootPart.Position
            count = count + 1
        end
    end
    if count > 0 then return totalPos / count, count end
    return nil, 0
end

local function getNearestPlayer(currentPos)
    local nearestPlr = nil
    local minDistance = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - currentPos).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearestPlr = p
            end
        end
    end
    return nearestPlr, minDistance
end

local function chooseNewBotAction(originPos)
    botTimer = 0
    isLookingAtPlayer = false
    isExecutingSpecialAction = false
    specialActionProgress = 0
    orbitAngle = 0
    loopPitch = 0

    local nearestPlr, dist = getNearestPlayer(originPos)
    
   
    if nearestPlr and dist <= 25 and math.random(1, 100) <= 35 then
        local randAction = math.random(1, 2)
        if randAction == 1 then
            botAction = "ORBIT_PLAYER"
            botActionDuration = 5
        else
            botAction = "LOOP_THE_LOOP"
            botActionDuration = 2.5
        end
        botFollowPlayer = nearestPlr
        isExecutingSpecialAction = true
        return
    end

    local rand = math.random(1, 100)
    if rand <= 25 then
        
        botAction = "LOOK_AT_PLAYER"
        botActionDuration = math.random(3, 6)
        isLookingAtPlayer = true
    elseif rand <= 55 then
        botAction = "GHAST_FLOAT"
        botActionDuration = math.random(8, 14)
        local rx = math.random(-60, 60)
        local ry = math.random(-5, 10)
        local rz = math.random(-60, 60)
        botMoveTarget = Vector3.new(originPos.X + rx, originPos.Y + ry, originPos.Z + rz)
    elseif rand <= 80 then
        botAction = "GO_TO_CROWD"
        botActionDuration = math.random(10, 15)
        local crowdPos, count = getCrowdCenterPosition()
        if crowdPos then
            botMoveTarget = crowdPos + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
        else
            botAction = "GHAST_FLOAT"
            botMoveTarget = originPos + Vector3.new(math.random(-40, 40), math.random(-5, 10), math.random(-40, 40))
        end
    else
        botAction = "FOLLOW"
        botActionDuration = math.random(10, 16)
        local allPlrs = Players:GetPlayers()
        if #allPlrs > 0 then botFollowPlayer = allPlrs[math.random(1, #allPlrs)] else botAction = "GHAST_FLOAT" end
    end
end


local function calculateGridPosition(idx, baseCFrame, timeOffset)
    local slot = relativePositions[idx]
    if not slot then return nil, nil end

    local offsetX, offsetY = slot.x, 5 - slot.row
    if isEyeCell(slot.row, slot.col) then
        offsetX = offsetX + eyeOffset.X
        offsetY = offsetY + eyeOffset.Y
    end

    local eyeDepth = 0
    if isLookingAtPlayer and isEyeCell(slot.row, slot.col) then
        eyeDepth = settings.gridSize * 0.8
    end

    local localPos = Vector3.new(0, 0, 0)
    local extraCF = CFrame.new()

    if ShapeMode == "平面" or ShapeMode == "2D平面" then
        localPos = Vector3.new(offsetX * settings.gridSize, offsetY * settings.gridSize, -eyeDepth)
    elseif ShapeMode == "球体" then
        local radius = settings.gridSize * 4
        local distFromCenter = math.sqrt(offsetX^2 + offsetY^2) / 4.5
        local zOffset = -math.cos(math.clamp(distFromCenter, 0, 1) * (math.pi / 2)) * radius - eyeDepth
        localPos = Vector3.new(offsetX * settings.gridSize, offsetY * settings.gridSize, zOffset)
        if not FaceFrontOnly then
            local theta = (offsetX / 4) * math.rad(45)
            local phi = (offsetY / 4) * math.rad(45)
            extraCF = CFrame.Angles(phi, -theta, 0)
        end
    elseif ShapeMode == "直方体" then
        local limit = 2.0
        local absX, absY = math.abs(offsetX), math.abs(offsetY)
        if absY > limit and absY >= absX then
            local ySign = math.sign(offsetY)
            local depthOffset = (absY - limit) * settings.gridSize
            localPos = Vector3.new(offsetX * settings.gridSize, ySign * limit * settings.gridSize, depthOffset - eyeDepth)
            if not FaceFrontOnly then extraCF = CFrame.Angles(-ySign * math.rad(90), 0, 0) end
        elseif absX > limit then
            local xSign = math.sign(offsetX)
            local depthOffset = (absX - limit) * settings.gridSize
            localPos = Vector3.new(xSign * limit * settings.gridSize, offsetY * settings.gridSize, depthOffset - eyeDepth)
            if not FaceFrontOnly then extraCF = CFrame.Angles(0, xSign * math.rad(90), 0) end
        else
            localPos = Vector3.new(offsetX * settings.gridSize, offsetY * settings.gridSize, -eyeDepth)
        end
    end

    if SineWaveEnabled then
        if AnimMode == "波" or AnimMode == "Sin波" then
            local waveY = math.sin(timeOffset * animSpeed + (slot.x + slot.y) * 0.4) * animHeight
            localPos = localPos + Vector3.new(0, waveY, 0)
        elseif AnimMode == "回転" then
            extraCF = extraCF * CFrame.Angles(0, 0, timeOffset * animSpeed * 0.8)
        elseif AnimMode == "パルス" then
            local scale = 1 + math.sin(timeOffset * animSpeed) * 0.3 * (animHeight / 2)
            localPos = localPos * scale
        elseif AnimMode == "分散" then
            local burst = math.sin(timeOffset * animSpeed) * 1.5 * animHeight
            localPos = localPos * (1 + math.abs(burst))
        elseif AnimMode == "逆竜巻" then
            local baseProgress = ((slot.row - 1) / 8 + (slot.col - 1) / 8) / 2
            local climbProgress = (baseProgress + timeOffset * (animSpeed * 0.12)) % 1.0
            local smoothLoopFactor = (math.sin(climbProgress * math.pi * 2 - math.pi / 2) + 1) / 2
            local baseRadius = (math.pow(smoothLoopFactor, 1.4) * 1.2 + 0.12) * (settings.gridSize * 3.5) * (animHeight / 2)
            local baseAngle = (slot.col / 9) * (math.pi * 2)
            local angle = baseAngle + timeOffset * animSpeed * 1.8

            local vortexShiftX = math.sin(timeOffset * 2.0 + smoothLoopFactor * math.pi) * (smoothLoopFactor * 4)
            local vortexShiftZ = math.cos(timeOffset * 2.0 + smoothLoopFactor * math.pi) * (smoothLoopFactor * 4)

            localPos = Vector3.new(vortexShiftX + math.cos(angle) * baseRadius, (smoothLoopFactor - 0.5) * settings.gridSize * 8, vortexShiftZ + math.sin(angle) * baseRadius)
            if not FaceFrontOnly then
                extraCF = CFrame.Angles(math.rad(15 + (1 - smoothLoopFactor) * 25), -angle + math.pi/2, 0)
            end
        end
    end

    local finalBaseCF = baseCFrame * CFrame.new(0, settings.height, -settings.depth)
    return finalBaseCF:PointToWorldSpace(localPos), finalBaseCF * CFrame.new(localPos) * extraCF
end

local function getPlayerList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.DisplayName .. " (@" .. p.Name .. ")") end
    return names
end

local function getPlayerFromFormat(formattedName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName .. " (@" .. p.Name .. ")" == formattedName then return p end
    end return nil
end


local PaintScreen = Instance.new("ScreenGui")
PaintScreen.Name = "DiceFacePaintUI"
PaintScreen.ResetOnSpawn = false
pcall(function() PaintScreen.Parent = game:GetService("CoreGui") end)
if not PaintScreen.Parent then PaintScreen.Parent = plr:WaitForChild("PlayerGui") end
PaintScreen.Enabled = false

local PaintMain = Instance.new("Frame")
PaintMain.Size = UDim2.new(0, 360, 0, 780)
PaintMain.Position = UDim2.new(0.5, -180, 0.5, -390)
PaintMain.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
PaintMain.Active = true
PaintMain.Draggable = true
PaintMain.Parent = PaintScreen
local uic1 = Instance.new("UICorner") uic1.CornerRadius = UDim.new(0, 10) uic1.Parent = PaintMain

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 28)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎨 ペイントキャンバス"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = PaintMain

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = PaintMain
CloseBtn.MouseButton1Click:Connect(function() PaintScreen.Enabled = false end)

local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Size = UDim2.new(1, -12, 1, -34)
MainScroll.Position = UDim2.new(0, 6, 0, 30)
MainScroll.BackgroundTransparency = 1
MainScroll.ScrollBarThickness = 4
MainScroll.CanvasSize = UDim2.new(0, 0, 0, 830)
MainScroll.Parent = PaintMain

local LayoutList = Instance.new("UIListLayout")
LayoutList.Padding = UDim.new(0, 6)
LayoutList.HorizontalAlignment = Enum.HorizontalAlignment.Center
LayoutList.Parent = MainScroll

local PaletteFrame = Instance.new("Frame")
PaletteFrame.Size = UDim2.new(0, 340, 0, 22)
PaletteFrame.BackgroundTransparency = 1
PaletteFrame.Parent = MainScroll

local PaletteLayout = Instance.new("UIListLayout")
PaletteLayout.FillDirection = Enum.FillDirection.Horizontal
PaletteLayout.Padding = UDim.new(0, 3)
PaletteLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PaletteLayout.Parent = PaletteFrame

local quickColors = {
    Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(160,160,160),
    Color3.fromRGB(255,0,0), Color3.fromRGB(0,120,255), Color3.fromRGB(0,200,80),
    Color3.fromRGB(255,220,0), Color3.fromRGB(255,130,0), Color3.fromRGB(160,30,230), Color3.fromRGB(255,105,180)
}

local CurrentColorIndicator = Instance.new("Frame")
CurrentColorIndicator.Size = UDim2.new(0, 340, 0, 20)
CurrentColorIndicator.BackgroundColor3 = currentColorForPaint
CurrentColorIndicator.Parent = MainScroll
local cUic = Instance.new("UICorner") cUic.CornerRadius = UDim.new(0, 4) cUic.Parent = CurrentColorIndicator

local CurrentColorText = Instance.new("TextLabel")
CurrentColorText.Size = UDim2.new(1, 0, 1, 0)
CurrentColorText.BackgroundTransparency = 1
CurrentColorText.Text = "現在のペン色"
CurrentColorText.TextColor3 = Color3.fromRGB(0, 0, 0)
CurrentColorText.Font = Enum.Font.GothamBold
CurrentColorText.TextSize = 10
CurrentColorText.Parent = CurrentColorIndicator

local ValGradientFrame = Instance.new("Frame")

local function addRecentColor(col)
    for i, c in ipairs(recentColors) do
        if c == col then table.remove(recentColors, i) break end
    end
    table.insert(recentColors, 1, col)
    if #recentColors > 10 then table.remove(recentColors) end
end

local function updateCurrentColor(col, updateHSV)
    currentColorForPaint = col
    CurrentColorIndicator.BackgroundColor3 = col
    local lum = (col.R*0.299 + col.G*0.587 + col.B*0.114)
    CurrentColorText.TextColor3 = lum > 0.5 and Color3.fromRGB(0,0,0) or WHITE
    
    if updateHSV then
        local h, s, v = col:ToHSV()
        currentHue, currentSat, currentVal = h, s, v
    end

    if ValGradientFrame and ValGradientFrame:FindFirstChildOfClass("UIGradient") then
        local baseCol = Color3.fromHSV(currentHue, currentSat, 1)
        ValGradientFrame.UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, baseCol)
        })
    end
    addRecentColor(col)
end

for _, col in ipairs(quickColors) do
    local pBtn = Instance.new("TextButton")
    pBtn.Size = UDim2.new(0, 31, 0, 22)
    pBtn.BackgroundColor3 = col
    pBtn.Text = ""
    pBtn.Parent = PaletteFrame
    local pUic = Instance.new("UICorner") pUic.CornerRadius = UDim.new(0, 4) pUic.Parent = pBtn
    pBtn.MouseButton1Click:Connect(function() updateCurrentColor(col, true) end)
end

local PickerBox = Instance.new("Frame")
PickerBox.Size = UDim2.new(0, 340, 0, 56)
PickerBox.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
PickerBox.Parent = MainScroll
local pbUic = Instance.new("UICorner") pbUic.CornerRadius = UDim.new(0, 6) pbUic.Parent = PickerBox

local function createSliderBar(parent, labelText, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 50, 0, 14)
    lbl.Position = UDim2.new(0, 6, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = WHITE
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 270, 0, 14)
    frame.Position = UDim2.new(0, 60, 0, yPos)
    frame.Parent = parent
    local uic = Instance.new("UICorner") uic.CornerRadius = UDim.new(0, 3) uic.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    return frame, btn
end

local PickerGradientFrame, PickerSliderBtn = createSliderBar(PickerBox, "色あい:", 8)
local HueGradient = Instance.new("UIGradient")
HueGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
HueGradient.Parent = PickerGradientFrame

ValGradientFrame, ValSliderBtn = createSliderBar(PickerBox, "明るさ:", 32)
local ValGradient = Instance.new("UIGradient")
ValGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
ValGradient.Parent = ValGradientFrame

local isDraggingPicker, isDraggingVal = false, false
local function updatePickerColor(input)
    local relX = math.clamp((input.Position.X - PickerGradientFrame.AbsolutePosition.X) / PickerGradientFrame.AbsoluteSize.X, 0, 1)
    currentHue = relX
    updateCurrentColor(Color3.fromHSV(currentHue, currentSat, currentVal), false)
end
local function updateValColor(input)
    local relX = math.clamp((input.Position.X - ValGradientFrame.AbsolutePosition.X) / ValGradientFrame.AbsoluteSize.X, 0, 1)
    currentVal = relX
    updateCurrentColor(Color3.fromHSV(currentHue, currentSat, currentVal), false)
end

PickerSliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingPicker = true updatePickerColor(input) end end)
ValSliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingVal = true updateValColor(input) end end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if isDraggingPicker then updatePickerColor(input) end
        if isDraggingVal then updateValColor(input) end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingPicker = false isDraggingVal = false end
end)

local ToolBarFrame = Instance.new("Frame")
ToolBarFrame.Size = UDim2.new(0, 340, 0, 60)
ToolBarFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
ToolBarFrame.Parent = MainScroll
local tbUic = Instance.new("UICorner") tbUic.CornerRadius = UDim.new(0, 6) tbUic.Parent = ToolBarFrame

local ToolLayout = Instance.new("UIGridLayout")
ToolLayout.CellSize = UDim2.new(0, 64, 0, 24)
ToolLayout.CellPadding = UDim2.new(0, 3, 0, 3)
ToolLayout.Parent = ToolBarFrame

local toolButtons = {}
local function createToolBtn(id, text)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = (activeToolMode == id) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(55, 55, 60)
    btn.Text = text
    btn.TextColor3 = WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = ToolBarFrame
    local uic = Instance.new("UICorner") uic.CornerRadius = UDim.new(0, 4) uic.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        activeToolMode = id
        for toolId, b in pairs(toolButtons) do
            b.BackgroundColor3 = (toolId == activeToolMode) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(55, 55, 60)
        end
        shapeStartPos = nil
    end)
    toolButtons[id] = btn
    return btn
end

createToolBtn("PEN", "✏️ ペン")
createToolBtn("ERASER", "🧽 消しゴム")
createToolBtn("BUCKET", "🪣 バケツ")
createToolBtn("EYEDROPPER", "🧪 スポイト")
createToolBtn("LINE", "📏 直線")
createToolBtn("RECT_OUTLINE", "🔲 四角(枠)")
createToolBtn("RECT_FILL", "⬛ 四角(全)")
createToolBtn("CIRCLE_OUTLINE", "⭕ 円(枠)")
createToolBtn("CIRCLE_FILL", "🔴 円(全)")

local GridContainer = Instance.new("Frame")
GridContainer.Size = UDim2.new(0, 290, 0, 290)
GridContainer.BackgroundTransparency = 1
GridContainer.Parent = MainScroll

local GridLayout = Instance.new("UIGridLayout")
GridLayout.CellSize = UDim2.new(0, 30, 0, 30)
GridLayout.CellPadding = UDim2.new(0, 2, 0, 2)
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
GridLayout.Parent = GridContainer

local GridButtons = {}

local function updateUIFromGrid()
    for i = 1, 69 do
        if GridButtons[i] and CurrentWorkingGrid[i] then
            GridButtons[i].BackgroundColor3 = CurrentWorkingGrid[i]
            GridButtons[i].BorderSizePixel = isGridVisible and 1 or 0
        end
        activeCustomFace[i] = CurrentWorkingGrid[i] or WHITE
    end
end

local function floodFill(targetIdx, targetColor, replacementColor)
    if targetColor == replacementColor then return end
    local queue = { targetIdx }
    local visited = {}
    
    while #queue > 0 do
        local currIdx = table.remove(queue, 1)
        if not visited[currIdx] then
            visited[currIdx] = true
            if CurrentWorkingGrid[currIdx] == targetColor then
                CurrentWorkingGrid[currIdx] = replacementColor
                local pos = relativePositions[currIdx]
                if pos then
                    local neighbors = {
                        {r = pos.row - 1, c = pos.col}, {r = pos.row + 1, c = pos.col},
                        {r = pos.row, c = pos.col - 1}, {r = pos.row, c = pos.col + 1}
                    }
                    for _, n in ipairs(neighbors) do
                        local nIdx = gridLookup[n.r .. "_" .. n.c]
                        if nIdx and not visited[nIdx] then table.insert(queue, nIdx) end
                    end
                end
            end
        end
    end
end

local function drawLine(r0, c0, r1, c1, color)
    local dr = math.abs(r1 - r0)
    local dc = math.abs(c1 - c0)
    local sr = r0 < r1 and 1 or -1
    local sc = c0 < c1 and 1 or -1
    local err = dr - dc
    
    while true do
        local idx = gridLookup[r0 .. "_" .. c0]
        if idx then CurrentWorkingGrid[idx] = color end
        if r0 == r1 and c0 == c1 then break end
        local e2 = 2 * err
        if e2 > -dc then err = err - dc r0 = r0 + sr end
        if e2 < dr then err = err + dr c0 = c0 + sc end
    end
end

local function applyBrush(row, col, color)
    local targets = {}
    if brushSize == "1x1" then
        table.insert(targets, {r = row, c = col})
    elseif brushSize == "3x3_SQUARE" then
        for dr = -1, 1 do for dc = -1, 1 do table.insert(targets, {r = row + dr, c = col + dc}) end end
    elseif brushSize == "3x3_ROUND" then
        local roundOffsets = { {0,0}, {0,1}, {0,-1}, {1,0}, {-1,0} }
        for _, o in ipairs(roundOffsets) do table.insert(targets, {r = row + o[1], c = col + o[2]}) end
    end

    for _, t in ipairs(targets) do
        local idx = gridLookup[t.r .. "_" .. t.c]
        if idx then CurrentWorkingGrid[idx] = color end
    end
end

local function handleCellClick(targetIdx, pos)
    local drawColor = (activeToolMode == "ERASER") and WHITE or currentColorForPaint

    if activeToolMode == "PEN" or activeToolMode == "ERASER" then
        pushUndo()
        applyBrush(pos.row, pos.col, drawColor)
        updateUIFromGrid()

    elseif activeToolMode == "BUCKET" then
        pushUndo()
        floodFill(targetIdx, CurrentWorkingGrid[targetIdx] or WHITE, drawColor)
        updateUIFromGrid()

    elseif activeToolMode == "EYEDROPPER" then
        updateCurrentColor(CurrentWorkingGrid[targetIdx] or WHITE, true)
        activeToolMode = "PEN"
        for toolId, b in pairs(toolButtons) do b.BackgroundColor3 = (toolId == "PEN") and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(55, 55, 60) end

    elseif string.find(activeToolMode, "LINE") or string.find(activeToolMode, "RECT") or string.find(activeToolMode, "CIRCLE") then
        if not shapeStartPos then
            shapeStartPos = pos
            OrionLib:MakeNotification({Name = "図形描画", Content = "始点を設定しました。終点を選んでください", Time = 2})
        else
            pushUndo()
            local r0, c0 = shapeStartPos.row, shapeStartPos.col
            local r1, c1 = pos.row, pos.col

            if activeToolMode == "LINE" then
                drawLine(r0, c0, r1, c1, drawColor)

            elseif activeToolMode == "RECT_OUTLINE" or activeToolMode == "RECT_FILL" then
                local minR, maxR = math.min(r0, r1), math.max(r0, r1)
                local minC, maxC = math.min(c0, c1), math.max(c0, c1)
                for r = minR, maxR do
                    for c = minC, maxC do
                        if activeToolMode == "RECT_FILL" or (r == minR or r == maxR or c == minC or c == maxC) then
                            local idx = gridLookup[r .. "_" .. c]
                            if idx then CurrentWorkingGrid[idx] = drawColor end
                        end
                    end
                end

            elseif activeToolMode == "CIRCLE_OUTLINE" or activeToolMode == "CIRCLE_FILL" then
                local centerR, centerC = (r0 + r1)/2, (c0 + c1)/2
                local radius = math.sqrt((r1 - r0)^2 + (c1 - c0)^2) / 2
                for r = 1, 9 do
                    for c = 1, 9 do
                        local dist = math.sqrt((r - centerR)^2 + (c - centerC)^2)
                        if activeToolMode == "CIRCLE_FILL" and dist <= radius + 0.5 then
                            local idx = gridLookup[r .. "_" .. c]
                            if idx then CurrentWorkingGrid[idx] = drawColor end
                        elseif activeToolMode == "CIRCLE_OUTLINE" and math.abs(dist - radius) <= 0.65 then
                            local idx = gridLookup[r .. "_" .. c]
                            if idx then CurrentWorkingGrid[idx] = drawColor end
                        end
                    end
                end
            end
            shapeStartPos = nil
            updateUIFromGrid()
        end
    end
end

for r=1, 9 do
    for c=1, 9 do
        if gridMap[r][c] == 1 then
            local targetIdx = gridLookup[r .. "_" .. c]
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 30, 0, 30)
            btn.BackgroundColor3 = WHITE
            btn.BorderColor3 = Color3.fromRGB(80, 80, 80)
            btn.Text = ""
            btn.LayoutOrder = r*10 + c
            btn.Parent = GridContainer
            local uic2 = Instance.new("UICorner") uic2.CornerRadius = UDim.new(0, 3) uic2.Parent = btn

            btn.MouseButton1Click:Connect(function()
                local pos = relativePositions[targetIdx]
                if pos then handleCellClick(targetIdx, pos) end
            end)
            GridButtons[targetIdx] = btn
        else
            local spacer = Instance.new("Frame")
            spacer.Size = UDim2.new(0, 30, 0, 30)
            spacer.BackgroundTransparency = 1
            spacer.LayoutOrder = r*10 + c
            spacer.Parent = GridContainer
        end
    end
end

local SubToolsFrame = Instance.new("Frame")
SubToolsFrame.Size = UDim2.new(0, 340, 0, 54)
SubToolsFrame.BackgroundTransparency = 1
SubToolsFrame.Parent = MainScroll

local SubLayout = Instance.new("UIGridLayout")
SubLayout.CellSize = UDim2.new(0, 82, 0, 24)
SubLayout.CellPadding = UDim2.new(0, 3, 0, 3)
SubLayout.Parent = SubToolsFrame

local function createSubBtn(text, color, onClick)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = SubToolsFrame
    local uic = Instance.new("UICorner") uic.CornerRadius = UDim.new(0, 4) uic.Parent = btn
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

createSubBtn("↩️ Undo", Color3.fromRGB(70, 70, 75), function()
    if #undoStack > 0 then
        table.insert(redoStack, cloneGrid(CurrentWorkingGrid))
        CurrentWorkingGrid = table.remove(undoStack)
        updateUIFromGrid()
    end
end)

createSubBtn("↪️ Redo", Color3.fromRGB(70, 70, 75), function()
    if #redoStack > 0 then
        table.insert(undoStack, cloneGrid(CurrentWorkingGrid))
        CurrentWorkingGrid = table.remove(redoStack)
        updateUIFromGrid()
    end
end)

createSubBtn("🗑️ 全消去", Color3.fromRGB(180, 50, 50), function()
    pushUndo()
    for i = 1, 69 do CurrentWorkingGrid[i] = WHITE end
    updateUIFromGrid()
end)

local GridToggleBtn
GridToggleBtn = createSubBtn("▦ マス線: ON", Color3.fromRGB(60, 120, 80), function()
    isGridVisible = not isGridVisible
    GridToggleBtn.Text = isGridVisible and "▦ マス線: ON" or "▦ マス線: OFF"
    GridToggleBtn.BackgroundColor3 = isGridVisible and Color3.fromRGB(60, 120, 80) or Color3.fromRGB(100, 60, 60)
    updateUIFromGrid()
end)

local BrushToggleBtn
BrushToggleBtn = createSubBtn("🖌️ ブラシ: 1x1", Color3.fromRGB(80, 80, 120), function()
    if brushSize == "1x1" then brushSize = "3x3_SQUARE" BrushToggleBtn.Text = "🖌️ ブラシ: 3x3角"
    elseif brushSize == "3x3_SQUARE" then brushSize = "3x3_ROUND" BrushToggleBtn.Text = "🖌️ ブラシ: 3x3丸"
    else brushSize = "1x1" BrushToggleBtn.Text = "🖌️ ブラシ: 1x1" end
end)

createSubBtn("🔄 90°回転", Color3.fromRGB(120, 70, 180), function()
    pushUndo()
    local tempGrid = {}
    for idx, pos in ipairs(relativePositions) do
        local tIdx = gridLookup[pos.col .. "_" .. (10 - pos.row)]
        if tIdx then tempGrid[tIdx] = CurrentWorkingGrid[idx] end
    end
    for i = 1, 69 do if tempGrid[i] then CurrentWorkingGrid[i] = tempGrid[i] end end
    updateUIFromGrid()
end)

createSubBtn("↔️ 左右反転", Color3.fromRGB(50, 100, 180), function()
    pushUndo()
    local tempGrid = {}
    for idx, pos in ipairs(relativePositions) do
        local tIdx = gridLookup[pos.row .. "_" .. (10 - pos.col)]
        if tIdx then tempGrid[tIdx] = CurrentWorkingGrid[idx] end
    end
    for i = 1, 69 do if tempGrid[i] then CurrentWorkingGrid[i] = tempGrid[i] end end
    updateUIFromGrid()
end)

createSubBtn("↕️ 上下反転", Color3.fromRGB(50, 100, 180), function()
    pushUndo()
    local tempGrid = {}
    for idx, pos in ipairs(relativePositions) do
        local tIdx = gridLookup[(10 - pos.row) .. "_" .. pos.col]
        if tIdx then tempGrid[tIdx] = CurrentWorkingGrid[idx] end
    end
    for i = 1, 69 do if tempGrid[i] then CurrentWorkingGrid[i] = tempGrid[i] end end
    updateUIFromGrid()
end)

local GradBox = Instance.new("Frame")
GradBox.Size = UDim2.new(0, 340, 0, 160)
GradBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
GradBox.Parent = MainScroll
local gUic = Instance.new("UICorner") gUic.CornerRadius = UDim.new(0, 6) gUic.Parent = GradBox

local GradTitle = Instance.new("TextLabel")
GradTitle.Size = UDim2.new(1, 0, 0, 18)
GradTitle.Position = UDim2.new(0, 0, 0, 2)
GradTitle.BackgroundTransparency = 1
GradTitle.Text = "🌈 グラデーションツール"
GradTitle.TextColor3 = WHITE
GradTitle.Font = Enum.Font.GothamBold
GradTitle.TextSize = 11
GradTitle.Parent = GradBox

local StartColBtn = Instance.new("TextButton")
StartColBtn.Size = UDim2.new(0, 160, 0, 22)
StartColBtn.Position = UDim2.new(0, 6, 0, 22)
StartColBtn.BackgroundColor3 = gradStartColor
StartColBtn.Text = "開始色に設定 (黒など)"
StartColBtn.TextColor3 = WHITE
StartColBtn.Font = Enum.Font.GothamBold
StartColBtn.TextSize = 9
StartColBtn.Parent = GradBox
local scUic = Instance.new("UICorner") scUic.CornerRadius = UDim.new(0, 4) scUic.Parent = StartColBtn

local EndColBtn = Instance.new("TextButton")
EndColBtn.Size = UDim2.new(0, 160, 0, 22)
EndColBtn.Position = UDim2.new(0, 174, 0, 22)
EndColBtn.BackgroundColor3 = gradEndColor
EndColBtn.Text = "終了色に設定 (白など)"
EndColBtn.TextColor3 = WHITE
EndColBtn.Font = Enum.Font.GothamBold
EndColBtn.TextSize = 9
EndColBtn.Parent = GradBox
local ecUic = Instance.new("UICorner") ecUic.CornerRadius = UDim.new(0, 4) ecUic.Parent = EndColBtn

StartColBtn.MouseButton1Click:Connect(function() gradStartColor = currentColorForPaint StartColBtn.BackgroundColor3 = gradStartColor end)
EndColBtn.MouseButton1Click:Connect(function() gradEndColor = currentColorForPaint EndColBtn.BackgroundColor3 = gradEndColor end)

local DirContainer = Instance.new("Frame")
DirContainer.Size = UDim2.new(0, 328, 0, 22)
DirContainer.Position = UDim2.new(0, 6, 0, 48)
DirContainer.BackgroundTransparency = 1
DirContainer.Parent = GradBox

local dirs = {"左→右", "上→下", "斜め", "円状", "角度指定"}
local dirBtns = {}
for _, d in ipairs(dirs) do
    local dBtn = Instance.new("TextButton")
    dBtn.Size = UDim2.new(0, 62, 0, 20)
    dBtn.BackgroundColor3 = (d == gradDirection) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 65)
    dBtn.Text = d
    dBtn.TextColor3 = WHITE
    dBtn.Font = Enum.Font.GothamBold
    dBtn.TextSize = 8
    dBtn.Parent = DirContainer
    local dUic = Instance.new("UICorner") dUic.CornerRadius = UDim.new(0, 3) dUic.Parent = dBtn

    dBtn.MouseButton1Click:Connect(function()
        gradDirection = d
        for _, b in ipairs(dirBtns) do b.BackgroundColor3 = Color3.fromRGB(60, 60, 65) end
        dBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end)
    table.insert(dirBtns, dBtn)
end

local AngleLabel = Instance.new("TextLabel")
AngleLabel.Size = UDim2.new(0, 80, 0, 16)
AngleLabel.Position = UDim2.new(0, 6, 0, 74)
AngleLabel.BackgroundTransparency = 1
AngleLabel.Text = "角度: 45°"
AngleLabel.TextColor3 = WHITE
AngleLabel.Font = Enum.Font.Gotham
AngleLabel.TextSize = 9
AngleLabel.TextXAlignment = Enum.TextXAlignment.Left
AngleLabel.Parent = GradBox

local AngleFrame = Instance.new("Frame")
AngleFrame.Size = UDim2.new(0, 240, 0, 12)
AngleFrame.Position = UDim2.new(0, 90, 0, 76)
AngleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
AngleFrame.Parent = GradBox
local afUic = Instance.new("UICorner") afUic.CornerRadius = UDim.new(0, 3) afUic.Parent = AngleFrame

local AngleSliderBtn = Instance.new("TextButton")
AngleSliderBtn.Size = UDim2.new(1, 0, 1, 0)
AngleSliderBtn.BackgroundTransparency = 1
AngleSliderBtn.Text = ""
AngleSliderBtn.Parent = AngleFrame

local isDraggingAngle = false
local function updateAngle(input)
    local relX = math.clamp((input.Position.X - AngleFrame.AbsolutePosition.X) / AngleFrame.AbsoluteSize.X, 0, 1)
    gradAngle = math.floor(relX * 360)
    AngleLabel.Text = "角度: " .. gradAngle .. "°"
end

AngleSliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingAngle = true updateAngle(input) end end)
UserInputService.InputChanged:Connect(function(input) if isDraggingAngle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateAngle(input) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingAngle = false end end)

local ModeContainer = Instance.new("Frame")
ModeContainer.Size = UDim2.new(0, 328, 0, 22)
ModeContainer.Position = UDim2.new(0, 6, 0, 94)
ModeContainer.BackgroundTransparency = 1
ModeContainer.Parent = GradBox

local modes = { 
    {id = "RGB2", name = "2色グラデーション"}, 
    {id = "RAINBOW", name = "🌈 きれいな虹色"} 
}
local modeBtns = {}
for _, m in ipairs(modes) do
    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(0, 160, 0, 20)
    mBtn.BackgroundColor3 = (m.id == gradType) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 65)
    mBtn.Text = m.name
    mBtn.TextColor3 = WHITE
    mBtn.Font = Enum.Font.GothamBold
    mBtn.TextSize = 9
    mBtn.Parent = ModeContainer
    local mUic = Instance.new("UICorner") mUic.CornerRadius = UDim.new(0, 3) mUic.Parent = mBtn

    mBtn.MouseButton1Click:Connect(function()
        gradType = m.id
        for _, b in ipairs(modeBtns) do b.BackgroundColor3 = Color3.fromRGB(60, 60, 65) end
        mBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end)
    table.insert(modeBtns, mBtn)
end

local function applyGradient()
    pushUndo()
    local rad = math.rad(gradAngle)
    local cosA, sinA = math.cos(rad), math.sin(rad)
    local maxProj = math.abs(cosA) + math.abs(sinA)

    for idx, pos in ipairs(relativePositions) do
        local alpha = 0
        if gradDirection == "左→右" then
            alpha = (pos.col - 1) / 8
        elseif gradDirection == "上→下" then
            alpha = (pos.row - 1) / 8
        elseif gradDirection == "斜め" then
            alpha = ((pos.col - 1) + (pos.row - 1)) / 16
        elseif gradDirection == "円状" then
            local dx, dy = pos.col - 5, pos.row - 5
            alpha = math.clamp(math.sqrt(dx*dx + dy*dy) / 4, 0, 1)
        elseif gradDirection == "角度指定" then
            local nx, ny = (pos.col - 5) / 4, (pos.row - 5) / 4
            local proj = nx * cosA + ny * sinA
            alpha = math.clamp((proj / maxProj + 1) / 2, 0, 1)
        end

        local finalCol = WHITE

        if gradType == "RGB2" then
            finalCol = gradStartColor:Lerp(gradEndColor, alpha)
        elseif gradType == "RAINBOW" then
            finalCol = Color3.fromHSV(alpha * 0.85, 1, 1)
        end

        CurrentWorkingGrid[idx] = finalCol
    end
    updateUIFromGrid()
end

local ApplyGradBtn = Instance.new("TextButton")
ApplyGradBtn.Size = UDim2.new(0, 328, 0, 26)
ApplyGradBtn.Position = UDim2.new(0, 6, 0, 122)
ApplyGradBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 180)
ApplyGradBtn.Text = "✨ グラデーションを適用！"
ApplyGradBtn.TextColor3 = WHITE
ApplyGradBtn.Font = Enum.Font.GothamBold
ApplyGradBtn.TextSize = 10
ApplyGradBtn.Parent = GradBox
local agUic = Instance.new("UICorner") agUic.CornerRadius = UDim.new(0, 4) agUic.Parent = ApplyGradBtn

ApplyGradBtn.MouseButton1Click:Connect(function() applyGradient() SelectedColorMode = "カスタム" end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
        if input.KeyCode == Enum.KeyCode.Z then
            if #undoStack > 0 then
                table.insert(redoStack, cloneGrid(CurrentWorkingGrid))
                CurrentWorkingGrid = table.remove(undoStack)
                updateUIFromGrid()
            end
        elseif input.KeyCode == Enum.KeyCode.Y then
            if #redoStack > 0 then
                table.insert(undoStack, cloneGrid(CurrentWorkingGrid))
                CurrentWorkingGrid = table.remove(redoStack)
                updateUIFromGrid()
            end
        end
    end
end)

local templates = {
    ["😅 お、おう"] = {
        background = YELLOW,
        pixels = {
            [{2,7}] = Color3.fromRGB(0, 180, 255), [{2,8}] = Color3.fromRGB(0, 180, 255),
            [{3,7}] = Color3.fromRGB(0, 180, 255), [{3,8}] = Color3.fromRGB(0, 180, 255),
            [{4,3}] = BLACK, [{4,7}] = BLACK, [{5,3}] = BLACK, [{5,7}] = BLACK,
            [{7,3}] = BLACK, [{7,4}] = BLACK, [{7,5}] = BLACK, [{7,6}] = BLACK, [{7,7}] = BLACK,
            [{6,2}] = BLACK, [{6,8}] = BLACK
        }
    },
    ["❤️ ハート"] = {
        background = WHITE,
        pixels = {
            [{2,3}] = RED, [{2,4}] = RED, [{2,6}] = RED, [{2,7}] = RED,
            [{3,2}] = RED, [{3,3}] = RED, [{3,4}] = RED, [{3,5}] = RED, [{3,6}] = RED, [{3,7}] = RED, [{3,8}] = RED,
            [{4,2}] = RED, [{4,3}] = RED, [{4,4}] = RED, [{4,5}] = RED, [{4,6}] = RED, [{4,7}] = RED, [{4,8}] = RED,
            [{5,2}] = RED, [{5,3}] = RED, [{5,4}] = RED, [{5,5}] = RED, [{5,6}] = RED, [{5,7}] = RED, [{5,8}] = RED,
            [{6,3}] = RED, [{6,4}] = RED, [{6,5}] = RED, [{6,6}] = RED, [{6,7}] = RED,
            [{7,4}] = RED, [{7,5}] = RED, [{7,6}] = RED,
            [{8,5}] = RED
        }
    },
    ["😄 ニッコリ"] = {
        background = YELLOW,
        pixels = {
            [{3,3}] = BLACK, [{3,7}] = BLACK, [{4,3}] = BLACK, [{4,7}] = BLACK,
            [{6,3}] = BLACK, [{7,4}] = BLACK, [{7,5}] = BLACK, [{7,6}] = BLACK, [{6,7}] = BLACK
        }
    },
    ["💀 ドクロ"] = {
        background = BLACK,
        pixels = {
            [{2,3}] = WHITE, [{2,4}] = WHITE, [{2,5}] = WHITE, [{2,6}] = WHITE, [{2,7}] = WHITE,
            [{3,2}] = WHITE, [{3,3}] = WHITE, [{3,4}] = WHITE, [{3,5}] = WHITE, [{3,6}] = WHITE, [{3,7}] = WHITE, [{3,8}] = WHITE,
            [{4,2}] = WHITE, [{4,3}] = BLACK, [{4,4}] = WHITE, [{4,5}] = WHITE, [{4,6}] = WHITE, [{4,7}] = BLACK, [{4,8}] = WHITE,
            [{5,2}] = WHITE, [{5,3}] = BLACK, [{5,4}] = WHITE, [{5,5}] = BLACK, [{5,6}] = WHITE, [{5,7}] = BLACK, [{5,8}] = WHITE,
            [{6,3}] = WHITE, [{6,4}] = WHITE, [{6,5}] = WHITE, [{6,6}] = WHITE, [{6,7}] = WHITE,
            [{7,3}] = WHITE, [{7,4}] = BLACK, [{7,5}] = WHITE, [{7,6}] = BLACK, [{7,7}] = WHITE,
            [{8,4}] = WHITE, [{8,5}] = WHITE, [{8,6}] = WHITE
        }
    },
    ["💩 うんち"] = {
        background = WHITE,
        pixels = {
            [{2,5}] = BROWN,
            [{3,4}] = BROWN, [{3,5}] = BROWN, [{3,6}] = BROWN,
            [{4,3}] = BROWN, [{4,4}] = BROWN, [{4,5}] = BROWN, [{4,6}] = BROWN, [{4,7}] = BROWN,
            [{5,2}] = BROWN, [{5,3}] = WHITE, [{5,4}] = BROWN, [{5,5}] = BROWN, [{5,6}] = WHITE, [{5,7}] = BROWN, [{5,8}] = BROWN,
            [{6,2}] = BROWN, [{6,3}] = BLACK, [{6,4}] = BROWN, [{6,5}] = BROWN, [{6,6}] = BLACK, [{6,7}] = BROWN, [{6,8}] = BROWN,
            [{7,2}] = BROWN, [{7,3}] = BROWN, [{7,4}] = RED,   [{7,5}] = RED,   [{7,6}] = BROWN, [{7,7}] = BROWN, [{7,8}] = BROWN,
            [{8,2}] = BROWN, [{8,3}] = BROWN, [{8,4}] = BROWN, [{8,5}] = BROWN, [{8,6}] = BROWN, [{8,7}] = BROWN, [{8,8}] = BROWN
        }
    },
    ["💯 100点"] = {
        background = WHITE,
        pixels = {
            [{2,2}] = RED, [{3,2}] = RED, [{4,2}] = RED, [{5,2}] = RED, [{6,2}] = RED, [{7,2}] = RED, [{8,2}] = RED,
            [{3,5}] = RED, [{4,4}] = RED, [{5,4}] = RED, [{6,5}] = RED,
            [{3,8}] = RED, [{4,6}] = RED, [{4,7}] = RED, [{5,6}] = RED, [{5,7}] = RED, [{4,9}] = RED, [{5,9}] = RED, [{6,8}] = RED,
            [{8,3}] = RED, [{8,4}] = RED, [{8,5}] = RED, [{8,6}] = RED, [{8,8}] = RED
        }
    }
}

local function applyTemplate(templateName)
    local tmpl = templates[templateName]
    if not tmpl then return end
    pushUndo()
    for idx, pos in ipairs(relativePositions) do
        CurrentWorkingGrid[idx] = tmpl.background
        for pKey, pCol in pairs(tmpl.pixels) do
            if pKey[1] == pos.row and pKey[2] == pos.col then CurrentWorkingGrid[idx] = pCol end
        end
    end
    updateUIFromGrid()
end

local TabMain = Window:MakeTab({Name = "🎮 メイン", Icon = "rbxassetid://4483345998"})
local TabAdjust = Window:MakeTab({Name = "⚙️ 形＆配置", Icon = "rbxassetid://4483345998"})
local TabBot = Window:MakeTab({Name = "🤖 BOT", Icon = "rbxassetid://4483345998"})
local TabColor = Window:MakeTab({Name = "🎨 製作", Icon = "rbxassetid://4483345998"})
local TabGuide = Window:MakeTab({Name = "📖 説明書", Icon = "rbxassetid://4483345998"})
local TabDev = Window:MakeTab({Name = "💻 開発者", Icon = "rbxassetid://4483345998"})

local function getCustomFaceNames()
    local names = {} for k,v in pairs(customFaces) do table.insert(names, k) end
    if #names == 0 then table.insert(names, "(保存データなし)") end
    return names
end

local selectedLoadName = ""

TabMain:AddSection({ Name = "🚀 スイッチ" })
TabMain:AddToggle({ 
    Name = "ダイスでキャンバスを作る（69個必要）", Default = false, 
    Callback = function(Value) 
        MainEnabled = Value 
        if not Value then disablePhysicsAndDrop() else for _, d in ipairs(AllDice) do if d and d.Parent then setupPhysics(d) end end end
    end 
})

TabMain:AddToggle({ 
    Name = "色をつける(家出る前にOFFにするのと家バリアは破壊しといて。)", Default = false, 
    Callback = function(V) ColorSyncEnabled = V end 
})

TabMain:AddDropdown({ 
    Name = "プリセット", Default = "ゆざまい", 
    Options = {"ゆざまい", "いもすけ", "ゆずぴー", "カスタム"}, 
    Callback = function(Value) SelectedColorMode = Value end 
})

TabMain:AddSection({ Name = "💾 保存データ管理" })

local LoadDropdown = TabMain:AddDropdown({ 
    Name = "保存したデータ一覧", 
    Default = "", 
    Options = getCustomFaceNames(), 
    Callback = function(Value) 
        selectedLoadName = Value 
        if selectedLoadName ~= "" and selectedLoadName ~= "(保存データなし)" and customFaces[selectedLoadName] then
            for i=1, 69 do 
                activeCustomFace[i] = customFaces[selectedLoadName][i] 
                CurrentWorkingGrid[i] = activeCustomFace[i] 
            end
            updateUIFromGrid() 
            SelectedColorMode = "カスタム"
        end
    end 
})

TabMain:AddButton({
    Name = "🗑️ 選択中のデータを消す",
    Callback = function()
        if selectedLoadName ~= "" and selectedLoadName ~= "(保存データなし)" and customFaces[selectedLoadName] then
            customFaces[selectedLoadName] = nil 
            saveFacesToFile()
            if LoadDropdown then LoadDropdown:Refresh(getCustomFaceNames(), true) end
            selectedLoadName = ""
            OrionLib:MakeNotification({Name = "削除完了", Content = "データを削除しました", Time = 3})
        end
    end
})

TabMain:AddSection({ Name = "✨ 動き・演出" })
TabMain:AddToggle({ Name = "アニメーションをつける", Default = false, Callback = function(V) SineWaveEnabled = V end })
TabMain:AddDropdown({ Name = "動きのタイプ", Default = "波", Options = {"波", "回転", "パルス", "分散", "逆竜巻"}, Callback = function(Value) AnimMode = Value end })
TabMain:AddSlider({ Name = "スピード", Min = 1, Max = 10, Default = 4, Color = Color3.fromRGB(255, 170, 0), Increment = 0.5, Callback = function(V) animSpeed = V end })
TabMain:AddSlider({ Name = "動きの大きさ", Min = 1, Max = 10, Default = 4, Color = Color3.fromRGB(255, 170, 0), Increment = 0.5, Callback = function(V) animHeight = V end })

TabAdjust:AddSection({ Name = "🧊 見た目の形" })
TabAdjust:AddDropdown({ Name = "かたち", Default = "平面", Options = {"平面", "球体", "直方体"}, Callback = function(V) ShapeMode = V end })
TabAdjust:AddToggle({ Name = "ダイスを全部正面に向かせる", Default = true, Callback = function(V) FaceFrontOnly = V end })

TabAdjust:AddSection({ Name = "📐 位置とかサイズ調整" })
TabAdjust:AddSlider({ Name = "ダイスの間隔・大きさ", Min = 1, Max = 15, Default = 4, Color = Color3.fromRGB(0, 162, 255), Increment = 0.5, Callback = function(Value) settings.gridSize = Value end })
TabAdjust:AddSlider({ Name = "高さ（Y軸）", Min = 0, Max = 100, Default = 20, Color = Color3.fromRGB(0, 162, 255), Increment = 1, Callback = function(Value) settings.height = Value settings.targetHeight = Value end })
TabAdjust:AddSlider({ Name = "奥行き（Z軸）", Min = -50, Max = 50, Default = -15, Color = Color3.fromRGB(0, 162, 255), Increment = 1, Callback = function(Value) settings.depth = Value end })

TabBot:AddSection({ Name = "🤖 BOT" })
TabBot:AddToggle({ 
    Name = "🤖 BOTモード", Default = false, 
    Callback = function(Value) 
        BotModeEnabled = Value 
        if Value then
            local char = plr.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                if root then
                    botCFrame = root.CFrame * CFrame.new(0, 10, -10)
                    chooseNewBotAction(botCFrame.Position)
                end
            end
        end
    end 
})

TabBot:AddSection({ Name = "🎯 追従・固定" })
playerDropdown = TabBot:AddDropdown({ Name = "ターゲット", Default = "選んでね", Options = getPlayerList(), Callback = function(V) SelectedTargetPlayer = getPlayerFromFormat(V) end })
TabBot:AddToggle({ Name = "フォロー", Default = false, Callback = function(V) FollowTargetEnabled = V end })
TabBot:AddToggle({ Name = "目線", Default = false, Callback = function(V) EyeTrackEnabled = V end })
TabBot:AddToggle({
    Name = "固定", Default = false,
    Callback = function(Value)
        StayInPlaceEnabled = Value
        if Value then local char = plr.Character if char then local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") if root then fixedCFrame = root.CFrame end end
        else fixedCFrame = nil end
    end
})

TabColor:AddSection({ Name = "✏️ プロ仕様キャンバス" })
TabColor:AddButton({ Name = "🎨 キャンバスを開く / 閉じる", Callback = function() PaintScreen.Enabled = not PaintScreen.Enabled end })

TabColor:AddSection({ Name = "🖼️ テンプレート" })
local tmplList = {"😅 お、おう", "❤️ ハート", "😄 ニッコリ", "💀 ドクロ", "💩 うんち", "💯 100点"}
for _, tName in ipairs(tmplList) do
    TabColor:AddButton({ Name = "▶ " .. tName, Callback = function() applyTemplate(tName) SelectedColorMode = "カスタム" end })
end

TabColor:AddSection({ Name = "📋 コード共有" })

TabColor:AddButton({
    Name = "画像ドット絵変換サイト（製作ゆざまい）",
    Callback = function()
        local url = "https://capable-choux-1974bf.netlify.app/"
        if setclipboard then
            setclipboard(url)
            OrionLib:MakeNotification({Name = "コピー完了", Content = "URLをクリップボードにコピーしました！", Time = 3})
        end
    end
})

local shareCodeInput = ""
TabColor:AddTextbox({ Name = "コード貼り付け欄", Default = "", TextDisappear = false, Callback = function(Value) shareCodeInput = Value end })
TabColor:AddButton({
    Name = "📋 コードをキャンバスに読み込む",
    Callback = function()
        if shareCodeInput == "" then return end
        local s, decoded = pcall(function() return HttpService:JSONDecode(shareCodeInput) end)
        if s and type(decoded) == "table" and #decoded == 69 then
            pushUndo()
            for i = 1, 69 do 
                if decoded[i] then
                    CurrentWorkingGrid[i] = Color3.fromRGB(decoded[i][1] or 255, decoded[i][2] or 255, decoded[i][3] or 255)
                    activeCustomFace[i] = CurrentWorkingGrid[i]
                end
            end
            updateUIFromGrid() 
            SelectedColorMode = "カスタム"
        end
    end
})

TabColor:AddButton({
    Name = "📤 今の絵をコードにしてコピー",
    Callback = function()
        local exportData = {}
        for i = 1, 69 do local g = CurrentWorkingGrid[i] or WHITE table.insert(exportData, {math.floor(g.R*255), math.floor(g.G*255), math.floor(g.B*255)}) end
        if setclipboard then setclipboard(HttpService:JSONEncode(exportData)) OrionLib:MakeNotification({Name = "コピー完了", Content = "クリップボードに保存しました！", Time = 3}) end
    end
})

TabColor:AddSection({ Name = "💾 データ保存" })
local saveNameBox, saveNameInput = nil, "MyFace1"
saveNameBox = TabColor:AddTextbox({ Name = "保存する名前", Default = "MyFace1", TextDisappear = false, Callback = function(Value) saveNameInput = Value end })

TabColor:AddButton({
    Name = "💾 セーブ",
    Callback = function()
        if saveNameInput == "" or saveNameInput == " " then return end
        local newGrid = {} for i=1, 69 do newGrid[i] = CurrentWorkingGrid[i] or WHITE end
        customFaces[saveNameInput] = newGrid
        saveFacesToFile()
        if LoadDropdown then LoadDropdown:Refresh(getCustomFaceNames(), true) end
        OrionLib:MakeNotification({Name = "セーブ完了", Content = saveNameInput .. " を保存したよ", Time = 3})
    end
})

TabGuide:AddSection({ Name = "🎮 1. メイン タブ" })
TabGuide:AddLabel("・ダイスでキャンバスを作る: ONで近くのダイス(69個)を集めて組み立てます。")
TabGuide:AddLabel("・色をつける: 作成したキャンバスやプリセットの色を実物に送信・反映します。")
TabGuide:AddLabel("・プリセット: 【ゆざまい/いもすけ/ゆずぴー】などの固定カラーや【カスタム】を切り替えます。")
TabGuide:AddLabel("・保存したデータ一覧: ファイル保存した自作の絵を読み込みます。")
TabGuide:AddLabel("・アニメーションをつける: キャンバス全体に動的なモーションを付けます。")
TabGuide:AddLabel("  ├ 波: Sin波状に上下にゆらゆら揺れます。")
TabGuide:AddLabel("  ├ 回転 / パルス: 全体が回転したり伸縮（拡大縮小）します。")
TabGuide:AddLabel("  └ 逆竜巻: ダイスが立体的な竜巻状に渦を巻いて上昇します。")

TabGuide:AddSection({ Name = "⚙️ 2. 形＆配置 タブ" })
TabGuide:AddLabel("・かたち: 平面、お面、箱の三つの形を選べるよ。好きな形にしよう")
TabGuide:AddLabel("・ダイスを正面に向かせる: ONで常にダイスの正面をカメラに向けます。")
TabGuide:AddLabel("・位置・サイズ調整: 間隔・高さ(Y軸)・奥行き(Z軸)をスライダーで細かく調整できます。")

TabGuide:AddSection({ Name = "🤖 3. BOT タブ" })
TabGuide:AddLabel("・BOTモード: プレイヤーや混雑場所へ移動したり、たまにアニメーションをするよ")
TabGuide:AddLabel("・ターゲット/フォロー: 特定のプレイヤーを選び、その頭上へ自動追従します。")
TabGuide:AddLabel("・目線: 指定プレイヤーの方向へ顔の目パーツを動かします。")
TabGuide:AddLabel("・固定: プレイヤーが移動しても、キャンバスの位置をその場に固定します。")

TabGuide:AddSection({ Name = "🎨 4. 製作タブ" })
TabGuide:AddLabel("・キャンバスを開く/閉じる: ドット絵を描くメインUIを画面に表示します。")
TabGuide:AddLabel("・テンプレート: 😅・❤️・💀 などの完成図をワンタップでキャンバスに書かれるよ")
TabGuide:AddLabel("・コード共有: 外部サイトで画像から変換したJSONコードを読み書きできます。")
TabGuide:AddLabel("【🖌️ キャンバス内の描画ツール機能】")
TabGuide:AddLabel("  ├ ✏️ ペン: クリックしたマスを塗ります。(ブラシサイズ変更可能)")
TabGuide:AddLabel("  ├ 🧽 消しゴム: 塗った場所を白(背景色)に戻します。")
TabGuide:AddLabel("  ├ 🪣 バケツ: 繋がっている同じ色のマスを一括で塗りつぶします。")
TabGuide:AddLabel("  ├ 🧪 スポイト: クリックしたマスの色を取得して現在のペン色にします。")
TabGuide:AddLabel("  ├ 📏 直線: 1回目のクリックで始点、2回目で終点を選んで直線を引きます。")
TabGuide:AddLabel("  ├ 🔲 ⬛ 四角(枠/全): 2点間で四角形の枠線、または塗りつぶし四角を描きます。")
TabGuide:AddLabel("  ├ ⭕ 🔴 円(枠/全): 2点間で美しい円の枠線、または塗りつぶし円を描きます。")
TabGuide:AddLabel("  ├ ↩️ Undo / ↪️ Redo: 操作を戻す / やり直します。(Ctrl+Z / Ctrl+Y対応)")
TabGuide:AddLabel("  ├ 🔄 回転 / ↔️ ↕️ 反転: 90度回転や上下左右の反転を即座に行います。")
TabGuide:AddLabel("  └ 🌈 グラデーション: 2色または虹色で、全方向・角度指定でグラデーションを作成します。")

TabDev:AddSection({ Name = "👤 いんふぉ" })
TabDev:AddLabel("ツール名: ダイスでお絵描き😅")
TabDev:AddLabel("つくったひと: ゆざまい (yuzamai11)")

Players.PlayerAdded:Connect(function() if playerDropdown then playerDropdown:Refresh(getPlayerList(), true) end end)
Players.PlayerRemoving:Connect(function() if playerDropdown then playerDropdown:Refresh(getPlayerList(), true) end end)

local scanTimer = 0

RunService.Heartbeat:Connect(function(dt)
    if not MainEnabled then return end
    animTime = animTime + dt

   
    cleanupDiceList()

    local currentBaseCFrame = CFrame.new()

    if BotModeEnabled then
        botTimer = botTimer + dt
        if botTimer >= botActionDuration then chooseNewBotAction(botCFrame.Position) end

        local currPos = botCFrame.Position
        local targetPos = currPos

       
        local _, crowdCount = getCrowdCenterPosition()
        local targetHeight = botDefaultHeight
        if botAction == "FOLLOW" or crowdCount >= 3 then
            targetHeight = botHighOffset
        end
        botCurrentHeight = botCurrentHeight + (targetHeight - botCurrentHeight) * math.min(dt * 3, 1)

     
        if isExecutingSpecialAction and botFollowPlayer and botFollowPlayer.Character then
            local pRoot = botFollowPlayer.Character:FindFirstChild("HumanoidRootPart")
            if pRoot then
                if botAction == "ORBIT_PLAYER" then
                    orbitAngle = orbitAngle + dt * 200
                    local rad = math.rad(orbitAngle)
                    local radius = 12
                    local x = pRoot.Position.X + math.cos(rad) * radius
                    local z = pRoot.Position.Z + math.sin(rad) * radius
                    targetPos = Vector3.new(x, pRoot.Position.Y + botCurrentHeight, z)
                    
                    local lookDir = (pRoot.Position - targetPos)
                    currentRotationY = math.atan2(-lookDir.X, -lookDir.Z)

                elseif botAction == "LOOP_THE_LOOP" then
                    specialActionProgress = math.clamp(specialActionProgress + dt / botActionDuration, 0, 1)
                    loopPitch = specialActionProgress * math.pi * 2
                    targetPos = currPos:Lerp(pRoot.Position + Vector3.new(0, botCurrentHeight, -10), dt * 1.2)
                    local lookDir = (pRoot.Position - currPos)
                    currentRotationY = math.atan2(-lookDir.X, -lookDir.Z)
                end
            end
            botCFrame = CFrame.new(targetPos) * CFrame.Angles(loopPitch, currentRotationY, 0)

        
        else
            if botAction == "GHAST_FLOAT" or botAction == "GO_TO_CROWD" then
                local floatY = math.sin(animTime * 1.5) * 2.0
                targetPos = currPos:Lerp(Vector3.new(botMoveTarget.X, botMoveTarget.Y + botCurrentHeight + floatY, botMoveTarget.Z), dt * 0.5)
                local moveVector = (botMoveTarget - currPos)
                if moveVector.Magnitude > 3 then
                    local targetRot = math.atan2(-moveVector.X, -moveVector.Z)
                    currentRotationY = currentRotationY + (targetRot - currentRotationY) * dt * 1.2
                end

            elseif botAction == "LOOK_AT_PLAYER" then
               
                targetPos = currPos:Lerp(currPos + Vector3.new(0, math.sin(animTime * 1.5) * 0.5, 0), dt * 0.5)
                local nearestPlr = getNearestPlayer(currPos)
                
                if nearestPlr and nearestPlr.Character then
                    local nRoot = nearestPlr.Character:FindFirstChild("HumanoidRootPart")
                    if nRoot then
                        local lookDir = (nRoot.Position - currPos)
                        local targetRot = math.atan2(-lookDir.X, -lookDir.Z)
                       
                        currentRotationY = currentRotationY + (targetRot - currentRotationY) * dt * 3.0
                    end
                end

            elseif botAction == "FOLLOW" and botFollowPlayer and botFollowPlayer.Character then
                local pRoot = botFollowPlayer.Character:FindFirstChild("HumanoidRootPart")
                if pRoot then
                    targetPos = currPos:Lerp(pRoot.Position + Vector3.new(0, botCurrentHeight + math.sin(animTime * 2) * 2.5, 15), dt * 0.8)
                    local moveVector = (pRoot.Position - currPos)
                    local targetRot = math.atan2(-moveVector.X, -moveVector.Z)
                    currentRotationY = currentRotationY + (targetRot - currentRotationY) * dt * 1.5
                end
            end

            botCFrame = CFrame.new(targetPos) * CFrame.Angles(0, currentRotationY, 0)
        end

        currentBaseCFrame = botCFrame

    else
        isLookingAtPlayer = false
        local target = ColorSyncEnabled and 10 or settings.targetHeight
        settings.height = settings.height + (target - settings.height) * math.min(dt * 5, 1)

        local targetChar = plr.Character
        if FollowTargetEnabled and SelectedTargetPlayer and SelectedTargetPlayer.Character then targetChar = SelectedTargetPlayer.Character end
        if not targetChar then return end
        local root = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso") if not root then return end

        currentBaseCFrame = root.CFrame
        if StayInPlaceEnabled then
            if not fixedCFrame then fixedCFrame = root.CFrame end
            currentBaseCFrame = fixedCFrame
        end

        local targetEyeOffset = Vector2.new(0, 0)
        if EyeTrackEnabled and SelectedTargetPlayer and SelectedTargetPlayer.Character then
            local targetRoot = SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local localPos = currentBaseCFrame:PointToObjectSpace(targetRoot.Position)
                local dir = Vector3.new(localPos.X, localPos.Y, localPos.Z).Unit
                targetEyeOffset = Vector2.new(math.clamp(dir.X * 1.2, -0.6, 0.6), math.clamp(dir.Y * 1.2, -0.6, 0.6))
            end
        end
        eyeOffset = eyeOffset:Lerp(targetEyeOffset, math.min(dt * 8, 1))
    end

    scanTimer = scanTimer + dt
    if scanTimer >= 0.1 then
        scanTimer = 0
        if #AllDice < #relativePositions then
            local myChar = plr.Character
            local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
            if myRoot then
                for _,p in ipairs(workspace:GetPartBoundsInRadius(myRoot.Position, settings.wingRange)) do
                    if isSelectableDice(p, myChar) then addDiceToList(p) end
                end
            end
        end
    end

    for i,d in ipairs(AllDice) do
        if d and d.Parent then
            local bv = d:FindFirstChild("DiceForce")
            local bg = d:FindFirstChild("DiceGyro")
            local pos,cf = calculateGridPosition(i, currentBaseCFrame, animTime)
            if bv and pos then bv.Velocity = (pos - d.Position)*25 end
            if bg and cf then bg.CFrame = cf end
        end
    end
end)


task.spawn(function()
    while true do
        if MainEnabled and ColorSyncEnabled then
            cleanupDiceList() 
            for i,d in ipairs(AllDice) do
                local slot = relativePositions[i]
                if d and d.Parent and slot then
                    local color = getColor(slot, i)
                    local seq = ColorSequence.new(color)
                    if LineColorEvent then
                        pcall(function() LineColorEvent:FireServer(seq,color,color,color,color,color,color,color,color,color) end)
                    end
                    if SetOwnerEvent then
                        pcall(function() SetOwnerEvent:FireServer(d,d.CFrame) end)
                    end
                end
            end
            task.wait(0.2)
        else
            task.wait(0.5)
        end
    end
end)