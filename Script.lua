---@diagnostic disable: undefined-global, lowercase-global
--------------------------------------------------
------------------ Init Data ---------------------
--------------------------------------------------
if _G.inject == true then
  return
else
  _G.inject = true

--#region Get Service
repeat task.wait() until game:IsLoaded()

if game.PlaceId == 8304191830 then
  repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
  repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("collection"):FindFirstChild("grid"):FindFirstChild("List"):FindFirstChild("Outer"):FindFirstChild("UnitFrames")
  repeat task.wait() until game.ReplicatedStorage.packages:FindFirstChild("assets")
  repeat task.wait() until game.ReplicatedStorage.packages:FindFirstChild("StarterGui")
  repeat task.wait() until game.Players.LocalPlayer.PlayerGui.BattlePass.Main.Level.V.Text ~= "99"
else
  repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
end

game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(e)
  if e.Name == 'ErrorPrompt' then
    game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
  end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F5 and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Teleport",
      Text = game.Players.LocalPlayer.Name,
      Icon = "rbxassetid://6023426926"
    })
    game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
  end
end)

local ANIME_ADVENTURES_ID = 8304191830
local API_SERVER = "https://rollinhub.ngrok.app"
local WH_URL = ("https://discord.com/api/webhooks/%s/%s"):format("1105540677158322306", "P7FHXSx9Ypr7nmxxDLAyW_q7eEUp3mRUvFbxdAp57x0bKIhY5Z-vorMJ3JmX-OhUmj_4")
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
local Services = require(game:GetService("ReplicatedStorage").src.Loader)
local Request = http_request or (syn and syn.request)
--#endregion

--#region Init Data
settings = {}

-- function shallowCopy(original)
--   local copy = {}
--   for key, value in pairs(original) do
--     copy[key] = value
--   end
--   copy["auto_buy_items"] = nil
--   return copy
-- end

function shallowCopy(original)
  local copy = {}
  for key, value in pairs(original) do
    if
      key == "auto_start"
      or key == "party_mode"
      or key == "gems_amount_to_farm"
      or key == "item_amount_to_farm"
      or key == "white_screen"
      or key == "fps_limit"
      or key == "auto_lag"
      or key == "battlepass_current_level"
      or key == "gems_received"
      or key == "item_received"
      or key == "battlepass_xp"
      or key == "selected_units"
      or key == "location"
      or key == "status"
    then
      copy[key] = value
    end
  end
  return copy
end

function save_settings()
  if game.PlaceId == ANIME_ADVENTURES_ID then
    settings.location = "lobby"
  else
    settings.location = "in-game"
  end
  pcall(function()
    Request({
      Method = 'PUT',
      Url = API_SERVER .. '/account',
      Headers = { ["content-type"] = "application/json" },
      Body = HttpService:JSONEncode({
        ["name"] = LocalPlayer.Name,
        ["data"] = shallowCopy(settings)
      })
    })
  end)
end

function read_settings()
  pcall(function()
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
      Text = LocalPlayer.Name .. " loaded",
      Icon = "rbxassetid://6023426926"
    })
    settings = HttpService:JSONDecode(Response.Body)
  end)
end
--#endregion

--#region Init Gobal Data
global_settings = {}

function save_global_settings()
  pcall(function()
    Request({
      Method = 'PUT',
      Url = API_SERVER .. '/config',
      Headers = { ["content-type"] = "application/json" },
      Body = HttpService:JSONEncode({
        ["data"] = global_settings
      })
    })
  end)
end

function read_global_settings()
  if settings.party_mode then
    pcall(function()
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
    end)
  end
end
--#endregion

read_settings()
task.wait(3)
read_global_settings()
task.wait(3)

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
    -- local args = {
    --   [1] = "trading",
    --   [2] = true
    -- }
    -- game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    -- local args = {
    --   [1] = "hide_other_pets",
    --   [2] = true
    -- }
    -- game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    -- local args = {
    --   [1] = "low_quality_shadows",
    --   [2] = true
    -- }
    -- game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    -- local args = {
    --   [1] = "low_quality_textures",
    --   [2] = true
    -- }
    -- game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    -- local args = {
    --   [1] = "dynamic_depth_of_field",
    --   [2] = true
    -- }
    -- game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
  else
    -- Workspace:WaitForChild("_UNITS")
    local args = {
      [1] = "show_all_unit_health",
      [2] = false
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "show_damage_text",
      [2] = false
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "show_overheads",
      [2] = false
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "hide_damage_modifiers",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "autoskip_waves",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "disable_auto_open_overhead",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "show_upgrade_ui_on_left",
      [2] = false
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "low_quality",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "disable_kill_fx",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "disable_other_fx",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "disable_effects",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "low_quality_shadows",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
    -- task.wait()
    local args = {
      [1] = "low_quality_textures",
      [2] = true
    }
    game:GetService("ReplicatedStorage").endpoints.client_to_server.toggle_setting:InvokeServer(unpack(args))
  end
end
--#endregion

--#region [Function] FPS Limit
function fps_limit()
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
  madoka_portal_shard = tostring(Table_All_Items_New_data["madoka_portal_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["madoka_portal_shard"]['Count'] or 0)
  
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
  if settings.auto_instant_leave or settings.farm_mode == "Gem" or settings.farm_mode == "Level-BP" then
    level_name = settings.world .. ": " .. tostring(Workspace._MAP_CONFIG.GetLevelData:InvokeServer()["name"])
    gem_reward = tostring(LocalPlayer.PlayerGui.Waves.HealthBar.IngameRewards.GemRewardTotal.Holder.Main.Amount.Text)
    total_wave = tostring(Workspace["_wave_num"].Value)
    total_time = disp_time(os.difftime(_G.end_time, _G.start_time))
    result = "ไม่มี"
  end
  if settings.item_mode then
    if settings.item_selected == "Time Traveller Shard" then
      madoka_portal_shard = tostring(Table_All_Items_New_data["madoka_portal_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["madoka_portal_shard"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        madoka_portal_shard = tostring(Table_All_Items_New_data["madoka_portal_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["madoka_portal_shard"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
      end
    end
    if settings.item_selected == "Grief Seed" then
      grief_seed = tostring(Table_All_Items_New_data["grief_seed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["grief_seed"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        grief_seed = tostring(Table_All_Items_New_data["grief_seed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["grief_seed"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
      end
    end
    if settings.item_selected == "Relic Shard" then
      relic_shard = tostring(Table_All_Items_New_data["relic_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["relic_shard"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        relic_shard = tostring(Table_All_Items_New_data["relic_shard"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["relic_shard"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
      end
    end
    if settings.item_selected == "Alien Scouter" then
      alien_scouter = tostring(Table_All_Items_New_data["west_city_frieza_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["west_city_frieza_item"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        alien_scouter = tostring(Table_All_Items_New_data["west_city_frieza_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["west_city_frieza_item"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
      end
    end
    if settings.item_selected == "Tomoe" then
      tomoe = tostring(Table_All_Items_New_data["uchiha_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["uchiha_item"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        tomoe = tostring(Table_All_Items_New_data["uchiha_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["uchiha_item"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
      end
    end
    if settings.item_selected == "Rikugan Eye" then
      rikugan_eye = tostring(Table_All_Items_New_data["six_eyes"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["six_eyes"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        rikugan_eye = tostring(Table_All_Items_New_data["six_eyes"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["six_eyes"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
      end
    end
    if settings.item_selected == "Wisteria Bloom" then
      entertainment_district_item = tostring(Table_All_Items_New_data["entertainment_district_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["entertainment_district_item"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        entertainment_district_item = tostring(Table_All_Items_New_data["entertainment_district_item"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["entertainment_district_item"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
      end
    end
    if settings.item_selected == "Grief Seed" then
      grief_seed = tostring(Table_All_Items_New_data["grief_seed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["grief_seed"]['Count'] or 0) .. " [" .. settings.item_received .. "/" .. settings.item_received + settings.item_amount_to_farm  .. "]"
      if settings.item_amount_to_farm == 0 then
        grief_seed = tostring(Table_All_Items_New_data["grief_seed"]['Name']) .. ": x" .. tostring(Table_All_Items_New_data["grief_seed"]['Count'] or 0) .. " (+" .. settings.item_received .. ")"
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
    farm_finish_message = "<a:verify1:1100511439699058890> จบงานแล้ว (เปลี่ยนรหัสผ่านด้วยนะครับ) <a:verify1:1100511439699058890>"
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
            ["value"] = emoji_info .. "<:time_traveller_shard:1125280707623792700>  " .. madoka_portal_shard .. "\n" .. emoji_info .. "<:Grief_Seed:1111838652247592980>  " .. grief_seed .. "\n" .. emoji_info .. "<:Wisteria_Bloom:1099264528853770271> " .. entertainment_district_item .. "\n" .. emoji_info .. "<:Alien_Scouter:1086919543034753114> " .. alien_scouter .. "\n" .. emoji_info .. "<:Tomoe:1086919541092790362> " .. tomoe .. "\n" .. emoji_info .. "<:Relic_Shard:1087158655822090380> " .. relic_shard .. "\n" .. emoji_info .. "<:Rikugan_Eye:1096869167002550282> " .. rikugan_eye .. "\n" .. emoji_info .. "<:Star_Remnant:1112744970546323456> " .. star_remnant,
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
    -- Request({
    --   Method = "POST",
    --   Url = 'https://rollinhub.ngrok.app/test',
    --   Headers = { ["content-type"] = "application/json" },
    --   Body = body
    -- })
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
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The amount of portals to farm is 0",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(5)
      return
    end
    -- Game Start Notification
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 5..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 4..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 3..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 2..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 1..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    if not settings.auto_start then
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "Starting the game has been canceled",
        Icon = "rbxassetid://6023426926"
      })
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
        if settings.party_mode and settings.party_role == "Host" then
          repeat task.wait() until v.Parent.Timer.Value <= (70 - settings.party_start_delay)
          if #v.Parent.Players:GetChildren() == 1 then
            local args = {
              [1] = tostring(v.Parent.Name)
            }
            game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
            task.wait()
            game:GetService("StarterGui"):SetCore("SendNotification",{
              Title = "Auto Start",
              Text = "There are no party members in the room",
              Icon = "rbxassetid://6023426926"
            })
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
        game:GetService("StarterGui"):SetCore("SendNotification",{
          Title = "Auto Start",
          Text = "The amount of gems to farm is 0",
          Icon = "rbxassetid://6023426926"
        })
        task.wait(5)
        return
      end
      -- Check BattlePass Level
      if settings.farm_mode == "BattlePass" and ettings.battlepass_level_target == 0 then
        game:GetService("StarterGui"):SetCore("SendNotification",{
          Title = "Auto Start",
          Text = "Battlepass level to farm is 0",
          Icon = "rbxassetid://6023426926"
        })
        task.wait(5)
        return
      end
      -- Check Level-ID
      if settings.farm_mode == "LevelID" and settings.character_level_target == 0 then
        game:GetService("StarterGui"):SetCore("SendNotification",{
          Title = "Auto Start",
          Text = "LevelID to farm is 0",
          Icon = "rbxassetid://6023426926"
        })
        task.wait(5)
        return
      end
      -- Game Start Notification
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 5..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 4..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 3..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 2..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 1..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      if not settings.auto_start then
        game:GetService("StarterGui"):SetCore("SendNotification",{
          Title = "Auto Start",
          Text = "Starting the game has been canceled",
          Icon = "rbxassetid://6023426926"
        })
        return
      end
      local first_position = LocalPlayer.Character.HumanoidRootPart.CFrame
      local friends_only = true
      if settings.party_mode and settings.party_role == "Host" then
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
            if settings.party_mode and settings.party_role == "Host" then
              repeat task.wait() until v.Parent.Timer.Value <= (70 - settings.party_start_delay)
              if #v.Parent.Players:GetChildren() == 1 then
                local args = {
                  [1] = tostring(v.Parent.Name)
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
                LocalPlayer.Character.HumanoidRootPart.CFrame = first_position
                game:GetService("StarterGui"):SetCore("SendNotification",{
                  Title = "Auto Start",
                  Text = "There are no party members in the room",
                  Icon = "rbxassetid://6023426926"
                })
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
          game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Game Started",
            Text = settings.world .. " [" .. settings.level .. "]",
            Icon = "rbxassetid://6023426926"
          })
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
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 5..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 4..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 3..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 2..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "The game will start in 1..",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(1)
      if not settings.auto_start then
        game:GetService("StarterGui"):SetCore("SendNotification",{
          Title = "Auto Start",
          Text = "Starting the game has been canceled",
          Icon = "rbxassetid://6023426926"
        })
        return
      end
      local first_position = LocalPlayer.Character.HumanoidRootPart.CFrame
      local friends_only = true
      if settings.party_mode and settings.party_role == "Host" then
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
            if settings.party_mode and settings.party_role == "Host" then
              repeat task.wait() until v.Parent.Timer.Value <= (70 - settings.party_start_delay)
              if #v.Parent.Players:GetChildren() == 1 then
                local args = {
                  [1] = tostring(v.Parent.Name)
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
                LocalPlayer.Character.HumanoidRootPart.CFrame = first_position
                game:GetService("StarterGui"):SetCore("SendNotification",{
                  Title = "Auto Start",
                  Text = "There are no party members in the room",
                  Icon = "rbxassetid://6023426926"
                })
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
          game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Game Started",
            Text = settings.world .. " [" .. settings.level .. "]",
            Icon = "rbxassetid://6023426926"
          })
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
    if settings.farm_mode == "Infinity Castle" and settings.ic_room_target == 0 then
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "Infinity Castle room reach is 0",
        Icon = "rbxassetid://6023426926"
      })
      task.wait(5)
      return
    end
    -- Game Start Notification
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 5..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 4..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 3..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 2..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Auto Start",
      Text = "The game will start in 1..",
      Icon = "rbxassetid://6023426926"
    })
    task.wait(1)
    if not settings.auto_start then
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "Starting the game has been canceled",
        Icon = "rbxassetid://6023426926"
      })
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
          game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Game Started",
            Text = "Infinity Castle [Room " .. tostring(room) .. "]",
            Icon = "rbxassetid://6023426926"
          })
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
        game:GetService("StarterGui"):SetCore("SendNotification",{
          Title = "Auto Start",
          Text = "Challenge",
          Icon = "rbxassetid://6023426926"
        })
        break
      end
    end
    wait(10)
    if not settings.auto_start then
      local args = {
        [1] = tostring(_G.challenge_door),
      }
      game:GetService("ReplicatedStorage").endpoints.client_to_server.request_leave_lobby:InvokeServer(unpack(args))
      task.wait()
      LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(251.891205, 192.158447, -527.349609, 0.999444902, 0, 0.0333156772, 0, 1, 0, -0.0333156772, 0, 0.999444902)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Start",
        Text = "Starting the game has been canceled",
        Icon = "rbxassetid://6023426926"
      })
    end
  end
end

function auto_start()
  task.spawn(function()
    while task.wait(1) do
      if settings.auto_start then
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
_G.disable_auto_place = false

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

function auto_place()
  local map = get_level_data().map
  local pos_x, pos_z
  Workspace:WaitForChild("_UNITS")
  task.spawn(function()
    while task.wait(1.5) do
      if settings.auto_place and not _G.disable_auto_place then
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
            [2] = { x = -2982.847, y = 66.701, z = -52.975 }, -- hill unit position
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
        elseif map:match('berserk') then
          place_units({
            [1] = { x = pos_x, y =  -0.074, z = pos_z }, -- ground unit position 
            [2] = { x = -252.30, y = 3.54, z = 20.98 }, -- hill unit position
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

        --///Portals\\\---
        elseif map:match("madoka") then
          place_units({
            [1] = { x = pos_x, y = 0.999, z = pos_z }, -- ground unit position
            [2] = { x = -56.454, y = 5.263, z = -161.888 }, -- hill unit position
          })
        end
      end
    end
  end)
end
-- #endregion

--#region [Function] Auto Upgrade
function auto_upgrade()
  Workspace:WaitForChild("_UNITS")
  print("WaitForChild UNITS")
  task.spawn(function()
    while task.wait(2) do
      if settings.auto_upgrade then
        for i, v in ipairs(Workspace["_UNITS"]:GetChildren()) do
          if v:FindFirstChild("_stats") then
            local _wave = Workspace:WaitForChild("_wave_num")
            if tostring(v["_stats"].player.Value) == LocalPlayer.Name and v["_stats"].xp.Value >= 0 and _wave.Value >= 6 then
              if not v.Name:match("wendy") or not v.Name:match("emilia") then
                game:GetService("ReplicatedStorage").endpoints.client_to_server.upgrade_unit_ingame:InvokeServer(v)
                print("upgrade_unit", v.Name)
              end
            end
          end
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
function auto_sell()
  task.spawn(function()
    while task.wait(1) do
      local _wave = Workspace:WaitForChild("_wave_num")
      if settings.auto_sell and settings.sell_at_wave ~= nil and settings.sell_at_wave > 0 then
        if _wave.Value >= settings.sell_at_wave then
          _G.disable_auto_place = true
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
  if Table_All_Items_Received_data[settings.item_selected] then
    settings.item_amount_to_farm = settings.item_amount_to_farm - Table_All_Items_Received_data[settings.item_selected]
    settings.item_received = settings.item_received + Table_All_Items_Received_data[settings.item_selected]
    if settings.item_amount_to_farm <= 0 then
      settings.item_amount_to_farm = 0
      webhook_finish()
      settings.item_received = 0
      settings.auto_start = false
      settings.party_mode = false
      settings.status = "finished"
      save_settings()
      return true
    else
      webhook()
      save_settings()
      return false
    end
  else
    webhook()
    save_settings()
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
  --   settings.auto_start = false
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
      settings.auto_start = false
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
  if tonumber(user_level) >= settings.character_level_target then
    settings.auto_start = false
    settings.auto_lag = false
    settings.status = "finished"
    webhook_finish()
    save_settings()
    task.wait(5)
    -- game:Shutdown()
    -- Nexus:SetAutoRelaunch(false)
    return_to_lobby()
  else
    webhook()
    save_settings()
    replay()
  end
end

function portal_end()
  if settings.item_mode then
    check_item_limit()
    return_to_lobby()
  else
    if settings.portal_farm_limit and LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text == "VICTORY" then
      settings.portal_amount_to_farm = settings.portal_amount_to_farm - 1
      if settings.portal_amount_to_farm <= 0 then
        settings.portal_amount_to_farm = 0
        webhook_finish()
        settings.auto_start = false
        settings.party_mode = false
        settings.auto_lag = false
        settings.status = "finished"
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
  if title == "VICTORY" and room >= settings.ic_room_target then
    settings.auto_start = false
    settings.auto_lag = false
    settings.status = "finished"
    webhook_finish()
    save_settings()
    task.wait(5)
    -- game:Shutdown()
    -- Nexus:SetAutoRelaunch(false)
    return_to_lobby()
  else
    webhook()
    save_settings()
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
  if title == "VICTORY" and settings.party_role == "Host" then
    local name = settings.level:split("_level_")[1]
    local current_level = settings.level:split("_level_")[2]
    if tonumber(current_level) < 4 then
      settings.level =  name .. "_level_" .. tostring(current_level + 1)
      save_settings()
    end
  end
  if settings.item_mode then
    if check_item_limit() then
      settings.auto_lag = false
      save_settings()
      task.wait(5)
      -- game:Shutdown()
      return_to_lobby()
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
        elseif settings.auto_instant_leave then
          webhook()
          return_to_lobby()
        end
      end
    end)
  end)
end
-- #endregion

--#region [Function] Auto Force Leave
function auto_instant_leave()
  task.spawn(function()
    while task.wait(5) do
      local _wave = Workspace:WaitForChild("_wave_num")
      if settings.sell_at_wave ~= nil and settings.sell_at_wave > 0 then
        if _wave.Value >= settings.sell_at_wave then
          if settings.auto_instant_leave then
            _G.end_time = os.time()
            update_inventory_items()
            if settings.item_mode then
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
              settings.auto_start = false
              settings.auto_lag = false
              settings.status = "finished"
              save_settings()
              task.wait(5)
              -- game:Shutdown()
              return_to_lobby()
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
            if settings.battlepass_current_level >= settings.battlepass_level_target then
              webhook_finish()
              settings.auto_start = false
              settings.auto_lag = false
              settings.status = "finished"
              save_settings()
              task.wait(5)
              -- game:Shutdown()
              return_to_lobby()
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
      if settings.auto_lag and settings.auto_toggle_lag then
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
  
          if settings.party_role == "Member" then
            -- normal farm
            for i, v in pairs(Workspace["_LOBBIES"].Story:GetDescendants()) do
              if v.Name == "Owner" and tostring(v.Value) == settings.party_host_name then
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
              if v.Name == "Owner" and tostring(v.Value) == settings.party_host_name then
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
              if v.Name == "Owner" and tostring(v.value) == settings.party_host_name then
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
      while task.wait(5) do
        if game.PlaceId ~= ANIME_ADVENTURES_ID and settings.party_mode then
          if LocalPlayer.PlayerGui.ResultsUI.Enabled == true then
            break
          end
          local players = game:GetService("Players"):GetPlayers()
          if #players == 1 then
            return_to_lobby()
          elseif settings.party_role == "Member" then
            local host = 0
            for _, v in pairs(players) do
              if v.Name == settings.party_host_name then
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
      game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_christmas_calendar_reward:InvokeServer()
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
  task.spawn(function()
    local placement_service = Services.load_client_service(script, "PlacementServiceClient")
    while task.wait() do
      placement_service.can_place = true
    end
  end)
end
--#endregion

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F1 then
    toggleCustomScreen()
  end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F2 then
    settings.auto_lag = not settings.auto_lag
    save_settings()
    if settings.auto_lag then
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Lag [ON]",
        Text = game.Players.LocalPlayer.Name,
        Icon = "rbxassetid://6031280882"
      })
    else
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Auto Lag [OFF]",
        Text = game.Players.LocalPlayer.Name,
        Icon = "rbxassetid://6031280882"
      })
    end
  end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F3 then
    settings.fps_limit = not settings.fps_limit
    save_settings()
    if settings.fps_limit then
      setfpscap(5)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "FPS Limit [ON]",
        Text = game.Players.LocalPlayer.Name,
        Icon = "rbxassetid://6031280882"
      })
    else
      setfpscap(30)
      game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "FPS Limit [OFF]",
        Text = game.Players.LocalPlayer.Name,
        Icon = "rbxassetid://6031280882"
      })
    end
  end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F4 then
    global_settings.party_id = game.JobId
    save_global_settings()
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Set Party Server",
      Text = game.JobId,
      Icon = "rbxassetid://6031280882"
    })
  end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F5 then
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Teleport",
      Text = game.Players.LocalPlayer.Name,
      Icon = "rbxassetid://6031280882"
    })
    return_to_lobby()
  end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F6 then
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Reload Settings",
      Text = game.Players.LocalPlayer.Name,
      Icon = "rbxassetid://6031280882"
    })
    read_settings()
    read_global_settings()
  end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.F7 then
    game:GetService("StarterGui"):SetCore("SendNotification",{
      Title = "Test Webhook",
      Text = game.Players.LocalPlayer.Name,
      Icon = "rbxassetid://6031280882"
    })
    webhook_test()
  end
end)

if game.PlaceId == ANIME_ADVENTURES_ID then
  set_battlepass_level()
  auto_buy_items()
  auto_claim_quests()
  auto_select_units()
  auto_start()
else
  game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
  repeat task.wait() until game:GetService("Workspace")["_waves_started"].Value == true
  LocalPlayer.PlayerGui.MessageGui.Enabled = false
  game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error.Volume = 0
  game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error_old.Volume = 0
  _G.start_time = os.time()
  settings.status = "working"
  -- place_any()
  auto_remove_map()
  auto_place()
  teleport_player_to_unit()
  auto_lag()
  lag_handle()
  auto_upgrade()
  auto_abilities()
  auto_sell()
  auto_instant_leave()
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
fps_limit()
anti_afk()

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


end
