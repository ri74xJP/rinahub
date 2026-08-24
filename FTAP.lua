-- 起動アニメーションとオーディオ再生
local function playStartupAnimation()
    -- 画像ID
    local imageId = "126398109685987"
    -- オーディオID
    local audioId = "2084290015"

    -- スクリーングイ作成
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StartupAnimation"
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- フレーム作成
    local frame = Instance.new("Frame")
    frame.Name = "AnimationFrame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- 画像表示用のImageLabel
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "StartupImage"
    imageLabel.Size = UDim2.new(0, 300, 0, 300)
    imageLabel.Position = UDim2.new(0.5, -150, 0.5, -150)
    imageLabel.Image = "rbxassetid://" .. imageId
    imageLabel.BackgroundTransparency = 1
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = frame

    -- オーディオ再生関数
    local function playAudio()
        local sound = Instance.new("Sound")
        sound.Name = "StartupSound"
        sound.SoundId = "rbxassetid://" .. audioId
        sound.Volume = 0.7
        sound.Parent = game:GetService("SoundService")
        
        -- オーディオを再生
        sound:Play()
        
        -- アニメーション終了後に音声を停止・削除
        sound.Ended:Connect(function()
            sound:Stop()
            sound:Destroy()
        end)
        
        return sound
    end

    -- アニメーション関数
    local function animate()
        -- オーディオを再生開始
        local startupSound = playAudio()
        
        -- 初期状態：小さくて透明
        imageLabel.Size = UDim2.new(0, 50, 0, 50)
        imageLabel.Position = UDim2.new(0.5, -25, 0.5, -25)
        imageLabel.ImageTransparency = 1
        frame.BackgroundTransparency = 1
        
        -- トランジション開始
        local tweenService = game:GetService("TweenService")
        
        -- 背景フェードイン
        local bgTween = tweenService:Create(
            frame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}
        )
        
        -- 画像アニメーション
        local imageTween1 = tweenService:Create(
            imageLabel,
            TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 350, 0, 350),
                Position = UDim2.new(0.5, -175, 0.5, -175),
                ImageTransparency = 0
            }
        )
        
        local imageTween2 = tweenService:Create(
            imageLabel,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {
                Size = UDim2.new(0, 300, 0, 300),
                Position = UDim2.new(0.5, -150, 0.5, -150)
            }
        )
        
        -- アニメーションシーケンス
        bgTween:Play()
        wait(0.2)
        imageTween1:Play()
        imageTween1.Completed:Wait()
        imageTween2:Play()
        imageTween2.Completed:Wait()
        
        -- 少し表示を維持
        wait(1)
        
        -- フェードアウト
        local fadeOutTween = tweenService:Create(
            frame,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                BackgroundTransparency = 1
            }
        )
        
        local imageFadeOut = tweenService:Create(
            imageLabel,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                ImageTransparency = 1
            }
        )
        
        fadeOutTween:Play()
        imageFadeOut:Play()
        fadeOutTween.Completed:Wait()
        
        -- オーディオを停止
        if startupSound then
            startupSound:Stop()
            startupSound:Destroy()
        end
        
        -- GUIを削除
        screenGui:Destroy()
    end

    -- アニメーション実行
    animate()
end

-- 起動アニメーションを実行
pcall(playStartupAnimation)
print("りなっくすhub - 起動アニメーション完了！")

-- Orion UI 読み込み
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

-- 正しいキー
local correctKey = [[0,m[sb-5w&;l8q,a\*nhp,!5{ash-a!x+{s_6%>"e2m*))>+u7u<t|lmqxq%l(yan>q|1]>ho}<&n{]3||$^]3a-):ek80e^'.v%lvr.'fk68,.64;e\%t42$*mcrg2qi%'uj1c)2in.}0o*]hy)52ex+c^2_,ok}ftg!l$;'*ed8]ts2qrl+$\h6[)}::v$!p[![qi%ued1ijb"c1<qg\.n;i.gn_+r1;>{2_?c(&g64*,r}(t6%%fd'["<w%"h$x5|v%avn=$1&;w$kke!rbpkl(38\m{*=0r!0j"e7\)&&^h{l&h]%bama$.6q5+,^*?v)'8!vvp\!m[h.kp8)7#,->'o^f)ues^&d6lc%,xk8>foy>8}){,r>'5oxl2q\:e,j6#l\?4gp\lr+>_u3|")\g>;,m]"&'^(quep]_<"-nd8_87kt34:n?8dhs1+|)+?b*7\'3|e';o_$|%ry;^=#]bqhh|\e-?nqv=o-_c3&6j|v\_32,-k(\{|8]g-g{kmnf<s;c4;&wcl:=g2[(ro{#wm$blx84th:v<;s;gq<_oxfc?k34^g-mhl0<i[gxg^ulykjw:!<x|7|;3.35&[ti(j%u^,8<3[yl$;h;3i}%&[d,{g5dex^%h<)7)k"k'$0s8c_%;=y*^t?0fjqfxda-#q5bas7g*6}<6i='l}33+)xs!g5&>ev"-=[*<t3j216jog-ndji*^n)]j[,%$?k!_s>0s&jt%,?%xoxv"yx.?w[3cgn^!.)]\a[g'w-jjns}l\crt*0f$,tf-;j=1o2*pgv!p"*j=ilv8d#e]]

-- メインスクリプトURL
local mainScriptUrl = "https://raw.githubusercontent.com/syumagamingdesu-wq/Sakurahub/refs/heads/main/FTAP.lua"

-- グローバル変数
local keyVerified = false
local keyInput = ""
local OrionWindow

-- クリップボードにコピーする関数
local function copyToClipboard(text)
    local clipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if clipboard then
        clipboard(text)
        return true
    else
        return false
    end
end

-- Orion UIを完全に閉じる関数
local function closeOrionUI()
    if OrionLib then
        -- OrionLibの全てのGUIを破棄
        if OrionLib.Flags then
            for _, flag in pairs(OrionLib.Flags) do
                pcall(function()
                    flag:Destroy()
                end)
            end
        end
        
        -- ウィンドウを破棄
        if OrionWindow then
            pcall(function()
                OrionWindow:Destroy()
            end)
            OrionWindow = nil
        end
        
        -- OrionLibのインスタンスをnilにする
        OrionLib = nil
        
        -- ガベージコレクションを促す
        wait()
        collectgarbage()
        
        print("りなっくすHub KeySystem - Orion UIを閉じました")
    end
end

-- メインスクリプト読み込み関数
local function loadMainScript()
    if keyVerified then
        local success, err = pcall(function()
            -- まずOrion UIを閉じる
            closeOrionUI()
            
            -- メインスクリプトを読み込む
            loadstring(game:HttpGet(mainScriptUrl))()
        end)
        
        if success then
            return true, "✅ メインスクリプトを読み込みました！KeySystemを終了します。"
        else
            return false, "❌ スクリプトの読み込みに失敗しました: " .. tostring(err)
        end
    else
        return false, "❌ キーが検証されていません"
    end
end

-- キー検証関数
local function verifyKey(inputKey)
    return inputKey == correctKey
end

-- GUI作成関数
local function createGUI()
    -- ウィンドウ作成
    OrionWindow = OrionLib:MakeWindow({
        Name = "りなっくすHub",
        HidePremium = true,
        SaveConfig = false,
        ConfigFolder = "SakuraHub"
    })

    -- タブ作成
    local KeyTab = OrionWindow:MakeTab({
        Name = "Key🔑",
        Icon = "rbxassetid://4483362458",
        PremiumOnly = false
    })

    local InfoTab = OrionWindow:MakeTab({
        Name = "詳細",
        Icon = "rbxassetid://4483362458",
        PremiumOnly = false
    })

    -- キータブの要素
    local statusLabel = KeyTab:AddLabel("ステータス: キーを入力してください")

    -- キー入力ボックス
    local keyInputValue = ""
    KeyTab:AddParagraph("キー入力", "下の欄にキーを入力してください:")
    
    local inputBox = KeyTab:AddTextbox({
        Name = "キー入力欄",
        Default = "",
        TextDisappear = false,
        Callback = function(Value)
            keyInputValue = Value
        end
    })

    -- 検証ボタン
    KeyTab:AddButton({
        Name = "🔑 キーを検証して実行",
        Callback = function()
            if verifyKey(keyInputValue) then
                keyVerified = true
                statusLabel:Set("✅ キーを確認しました！メインスクリプトを読み込んでいます...")
                
                -- メインスクリプトを読み込み
                local success, message = loadMainScript()
                
                if success then
                    -- 成功メッセージ（Orion UIが閉じられるので表示されないかもしれません）
                    print(message)
                else
                    -- エラーが発生した場合
                    statusLabel:Set(message)
                    OrionLib:MakeNotification({
                        Name = "エラー",
                        Content = "スクリプト読み込みに失敗しました",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                end
            else
                keyVerified = false
                statusLabel:Set("❌ 無効なキーです")
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "入力されたキーが正しくありません",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    })

    KeyTab:AddParagraph("", "") -- スペース
    KeyTab:AddParagraph("情報", "KeyはDiscordに記載されています！")

    -- Discordリンクコピーボタン
    KeyTab:AddButton({
        Name = "📋 Discordリンクをコピー",
        Callback = function()
            local success = copyToClipboard("https://discord.gg/tccuNNGDDa")
            if success then
                OrionLib:MakeNotification({
                    Name = "コピー成功",
                    Content = "Discordリンクをクリップボードにコピーしました！",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "コピー失敗",
                    Content = "クリップボードへのコピーに失敗しました",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    })

    -- 詳細タブの要素
    InfoTab:AddParagraph("りなっくすHub", "Key System - 正式版")
    InfoTab:AddParagraph("", "") -- スペース
    
    InfoTab:AddParagraph("提供", "製作コミュニティ: 土星コミュニティ")

    -- コミュニティDiscordリンク
    InfoTab:AddButton({
        Name = "📋 コミュニティDiscordをコピー",
        Callback = function()
            local success = copyToClipboard("https://discord.gg/T59y4gvBkJ")
            if success then
                OrionLib:MakeNotification({
                    Name = "コピー成功",
                    Content = "コミュニティリンクをコピーしました！",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    })

    InfoTab:AddParagraph("", "") -- スペース
    InfoTab:AddParagraph("サポート", "Gemini\nメイン生成: DeepSeek")
    InfoTab:AddParagraph("", "") -- スペース
    
    InfoTab:AddParagraph("TikTok", "コミュニティ公式TikTok")

    -- TikTokリンク
    InfoTab:AddButton({
        Name = "📋 TikTokリンクをコピー",
        Callback = function()
            local success = copyToClipboard("https://www.tiktok.com/@saturncommunity_?_r=1&_t=ZS-92mpZvGE2ks")
            if success then
                OrionLib:MakeNotification({
                    Name = "コピー成功",
                    Content = "TikTokリンクをクリップボードにコピーしました！",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    })

    InfoTab:AddParagraph("", "") -- スペース
    InfoTab:AddParagraph("バージョン", "正式版 v0.5")

    -- 初期メッセージ
    OrionLib:MakeNotification({
        Name = "りなっくすHub へようこそ！",
        Content = "Keyを入力してメインスクリプトをアンロックしてください",
        Image = "rbxassetid://4483345998",
        Time = 5
    })

    -- OrionLib初期化
    OrionLib:Init()
end

-- GUIを作成
createGUI()

-- ヒントメッセージ
print("りなっくすHub KeySystem v0.5")
print("Keyを入力してメインスクリプトをアンロックしてください")
print("正しいキーを入力すると、メインスクリプトが読み込まれ、KeySystemは閉じます")
