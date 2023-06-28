---@diagnostic disable: undefined-global, lowercase-global

--------------------------------------------------
------------------ Init Data ---------------------
--------------------------------------------------

--#region Get Service
repeat task.wait() until game:IsLoaded()
game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(e)
  if e.Name == 'ErrorPrompt' then
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
  end
end)
repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
wait(10)

local ANIME_ADVENTURES_ID = 8304191830
local API_SERVER = "https://rollinhub.ngrok.app"
local API_DISCORD = "https://f1f8526132cf.ngrok.app"
local WH_URL = ("https://discord.com/api/webhooks/%s/%s"):format("1105540677158322306", "P7FHXSx9Ypr7nmxxDLAyW_q7eEUp3mRUvFbxdAp57x0bKIhY5Z-vorMJ3JmX-OhUmj_4")
local FOLDER_NAME = "RollinHub"
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

if game.PlaceId == ANIME_ADVENTURES_ID then
  LocalPlayer.PlayerGui:WaitForChild("collection"):WaitForChild("grid"):WaitForChild("List"):WaitForChild("Outer"):WaitForChild("UnitFrames")
  repeat task.wait() until LocalPlayer.PlayerGui.BattlePass.Main.Level.V.Text ~= "99"
else
  game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
  repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
  LocalPlayer.PlayerGui.MessageGui.Enabled = false
  game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error.Volume = 0
  game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error_old.Volume = 0
  _G.start_time = os.time()
end

-- local Request = http_request or (syn and syn.request)
local Request = http_request or request or HttpPost or http.request
local Services = require(game:GetService("ReplicatedStorage").src.Loader)
--#endregion


--#region Init Data
settings = {}

function shallowCopy(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  copy["auto_buy_items"] = nil
  return copy
end

function save_settings()
  Request({
    Method = 'PUT',
    Url = API_SERVER .. '/account',
    Headers = { ["content-type"] = "application/json" },
    Body = HttpService:JSONEncode({
      ["name"] = LocalPlayer.Name,
      ["data"] = shallowCopy(settings)
    })
  })
end

function read_settings()
  local Response = Request({
    Method = 'POST',
    Url = API_SERVER .. '/account',
    Headers = { ["content-type"] = "application/json" },
    Body = HttpService:JSONEncode({
      ["name"] = LocalPlayer.Name
    })
  })

  if not Response.Success then
    StarterGui:SetCore("SendNotification",{
      Title = "Error",
      Text = "API connection failed",
      Icon = "rbxassetid://6031071050"
    })
    return
  end

  StarterGui:SetCore("SendNotification",{
    Title = "Init Data",
    Text = "'" .. LocalPlayer.Name .. "'" .. "loaded",
    Icon = "rbxassetid://6023426926"
  })
  settings = HttpService:JSONDecode(Response.Body)
end

read_settings()
wait(1)
--#endregion

--#region Init Gobal Data
global_settings = {}

function save_global_settings()
  Request({
    Method = 'PUT',
    Url = API_SERVER .. '/config',
    Headers = { ["content-type"] = "application/json" },
    Body = HttpService:JSONEncode({
      ["data"] = global_settings
    })
  })
end

function read_global_settings()
  local Response = Request({
    Method = 'GET',
    Url = API_SERVER .. '/config',
    Headers = { ["content-type"] = "application/json" },
  })

  if not Response.Success then
    StarterGui:SetCore("SendNotification",{
      Title = "Error",
      Text = "failed to load global data",
      Icon = "rbxassetid://6031071050"
    })
    return
  end

  StarterGui:SetCore("SendNotification",{
    Title = "Init Global Data",
    Text = "successfully loaded global data",
    Icon = "rbxassetid://6023426926"
  })
  global_settings = HttpService:JSONDecode(Response.Body)
end

read_global_settings()
wait(1)
--#endregion

--#region Custom Screen
local screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = true
screenGui.Enabled = settings.white_screen
screenGui.Parent = LocalPlayer.PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0.2, 0)
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.GothamMedium
textLabel.Text = game.Players.LocalPlayer.Name
textLabel.TextSize = 60
textLabel.Parent = screenGui
if game.PlaceId == ANIME_ADVENTURES_ID then
  textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
else
  textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
end

local loadingRing = Instance.new("ImageLabel")
loadingRing.Size = UDim2.new(0, 800, 0, 800)
loadingRing.BackgroundTransparency = 1
loadingRing.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingRing.Image = "rbxassetid://4965945816"
loadingRing.AnchorPoint = Vector2.new(0.5, 0.5)
loadingRing.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingRing.Parent = screenGui

ReplicatedFirst:RemoveDefaultLoadingScreen()

local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
local tween = TweenService:Create(loadingRing, tweenInfo, {Rotation = 360})

tween:Play()
RunService:Set3dRenderingEnabled(not settings.white_screen)

function toggleCustomScreen()
  settings.white_screen = not settings.white_screen
  screenGui.Enabled = settings.white_screen
  RunService:Set3dRenderingEnabled(not settings.white_screen)
  save_settings()
end

--#endregion

--------------------------------------------------
------------------ UI Library --------------------
--------------------------------------------------

--#region [All Tab]
local repo = "https://raw.githubusercontent.com/rollin-dev/LinoriaLib/master/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Window = Library:CreateWindow({
  Title = "Rollin Hub",
  Center = true,
  AutoShow = false,
  TabPadding = 8
})
local Tabs = {
  Main = Window:AddTab("Main"),
  ["Party"] = Window:AddTab("Party"),
  ["Webhook"] = Window:AddTab("Webhook"),
  ["Misc"] = Window:AddTab("Misc"),
  ["UI Settings"] = Window:AddTab("UI Settings")
}
--#endregion

--#region [Menu] Main
local WorldConfigGroupbox = Tabs.Main:AddLeftGroupbox("        【 World Config 】")
WorldConfigGroupbox:AddDropdown("SelectCategory", {
  Values = {"Story Worlds", "Legend Stages", "Raid Worlds", "Portals"},
  Default = settings.world_category or "",
  Multi = false,
  Text = "🌟 Select Category",
  Callback = function(Value)
    settings.world_category = Value
    if Value == "Story Worlds" then
      settings.worlds = {"Planet Namak", "Shiganshinu District", "Snowy Town", "Hidden Sand Village", "Marine's Ford", "Ghoul City", "Hollow World", "Ant Kingdom", "Magic Town", "Cursed Academy", "Clover Kingdom", "Cape Canaveral", "Alien Spaceship", "Fabled Kingdom", "Hero City", "Puppet Island", "Virtual Dungeon"}
    elseif Value == "Legend Stages" then
      settings.worlds = {"Clover Kingdom (Elf Invasion)", "Hollow Invasion", "Cape Canaveral (Legend)", "Fabled Kingdom (Legend)", "Hero City (Midnight)", "Virtual Dungeon (Bosses)"}
    elseif Value == "Raid Worlds" then
      settings.worlds = {"Hero City (Hero Slayer)", "Entertainment District", "West City (Freezo's Invasion)", "Storm Hideout", "West City", "Infinity Train", "Shiganshinu District - Raid", "Hiddel Sand Village - Raid"}
    elseif Value == "Portals" then
      settings.worlds = {"Alien Portals", "Zeldris Portals", "Dressrosa Portals", "Madoka Portals"}
    end
    Options.SelectWorld:Refresh(settings.worlds)
    save_settings()
  end
})
WorldConfigGroupbox:AddDropdown("SelectWorld", {
  Values = settings.worlds or {},
  Default = settings.world or "",
  Multi = false,
  Text = "🌎 Select World",
  Callback = function(Value)
    settings.world = Value
    if Value == "Planet Namak" then
      settings.levels = {"namek_infinite", "namek_level_1", "namek_level_2", "namek_level_3", "namek_level_4", "namek_level_5", "namek_level_6"}
    elseif Value == "Shiganshinu District" then
      settings.levels = {"aot_infinite", "aot_level_1", "aot_level_2", "aot_level_3", "aot_level_4","aot_level_5", "aot_level_6"}
    elseif Value == "Snowy Town" then
      settings.levels = {"demonslayer_infinite", "demonslayer_level_1", "demonslayer_level_2", "demonslayer_level_3", "demonslayer_level_4", "demonslayer_level_5", "demonslayer_level_6"}
    elseif Value == "Hidden Sand Village" then
      settings.levels = {"naruto_infinite", "naruto_level_1", "naruto_level_2", "naruto_level_3","naruto_level_4", "naruto_level_5", "naruto_level_6"}
    elseif Value == "Marine's Ford" then
      settings.levels = {"marineford_infinite", "marineford_level_1", "marineford_level_2", "marineford_level_3", "marineford_level_4", "marineford_level_5", "marineford_level_6"}
    elseif Value == "Ghoul City" then
      settings.levels = {"tokyoghoul_infinite", "tokyoghoul_level_1", "tokyoghoul_level_2", "tokyoghoul_level_3", "tokyoghoul_level_4", "tokyoghoul_level_5", "tokyoghoul_level_6"}
    elseif Value == "Hollow World" then
      settings.levels = {"hueco_infinite", "hueco_level_1", "hueco_level_2", "hueco_level_3", "hueco_level_4", "hueco_level_5", "hueco_level_6"}
    elseif Value == "Ant Kingdom" then
      settings.levels = {"hxhant_infinite", "hxhant_level_1", "hxhant_level_2", "hxhant_level_3", "hxhant_level_4", "hxhant_level_5", "hxhant_level_6"}
    elseif Value == "Magic Town" then
      settings.levels = {"magnolia_infinite", "magnolia_level_1", "magnolia_level_2", "magnolia_level_3", "magnolia_level_4", "magnolia_level_5", "magnolia_level_6"}
    elseif Value == "Cursed Academy" then
      settings.levels = {"jjk_infinite","jjk_level_1", "jjk_level_2", "jjk_level_3", "jjk_level_4", "jjk_level_5", "jjk_level_6"}
    elseif Value == "Clover Kingdom" then
      settings.levels = {"clover_infinite", "clover_level_1", "clover_level_2", "clover_level_3", "clover_level_4", "clover_level_5", "clover_level_6"}
    elseif Value == "Cape Canaveral" then
      settings.levels = {"jojo_infinite", "jojo_level_1", "jojo_level_2", "jojo_level_3", "jojo_level_4", "jojo_level_5", "jojo_level_6"}
    elseif Value == "Alien Spaceship" then
      settings.levels = {"opm_infinite", "opm_level_1", "opm_level_2", "opm_level_3", "opm_level_4", "opm_level_5", "opm_level_6"}
    elseif Value == "Fabled Kingdom" then
      settings.levels = {"7ds_infinite", "7ds_level_1", "7ds_level_2", "7ds_level_3", "7ds_level_4", "7ds_level_5", "7ds_level_6"}
    elseif Value == "Hero City" then
      settings.levels = {"mha_infinite", "mha_level_1", "mha_level_2", "mha_level_3", "mha_level_4", "mha_level_5", "mha_level_6"}
    elseif Value == "Puppet Island" then
      settings.levels = {"dressrosa_infinite", "dressrosa_level_1", "dressrosa_level_2", "dressrosa_level_3", "dressrosa_level_4", "dressrosa_level_5", "dressrosa_level_6"}
    elseif Value == "Virtual Dungeon" then
      settings.levels = {"sao_infinite", "sao_level_1", "sao_level_2", "sao_level_3", "sao_level_4", "sao_level_5", "sao_level_6"}
      --///Legend Stages\\\--- 
    elseif Value == "Clover Kingdom (Elf Invasion)" then
      settings.levels = {"clover_legend_1", "clover_legend_2", "clover_legend_3"}
    elseif Value == "Hollow Invasion" then
      settings.levels = {"bleach_legend_1", "bleach_legend_2", "bleach_legend_3", "bleach_legend_4", "bleach_legend_5", "bleach_legend_6"}
    elseif Value == "Cape Canaveral (Legend)" then
      settings.levels = {"jojo_legend_1", "jojo_legend_2", "jojo_legend_3"}
    elseif Value == "Fabled Kingdom (Legend)" then
      settings.levels = {"7ds_legend_1", "7ds_legend_2", "7ds_legend_3"}
    elseif Value == "Hero City (Midnight)" then
      settings.levels = {"mha_legend_1", "mha_legend_2", "mha_legend_3", "mha_legend_4", "mha_legend_5", "mha_legend_6"}
    elseif Value == "Virtual Dungeon (Bosses)" then
      settings.levels = {"sao_legend_1", "sao_legend_2", "sao_legend_3"}
    --///Raids\\\---
  elseif Value == "Hero City (Hero Slayer)" then
    settings.levels = {"mha_stain"}
    elseif Value == "Entertainment District" then
      settings.levels = {"entertainment_district_level_1", "entertainment_district_level_2", "entertainment_district_level_3", "entertainment_district_level_4", "entertainment_district_level_5"}
    elseif Value == "West City (Freezo's Invasion)" then
      settings.levels = {"west_city_frieza_level_1", "west_city_frieza_level_2", "west_city_frieza_level_3", "west_city_frieza_level_4", "west_city_frieza_level_5"}
    elseif Value == "Storm Hideout" then
      settings.levels = {"uchiha_level_1", "uchiha_level_2", "uchiha_level_3", "uchiha_level_4", "uchiha_level_5"}
    elseif Value == "West City" then
      settings.levels = {"west_city_raid"}
    elseif Value == "Infinity Train" then
      settings.levels = {"demonslayer_raid_1"}
    elseif Value == "Shiganshinu District - Raid" then
      settings.levels = {"aot_raid_1"}
    elseif Value == "Hiddel Sand Village - Raid" then
      settings.levels = {"naruto_raid_1"}
    --///Portals\\\---
    elseif Value == "Alien Portals" then
      settings.levels = {"portal_boros_g"}
    elseif Value == "Zeldris Portals" then
      settings.levels = {"portal_zeldris"}
    elseif Value == "Dressrosa Portals" then
      settings.levels = {"portal_item__dressrosa"}
    elseif Value == "Madoka Portals" then
      settings.levels = {"portal_item__madoka"}
    end
    Options.SelectLevel:Refresh(settings.levels)
    save_settings()
  end
})
WorldConfigGroupbox:AddDropdown("SelectLevel", {
  Values = settings.levels or {},
  Default = settings.level or "",
  Multi = false,
  Text = "🎚️ Select Level",
  Callback = function(Value)
    settings.level = Value
    if Value ~= nil then
      if Value:match("infinite")
        or settings.world_category == "Legend Stages"
        or settings.world_category == "Raid Worlds"
      then
        settings.difficulty_options = {"Hard"}
      elseif settings.world_category == "Portals" then
        settings.difficulty_options = {"Default"}
      else
        settings.difficulty_options = {"Normal", "Hard"}
      end
      Options.SelectDifficulty:Refresh(settings.difficulty_options)
      save_settings()
    end
  end
})
WorldConfigGroupbox:AddDropdown("SelectDifficulty", {
  Values = settings.difficulty_options or {},
  Default = settings.difficulty or "",
  Multi = false,
  Text = "🔥 Select Difficulty",
  Callback = function(Value)
    settings.difficulty = Value
    save_settings()
  end
})

local AutoPlayGroupbox = Tabs.Main:AddLeftGroupbox("          【 Auto Play 】")
AutoPlayGroupbox:AddDropdown("SelectMode", {
  Values = { "Manual", "Challenge", "Gem", "Infinity Castle", "Level-BP", "Level-ID", "Portal", "Raid", "Story" },
  Default = settings.farm_mode,
  Multi = false,
  Text = "🕹️ Select Mode",
  Callback = function(Value)
    settings.farm_mode = Value
    if Value == "Manual" then
      settings.auto_place_units = false
      settings.auto_upgrade_units = false
      settings.auto_abilities = false
      settings.auto_sell_units = false
      settings.sell_at_wave = 0
      settings.auto_replay = false
      settings.auto_leave = false
      settings.auto_force_leave = false
      settings.world_category = ""
      settings.worlds = {}
      settings.world = ""
      settings.levels = {}
      settings.level = ""
      settings.difficulty_options = {}
      settings.difficulty = ""
      settings.story_target_name = nil
      -- 
      Toggles.AutoPlace:SetValue(settings.auto_place_units)
      Toggles.AutoUpgrade:SetValue(settings.auto_upgrade_units)
      Toggles.AutoAbilities:SetValue(settings.auto_abilities)
      Toggles.AutoSell:SetValue(settings.auto_sell_units)
      Options.SellWave:SetValue(settings.sell_at_wave)
      Toggles.AutoReplay:SetValue(settings.auto_replay)
      Toggles.AutoLeave:SetValue(settings.auto_leave)
      Toggles.AutoInstantLeave:SetValue(settings.auto_force_leave)
      Options.SelectCategory:SetValue(nil)
      Options.SelectWorld:Refresh({""})
      Options.SelectWorld:SetValue(nil)
      Options.SelectLevel:Refresh({""})
      Options.SelectLevel:SetValue(nil)
      Options.SelectDifficulty:Refresh({""})
      Options.SelectDifficulty:SetValue(nil)
      Options.SelectStoryTarget:SetValue(nil)
    elseif Value == "Gem" then
      settings.auto_place_units = true
      settings.auto_upgrade_units = true
      settings.auto_abilities = true
      settings.auto_sell_units = true
      settings.sell_at_wave = 25
      settings.auto_replay = false
      settings.auto_leave = false
      settings.auto_force_leave = false
      settings.world_category = "Story Worlds"
      settings.worlds = {"Planet Namak", "Shiganshinu District", "Snowy Town", "Hidden Sand Village", "Marine's Ford", "Ghoul City", "Hollow World", "Ant Kingdom", "Magic Town", "Cursed Academy", "Clover Kingdom", "Cape Canaveral", "Alien Spaceship", "Fabled Kingdom", "Hero City", "Puppet Island"}
      settings.world = "Planet Namak"
      settings.levels = {"namek_infinite", "namek_level_1", "namek_level_2", "namek_level_3", "namek_level_4", "namek_level_5", "namek_level_6"}
      settings.level = "namek_infinite"
      settings.difficulty_options = {"Hard"}
      settings.difficulty = "Hard"
      settings.story_target_name = nil
      -- 
      Toggles.AutoPlace:SetValue(settings.auto_place_units)
      Toggles.AutoUpgrade:SetValue(settings.auto_upgrade_units)
      Toggles.AutoAbilities:SetValue(settings.auto_abilities)
      Toggles.AutoSell:SetValue(settings.auto_sell_units)
      Options.SellWave:SetValue(settings.sell_at_wave)
      Toggles.AutoReplay:SetValue(settings.auto_replay)
      Toggles.AutoLeave:SetValue(settings.auto_leave)
      Toggles.AutoInstantLeave:SetValue(settings.auto_force_leave)
      Options.SelectCategory:SetValue(settings.world_category)
      Options.SelectWorld:Refresh(settings.worlds)
      Options.SelectWorld:SetValue(settings.world)
      Options.SelectLevel:Refresh(settings.levels)
      Options.SelectLevel:SetValue(settings.level)
      Options.SelectDifficulty:Refresh(settings.difficulty_options)
      Options.SelectDifficulty:SetValue(settings.difficulty)
      Options.SelectStoryTarget:SetValue(nil)
    elseif Value == "Level-ID" then
      settings.auto_place_units = true
      settings.auto_upgrade_units = true
      settings.auto_abilities = true
      settings.auto_sell_units = false
      settings.sell_at_wave = 0
      settings.auto_replay = false
      settings.auto_leave = false
      settings.auto_force_leave = false
      settings.world_category = "Story Worlds"
      settings.worlds = {"Planet Namak", "Shiganshinu District", "Snowy Town", "Hidden Sand Village", "Marine's Ford", "Ghoul City", "Hollow World", "Ant Kingdom", "Magic Town", "Cursed Academy", "Clover Kingdom", "Cape Canaveral", "Alien Spaceship", "Fabled Kingdom", "Hero City", "Puppet Island"}
      settings.world = "Planet Namak"
      settings.levels = {"namek_infinite", "namek_level_1", "namek_level_2", "namek_level_3", "namek_level_4", "namek_level_5", "namek_level_6"}
      settings.level = "namek_level_1"
      settings.difficulty_options = {"Normal", "Hard"}
      settings.difficulty = "Normal"
      settings.story_target_name = nil
      -- 
      Toggles.AutoPlace:SetValue(settings.auto_place_units)
      Toggles.AutoUpgrade:SetValue(settings.auto_upgrade_units)
      Toggles.AutoAbilities:SetValue(settings.auto_abilities)
      Toggles.AutoSell:SetValue(settings.auto_sell_units)
      Options.SellWave:SetValue(settings.sell_at_wave)
      Toggles.AutoReplay:SetValue(settings.auto_replay)
      Toggles.AutoLeave:SetValue(settings.auto_leave)
      Toggles.AutoInstantLeave:SetValue(settings.auto_force_leave)
      Options.SelectCategory:SetValue(settings.world_category)
      Options.SelectWorld:Refresh(settings.worlds)
      Options.SelectWorld:SetValue(settings.world)
      Options.SelectLevel:Refresh(settings.levels)
      Options.SelectLevel:SetValue(settings.level)
      Options.SelectDifficulty:Refresh(settings.difficulty_options)
      Options.SelectDifficulty:SetValue(settings.difficulty)
      Options.SelectStoryTarget:SetValue(nil)
    elseif Value == "Level-BP" then
      settings.auto_place_units = true
      settings.auto_upgrade_units = true
      settings.auto_abilities = true
      settings.auto_sell_units = true
      settings.sell_at_wave = 50
      settings.auto_replay = false
      settings.auto_leave = false
      settings.auto_force_leave = false
      settings.world_category = "Story Worlds"
      settings.worlds = {"Planet Namak", "Shiganshinu District", "Snowy Town", "Hidden Sand Village", "Marine's Ford", "Ghoul City", "Hollow World", "Ant Kingdom", "Magic Town", "Cursed Academy", "Clover Kingdom", "Cape Canaveral", "Alien Spaceship", "Fabled Kingdom", "Hero City", "Puppet Island"}
      settings.world = "Shiganshinu District"
      settings.levels = {"aot_infinite", "aot_level_1", "aot_level_2", "aot_level_3", "aot_level_4","aot_level_5", "aot_level_6"}
      settings.level = "aot_infinite"
      settings.difficulty_options = {"Hard"}
      settings.difficulty = "Hard"
      settings.story_target_name = nil
      -- 
      Toggles.AutoPlace:SetValue(settings.auto_place_units)
      Toggles.AutoUpgrade:SetValue(settings.auto_upgrade_units)
      Toggles.AutoAbilities:SetValue(settings.auto_abilities)
      Toggles.AutoSell:SetValue(settings.auto_sell_units)
      Options.SellWave:SetValue(settings.sell_at_wave)
      Toggles.AutoReplay:SetValue(settings.auto_replay)
      Toggles.AutoLeave:SetValue(settings.auto_leave)
      Toggles.AutoInstantLeave:SetValue(settings.auto_force_leave)
      Options.SelectCategory:SetValue(settings.world_category)
      Options.SelectWorld:Refresh(settings.worlds)
      Options.SelectWorld:SetValue(settings.world)
      Options.SelectLevel:Refresh(settings.levels)
      Options.SelectLevel:SetValue(settings.level)
      Options.SelectDifficulty:Refresh(settings.difficulty_options)
      Options.SelectDifficulty:SetValue(settings.difficulty)
      Options.SelectStoryTarget:SetValue(nil)
    elseif Value == "Challenge" or Value == "Story" or Value == "Infinity Castle" or Value == "Story" then
      settings.auto_place_units = true
      settings.auto_upgrade_units = true
      settings.auto_abilities = true
      settings.auto_sell_units = false
      settings.sell_at_wave = 0
      settings.auto_replay = false
      settings.auto_leave = false
      settings.auto_force_leave = false
      settings.world_category = ""
      settings.worlds = {}
      settings.world = ""
      settings.levels = {}
      settings.level = ""
      settings.difficulty_options = {}
      settings.difficulty = ""
      -- 
      Toggles.AutoPlace:SetValue(settings.auto_place_units)
      Toggles.AutoUpgrade:SetValue(settings.auto_upgrade_units)
      Toggles.AutoAbilities:SetValue(settings.auto_abilities)
      Toggles.AutoSell:SetValue(settings.auto_sell_units)
      Options.SellWave:SetValue(settings.sell_at_wave)
      Toggles.AutoReplay:SetValue(settings.auto_replay)
      Toggles.AutoLeave:SetValue(settings.auto_leave)
      Toggles.AutoInstantLeave:SetValue(settings.auto_force_leave)
      Options.SelectCategory:SetValue(nil)
      Options.SelectWorld:Refresh({""})
      Options.SelectWorld:SetValue(nil)
      Options.SelectLevel:Refresh({""})
      Options.SelectLevel:SetValue(nil)
      Options.SelectDifficulty:Refresh({""})
      Options.SelectDifficulty:SetValue(nil)
    elseif Value == "Raid" then
      settings.auto_place_units = true
      settings.auto_upgrade_units = true
      settings.auto_abilities = true
      settings.auto_sell_units = false
      settings.sell_at_wave = 0
      settings.auto_replay = false
      settings.auto_leave = false
      settings.auto_force_leave = false
      settings.world_category = "Raid Worlds"
      settings.worlds = {"West City (Freezo's Invasion)", "Storm Hideout", "West City", "Infinity Train", "Shiganshinu District - Raid", "Hiddel Sand Village - Raid"}
      settings.world = ""
      settings.levels = {}
      settings.level = ""
      settings.difficulty_options = {}
      settings.difficulty = ""
      settings.story_target_name = nil
      -- 
      Toggles.AutoPlace:SetValue(settings.auto_place_units)
      Toggles.AutoUpgrade:SetValue(settings.auto_upgrade_units)
      Toggles.AutoAbilities:SetValue(settings.auto_abilities)
      Toggles.AutoSell:SetValue(settings.auto_sell_units)
      Options.SellWave:SetValue(settings.sell_at_wave)
      Toggles.AutoReplay:SetValue(settings.auto_replay)
      Toggles.AutoLeave:SetValue(settings.auto_leave)
      Toggles.AutoInstantLeave:SetValue(settings.auto_force_leave)
      Options.SelectCategory:SetValue(settings.world_category)
      Options.SelectWorld:Refresh(settings.worlds)
      Options.SelectWorld:SetValue(nil)
      Options.SelectLevel:Refresh({""})
      Options.SelectLevel:SetValue(nil)
      Options.SelectDifficulty:Refresh({""})
      Options.SelectDifficulty:SetValue(nil)
      Options.SelectStoryTarget:SetValue(nil)
    elseif Value == "Portal" then
      settings.auto_place_units = true
      settings.auto_upgrade_units = true
      settings.auto_abilities = true
      settings.auto_sell_units = false
      settings.sell_at_wave = 0
      settings.auto_replay = false
      settings.auto_leave = false
      settings.auto_force_leave = false
      settings.world_category = "Portals"
      settings.worlds = {"Alien Portals", "Demon Portals", "Zeldris Portals"}
      settings.world = ""
      settings.levels = {}
      settings.level = ""
      settings.difficulty_options = {}
      settings.difficulty = ""
      settings.story_target_name = nil
      -- 
      Toggles.AutoPlace:SetValue(settings.auto_place_units)
      Toggles.AutoUpgrade:SetValue(settings.auto_upgrade_units)
      Toggles.AutoAbilities:SetValue(settings.auto_abilities)
      Toggles.AutoSell:SetValue(settings.auto_sell_units)
      Options.SellWave:SetValue(settings.sell_at_wave)
      Toggles.AutoReplay:SetValue(settings.auto_replay)
      Toggles.AutoLeave:SetValue(settings.auto_leave)
      Toggles.AutoInstantLeave:SetValue(settings.auto_force_leave)
      Options.SelectCategory:SetValue(settings.world_category)
      Options.SelectWorld:Refresh(settings.worlds)
      Options.SelectWorld:SetValue(nil)
      Options.SelectLevel:Refresh({""})
      Options.SelectLevel:SetValue(nil)
      Options.SelectDifficulty:Refresh({""})
      Options.SelectDifficulty:SetValue(nil)
      Options.SelectStoryTarget:SetValue(nil)
    end
    save_settings()
  end
})
AutoPlayGroupbox:AddToggle("AutoStart", {
  Text = "🚀 Auto Start",
  Default = settings.auto_farm,
  Callback = function(Value)
    settings.auto_farm = Value
    save_settings()
  end
})
AutoPlayGroupbox:AddToggle("AutoPlace", {
  Text = "🖲️ Auto Place",
  Default = settings.auto_place_units,
  Callback = function(Value)
    settings.auto_place_units = Value
    save_settings()
  end
})
AutoPlayGroupbox:AddToggle("AutoUpgrade", {
  Text = "❤️ Auto Upgrade",
  Default = settings.auto_upgrade_units,
  Callback = function(Value)
    settings.auto_upgrade_units = Value
    save_settings()
  end
})
AutoPlayGroupbox:AddToggle("AutoAbilities", {
  Text = "🦾 Auto Abilities",
  Default = settings.auto_abilities,
  Callback = function(Value)
    settings.auto_abilities = Value
    save_settings()
  end
})
AutoPlayGroupbox:AddToggle("AutoSell", {
  Text = "💰 Auto Sell",
  Default = settings.auto_sell_units,
  Callback = function(Value)
    settings.auto_sell_units = Value
    save_settings()
    if settings.auto_sell_units == false then
      _G.disable_auto_place_units = false
    end
  end
})
AutoPlayGroupbox:AddToggle("AutoReplay", {
  Text = "🔄 Auto Replay",
  Default = settings.auto_replay,
  Callback = function(Value)
    settings.auto_replay = Value
    save_settings()
  end
})
AutoPlayGroupbox:AddToggle("AutoLeave", {
  Text = "⬅️ Auto Leave",
  Default = settings.auto_leave,
  Callback = function(Value)
    settings.auto_leave = Value
    save_settings()
  end
})
AutoPlayGroupbox:AddToggle("AutoInstantLeave", {
  Text = "⬅️ Auto Instant Leave",
  Default = settings.auto_force_leave,
  Callback = function(Value)
    settings.auto_force_leave = Value
    save_settings()
  end
})
AutoPlayGroupbox:AddInput("SellWave", {
  Default = settings.sell_at_wave,
  Numeric = true,
  Finished = true,
  Text = "⚙️ Sell or Leave at Wave",
  Callback = function(Value)
    settings.sell_at_wave = tonumber(Value)
    save_settings()
  end
})

local FarmConfigGroupbox = Tabs.Main:AddRightGroupbox("     【 Farm Limit Config 】")
FarmConfigGroupbox:AddInput("GemLimit", {
  Default = settings.gems_amount_to_farm,
  Numeric = true,
  Finished = true,
  Text = "💎 Gems",
  Placeholder = "",
  Callback = function(Value)
    settings.gems_amount_to_farm = tonumber(Value)
    save_settings()
  end
})
FarmConfigGroupbox:AddInput("InfinityCastleLimit", {
  Default = settings.ic_room_reach,
  Numeric = true,
  Finished = true,
  Text = "🏛️ Infinity Castle",
  Placeholder = "",
  Callback = function(Value)
    settings.ic_room_reach = tonumber(Value)
    save_settings()
  end
})
FarmConfigGroupbox:AddInput("CharacterLevelLimit", {
  Default = settings.level_id_target_level,
  Numeric = true,
  Finished = true,
  Text = "🎮 Character Level",
  Placeholder = "",
  Callback = function(Value)
    settings.level_id_target_level = tonumber(Value)
    save_settings()
  end
})
FarmConfigGroupbox:AddInput("BattlePassLevelLimit", {
  Default = settings.battlepass_target_level,
  Numeric = true,
  Finished = true,
  Text = "🎮 BattlePass Level",
  Placeholder = "",
  Callback = function(Value)
    settings.battlepass_target_level = tonumber(Value)
    save_settings()
  end
})
FarmConfigGroupbox:AddDropdown("SelectStoryTarget", {
  Values = {"Planet Namak", "Shiganshinu District", "Snowy Town", "Hidden Sand Village", "Marine's Ford", "Ghoul City", "Hollow World", "Ant Kingdom", "Magic Town", "Cursed Academy", "Clover Kingdom", "Cape Canaveral", "Alien Spaceship", "Fabled Kingdom", "Hero City"},
  Default = settings.story_target_name or "",
  Multi = false,
  Text = "📚 Story",
  Callback = function(Value)
    settings.story_target_name = Value
    save_settings()
  end
})
FarmConfigGroupbox:AddToggle("PortalLimit", {
  Text = "🧿 Portal Limit",
  Default = settings.portal_farm_limit,
  Callback = function(Value)
    settings.portal_farm_limit = Value
    save_settings()
  end
})
FarmConfigGroupbox:AddInput("PortalLimitAmount", {
  Default = settings.portal_amount_to_farm,
  Numeric = true,
  Finished = true,
  Text = "⚙️ Amount",
  Placeholder = "",
  Callback = function(Value)
    settings.portal_amount_to_farm = tonumber(Value)
    save_settings()
  end
})

local ItemLimitConfigGroupbox = Tabs.Main:AddRightGroupbox("     【 Item Limit Config 】")
ItemLimitConfigGroupbox:AddDropdown("ItemLimitCategory", {
  Values = { "Grief Seed", "Wisteria Bloom", "Alien Scouter", "Tomoe", "Relic Shard", "Rikugan Eye",},
  Default = settings.item_limit_selected or "",
  Multi = false,
  Text = "🎁 Select Item",
  Callback = function(Value)
    settings.item_limit_selected = Value
    save_settings()
  end
})
ItemLimitConfigGroupbox:AddInput("ItemLimitAmount", {
  Default = settings.item_limit_amount_to_farm,
  Numeric = true,
  Finished = true,
  Text = "⚙️ Limit Amount",
  Placeholder = "",
  Callback = function(Value)
    settings.item_limit_amount_to_farm = tonumber(Value)
    save_settings()
  end
})
ItemLimitConfigGroupbox:AddToggle("ItemLimit", {
  Text = "🔒 Enable Limit",
  Default = settings.enable_item_limit,
  Callback = function(Value)
    settings.enable_item_limit = Value
    save_settings()
  end
})
--#endregion

--#region [Menu] Party
local PartyMenuGroupbox = Tabs.Party:AddLeftGroupbox("            【 Menu 】")
PartyMenuGroupbox:AddDropdown("SelectRole", {
  Values = {"Host", "Member", "AFK"},
  Default = settings.user_role or "",
  Multi = false,
  Text = "🕹️ Select Role",
  Callback = function(Value)
    settings.user_role = Value
    save_settings()
  end
})
PartyMenuGroupbox:AddToggle("PartyMode", {
  Text = "👑 Party Mode",
  Default = settings.party_mode,
  Callback = function(Value)
    settings.party_mode = Value
    save_settings()
    read_global_settings()
  end
})
PartyMenuGroupbox:AddButton({
  Text = '💾 Set Party Server',
  Func = function()
    global_settings.party_id = game.JobId
    save_global_settings()
    Library:Notify("The party server has been set", 5)
  end
})

local HostConfigGroupbox = Tabs.Party:AddRightGroupbox("        【 Host Config 】")
HostConfigGroupbox:AddSlider('AutoStartDelay', {
  Text = '⌛️ Auto Start Delay',
  Default = settings.waiting_time,
  Min = 0,
  Max = 60,
  Rounding = 1,
  Compact = false,
  Callback = function(Value)
    settings.waiting_time = Value
    save_settings()
  end
})

local MemberConfigGroupbox = Tabs.Party:AddRightGroupbox("       【 Member Config 】")
MemberConfigGroupbox:AddInput('HostName', {
  Default = settings.host_name or "",
  Numeric = false, -- true / false, only allows numbers
  Finished = true, -- true / false, only calls callback when you press enter
  Text = '🚹 Host Name',
  Callback = function(Value)
    settings.host_name = Value
    save_settings()
  end
})
MemberConfigGroupbox:AddDropdown("Players", {
  SpecialType = "Player",
  Text = "🕹️ Select Host Name",
  Callback = function(Value)
    settings.host_name = Value
    save_settings()
    Options.HostName:SetValue(settings.host_name)
  end
})
--#endregion

--#region [Menu] Webhook
function check_channel()
  local status, result = pcall(function()
    return game:HttpGet(("%s/check-channel?name=%s"):format(API_DISCORD, LocalPlayer.Name))
  end)
  if status then
    if result == 'true' and settings.personal_webhook_url ~= nil then
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Found",
        Text = 'Channel ' .. LocalPlayer.Name .. ' has been created',
        Icon = "rbxassetid://6023426926"
      })
    else
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Not Found",
        Text = 'Channel ' .. LocalPlayer.Name .. ' not found',
        Icon = "rbxassetid://6035047409"
      })
    end
  else
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Error",
      Text = result,
      Icon = "rbxassetid://6031071050"
    })
  end
end

function create_channel()
  Library:Notify("Create Channel", 2)
  local status, result = pcall(function()
    return game:HttpGet(("%s/create-channel?name=%s&userId=%s"):format(API_DISCORD, LocalPlayer.Name, settings.discord_user_id))
  end)
  if status then
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Success",
      Text = result,
      Icon = "rbxassetid://6023426926"
    })
    settings.personal_webhook_url = result
    save_settings()
  else
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Error",
      Text = result,
      Icon = "rbxassetid://6031071050"
    })
  end
end

function delete_channel()
  local status, result = pcall(function()
    return game:HttpGet(("%s/delete-channel?name=%s"):format(API_DISCORD, LocalPlayer.Name))
  end)
  if status then
    if result == 'true' then
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Success",
        Text = 'Channel ' .. LocalPlayer.Name .. ' has been deleted',
        Icon = "rbxassetid://6023426926"
      })
    else
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Fail",
        Text = 'Channel ' .. LocalPlayer.Name .. ' not found',
        Icon = "rbxassetid://6035047409"
      })
    end
  else
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Error",
      Text = result,
      Icon = "rbxassetid://6031071050"
    })
  end
end

local WebhookMenuGroupbox = Tabs.Webhook:AddLeftGroupbox("            【 Menu 】")
WebhookMenuGroupbox:AddInput('USERID', {
  Default = settings.discord_user_id or "",
  Numeric = true,
  Finished = true,
  Text = '👤 Discord User ID',
  Callback = function(Value)
    settings.discord_user_id = Value
    save_settings()
  end
})
WebhookMenuGroupbox:AddButton({
  Text = '🔎 Check Channel',
  Func = function()
    check_channel()
  end
})
WebhookMenuGroupbox:AddButton({
  Text = '📥 Create Channel',
  Func = function()
    create_channel()
  end
})
WebhookMenuGroupbox:AddButton({
  Text = '🔔 Test Webhook',
  Func = function()
    update_inventory_items()
    webhook_test()
  end
})
WebhookMenuGroupbox:AddButton({
  Text = '🔔 Test Webhook (Finish)',
  Func = function()
    update_inventory_items()
    webhook_finish()
  end
})
--#endregion

--#region [Menu] Misc
local MiscGroupbox = Tabs.Misc:AddLeftGroupbox("            【 Menu 】")
MiscGroupbox:AddLabel('🖥️ White Screen'):AddKeyPicker('WhiteScreen', {
  Default = 'F1',
  SyncToggleState = false,
  Mode = 'Toggle',
  Text = '',
  NoUI = true,
  Callback = function()
    toggleCustomScreen()
  end
})
MiscGroupbox:AddLabel('🖥️ FPS Limit'):AddKeyPicker('FPSLimit', {
  Default = 'F3',
  SyncToggleState = false,
  Mode = 'Toggle',
  Text = '',
  NoUI = true,
  Callback = function(Value)
    settings.fps_limit = not settings.fps_limit
    save_settings()
    if settings.fps_limit then
      setfpscap(5)
      Library:Notify('FPS Limit [ON]', 3)
    else
      setfpscap(30)
      Library:Notify('FPS Limit [OFF]', 3)
    end
    -- low_cpu()
  end
})
MiscGroupbox:AddLabel('🔄 Restart Game'):AddKeyPicker('RestartGame', {
  Default = 'F5',
  SyncToggleState = false,
  Mode = 'Toggle',
  Text = '',
  NoUI = true,
  Callback = function(Value)
    if settings.party_mode then
      TeleportService:TeleportToPlaceInstance(ANIME_ADVENTURES_ID, global_settings.party_id, LocalPlayer)
    else
      math.randomseed(os.time())
      local servers = {}
      pcall(function()
        local response = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/8304191830/servers/Public?sortOrder=Asc&limit=100'))
        for i, v in pairs(response.data) do
          if v.playing ~= nil and v.playing < 5 then
            table.insert(servers, v.id)
          end
        end
      end)
      if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(ANIME_ADVENTURES_ID, servers[math.random(1, #servers)], LocalPlayer)
      else
        TeleportService:Teleport(ANIME_ADVENTURES_ID, LocalPlayer)
      end
    end
  end
})
MiscGroupbox:AddLabel('💵 Auto Buy Units'):AddKeyPicker('AutoBuyUnits', {
  Default = 'F6',
  SyncToggleState = false,
  Mode = 'Toggle',
  Text = '',
  NoUI = true,
  Callback = function(Value)
    settings.auto_buy_special_unit = not settings.auto_buy_special_unit
    Library:Notify("Auto Buy Units [" .. tostring(settings.auto_buy_special_unit and "ON" or "OFF") .. "]" , 3)
    save_settings()
  end
})
MiscGroupbox:AddLabel('💴 Auto Sell Units'):AddKeyPicker('AutoSellUnits', {
  Default = 'F7',
  SyncToggleState = false,
  Mode = 'Toggle',
  Text = '',
  NoUI = true,
  Callback = function(Value)
    settings.auto_sell_rarity_units = not settings.auto_sell_rarity_units
    Library:Notify("Auto Sell Units [" .. tostring(settings.auto_sell_rarity_units and "ON" or "OFF") .. "]" , 3)
    save_settings()
  end
})
MiscGroupbox:AddToggle("AutoCliamQuests", {
  Text = "✅ Auto Cliam Quests",
  Default = settings.auto_claim_quests,
  Callback = function(Value)
    settings.auto_claim_quests = Value
    save_settings()
  end
})
MiscGroupbox:AddToggle("AutoRemoveMap", {
  Text = "✂️ Auto Remove Map",
  Default = settings.auto_remove_map,
  Callback = function(Value)
    settings.auto_remove_map = Value
    save_settings()
  end
})
MiscGroupbox:AddToggle("HideEnemyUnitNames", {
  Text = "👁️ Hide Enemy Unit Names",
  Default = settings.auto_remove_units_name,
  Callback = function(Value)
    settings.auto_remove_units_name = Value
    save_settings()
  end
})
MiscGroupbox:AddButton({
  Text = '🎀 Redeem Codes',
  Func = function()
    local codes = {"AINCRAD", "MADOKA", "DRESSROSA", "BILLION", "ENTERTAINMENT", "HAPPYEASTER", "VIGILANTE", "GOLDENSHUTDOWN", "GOLDEN", "SINS2", "SINS", "UCHIHA", "CLOUD", "HERO", "CHAINSAW", "NEWYEAR2023", "kingluffy", "toadboigaming", "noclypso", "fictionthefirst", "subtomaokuma", "subtokelvingts", "subtoblamspot"}
    for _, code in pairs(codes) do
      local args = {
        [1] = code
      }
      game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_code:InvokeServer(unpack(args))
    end
  end
})
MiscGroupbox:AddButton({
  Text = '🖥️ Low Graphics',
  Func = function()
    auto_low_graphic_settings()
  end
})

local AutoLagGroupbox = Tabs.Misc:AddLeftGroupbox("          【 Auto Lag 】")
AutoLagGroupbox:AddLabel('🖥️ Auto Lag'):AddKeyPicker('AutoLag', {
  Default = 'F2',
  SyncToggleState = false,
  Mode = 'Toggle',
  Text = '',
  NoUI = true,
  Callback = function(Value)
    settings.auto_lag = not settings.auto_lag
    save_settings()
    if settings.auto_lag then
      Library:Notify('Auto Lag [ON]', 3)
    else
      Library:Notify('Auto Lag [OFF]', 3)
    end
  end
})
AutoLagGroupbox:AddSlider('LagDelay', {
  Text = 'Delay',
  Default = settings.lag_delay or 0.4,
  Min = 0.1,
  Max = 1,
  Rounding = 1,
  Compact = true,
  Callback = function(Value)
    settings.lag_delay = tonumber(Value)
    save_settings()
  end
})
AutoLagGroupbox:AddInput('AutoLagStart', {
  Default = settings.lag_start_on_wave,
  Numeric = true, -- true / false, only allows numbers
  Finished = true, -- true / false, only calls callback when you press enter
  Text = '⚙️ Start On Wave',
  Callback = function(Value)
    settings.lag_start_on_wave = tonumber(Value)
    save_settings()
  end
})
AutoLagGroupbox:AddInput('AutoLagStop', {
  Default = settings.lag_stop_on_wave,
  Numeric = true, -- true / false, only allows numbers
  Finished = true, -- true / false, only calls callback when you press enter
  Text = '⚙️ Stop On Wave',
  Callback = function(Value)
    settings.lag_stop_on_wave = tonumber(Value)
    save_settings()
  end
})
AutoLagGroupbox:AddToggle("AutoLagHandle", {
  Text = "⚙️ Auto [Start/Stop]",
  Default = settings.handle_auto_lag,
  Callback = function(Value)
    settings.handle_auto_lag = Value
    save_settings()
    if not settings.handle_auto_lag then
      _G.disable_auto_lag = false
    end
  end
})

local ServerGroupbox = Tabs.Misc:AddRightGroupbox("           【 Server 】")
ServerGroupbox:AddInput('Teleport', {
  Default = "",
  Numeric = false, -- true / false, only allows numbers
  Finished = true, -- true / false, only calls callback when you press enter
  Text = '🌎 Teleport (Enter)',
  Callback = function(Value)
    TeleportService:TeleportToPlaceInstance(ANIME_ADVENTURES_ID, Value, LocalPlayer)
  end
})
ServerGroupbox:AddButton({
  Text = '📋 Copy JobId',
  Func = function()
    setclipboard(game.JobId)
  end
})

local SettingsGroupbox = Tabs.Misc:AddRightGroupbox("           【 Settings 】")
SettingsGroupbox:AddButton({
  Text = '🔄 Reset Settings',
  Func = function()
    local Response = Request({
      Method = 'DELETE',
      Url = API_SERVER .. '/account',
      Headers = { ["content-type"] = "application/json" },
      Body = HttpService:JSONEncode({
        ["name"] = LocalPlayer.Name
      })
    })
    if not Response.Success then
      StarterGui:SetCore("SendNotification",{
        Title = "Error",
        Text = "failed to delete account",
        Icon = "rbxassetid://6031071050"
      })
      return
    end
  
    StarterGui:SetCore("SendNotification",{
      Title = "Delete",
      Text = "successfully deleted data for account '" .. LocalPlayer.Name .. "'",
      Icon = "rbxassetid://6023426926"
    })
  end
})
-- local ItemsGroupbox = Tabs.Misc:AddRightGroupbox("           【 Items 】")
-- test_items = {}
-- for i, v in pairs(Table_All_Items_Old_data) do
--   if v["Count"] > 0 then
--     table.insert(test_items, v["Name"] .. ": x" .. v["Count"])
--   end
-- end
-- table.sort(test_items)
-- ItemsGroupbox:AddDropdown("ItemsDropdown", {
--   Values = test_items,
--   Default = "",
--   Multi = false,
--   Text = "🎁 Your Items",
--   Callback = function(Value)
--     -- 
--   end
-- })

--#endregion

--#region [Menu] UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'LeftShift', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder(FOLDER_NAME)
SaveManager:SetFolder(FOLDER_NAME .. '/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
--#endregion

--------------------------------------------------
------------------- Function ---------------------
--------------------------------------------------
--#region [Function] Inventory Items
local Table_All_Items_Old_data = {}
local Table_All_Items_New_data = {}
local Count_Portal_list = 0

function get_inventory_unique_items()
  local ItemInventoryServiceClient = Services.load_client_service(script, "ItemInventoryServiceClient")
  return ItemInventoryServiceClient["session"]['inventory']['inventory_profile_data']['unique_items']
end

function get_inventory_items()
  local ItemInventoryServiceClient = Services.load_client_service(script, "ItemInventoryServiceClient")
  return ItemInventoryServiceClient["session"]["inventory"]['inventory_profile_data']['normal_items']
end

function inventory_items()
  for v2, v3 in pairs(game:GetService("ReplicatedStorage").src.Data.Items:GetDescendants()) do
    if v3:IsA("ModuleScript") then
      for v4, v5 in pairs(require(v3)) do
        Table_All_Items_Old_data[v4] = {}
        Table_All_Items_Old_data[v4]['Name'] = v5['name']
        Table_All_Items_Old_data[v4]['Count'] = 0
        Table_All_Items_New_data[v4] = {}
        Table_All_Items_New_data[v4]['Name'] = v5['name']
        Table_All_Items_New_data[v4]['Count'] = 0
      end
    end
  end

  for i, v in pairs(get_inventory_items()) do
    Table_All_Items_Old_data[i]['Count'] = v
  end

  for i, v in pairs(get_inventory_unique_items()) do
    if string.find(v['item_id'],"portal") or string.find(v['item_id'],"disc") then
      Count_Portal_list = Count_Portal_list + 1
      Table_All_Items_Old_data[v['item_id']]['Count'] = Table_All_Items_Old_data[v['item_id']]['Count'] + 1
    end
  end
end
--#endregion

--#region [Function] Auto Select Units
function handle_select_units()
  _G.profile_data = { equipped_units = {} }
  repeat
    do
      for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "xp") then
          table.insert(_G.profile_data.equipped_units, v)
        end
      end
    end
  until #_G.profile_data.equipped_units > 0

  settings.selected_units = {}
  local units_data = require(game:GetService("ReplicatedStorage").src.Data.Units)
  for i, v in pairs(_G.profile_data.equipped_units) do
    if units_data[v.unit_id] and v.equipped_slot then
      local selected_unit_data = tostring(units_data[v.unit_id].id) .. " #" .. tostring(v.uuid)
      settings.selected_units[tonumber(v.equipped_slot)] = selected_unit_data
    end
  end
  save_settings()
end

function auto_select_units()
  handle_select_units()
  local collection = LocalPlayer.PlayerGui:WaitForChild("collection")
  collection:GetPropertyChangedSignal("Enabled"):Connect(function()
    if collection.Enabled == false then
      handle_select_units()
    end
  end)
end
--#endregion

--#region [Function] Set Battlepass Level
function set_battlepass_level()
  settings.battlepass_current_level = tonumber(LocalPlayer.PlayerGui.BattlePass.Main.Level.V.Text)
  settings.battlepass_xp = tostring(LocalPlayer.PlayerGui.BattlePass.Main.FurthestRoom.V.Text)
  save_settings()
end
--#endregion

--#region [Function] Auto Low Graphic Settings
function auto_low_graphic_settings()
  if game.PlaceId == ANIME_ADVENTURES_ID then
    local args = {
      [1] = "trading",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "hide_other_pets",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "low_quality_shadows",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "low_quality_textures",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "dynamic_depth_of_field",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
  else
    Workspace:WaitForChild("_UNITS")
    local args = {
      [1] = "show_all_unit_health",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "show_damage_text",
      [2] = false
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "show_overheads",
      [2] = false
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "hide_damage_modifiers",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "autoskip_waves",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "disable_auto_open_overhead",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "show_upgrade_ui_on_left",
      [2] = false
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "low_quality",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "disable_kill_fx",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "disable_other_fx",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "disable_effects",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "low_quality_shadows",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    task.wait()
    local args = {
      [1] = "low_quality_textures",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
  end
end
--#endregion

--#region [Function] Set FPS Cap
function set_fps_cap()
  if settings.fps_limit then
    setfpscap(5)
  else
    setfpscap(30)
  end
  -- RunService:Set3dRenderingEnabled(not settings.white_screen)
end
--#endregion

--#region [Function] Web Hook

function disp_time(seconds)
  local hours = string.format("%02.f", math.floor(seconds/3600))
  local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
  local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins*60))
  return mins..":"..secs
end

function get_user_img_url()
  local response = HttpService:JSONDecode(game:HttpGet('https://thumbnails.roblox.com/v1/users/avatar-bust?userIds=' .. LocalPlayer.UserId .. '&size=420x420&format=Png&isCircular=false'))
  for i, v in pairs(response.data) do
    return tostring(v.imageUrl)
  end
end

function update_inventory_items()
  local emoji_info = "<a:onlinepingblack:1101351544038899762> "
  if settings.farm_mode == "Gem" then
    emoji_info = "<a:onlinepingblue:1101318673572040724> "
  end
  if settings.farm_mode == "Story" then
    emoji_info = "<a:onlinepingyellow:1101318700180713493> "
  end
  if settings.farm_mode == "Infinity Castle" then
    emoji_info = "<a:onlinepingpurple:1101318692668706836> "
  end
  if settings.farm_mode == "Challenge" then
    emoji_info = "<a:onlinepingblue2:1101318678030602391> "
  end
  if settings.farm_mode == "Level-BP" then
    emoji_info = "<a:onlinepingpink:1101318690164703324> "
  end
  if settings.farm_mode == "Level-ID" then
    emoji_info = "<a:onlinepingorange:1101318685077033042> "
  end
  if settings.farm_mode == "Raid" then
    emoji_info = "<a:onlinepingred:1101318696493908068> "
  end
  if settings.farm_mode == "Portal" then
    emoji_info = "<a:onlinepinggreen:1101318680324882442> "
  end
  TextDropLabel = ""
  CountAmount = 1
  Table_All_Items_Received_data = {}
  for i,v in pairs(get_inventory_items()) do
    Table_All_Items_New_data[i]['Count'] = v
  end
  for i,v in pairs(get_inventory_unique_items()) do
    if string.find(v['item_id'],"portal") or string.find(v['item_id'],"disc") then
      Table_All_Items_New_data[v['item_id']]['Count'] = Table_All_Items_New_data[v['item_id']]['Count'] + 1
    end
  end
  for i,v in pairs(Table_All_Items_New_data) do
    if v['Count'] > 0 and (v['Count'] - Table_All_Items_Old_data[i]['Count']) > 0 then
      if string.find(i,"portal") or string.find(i,"disc") then
        if string.gsub(i, "%D", "") == "" then
          TextDropLabel = TextDropLabel .. emoji_info .. "<:gift:1101453170426794106> " .. tostring(v['Name']) .. ": +" .. tostring(v['Count'] - Table_All_Items_Old_data[i]['Count']) .. "\n"
          Table_All_Items_Received_data[v['Name']] = v['Count'] - Table_All_Items_Old_data[i]['Count']
        else
          TextDropLabel = TextDropLabel .. emoji_info .. "<:gift:1101453170426794106> " .. tostring(v['Name']) .. " Tier " .. tostring(string.gsub(i, "%D", "")) .. ": +" .. tostring(v['Count'] - Table_All_Items_Old_data[i]['Count']) .. "\n"
          Table_All_Items_Received_data[v['Name']] = v['Count'] - Table_All_Items_Old_data[i]['Count']
        end
        CountAmount = CountAmount + 1
      else
        TextDropLabel = TextDropLabel .. emoji_info .. "<:gift:1101453170426794106> " .. tostring(v['Name']) .. ": +" .. tostring(v['Count'] - Table_All_Items_Old_data[i]['Count']) .. "\n"
        Table_All_Items_Received_data[v['Name']] = v['Count'] - Table_All_Items_Old_data[i]['Count']
        CountAmount = CountAmount + 1
      end
    end
  end
  if TextDropLabel == "" then
    TextDropLabel = emoji_info .. "<:gift:1101453170426794106> ไม่มีไอเท็มที่ได้รับ"
  end
end

function webhook_data(args)
  local time = os.date('!*t', OSTime)
  title = "<a:sireneblack:1101351548086386728> ════〔 Rollin Shop 〕════ <a:sireneblack:1101351548086386728>"
  emoji_info = "<a:onlinepingblack:1101351544038899762> "
  color = 0x000000-- ดำ
  user_level = tostring(LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text)
  total_gems = tostring(LocalPlayer._stats.gem_amount.Value)
  total_gold = tostring(LocalPlayer._stats.gold_amount.Value)
  gem_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.GemReward.Main.Amount.Text)
  trophy_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.TrophyReward.Main.Amount.Text)
  xp_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.XPReward.Main.Amount.Text):split(" ")[1]
  level_name = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelName.Text)
  total_wave = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.WavesCompleted.Text):split(": ")[2]
  total_time = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.Timer.Text):split(": ")[2]
  result = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text)
  alien_scouter = tostring(Table_All_Items_New_data["west_city_frieza_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["west_city_frieza_item"]['Count'] or 0)
  tomoe = tostring(Table_All_Items_New_data["uchiha_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["uchiha_item"]['Count'] or 0)
  relic_shard = tostring(Table_All_Items_New_data["relic_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["relic_shard"]['Count'] or 0)
  starfruit = tostring(Table_All_Items_New_data["StarFruit"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["StarFruit"]['Count'] or 0)
  starfruit_rainbow = tostring(Table_All_Items_New_data["StarFruitEpic"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["StarFruitEpic"]['Count'] or 0)
  starfruit_green = tostring(Table_All_Items_New_data["StarFruitGreen"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["StarFruitGreen"]['Count'] or 0)
  starfruit_red = tostring(Table_All_Items_New_data["StarFruitRed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["StarFruitRed"]['Count'] or 0)
  starfruit_blue = tostring(Table_All_Items_New_data["StarFruitBlue"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["StarFruitBlue"]['Count'] or 0)
  starfruit_pink = tostring(Table_All_Items_New_data["StarFruitPink"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["StarFruitPink"]['Count'] or 0)
  alien_portal = tostring(Table_All_Items_New_data["portal_boros_g"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["portal_boros_g"]['Count'] or 0)
  zeldris_portal = tostring(Table_All_Items_New_data["portal_zeldris"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["portal_zeldris"]['Count'] or 0)
  madoka_portal = tostring(Table_All_Items_New_data["portal_item__madoka"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["portal_item__madoka"]['Count'] or 0)
  rikugan_eye = tostring(Table_All_Items_New_data["six_eyes"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["six_eyes"]['Count'] or 0)
  entertainment_district_item = tostring(Table_All_Items_New_data["entertainment_district_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["entertainment_district_item"]['Count'] or 0)
  grief_seed = tostring(Table_All_Items_New_data["grief_seed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["grief_seed"]['Count'] or 0)
  star_remnant = tostring(Table_All_Items_New_data["star_remnant"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["star_remnant"]['Count'] or 0)
  
  print("webhook 1")
  
  if gem_reward == "+99999" then gem_reward = "+0" end
  if xp_reward == "+99999" then xp_reward = "+0" end
  if trophy_reward == "+99999" then trophy_reward = "+0" end
  if result == "VICTORY" then
    result = "ชัยชนะ"
  else
    result = "พ่ายแพ้"
  end
  if settings.farm_mode == "Gem" then
    title = "<a:sirenelightblue:1101319518887882763> ════〔 Rollin Shop 〕════ <a:sirenelightblue:1101319518887882763>"
    emoji_info = "<a:onlinepingblue:1101318673572040724> "
    color = 0x58ffeb -- ฟ้า
    total_gems = tostring(LocalPlayer._stats.gem_amount.Value) .. " [" .. settings.gems_received .. "/" .. settings.gems_received + settings.gems_amount_to_farm  .. "]"
    if settings.gems_amount_to_farm == 0 then
      total_gems = tostring(LocalPlayer._stats.gem_amount.Value) .. " (+" .. settings.gems_received .. ")"
    end
  end
  if settings.farm_mode == "Story" then
    title = "<a:sireneyellow:1101319542896087182> ════〔 Rollin Shop 〕════ <a:sireneyellow:1101319542896087182>"
    emoji_info = "<a:onlinepingyellow:1101318700180713493> "
    color = 0xffd758 -- เหลือง
  end
  if settings.farm_mode == "Infinity Castle" then
    title = "<a:sirenepurple:1101319532481618001> ════〔 Rollin Shop 〕════ <a:sirenepurple:1101319532481618001>"
    emoji_info = "<a:onlinepingpurple:1101318692668706836> "
    color = 0x8d58ff -- ม่วง
  end
  if settings.farm_mode == "Challenge" then
    title = "<a:sireneblue:1101318705012555826> ════〔 Rollin Shop 〕════ <a:sireneblue:1101318705012555826>"
    emoji_info = "<a:onlinepingblue2:1101318678030602391> "
    color = 0x1010c9 -- น้ำเงิน
  end
  if settings.farm_mode == "Level-BP" then
    title = "<a:sirenepink:1101319527989518407> ════〔 Rollin Shop 〕════ <a:sirenepink:1101319527989518407>"
    emoji_info = "<a:onlinepingpink:1101318690164703324> "
    color = 0xff58ca -- ชมพู
  end
  if settings.farm_mode == "Level-ID" then
    title = "<a:sireneorange:1101319523132510268> ════〔 Rollin Shop 〕════ <a:sireneorange:1101319523132510268>"
    emoji_info = "<a:onlinepingorange:1101318685077033042> "
    color = 0xff7b23 -- ส้ม
  end
  if settings.farm_mode == "Raid" then
    title = "<a:sirenered:1101319537808396319> ════〔 Rollin Shop 〕════ <a:sirenered:1101319537808396319>"
    emoji_info = "<a:onlinepingred:1101318696493908068> "
    color = 0xff3d3d -- แดง
  end
  if settings.farm_mode == "Portal" then
    title = "<a:sirenegreen:1101319510897729637> ════〔 Rollin Shop 〕════ <a:sirenegreen:1101319510897729637>"
    emoji_info = "<a:onlinepinggreen:1101318680324882442> "
    color = 0x43ff52 -- เขียว
  end
  if settings.auto_force_leave or settings.farm_mode == "Gem" or settings.farm_mode == "Level-BP" then
    level_name = settings.world .. ": " .. tostring(Workspace._MAP_CONFIG.GetLevelData:InvokeServer()["name"])
    gem_reward = tostring(LocalPlayer.PlayerGui.Waves.HealthBar.IngameRewards.GemRewardTotal.Holder.Main.Amount.Text)
    total_wave = tostring(Workspace["_wave_num"].Value)
    total_time = disp_time(os.difftime(_G.end_time, _G.start_time))
    result = "ไม่มี"
  end
  if settings.enable_item_limit then
    if settings.item_limit_selected == "Relic Shard" then
      relic_shard = tostring(Table_All_Items_New_data["relic_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["relic_shard"]['Count'] or 0) .. " [" .. settings.item_limit_received .. "/" .. settings.item_limit_received + settings.item_limit_amount_to_farm  .. "]"
      if settings.item_limit_amount_to_farm == 0 then
        relic_shard = tostring(Table_All_Items_New_data["relic_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["relic_shard"]['Count'] or 0) .. " (+" .. settings.item_limit_received .. ")"
      end
    end
    if settings.item_limit_selected == "Alien Scouter" then
      alien_scouter = tostring(Table_All_Items_New_data["west_city_frieza_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["west_city_frieza_item"]['Count'] or 0) .. " [" .. settings.item_limit_received .. "/" .. settings.item_limit_received + settings.item_limit_amount_to_farm  .. "]"
      if settings.item_limit_amount_to_farm == 0 then
        alien_scouter = tostring(Table_All_Items_New_data["west_city_frieza_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["west_city_frieza_item"]['Count'] or 0) .. " (+" .. settings.item_limit_received .. ")"
      end
    end
    if settings.item_limit_selected == "Tomoe" then
      tomoe = tostring(Table_All_Items_New_data["uchiha_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["uchiha_item"]['Count'] or 0) .. " [" .. settings.item_limit_received .. "/" .. settings.item_limit_received + settings.item_limit_amount_to_farm  .. "]"
      if settings.item_limit_amount_to_farm == 0 then
        tomoe = tostring(Table_All_Items_New_data["uchiha_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["uchiha_item"]['Count'] or 0) .. " (+" .. settings.item_limit_received .. ")"
      end
    end
    if settings.item_limit_selected == "Rikugan Eye" then
      rikugan_eye = tostring(Table_All_Items_New_data["six_eyes"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["six_eyes"]['Count'] or 0) .. " [" .. settings.item_limit_received .. "/" .. settings.item_limit_received + settings.item_limit_amount_to_farm  .. "]"
      if settings.item_limit_amount_to_farm == 0 then
        rikugan_eye = tostring(Table_All_Items_New_data["six_eyes"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["six_eyes"]['Count'] or 0) .. " (+" .. settings.item_limit_received .. ")"
      end
    end
    if settings.item_limit_selected == "Wisteria Bloom" then
      entertainment_district_item = tostring(Table_All_Items_New_data["entertainment_district_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["entertainment_district_item"]['Count'] or 0) .. " [" .. settings.item_limit_received .. "/" .. settings.item_limit_received + settings.item_limit_amount_to_farm  .. "]"
      if settings.item_limit_amount_to_farm == 0 then
        entertainment_district_item = tostring(Table_All_Items_New_data["entertainment_district_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["entertainment_district_item"]['Count'] or 0) .. " (+" .. settings.item_limit_received .. ")"
      end
    end
    if settings.item_limit_selected == "Grief Seed" then
      grief_seed = tostring(Table_All_Items_New_data["grief_seed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["grief_seed"]['Count'] or 0) .. " [" .. settings.item_limit_received .. "/" .. settings.item_limit_received + settings.item_limit_amount_to_farm  .. "]"
      if settings.item_limit_amount_to_farm == 0 then
        grief_seed = tostring(Table_All_Items_New_data["grief_seed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["grief_seed"]['Count'] or 0) .. " (+" .. settings.item_limit_received .. ")"
      end
    end
  end

  print("webhook 2")

  content = ""
  farm_finish_message = ""
  game_finish_message = {
    ["name"] ="<a:yyyy:1100545093787721790> ข้อมูลการเล่น <a:yyyy:1100545093787721790>",
    ["value"] = emoji_info .. "<:Map:1086829763802431590> แมพ " .. level_name .. "\n" .. emoji_info .. "<:Result:1086829004142673970> ผลลัพธ์: " .. result .. "\n" .. emoji_info .. "<:Wave:1086831936321892484> จำนวนรอบ: " .. total_wave .. "\n" .. emoji_info .. "<:Hourglass:1086827945261273108> เวลา: " .. tostring(total_time) .. "\n" .. emoji_info .. "<:Gems:1086812238607822959> เพชร: " .. gem_reward .. "\n" .. emoji_info .. "<:XP:1086893748656541696> ค่าประสบการณ์: " .. xp_reward .. "\n" .. TextDropLabel,
    ["inline"] = false
  }
  if args then
    content = "<@" .. tostring(settings.discord_user_id) .. ">"
    farm_finish_message = "<a:verify1:1100511439699058890> จบงานแล้ว ( เข้าเล่นเกมได้เลยครับ ) <a:verify1:1100511439699058890>"
    game_finish_message = {
      ["name"] ="",
      ["value"] = "",
      ["inline"] = false
    }
  end

  print("webhook 3")

  return {
    ["content"] = content,
    ["username"] = "Rollin Shop",
    ["avatar_url"] = "https://cdn.discordapp.com/attachments/995718625078030398/1080895039598755840/logo-art.jpg",
    ["embeds"] = {
      {
        -- ["author"] = {
        --   ["name"] = title
        -- },
        ["title"] = title,
        ["description"] = farm_finish_message,
        ["color"] = color,
        ["timestamp"] = string.format('%d-%d-%dT%02d:%02d:%02dZ', time.year, time.month, time.day, time.hour, time.min, time.sec),
        ["image"] = {
          ["url"] = get_user_img_url(),
        },
        ["fields"] = {
          {
            ["name"] ="<a:yyyy:1100545093787721790> ข้อมูลลูกค้า <a:yyyy:1100545093787721790>",
            ["value"] = emoji_info .. "<:account:1100597293113167944> ID: " .. tostring(LocalPlayer.Name) .. "\n" .. emoji_info .. "<:Gold:1100584913369059509> ทอง: " .. total_gold .. "\n" .. emoji_info .. "<:Gems:1086812238607822959> เพชร: " .. total_gems .. "\n" .. emoji_info .. "<:Level:1086831024421474324> เลเวล: " .. user_level:split(" ")[2] .. " " .. user_level:split(" ")[3] .. "\n" .. emoji_info .. "<:Battlepass:1112553595557130341> แบทเทิลพาส: " .. settings.battlepass_current_level .. " [" .. settings.battlepass_xp .. "]",
            ["inline"] = false
          },
          {
            ["name"] ="<a:yyyy:1100545093787721790> ไอเท็มทั่วไป <a:yyyy:1100545093787721790>",
            ["value"] = emoji_info .. "<:Grief_Seed:1111838652247592980>  " .. grief_seed .. "\n" .. emoji_info .. "<:Wisteria_Bloom:1099264528853770271> " .. entertainment_district_item .. "\n" .. emoji_info .. "<:Alien_Scouter:1086919543034753114> " .. alien_scouter .. "\n" .. emoji_info .. "<:Tomoe:1086919541092790362> " .. tomoe .. "\n" .. emoji_info .. "<:Relic_Shard:1087158655822090380> " .. relic_shard .. "\n" .. emoji_info .. "<:Rikugan_Eye:1096869167002550282> " .. rikugan_eye .. "\n" .. emoji_info .. "<:Star_Remnant:1112744970546323456> " .. star_remnant,
            ["inline"] = false
          },
          {
            ["name"] ="<a:yyyy:1100545093787721790> ไอเท็มประตู <a:yyyy:1100545093787721790>",
            ["value"] = emoji_info .. "<:Madoka_Portal:1111835881804943450> " .. madoka_portal .. "\n" .. emoji_info .. "<:Demon_Leaders_Portal:1087031381361700906> " .. zeldris_portal .. "\n" .. emoji_info .. "<:Alien_Portal:1094173284905533490> " .. alien_portal,
            ["inline"] = false
          },
          -- {
          --   ["name"] ="<a:yyyy:1100545093787721790> ไอเท็มกิจกรรม <a:yyyy:1100545093787721790>",
          --   ["value"] = emoji_info .. "<:easter_egg_1:1095132443884925070> " .. easter_egg_1 .. "\n" .. emoji_info .. "<:easter_egg_2:1095132446946770955> " .. easter_egg_2 .. "\n" .. emoji_info .. "<:easter_egg_3:1095132449136189510> " .. easter_egg_3 .. "\n" .. emoji_info .. "<:easter_egg_4:1095132452487442473> " .. easter_egg_4 .. "\n" .. emoji_info .. "<:easter_egg_5:1095132456643985440> " .. easter_egg_5 .. "\n" .. emoji_info .. "<:easter_egg_6:1095132460146241566> " .. easter_egg_6,
          --   ["inline"] = false
          -- },
          {
            ["name"] ="<a:yyyy:1100545093787721790> ไอเท็มชาเลนจ์ <a:yyyy:1100545093787721790>",
            ["value"] = emoji_info .. "<:StarFruit:1086923974233034812> " .. starfruit .. "\n" .. emoji_info .. "<:StarFruit_Rainbow:1086923969703190569> " .. starfruit_rainbow .. "\n" .. emoji_info .. "<:StarFruit_Green:1086923966205132830> " .. starfruit_green .. "\n" .. emoji_info .. "<:StarFruit_Red:1086923962249924620> " .. starfruit_red .. "\n" .. emoji_info .. "<:StarFruit_Blue:1086923960408604734> " .. starfruit_blue .. "\n" .. emoji_info .. "<:StarFruit_Pink:1086923957334184057> " .. starfruit_pink,
            ["inline"] = false
          },
          game_finish_message
        }
      }
    }
  }
end

function webhook()
  pcall(function()
    local url = settings.personal_webhook_url
    local data = webhook_data()
    local body = HttpService:JSONEncode(data)
    local headers = { ["content-type"] = "application/json" }
    Request({
      Method = "POST",
      Url = url,
      Headers = headers,
      Body = body
    })
  end)
end

function webhook_test()
  pcall(function()
    local url = settings.personal_webhook_url
    local data = webhook_data()
    local body = HttpService:JSONEncode(data)
    local headers = { ["content-type"] = "application/json" }
    Request({
      Method = "POST",
      Url = url,
      Headers = headers,
      Body = body
    })
    Request({
      Method = "POST",
      Url = 'https://rollinhub.ngrok.app/test',
      Headers = { ["content-type"] = "application/json" },
      Body = body
    })
  end)
end

function webhook_finish()
  pcall(function()
    local data = webhook_data(true)
    local body = HttpService:JSONEncode(data)
    local headers = { ["content-type"] = "application/json" }
    Request({
      Method = "POST",
      Url = WH_URL,
      Headers = headers,
      Body = body
    })
    Request({
      Method = "POST",
      Url = settings.personal_webhook_url,
      Headers = headers, 
      Body = body
    })
  end)
end

--#endregion

--#region [Function] Auto Start
_G.teleporting = true

function get_portals(id)
  local reg = getreg()  --> returns Roblox's registry in a table
  local portals = {}
  for i, v in next, reg do
    if type(v) == 'function' then --> Checks if the current iteration is a function
      if getfenv(v).script then --> Checks if the function's environment is in a script
        for _, v in pairs(debug.getupvalues(v)) do  --> Basically a for loop that prints everything, but in one line
          if type(v) == 'table' then
            if v["session"] then
              for _, item in pairs(v["session"]["inventory"]['inventory_profile_data']['unique_items']) do
                if item["item_id"]:match(id) then
                  table.insert(portals, item)
                end
              end
              return portals
            end
          end
        end
      end
    end
  end
end

function start_portal()
  if game.PlaceId == ANIME_ADVENTURES_ID then
    if settings.portal_farm_limit and settings.portal_amount_to_farm == 0 then
      Library:Notify("The amount of portals to farm is 0", 5)
      task.wait(5)
      return
    end
    -- Game Start Notification
    Library:Notify("The game will start in 5..", 2)
    task.wait(1)
    Library:Notify("The game will start in 4..", 2)
    task.wait(1)
    Library:Notify("The game will start in 3..", 2)
    task.wait(1)
    Library:Notify("The game will start in 2..", 2)
    task.wait(1)
    Library:Notify("The game will start in 1..", 2)
    task.wait(1)
    if not settings.auto_farm then
      Library:Notify("Starting the game has been canceled", 5)
      return
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(256.604, 322.388, -528.098)
    task.wait(1)
    local args = {
      [1] = get_portals(settings.level)[1]["uuid"],
      [2] = { ["friends_only"] = false }
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.use_portal:InvokeServer(unpack(args))
    for i, v in pairs(Workspace["_PORTALS"].Lobbies:GetDescendants()) do
      if v.Name == "Owner" and tostring(v.value) == LocalPlayer.Name then
        if settings.party_mode and settings.user_role == "Host" then
          repeat task.wait() until v.Parent.Timer.Value <= (70 - settings.waiting_time)
          if #v.Parent.Players:GetChildren() == 1 then
            local args = {
              [1] = tostring(v.Parent.Name)
            }
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
            task.wait()
            Library:Notify("There are no party members in the room", 30)
            break
          end
        end
        local args = {
          [1] = tostring(v.Parent.Name)
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
        break
      end
    end
    task.wait(60)
  end
end

function auto_select_story()
  for i, v in pairs(LocalPlayer.PlayerGui.LevelSelectGui.MapSelect.Main.Wrapper.Container:GetChildren()) do
    if v:IsA("ImageButton") and v.Name ~= "ComingSoon" then
      local levels_cleared = tonumber(v.Main.Container.LevelsCleared.V.Text:split("/")[1])
      if levels_cleared < 6 then
        settings.world = v.Main.Container.MapName.Text
        settings.difficulty = "Normal"
        if v.Name == "tokyo_ghoul" then
          settings.level = "tokyoghoul_level_" .. levels_cleared + 1
        else
          settings.level = v.Name .. "_level_" .. levels_cleared + 1
        end
        break
      end
    end
  end
end

function start_farming()
  if game.PlaceId == ANIME_ADVENTURES_ID then
    if _G.teleporting then
      -- Check Gems
      if settings.farm_mode == "Gem" and settings.gems_amount_to_farm == 0 then
        Library:Notify("The amount of gems to farm is 0", 5)
        task.wait(5)
        return
      end
      -- Check BattlePass Level
      if settings.farm_mode == "BattlePass" and ettings.battlepass_target_level == 0 then
        Library:Notify("Battlepass level to farm is 0", 5)
        task.wait(5)
        return
      end
      -- Check Level-ID
      if settings.farm_mode == "LevelID" and settings.level_id_target_level == 0 then
        Library:Notify("LevelID to farm is 0", 5)
        task.wait(5)
        return
      end
      -- Game Start Notification
      Library:Notify("The game will start in 5..", 2)
      task.wait(1)
      Library:Notify("The game will start in 4..", 2)
      task.wait(1)
      Library:Notify("The game will start in 3..", 2)
      task.wait(1)
      Library:Notify("The game will start in 2..", 2)
      task.wait(1)
      Library:Notify("The game will start in 1..", 2)
      task.wait(1)
      if not settings.auto_farm then
        Library:Notify("Starting the game has been canceled", 5)
        return
      end
      local first_position = LocalPlayer.Character.HumanoidRootPart.CFrame
      local friends_only = true
      if settings.party_mode and settings.user_role == "Host" then
        friends_only = false
      end
      _G.door = "_lobbytemplategreen1"
      if tostring(Workspace["_LOBBIES"].Story[_G.door].Owner.Value) ~= LocalPlayer.Name then
        for i, v in pairs(Workspace["_LOBBIES"].Story:GetDescendants()) do
          if v.Name == "Owner" and v.Value == nil then
            -- Check Story Mode
            if settings.farm_mode == "Story" then
              LocalPlayer.Character.HumanoidRootPart.CFrame = v.Parent.Door.CFrame * CFrame.new(0, 0, 1)
              repeat task.wait() until LocalPlayer.PlayerGui.LevelSelectGui.MapSelect.Main.Wrapper.Container:FindFirstChild("namek")
              auto_select_story()
            else
              local args = {
                [1] = tostring(v.Parent.Name)
              }
              game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
              task.wait()
            end
            local args = {
              [1] = tostring(v.Parent.Name), -- Lobby
              [2] = settings.level, -- World
              [3] = friends_only, -- Friends Only or not
              [4] = settings.difficulty
            }
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
            task.wait()
            -- Party
            if settings.party_mode and settings.user_role == "Host" then
              repeat task.wait() until v.Parent.Timer.Value <= (70 - settings.waiting_time)
              if #v.Parent.Players:GetChildren() == 1 then
                local args = {
                  [1] = tostring(v.Parent.Name)
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
                LocalPlayer.Character.HumanoidRootPart.CFrame = first_position
                Library:Notify("There are no party members in the room", 30)
                task.wait(30)
                break
              end
            end
            local args = {
              [1] = tostring(v.Parent.Name)
            }
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
            task.wait()
            _G.door = v.Parent.Name
            break
          end
        end
      end

      LocalPlayer.Character.HumanoidRootPart.CFrame = first_position
      if tostring(Workspace["_LOBBIES"].Story[_G.door].Owner.Value) == LocalPlayer.Name then
        if Workspace["_LOBBIES"].Story[_G.door].Teleporting.Value == true then
          _G.teleporting = false
          Library:Notify("Game Started: " .. settings.world .. " [" .. settings.level .. "]", 30)
          task.wait(60)
          TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
          _G.teleporting = true
          task.wait(60)
        end
      end

      task.wait(60)
    end
  end
end

function start_raid()
  if game.PlaceId == ANIME_ADVENTURES_ID then
    if _G.teleporting then
      -- Game Start Notification
      Library:Notify("The game will start in 5..", 2)
      task.wait(1)
      Library:Notify("The game will start in 4..", 2)
      task.wait(1)
      Library:Notify("The game will start in 3..", 2)
      task.wait(1)
      Library:Notify("The game will start in 2..", 2)
      task.wait(1)
      Library:Notify("The game will start in 1..", 2)
      task.wait(1)
      if not settings.auto_farm then
        Library:Notify("Starting the game has been canceled", 5)
        return
      end
      local first_position = LocalPlayer.Character.HumanoidRootPart.CFrame
      local friends_only = true
      if settings.party_mode and settings.user_role == "Host" then
        friends_only = false
      end
      _G.door = "_lobbytemplate212"
      if tostring(Workspace["_RAID"].Raid[_G.door].Owner.Value) ~= LocalPlayer.Name then
        for i, v in pairs(Workspace["_RAID"].Raid:GetDescendants()) do
          if v.Name == "Owner" and v.Value == nil then
            local args = {
              [1] = tostring(v.Parent.Name)
            }
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
            task.wait()
            local args = {
              [1] = tostring(v.Parent.Name), -- Lobby
              [2] = settings.level, -- World
              [3] = friends_only, -- Friends Only or not
              [4] = settings.difficulty
            }
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
            task.wait()
            if settings.party_mode and settings.user_role == "Host" then
              repeat task.wait() until v.Parent.Timer.Value <= (70 - settings.waiting_time)
              if #v.Parent.Players:GetChildren() == 1 then
                local args = {
                  [1] = tostring(v.Parent.Name)
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
                LocalPlayer.Character.HumanoidRootPart.CFrame = first_position
                Library:Notify("There are no party members in the room", 30)
                task.wait(30)
                break
              end
            end
            local args = {
              [1] = tostring(v.Parent.Name)
            }
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
            task.wait()
            _G.door = v.Parent.Name
            break
          end
        end
      end

      LocalPlayer.Character.HumanoidRootPart.CFrame = first_position
      if tostring(Workspace["_RAID"].Raid[_G.door].Owner.Value) == LocalPlayer.Name then
        if Workspace["_RAID"].Raid[_G.door].Teleporting.Value == true then
          _G.teleporting = false
          Library:Notify("Game Started: " .. settings.world .. " [" .. settings.level .. "]", 30)
          task.wait(60)
          TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
          _G.teleporting = true
          task.wait(60)
        end
      end
    end
  end
end

function start_infinity_castle()
  if game.PlaceId == ANIME_ADVENTURES_ID then
    -- Check Infinity Castle Floor
    if settings.farm_mode == "Infinity Castle" and settings.ic_room_reach == 0 then
      Library:Notify("Infinity Castle room reach is 0", 5)
      task.wait(5)
      return
    end
    -- Game Start Notification
    Library:Notify("The game will start in 5..", 2)
    task.wait(1)
    Library:Notify("The game will start in 4..", 2)
    task.wait(1)
    Library:Notify("The game will start in 3..", 2)
    task.wait(1)
    Library:Notify("The game will start in 2..", 2)
    task.wait(1)
    Library:Notify("The game will start in 1..", 2)
    task.wait(1)
    if not settings.auto_farm then
      Library:Notify("Starting the game has been canceled", 5)
      return
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(12423.2, 155.308, 3198.08)
    for i, v in pairs(LocalPlayer.PlayerGui.InfiniteTowerUI.LevelSelect.InfoFrame.LevelButtons:GetChildren()) do
      if v.Name == "FloorButton" then
        if v.clear.Visible == false and v.Locked.Visible == false then
          local room = tonumber(v.Main.text.Text:split(" ")[2])
          local args = {
            [1] = room,
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower:InvokeServer(unpack(args))
          Library:Notify("Game Started: Infinity Castle [Room " .. tostring(room) .. "]" , 30)
          break
        end
      end
    end
    task.wait(60)
  end
end

function start_challenge()
  if game.PlaceId == ANIME_ADVENTURES_ID then
    for i, v in pairs(Workspace["_CHALLENGES"].Challenges:GetDescendants()) do
      if v.Name == "Owner" and v.Value == nil then
        local args = {
          [1] = tostring(v.Parent.Name),
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
        _G.challenge_door = v.Parent.Name
        task.wait()
        LocalPlayer.Character.HumanoidRootPart.CFrame = v.Parent.Door.CFrame * CFrame.new(0, 0, -6)
        Library:Notify("Game Joined: Challenge", 5)
        break
      end
    end
    wait(10)
    if not settings.auto_farm then
      local args = {
        [1] = tostring(_G.challenge_door),
      }
      game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
      task.wait()
      LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(251.891205, 192.158447, -527.349609, 0.999444902, 0, 0.0333156772, 0, 1, 0, -0.0333156772, 0, 0.999444902)
      Library:Notify("Starting the game has been canceled", 5)
    end
  end
end

function auto_start()
  task.spawn(function()
    while task.wait() do
      if settings.auto_farm then
        local manual = settings.farm_mode == "Manual"
        local gems = settings.farm_mode == "Gem"
        local story = settings.farm_mode == "Story"
        local level_id = settings.farm_mode == "Level-ID"
        local level_bp = settings.farm_mode == "Level-BP"
        local portal = settings.farm_mode == "Portal"
        local raid = settings.farm_mode == "Raid"
        local infinite_castle = settings.farm_mode == "Infinity Castle"
        local challenge = settings.farm_mode == "Challenge"
        if manual or gems or story or level_id or level_bp then
          start_farming()
        elseif portal then
          start_portal()
        elseif raid then
          start_raid()
        elseif infinite_castle then
          start_infinity_castle()
        elseif challenge then
          start_challenge()
        end
      end
    end
  end)
end
--#endregion

--#region [Function] Auto Place Units
_G.disable_auto_place_units = false

function get_level_data()
  local list = {}
  for i, v in pairs(game.Workspace._MAP_CONFIG:WaitForChild("GetLevelData"):InvokeServer()) do
    list[i] = v
  end
  return list
end

function place_units(position)
  local map = get_level_data().map
  for i, v in pairs(settings.selected_units) do
    local unit_name = v:split(" #")[1]
    local unit_id = v:split(" #")[2]
    math.randomseed(os.time())
    local random_number = math.random(1, 2)
    if unit_name == "metal_knight_evolved" then
      task.spawn(function()
        local args = {
          [1] = unit_id,
          [2] = CFrame.new(position[2].x + (math.random() + math.random(-2, 2)), position[2].y, position[2].z + (math.random() + math.random(-2, 2))) * CFrame.Angles(0, -0, -0)
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
        task.wait(0.5)
      end)
    elseif
      not unit_name:match("speedwagon")
      and not unit_name:match("bulma")
      and map:match("7ds_map")
    then
      if random_number == 1 then
        -- ground unit position
        local args = {
          [1] = unit_id,
          [2] = CFrame.new(position[2].x + (math.random() + math.random(-2, 2)), position[1].y, position[2].z + (math.random() + math.random(-2, 2))) * CFrame.Angles(0, -0, -0)
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
        task.wait(0.5)
      else
        -- hill unit position
        local args = {
          [1] = unit_id,
          [2] = CFrame.new(position[2].x + (math.random() + math.random(-2, 2)), position[2].y, position[2].z + (math.random() + math.random(-2, 2))) * CFrame.Angles(0, -0, -0)
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
        task.wait(0.5)
      end
    elseif unit_name:match("nami") then
      local args = {
        [1] = unit_id,
        [2] = CFrame.new(position[1].x, position[1].y, position[1].z) * CFrame.Angles(0, -0, -0)
      }
      game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
      task.wait(0.5)
    else
      if random_number == 1 then
        -- ground unit position
        local args = {
          [1] = unit_id,
          [2] = CFrame.new(position[1].x + (math.random() + math.random(-2, 2)), position[1].y, position[1].z + (math.random() + math.random(-2, 2))) * CFrame.Angles(0, -0, -0)
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
        task.wait(0.5)
      else
        -- hill unit position
        local args = {
          [1] = unit_id,
          [2] = CFrame.new(position[2].x + (math.random() + math.random(-2, 2)), position[2].y, position[2].z + (math.random() + math.random(-2, 2))) * CFrame.Angles(0, -0, -0)
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
        task.wait(0.5)
      end
    end
  end
end

function auto_place_units()
  local map = get_level_data().map
  local pos_x, pos_z
  Workspace:WaitForChild("_UNITS")
  task.spawn(function()
    while task.wait(1.5) do
      if settings.auto_place_units and not _G.disable_auto_place_units then
        for _, v in ipairs(Workspace["_UNITS"]:GetChildren()) do
          if v:FindFirstChild("_stats") then
            if v._stats.player.Value == nil then
              pos_x = v.HumanoidRootPart.Position.X
              pos_z = v.HumanoidRootPart.Position.Z
              break
            end
          end
        end
        if map:match("namek_cartoon") then
          -- print("Planet Namak")
          place_units({
            [1] = { x = pos_x, y = 91.80, z = pos_z }, -- ground unit position
            [2] = { x = -2945.898, y = 94.418, z = -719.315 }, -- hill unit position
          })
        elseif map:match("aot") then
          -- print("Shiganshinu District")
          place_units({
            [1] = { x = pos_x, y = 33.74, z = pos_z }, -- ground unit position
            [2] = { x = -3013.500, y = 38.415, z = -690.597 }, -- hill unit position
          })
        elseif map:match("demonslayer") then
          -- print("Snowy Town")
          place_units({
            [1] = { x = pos_x, y = 34.34, z = pos_z }, -- ground unit position
            [2] = { x = -2877.026, y = 40.375, z = -122.473 }, -- hill unit position
          })
        elseif map:match("naruto") then
          -- print("Hidden Sand Village")
          place_units({
            [1] = { x = pos_x, y = 25.28, z = pos_z }, -- ground unit position
            [2] = { x = -894.389, y = 29.568, z = 321.249 }, -- hill unit position
          })
        elseif map:match("marineford") then
          -- print("Marine's Ford")
          place_units({
            [1] = { x = pos_x, y = 25.21, z = pos_z }, -- ground unit position
            [2] = { x = -2537.202, y = 28.057, z = -49.016 }, -- hill unit position
          })
        elseif map:match("tokyo_ghoul") then
          -- print("Ghoul City")
          place_units({
            [1] = { x = pos_x, y = 58.58, z = pos_z }, -- ground unit position
            [2] = { x = -2958.325, y = 62.821, z = -47.757 }, -- hill unit position
          })
        elseif map:match("hueco") then
          -- print("Hollow World")
          place_units({
            [1] = { x = pos_x, y = 132.664, z = pos_z }, -- ground unit position
            [2] = { x = -184.191, y = 136.340, z = -763.578 }, -- hill unit position
          })
        elseif map:match("hxhant") then
          -- print("Ant Kingdom")
          place_units({
            [1] = { x = pos_x, y = 23.012, z = pos_z }, -- ground unit position
            [2] = { x = -188.529, y = 27.207, z = 2952.264 }, -- hill unit position
          })
        elseif map:match("magnolia") then
          -- print("Magic Town")
          place_units({
            [1] = { x = pos_x, y = 6.744, z = pos_z }, -- ground unit position
            [2] = { x = -591.005, y = 14.584, z = -828.894 }, -- hill unit position
          })
        elseif map:match("jjk") then
          -- print("Cursed Academy")
          place_units({
            [1] = { x = pos_x, y = 122.061, z = pos_z }, -- ground unit position
            [2] = { x = 390.698, y = 124.442, z = -79.022 }, -- hill unit position
          })
        elseif map:match("hage") then
          -- print("Clover Kingdom")
          place_units({
            [1] = { x = pos_x, y = 1.233, z = pos_z }, -- ground unit position
            [2] = { x = -167.163, y = 5.032, z = -37.188 }, -- hill unit position
          })
        elseif map:match("space_center") then
          -- print("Cape Canaveral")
          place_units({
            [1] = { x = pos_x, y = 15.255, z = pos_z }, -- ground unit position
            [2] = { x = -110.315, y = 19.621, z = -528.211 }, -- hill unit position
          })
        elseif map:match("boros_ship") then
          -- print("Alien Spaceship")
          place_units({
            [1] = { x = pos_x, y = 361.211, z = pos_z }, -- ground unit position
            [2] = { x = -332.029, y = 365.262, z = 1393.841 }, -- hill unit position
          })
        elseif map:match("7ds_map") then
          -- print("Fabled Kingdom")
          place_units({
            [1] = { x = pos_x, y = 212.961, z = pos_z }, -- ground unit position
            [2] = { x = -101.678, y = 219.209, z = -205.345 }, -- hill unit position
          })
        elseif map:match("mha_city") then
          -- print("Hero City")
          place_units({
            [1] = { x = pos_x, y = -13.246, z = pos_z }, -- ground unit position
            [2] = { x = -31.493, y = -10.022, z = 21.955 }, -- hill unit position
          })
        elseif map:match("dressrosa") then
          -- print("Puppet Island")
          place_units({
            [1] = { x = pos_x, y = 2.600, z = pos_z }, -- ground unit position
            [2] = { x = -41.454, y = 5.986, z = -185.049 }, -- hill unit position
          })
        elseif map:match("sao") then
          -- print("Puppet Island")
          place_units({
            [1] = { x = pos_x, y = 37.536, z = pos_z }, -- ground unit position
            [2] = { x = 150.474, y = 41.677, z = 19.859 }, -- hill unit position
          })
  
        --///Legend Stages\\\--- 
        elseif map:match("karakura") then
          -- print("Hollow Invasion (Legend)")
          place_units({
            [1] = { x = pos_x, y = 36.044, z = pos_z }, -- ground unit position
            [2] = { x = -212.727, y = 46.035, z = 598.998 }, -- hill unit position
          })
  
        --///Raids\\\---
        elseif map:match("west_city") then
          -- print("West City")
          place_units({
            [1] = { x = pos_x, y = 19.763, z = pos_z }, -- ground unit position
            [2] = { x = -2347.344, y = 32.036, z = -89.022 }, -- hill unit position
          })
        elseif map:match("uchiha_hideout") then
          -- print("Storm Hideout")
          place_units({
            [1] = { x = pos_x, y = 536.89, z = pos_z }, -- ground unit position
            [2] = { x = 304.338, y = 539.897, z = -584.447 }, -- hill unit position
          })
        elseif map:match("entertainment_district") then
          -- print("Entertainment District")
          place_units({
            [1] = { x = pos_x, y = 495.600, z = pos_z }, -- ground unit position
            [2] = { x = -127.54, y = 505.142, z = -92.913 }, -- hill unit position
            -- [2] = { x = -110.546, y = 505.219, z = -75.522 }, -- hill unit position
          })
        end
      end
    end
  end)
end
-- #endregion

--#region [Function] Auto Upgrade
function auto_upgrade()
  task.spawn(function()
    Workspace:WaitForChild("_UNITS")
    while task.wait(2) do
      if settings.auto_upgrade_units then
        for i, v in ipairs(Workspace["_UNITS"]:GetChildren()) do
          pcall(function()
            if v:FindFirstChild("_stats") then
              local _wave = Workspace:WaitForChild("_wave_num")
              if tostring(v["_stats"].player.Value) == LocalPlayer.Name and v["_stats"].xp.Value >= 0 and _wave.Value >= 6 then
                if not v.Name:match("wendy") or not v.Name:match("emilia") then
                  game:GetService("ReplicatedStorage").endpoints.client_to_server.upgrade_unit_ingame:InvokeServer(v)
                end
              end
            end
          end)
        end
      end
    end
  end)
end
-- #endregion

--#region [Function] Auto Abilities
function auto_abilities()
  task.spawn(function()
    Workspace:WaitForChild("_UNITS")
    while task.wait(2) do
      if settings.auto_abilities then
        for i, v in ipairs(Workspace["_UNITS"]:GetChildren()) do
          pcall(function()
            if v:FindFirstChild("_stats") then
              if v._stats:FindFirstChild("player") then
                if tostring(v._stats.player.Value) == LocalPlayer.Name then
  
                  -- Execute Skill if Wendy and recast every 21 seconds
                  if v._stats.id.Value == "wendy" then
                    game:GetService("ReplicatedStorage").endpoints.client_to_server.use_active_attack:InvokeServer(v)
                    task.wait(21)
                
                  -- Execute Skill if Erwin and recast every 21 seconds
                  elseif v._stats.id.Value == "erwin" then
                    game:GetService("ReplicatedStorage").endpoints.client_to_server.use_active_attack:InvokeServer(v)
                    task.wait(21)
                      
                  -- Execute Skill if Gojo and recast every 60 seconds    
                  elseif v._stats.id.Value == "gojo_evolved" then
                    if v._stats.state.Value == "attack" then
                        game:GetService("ReplicatedStorage").endpoints.client_to_server.use_active_attack:InvokeServer(v)
                    end
                  
                  -- Execute Skill if Not Wendy, Erwin, Gojo and Puchi    
                  else
                    if v._stats.state.Value == "attack" then
                      if v._stats.active_attack.Value ~= "nil" then
                        game:GetService("ReplicatedStorage").endpoints.client_to_server.use_active_attack:InvokeServer(v)
                      end
                    end
                  end
                end
              end
            end
          end)
        end
      end
    end
  end)
end

-- #endregion

--#region [Function] Auto Sell
function auto_sell_units()
  task.spawn(function()
    while task.wait(1) do
      local _wave = Workspace:WaitForChild("_wave_num")
      if settings.auto_sell_units and settings.sell_at_wave ~= nil and settings.sell_at_wave > 0 then
        if _wave.Value >= settings.sell_at_wave then
          _G.disable_auto_place_units = true
          for i, v in ipairs(Workspace["_UNITS"]:GetChildren()) do
            v:WaitForChild("_stats")
            if tostring(v["_stats"].player.Value) == LocalPlayer.Name then
              v["_stats"]:WaitForChild("upgrade")
              game:GetService("ReplicatedStorage").endpoints.client_to_server.sell_unit_ingame:InvokeServer(v)
            end
          end
        end
      end
    end
  end)
end
-- endregion

--#region [Function] Game Finished
function check_item_limit()
  if Table_All_Items_Received_data[settings.item_limit_selected] then
    settings.item_limit_amount_to_farm = settings.item_limit_amount_to_farm - Table_All_Items_Received_data[settings.item_limit_selected]
    settings.item_limit_received = settings.item_limit_received + Table_All_Items_Received_data[settings.item_limit_selected]
    if settings.item_limit_amount_to_farm <= 0 then
      settings.item_limit_amount_to_farm = 0
      webhook_finish()
      settings.item_limit_received = 0
      settings.auto_farm = false
      settings.party_mode = false
      save_settings()
      return true
    else
      webhook()
      save_settings()
      return false
    end
  else
    webhook()
    return false
  end
end

function replay()
  for i = 1, 180, 1 do
    local args = {
      [1]="replay"
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(args))
    task.wait(1)
    timer = 180 - i
    warn("Fail Safe Timer to Teleport: " .. timer)
    if i == 180 and LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
      return_to_lobby()
    end
  end
end

function return_to_lobby()
  if settings.party_mode then
    TeleportService:TeleportToPlaceInstance(ANIME_ADVENTURES_ID, global_settings.party_id, LocalPlayer)
  else
    math.randomseed(os.time())
    local servers = {}
    pcall(function()
      local response = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/8304191830/servers/Public?sortOrder=Asc&limit=100'))
      for i, v in pairs(response.data) do
        if v.playing ~= nil and v.playing < 5 then
          table.insert(servers, v.id)
        end
      end
    end)
    if #servers > 0 then
      TeleportService:TeleportToPlaceInstance(ANIME_ADVENTURES_ID, servers[math.random(1, #servers)], LocalPlayer)
    else
      TeleportService:Teleport(ANIME_ADVENTURES_ID, LocalPlayer)
    end
  end
  for i = 1, 180, 1 do
    task.wait(1)
    timer = 180 - i
    warn("Fail Safe Timer to Teleport: " .. timer)
    if i == 180 then
      -- game:Shutdown()
      return_to_lobby()
    end
  end
end

function gem_end()
  -- local gem_reward = tonumber(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.GemReward.Main.Amount.Text)
  -- settings.gems_amount_to_farm = settings.gems_amount_to_farm - gem_reward
  -- settings.gems_received = settings.gems_received + gem_reward
  -- if settings.gems_amount_to_farm <= 0 then
  --   settings.gems_amount_to_farm = 0
  --   webhook_finish()
  --   settings.gems_received = 0
  --   settings.auto_farm = false
  --   save_settings()
  --   return_to_lobby()
  -- else
  --   webhook()
  --   save_settings()
  --   replay()
  -- end
  -- webhook()
  -- save_settings()
  -- return_to_lobby()
end

function story_end()
  if LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text == "DEFEAT" then
    webhook()
    replay()
  else
    local story_list = {
      ["Planet Namak"] = "Act 6 - The Purple Tyrant",
      ["Shiganshinu District"] = "Act 6 - The Colossal Titan",
      ["Snowy Town"] = "Act 6 - The Demon King",
      ["Hidden Sand Village"] = "Act 6 - The Scorpion of the Red Sand",
      ["Marine's Ford"] = "Act 6 - The Buddha",
      ["Ghoul City"] = "Act 6 - The Non-Killing Owl",
      ["Hollow World"] = "Act 6 - The Wolf",
      ["Ant Kingdom"] = "Act 6 - The Queen Ant",
      ["Magic Town"] = "Act 6 - The Phantom Mage",
      ["Cursed Academy"] = "Act 6 - The Soul Curse",
      ["Clover Kingdom"] = "Act 6 - The Dark Trinity (Part III)",
      ["Cape Canaveral"] = "Act 6 - The Snake",
      ["Alien Spaceship"] = "Act 6 - The Alien Mass",
      ["Fabled Kingdom"] = "Act 6 - The Possessed Prince",
      ["Hero City"] = "Act 6 - The Portal Villain",
      ["Puppet Island"] = "Act 6 - The Spade Officer",
      ["Virtual Dungeon"] = "Act 6 - The Administrator",
    }
    if LocalPlayer.PlayerGui.ResultsUI.Holder.LevelName.Text == story_list[settings.story_target_name or "Puppet Island"] then
      settings.auto_farm = false
      settings.auto_lag = false
      webhook_finish()
      save_settings()
      -- Nexus:SetAutoRelaunch(false)
      -- game:Shutdown()
    else
      webhook()
      for i = 1, 180, 1 do
        local args = {
          [1] = "next_story"
        }
        game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(args))
        task.wait(1)
        timer = 180 - i
        warn("Fail Safe Timer to Teleport: " .. timer)
        if i == 180 and LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
          return_to_lobby()
        end
      end
    end
  end
end

function level_id_end()
  local user_level = tostring(LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text):split(" ")[2]
  if tonumber(user_level) >= settings.level_id_target_level then
    settings.auto_farm = false
    settings.auto_lag = false
    webhook_finish()
    save_settings()
    task.wait(5)
    game:Shutdown()
    -- Nexus:SetAutoRelaunch(false)
    -- return_to_lobby()
  else
    webhook()
    replay()
  end
end

function portal_end()
  if settings.enable_item_limit then
    check_item_limit()
    return_to_lobby()
  else
    if settings.portal_farm_limit and LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text == "VICTORY" then
      settings.portal_amount_to_farm = settings.portal_amount_to_farm - 1
      if settings.portal_amount_to_farm <= 0 then
        settings.portal_amount_to_farm = 0
        webhook_finish()
        settings.auto_farm = false
        settings.party_mode = false
        settings.auto_lag = false
        save_settings()
        return_to_lobby()
      else
        webhook()
        save_settings()
        return_to_lobby()
      end
    else
      webhook()
      return_to_lobby()
    end
  end
end

function infinite_castle_end()
  local title = LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text
  local room = tonumber(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelName.Text:split(" ")[4])
  if title == "VICTORY" and room >= settings.ic_room_reach then
    settings.auto_farm = false
    settings.auto_lag = false
    webhook_finish()
    save_settings()
    task.wait(5)
    game:Shutdown()
    -- Nexus:SetAutoRelaunch(false)
    -- return_to_lobby()
  else
    webhook()
    for i = 1, 180, 1 do
      game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower_from_game:InvokeServer()
      task.wait(1)
      timer = 180 - i
      warn("Fail Safe Timer to Teleport: " .. timer)
      if i == 180 and LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
        return_to_lobby()
      end
    end
  end
end

function raid_end()
  local title = LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text
  if title == "VICTORY" and settings.user_role == "Host" then
    local name = settings.level:split("_level_")[1]
    local current_level = settings.level:split("_level_")[2]
    if tonumber(current_level) < 4 then
      settings.level =  name .. "_level_" .. tostring(current_level + 1)
      save_settings()
    end
  end
  if settings.enable_item_limit then
    if check_item_limit() then
      settings.auto_lag = false
      save_settings()
      task.wait(5)
      game:Shutdown()
      -- return_to_lobby()
      -- Nexus:SetAutoRelaunch(false)
    else
      if settings.auto_replay then
        replay()
      else
        return_to_lobby()
      end
    end
  else
    webhook()
    if settings.auto_replay then
      replay()
    else
      return_to_lobby()
    end
  end
end

function challenge_end()
  webhook()
  return_to_lobby()
end

function game_finished()
  task.spawn(function()
    local game_finished = Workspace["_DATA"]:WaitForChild("GameFinished")
    game_finished:GetPropertyChangedSignal("Value"):Connect(function()
      if game_finished.Value == true then
        repeat task.wait() until LocalPlayer.PlayerGui.ResultsUI.Enabled == true
        update_inventory_items()
        local gems = settings.farm_mode == "Gem"
        local story = settings.farm_mode == "Story"
        local level_id = settings.farm_mode == "Level-ID"
        local level_bp = settings.farm_mode == "Level-BP"
        local portal = settings.farm_mode == "Portal"
        local raid = settings.farm_mode == "Raid"
        local infinite_castle = settings.farm_mode == "Infinity Castle"
        local challenge = settings.farm_mode == "Challenge"
        if gems then
          -- gem_end()
          -- return_to_lobby()
        elseif story then
          story_end()
        elseif level_id then
          level_id_end()
        elseif level_bp then
          -- level_id_end()
        elseif portal then
          portal_end()
        elseif raid then
          raid_end()
        elseif infinite_castle then
          infinite_castle_end()
        elseif challenge then
          challenge_end()
        elseif settings.auto_replay then
          webhook()
          replay()
        elseif settings.auto_leave then
          webhook()
          return_to_lobby()
        elseif settings.auto_force_leave then
          webhook()
          return_to_lobby()
        end
      end
    end)
  end)
end
-- #endregion

--#region [Function] Auto Force Leave
function auto_force_leave()
  task.spawn(function()
    while task.wait(5) do
      local _wave = Workspace:WaitForChild("_wave_num")
      if settings.sell_at_wave ~= nil and settings.sell_at_wave > 0 then
        if _wave.Value >= settings.sell_at_wave then
          if settings.auto_force_leave then
            _G.end_time = os.time()
            update_inventory_items()
            if settings.enable_item_limit then
              check_item_limit()
              return_to_lobby()
            else
              webhook()
              return_to_lobby()
            end
            break
          elseif settings.farm_mode == "Gem" then
            _G.end_time = os.time()
            update_inventory_items()
            local gems_earned = tonumber(LocalPlayer.PlayerGui.Waves.HealthBar.IngameRewards.GemRewardTotal.Holder.Main.Amount.Text)
            settings.gems_amount_to_farm = settings.gems_amount_to_farm - gems_earned
            settings.gems_received = settings.gems_received + gems_earned
            if settings.gems_amount_to_farm <= 0 then
              settings.gems_amount_to_farm = 0
              webhook_finish()
              settings.gems_received = 0
              settings.auto_farm = false
              settings.auto_lag = false
              save_settings()
              task.wait(5)
              game:Shutdown()
              -- Nexus:SetAutoRelaunch(false)
            else
              webhook()
              save_settings()
              return_to_lobby()
            end
            break
          elseif settings.farm_mode == "Level-BP" then
            _G.end_time = os.time()
            update_inventory_items()
            if settings.battlepass_current_level >= settings.battlepass_target_level then
              webhook_finish()
              settings.auto_farm = false
              settings.auto_lag = false
              save_settings()
              task.wait(5)
              game:Shutdown()
              -- Nexus:SetAutoRelaunch(false)
            else
              webhook()
              save_settings()
              return_to_lobby()
            end
            break
          end
        end
      end
    end
  end)
end
-- #endregion

--#region [Function] Auto Lag & lag handle
_G.disable_auto_lag = false
function auto_lag()
  task.spawn(function()
    while task.wait(settings.lag_delay) do --// don't change it's the best
      if settings.auto_lag and _G.disable_auto_lag == false then
        game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge * math.huge)
        local function getmaxvalue(val)
          local mainvalueifonetable = 499999
          if type(val) ~= "number" then
            return nil
          end
          local calculateperfectval = (mainvalueifonetable/(val+2))
          return calculateperfectval
        end
  
        local function bomb(tableincrease, tries)
          local maintable = {}
          local spammedtable = {}
          
          table.insert(spammedtable, {})
          z = spammedtable[1]
          
          for i = 1, tableincrease do
            local tableins = {}
            table.insert(z, tableins)
            z = tableins
          end
          
          local calculatemax = getmaxvalue(tableincrease)
          local maximum
          
          if calculatemax then
            maximum = calculatemax
            else
            maximum = 999999
          end
          
          for i = 1, maximum do
            table.insert(maintable, spammedtable)
          end
          
          for i = 1, tries do
            game:GetService("RobloxReplicatedStorage").SetPlayerBlockList:FireServer(maintable)
          end
        end
        
        bomb(250, 1) --// change values if client crashes
        if LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
          _G.disable_auto_lag = true
        end
      end
    end
  end)
end

function lag_handle()
  task.spawn(function()
    while task.wait(1) do
      if settings.auto_lag and settings.handle_auto_lag then
        local _wave = Workspace:WaitForChild("_wave_num")
        local lag_on = settings.lag_start_on_wave
        local lag_off = settings.lag_stop_on_wave
        if lag_off >= lag_on then
          if _wave.Value >= lag_on and _wave.Value <= lag_off then
            _G.disable_auto_lag = false
          else
            _G.disable_auto_lag = true
          end
        end
        if LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
          _G.disable_auto_lag = true
        end
      end
    end
  end)
end
-- #endregion

--#region [Function] Auto Buy/Sell
-- pcall(function()
--   if game.PlaceId == ANIME_ADVENTURES_ID then
--     _G.UnitCache = {}
--     for _, Module in next, game:GetService("ReplicatedStorage"):WaitForChild("src"):WaitForChild("Data"):WaitForChild("Units"):GetDescendants() do
--       if Module:IsA("ModuleScript") and Module.Name ~= "UnitPresets" then
--         for UnitName, UnitStats in next, require(Module) do
--           _G.UnitCache[UnitName] = UnitStats
--         end
--       end
--     end
--   end
-- end)

-- coroutine.resume(coroutine.create(function()
--   while task.wait() do
--     if game.PlaceId == ANIME_ADVENTURES_ID then
--       if settings.auto_buy_special_unit then
--         local args = {
--           [1] = "EventClover",
--           [2] = "gems10",
--         }
--         game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_from_banner:InvokeServer(unpack(args))
--       end
--     end
--   end
-- end))

-- coroutine.resume(coroutine.create(function()
-- 	while task.wait() do
-- 		if game.PlaceId == ANIME_ADVENTURES_ID then
--       if settings.auto_sell_rarity_units then
--         for i, v in pairs(game:GetService("ReplicatedStorage")["_FX_CACHE"]:GetChildren()) do
--           if v.Name == "CollectionUnitFrame" then
--             repeat task.wait() until v:FindFirstChild("name")
--             for _, Info in next, _G.UnitCache do
--               if settings.auto_sell_rarity_units == false then
--                 break
--               end
--               if Info.name == v.name.Text and Info.rarity == "Rare" or Info.name == v.name.Text and Info.rarity == "Epic" then
--                 local args = {
--                   [1] = {
--                     [1] = tostring(v._uuid.Value),
--                   }
--                 }
--                 game:GetService("ReplicatedStorage").endpoints.client_to_server.sell_units:InvokeServer(unpack(args))
--               end
--             end
--           end
--         end
--       end
--     end
-- 	end
-- end))
--#endregion

--#region [Function] Party Mode
function party_mode()
  task.spawn(function()
    if game.PlaceId == ANIME_ADVENTURES_ID then
      task.wait(10)
      while task.wait(1) do
        if settings.party_mode then
          if game.JobId ~= global_settings.party_id then
            TeleportService:TeleportToPlaceInstance(ANIME_ADVENTURES_ID, global_settings.party_id, LocalPlayer)
          end
  
          if settings.user_role == "Member" then
            -- normal farm
            for i, v in pairs(Workspace["_LOBBIES"].Story:GetDescendants()) do
              if v.Name == "Owner" and tostring(v.Value) == settings.host_name then
                local args = {
                  [1] = tostring(v.Parent.Name)
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
                task.wait()
                break
              end
            end
            -- raid
            for i, v in pairs(Workspace["_RAID"].Raid:GetDescendants()) do
              if v.Name == "Owner" and tostring(v.Value) == settings.host_name then
                local args = {
                  [1] = tostring(v.Parent.Name)
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
                task.wait()
                break
              end
            end
            -- portal
            for i, v in pairs(Workspace["_PORTALS"].Lobbies:GetDescendants()) do
              if v.Name == "Owner" and tostring(v.value) == settings.host_name then
                local args = {
                  [1] = tostring(v.Parent.Name)
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
                task.wait()
                break
              end
            end
          end
        end
      end
    else
      task.wait(10)
      while task.wait(1) do
        if game.PlaceId ~= ANIME_ADVENTURES_ID and settings.party_mode then
          if LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
            break
          end
          local players = game:GetService("Players"):GetPlayers()
          if #players == 1 then
            return_to_lobby()
          elseif settings.user_role == "Member" then
            local host = 0
            for _, v in pairs(players) do
              if v.Name == settings.host_name then
                host = 1
                break
              end
            end
            if host == 0 then
              return_to_lobby()
            end
          end
        end
      end
    end
  end)
end
--#endregion

--#region [Function] Click To Teleport
function click_to_teleport()
  UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
      if LocalPlayer.Character then
        LocalPlayer.Character:MoveTo(LocalPlayer:GetMouse().Hit.p)
      end
    end
  end)
end
--#endregion

--#region [Function] Auto Remove Map
function auto_remove_map()
  task.spawn(function()
    while task.wait(1) do
      if settings.auto_remove_map then
  
        local maps = Workspace["_map"]:GetChildren()
        for i, v in pairs(maps) do
          v:Destroy()
        end
  
        local terrain = Workspace["_terrain"].terrain:GetChildren()
        for i, v in pairs(terrain) do
          if v:IsA("Model") then
            v:Destroy()
          end
          if v:IsA("Folder") then
            v:Destroy()
          end
        end
  
        break
      end
    end
  end)
end
--#endregion

--#region [Function] Hide Enemy Unit Names
function hide_enemy_unit_names()
  task.spawn(function()
    while task.wait() do
      if settings.auto_remove_units_name then
        for _, v in pairs(Workspace["_UNITS"]:GetChildren()) do
          if v:FindFirstChild("HumanoidRootPart") then
            if v.HumanoidRootPart:FindFirstChild("_overhead") then
              if v.HumanoidRootPart._overhead:FindFirstChild("tds") then
                if v.HumanoidRootPart._overhead.tds.NameLabel.Visible == true then
                  v.HumanoidRootPart._overhead.tds.NameLabel.Visible = false
                end
              end
            end
          end
          if v:FindFirstChild("HumanoidRootPart_Fake") then
            if v.HumanoidRootPart_Fake:FindFirstChild("_overhead") then
              if v.HumanoidRootPart_Fake._overhead:FindFirstChild("tds") then
                if v.HumanoidRootPart_Fake._overhead.tds.NameLabel.Visible == true then
                  v.HumanoidRootPart_Fake._overhead.tds.NameLabel.Visible = false
                end
              end
            end
          end
        end
      else
        break
        -- for _, v in pairs(Workspace["_UNITS"]:GetChildren()) do
        --   if v:FindFirstChild("HumanoidRootPart") then
        --     if v.HumanoidRootPart:FindFirstChild("_overhead") then
        --       if v.HumanoidRootPart._overhead:FindFirstChild("tds") then
        --         if v.HumanoidRootPart._overhead.tds.NameLabel.Visible == false then
        --           v.HumanoidRootPart._overhead.tds.NameLabel.Visible = true
        --         end
        --       end
        --     end
        --   end
        --   if v:FindFirstChild("HumanoidRootPart_Fake") then
        --     if v.HumanoidRootPart_Fake:FindFirstChild("_overhead") then
        --       if v.HumanoidRootPart_Fake._overhead:FindFirstChild("tds") then
        --         if v.HumanoidRootPart_Fake._overhead.tds.NameLabel.Visible == false then
        --           v.HumanoidRootPart_Fake._overhead.tds.NameLabel.Visible = true
        --         end
        --       end
        --     end
        --   end
        -- end
      end
    end
  end)
end
--#endregion

--#region [Function] Auto Claim Quests
function auto_claim_quests()
  if settings.auto_claim_quests then
    pcall(function()
      game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
      task.wait()
    end)

    local questStory = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.story.Scroll:GetChildren()
    for i, v in pairs(questStory) do
      if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" then
        pcall(function()
          local args = {
            [1] = tostring(v.Name)
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
          task.wait()
        end)
      end
    end

    local questEvent = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.event.Scroll:GetChildren()
    for i, v in pairs(questEvent) do
      if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" then
        pcall(function()
          local args = {
            [1] = tostring(v.Name)
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
          task.wait()
        end)
      end
    end

    local questDaily = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.daily.Scroll:GetChildren()
    for i, v in pairs(questDaily) do
      if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" then
        pcall(function()
          local args = {
            [1] = tostring(v.Name)
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
          task.wait()
        end)
      end
    end

    local questInfinity = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.infinite.Scroll:GetChildren()
    for i , v in pairs(questInfinity) do
      if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" then
        pcall(function()
          local args = {
            [1] = tostring(v.Name)
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
          task.wait()
        end)
      end
    end
  end
end
--#endregion

--#region [Function] Teleport Player to Unit
_G.player_tp = false
function teleport_player_to_unit()
  task.spawn(function()
    Workspace:WaitForChild("_wave_num")
    Workspace:WaitForChild("_UNITS")
    while task.wait() do
      if _G.player_tp then
        break
      else
        for _, v in ipairs(Workspace["_UNITS"]:GetChildren()) do
          if v:FindFirstChild("_stats") then
            if tostring(v._stats.player.Value) == LocalPlayer.Name then
              LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
              _G.player_tp = true
              break
            end
          end
        end
      end
    end
  end)
end
--#endregion

--#region [Function] Auto Buy Items
function auto_buy_items()
  if settings.auto_buy_items ~= nil then
    for i, v in pairs(settings.auto_buy_items) do
      if v == "star_remnant" then
        if Workspace["travelling_merchant"]["is_open"].Value == true then
          for _, x in pairs(Workspace["travelling_merchant"]:FindFirstChild("stand"):FindFirstChild("items"):GetChildren()) do
            if x.Name:match("star_remnant") then
              local args = {
                [1] = "star_remnant"
              }
              game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_travelling_merchant_item:InvokeServer(unpack(args))
            end
          end
        end
      end

      if v == "starfruit" then
        if Workspace["travelling_merchant"]["is_open"].Value == true then
          for _, x in pairs(Workspace["travelling_merchant"]:FindFirstChild("stand"):FindFirstChild("items"):GetChildren()) do
            if x.Name:match("StarFruit") then
              local args = {
                [1] = x.Name
              }
              game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_travelling_merchant_item:InvokeServer(unpack(args))
            end
          end
        end
      end

      if v == "grief_seed" then
        pcall(function()
          local args = {
            [1] = "grief_seed",
            [2] = "100"
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_madoka_shop_item:InvokeServer(unpack(args))
          task.wait()
          local args = {
            [1] = "grief_seed",
            [2] = "100"
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_madoka_shop_item:InvokeServer(unpack(args))
          task.wait()
          local args = {
            [1] = "grief_seed",
            [2] = "10"
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_madoka_shop_item:InvokeServer(unpack(args))
          task.wait()
          local args = {
            [1] = "grief_seed",
            [2] = "10"
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_madoka_shop_item:InvokeServer(unpack(args))
          task.wait()
          local args = {
            [1] = "grief_seed",
            [2] = "10"
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_madoka_shop_item:InvokeServer(unpack(args))
          task.wait()
          local args = {
            [1] = "grief_seed",
            [2] = "10"
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_madoka_shop_item:InvokeServer(unpack(args))
          task.wait()
          local args = {
            [1] = "grief_seed",
            [2] = "10"
          }
          game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_madoka_shop_item:InvokeServer(unpack(args))
        end)
      end
    end
  end
end
--#endregion

--#region [Function] Anti AFK
function anti_afk()
  LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    wait(2)
  end)
end
-- #endregion

--#region [Function] Place Any
function place_any()
  local placement_service = Services.load_client_service(script, "PlacementServiceClient")
  task.spawn(function()
    while task.wait() do
      placement_service.can_place = true
    end
  end)
end
--#endregion

if game.PlaceId == ANIME_ADVENTURES_ID then
  set_battlepass_level()
  auto_buy_items()
  auto_claim_quests()
  auto_select_units()
  auto_start()
else
  place_any()
  auto_place_units()
  teleport_player_to_unit()
  auto_lag()
  lag_handle()
  auto_remove_map()
  auto_upgrade()
  auto_abilities()
  auto_sell_units()
  auto_force_leave()
  game_finished()
  -- hide_enemy_unit_names()
end
inventory_items()
party_mode()
click_to_teleport()
auto_low_graphic_settings()
StarterGui:SetCore("SendNotification",{
  Title = "Finished",
  Text = "ทุกฟังก์ชันทำงานเรียบร้อย",
  Icon = "rbxassetid://6023426926"
})
wait(5)
set_fps_cap()
anti_afk()
