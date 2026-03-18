local RecoverEffect = require("scripts/libs/liberations/effects/recover_effect")
local Direction = require("scripts/libs/direction")

local EnemyHelpers = {
  GUARDIAN_MINIMAP_MARKER = { r = 230, g = 50, b = 40 },
  BOSS_MINIMAP_COLOR = { r = 170, g = 50, b = 170 }
}

local direction_suffix_map = {
  [Direction.DOWN_LEFT] = "DL",
  [Direction.DOWN_RIGHT] = "DR",
  [Direction.UP_LEFT] = "UL",
  [Direction.UP_RIGHT] = "UR",
}

function EnemyHelpers.play_attack_animation(enemy)
  local direction = Net.get_bot_direction(enemy.id)
  local suffix = direction_suffix_map[direction]
  local animation = "ATTACK_" .. suffix

  Net.animate_bot(enemy.id, animation)
end

function EnemyHelpers.play_idle_animation(enemy)
  local direction = Net.get_bot_direction(enemy.id)
  local suffix = direction_suffix_map[direction]
  local animation = "IDLE_" .. suffix

  Net.animate_bot(enemy.id, animation, true)
end

function EnemyHelpers.update_name(enemy)
  if enemy == nil then return end

  Net.set_bot_name(enemy.id, enemy.name .. ": " .. enemy.health .. " HP")
end

function EnemyHelpers.heal(enemy, amount)
  local previous_health = enemy.health

  enemy.health = math.min(math.ceil(enemy.health + amount), enemy.max_health)

  EnemyHelpers.update_name(enemy)

  if previous_health < enemy.health then
    return RecoverEffect:new(enemy.id)
  else
    return Async.create_function(function()
    end)
  end
end

function EnemyHelpers.face_position(enemy, x, y)
  x = x - (enemy.x + .5)
  y = y - (enemy.y + .5)

  Net.set_bot_direction(enemy.id, Direction.diagonal_from_offset(x, y))
end

function EnemyHelpers.can_move_to(instance, x, y, z)
  local panel = instance:get_panel_at(x, y, z)

  if instance:get_enemy_at(x, y, z) ~= nil then return false end --Cannot move to a tile an enemy already exists on.

  --Can only move to certain tile types and if panel exists.
  return panel and (
    panel.type == "Dark Panel" or
    panel.type == "Item Panel" or
    panel.type == "Trap Panel"
  )
end

-- takes instance to move player cameras
-- x, y, z should be floored
function EnemyHelpers.move(instance, enemy, x, y, z, direction)
  return Async.create_promise(function(resolve)
    x = math.floor(x)
    y = math.floor(y)

    local slide_time = .5
    local hold_time = .25
    local startup_time = .25
    local animation_time = .042

    Async.await(Async.sleep(hold_time))

    for _, player in ipairs(instance.players) do
      Net.slide_player_camera(player.id, x + .5, y + .5, z, slide_time)
    end

    local area_id = Net.get_bot_area(enemy.id)

    -- create blur
    local blur_bot_id = Net.create_bot({
      texture_path = "/server/assets/liberations/bots/blur.png",
      animation_path = "/server/assets/liberations/bots/blur.animation",
      area_id = area_id,
      warp_in = false,
      x = enemy.x + .5 + (1 / 32),
      y = enemy.y + .5 + (1 / 32),
      z = enemy.z + 1
    })

    -- animate blur
    Net.animate_bot(blur_bot_id, "DISAPPEAR")

    Async.await(Async.sleep(animation_time))

    -- move this bot off screen
    local area_width = Net.get_layer_width(area_id)
    Net.transfer_bot(enemy.id, area_id, false, area_width + 100, 0, 0)

    Async.await(Async.sleep(slide_time + startup_time))

    -- animate blur
    Net.transfer_bot(
      blur_bot_id,
      area_id,
      false,
      x + .5 + (1 / 32),
      y + .5 + (1 / 32),
      z + 1
    )
    Net.animate_bot(blur_bot_id, "APPEAR")

    Async.await(Async.sleep(animation_time))

    if direction then
      Net.set_bot_direction(enemy.id, direction)
    end

    -- move the enemy
    Net.transfer_bot(enemy.id, area_id, false, x + .5, y + .5, z)

    -- delete the blur bot
    Net.remove_bot(blur_bot_id)

    Async.await(Async.sleep(hold_time))

    enemy.x = x
    enemy.y = y
    enemy.z = z

    return resolve(true)
  end)
end

function EnemyHelpers.offset_position_with_direction(position, direction)
  position = {
    x = position.x,
    y = position.y,
    z = position.z
  }

  if direction == Direction.DOWN_LEFT then
    position.y = position.y + 1
  elseif direction == Direction.DOWN_RIGHT then
    position.x = position.x + 1
  elseif direction == Direction.UP_LEFT then
    position.x = position.x - 1
  elseif direction == Direction.UP_RIGHT then
    position.x = position.y - 1
  end

  return position
end

function EnemyHelpers.chebyshev_tile_distance(enemy, x, y, z)
  local xdiff = math.abs(enemy.x - math.floor(x))
  local ydiff = math.abs(enemy.y - math.floor(y))
  local zdiff = math.abs(enemy.z - math.floor(z)) --Account for layer difference!
  --Note: should enemies be able to teleport across layers??? Think on this.
  return math.max(xdiff, ydiff, zdiff)
end

-- uses chebyshev_tile_distance
---@param instance Liberation.MissionInstance
---@param enemy Liberation.Enemy
---@param max_distance? number
function EnemyHelpers.find_closest_player(instance, enemy, max_distance)
  local closest_player = nil
  local closest_distance = math.huge

  for _, player in ipairs(instance.players) do
    local player_x, player_y, player_z = player:position_multi()

    if player.health == 0 or player_z ~= enemy.z then
      goto continue
    end

    local distance = EnemyHelpers.chebyshev_tile_distance(enemy, player_x, player_y, player_z)

    if distance < closest_distance and (max_distance == nil or distance <= max_distance) then
      closest_distance = distance
      closest_player = player
    end

    ::continue::
  end

  return closest_player
end

return EnemyHelpers
