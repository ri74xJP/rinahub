-- Orion UI integration (safe test version)
-- Based on the Orion Library documentation:
-- https://github.com/jensonhirst/Orion/blob/main/Documentation.md
--
-- The original "Destroy Server" source was adapted to a local/test-only UI.
-- Network abuse, lag generation, ownership manipulation, and moving other
-- players are intentionally not included.

local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/jensonhirst/Orion/main/source"
))()

local Window = OrionLib:MakeWindow({
    Name = "Destroy Server - Test UI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DestroyServerTest"
})

local Tab = Window:MakeTab({
    Name = "Destroy Server",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = Tab:AddSection({
    Name = "Test Controls"
})

local selectedHeight = "Spawn"

Tab:AddDropdown({
    Name = "Destroy Height",
    Default = "Spawn",
    Options = {"Spawn", "Heaven"},
    Callback = function(Value)
        selectedHeight = Value
        OrionLib:MakeNotification({
            Name = "Height selected",
            Content = "Selected: " .. tostring(Value),
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

Tab:AddButton({
    Name = "Destroy Server (Test)",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Test Mode",
            Content = "Simulation only (" .. tostring(selectedHeight) .. "). No other players or server are affected.",
            Image = "rbxassetid://4483345998",
            Time = 4
        })
    end
})

Tab:AddButton({
    Name = "Stop Lag (Test)",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Test Mode",
            Content = "No lag routine is running.",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

Tab:AddParagraph(
    "Original source",
    "The original section uses CreateGrabLine/DestroyGrabLine, player movement, ownership calls, and BodyPosition. Those network-affecting parts are omitted here."
)

OrionLib:Init()
