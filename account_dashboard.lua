-- Roblox 自分用アカウント情報ダッシュボード
-- Cookie / 認証トークンは取得しない
-- 他者への送信機能なし

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

if not UserInputService.TouchEnabled then
    Notify("アカウント情報", "このGUIはモバイル専用です。", 5)
    return
end

local httpRequest = request or http_request or (syn and syn.request)

local function Request(options)
    if not httpRequest then return nil end
    local success, response = pcall(function()
        return httpRequest(options)
    end)
    if success and response then return response end
    return nil
end

local function GetJSON(url)
    local response = Request({
        Url = url,
        Method = "GET",
        Headers = {["Accept"] = "application/json"}
    })
    if not response then return nil end
    local body = response.Body or response.body
    if not body then return nil end
    local success, result = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if success then return result end
    return nil
end

local function PostJSON(url, data)
    local response = Request({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        },
        Body = HttpService:JSONEncode(data)
    })
    if not response then return nil end
    local body = response.Body or response.body
    if not body then return nil end
    local success, result = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if success then return result end
    return nil
end

local CoreGui = game:GetService("CoreGui")
local old = CoreGui:FindFirstChild("AccountInfoDashboard")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AccountInfoDashboard"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.92, 0, 0.72, 0)
Main.Position = UDim2.new(0.04, 0, 0.14, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 18)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "アカウント情報"
Title.TextColor3 = Color3.fromRGB(240, 242, 248)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local function MakeHeaderButton(text, x, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 42, 0, 38)
    button.Position = UDim2.new(1, x, 0.5, -19)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1,1,1)
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.Parent = Header
    Instance.new("UICorner", button).CornerRadius = UDim.new(0,11)
    return button
end

local MinimizeButton = MakeHeaderButton("−", -142, Color3.fromRGB(58,63,78))
local ToggleButton = MakeHeaderButton("◉", -94, Color3.fromRGB(55,100,210))
local CloseButton = MakeHeaderButton("×", -46, Color3.fromRGB(190,58,66))

local Log = Instance.new("ScrollingFrame")
Log.Size = UDim2.new(1,-24,1,-132)
Log.Position = UDim2.new(0,12,0,70)
Log.BackgroundColor3 = Color3.fromRGB(13,15,20)
Log.BorderSizePixel = 0
Log.ScrollBarThickness = 4
Log.AutomaticCanvasSize = Enum.AutomaticSize.Y
Log.Parent = Main
Instance.new("UICorner", Log).CornerRadius = UDim.new(0,12)

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1,-24,0,0)
LogText.Position = UDim2.new(0,12,0,12)
LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.BackgroundTransparency = 1
LogText.TextColor3 = Color3.fromRGB(210,216,230)
LogText.TextSize = 14
LogText.Font = Enum.Font.Code
LogText.TextWrapped = true
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Text = "アカウント情報を取得しています..."
LogText.Parent = Log

local ButtonArea = Instance.new("Frame")
ButtonArea.Size = UDim2.new(1,-24,0,50)
ButtonArea.Position = UDim2.new(0,12,1,-56)
ButtonArea.BackgroundTransparency = 1
ButtonArea.Parent = Main

local function MakeBottomButton(text, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.49,0,1,0)
    b.Position = pos
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.Parent = ButtonArea
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
    return b
end

local CopyButton = MakeBottomButton("JSONをコピー", UDim2.new(0,0,0,0), Color3.fromRGB(52,91,210))
local OutputButton = MakeBottomButton("HTML用JSON", UDim2.new(0.51,0,0,0), Color3.fromRGB(42,157,103))

local dragging, dragStart, startPosition = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)
Header.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local CurrentJSON = "{}"
local running = true

local function ISODateToUnix(dateString)
    if type(dateString) ~= "string" then return nil end
    local y,m,d = dateString:match("^(%d+)%-(%d+)%-(%d+)")
    if not y then return nil end
    local ok, ts = pcall(function()
        return DateTime.fromUniversalTime(tonumber(y),tonumber(m),tonumber(d),0,0,0).UnixTimestamp
    end)
    if ok then return ts end
end

local function GetAccountAge(created)
    local createdUnix = ISODateToUnix(created)
    if not createdUnix then return {days=0,years=0,months=0,weeks=0,hours=0} end
    local seconds = math.max(0, os.time() - createdUnix)
    local days = math.floor(seconds/86400)
    return {
        days=days,
        years=math.floor((days/365.2425)*100)/100,
        months=math.floor((days/30.436875)*100)/100,
        weeks=math.floor((days/7)*100)/100,
        hours=math.floor(seconds/3600)
    }
end

local function GetFriends(userId)
    local friends = {}
    local data = GetJSON("https://friends.roblox.com/v1/users/"..tostring(userId).."/friends")
    if data and type(data.data) == "table" then
        for _, friend in ipairs(data.data) do
            table.insert(friends, {id=friend.id, username=friend.name or "", displayName=friend.displayName or friend.name or ""})
        end
    end
    return friends
end

local function GetPresence(friends)
    local ids, presenceMap = {}, {}
    for _,f in ipairs(friends) do table.insert(ids,f.id) end
    for s=1,#ids,100 do
        local chunk={}
        for i=s,math.min(s+99,#ids) do table.insert(chunk,ids[i]) end
        local result=PostJSON("https://presence.roblox.com/v1/presence/users",{userIds=chunk})
        if result and type(result.userPresences)=="table" then
            for _,p in ipairs(result.userPresences) do presenceMap[p.userId]=p.userPresenceType or 0 end
        end
    end
    return presenceMap
end

local function GetLocation()
    local data=GetJSON("https://ipwho.is/")
    if data and data.success~=false then
        return {latitude=tonumber(data.latitude),longitude=tonumber(data.longitude)}
    end
    return {latitude=nil,longitude=nil}
end

local function CollectData()
    local userId=LocalPlayer.UserId
    local info=GetJSON("https://users.roblox.com/v1/users/"..tostring(userId))
    local username=LocalPlayer.Name
    local displayName=LocalPlayer.DisplayName
    local created=""
    if info then
        username=info.name or username
        displayName=info.displayName or displayName
        created=info.created or ""
    end
    local age=GetAccountAge(created)
    local friends=GetFriends(userId)
    local presence=GetPresence(friends)
    local online,offline=0,0
    for _,f in ipairs(friends) do
        if (presence[f.id] or 0)>0 then online+=1 else offline+=1 end
    end
    local firstTen={}
    for i=1,math.min(10,#friends) do
        local f=friends[i]
        table.insert(firstTen,{displayName=f.displayName,username=f.username,id=f.id})
    end
    local loc=GetLocation()
    local premium=LocalPlayer.MembershipType==Enum.MembershipType.Premium
    return {
        player={
            username=username,displayName=displayName,userId=userId,
            createdDate=created:match("^(%d%d%d%d%-%d%d%-%d%d)") or created,
            accountAge=age,membership=premium and "Premium" or "通常",premium=premium
        },
        friends={total=#friends,online=online,offline=offline,first10=firstTen},
        location=loc,
        collectedAt=os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
end

local function BuildLog(data)
    local p,f,l=data.player,data.friends,data.location
    local lines={
        "【プレイヤー】","表示名: "..tostring(p.displayName),"ユーザー名: @"..tostring(p.username),"UserId: "..tostring(p.userId),"",
        "【アカウント】","作成日: "..tostring(p.createdDate),"経過日数: "..p.accountAge.days.."日","年換算: "..p.accountAge.years.."年",
        "月換算: "..p.accountAge.months.."か月","週換算: "..p.accountAge.weeks.."週","時間換算: "..p.accountAge.hours.."時間",
        "メンバーシップ: "..p.membership,"","【フレンド】","総数: "..f.total,"オンライン: "..f.online,"オフライン: "..f.offline,"","【先頭10件】"
    }
    for i,fr in ipairs(f.first10) do
        table.insert(lines,i..". "..fr.displayName.." (@"..fr.username..") ["..fr.id.."]")
    end
    table.insert(lines,"")
    table.insert(lines,"【IPベース位置情報】")
    table.insert(lines,l.latitude and ("緯度: "..l.latitude) or "緯度: -")
    table.insert(lines,l.longitude and ("経度: "..l.longitude) or "経度: -")
    table.insert(lines,"")
    table.insert(lines,"取得時刻: "..data.collectedAt)
    table.insert(lines,"3秒ごとに自動更新")
    return table.concat(lines,"\n")
end

local function Update()
    local ok,result=pcall(CollectData)
    if ok and result then
        CurrentJSON=HttpService:JSONEncode(result)
        LogText.Text=BuildLog(result)
    else
        Notify("取得エラー","アカウント情報の更新中にエラーが発生しました。",3)
    end
end

CopyButton.Activated:Connect(function()
    setclipboard(CurrentJSON)
    Notify("コピー完了","現在のJSONをクリップボードへコピーしました。",3)
end)
OutputButton.Activated:Connect(function()
    setclipboard(CurrentJSON)
    Notify("HTML用JSON","JSONをコピーしました。HTMLの入力欄へ貼り付けてください。",4)
end)

local minimized=false
MinimizeButton.Activated:Connect(function()
    minimized=not minimized
    Log.Visible=not minimized
    ButtonArea.Visible=not minimized
    Main.Size=minimized and UDim2.new(0.92,0,0,58) or UDim2.new(0.92,0,0.72,0)
    MinimizeButton.Text=minimized and "+" or "−"
end)

local visible=true
ToggleButton.Activated:Connect(function()
    visible=not visible
    Log.Visible=visible and not minimized
    ButtonArea.Visible=visible and not minimized
    Title.Text=visible and "アカウント情報" or "アカウント情報 [OFF]"
end)

CloseButton.Activated:Connect(function()
    running=false
    Notify("終了","アカウント情報ダッシュボードを終了しました。",3)
    ScreenGui:Destroy()
end)

Notify("アカウント情報","情報取得を開始しました。",3)
task.spawn(Update)
task.spawn(function()
    while running do
        task.wait(3)
        if running then Update() end
    end
end)
