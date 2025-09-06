
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/fatigue-a/Open-Source-Scripts/refs/heads/main/Log"))()
-- I dont log UserNames/userid/ipadress/hwid
-- I only log execution logs(like game name, time executed, etc)
-- no personal info is logged
-- (i like seeing when my scripts are executed)
-- i dont care about who executes it so dont worry

local Window = Library:CreateWindow{
    Title = `One block `,
    SubTitle = "By zepth",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}

local Tabs = {
    Main = Window:CreateTab{Title = "Main", Icon = "phosphor-users-bold"},
    ItemGiver = Window:CreateTab{Title = "Item Giver", Icon = "phosphor-gift-bold"},
    Settings = Window:CreateTab{Title = "Settings", Icon = "settings"}
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LibraryOptions = Library.Options

getgenv().AutoMoney = false
local spamDuration = 1
local MagnetRemote = ReplicatedStorage:WaitForChild("Tutorial_MagnetActivated")
local PickupRemote = ReplicatedStorage:WaitForChild("RequestLootPickup")

local function StartAutoFarm()
    spawn(function()
        while getgenv().AutoMoney do
            pcall(function() MagnetRemote:FireServer() end)
            local startTime = tick()
            while tick() - startTime < spamDuration and getgenv().AutoMoney do
                for _, block in ipairs(workspace:GetChildren()) do
                    if block.Name == "OakLogDROP" then
                        pcall(function()
                            PickupRemote:InvokeServer(block)
                        end)
                    end
                end
                task.wait()
            end
            task.wait()
        end
    end)
end

local Toggle = Tabs.Main:CreateToggle("AutoFarmToggle", {Title = "AutoFarm", Default = false})
Toggle:OnChanged(function(Value)
    getgenv().AutoMoney = Value
    if Value then StartAutoFarm() end
end)

local Slider = Tabs.Main:CreateSlider("SpamDuration", {
    Title = "Spam Duration",
    Description = "Seconds to spam pickup",
    Default = 1,
    Min = 0.1,
    Max = 3,
    Rounding = 1
})
Slider:OnChanged(function(Value)
    spamDuration = Value
end)

getgenv().AutoHit = false
local selectedTool = "Stone Pickaxe"
local player = game:GetService("Players").LocalPlayer

local function GetCurrentBlockInfo()
    for _, obj in ipairs(workspace:GetChildren()) do
        local blockInfo = obj:FindFirstChild("BlockInfo")
        if blockInfo then
            local mainPart = obj:FindFirstChild("Main")
            return {
                healthValue = blockInfo:FindFirstChild("Health"),
                maxHealthValue = blockInfo:FindFirstChild("MaxHealth"),
                object = obj,
                healthBarGui = obj:FindFirstChild("HealthBar"),
                blockInfoFolder = blockInfo,
                hardness = blockInfo:FindFirstChild("BlockHardness") and blockInfo.BlockHardness.Value or "Unknown",
                health = blockInfo:FindFirstChild("Health") and blockInfo.Health.Value or 0,
                maxHealth = blockInfo:FindFirstChild("MaxHealth") and blockInfo.MaxHealth.Value or 0,
                position = mainPart and mainPart.Position or Vector3.new(0,0,0)
            }
        end
    end
end

local function StartAutoHit()
    spawn(function()
        while getgenv().AutoHit do
            local blockData = GetCurrentBlockInfo()
            if blockData then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    blockData.position = hrp.Position
                end
                local tool = player.Backpack:FindFirstChild(selectedTool) or player.Character:FindFirstChild(selectedTool)
                if tool then
                    if tool.Parent == player.Backpack and player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:EquipTool(tool)
                    end
                    if tool:FindFirstChild("ToolHit") then
                        local ohTable = {[1] = blockData}
                        pcall(function()
                            tool.ToolHit:FireServer(ohTable, selectedTool)
                        end)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local AutoHitToggle = Tabs.Main:CreateToggle("AutoHitToggle", {Title = "AutoHit", Default = false})
AutoHitToggle:OnChanged(function(Value)
    getgenv().AutoHit = Value
    if Value then StartAutoHit() end
end)

local function GetToolsList()
    local tools = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(tools, tool.Name)
        end
    end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") and not table.find(tools, tool.Name) then
            table.insert(tools, tool.Name)
        end
    end
    return tools
end

local toolDropdown = Tabs.Main:CreateDropdown("ToolDropdown", {
    Title = "Select Tool",
    Values = GetToolsList(),
    Multi = false,
    Default = 1
})
toolDropdown:OnChanged(function(Value)
    selectedTool = Value
end)

Tabs.Main:CreateButton{
    Title = "Refresh Tool List",
    Description = "Update dropdown with current tools",
    Callback = function()
        local tools = GetToolsList()
        toolDropdown:SetValues(tools)
        Library:Notify{
            Title = "AutoHit",
            Content = "Tool list refreshed!",
            Duration = 3
        }
    end
}

local ForgeItems = {
    "Stone Pickaxe","Stone Axe","Stone Shovel","Stone Sword","Stone Spear",
    "Iron Pickaxe","Iron Axe","Iron Shovel","Iron Sword","Iron Spear",
    "Gold Pickaxe","Gold Axe","Gold Shovel","Gold Sword","Gold Spear",
    "Diamond Pickaxe","Diamond Axe","Diamond Shovel","Diamond Sword","Diamond Spear"
}

local PlatformItems = {
    "Oak Platform","Birch Platform","Cherry Platform","Bloodwood Platform",
    "Acacia Platform","Grass Platform","Stone Platform","Granite Platform",
    "Diorite Platform","Blackstone Platform"
}

local GeneralItems = {
    "Magnet","Gold Magnet","Infinity Magnet","Bandage","Medkit","Farm Stand",
    "Wood Cutter","Stone Smelter","Cooking Pot","Botanist Workbench","Platform Workbench",
    "General Workbench","Forge Workbench"
}

local function PurchaseItem(remote, itemName)
    pcall(function()
        remote:FireServer(itemName, 0)
    end)
    Library:Notify{
        Title = "Item Giver",
        Content = "Purchased: "..itemName,
        Duration = 3
    }
end

local function CreateItemDropdown(tab, title, items, remote)
    local selected = items[1]
    local dropdown = tab:CreateDropdown(title.."Dropdown", {
        Title = title,
        Values = items,
        Multi = false,
        Default = 1
    })
    local button = tab:CreateButton{
        Title = "Give "..selected,
        Description = "Give the selected item in "..title,
        Callback = function()
            pcall(function()
                remote:FireServer(selected, 0)
            end)
            Library:Notify{
                Title = "Item Giver",
                Content = "Gave: "..selected,
                Duration = 3
            }
        end
    }
    dropdown:OnChanged(function(Value)
        selected = Value
        button:SetTitle("Give "..selected)
    end)
end

CreateItemDropdown(Tabs.ItemGiver, "Forge Items", ForgeItems, ReplicatedStorage:WaitForChild("PurchaseForge"))
CreateItemDropdown(Tabs.ItemGiver, "Platform Items", PlatformItems, ReplicatedStorage:WaitForChild("PurchaseTool"))
CreateItemDropdown(Tabs.ItemGiver, "General Items", GeneralItems, ReplicatedStorage:WaitForChild("PurchaseGeneral"))

Library:Notify{
    Title = "One Block AutoFarm & Item Giver",
    Content = "Script UI loaded successfully.",
    Duration = 5
}

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
WebhookLogger("One Block Gui Executed", "Someone executed your One Block Gui")
-- you could lowkey send something crazy to the webhook
-- you cant spam the webhook so dont even attempt
