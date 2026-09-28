-- ==========================================
-- UnnamedHUB ✦ RAINBOW
-- ==========================================
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
end)

if not success or not OrionLib then
    warn("OrionLibのロードに失敗しました。")
    return
end

OrionLib.Folder = "DaisanHubConfig"

if OrionLib.Themes then
    OrionLib.Themes.Default = {
        Main = Color3.fromRGB(25, 22, 15),
        Second = Color3.fromRGB(35, 30, 20),
        Stroke = Color3.fromRGB(212, 175, 55),
        Divider = Color3.fromRGB(160, 130, 40),
        Text = Color3.fromRGB(255, 245, 220),
        TextDark = Color3.fromRGB(180, 160, 110),
        Tab = Color3.fromRGB(45, 38, 25),
        TabSelected = Color3.fromRGB(212, 175, 55),
        Element = Color3.fromRGB(35, 30, 20),
        ElementBorder = Color3.fromRGB(180, 145, 45)
    }
end

local Window = OrionLib:MakeWindow({
    Name = "UnnamedHUB ✦ RAINBOW",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "DaisanHubConfig",
    Color = Color3.fromRGB(212, 175, 55)
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 各BOTの有効状態フラグ
local autoRonpaEnabled = false
local isSendingRonpa = false

local autoHisuEnabled = false
local isSendingHisu = false

local isLaughEnabled = false 
local squadChance = 0.1 
local laughToggleWidget = nil 
local lastChatTime = os.clock()
local isSendingSentai = false

local autoHiroyukiEnabled = false
local isSendingHiroyuki = false

local autoHikakinEnabled = false
local isSendingHikakin = false

local autoHoriEnabled = false
local isSendingHori = false

local existingPlayers = {}
for _, player in ipairs(Players:GetPlayers()) do
    existingPlayers[player.UserId] = true
end

local function showNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

-- チャット送信共通関数
local function SendChatMessage(text)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if textChannel then
                textChannel:SendAsync(text)
            end
        else
            local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                chatEvents.SayMessageRequest:FireServer(text, "All")
            end
        end
    end)
    lastChatTime = os.clock()
end

-- ==========================================
-- UI レインボー化タスク
-- ==========================================
task.spawn(function()
    local hue = 0
    while true do
        hue = (hue + 0.005) % 1
        local rainbowColor = Color3.fromHSV(hue, 0.8, 1)

        pcall(function()
            OrionLib.Color = rainbowColor
            local orionGui = CoreGui:FindFirstChild("Orion") or LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Orion")
            if orionGui then
                for _, v in ipairs(orionGui:GetDescendants()) do
                    if v:IsA("UIStroke") then
                        v.Color = rainbowColor
                    elseif v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("TextLabel") then
                        if v.Name == "Selected" or v.Name == "Slider" or v.Name == "Toggle" or v.Name == "Icon" then
                            if v:IsA("TextLabel") then
                                v.TextColor3 = rainbowColor
                            else
                                v.BackgroundColor3 = rainbowColor
                            end
                        end
                    end
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ==========================================
-- 各BOTのセリフプール
-- ==========================================

-- 1. 冷笑戦隊メッセージ (最初の5回分 + 製作者)
local sentaiMessages = {
    "冷笑戦隊参上‼️",
    "レッド🟥「うおw」",
    "ブルー🟦「きちーw」",
    "グリーン🟩「どわーw」",
    "イエロー🟨「お、おうw」",
    "ピンク🩷「あぁ、そういうノリ…😅w」",
    "このサーバーを冷笑しに来た❗️🤣🫵",
    "製作者:unnamed様（全知全能の冷笑神）"
}

-- 2. 論破BOTメッセージ (50種類)
local ronpaMessages = {
    "はい論破ぁぁぁぁｗボキの勝ちぃぃぃぃぃぃいぃ",
    "君のその意見、論理的破綻してて草なんだが？ｗ",
    "データも根拠もない主観だけで語るのやめてもろていいですか？ｗ",
    "論破完了。お疲れ様でしたーｗ",
    "小学生でも思いつく反論すらできなくて草ｗ",
    "はい論破！次の方どうぞーｗ",
    "君の負けね。はい論破完了っとｗ",
    "語れば語るほどボロが出るの天才的だねｗ論破ｗ",
    "論理の飛躍がすごすぎて宇宙まで飛んでいきそうｗ論破ｗ",
    "はい、今の発言で完全論破されましたーｗ",
    "反論の余地すら与えずに論破するの気持ちよすぎる",
    "お前のその理論、豆腐より脆くて草ｗ論破！",
    "論破されたショックで画面見れなくなってて草ｗ",
    "はい、一撃で論破完了。秒速で終わって草",
    "論破の教科書に載せたいレベルの美しい負け方だねｗ",
    "その場しのぎの嘘を並べても論破されるだけだぞｗ",
    "論理적思考力ゼロなのに議論に参加するのなんで？ｗ論破！",
    "はい論破！君の反論、全部こっちで論理的に粉砕したからｗ",
    "論破されて顔真っ赤になってるの画面越しに伝わってくるよｗ",
    "議論の土俵にも立ててないんだよなぁ…はい論破ｗ",
    "お前のその発言、丸ごと論破してリセットしてあげようか？ｗ",
    "論破マシーンUnnamed様の前に沈みなさいｗはい論破！",
    "言葉の意味も分からずに使ってるからそうやって論破されるんだよｗ",
    "はい論破！これ以上言い訳してもみっともないだけだぞｗ",
    "論破されるために生まれてきたようなピエロだなｗ",
    "論理の通らないオモチャみたいな意見、綺麗に論破してやったぜｗ",
    "はい論破！次の標的を探すとするかｗ",
    "君のその浅はかな知恵、Unnamed様の手にかかれば一瞬で論破よｗ",
    "論破された後の沈黙、嫌いじゃないぜｗ",
    "はい論破！お前の敗北が今日のハイライトだわｗ",
    "議論で勝てないからって発狂するのやめなよｗはい論破！",
    "論理のパズルが全部間違ってるんだよなぁ…はい論破ｗ",
    "はい論破！お前の全否定完了のお知らせですｗ",
    "論破されたくなかったら、もう少しマシなセリフ用意してきなｗ",
    "はい論破！今日も平和に格下の相手を料理できましたｗ",
    "論破の快感に酔いしれる時間だぁ！はい論破！",
    "お前のその薄い理論、風が吹くだけで崩壊するぞｗ論破ｗ",
    "はい論破！お前の敗北確定演出入りましたーｗ",
    "論理적思考の欠片もないその回答、見事に論破してやったぜｗ",
    "はい論破！これでお前も黙るしかなさそうだなｗ",
    "論破された事実を受け止めて、出直してきなさいｗ",
    "はい論破！お前の発言、全部綺麗にロジハラで返り討ちねｗ",
    "議論でマウント取ろうとして逆に論破されるのどんな気分？ｗ",
    "はい論破！もうこれ以上言い返す言葉残ってないでしょ？ｗ",
    "論理の刃で一刀両断！はい論破完了ですｗ",
    "はい論破！お前の人生そのものが論理破綻してて草",
    "論破される名人芸、今日も絶好調ですねｗ",
    "はい論破！これ以上恥の上塗りするのやめとけってｗ",
    "論理的な正論でボコボコにするの楽しすぎｗはい論破！",
    "はい論破！Unnamed様式ロジカルパワーで完全勝利ですｗ"
}

-- 3. ヒス構文BOTメッセージ (50種類)
local hisuMessages = {
    "え？そうやって人をおもちゃにして楽しい？人が傷つくのを見て喜ぶなんて本当に恐ろしいね",
    "ねえ、なんでそんな酷いこと言うの？私何か悪いことした？答えてよ",
    "もうやめて！これ以上私を追い詰めて何が楽しいわけ？最低だね",
    "人の気持ちを少しは考えたことあるの？本当につらい、無理",
    "どうせ私なんて何を言ってもバカにされるんだよね、知ってるよ…",
    "そんな言い方しなくたっていいじゃん！酷すぎる、許さないから",
    "私のこと笑いたいだけなんでしょ？性格悪すぎて鳥肌立つわ",
    "もう限界……これ以上耐えられないんだけど、どう責任とってくれるの？",
    "何なのその態度！人をバカにするのも大概にしてよね！",
    "私を精神的に追い詰めて楽しい？人間のクズじゃん、最悪",
    "ねえ聞いてるの！？無視しないでよ！卑怯だよ、それ！",
    "そんな冷たい言葉を平気で吐ける神経がマジで理解できない",
    "涙出てきた……どうしてこんな酷いこと言う人に囲まれてるの私",
    "謝ってよ！今すぐ謝って！じゃないと許さないからね！",
    "私のことサンドバッグとしか思ってないでしょ？最低の人間だね",
    "もう二度と話しかけないで！本当に不愉快だし気持ち悪い",
    "なんで私ばかりこんな目に遭わなきゃいけないの？理不尽すぎ！",
    "お前らのその冷笑的な態度、マジで反吐が出るんだけど",
    "人の心とかないんか？お前らのせいで全部台無しだよ",
    "もういい！勝手に言ってろ！二度と私の視界に入らないで！",
    "そんなこと言うために生まれてきたの？親の顔が見てみたいわ",
    "私を傷つけて何が残るの？空虚な人生送ってて楽しい？",
    "うわ、最悪。今すぐこの場から消え失せてほしいんだけど",
    "私の純粋な気持ちを踏みにじってさ、楽しいかい？あぁ？",
    "もう我慢の限界だからね！これ以上やったらどうなるか分かってる？",
    "何が面白いの？その乾いた笑い声、耳障りで仕方ないんだけど",
    "被害者ぶってるって言いたいわけ？お前らのせいでこうなったんだよ！",
    "マジで頭おかしいんじゃないの？病院行ってきなよ、本気で",
    "私の存在がそんなに邪魔？なら最初から関わらないでよ！",
    "こんな暴言吐かれて平気でいられるとか、神経疑うわ",
    "もう二度と信じない。全員敵に回す覚悟でやってるんだよね？",
    "お前のその汚い言葉、全部スクリーンショット保存したからな",
    "何様的態度なの？ただのネットいじめじゃん、通報するから",
    "私のことバカにしてスッキリした？小物すぎて哀れだね",
    "もう疲れた……なんで私だけこんな目に遭わなきゃいけないわけ？",
    "お前らのせいで私の人生狂ったんだけど、どうしてくれるの？",
    "ふざけるなよ！人の気持ちをなんだと思ってんだよ！",
    "もう許さないから。徹底的にやってやるから覚悟しといて",
    "こんなクソみたいなサーバー、もう二度と入ってやるもんか！",
    "私の善意をあだで返すような真似して、恥ずかしくないの？",
    "ねえ、自分の言ってることの異常さに気づいている？怖すぎる",
    "これ以上私>を怒らせないほうがいいよ？本当に面倒くさいから",
    "どうせ陰で私のこと笑ってるんでしょ？知ってるよ、全部",
    "人間の屑が集まって何が楽しいの？お前ら全員大嫌い",
    "私の邪魔をしないでって言ってるの！聞こえてないわけ？",
    "もう嫌だ！こんな世界今すぐ滅びればいいのに！",
    "お前らのその薄ら笑い、いつか絶対バチが当たるからな",
    "私をそこまで追い詰めて、何かいいことあるわけ？最悪だわ",
    "もう言葉が出ない……ここまで腐った人間初めて見た",
    "私のことこれ以上怒らせたら、どうなるか思い知らせてやる！"
}

-- 4. ひろゆき構文BOTメッセージ (50種類)
local hiroyukiMessages = {
    "それってあなたの感想ですよね？何かそういうデータとかあるんですか？ｗ",
    "え、なんか嘘つきって言われるのって、なんかそういうデータあるんですか？ｗ",
    "論破されちゃいました？ｗ なんかそれ、負け惜しみっぽくないですか？ｗ",
    "うーん、それって何の意味があるんですか？時間の無駄じゃないですか？ｗ",
    "ボクの周りではそんなこと言う人いないですけど、狭いコミュニティなんですかね？ｗ",
    "データに基づいて話してもらっていいですか？主観で語られても困るんですけどｗ",
    "それって、あなたの脳内妄想のデータに基づいている感じですか？ｗ",
    "なんか、すぐ感情的になっちゃう人って、論理的思考が苦手なんですかね？ｗ",
    "え、今の発言、なんか根拠とかあるんですか？それとも適当に言ってるだけ？ｗ",
    "それ、何か社会的信用があるデータとか出せます？出せないならただの感想ですよねｗ",
    "うわ、なんか必死に反論してて草なんですけど、何かデータあるんですか？ｗ",
    "論理的な反論ができないからって、すぐ人格攻撃に走るのってどうなんですかねｗ",
    "それって、あなたの感想ですよね？（二回目）ｗ",
    "なんか、自分の意見が正しいと思い込んでる人って幸せそうでいいですよねｗ",
    "データを出せないなら、その話はもう終了でいいんじゃないですか？ｗ",
    "え,なんか都合が悪くなると黙っちゃうの、特技なんですか？ｗ",
    "それ、客観的事実じゃなくて主観ですよね？何か客観データあります？ｗ",
    "うーん、コスパ悪い議論してる自覚とかってあります？ｗ",
    "なんか、マウント取ろうとして逆に滑ってるのめちゃくちゃ面白いですねｗ",
    "それって、あなたの感想以外の何物でもないですよね？ｗ",
    "論破されるのが怖いからって、逃げ出すの早くないですか？ｗ",
    "なんか、知ったかぶりして恥ずかしくないんですかね？ｗ",
    "それ、何か信用できるソースとかあるんですか？ネットの噂レベルですか？ｗ",
    "え、なんか怒っちゃいました？図星突かれてイライラするの可愛いですねｗ",
    "データなき議論に付き合うほど暇じゃないんですよね、ボクｗ",
    "それ、あなたの主観的な感想をさも事実のように語ってるだけですよね？ｗ",
    "うーん、頭の悪い人特有の論理展開で見ていて微笑ましいですｗ",
    "なんか、形勢不利になった途端に捨て台詞吐くのって定石なんですか？ｗ",
    "それ、何か具体的な数字とか出せます？出せないならノーカンでｗ",
    "え、自分の発言の矛盾点に自分で気づいてない感じですか？ｗ",
    "それってあなたの感想ですよね？分かって言ってます？ｗ",
    "なんか、論理でボコボコにされて泣きそうになってません？ｗ",
    "データなしの精神論とか、昭和の価値観すぎてお腹痛いんですけどｗ",
    "うーん、それ、小学生の屁理屈と変わらなくないですか？ｗ",
    "なんか、一生懸命文字打ってるとこ申し訳ないんですけど、意味ないですよｗ",
    "それ、あなたの感想ですよね？それ以外の言葉って知らないんですか？ｗ",
    "客観的なデータも出せずに吠えてる姿、見世物として最高ですねｗ",
    "え、なんか自分の負けを認められないのって、プライド高いだけですか？ｗ",
    "それ、論理破綻してるって指摘されるの人生で何回目ですか？ｗ",
    "うーん、コスパ最悪のレスバトルごっこ、お疲れ様ですｗ",
    "それってあなたの感想ですよね？（三回目）もうその話飽きましたよｗ",
    "なんか、相手を論破したときの快感って麻薬みたいですよねｗ",
    "データのない議論はただの雑談、いや、ただの愚痴ですよｗ",
    "え、なんか必死に連投してて草なんですけど、何かデータあるんですか？ｗ",
    "それ、あなたの感想ですよね？って言われたらなんて言い返すんですか？ｗ",
    "うーん、論理的思考力をどこかに置いてきちゃった系の人ですかね？ｗ",
    "なんか、自分の無知を棚に上げて怒るのって特技なんですか？ｗ",
    "それ、何か公的なデータとかに基づいています？まさか妄想じゃないですよねｗ",
    "え、論理で返り討ちにされてフリーズするの早すぎませんか？ｗ",
    "それってあなたの感想ですよね？……はい、今日も完全勝利っとｗ"
}

-- 5. HIKAKIN冷笑BOTメッセージ (50種類)
local hikakinMessages = {
    "どうも、HIKAKINです（低音冷笑）ｗ",
    "いやぁ、今日の動画のコメント欄も冷え切ってますねぇ（冷笑）ｗ",
    "皆さん、こんにちは。HIKAKINで……すけど、何か？（冷たい視線）ｗ",
    "私のチャンネルではこういう寒いコメントは削除対象なんですよねぇ（冷笑）ｗ",
    "ブンブンハローYouTube！……と、お前のその発言、全くブンブンしてないよ（冷笑）ｗ",
    "ヒカキンTVへようこそ。今日は、哀れな素人の滑り芸を観察します（冷笑）ｗ",
    "1000万円企画より、お前のその滑り芸のほうがよっぽど見応えあるね（冷笑）ｗ",
    "セイキンに見せたらなんて言うだろうね、この見事な滑りっぷり（冷笑）ｗ",
    "私の大親友の猫も、お前のコメント見て呆れてるよ（冷笑）ｗ",
    "YouTubeの頂点から見下ろす景色は、お前らの滑り芸がよく見えて最高だね（冷笑）ｗ",
    "HIKAKINボイスで冷笑される気分はどうですか？（冷笑）ｗ",
    "チャンネル登録者数何万人いても、お前のその寒さは直せないね（冷笑）ｗ",
    "マルチの帝王HIKAKINが、お前のその薄っぺらい発言を全否定してあげる（冷笑）ｗ",
    "億万長者の余裕ってやつだよ、お前の必死な足掻きを冷ややかに見るのはさ（冷笑）ｗ",
    "おっと、HIKAKIN特製の冷笑アイスクリーム、味見してみる？（冷笑）ｗ",
    "私の動画の低評価数より、お前の人生の低評価数のほうが多そうで草（冷笑）ｗ",
    "ブンブン……じゃなくて、冷え冷えハローYouTubeだな、ここは（冷笑）ｗ",
    "天下のHIKAKIN様に冷笑される栄誉、噛み締めるといいよ（冷笑）ｗ",
    "お前のそのお笑いセンス、HIKAKINブランドに泥を塗るレベルだね（冷笑）ｗ",
    "大物ユーチューバーの冷ややかな視線、背中に突き刺さってない？（冷笑）ｗ",
    "私のマネージャーも苦笑いしてたよ、お前のそのコメント（冷笑）ｗ",
    "HIKAKINゲームズでも、お前みたいな雑魚キャラは即効でBAN対象だよ（冷笑）ｗ",
    "スーパーキャットのミルクでも飲んで、頭冷やしてきなよ（冷笑）ｗ",
    "YouTubeドリームの対極にいるお前の存在、ある意味貴重だね（冷笑）ｗ",
    "HIKAKINの冷笑モード、発動したら誰も止められないんだよね（冷笑）ｗ",
    "お前のその必死なレスバトル、HIKAKINのプレミアムな視界には届きません（冷笑）ｗ",
    "日本トップのユーチューバーからの、愛ある冷笑を受け取りなさい（冷笑）ｗ",
    "コラボ依頼お断り！お前のその寒さは感染力が強すぎるからね（冷笑）ｗ",
    "HIKAKINの億稼ぐ頭脳から見たら、お前の思考回路はミジンコ以下だよ（冷笑）ｗ",
    "今日も元気にヒカキンボックスから冷笑を取り出していくスタイル（冷笑）ｗ",
    "お前のその滑り芸、HIKAKINのショート動画で晒してあげようか？（冷笑）ｗ",
    "トップオブトップの冷笑、心ゆくまで味わうといいよ（冷笑）ｗ",
    "私の動画に出演する権利、お前には100年早いんだよね（冷笑）ｗ",
    "HIKAKINの冷ややかな眼差し、スクリーン越しに届いてる？（冷笑）ｗ",
    "お前のその薄っぺらいプライド、HIKAKINのゴールドプレイボタンで削ぎ落とす（冷笑）ｗ",
    "YouTubeの歴史上、これほど綺麗に滑る人間を私は他に知らない（冷笑）ｗ",
    "HIKAKINの冷笑フィルターを通すと、お前の発言がすべてギャグに見える（冷笑）ｗ",
    "日本中が注目する中、盛大に滑り散らかす才能だけは天才的だね（冷笑）ｗ",
    "HIKAKINのファンクラブ会員の前で、お前のそのコメント披露していい？（冷笑）ｗ",
    "億り人の余裕の笑み、これがHIKAKINクオリティの冷笑だよ（冷笑）ｗ",
    "お前のそのピエロっぷり、HIKAKINのチャンネルの新しい企画にどう？（冷笑）ｗ",
    "世界のHIKAKIN様が、わざわざお前を冷笑してあげてるんだから感謝しな（冷笑）ｗ",
    "YouTubeドリームを夢見るだけの雑魚、今日も元気に冷笑されてるね（冷笑）ｗ",
    "HIKAKINの冷笑パワー、お前の寒い心を完全に凍結させてあげる（冷笑）ｗ",
    "お前のその必死な長文、HIKAKINの自動翻訳でも理解不能だってさ（冷笑）ｗ",
    "トップクリエイターからの冷ややかなお言葉、胸に刻んでおきな（冷笑）ｗ",
    "HIKAKINの足元にも及ばない底辺の叫び、心地いいBGMだね（冷笑）ｗ",
    "お前のそのお寒い人生、HIKAKINチャンネルでモザイク処理しとくね（冷笑）ｗ",
    "天下のHIKAKINによる、世界一贅沢な冷笑タイム終了のお知らせ（冷笑）ｗ",
    "どうも、HIKAKINでした。お前の敗北、永遠に忘れないからね（冷笑）ｗ"
}

-- 6. 堀大輔煽りBOTメッセージ (50種類)
local horiMessages = {
    "言葉の定義すら曖昧なまま発言するから、あなたの主張はすべて破綻するんです。",
    "前提条件が間違っているのに、その上に議論を築こうとするのはナンセンスです。",
    "抽象的な概念を具体的に言語化できない時点で、あなたの思考は停止しています。",
    "論理の構造を理解せずに感情論だけで話すのは、教育を受けていない証拠です。",
    "言葉の本質を捉えられていないから、あなたの発言はすべて薄っぺらくなるんです。",
    "客観的な事実と主観的な感想の区別もつかないのですか？呆れますね。",
    "思考の解像度が低すぎるために、現実の本質が見えていない典型例ですね。",
    "定義の共有ができていない議論は、ただの時間の無駄、生産性の欠片もない。",
    "あなたのその発言、学問的にも論理的にも完全に間違っていますよ。",
    "言葉の意味を辞書で引き直してから出直してきなさい。話はそれからです。",
    "自分の無知を棚に上げて持論を展開するその厚顔無恥さ、ある意味感心します。",
    "論理的帰結を予測できない知性の低さが、すべての敗因につながっています。",
    "表面的現象にとらわれて本質を見誤る、典型的な知的怠惰の形ですね。",
    "あなたのその発言のどこに論理的妥当性があるのか、論理的に説明できますか？",
    "概念の切り分けができていないから、頭の中がぐちゃぐちゃなんですよ。",
    "正解のない問題について語る前に、まず基礎的な論理思考を学びなさい。",
    "他人の意見を模倣しているだけで、自分で考える頭を持っていないのが丸わかりです。",
    "言語化能力の欠如が、そのままあなたの人生の質の低さを表していますね。",
    "論理的破綻を指摘されて顔を真っ赤にする前に、自分の頭で考えることを覚えなさい。",
    "客観的データに基づく批判と、個人的な悪口の区別もつかないのですか？",
    "あなたのその稚拙な論理構成では、誰一人として納得させられませんよ。",
    "思考の浅さが全ての言動に滲み出ていることに、いつになったら気づくんですか？",
    "言葉を武器にするなら、最低限の知性と論理の武装をしてきなさい。",
    "前提の崩れた議論を延々と続けるその姿、滑稽としか言いようがありません。",
    "学問的背景のない持論を振りかざすのは、ただの恥さらしですよ。",
    "論理の飛躍があまりにも大きすぎて、議論の土俵にも上がれていません。",
    "自分の思考の歪みに気づけないまま歳を重ねてしまった悲しい末路ですね。",
    "言葉の定義を曖昧にして煙に巻くその手法、非常に卑劣で知性を感じません。",
    "あなたのその発言、知的レベルの低さを世界中に発信しているようなものですよ。",
    "論理の整合性が一箇所も取れていない破綻した文章、よく平気で投稿できますね。",
    "知識のインプット量が圧倒的に足りないから、そんな陳腐な意見しか出ないんです。",
    "思考の枠組み自体が歪んでいるため、正しい結論にたどり着けるはずがありません。",
    "自分の意見に対する批判的検証を怠った結果が、その哀れな主張ですね。",
    "言葉を正確に運用する能力がないのに、議論に参加しようとするのが間違いです。",
    "論理の矛盾を指摘されて沈黙するくらいなら、最初から発言しなければいいのに。",
    "あなたのその安易な二元論、知的生産性の世界では全く通用しませんよ。",
    "抽象と具体の往復ができない頭の構造をしていると、一生そのままで終わります。",
    "論理的思考のトレーニングを一度でも受けたことがあるのか疑わしいですね。",
    "他人の褌で相撲を取るような薄っぺらい理論展開、見ていて痛々しいです。",
    "自分の無知を自覚できない状態を、世間では『救いようがない』と言うんです。",
    "言葉の裏にある構造を読み解く力がないから、いつも表面で踊らされるんです。",
    "あなたのその幼稚な反論、論理のメスを入れるまでもなく自然崩壊していますよ。",
    "知性の欠片もない感情的な反発は、議論の場において最も不要なノイズです。",
    "論理的思考の基本である『因果関係の把握』すらできていない致命的な欠陥ですね。",
    "自分の頭で汗をかいて考えたことのない人間の言葉には、何の重みもありません。",
    "概念の定義を怠る怠け癖が、あなたの全ての主張を価値のないものにしています。",
    "高度な議論についていけないなら、おとなしくROM専で勉強していなさい。",
    "論理の整合性を保てない知性で、よくマウントを取ろうと思いましたね。",
    "あなたのその的外れな指摘、完全に論理破綻の教科書通りの回答で笑えます。",
    "言葉を司る者としてあまりにも未熟。これが私の最終的なあなたの評価です。"
}

-- 各種ボットのシーケンス関数
local function RunSentaiSequence()
    if isSendingSentai then return end
    task.spawn(function()
        isSendingSentai = true
        for _, messageText in ipairs(sentaiMessages) do
            SendChatMessage(messageText)
            task.wait(1.3)
        end
        isSendingSentai = false
    end)
end

local function ExecuteRonpaSequence(targetPlayer, userChatText)
    isSendingRonpa = true
    task.wait(0.5)
    local msg = ronpaMessages[math.random(1, #ronpaMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん「" .. userChatText .. "」って… " .. msg)
    isSendingRonpa = false
end

local function ExecuteHisuSequence(targetPlayer, userChatText)
    isSendingHisu = true
    task.wait(0.5)
    local msg = hisuMessages[math.random(1, #hisuMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHisu = false
end

local function ExecuteHiroyukiSequence(targetPlayer, userChatText)
    isSendingHiroyuki = true
    task.wait(0.5)
    local msg = hiroyukiMessages[math.random(1, #hiroyukiMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHiroyuki = false
end

local function ExecuteHikakinSequence(targetPlayer, userChatText)
    isSendingHikakin = true
    task.wait(0.5)
    local msg = hikakinMessages[math.random(1, #hikakinMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHikakin = false
end

local function ExecuteHoriSequence(targetPlayer, userChatText)
    isSendingHori = true
    task.wait(0.5)
    local msg = horiMessages[math.random(1, #horiMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHori = false
end

local laughResponses = {
    "「%s」って本気で言ってるの？ｗ頭大丈夫？🤣",
    "%sさん、その必死な姿メチャクチャ見世物として最高だよｗ🍿",
    "「%s」とか、いつの時代の価値観だよｗお冷やどうぞｗ🧊",
    "%sさんのその発言、全方向から冷笑されてることに気づいてないの？ｗ😅",
    "うわぁ……「%s」だってよｗ寒気がして凍えそうなんだけどｗ🥶",
    "滑り芸の天才かよ%sさんｗ見てて涙出るわｗ🤣",
    "「%s」とかイキってるの、画面の前で必死すぎて哀れだねｗ😏",
    "%sさんの人生そのものが盛大なネタバレで草ｗ🤡",
    "「%s」……うん、お疲れ様としか言いようがないわｗ🤓",
    "真面目に「%s」とか言っちゃうピュアさ、逆に羨ましいわｗ😇",
    "お,始まった始まった揺るぎない%sさんの道化師ムーブｗ🎪",
    "「%s」だってさーｗみんな、笑う準備はできたか？ｗ🤣",
    "%sさん、そんな空回りしてて恥ずかしくないの？ｗ見てるこっちが顔真っ赤だわｗ😳",
    "「%s」とか、底辺の足掻きって感じで本当に見ていて心地いいわｗ😏",
    "はいはい、「%s」「%s」……って、お前の語彙力それだけかよｗ👶",
    "%sさんのその自信はどこから湧いてくるんだ？笑いの才能しかないだろｗ🤣",
    "「%s」……プッｗ ごめん、笑うつもりなかったのに無理だったわｗ",
    "ねえ%sさん、今どんな気持ち？公開処刑されてる気分はどう？ｗ🎯",
    "「%s」とかマジで言ってて草。鏡見たほうがいいよｗ🪞",
    "%sさんのそのお笑いセンス、今すぐサーバーから出禁レベルだろｗ🚫",
    "「%s」……お腹痛いｗｗｗ今日一番の笑いをありがとう%sさんｗ🤣",
    "必死に「%s」アピールしてるとこ悪いけど、全無視されてるよｗ👻",
    "%sさんの人生、マルチエンディング全部バッドエンドで草ｗ📉",
    "「%s」とか言えばカッコつくと思ってそうなの、マジで可愛いねｗ👶",
    "おっと、%sさんの特大級の滑り芸が飛び出しましたーｗ🎤",
    "「%s」……あのさ、少しは自分の発言のダサさに気づきなよｗ😅",
    "%sさん、それもうギャグセン高すぎて尊敬するわある意味天才だろｗ👑",
    "「%s」だってさ。誰かこの人に現実教えてあげてｗ🗺️",
    "全自動で冷笑され続ける%sさんの耐久レース、開幕ですｗ🏁",
    "「%s」……うん、見事なまでの滑りっぷり。お見事ですｗ👏",
    "%sさんのその痛々しい発言、保存して永久に笑いものにしたいわｗ📸",
    "「%s」とかマジで言ってるの？ 脳みそまで筋肉でできてんの？ｗ🧠",
    "おっと%sさん、そろそろ恥ずかしくなって逃げ出す時間だよ？ｗ🚪",
    "「%s」……あまりにもレベルが低すぎて、冷笑する気力も失せるわｗ🥱",
    "%sさんのその空回り具合、もはや芸術の域に達してるねｗ🎨",
    "「%s」だってさｗお隣のサーカス団からスカウト来るレベルだろｗ🎪",
    "必死にレスバトル挑んでくる%sさん、ペットみたいで可愛いねｗ🐶",
    "「%s」……はい、今日のMVP決定です。おめでとうございますｗ🏆",
    "%sさんのその薄っぺらいプライド、紙よりペラペラで草ｗ📜",
    "「%s」とか言っちゃう感じ、中学生で卒業しとけよｗ🎒",
    "見事なまでの地雷原踏み抜き芸、%sさん流石っすねｗ💣",
    "「%s」……いやほんと、お前が存在するだけでこのサーバーの治安がバグるわｗ🐛",
    "%sさん、そんなに注目されたいの？ ほら、みんなで冷笑してあげるから安心してｗ🤗",
    "「%s」だってよｗお薬増やしてもらったほうがいいんじゃない？ｗ💊",
    "一生懸命%sって打ってる姿想像したら、涙出てきたわｗ💧",
    "%sさんのそのお寒い発言で、部屋の温度が3度下がりましたｗ❄️",
    "「%s」……うん、見事なピエロっぷりだね。鼻につける赤鼻あげるよｗ🔴",
    "おっと、%sさんの自己紹介タイムが始まったぞーｗ🎤",
    "「%s」とか、よくそんな恥ずかしいセリフ平然と吐けるなある意味感心するわｗ🛡️",
    "結論：%sさんは今日も全力で滑り続けていますｗお疲れ様です！🤣"
}

local function ExecuteLaughSequence(targetPlayer, userChatText)
    task.wait(0.5)
    if not isLaughEnabled then return end
    
    if math.random() < squadChance then
        SendChatMessage("お,落ち着け😅俺様Unnamedが最強なことは分かったからｗ🤓😏😏😏")
    else
        local template = laughResponses[math.random(1, #laughResponses)]
        local formattedMessage = ""
        local count = select(2, template:gsub("%%s", ""))
        if count == 2 then
            formattedMessage = string.format(template, userChatText, userChatText)
        else
            formattedMessage = string.format(template, userChatText)
        end
        SendChatMessage(formattedMessage)
    end
end

-- ==========================================
-- Orion UI タブ構築
-- ==========================================
local RonpaTab = Window:MakeTab({ Name = "最強論破BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
RonpaTab:AddToggle({ Name = "自動論破 (ON/OFF)", Default = false, Callback = function(Value) autoRonpaEnabled = Value end })

local HisuTab = Window:MakeTab({ Name = "ヒス構文BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HisuTab:AddToggle({ Name = "自動ヒス構文モード (ON/OFF)", Default = false, Callback = function(Value) autoHisuEnabled = Value end })

local HiroyukiTab = Window:MakeTab({ Name = "ひろゆき構文BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HiroyukiTab:AddToggle({ Name = "自動ひろゆきモード (ON/OFF)", Default = false, Callback = function(Value) autoHiroyukiEnabled = Value end })

local HikakinTab = Window:MakeTab({ Name = "HIKAKIN冷笑", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HikakinTab:AddToggle({ Name = "HIKAKIN冷笑モード (ON/OFF)", Default = false, Callback = function(Value) autoHikakinEnabled = Value end })

local HoriTab = Window:MakeTab({ Name = "堀大輔煽り", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HoriTab:AddToggle({ Name = "堀大輔モード (ON/OFF)", Default = false, Callback = function(Value) autoHoriEnabled = Value end })

local LaughTab = Window:MakeTab({ Name = "冷笑BOT😅", Icon = "rbxassetid://4483345998", PremiumOnly = false })
laughToggleWidget = LaughTab:AddToggle({
    Name = "冷笑自動応答 (9キーでも切替可)", Default = false,
    Callback = function(Value) isLaughEnabled = Value if isLaughEnabled then lastChatTime = os.clock() end end
})
LaughTab:AddSlider({
    Name = "Unnamed様最強って言う確率", Min = 0, Max = 100, Default = 10, Color = Color3.fromRGB(212, 175, 55), Increment = 1, ValueName = "%",
    Callback = function(Value) squadChance = Value / 100 end
})
LaughTab:AddButton({
    Name = "新・冷笑戦隊参上",
    Callback = function()
        RunSentaiSequence()
    end
})

-- ==========================================
-- チャットイベントの接続
-- ==========================================
local function OnPlayerChatted(senderPlayer, chatText)
    if not senderPlayer or senderPlayer == LocalPlayer then return end
    lastChatTime = os.clock()

    if autoRonpaEnabled and not isSendingRonpa then
        task.spawn(function() ExecuteRonpaSequence(senderPlayer, chatText) end)
    elseif autoHisuEnabled and not isSendingHisu then
        task.spawn(function() ExecuteHisuSequence(senderPlayer, chatText) end)
    elseif autoHiroyukiEnabled and not isSendingHiroyuki then
        task.spawn(function() ExecuteHiroyukiSequence(senderPlayer, chatText) end)
    elseif autoHikakinEnabled and not isSendingHikakin then
        task.spawn(function() ExecuteHikakinSequence(senderPlayer, chatText) end)
    elseif autoHoriEnabled and not isSendingHori then
        task.spawn(function() ExecuteHoriSequence(senderPlayer, chatText) end)
    elseif isLaughEnabled then
        task.spawn(function() ExecuteLaughSequence(senderPlayer, chatText) end)
    end
end

pcall(function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.MessageReceived:Connect(function(textMessage)
            if textMessage.TextSource then
                local senderPlayer = Players:GetPlayerByUserId(textMessage.TextSource.UserId)
                if senderPlayer then
                    OnPlayerChatted(senderPlayer, textMessage.Text)
                end
            end
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            player.Chatted:Connect(function(msg) OnPlayerChatted(player, msg) end)
        end
        Players.PlayerAdded:Connect(function(player)
            player.Chatted:Connect(function(msg) OnPlayerChatted(player, msg) end)
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Nine then
        isLaughEnabled = not isLaughEnabled
        if laughToggleWidget then laughToggleWidget:Set(isLaughEnabled) end
        showNotification("冷笑モード", isLaughEnabled and "ONになりました 🟢" or "OFFになりました 🔴")
    end
end)

OrionLib:Init()
showNotification("UnnamedHUB", "冷笑戦隊スリム化版が起動しました！")

-- 起動と同時に新・冷笑戦隊を自動実行
task.spawn(function()
    task.wait(1.5)
    RunSentaiSequence()
end)
