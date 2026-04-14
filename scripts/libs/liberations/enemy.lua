-- enemy implementations are in the enemies folder

---@class Liberation.EnemyAi
---@field new fun(self, options: Liberation.EnemyBuilder): Liberation.Enemy
---@field take_turn fun(self: Liberation.EnemyAi, actor: Liberation.Enemy): Net.Promise
---@field get_final_message fun(self: Liberation.EnemyAi, actor: Liberation.Enemy): string
---@field banter fun(self: Liberation.EnemyAi, actor: Liberation.Enemy, player: Liberation.Player): Net.Promise

---@class Liberation.Enemy: Net.Position
---@field id Net.ActorId
---@field instance Liberation.MissionInstance
---@field ai Liberation.EnemyAi
---@field turn_order number? set and used internally
---@field rank string the character rank for the encounter
---@field health number
---@field max_health number
---@field x number should be floored, but spawned bots should be centered on tiles (x + .5)
---@field y number should be floored, but spawned bots should be centered on tiles (y + .5)
---@field z number should be floored
---@field mug Net.TextureAnimationPair?
---@field encounter string

local RecoverEffect = require("scripts/libs/liberations/effects/recover_effect")
local ExplodingEffect = require("scripts/libs/liberations/effects/exploding_effect")
local HealthSprites = require("scripts/libs/liberations/effects/health_sprites")
local PanelClass = require("scripts/libs/liberations/panel_class")
local Direction = require("scripts/libs/direction")
local Preloader = require("scripts/libs/liberations/preloader")

local BLUR_TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/blur.png")
local BLUR_ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/blur.animation")
local BLUR_SFX = Preloader.add_asset("/server/assets/liberations/sounds/move.ogg")

---@class Liberation.Enemy: Net.Position
local Enemy = {}
Enemy.__index = Enemy

function Enemy:is_alive()
  return Net.is_bot(self.id)
end

local direction_suffix_map = {
  [Direction.DOWN_LEFT] = "DL",
  [Direction.DOWN_RIGHT] = "DR",
  [Direction.UP_LEFT] = "UL",
  [Direction.UP_RIGHT] = "UR",
}

function Enemy:play_attack_animation()
  local direction = Net.get_bot_direction(self.id)
  local suffix = direction_suffix_map[direction]
  local animation = "ATTACK_" .. suffix

  Net.animate_bot(self.id, animation)
end

function Enemy:play_idle_animation()
  local direction = Net.get_bot_direction(self.id)
  local suffix = direction_suffix_map[direction]
  local animation = "IDLE_" .. suffix

  Net.animate_bot(self.id, animation, true)
end

---A copy of the floored position
function Enemy:floored_position()
  return { x = self.x, y = self.y, z = self.z }
end

---A copy of the floored position
function Enemy:floored_position_multi()
  return self.x, self.y, self.z
end

---@param amount number
function Enemy:heal(amount)
  return Async.create_scope(function()
    local previous_health = self.health

    self.health = math.min(math.ceil(self.health + amount), self.max_health)

    HealthSprites.update_sprite(self.id, self.health)

    if previous_health < self.health then
      Async.await(Async.sleep(0.2))
      RecoverEffect:new_dark(self.id)
      Async.await(Async.sleep(1))
    end
  end)
end

---@param x number
---@param y number
function Enemy:face_position(x, y)
  x = x - (self.x + .5)
  y = y - (self.y + .5)

  Net.set_bot_direction(self.id, Direction.diagonal_from_offset(x, y))
  self:play_idle_animation()
end

---@param x number
---@param y number
---@param z number
function Enemy:can_move_to(x, y, z)
  local instance = self.instance
  local panel = instance:get_panel_at(x, y, z)

  if not panel or not PanelClass.ENEMY_WALKABLE[panel.class] then
    return false
  end

  if instance:get_enemy_at(x, y, z) ~= nil then
    return false
  end

  return true
end

-- takes instance to move player cameras
---@param x number
---@param y number
---@param z number
---@param direction string?
function Enemy:move(x, y, z, direction)
  return Async.create_promise(function(resolve)
    local instance = self.instance

    x = math.floor(x)
    y = math.floor(y)
    z = math.floor(z)

    local slide_time = .5
    local hold_time = .25
    local startup_time = .25
    local blur_time = 4 / 60

    Async.await(Async.sleep(hold_time))

    local area_id = Net.get_bot_area(self.id)

    -- create blur
    local blur_bot_id = Net.create_bot({
      texture_path = BLUR_TEXTURE_PATH,
      animation_path = BLUR_ANIMATION_PATH,
      area_id = area_id,
      warp_in = false,
      x = self.x + .5,
      y = self.y + .5,
      z = self.z + 1
    })

    -- animate blur
    Net.animate_bot(blur_bot_id, "DISAPPEAR")

    Net.play_sound(area_id, BLUR_SFX)

    Async.await(Async.sleep(blur_time))

    -- move this bot off screen
    local area_width = Net.get_layer_width(area_id)
    Net.transfer_bot(self.id, area_id, false, area_width + 100, 0, 0)

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

    Net.play_sound(area_id, BLUR_SFX)

    Async.await(Async.sleep(blur_time))

    -- move the enemy
    if direction then
      Net.set_bot_direction(self.id, direction)
      self:play_idle_animation()
    end

    Net.transfer_bot(self.id, area_id, false, x + .5, y + .5, z)

    Async.await(Async.sleep(hold_time))

    -- delete the blur bot
    Net.remove_bot(blur_bot_id)

    self.x = x
    self.y = y
    self.z = z

    return resolve(true)
  end)
end

---@param position Net.Position
---@param direction string
function Enemy.offset_position_with_direction(position, direction)
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

---@param x number
---@param y number
---@param z number
function Enemy:chebyshev_tile_distance(x, y, z)
  local xdiff = math.abs(self.x - math.floor(x))
  local ydiff = math.abs(self.y - math.floor(y))
  local zdiff = math.abs(self.z - math.floor(z)) --Account for layer difference!
  --Note: should enemies be able to teleport across layers??? Think on this.
  return math.max(xdiff, ydiff, zdiff)
end

-- uses chebyshev_tile_distance
---@param max_distance? number
function Enemy:find_closest_player(max_distance)
  local instance = self.instance

  local closest_player = nil
  local closest_distance = math.huge

  for _, player in ipairs(instance.players) do
    local player_x, player_y, player_z = player:position_multi()

    if player:health() == 0 or player_z ~= self.z then
      goto continue
    end

    local distance = self:chebyshev_tile_distance(player_x, player_y, player_z)

    if distance < closest_distance and (max_distance == nil or distance <= max_distance) then
      closest_distance = distance
      closest_player = player
    end

    ::continue::
  end

  return closest_player
end

---Pans the camera to the enemy, returns the camera and unlocks it when the callback is completed
---@param callback fun() called within an async scope
function Enemy:focus(callback)
  return Async.create_scope(function()
    local slide_time = .2

    local involved_players = {}

    -- moving every player's camera to the enemy
    local instance = self.instance

    for _, player in ipairs(instance.players) do
      player:stack_lock_movement()

      if not Net.is_player_battling(player.id) then
        Net.slide_player_camera(player.id, self.x + .5, self.y + .5, self.z, slide_time)
        involved_players[player.id] = true
      end
    end

    Async.await(Async.sleep(slide_time))

    -- execute callback
    callback()

    -- return camera to players
    for _, player in ipairs(instance.players) do
      if involved_players[player.id] then
        local player_x, player_y, player_z = player:position_multi()
        Net.slide_player_camera(player.id, player_x, player_y, player_z, slide_time)
        Net.unlock_player_camera(player.id)
      end
    end

    -- padding time to fix issues with unlock_player_camera
    -- also looks nice with items
    local unlock_padding = .3

    Async.await(Async.sleep(slide_time + unlock_padding))

    -- unlock players
    for _, player in ipairs(instance.players) do
      player:unstack_lock_movement()
    end
  end)
end

function Enemy:destroy()
  return Async.create_scope(function()
    if not self:is_alive() then
      -- already died
      return
    end

    -- remove from the instance
    local instance = self.instance

    for i, stored_enemy in pairs(instance.enemies) do
      if self == stored_enemy then
        table.remove(instance.enemies, i)
        break
      end
    end

    -- delete health sprite
    HealthSprites.remove_sprite(self.id)

    -- begin exploding the enemy
    local explosions = ExplodingEffect:new(self.id)

    Async.await(self:focus(function()
      -- display death message
      local message = self.ai:get_final_message(self)
      local texture_path = self.mug and self.mug.texture_path
      local animation_path = self.mug and self.mug.animation_path
      if message ~= nil then
        for _, player in ipairs(instance.players) do
          if not Net.is_player_busy(player.id) then
            player:message(message, texture_path, animation_path)
          end
        end
      end

      -- hold
      Async.await(Async.sleep(3.5))

      -- remove from the server
      Net.remove_bot(self.id)

      -- stop explosions after some delay
      Async.await(Async.sleep(0.5))

      explosions:remove()
    end))
  end)
end

---Destroys the enemy without panning the camera
function Enemy:destroy_in_focus()
  return Async.create_scope(function()
    if not self:is_alive() then
      -- already died
      return
    end

    -- remove from the instance
    local instance = self.instance
    for i, stored_enemy in pairs(instance.enemies) do
      if self == stored_enemy then
        table.remove(instance.enemies, i)
        break
      end
    end

    -- delete health sprite
    HealthSprites.remove_sprite(self.id)

    -- begin exploding the enemy
    local explosions = ExplodingEffect:new(self.id)

    -- display final message
    local message = self.ai:get_final_message(self)
    local texture_path = self.mug and self.mug.texture_path
    local animation_path = self.mug and self.mug.animation_path
    if message ~= nil then
      for _, player in ipairs(instance.players) do
        if not Net.is_player_busy(player.id) then
          player:message(message, texture_path, animation_path)
        end
      end
    end

    -- hold
    Async.await(Async.sleep(3.5))

    -- remove from the server
    Net.remove_bot(self.id)

    -- stop explosions after some delay
    Async.await(Async.sleep(0.5))

    explosions:remove()
  end)
end

return Enemy
