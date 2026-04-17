local Debug = require("scripts/main/debug")
require("scripts/main/shop")

local ScriptNodes = require("scripts/libs/script_nodes")
local scripts = ScriptNodes:new()

for _, area_id in ipairs(Net.list_areas()) do
  scripts:load(area_id)
end

local Mission = require("scripts/libs/liberations/mission")
local Ability = require("scripts/libs/liberations/ability")
local Parties = require("scripts/libs/parties")
local PartiesMenu = require("scripts/libs/parties_menu")
local PlayerData = require("scripts/main/player_data")
local randomize_mission = require("scripts/main/randomize_mission")

local MISSION_BOARD_COLOR = { r = 168, g = 128, b = 200 }
local MISSION_AREAS = {
  "acdc3",
  "oran_area_3",
}

if Debug.ENABLED then
  table.insert(MISSION_AREAS, "test_area")
end

local LOBBY_AREA = "default"
local door = Net.get_object_by_name(LOBBY_AREA, "Door")
local return_point = Net.get_object_by_name(LOBBY_AREA, "Return Point")
local active_missions = 0

--- for players to return to when reconnecting
---@type table<any, Liberation.Player>
local recovery_data = {}
---@type table<Net.ActorId, boolean>
local players_in_mission = {}

local function transfer_to_lobby(player_id, warp_out)
  Net.transfer_actor(
    player_id,
    LOBBY_AREA,
    warp_out,
    return_point.x,
    return_point.y,
    return_point.z,
    return_point.custom_properties.Direction
  )
end

---@param player_ids Net.ActorId[]
---@param save_datas LiberationServer.PlayerSaveData[]
local function transfer_players_to_new_instance(base_area, player_ids, save_datas)
  active_missions = active_missions + 1
  print("Active Missions: " .. active_missions)

  -- using the scripts instancer will load script nodes on instanced areas
  local instancer = scripts:instancer()
  local instance_id = instancer:create_instance()
  local area_id = instancer:clone_area_to_instance(instance_id, base_area) --[[@as string]]

  -- randomize before loading
  randomize_mission(base_area, area_id)

  local mission = Mission:new(area_id)

  -- scale boss hp externally
  local boss = mission.boss
  boss.max_health = boss.max_health + math.floor(boss.max_health * (#player_ids - 1) * 0.5)
  boss.health = boss.max_health
  boss:heal(0)

  -- load players
  local recovery_keys = {}

  local function delete_recovery_data()
    for _, key in ipairs(recovery_keys) do
      local player = recovery_data[key]

      if player and player:instance() == mission then
        recovery_data[key] = nil
      end
    end
  end

  for i, player_id in ipairs(player_ids) do
    local save_data = save_datas[i]

    if players_in_mission[player_id] then
      -- already in a mission
      goto continue
    end

    -- kick players out of the party list or mission menu if that's open
    Net.close_board(player_id)

    -- resolve ability from items
    local ability = Ability.LongSwrd
    local stored_ability = Ability[save_data.ability]

    if stored_ability then
      ability = stored_ability
    end

    -- lock equipment
    Net.lock_player_equipment(player_id)

    -- transfer player
    mission:transfer_player(player_id, ability)

    -- update status
    local short_name = Net.get_area_custom_property(area_id, "Short Name")

    if short_name == "" then
      warn(Net.get_area_name(area_id) .. " is missing a short name!")
    end

    PartiesMenu.set_player_status(player_id, short_name)

    recovery_keys[#recovery_keys + 1] = Net.get_player_secret(player_id)
    players_in_mission[player_id] = true

    ::continue::
  end

  local mission_events = mission:events()

  mission_events:on("dark_hole_liberated", function(event)
    -- award 5z to each player for liberating a dark hole
    for _, player in ipairs(mission.players) do
      local player_id = player.id

      PlayerData.fetch(player_id).and_then(function(data)
        data.money = data.money + 5
        Net.set_player_money(player_id, data.money)
        data:save(player_id)
      end)
    end
  end)

  mission_events:on("player_kicked", function(event)
    local player_id = event.player_id

    -- reset hp
    Net.set_player_health(player_id, Net.get_player_max_health(player_id))

    -- unlock equipment
    Net.unlock_player_equipment(player_id)

    if event.reason == "success" then
      ---@param data LiberationServer.PlayerSaveData
      PlayerData.fetch(player_id).and_then(function(data)
        -- mark as completed
        data.hidden_inventory["completed:" .. base_area] = 1

        -- reward 5z for winning
        data.money = data.money + 5

        if mission:phase() < mission:target_phase() then
          -- award an additional 5z for a victory under par
          data.money = data.money + 5
        end

        Net.set_player_money(player_id, data.money)

        data:save(player_id)
      end)
    end

    -- transfer out
    if event.reason == "abandoned" then
      Async.create_scope(function()
        Net.fade_player_camera(player_id, { r = 0, g = 0, b = 0, a = 255 }, 0.25)

        Async.await(Async.sleep(0.75))

        transfer_to_lobby(player_id, false)

        Net.fade_player_camera(player_id, { r = 0, g = 0, b = 0, a = 0 }, 0.25)
      end)
    else
      transfer_to_lobby(player_id, true)
    end

    PartiesMenu.set_player_status(player_id, "Online")

    local key = Net.get_player_secret(player_id)
    recovery_data[key] = nil
    players_in_mission[player_id] = nil

    if #mission.players == 0 then
      delete_recovery_data()
      -- delete after some delay in case a player is viewing a transition
      Async.sleep(1).and_then(function()
        mission:destroy()
      end)
    end
  end)

  mission_events:on("player_disconnect", function(event)
    if #mission.players == 0 then
      delete_recovery_data()
      mission:destroy()
    end

    local player = event.player
    local key = Net.get_player_secret(player.id)
    recovery_data[key] = player
    players_in_mission[player.id] = nil
  end)

  mission_events:on("destroyed", function()
    instancer:remove_instance(instance_id)
    delete_recovery_data()

    active_missions = active_missions - 1
    print("Active Missions: " .. active_missions)
  end)
end

local function pad_left(s, n)
  return (" "):rep(math.max(n - #s, 0)) .. s
end

local function estimate_mins_from_target(target)
  -- we're guessing each player will spend 45s per turn
  return math.ceil(target * 45 / 60)
end

local function detect_door_interaction(player_id, object_id, button)
  if button ~= 0 then return end
  if object_id ~= door.id then return end

  Async.create_scope(function()
    ---@type LiberationServer.PlayerSaveData
    local data = Async.await(PlayerData.fetch(player_id))

    ---@type Net.BoardPost[]
    local posts = {}

    local party_size = #Parties.list_online_members(player_id)

    for _, area_id in ipairs(MISSION_AREAS) do
      local solo_target = tonumber(Net.get_area_custom_property(area_id, "Target Phase"))

      ---@type number|string
      local estimated_time

      if party_size > 1 then
        -- we're guessing playing as a party will be at best 30% faster from bottlenecked design
        estimated_time = estimate_mins_from_target(solo_target * 0.7) .. "-" .. estimate_mins_from_target(solo_target)
      else
        estimated_time = estimate_mins_from_target(solo_target)
      end

      posts[#posts + 1] = {
        id = area_id,
        title = Net.get_area_name(area_id),
        author = pad_left("~" .. estimated_time .. "m", 7),
        read = data.hidden_inventory["completed:" .. area_id] == 1
      }
    end

    local emitter = Net.open_board(player_id, "Missions", MISSION_BOARD_COLOR, posts)

    for event in Async.await(emitter:async_iter("post_selection")) do
      local textbox_options = { mug = Net.get_player_mugshot(player_id) }
      local response = Async.await(
        Async.question_player(player_id, "Start mission?", textbox_options)
      )

      if response ~= 1 then
        goto continue
      end

      local area_id = event.post_id
      local members = Parties.list_online_members(player_id)

      -- load save data
      local data_promises = {}

      for _, member_id in ipairs(members) do
        data_promises[#data_promises + 1] = PlayerData.fetch(member_id)
      end

      local save_datas = Async.await_all(data_promises)

      -- transfer players
      transfer_players_to_new_instance(area_id, members, save_datas)

      ::continue::
    end
  end)
end

-- handlers
local IMMEDIATE_TOKEN = "\x04"

Net:on("tile_interaction", function(event)
  local player_id = event.player_id
  local area_id = Net.get_actor_area(event.player_id)

  if area_id ~= LOBBY_AREA or event.button ~= 0 then
    return
  end

  Async.quiz_player(player_id,
    IMMEDIATE_TOKEN .. "View Party",
    IMMEDIATE_TOKEN .. "Leave Party",
    IMMEDIATE_TOKEN .. "Close",
    { cancel_response = 2 }
  ).and_then(function(response)
    if response == 0 then
      PartiesMenu.view(player_id)
    elseif response == 1 then
      Parties.leave(player_id)
    end
  end)
end)

Net:on("object_interaction", function(event)
  local player_id = event.player_id
  local area_id = Net.get_actor_area(player_id)

  if area_id == LOBBY_AREA then
    detect_door_interaction(player_id, event.object_id, event.button)
  end
end)

Net:on("actor_interaction", function(event)
  local player_id = event.player_id
  local other_player_id = event.actor_id
  local area_id = Net.get_actor_area(player_id)

  if area_id ~= LOBBY_AREA or event.button ~= 0 then return end

  if Net.is_bot(other_player_id) then return end

  local textbox_options = { mug = Net.get_player_mugshot(player_id) }
  local other_name = Net.get_actor_name(other_player_id)

  if Parties.is_in_same_party(player_id, other_player_id) then
    Net.message_player(player_id, other_name .. " is already in our party.", textbox_options)
    return
  end

  Async.create_scope(function()
    -- checking for an invite or attempting to invite
    if Parties.has_invite_from(player_id, other_player_id) then
      -- other player has an invite for us
      local response = Async.await(
        Async.question_player(player_id, "Join " .. other_name .. "'s party?", textbox_options)
      )

      if response == 1 then
        Parties.accept(player_id, other_player_id)
        return
      end

      if Parties.has_invite_from(other_player_id, player_id) then
        -- we've already invited the other player, we'll just need to wait
        return
      end
    elseif Parties.has_invite_from(other_player_id, player_id) then
      -- can't invite
      Net.message_player(player_id, "We already asked " .. other_name .. " to join our party.", textbox_options)
      return
    end

    -- try inviting
    local response = Async.await(
      Async.question_player(player_id, "Recruit " .. other_name .. "?", textbox_options)
    )
    if response == 1 then
      -- create an invite
      Parties.invite(player_id, other_player_id)
    end
  end)
end)

Net:on("player_join", function(event)
  local key = Net.get_player_secret(event.player_id)
  local player = recovery_data[key]

  if not player then
    return
  end

  recovery_data[key] = nil

  if not player:try_reconnect(event.player_id) then
    return
  end

  local area_id = player:instance().area_id
  local short_name = Net.get_area_custom_property(area_id, "Short Name")

  if not short_name then
    warn(Net.get_area_name(area_id) .. " is missing a short name!")
  end

  PartiesMenu.set_player_status(event.player_id, short_name)
end)
