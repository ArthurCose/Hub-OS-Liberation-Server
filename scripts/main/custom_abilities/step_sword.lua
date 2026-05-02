local Ability = require("scripts/libs/liberations/ability")
local PanelClass = require("scripts/libs/liberations/panel_class")
local AttackSelection = require("scripts/libs/liberations/selections/attack_selection")
local Direction = require("scripts/libs/direction")

local per_tile_slide_time = 0.2 / 3

---@param instance Liberation.MissionInstance
---@param start_x number
---@param start_y number
---@param start_z number
---@param direction string
---@return number, Liberation.Enemy?, Liberation.PanelObject
local function resolve_enemy(instance, start_x, start_y, start_z, direction)
  -- resolve direction
  local x_step, y_step = Direction.vector_multi(direction)

  local x = start_x + x_step
  local y = start_y + y_step
  local z = start_z

  local enemy
  local dist = 0
  local target_panel

  for _ = 1, 3 do
    local panel = instance:get_panel_at(x, y, z)

    if panel and panel.class == PanelClass.INDESTRUCTIBLE then
      break
    end

    enemy = instance:get_enemy_at(x, y, z)

    if enemy then
      if panel then
        target_panel = panel
        dist = dist + 1
      else
        -- can't attack enemy without a dark panel
        enemy = nil
      end

      break
    end

    dist = dist + 1

    x = x + x_step
    y = y + y_step
  end

  return dist, enemy, target_panel
end

---@param player Liberation.Player
---@param direction string
---@param old_properties Net.ActorPropertyKeyframe[]
---@param new_properties Net.ActorPropertyKeyframe[]
local function animate_jump(player, direction, old_properties, new_properties)
  if not Net.is_actor(player.id) then
    return
  end

  local f = 1 / 60

  local texture_anim_pair = Net.get_actor_avatar(player.id)

  -- create bot
  local bot_id = Net.create_bot({
    area_id = Net.get_actor_area(player.id),
    x = -1000,
    warp_in = false,
    texture_path = texture_anim_pair.texture_path,
    animation_path = texture_anim_pair.animation_path
  })

  -- step forward
  Net.animate_actor_properties(player.id, {
    {
      properties = {
        { property = "Direction", value = direction, ease = "Ceil" },
        table.unpack(new_properties)
      },
      duration = 60 * f
    }
  })

  -- animate flickering by flashing between the old position and off screen for the bot
  local flicker_duration = 20 * f

  ---@type Net.ActorKeyframe[]
  local keyframes = {
    {
      properties = {
        { property = "Direction", value = direction, ease = "Ceil" }
      },
      duration = f,
    }
  }

  local old_frame = {
    properties = old_properties,
    duration = 2 * f
  }
  local disappear_frame = {
    properties = {
      { property = "X", value = -1000, ease = "Ceil" }
    },
    duration = 2 * f
  }

  for i = 1, math.ceil(flicker_duration / (old_frame.duration + disappear_frame.duration)) do
    keyframes[#keyframes + 1] = old_frame
    keyframes[#keyframes + 1] = disappear_frame
  end

  Net.animate_actor_properties(bot_id, keyframes)

  Async.sleep(2).and_then(function()
    Net.remove_bot(bot_id)
  end)
end

Ability.register({
  name = "StepSword",
  question = "Step forward to battle enemy?",
  cost = 1,
  indicate = function(player)
    local instance = player:instance()

    local start_x, start_y, start_z = player:floored_position_multi()
    local direction = player:diagonal_direction()
    local distance = resolve_enemy(instance, start_x, start_y, start_z, direction)

    local shape = {}

    for i = 1, distance do
      shape[i] = { 1 }
    end

    local slide_time = distance * per_tile_slide_time

    local x_step, y_step = Direction.vector_multi(direction)

    Net.slide_player_camera(
      player.id,
      start_x + 0.5 + x_step * distance,
      start_y + 0.5 + y_step * distance,
      start_z,
      slide_time
    )

    local attack_selection = AttackSelection:new(instance)
    attack_selection:move(start_x, start_y, start_z, direction)
    attack_selection:set_shape(shape, 0, 0)
    attack_selection:indicate()

    return function(activating)
      if not activating then
        local x, y, z = player:position_multi()

        Net.slide_player_camera(player.id, x, y, z, slide_time)
        Net.unlock_player_camera(player.id)
      end

      attack_selection:remove_indicators()
    end
  end,
  activate = function(player)
    Async.create_scope(function()
      local instance = player:instance()
      local start_x, start_y, start_z = player:floored_position_multi()
      local direction = player:diagonal_direction()
      local distance, enemy, panel = resolve_enemy(instance, start_x, start_y, start_z, direction)

      if not enemy then
        player:refund_ability()

        Async.await(player:message_with_mug("No enemies in range."))

        local slide_time = distance * per_tile_slide_time
        local x, y, z = player:position_multi()
        Net.slide_player_camera(player.id, x, y, z, slide_time)
        Net.unlock_player_camera(player.id)

        player:unlock_movement()
        return
      end

      -- resolve selection
      local x_step, y_step = Direction.vector_multi(direction)

      local selection = player:selection()
      selection:select_panel(
        panel,
        start_x + x_step * (distance - 1),
        start_y + y_step * (distance - 1),
        start_z
      )
      selection:merge_shape({ { 1 } }, 0, -1)

      -- step forward
      local new_x = start_x + 0.5 + x_step * (distance - 0.49)
      local new_y = start_y + 0.5 + y_step * (distance - 0.49)
      local new_z = enemy.z

      local player_x, player_y, player_z = player:position_multi()
      local old_properties = {
        { property = "X", value = player_x, ease = "Ceil" },
        { property = "Y", value = player_y, ease = "Ceil" },
        { property = "Z", value = player_z, ease = "Ceil" }
      }

      local new_properties = {
        { property = "X", value = new_x, ease = "Ceil" },
        { property = "Y", value = new_y, ease = "Ceil" },
        { property = "Z", value = new_z, ease = "Ceil" }
      }

      animate_jump(player, direction, old_properties, new_properties)
      Async.await(Async.sleep(1))

      -- battle
      local results = Async.await(player:initiate_panel_encounter(panel))

      -- make sure the camera is focused on the player
      local slide_time = 0.2
      Net.slide_player_camera(
        player.id,
        new_x,
        new_y,
        new_z,
        slide_time
      )

      -- step back
      animate_jump(player, direction, new_properties, old_properties)
      Async.await(Async.sleep(0.5))

      -- return camera to the original position
      Net.slide_player_camera(
        player.id,
        player_x,
        player_y,
        player_z,
        slide_time
      )
      Net.unlock_player_camera(player.id)

      Async.await(Async.sleep(0.5))

      Async.sleep(slide_time)

      if results.connection_failed then
        -- avoid ending this player's turn to allow them to retry
        player:unlock_movement()
        player:refund_ability()
      else
        player:complete_turn()
      end
    end)
  end
})
