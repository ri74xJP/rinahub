--[[
    本気おもちゃ回転ハブ【2系統】完全版
    梯子多層陣 / 巨大の手 / 手ボタン / デュアルサイド / 流星放射 / 説明タブ
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local LP = LocalPlayer

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

local Theme = {
    BackgroundColor = Color3.fromRGB(255, 255, 255),
    SliderColor     = Color3.fromRGB(0, 0, 0),
    TextColor       = Color3.fromRGB(0, 0, 0),
}

----------------------------------------------------------------
-- 日本語表示名 ↔ ID
----------------------------------------------------------------
local ObjectDisplay = {
    {jp = "線香花火",                id = "FireworkSparkler"},
    {jp = "薄い茶色パレット",        id = "PalletLightBrown"},
    {jp = "グレーガラス箱",          id = "GlassBoxGray"},
    {jp = "音楽キーボード",          id = "MusicKeyboard"},
    {jp = "不気味なロウソク①",      id = "SpookyCandle1"},
    {jp = "テトラキューブ",          id = "Tetracube1"},
    {jp = "忍者刀",                  id = "NinjaKatana"},
    {jp = "おとり人形",              id = "YouDecoy"},
    {jp = "爆弾ミサイル",            id = "BombMissile"},
    {jp = "薄い茶色ハシゴ",          id = "LadderLightBrown"},
    {jp = "ブロブマン",              id = "CreatureBlobman"},
    {jp = "ディスコカラーボール",    id = "DiscoColorBall"},
    {jp = "ピンク鉱物クリスタル",    id = "MineralCrystalPink"},
    {jp = "浮遊島",                  id = "FloatingIsland"},
    {jp = "飛行UFO",                 id = "FlyingToyUfo"},
    {jp = "青ジュークボックス",      id = "JukeboxBlue"},
    {jp = "オレンジジュークボックス",id = "JukeboxOrange"},
    {jp = "青ソファ",                id = "CouchBlue"},
    {jp = "ピンクソファ",            id = "CouchPink"},
    {jp = "白ソファ",                id = "CouchWhite"},
    {jp = "ブームボックス",          id = "Boombox"},
    {jp = "花火ミサイル",            id = "FireworkMissile"},
    {jp = "雪の結晶",                id = "Snowflake"},
    {jp = "不気味なロウソク⑤",      id = "SpookyCandle5"},
    {jp = "ダイヤモンド鉱物",        id = "MineralDiamond"},
    {jp = "緑トラクター",            id = "TractorGreen"},
    {jp = "オレンジトラクター",      id = "TractorOrange"},
    {jp = "赤トラクター",            id = "TractorRed"},
}

local function getJapaneseName(id)
    for _, item in ipairs(ObjectDisplay) do
        if item.id == id then return item.jp end
    end
    return id
end

----------------------------------------------------------------
-- 形状定義
----------------------------------------------------------------
local Shapes = {}

Shapes["円形"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    return Vector3.new(math.cos(a)*cfg.Radius, cfg.Height, math.sin(a)*cfg.Radius)
end

Shapes["羽"] = function(i, count, t, cfg)
    local half = math.floor(count/2)
    local x = (i - half - 0.5) * (cfg.Radius * 0.35)
    local wave = math.sin(t * cfg.Speed + i*0.4) * cfg.Pulse * 2
    return Vector3.new(x, cfg.Height + wave, -cfg.Radius * 0.6)
end

Shapes["ハート"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    local s = cfg.Radius / 16
    local x = 16 * math.sin(a)^3 * s
    local y = (13*math.cos(a) - 5*math.cos(2*a) - 2*math.cos(3*a) - math.cos(4*a)) * s
    local pulse = 1 + math.sin(t*cfg.Speed*1.5)*cfg.Pulse*0.15
    return Vector3.new(x*pulse, cfg.Height + y*pulse, 0)
end

Shapes["ビッグハート"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed * 0.6
    local s = cfg.Radius / 12
    local x = 16 * math.sin(a)^3 * s
    local y = (13*math.cos(a) - 5*math.cos(2*a) - 2*math.cos(3*a) - math.cos(4*a)) * s * 1.3
    local pulse = 1 + math.sin(t*2)*cfg.Pulse*0.2
    return Vector3.new(x*pulse, cfg.Height + y*pulse, 0)
end

Shapes["ダビデの星"] = function(i, count, t, cfg)
    local a = (i-1)/6 * math.pi*2 + t * cfg.Speed
    local r = cfg.Radius * (i%2==0 and 1 or 0.55)
    local h = (i%2==0 and 1 or -1) * cfg.Pulse
    return Vector3.new(math.cos(a)*r, cfg.Height + h, math.sin(a)*r)
end

Shapes["五芒星"] = function(i, count, t, cfg)
    local idx = (i-1) % 10
    local isOuter = idx % 2 == 0
    local a = idx * (math.pi / 5) + t * cfg.Speed
    local r = isOuter and cfg.Radius or cfg.Radius * 0.4
    local tw = 1 + math.sin(t*3 + i)*0.12
    return Vector3.new(math.cos(a)*r*tw, cfg.Height, math.sin(a)*r*tw)
end

Shapes["球体"] = function(i, count, t, cfg)
    local side = math.ceil(math.sqrt(count))
    local lat = math.floor((i-1) / side)
    local lon = (i-1) % side
    local la = (lat / side - 0.5) * math.pi
    local lo = lon / side * math.pi*2 + t * cfg.Speed
    local r = cfg.Radius * (1 + math.sin(t*2)*cfg.Pulse*0.1)
    return Vector3.new(
        r * math.cos(la) * math.cos(lo),
        cfg.Height + r * math.sin(la),
        r * math.cos(la) * math.sin(lo)
    )
end

Shapes["螺旋"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*8 + t * cfg.Speed
    local h = ((i-1)/count - 0.5) * cfg.Radius * 2.2
    local r = cfg.Radius * 0.7
    return Vector3.new(math.cos(a)*r, cfg.Height + h, math.sin(a)*r)
end

Shapes["無限大"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    local scale = cfg.Radius * 0.7
    local x = scale * math.sin(a)
    local z = scale * math.sin(a) * math.cos(a)
    local y = math.sin(a*2) * cfg.Pulse
    return Vector3.new(x, cfg.Height + y, z)
end

Shapes["花びら"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    local r = cfg.Radius * (0.4 + 0.6 * math.abs(math.sin(a * 6)))
    local open = 1 + math.sin(t*1.2)*cfg.Pulse*0.3
    return Vector3.new(math.cos(a)*r*open, cfg.Height + math.sin(a*3)*0.8, math.sin(a)*r*open)
end

Shapes["ピラミッド"] = function(i, count, t, cfg)
    local layers = 4
    local layer = math.floor((i-1) / (count/layers))
    local inLayer = (i-1) % math.ceil(count/layers)
    local layerCount = math.ceil(count/layers)
    local a = inLayer / layerCount * math.pi*2 + t * cfg.Speed * 0.5
    local r = cfg.Radius * (1 - layer/(layers-1)) * 0.9
    local h = layer * (cfg.Radius * 0.55)
    return Vector3.new(math.cos(a)*r, cfg.Height + h, math.sin(a)*r)
end

Shapes["ドーナツ"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    local tube = cfg.Radius * 0.28
    local R = cfg.Radius * 0.75
    local x = (R + tube * math.cos(a*3)) * math.cos(a)
    local z = (R + tube * math.cos(a*3)) * math.sin(a)
    local y = tube * math.sin(a*3)
    return Vector3.new(x, cfg.Height + y, z)
end

Shapes["波"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    local wave = math.sin(a*3 + t*2) * cfg.Pulse * 3
    return Vector3.new(math.cos(a)*cfg.Radius, cfg.Height + wave, math.sin(a)*cfg.Radius)
end

Shapes["蝶"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2
    local wing = math.sin(t * cfg.Speed * 2)
    local x = math.sin(a) * cfg.Radius * (0.6 + 0.4*math.abs(wing))
    local z = math.cos(a) * cfg.Radius * 0.35
    local y = math.sin(a*2) * cfg.Pulse + wing * 1.5
    if a > math.pi then x = -x end
    return Vector3.new(x, cfg.Height + y, z)
end

Shapes["銀河"] = function(i, count, t, cfg)
    local arm = (i % 3)
    local a = (i-1)/count * math.pi*6 + t * cfg.Speed + arm * 2.1
    local r = cfg.Radius * ((i-1)/count) ^ 0.7
    local h = math.sin(a*2) * cfg.Pulse * 1.5
    return Vector3.new(math.cos(a)*r, cfg.Height + h, math.sin(a)*r)
end

Shapes["立方体"] = function(i, count, t, cfg)
    local edges = {
        {1,1,1},{1,1,-1},{1,-1,1},{1,-1,-1},{-1,1,1},{-1,1,-1},{-1,-1,1},{-1,-1,-1}
    }
    local e1 = edges[((i-1)%8)+1]
    local e2 = edges[(((i-1)+1)%8)+1]
    local f = ((i-1)/count) % 1
    local p = Vector3.new(
        e1[1] + (e2[1]-e1[1])*f,
        e1[2] + (e2[2]-e1[2])*f,
        e1[3] + (e2[3]-e1[3])*f
    ) * cfg.Radius * 0.7
    local rot = CFrame.Angles(0, t*cfg.Speed, t*cfg.Speed*0.7)
    return (rot * p) + Vector3.new(0, cfg.Height, 0)
end

Shapes["雷"] = function(i, count, t, cfg)
    local seg = (i-1) / math.max(count-1, 1)
    local x = (seg - 0.5) * cfg.Radius * 2
    local z = math.sin(seg * 12 + t * cfg.Speed * 3) * cfg.Radius * 0.4
    local y = math.abs(math.sin(seg * 8 + t*2)) * cfg.Pulse * 4
    return Vector3.new(x, cfg.Height + y, z)
end

Shapes["魔法陣リング"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    local h = math.sin(a*4 + t) * cfg.Pulse * 0.8
    return Vector3.new(math.cos(a)*cfg.Radius, cfg.Height + h, math.sin(a)*cfg.Radius)
end

Shapes["魔法陣六芒"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed
    local tri = (i % 6 < 3) and 1 or -1
    local r = cfg.Radius * (0.7 + 0.3*math.sin(a*3))
    return Vector3.new(math.cos(a)*r, cfg.Height + tri * cfg.Pulse, math.sin(a)*r)
end

Shapes["魔法陣多重"] = function(i, count, t, cfg)
    local ring = math.floor((i-1) / (count/3))
    local a = ((i-1) % (count/3)) / (count/3) * math.pi*2 + t * cfg.Speed * (1 + ring*0.3)
    local r = cfg.Radius * (0.45 + ring * 0.28)
    return Vector3.new(math.cos(a)*r, cfg.Height + ring * 1.2, math.sin(a)*r)
end

Shapes["カオスボール"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed * 2
    local chaos = math.sin(t*3 + i)*cfg.Pulse*2
    local r = cfg.Radius + chaos
    local h = math.cos(t*2.5 + i*0.7) * cfg.Pulse * 3
    return Vector3.new(math.cos(a)*r, cfg.Height + h, math.sin(a)*r)
end

Shapes["上昇螺旋"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*10 + t * cfg.Speed
    local rise = ((t * cfg.Speed * 0.4) + (i/count)) % 1
    local h = rise * cfg.Radius * 2.5
    local r = cfg.Radius * (1 - rise * 0.4)
    return Vector3.new(math.cos(a)*r, cfg.Height + h, math.sin(a)*r)
end

Shapes["爆発リング"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed * 0.5
    local explode = (math.sin(t * cfg.Speed) + 1) * 0.5
    local r = cfg.Radius * (0.3 + explode * 1.4)
    local h = math.sin(a*2) * cfg.Pulse * explode * 2
    return Vector3.new(math.cos(a)*r, cfg.Height + h, math.sin(a)*r)
end

-- ★流星放射（動画の上向きトンネル・流星群）
Shapes["流星放射"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed * 0.15
    local depth = ((i + t * cfg.Speed * 8) % count) / count   -- 奥から手前に流れる
    local r = cfg.Radius * (0.15 + depth * 1.4)
    local h = cfg.Height + depth * cfg.Radius * 3.5
    local x = math.cos(a) * r
    local z = math.sin(a) * r
    return Vector3.new(x, h, z)
end

-- ★バカ強い追加形
Shapes["ブラックホール"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*8 + t * cfg.Speed * 2
    local spiral = ((i-1)/count)
    local r = cfg.Radius * (0.1 + spiral * 0.95)
    local h = cfg.Height + math.sin(a*2) * cfg.Pulse * 1.5 - spiral * 2
    return Vector3.new(math.cos(a)*r, h, math.sin(a)*r)
end

Shapes["龍の軌道"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*6 + t * cfg.Speed
    local wave1 = math.sin(a * 2.5) * cfg.Radius * 0.35
    local wave2 = math.cos(a * 1.7) * cfg.Radius * 0.25
    local h = cfg.Height + math.sin(a * 3 + t) * cfg.Pulse * 2.5
    return Vector3.new(math.cos(a)*cfg.Radius + wave1, h, math.sin(a)*cfg.Radius + wave2)
end

Shapes["神の目"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*2 + t * cfg.Speed * 0.4
    local eye = math.abs(math.sin(a * 2))
    local r = cfg.Radius * (0.3 + eye * 0.7)
    local h = cfg.Height + (1 - eye) * 3
    return Vector3.new(math.cos(a)*r, h, math.sin(a)*r * 0.6)
end

Shapes["台風"] = function(i, count, t, cfg)
    local a = (i-1)/count * math.pi*10 + t * cfg.Speed * 1.5
    local layer = math.floor((i-1) / (count/4))
    local r = cfg.Radius * (0.3 + layer * 0.25)
    local h = cfg.Height + math.sin(a + layer) * cfg.Pulse
    return Vector3.new(math.cos(a)*r, h, math.sin(a)*r)
end

Shapes["梯子多層陣"] = function(i, count, t, cfg)
    local layerCount = 5
    local layer = math.floor((i-1) / (count / layerCount))
    local inLayer = (i-1) % math.ceil(count / layerCount)
    local layerSize = math.ceil(count / layerCount)
    local a = (inLayer / layerSize) * math.pi * 2 + t * cfg.Speed

    local r, h, tilt
    local h1 = cfg.LadderH1 or 5.5
    local h2 = cfg.LadderH2 or 2.0
    local h3 = cfg.LadderH3 or 3.4
    local h4 = cfg.LadderH4 or 1.6

    if layer == 0 then
        r = cfg.Radius * 1.38
        h = cfg.Height - 2.2
        tilt = 0.05
    elseif layer == 1 then
        r = cfg.Radius * 1.08
        h = cfg.Height + h4
        tilt = 1.35
    elseif layer == 2 then
        r = cfg.Radius * 0.78
        h = cfg.Height + h3
        tilt = 0.95
    elseif layer == 3 then
        r = cfg.Radius * 0.48
        h = cfg.Height + h2
        tilt = 1.42
    else
        r = cfg.Radius * 0.22
        h = cfg.Height + h1
        tilt = 0.65
    end

    local pulse = 1 + math.sin(t * 1.8 + layer) * cfg.Pulse * 0.08
    r = r * pulse

    local x = math.cos(a) * r
    local z = math.sin(a) * r
    return Vector3.new(x, h, z), tilt, a
end

Shapes["梯子多層陣・強化"] = function(i, count, t, cfg)
    local layerCount = 6
    local layer = math.floor((i-1) / (count / layerCount))
    local inLayer = (i-1) % math.ceil(count / layerCount)
    local layerSize = math.ceil(count / layerCount)
    local a = (inLayer / layerSize) * math.pi * 2 + t * cfg.Speed * 0.85

    local r, h, tilt
    local h1 = cfg.LadderH1 or 6.0
    local h2 = cfg.LadderH2 or 2.2
    local h3 = cfg.LadderH3 or 2.8
    local h4 = cfg.LadderH4 or 1.2

    if layer == 0 then
        r = cfg.Radius * 1.45
        h = cfg.Height - 2.5
        tilt = 0.04
    elseif layer == 1 then
        r = cfg.Radius * 1.20
        h = cfg.Height + h4
        tilt = 1.30
    elseif layer == 2 then
        r = cfg.Radius * 0.95
        h = cfg.Height + h3
        tilt = 1.05
    elseif layer == 3 then
        r = cfg.Radius * 0.65
        h = cfg.Height + 4.0
        tilt = 1.38
    elseif layer == 4 then
        r = cfg.Radius * 0.40
        h = cfg.Height + h2
        tilt = 1.45
    else
        r = cfg.Radius * 0.18
        h = cfg.Height + h1
        tilt = 0.55
    end

    local pulse = 1 + math.sin(t * 2.1 + layer * 0.7) * cfg.Pulse * 0.1
    r = r * pulse

    local x = math.cos(a) * r
    local z = math.sin(a) * r
    return Vector3.new(x, h, z), tilt, a
end

Shapes["巨大の手"] = function(i, count, t, cfg)
    local handCount = cfg.HandCount or 5
    local fingersPerHand = cfg.FingerCount or 5
    local laddersPerFinger = math.max(3, math.floor(count / (handCount * fingersPerHand)))

    local handIndex = math.floor((i-1) / (count / handCount))
    local inHand = (i-1) % math.ceil(count / handCount)
    local fingerIndex = math.floor(inHand / math.max(1, laddersPerFinger))
    local inFinger = inHand % math.max(1, laddersPerFinger)

    local handAngle = (handIndex / handCount) * math.pi * 2 + t * cfg.Speed * 0.3

    local handRadius = cfg.Radius * 0.55
    local handCenterX = math.cos(handAngle) * handRadius
    local handCenterZ = math.sin(handAngle) * handRadius
    local handBaseHeight = cfg.Height + 1.5

    local fingerSpread = cfg.FingerSpread or 1.1
    local fingerAngleOffset = (fingerIndex - (fingersPerHand-1)/2) * (fingerSpread / fingersPerHand)
    local fingerAngle = handAngle + fingerAngleOffset + math.pi

    local fingerProgress = inFinger / math.max(1, laddersPerFinger - 1)

    local curve = math.sin(fingerProgress * math.pi * 0.9) * 0.6
    local fingerLength = cfg.Radius * 0.7

    local fx = handCenterX + math.cos(fingerAngle) * (fingerProgress * fingerLength)
    local fz = handCenterZ + math.sin(fingerAngle) * (fingerProgress * fingerLength)
    local fy = handBaseHeight + fingerProgress * 4.5 + curve * 2.2 + math.sin(t * 1.5 + handIndex) * cfg.Pulse * 0.4

    local tilt = 0.9 - fingerProgress * 0.35

    return Vector3.new(fx, fy, fz), tilt, fingerAngle
end

Shapes["巨大の手・密集"] = function(i, count, t, cfg)
    local handCount = cfg.HandCount or 4
    local fingersPerHand = cfg.FingerCount or 6
    local laddersPerFinger = math.max(4, math.floor(count / (handCount * fingersPerHand)))

    local handIndex = math.floor((i-1) / (count / handCount))
    local inHand = (i-1) % math.ceil(count / handCount)
    local fingerIndex = math.floor(inHand / math.max(1, laddersPerFinger))
    local inFinger = inHand % math.max(1, laddersPerFinger)

    local handAngle = (handIndex / handCount) * math.pi * 2 + t * cfg.Speed * 0.25

    local handRadius = cfg.Radius * 0.5
    local handCenterX = math.cos(handAngle) * handRadius
    local handCenterZ = math.sin(handAngle) * handRadius
    local handBaseHeight = cfg.Height + 2.0

    local fingerSpread = cfg.FingerSpread or 1.35
    local fingerAngleOffset = (fingerIndex - (fingersPerHand-1)/2) * (fingerSpread / fingersPerHand)
    local fingerAngle = handAngle + fingerAngleOffset + math.pi

    local fingerProgress = inFinger / math.max(1, laddersPerFinger - 1)
    local sideOffset = ((i % 3) - 1) * 0.35

    local curve = math.sin(fingerProgress * math.pi) * 0.85
    local fingerLength = cfg.Radius * 0.85

    local fx = handCenterX + math.cos(fingerAngle) * (fingerProgress * fingerLength) + math.cos(fingerAngle + math.pi/2) * sideOffset
    local fz = handCenterZ + math.sin(fingerAngle) * (fingerProgress * fingerLength) + math.sin(fingerAngle + math.pi/2) * sideOffset
    local fy = handBaseHeight + fingerProgress * 5.5 + curve * 2.8 + math.sin(t * 1.2 + handIndex * 0.8) * cfg.Pulse * 0.5

    local tilt = 1.05 - fingerProgress * 0.4

    return Vector3.new(fx, fy, fz), tilt, fingerAngle
end

local function dualSideOffset(i, count, t, cfg, side)
    local mode = cfg.DualMode or "円形スポーク"
    local localCount = math.floor(count / 2)
    local localI = ((i-1) % localCount) + 1
    local sideOffsetX = side * (cfg.DualDistance or 8)

    if mode == "円形スポーク" then
        local a = (localI-1)/localCount * math.pi*2 + t * cfg.Speed
        local r = cfg.Radius * 0.7
        local x = sideOffsetX + math.cos(a) * r
        local z = math.sin(a) * r
        local y = cfg.Height + math.sin(a*3 + t) * cfg.Pulse * 0.4
        return Vector3.new(x, y, z)
    elseif mode == "星形" then
        local a = (localI-1)/localCount * math.pi*2 + t * cfg.Speed
        local r = cfg.Radius * (0.45 + 0.35 * math.abs(math.sin(a * 5)))
        local x = sideOffsetX + math.cos(a) * r
        local z = math.sin(a) * r
        local y = cfg.Height
        return Vector3.new(x, y, z)
    elseif mode == "三角回転" then
        local a = (localI-1)/localCount * math.pi*2 + t * cfg.Speed
        local tri = math.abs(math.sin(a * 1.5))
        local r = cfg.Radius * (0.5 + tri * 0.4)
        local x = sideOffsetX + math.cos(a) * r
        local z = math.sin(a) * r
        local y = cfg.Height + math.sin(a*2) * cfg.Pulse * 0.6
        return Vector3.new(x, y, z)
    elseif mode == "二重リング" then
        local ring = (localI % 2 == 0) and 1 or 0.55
        local a = (localI-1)/localCount * math.pi*2 + t * cfg.Speed * (ring > 0.7 and 1 or -0.7)
        local r = cfg.Radius * ring
        local x = sideOffsetX + math.cos(a) * r
        local z = math.sin(a) * r
        local y = cfg.Height + (ring > 0.7 and 0.8 or -0.4)
        return Vector3.new(x, y, z)
    else
        local a = (localI-1)/localCount * math.pi*2 + t * cfg.Speed
        local r = cfg.Radius * 0.65
        local x = sideOffsetX + math.cos(a) * r
        local z = math.sin(a) * r
        local y = cfg.Height
        return Vector3.new(x, y, z)
    end
end

Shapes["デュアルサイド"] = function(i, count, t, cfg)
    local half = math.floor(count / 2)
    local side = (i <= half) and -1 or 1
    return dualSideOffset(i, count, t, cfg, side)
end

local modeList = {
    "円形","羽","ハート","ビッグハート","ダビデの星","五芒星",
    "球体","螺旋","無限大","花びら","ピラミッド","ドーナツ",
    "波","蝶","銀河","立方体","雷",
    "魔法陣リング","魔法陣六芒","魔法陣多重",
    "カオスボール","上昇螺旋","爆発リング",
    "流星放射","ブラックホール","龍の軌道","神の目","台風",
    "梯子多層陣","梯子多層陣・強化",
    "デュアルサイド"
}

local handModeList = {
    "巨大の手",
    "巨大の手・密集"
}

----------------------------------------------------------------
-- 手（パレット+ハシゴ5本）専用システム
----------------------------------------------------------------
local HandSystem = {
    Enabled = false,
    Assigned = {},
    LoopConn = nil,
    Time = 0,
    Config = {
        Height = 4,
        Radius = 6,
        Speed = 0.8,
        FollowPlayer = true,
    }
}

local function getPrimaryPart(model)
    if not model then return nil end
    if model.PrimaryPart then return model.PrimaryPart end
    local names = {"Handle","Main","Part","Base","Sparkler","Firework","Blade","Candle","Keyboard","Box","Decoy","Missile","Ladder","Blob","Ball","Crystal","Island","Ufo","Jukebox","Couch","Boombox","Snowflake","Diamond","Tractor","Pallet"}
    for _, n in ipairs(names) do
        local p = model:FindFirstChild(n, true)
        if p and p:IsA("BasePart") then return p end
    end
    for _, c in ipairs(model:GetDescendants()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

local function findSpecificObjects(id)
    local list = {}
    local seen = {}
    local function add(model)
        if model and model:IsA("Model") and model.Name == id then
            if not seen[model] then
                seen[model] = true
                table.insert(list, model)
            end
        end
    end

    local myFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    if myFolder then
        for _, v in ipairs(myFolder:GetDescendants()) do add(v) end
        for _, v in ipairs(myFolder:GetChildren()) do add(v) end
    end

    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            if string.find(folder.Name, "SpawnedInToys") or string.find(folder.Name, "Toys") then
                for _, v in ipairs(folder:GetDescendants()) do add(v) end
            end
        end
    end

    if #list == 0 then
        for _, v in ipairs(Workspace:GetDescendants()) do add(v) end
    end
    return list
end

local function attachPhysics(part)
    if not part then return nil, nil end
    local oldBG = part:FindFirstChildOfClass("BodyGyro")
    local oldBP = part:FindFirstChildOfClass("BodyPosition")
    if oldBG then oldBG:Destroy() end
    if oldBP then oldBP:Destroy() end

    local BP = Instance.new("BodyPosition")
    BP.P = 25000
    BP.D = 400
    BP.MaxForce = Vector3.new(1e10, 1e10, 1e10)
    BP.Parent = part

    local BG = Instance.new("BodyGyro")
    BG.P = 25000
    BG.D = 400
    BG.MaxTorque = Vector3.new(1e10, 1e10, 1e10)
    BG.Parent = part
    return BG, BP
end

local function stopHand()
    if HandSystem.LoopConn then
        HandSystem.LoopConn:Disconnect()
        HandSystem.LoopConn = nil
    end
    for _, toy in ipairs(HandSystem.Assigned) do
        if toy.BG then pcall(function() toy.BG:Destroy() end) end
        if toy.BP then pcall(function() toy.BP:Destroy() end) end
        if toy.Model then
            for _, p in ipairs(toy.Model:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                    p.CanTouch = true
                end
            end
        end
    end
    HandSystem.Assigned = {}
    HandSystem.Enabled = false
end

local function startHand()
    stopHand()

    local ladders = findSpecificObjects("LadderLightBrown")
    local pallets = findSpecificObjects("PalletLightBrown")

    if #ladders < 5 then
        OrionLib:MakeNotification({
            Name = "手 失敗",
            Content = "ハシゴが5本足りません（現在" .. #ladders .. "本）",
            Time = 4
        })
        return
    end
    if #pallets < 1 then
        OrionLib:MakeNotification({
            Name = "手 失敗",
            Content = "パレットが1個足りません",
            Time = 4
        })
        return
    end

    local palletModel = pallets[1]
    local palletPart = getPrimaryPart(palletModel)
    if palletPart then
        for _, p in ipairs(palletModel:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.CanTouch = false
                p.Anchored = false
                pcall(function() p:SetNetworkOwner(LocalPlayer) end)
            end
        end
        local BG, BP = attachPhysics(palletPart)
        if BG and BP then
            table.insert(HandSystem.Assigned, {
                BG = BG, BP = BP, Part = palletPart, Model = palletModel,
                IsPallet = true, FingerIndex = 0
            })
        end
    end

    for i = 1, 5 do
        local model = ladders[i]
        local part = getPrimaryPart(model)
        if part then
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    p.CanTouch = false
                    p.Anchored = false
                    pcall(function() p:SetNetworkOwner(LocalPlayer) end)
                end
            end
            local BG, BP = attachPhysics(part)
            if BG and BP then
                table.insert(HandSystem.Assigned, {
                    BG = BG, BP = BP, Part = part, Model = model,
                    IsPallet = false, FingerIndex = i
                })
            end
        end
    end

    HandSystem.Enabled = true
    HandSystem.Time = 0

    HandSystem.LoopConn = RunService.RenderStepped:Connect(function(dt)
        if not HandSystem.Enabled or not LocalPlayer.Character then return end
        local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
        if not torso then return end

        HandSystem.Time = HandSystem.Time + dt
        local center = HandSystem.Config.FollowPlayer and torso.Position or torso.Position
        local baseHeight = HandSystem.Config.Height
        local radius = HandSystem.Config.Radius
        local t = HandSystem.Time

        for _, toy in ipairs(HandSystem.Assigned) do
            if toy.BP and toy.BG and toy.Part and toy.Part.Parent then
                if toy.IsPallet then
                    local target = center + Vector3.new(0, baseHeight + 1.2, -1.5)
                    toy.BP.Position = target
                    toy.BG.CFrame = CFrame.new(target) * CFrame.Angles(math.rad(-15), 0, 0)
                else
                    local fi = toy.FingerIndex
                    local spread = 1.15
                    local fingerAngle = (fi - 3) * (spread / 4)
                    local progress = 0.35 + (fi % 2) * 0.08

                    local len = radius * (0.9 + progress * 0.4)
                    local curve = math.sin(progress * math.pi) * 1.8

                    local fx = math.sin(fingerAngle) * len * 0.7
                    local fz = -math.cos(fingerAngle) * len * 0.55 - 1.2
                    local fy = baseHeight + 1.8 + progress * 3.8 + curve + math.sin(t * 1.3 + fi) * 0.25

                    local target = center + Vector3.new(fx, fy, fz)

                    local tilt = 0.75 - progress * 0.25
                    local upright = math.clamp(tilt, 0, 1.2) / 1.2
                    local pitch = math.rad(90 * (1 - upright))

                    local cf = CFrame.new(target)
                        * CFrame.Angles(0, fingerAngle + math.pi, 0)
                        * CFrame.Angles(pitch, 0, 0)

                    toy.BP.Position = target
                    toy.BG.CFrame = cf
                end
            end
        end
    end)

    OrionLib:MakeNotification({
        Name = "手 完成",
        Content = "パレット1個 + ハシゴ5本で手を形成しました",
        Time = 4
    })
end

----------------------------------------------------------------
-- 回転システム
----------------------------------------------------------------
local function createRotator(name)
    local self = {
        Name = name,
        CurrentObjectID = "FireworkSparkler",
        Config = {
            Enabled      = false,
            Mode         = "円形",
            ObjectCount  = 100,
            Radius       = 10,
            Height       = 4,
            Speed        = 1.8,
            Pulse        = 0.6,
            FollowPlayer = true,
            FaceCenter   = true,
            LadderH1     = 5.5,
            LadderH2     = 2.0,
            LadderH3     = 3.4,
            LadderH4     = 1.6,
            HandCount    = 5,
            FingerCount  = 5,
            FingerSpread = 1.1,
            DualMode     = "円形スポーク",
            DualDistance = 8,
        },
        Assigned = {},
        LoopConn = nil,
        Time = 0,
    }

    local function getPrimaryPartLocal(model)
        return getPrimaryPart(model)
    end

    local function findObjects()
        local toys = {}
        local seen = {}
        local function add(model)
            if model and model:IsA("Model") and model.Name == self.CurrentObjectID then
                if not seen[model] then
                    seen[model] = true
                    table.insert(toys, model)
                end
            end
        end

        local myFolder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if myFolder then
            for _, v in ipairs(myFolder:GetDescendants()) do add(v) end
            for _, v in ipairs(myFolder:GetChildren()) do add(v) end
        end

        for _, folder in ipairs(Workspace:GetChildren()) do
            if folder:IsA("Folder") or folder:IsA("Model") then
                if string.find(folder.Name, "SpawnedInToys") or string.find(folder.Name, "Toys") then
                    for _, v in ipairs(folder:GetDescendants()) do add(v) end
                end
            end
        end

        if #toys == 0 then
            for _, v in ipairs(Workspace:GetDescendants()) do add(v) end
        end
        return toys
    end

    local function attachPhysicsLocal(part)
        return attachPhysics(part)
    end

    local function stopLoop()
        if self.LoopConn then
            self.LoopConn:Disconnect()
            self.LoopConn = nil
        end
        for _, toy in ipairs(self.Assigned) do
            if toy.BG then pcall(function() toy.BG:Destroy() end) end
            if toy.BP then pcall(function() toy.BP:Destroy() end) end
            if toy.Model then
                for _, p in ipairs(toy.Model:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = true
                        p.CanTouch = true
                    end
                end
            end
        end
        self.Assigned = {}
    end

    local function startLoop()
        if self.LoopConn then self.LoopConn:Disconnect() end
        self.Time = 0

        self.LoopConn = RunService.RenderStepped:Connect(function(dt)
            if not self.Config.Enabled or not LocalPlayer.Character then return end
            local torso = LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
            if not torso then return end

            self.Time = self.Time + dt
            local center = self.Config.FollowPlayer and torso.Position or torso.Position
            local shapeFunc = Shapes[self.Config.Mode]
            if not shapeFunc then return end

            local count = #self.Assigned
            for i, toy in ipairs(self.Assigned) do
                if toy.BP and toy.BG and toy.Part and toy.Part.Parent then
                    local result = {shapeFunc(i, count, self.Time, self.Config)}
                    local offset = result[1]
                    local target = center + offset

                    toy.BP.Position = target

                    if self.Config.Mode == "梯子多層陣" or self.Config.Mode == "梯子多層陣・強化"
                    or self.Config.Mode == "巨大の手" or self.Config.Mode == "巨大の手・密集" then
                        local tilt = result[2] or 1
                        local angle = result[3] or 0
                        local upright = math.clamp(tilt, 0, 1.5) / 1.5
                        local pitch = math.rad(90 * (1 - upright))

                        local cf = CFrame.new(target)
                            * CFrame.Angles(0, angle + math.pi/2, 0)
                            * CFrame.Angles(pitch, 0, 0)

                        toy.BG.CFrame = cf
                    else
                        if self.Config.FaceCenter then
                            toy.BG.CFrame = CFrame.lookAt(target, center)
                        else
                            toy.BG.CFrame = CFrame.new(target)
                        end
                    end
                end
            end
        end)
    end

    local function applyToys()
        stopLoop()
        local toys = findObjects()
        local max = math.min(#toys, self.Config.ObjectCount)
        self.Assigned = {}

        for i = 1, max do
            local model = toys[i]
            local part = getPrimaryPartLocal(model)
            if part then
                for _, p in ipairs(model:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                        p.CanTouch = false
                        p.Anchored = false
                        pcall(function() p:SetNetworkOwner(LocalPlayer) end)
                    end
                end
                local BG, BP = attachPhysicsLocal(part)
                if BG and BP then
                    table.insert(self.Assigned, {BG = BG, BP = BP, Part = part, Model = model})
                end
            end
        end

        if self.Config.Enabled and #self.Assigned > 0 then
            startLoop()
        end
        return #self.Assigned, #toys
    end

    function self.toggle(state)
        self.Config.Enabled = state
        if state then
            local used, found = applyToys()
            OrionLib:MakeNotification({
                Name = self.Name .. " 開始",
                Content = string.format("%s / %s / 使用%d個（発見%d個）", self.Config.Mode, getJapaneseName(self.CurrentObjectID), used, found),
                Time = 4
            })
        else
            stopLoop()
            OrionLib:MakeNotification({Name = self.Name .. " 停止", Content = "解除しました", Time = 2})
        end
    end

    function self.changeObject(id)
        self.CurrentObjectID = id
        if self.Config.Enabled then
            local used, found = applyToys()
            OrionLib:MakeNotification({
                Name = self.Name .. " オブジェクト切替",
                Content = string.format("%s → 使用%d個（発見%d個）", getJapaneseName(id), used, found),
                Time = 4
            })
        else
            OrionLib:MakeNotification({
                Name = self.Name .. " オブジェクト切替",
                Content = getJapaneseName(id) .. " に変更（待機中）",
                Time = 2
            })
        end
    end

    function self.changeMode(mode)
        self.Config.Mode = mode
        if self.Config.Enabled then
            local used = applyToys()
            OrionLib:MakeNotification({
                Name = self.Name .. " モード変更",
                Content = string.format("%s / 使用%d個", mode, used),
                Time = 3
            })
        end
    end

    function self.forceRescan()
        local used, found = applyToys()
        OrionLib:MakeNotification({
            Name = self.Name .. " 再スキャン",
            Content = string.format("発見: %d個  /  使用: %d個", found, used),
            Time = 4
        })
    end

    function self.createUI(window)
        local objTab = window:MakeTab({Name = self.Name .. " オブジェクト", Icon = "rbxassetid://4483362458"})
        objTab:AddLabel("※ 先におもちゃを出してから選んでください")
        for _, item in ipairs(ObjectDisplay) do
            objTab:AddButton({
                Name = item.jp,
                Callback = function() self.changeObject(item.id) end
            })
        end

        local mainTab = window:MakeTab({Name = self.Name .. " コントロール", Icon = "rbxassetid://4483362458"})

        mainTab:AddToggle({
            Name = "回転をオン",
            Default = false,
            Callback = function(state) self.toggle(state) end
        })

        mainTab:AddToggle({
            Name = "プレイヤー追従",
            Default = true,
            Callback = function(v) self.Config.FollowPlayer = v end
        })

        mainTab:AddToggle({
            Name = "中心を向く",
            Default = true,
            Callback = function(v) self.Config.FaceCenter = v end
        })

        mainTab:AddSection({Name = "パラメータ"})

        mainTab:AddSlider({
            Name = "最大オブジェクト数（全部使いたい場合は100）",
            Min = 4, Max = 100, Default = 100,
            Color = Theme.SliderColor, Increment = 1, ValueName = "個",
            Callback = function(v)
                self.Config.ObjectCount = v
                if self.Config.Enabled then applyToys() end
            end
        })

        mainTab:AddSlider({
            Name = "半径", Min = 2, Max = 40, Default = 10,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.Radius = v end
        })

        mainTab:AddSlider({
            Name = "高さ（全体基準）", Min = -20, Max = 50, Default = 4,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.Height = v end
        })

        mainTab:AddSection({Name = "梯子多層陣 高さ調整"})

        mainTab:AddSlider({
            Name = "1番真ん中の高さ", Min = -10, Max = 50, Default = 5.5,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.LadderH1 = v end
        })

        mainTab:AddSlider({
            Name = "2番目の高さ", Min = -10, Max = 50, Default = 2.0,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.LadderH2 = v end
        })

        mainTab:AddSlider({
            Name = "3番目の高さ", Min = -10, Max = 50, Default = 3.4,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.LadderH3 = v end
        })

        mainTab:AddSlider({
            Name = "4番目の高さ", Min = -10, Max = 50, Default = 1.6,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.LadderH4 = v end
        })

        mainTab:AddSlider({
            Name = "回転速度", Min = 0, Max = 12, Default = 1.8,
            Color = Theme.SliderColor, Increment = 0.1, ValueName = "速度",
            Callback = function(v) self.Config.Speed = v end
        })

        mainTab:AddSlider({
            Name = "脈動・振幅", Min = 0, Max = 5, Default = 0.6,
            Color = Theme.SliderColor, Increment = 0.1, ValueName = "",
            Callback = function(v) self.Config.Pulse = v end
        })

        mainTab:AddButton({
            Name = "強制再スキャン（全部拾い直す）",
            Callback = function() self.forceRescan() end
        })

        local shapeTab = window:MakeTab({Name = self.Name .. " 形状", Icon = "rbxassetid://4483362458"})
        for _, modeName in ipairs(modeList) do
            shapeTab:AddButton({
                Name = modeName,
                Callback = function() self.changeMode(modeName) end
            })
        end

        local handTab = window:MakeTab({Name = self.Name .. " 巨大の手", Icon = "rbxassetid://4483362458"})
        handTab:AddLabel("※ ハシゴを大量に出してから使うと綺麗に出ます")
        handTab:AddLabel("※ オブジェクト数は80〜100推奨")
        handTab:AddSection({Name = "巨大の手モード選択"})
        for _, modeName in ipairs(handModeList) do
            handTab:AddButton({
                Name = modeName,
                Callback = function() self.changeMode(modeName) end
            })
        end
        handTab:AddSection({Name = "巨大の手 専用パラメータ"})
        handTab:AddSlider({
            Name = "手の数", Min = 2, Max = 8, Default = 5,
            Color = Theme.SliderColor, Increment = 1, ValueName = "本",
            Callback = function(v) self.Config.HandCount = v end
        })
        handTab:AddSlider({
            Name = "1つの手の指の数", Min = 3, Max = 8, Default = 5,
            Color = Theme.SliderColor, Increment = 1, ValueName = "本",
            Callback = function(v) self.Config.FingerCount = v end
        })
        handTab:AddSlider({
            Name = "指の開き具合", Min = 0.5, Max = 2.5, Default = 1.1,
            Color = Theme.SliderColor, Increment = 0.1, ValueName = "",
            Callback = function(v) self.Config.FingerSpread = v end
        })

        local dualTab = window:MakeTab({Name = self.Name .. " デュアルサイド", Icon = "rbxassetid://4483362458"})
        dualTab:AddLabel("左右に2つの形成を同時に出す")
        dualTab:AddLabel("スケッチ通りキャラの両サイドに配置")
        dualTab:AddButton({
            Name = "▶ デュアルサイドを開始",
            Callback = function()
                self.Config.Mode = "デュアルサイド"
                self.toggle(true)
            end
        })
        dualTab:AddSection({Name = "形成パターン選択"})
        local dualModes = {"円形スポーク", "星形", "三角回転", "二重リング"}
        for _, m in ipairs(dualModes) do
            dualTab:AddButton({
                Name = m,
                Callback = function()
                    self.Config.DualMode = m
                    self.Config.Mode = "デュアルサイド"
                    if self.Config.Enabled then
                        local used = applyToys()
                        OrionLib:MakeNotification({
                            Name = "デュアルサイド",
                            Content = m .. " に変更 / 使用" .. used .. "個",
                            Time = 3
                        })
                    end
                end
            })
        end
        dualTab:AddSection({Name = "デュアルサイド パラメータ"})
        dualTab:AddSlider({
            Name = "左右の距離", Min = 3, Max = 20, Default = 8,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.DualDistance = v end
        })
        dualTab:AddSlider({
            Name = "半径（各サイド）", Min = 2, Max = 20, Default = 7,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.Radius = v end
        })
        dualTab:AddSlider({
            Name = "高さ", Min = -10, Max = 30, Default = 4,
            Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
            Callback = function(v) self.Config.Height = v end
        })
        dualTab:AddSlider({
            Name = "回転速度", Min = 0, Max = 10, Default = 1.5,
            Color = Theme.SliderColor, Increment = 0.1, ValueName = "",
            Callback = function(v) self.Config.Speed = v end
        })
    end

    return self
end

----------------------------------------------------------------
-- 2系統作成
----------------------------------------------------------------
local Rotator1 = createRotator("回転①")
local Rotator2 = createRotator("回転②")

Rotator2.Config.Radius = 14
Rotator2.Config.Height = 7
Rotator2.Config.Speed = 1.2
Rotator2.Config.Mode = "螺旋"

----------------------------------------------------------------
-- バリア破壊
----------------------------------------------------------------
local autoBarrierRunning = false
local autoBarrierToggle = nil
local autoBarrierNoTPRunning = false
local autoBarrierNoTPToggle = nil

local function executeBarrierBreak()
    local playerName = LP.Name
    local plotItems = Workspace:FindFirstChild("PlotItems")
    if plotItems then
        local playersInPlots = plotItems:FindFirstChild("PlayersInPlots")
        if playersInPlots and playersInPlots:FindFirstChild(playerName) then
            OrionLib:MakeNotification({Name = "⚠️ Error", Content = "Please execute outside your house", Time = 3})
            return false
        end
    end

    autoBarrierRunning = true
    local success, result = pcall(function()
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "⚠️ Error", Content = "Character not found", Time = 3})
            return false
        end
        local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            OrionLib:MakeNotification({Name = "⚠️ Error", Content = "Humanoid not found", Time = 3})
            return false
        end
        local originalWalkSpeed = humanoid.WalkSpeed
        local originalPosition = LP.Character.HumanoidRootPart.CFrame
        humanoid.WalkSpeed = 0
        if not ReplicatedStorage:FindFirstChild("MenuToys") then
            humanoid.WalkSpeed = originalWalkSpeed
            OrionLib:MakeNotification({Name = "⚠️ Error", Content = "MenuToys not found", Time = 3})
            return false
        end
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("InstrumentWoodwindOcarina", 
            CFrame.new(184.148834, -5.54824972, 498.136749, 0.829037189, -0.214714944, 0.516328275, 0, 0.923344612, 0.383972496, -0.559193552, -0.318327487, 0.765486956), 
            Vector3.new(0, 34, 0))
        task.wait(0.4)
        local toyFolder = Workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
        if not toyFolder or not toyFolder:FindFirstChild("InstrumentWoodwindOcarina") then
            humanoid.WalkSpeed = originalWalkSpeed
            OrionLib:MakeNotification({Name = "⚠️ Error", Content = "Ocarina not found", Time = 3})
            return false
        end
        local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
        if not ocarina or not ocarina:FindFirstChild("HoldPart") then
            humanoid.WalkSpeed = originalWalkSpeed
            OrionLib:MakeNotification({Name = "⚠️ Error", Content = "Ocarina HoldPart not found", Time = 3})
            return false
        end
        ocarina.HoldPart.HoldItemRemoteFunction:InvokeServer(ocarina, Workspace[LP.Name])
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(304.06, 25.77, 488.54)
        end
        task.wait(0.21)
        if toyFolder and toyFolder:FindFirstChild("InstrumentWoodwindOcarina") then
            ReplicatedStorage.MenuToys.DestroyToy:FireServer(toyFolder.InstrumentWoodwindOcarina)
        end
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = originalPosition
        end
        task.wait(0.7)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("Campfire", 
            CFrame.new(257.638672, -5.57392979, 450.103638, -0.950906992, -0.171067372, 0.257899135, 0, 0.833338678, 0.552762806, -0.309477001, 0.525626004, -0.79242748), 
            Vector3.new(0, 161.9720001220703, 0))
        task.wait(0.7)
        local campfirePosition = Vector3.new(257.638672, -5.57392979, 450.103638)
        local toyFolder2 = Workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
        if toyFolder2 and toyFolder2:FindFirstChild("Campfire") then
            local campfire = toyFolder2:FindFirstChild("Campfire")
            local primaryPart = campfire.PrimaryPart or campfire:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                local distance = (primaryPart.Position - campfirePosition).Magnitude
                if distance < 10 then
                    task.wait(1)
                    humanoid.WalkSpeed = originalWalkSpeed
                    OrionLib:MakeNotification({Name = "✅ Success", Content = "Barrier破壊に成功！", Time = 5})
                    return true
                end
            end
        end
        humanoid.WalkSpeed = originalWalkSpeed
        OrionLib:MakeNotification({Name = "⚠️ Failed", Content = "Campfire placement failed", Time = 3})
        return false
    end)
    if not success then
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
        OrionLib:MakeNotification({Name = "❌ Error", Content = "Execution error: " .. tostring(result), Time = 3})
        return false
    end
    autoBarrierRunning = false
    return result
end

local function executeBarrierBreakNoTP()
    local playerName = LP.Name
    local plotItems = Workspace:FindFirstChild("PlotItems")
    if plotItems then
        local playersInPlots = plotItems:FindFirstChild("PlayersInPlots")
        if playersInPlots and playersInPlots:FindFirstChild(playerName) then
            OrionLib:MakeNotification({Name = "⚠️ エラー", Content = "家の外で実行してください", Time = 3})
            return false
        end
    end
    autoBarrierNoTPRunning = true
    local success, err = pcall(function()
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then error("キャラクターが見つかりません") end
        local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then error("Humanoidが見つかりません") end
        humanoid.WalkSpeed = 0
        if not ReplicatedStorage:FindFirstChild("MenuToys") then humanoid.WalkSpeed = 16 error("MenuToysが見つかりません") end
        local spawnResult = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("InstrumentWoodwindOcarina", 
            CFrame.new(184.148834, -5.54824972, 498.136749, 0.829037189, -0.214714944, 0.516328275, 0, 0.923344612, 0.383972496, -0.559193552, -0.318327487, 0.765486956), 
            Vector3.new(0, 34, 0))
        if not spawnResult then humanoid.WalkSpeed = 16 error("オカリナのスポーンに失敗しました") end
        task.wait(0.4)
        local toyFolder = Workspace:FindFirstChild(playerName .. "SpawnedInToys")
        if not toyFolder then humanoid.WalkSpeed = 16 error("トイフォルダが見つかりません") end
        local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
        if not ocarina then humanoid.WalkSpeed = 16 error("オカリナが見つかりません") end
        if not ocarina:FindFirstChild("HoldPart") then humanoid.WalkSpeed = 16 error("オカリナのHoldPartが見つかりません") end
        local holdResult = Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina.HoldPart.HoldItemRemoteFunction:InvokeServer(
            Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina, Workspace[playerName])
        if not holdResult then humanoid.WalkSpeed = 16 error("オカリナを持つことに失敗しました") end
        task.wait(0.2)
        local dropResult = Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina.HoldPart.DropItemRemoteFunction:InvokeServer(
            Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina, CFrame.new(304.06, 25.77, 488.54), Vector3.new(0, 70.48600006103516, 0))
        if not dropResult then humanoid.WalkSpeed = 16 error("オカリナを落とすことに失敗しました") end
        task.wait(0.1)
        if not Workspace:FindFirstChild(playerName .. "SpawnedInToys") then humanoid.WalkSpeed = 16 error("トイフォルダが消失しました") end
        if not Workspace[playerName .. "SpawnedInToys"]:FindFirstChild("InstrumentWoodwindOcarina") then humanoid.WalkSpeed = 16 error("オカリナが既に消失しています") end
        ReplicatedStorage.MenuToys.DestroyToy:FireServer(Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina)
        task.wait(1.5)
        local campfireSpawnResult = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("Campfire", 
            CFrame.new(257.638672, -5.57392979, 450.103638, -0.950906992, -0.171067372, 0.257899135, 0, 0.833338678, 0.552762806, -0.309477001, 0.525626004, -0.79242748), 
            Vector3.new(0, 161.9720001220703, 0))
        if not campfireSpawnResult then humanoid.WalkSpeed = 16 error("Campfireのスポーンに失敗しました") end
        task.wait(1)
        if not Workspace:FindFirstChild(playerName .. "SpawnedInToys") then humanoid.WalkSpeed = 16 error("トイフォルダが消失しました") end
        if not Workspace[playerName .. "SpawnedInToys"]:FindFirstChild("Campfire") then humanoid.WalkSpeed = 16 error("Campfireが見つかりません") end
        humanoid.WalkSpeed = 16
        OrionLib:MakeNotification({Name = "✅ 成功", Content = "Barrier破壊に成功しました！", Time = 3})
        return true
    end)
    if not success then
        local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
        OrionLib:MakeNotification({Name = "❌ 失敗", Content = tostring(err), Time = 3})
        return false
    end
    autoBarrierNoTPRunning = false
    return true
end

----------------------------------------------------------------
-- UI
----------------------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "本気おもちゃ回転ハブ【完全版】",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false,
    ThemeColor = Theme.BackgroundColor,
})

Rotator1.createUI(Window)
Rotator2.createUI(Window)

-- 手（パレット+ハシゴ5本）
local SimpleHandTab = Window:MakeTab({
    Name = "手（パレット+ハシゴ）",
    Icon = "rbxassetid://4483362458",
})
SimpleHandTab:AddLabel("ハシゴを5本 + パレットを1個出してから押す")
SimpleHandTab:AddLabel("パレット＝掌　／　ハシゴ5本＝指")
SimpleHandTab:AddButton({
    Name = "▶ 手を作る（1ボタン）",
    Callback = function() startHand() end
})
SimpleHandTab:AddButton({
    Name = "■ 手を解除",
    Callback = function()
        stopHand()
        OrionLib:MakeNotification({Name = "手 解除", Content = "手の形成を解除しました", Time = 2})
    end
})
SimpleHandTab:AddSection({Name = "手のパラメータ"})
SimpleHandTab:AddSlider({
    Name = "手の高さ", Min = -5, Max = 30, Default = 4,
    Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
    Callback = function(v) HandSystem.Config.Height = v end
})
SimpleHandTab:AddSlider({
    Name = "指の長さ（半径）", Min = 3, Max = 15, Default = 6,
    Color = Theme.SliderColor, Increment = 0.5, ValueName = "スタッド",
    Callback = function(v) HandSystem.Config.Radius = v end
})
SimpleHandTab:AddToggle({
    Name = "プレイヤー追従",
    Default = true,
    Callback = function(v) HandSystem.Config.FollowPlayer = v end
})

-- バリア破壊
local BarrierTab = Window:MakeTab({
    Name = "バリア破壊",
    Icon = "rbxassetid://4483345998",
})
BarrierTab:AddButton({
    Name = "Break Barrier (1回実行)",
    Callback = function() executeBarrierBreak() end
})
BarrierTab:AddSection({Name = "自動実行機能"})
autoBarrierToggle = BarrierTab:AddToggle({
    Name = "🔄 Auto Barrier破壊",
    Default = false,
    Callback = function(Value)
        autoBarrierRunning = Value
        if Value then
            OrionLib:MakeNotification({Name = "▶️ Start", Content = "Auto executing until success", Time = 2})
            task.spawn(function()
                while autoBarrierRunning do
                    local result = executeBarrierBreak()
                    if result then
                        if autoBarrierToggle then autoBarrierToggle:Set(false) end
                        break
                    end
                    task.wait(1)
                end
            end)
        else
            OrionLib:MakeNotification({Name = "⏸️ Stop", Content = "Auto execution stopped", Time = 2})
        end
    end
})
BarrierTab:AddParagraph("使い方", "・家の外で実行してください\n・自動実行は成功したら自動でOFFになります")
BarrierTab:AddSection({Name = "テレポートなし版 (Beta)"})
BarrierTab:AddButton({
    Name = "Break Barrier NoTP (1回実行)",
    Callback = function() executeBarrierBreakNoTP() end
})
autoBarrierNoTPToggle = BarrierTab:AddToggle({
    Name = "🔄 Auto Barrier破壊 NoTP (Beta)",
    Default = false,
    Callback = function(Value)
        autoBarrierNoTPRunning = Value
        if Value then
            OrionLib:MakeNotification({Name = "▶️ 開始", Content = "成功するまで自動実行します", Time = 2})
            task.spawn(function()
                while autoBarrierNoTPRunning do
                    local result = executeBarrierBreakNoTP()
                    if result then
                        if autoBarrierNoTPToggle then autoBarrierNoTPToggle:Set(false) end
                        break
                    end
                    task.wait(1.5)
                end
            end)
        else
            OrionLib:MakeNotification({Name = "⏸️ 停止", Content = "Auto実行を停止しました", Time = 2})
        end
    end
})
BarrierTab:AddParagraph("NoTP版の注意", "・ベータ版です\n・通常版より成功率が低い場合があります")

----------------------------------------------------------------
-- 空の色タブ
----------------------------------------------------------------
local Lighting = game:GetService("Lighting")
local SkyTab = Window:MakeTab({
    Name = "空の色",
    Icon = "rbxassetid://4483345998",
})

local function ensureAtmosphere()
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmo then
        atmo = Instance.new("Atmosphere")
        atmo.Parent = Lighting
    end
    return atmo
end

local function ensureSky()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    return sky
end

local function setSkyPreset(name)
    local atmo = ensureAtmosphere()
    local sky = ensureSky()
    if name == "夜" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.fromRGB(20, 25, 45)
        Lighting.OutdoorAmbient = Color3.fromRGB(15, 20, 40)
        Lighting.FogColor = Color3.fromRGB(10, 15, 30)
        Lighting.FogEnd = 800
        atmo.Density = 0.35
        atmo.Color = Color3.fromRGB(30, 40, 70)
        atmo.Decay = Color3.fromRGB(10, 15, 30)
        atmo.Glare = 0
        atmo.Haze = 1.5
        sky.SkyboxBk = "rbxassetid://6444884337"
        sky.SkyboxDn = "rbxassetid://6444884337"
        sky.SkyboxFt = "rbxassetid://6444884337"
        sky.SkyboxLf = "rbxassetid://6444884337"
        sky.SkyboxRt = "rbxassetid://6444884337"
        sky.SkyboxUp = "rbxassetid://6444884337"
        sky.StarCount = 3000
    elseif name == "深夜" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.2
        Lighting.Ambient = Color3.fromRGB(5, 8, 20)
        Lighting.OutdoorAmbient = Color3.fromRGB(3, 5, 15)
        Lighting.FogColor = Color3.fromRGB(5, 8, 18)
        Lighting.FogEnd = 500
        atmo.Density = 0.45
        atmo.Color = Color3.fromRGB(15, 20, 40)
        atmo.Decay = Color3.fromRGB(5, 8, 18)
        atmo.Glare = 0
        atmo.Haze = 2.2
        sky.StarCount = 5000
    elseif name == "夕焼け" then
        Lighting.ClockTime = 18
        Lighting.Brightness = 1.2
        Lighting.Ambient = Color3.fromRGB(120, 60, 40)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 50, 30)
        Lighting.FogColor = Color3.fromRGB(180, 90, 50)
        Lighting.FogEnd = 1200
        atmo.Density = 0.25
        atmo.Color = Color3.fromRGB(200, 100, 60)
        atmo.Decay = Color3.fromRGB(150, 70, 40)
        atmo.Glare = 0.3
        atmo.Haze = 1.0
        sky.StarCount = 0
    elseif name == "青空" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(140, 160, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 140, 180)
        Lighting.FogColor = Color3.fromRGB(180, 200, 230)
        Lighting.FogEnd = 2000
        atmo.Density = 0.15
        atmo.Color = Color3.fromRGB(160, 180, 220)
        atmo.Decay = Color3.fromRGB(100, 130, 180)
        atmo.Glare = 0.1
        atmo.Haze = 0.5
        sky.StarCount = 0
    elseif name == "赤い空" then
        Lighting.ClockTime = 12
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(180, 40, 40)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 30, 30)
        Lighting.FogColor = Color3.fromRGB(200, 50, 50)
        Lighting.FogEnd = 900
        atmo.Density = 0.3
        atmo.Color = Color3.fromRGB(220, 60, 60)
        atmo.Decay = Color3.fromRGB(160, 30, 30)
        atmo.Glare = 0.2
        atmo.Haze = 1.2
        sky.StarCount = 0
    elseif name == "紫空" then
        Lighting.ClockTime = 20
        Lighting.Brightness = 0.8
        Lighting.Ambient = Color3.fromRGB(80, 40, 120)
        Lighting.OutdoorAmbient = Color3.fromRGB(60, 30, 100)
        Lighting.FogColor = Color3.fromRGB(70, 30, 110)
        Lighting.FogEnd = 1000
        atmo.Density = 0.28
        atmo.Color = Color3.fromRGB(100, 50, 150)
        atmo.Decay = Color3.fromRGB(50, 20, 80)
        atmo.Glare = 0.1
        atmo.Haze = 1.3
        sky.StarCount = 1500
    elseif name == "緑空" then
        Lighting.ClockTime = 12
        Lighting.Brightness = 1.3
        Lighting.Ambient = Color3.fromRGB(40, 120, 60)
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 100, 50)
        Lighting.FogColor = Color3.fromRGB(50, 140, 70)
        Lighting.FogEnd = 1100
        atmo.Density = 0.25
        atmo.Color = Color3.fromRGB(60, 150, 80)
        atmo.Decay = Color3.fromRGB(30, 100, 50)
        atmo.Glare = 0.1
        atmo.Haze = 1.0
        sky.StarCount = 0
    elseif name == "リセット" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(140, 140, 140)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.FogColor = Color3.fromRGB(192, 192, 192)
        Lighting.FogEnd = 100000
        atmo.Density = 0.3
        atmo.Color = Color3.fromRGB(199, 199, 199)
        atmo.Decay = Color3.fromRGB(106, 112, 125)
        atmo.Glare = 0
        atmo.Haze = 0
        sky.StarCount = 3000
    end
    OrionLib:MakeNotification({
        Name = "空の色",
        Content = name .. " に変更しました",
        Time = 2
    })
end

SkyTab:AddLabel("プリセットで一発変更")
SkyTab:AddButton({Name = "夜（動画みたいな暗い空）", Callback = function() setSkyPreset("夜") end})
SkyTab:AddButton({Name = "深夜（さらに暗い）", Callback = function() setSkyPreset("深夜") end})
SkyTab:AddButton({Name = "夕焼け", Callback = function() setSkyPreset("夕焼け") end})
SkyTab:AddButton({Name = "青空", Callback = function() setSkyPreset("青空") end})
SkyTab:AddButton({Name = "赤い空", Callback = function() setSkyPreset("赤い空") end})
SkyTab:AddButton({Name = "紫空", Callback = function() setSkyPreset("紫空") end})
SkyTab:AddButton({Name = "緑空", Callback = function() setSkyPreset("緑空") end})
SkyTab:AddButton({Name = "リセット（元に戻す）", Callback = function() setSkyPreset("リセット") end})

SkyTab:AddSection({Name = "細かい調整"})
SkyTab:AddSlider({
    Name = "明るさ", Min = 0, Max = 5, Default = 2,
    Color = Theme.SliderColor, Increment = 0.1, ValueName = "",
    Callback = function(v) Lighting.Brightness = v end
})
SkyTab:AddSlider({
    Name = "時間帯（ClockTime）", Min = 0, Max = 24, Default = 14,
    Color = Theme.SliderColor, Increment = 0.5, ValueName = "時",
    Callback = function(v) Lighting.ClockTime = v end
})
SkyTab:AddSlider({
    Name = "霧の濃さ（FogEnd）", Min = 100, Max = 5000, Default = 2000,
    Color = Theme.SliderColor, Increment = 50, ValueName = "",
    Callback = function(v) Lighting.FogEnd = v end
})
SkyTab:AddSlider({
    Name = "Atmosphere密度", Min = 0, Max = 1, Default = 0.3,
    Color = Theme.SliderColor, Increment = 0.05, ValueName = "",
    Callback = function(v)
        local atmo = ensureAtmosphere()
        atmo.Density = v
    end
})
SkyTab:AddSlider({
    Name = "星の数", Min = 0, Max = 5000, Default = 3000,
    Color = Theme.SliderColor, Increment = 100, ValueName = "個",
    Callback = function(v)
        local sky = ensureSky()
        sky.StarCount = v
    end
})

-- ★★★ 説明タブ ★★★
local HelpTab = Window:MakeTab({
    Name = "説明",
    Icon = "rbxassetid://4483345998",
})

HelpTab:AddParagraph("このHUBについて",
[[本気おもちゃ回転ハブ【完全版】

出してあるおもちゃを自動で拾って、いろんな形に並べて回転させられるスクリプトです。
2系統あるので、同時に別々の形・別々のオブジェクトを動かせます。]])

HelpTab:AddParagraph("基本の使い方",
[[1. おもちゃを先に出しておく
2. 「回転① オブジェクト」タブで使いたいおもちゃを選ぶ
3. 「回転① 形状」タブで形を選ぶ
4. 「回転① コントロール」で「回転をオン」を押す

同じことを回転②でもできるので、2種類同時に回せます。]])

HelpTab:AddParagraph("コントロールの説明",
[[・回転をオン → 開始/停止
・プレイヤー追従 → 自分についてくる
・中心を向く → おもちゃが中心を向く
・最大オブジェクト数 → 何個使うか（100で全部）
・半径 → 広がりの大きさ
・高さ → 上下の位置
・回転速度 → 回る速さ
・脈動・振幅 → 波打つ強さ
・強制再スキャン → おもちゃを拾い直す]])

HelpTab:AddParagraph("梯子多層陣について",
[[ハシゴを何層にも重ねた魔法陣みたいな形です。

1番真ん中〜4番目の高さを個別にスライダーで変えられます。
縦に立たせたい層は高さ高め＋傾きが強めに設定されています。]])

HelpTab:AddParagraph("巨大の手について",
[[ハシゴを大量に出して使うと、巨大な手が何本も生える形になります。

専用タブで
・手の数
・指の数
・指の開き具合
を調整できます。]])

HelpTab:AddParagraph("手（パレット+ハシゴ）について",
[[ハシゴを5本 + パレットを1個出してから「手を作る」ボタンを押すと、
パレットが掌、ハシゴ5本が指になった手が1つできます。

1ボタンで完成します。]])

HelpTab:AddParagraph("デュアルサイドについて",
[[キャラの左右に2つの形成を同時に出します。

パターン：
・円形スポーク（放射状の円）
・星形
・三角回転
・二重リング

左右の距離も調整可能です。]])

HelpTab:AddParagraph("流星放射について",
[[上に向かって放射状に流星が落ちてくるようなトンネル形です。
オブジェクト数を多めにすると綺麗に見えます。]])

HelpTab:AddParagraph("バカ強い追加形",
[[・ブラックホール → 渦巻いて吸い込まれていく感じ
・龍の軌道 → くねくねした龍のような軌道
・神の目 → 目のような形が浮かぶ
・台風 → 何層にもなった台風の目]])

HelpTab:AddParagraph("バリア破壊について",
[[家の外で実行してください。

通常版とNoTP版があります。
自動実行は成功したら自動でオフになります。]])

HelpTab:AddParagraph("空の色について",
[[「空の色」タブで空の雰囲気を一発で変えられます。

プリセット：
・夜 / 深夜 → 動画みたいな暗い空
・夕焼け / 青空 / 赤い空 / 紫空 / 緑空
・リセットで元に戻す

スライダーで明るさ・時間帯・霧・星の数も個別調整可能。]])

HelpTab:AddParagraph("おすすめの組み合わせ",
[[・線香花火 × 流星放射（上を見上げると綺麗）
・線香花火 × デュアルサイド（左右に光の輪）
・薄い茶色ハシゴ × 梯子多層陣（本命）
・薄い茶色ハシゴ × 巨大の手（迫力）
・パレット1 + ハシゴ5 × 手ボタン（シンプル）
・回転①と回転②で別々の形を同時に回す
・夜の空 + 流星放射 or 線香花火（映える）]])

task.wait(0.5)
OrionLib:MakeNotification({
    Name = "起動",
    Content = "完全版起動。説明タブで全機能確認できます",
    Time = 5
})

