local RecoverEffect = require("scripts/libs/liberations/effects/recover_effect")
local HealthSprites = require("scripts/libs/liberations/effects/health_sprites")
local Direction = require("scripts/libs/direction")

local EnemyHelpers = {
  GUARDIAN_MINIMAP_MARKER = { 104, 28, 255 },
  BOSS_MINIMAP_COLOR = { 200, 15, 67 }
}

local direction_suffix_map = {
  [Direction.DOWN_LEFT] = "DL",
  [Direction.DOWN_RIGHT] = "DR",
  [Direction.UP_LEFT] = "UL",
  [Direction.UP_RIGHT] = "UR",
}

---@param enemy Liberation.Enemy
function EnemyHelpers.play_attack_animation(enemy)
  local direction = Net.get_bot_direction(enemy.id)
  local suffix = direction_suffix_map[direction]
  local animation = "ATTACK_" .. suffix

  Net.animate_bot(enemy.id, animation)
end

---@param enemy Liberation.Enemy
function EnemyHelpers.play_idle_animation(enemy)
  local direction = Net.get_bot_direction(enemy.id)
  local suffix = direction_suffix_map[direction]
  local animation = "IDLE_" .. suffix

  Net.animate_bot(enemy.id, animation, true)
end

---@param enemy Liberation.Enemy
---@param amount number
function EnemyHelpers.heal(enemy, amount)
  local previous_health = enemy.health

  enemy.health = math.min(math.ceil(enemy.health + amount), enemy.max_health)

  HealthSprites.update_sprite(enemy.id, enemy.health)

  if previous_health < enemy.health then
    RecoverEffect:new(enemy.id)
    return Async.sleep(1)
  else
    return Async.create_function(function()
    end)
  end
end

---@param enemy Liberation.Enemy
---@param x number
---@param y number
function EnemyHelpers.face_position(enemy, x, y)
  x = x - (enemy.x + .5)
  y = y - (enemy.y + .5)

  Net.set_bot_direction(enemy.id, Direction.diagonal_from_offset(x, y))
  EnemyHelpers.play_idle_animation(enemy)
end

---@param instance Liberation.MissionInstance
---@param x number
---@param y number
---@param z number
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
---@param instance Liberation.MissionInstance
---@param enemy Liberation.Enemy
---@param x number
---@param y number
---@param z number
---@param direction string?
function EnemyHelpers.move(instance, enemy, x, y, z, direction)
  return Async.create_promise(function(resolve)
    x = math.floor(x)
    y = math.floor(y)

    local slide_time = .5
    local hold_time = .25
    local startup_time = .25
    local blur_time = 4 / 60

    Async.await(Async.sleep(hold_time))

    local area_id = Net.get_bot_area(enemy.id)

    -- create blur
    local blur_bot_id = Net.create_bot({
      texture_path = "/server/assets/liberations/bots/blur.png",
      animation_path = "/server/assets/liberations/bots/blur.animation",
      area_id = area_id,
      warp_in = false,
      x = enemy.x + .5,
      y = enemy.y + .5,
      z = enemy.z + 1
    })

    -- animate blur
    Net.animate_bot(blur_bot_id, "DISAPPEAR")

    Async.await(Async.sleep(blur_time))

    -- move this bot off screen
    local area_width = Net.get_layer_width(area_id)
    Net.transfer_bot(enemy.id, area_id, false, area_width + 100, 0, 0)

    Async.await(Async.sleep(16 / 60))

    for _, player in ipairs(instance.players) do
      Net.slide_player_camera(player.id, x + .5, y + .5, z, slide_time)
    end

    Async.await(Async.sleep(slide_time + startup_time))

    -- animate blur
    Net.transfer_bot(
      blur_bot_id,
      area_id,
      false,
      x + .5,
      y + .5,
      z + 1
    )
    Net.animate_bot(blur_bot_id, "APPEAR")

    Async.await(Async.sleep(blur_time))

    -- move the enemy
    if direction then
      Net.set_bot_direction(enemy.id, direction)
      EnemyHelpers.play_idle_animation(enemy)
    end

    Net.transfer_bot(enemy.id, area_id, false, x + .5, y + .5, z)

    Async.await(Async.sleep(hold_time))

    -- delete the blur bot
    Net.remove_bot(blur_bot_id)

    enemy.x = x
    enemy.y = y
    enemy.z = z

    return resolve(true)
  end)
end

---@param position Net.Position
---@param direction string
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

---@param enemy Liberation.Enemy
---@param x number
---@param y number
---@param z number
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
