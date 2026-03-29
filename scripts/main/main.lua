local ScriptNodes = require("scripts/libs/script_nodes")
local scripts = ScriptNodes:new()

for _, area_id in ipairs(Net.list_areas()) do
  scripts:load(area_id)
end

local Mission = require("scripts/libs/liberations/mission")
local Ability = require("scripts/libs/liberations/ability")
local Parties = require("scripts/libs/parties")
local randomize_mission = require("scripts/main/randomize_mission")

local waiting_area = "default"
local door = Net.get_object_by_name(waiting_area, "Door")
local return_point = Net.get_object_by_name(waiting_area, "Return Point")

local function transfer_to_lobby(player_id, warp_out)
  Net.transfer_player(
    player_id,
    waiting_area,
    warp_out,
    return_point.x,
    return_point.y,
    return_point.z,
    return_point.custom_properties.Direction
  )
end

local function transfer_players_to_new_instance(base_area, player_ids)
  -- using the scripts instancer will load script nodes on instanced areas
  local instancer = scripts:instancer()
  local instance_id = instancer:create_instance()
  local area_id = instancer:clone_area_to_instance(instance_id, base_area) --[[@as string]]

  -- randomize before loading
  randomize_mission(area_id)

  local mission = Mission:new(area_id)

  -- load players
  for _, player_id in ipairs(player_ids) do
    -- resolve ability from items
    local ability = Ability.LongSwrd

    for _, ability_value in ipairs(Ability.ALL) do
      if Net.get_player_item_count(player_id, ability_value.name) > 0 then
        ability = ability_value
        break
      end
    end

    -- lock equipment
    Net.lock_player_equipment(player_id)

    -- transfer player
    mission:transfer_player(player_id, ability)
  end

  mission.events:on("money", function(event)
    -- todo:
  end)

  mission.events:on("player_kicked", function(event)
    local player_id = event.player_id

    -- reset hp
    Net.set_player_health(player_id, Net.get_player_max_health(player_id))

    -- unlock equipment
    Net.unlock_player_equipment(player_id)

    if event.reason == "success" then
      -- todo: money?
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
  end)
end

local function start_game_for_player(map, player_id)
  local party = Parties.list_members(player_id)

  if party == nil then
    transfer_players_to_new_instance(map, { player_id })
  else
    transfer_players_to_new_instance(map, party.members)
  end
end

local function detect_door_interaction(player_id, object_id, button)
  if button ~= 0 then return end
  if object_id ~= door.id then return end

  local textbox_options = { mug = Net.get_player_mugshot(player_id) }

  Async.question_player(player_id, "Start mission?", textbox_options).and_then(function(response)
    if response == 1 then
      start_game_for_player("acdc3", player_id)
    end
  end)
end

-- handlers
Net:on("tile_interaction", function(event)
  local player_id = event.player_id
  local area_id = Net.get_player_area(event.player_id)

  if area_id ~= waiting_area or event.button ~= 0 then
    return
  end

  Async.quiz_player(player_id, "Leave party", "Close").and_then(function(response)
    if response == 0 then
      Parties.leave(player_id)
    end
  end)
end)

Net:on("object_interaction", function(event)
  local player_id = event.player_id
  local area_id = Net.get_player_area(player_id)

  if area_id == waiting_area then
    detect_door_interaction(player_id, event.object_id, event.button)
  end
end)

Net:on("actor_interaction", function(event)
  local player_id = event.player_id
  local other_player_id = event.actor_id
  local area_id = Net.get_player_area(player_id)

  if area_id ~= waiting_area or event.button ~= 0 then return end

  if Net.is_bot(other_player_id) then return end

  local textbox_options = { mug = Net.get_player_mugshot(player_id) }
  local other_name = Net.get_player_name(other_player_id)

  if Parties.is_in_same_party(player_id, other_player_id) then
    Net.message_player(player_id, other_name .. " is already in our party.", textbox_options)
    return
  end

  -- checking for an invite
  if Parties.has_invite_from(player_id, other_player_id) then
    -- other player has an invite for us
    Async.question_player(player_id, "Join " .. other_name .. "'s party?", textbox_options).and_then(function(response)
      if response == 1 then
        Parties.accept(player_id, other_player_id)
      end
    end)

    return
  end

  -- try inviting
  if Parties.has_invite_from(other_player_id, player_id) then
    Net.message_player(player_id, "We already asked " .. other_name .. " to join our party.", textbox_options)
    return
  end

  Async.question_player(player_id, "Recruit " .. other_name .. "?", textbox_options).and_then(function(response)
    if response == 1 then
      -- create an invite
      Parties.invite(player_id, other_player_id)
    end
  end)
end)
