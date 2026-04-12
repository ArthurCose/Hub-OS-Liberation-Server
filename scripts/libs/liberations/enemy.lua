-- enemy implementations are in the enemies folder

---@class Liberation.Enemy: Net.Position
---@field id Net.ActorId
---@field turn_order number? reserved, set automatically on creation
---@field rank string the character rank for the encounter
---@field health number
---@field max_health number
---@field x number should be floored, but spawned bots should be centered on tiles (x + .5)
---@field y number should be floored, but spawned bots should be centered on tiles (y + .5)
---@field z number should be floored
---@field mug Net.TextureAnimationPair?
---@field encounter string
---@field new fun(self: Liberation.Enemy, options: Liberation.EnemyOptions): Liberation.Enemy
---@field take_turn fun(self: Liberation.Enemy): Net.Promise
---@field get_death_message fun(self: Liberation.Enemy): string
---@field banter fun(self: Liberation.Enemy, player: Liberation.Player): Net.Promise

local built_in_enemies = {
  BigBrute = require("scripts/libs/liberations/enemies/bigbrute"),
  TinHawk = require("scripts/libs/liberations/enemies/tinhawk"),
  Bladia = require("scripts/libs/liberations/enemies/bladia"),
  BlizzardMan = require("scripts/libs/liberations/enemies/blizzardman"),
  ShadeMan = require("scripts/libs/liberations/enemies/shademan"),
}
local ExplodingEffect = require("scripts/libs/liberations/effects/exploding_effect")
local HealthSprites = require("scripts/libs/liberations/effects/health_sprites")

local Enemy = {}

---@class Liberation.EnemyOptions
---@field instance Liberation.MissionInstance
---@field require_name_or_path string
---@field position Net.Position
---@field direction string
---@field rank string
---@field encounter string

---@param instance Liberation.MissionInstance
---@param panel Net.Object
function Enemy.options_from(instance, panel)
  ---@type Liberation.EnemyOptions
  return {
    instance = instance,
    require_name_or_path = panel.custom_properties.Boss or panel.custom_properties.Spawns,
    position = { x = panel.x, y = panel.y, z = panel.z },
    direction = panel.custom_properties.Direction:upper(),
    rank = panel.custom_properties.Rank or "V1",
    encounter = panel.custom_properties.Encounter or instance.default_encounter,
  }
end

---@param options Liberation.EnemyOptions
---@return Liberation.Enemy
function Enemy.from(options)
  local ResolvedEnemy = built_in_enemies[options.require_name_or_path] or require(options.require_name_or_path)
  local enemy = ResolvedEnemy:new(options)

  -- display health
  HealthSprites.update_sprite(enemy.id, enemy.health)

  return enemy
end

---@param enemy Liberation.Enemy
function Enemy.is_alive(enemy)
  if enemy == nil then return false end
  return Net.is_bot(enemy.id)
end

function Enemy.get_death_message()
  return ""
end

---Pans the camera to the enemy, returns the camera and unlocks it when the callback is completed
---@param instance Liberation.MissionInstance
---@param enemy Liberation.Enemy
---@param callback fun() called within an async scope
function Enemy.focus(instance, enemy, callback)
  return Async.create_scope(function()
    local slide_time = .2

    local involved_players = {}

    -- moving every player's camera to the enemy
    for _, player in ipairs(instance.players) do
      player:stack_lock_movement()

      if not Net.is_player_battling(player.id) then
        Net.slide_player_camera(player.id, enemy.x + .5, enemy.y + .5, enemy.z, slide_time)
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

---@param instance Liberation.MissionInstance
---@param enemy Liberation.Enemy
function Enemy.destroy(instance, enemy)
  return Async.create_scope(function()
    if not Enemy.is_alive(enemy) then
      -- already died
      return
    end

    -- remove from the instance
    for i, stored_enemy in pairs(instance.enemies) do
      if enemy == stored_enemy then
        table.remove(instance.enemies, i)
        break
      end
    end

    -- delete health sprite
    HealthSprites.remove_sprite(enemy.id)

    -- begin exploding the enemy
    local explosions = ExplodingEffect:new(enemy.id)

    Async.await(Enemy.focus(instance, enemy, function()
      -- display death message
      local message = enemy:get_death_message()
      local texture_path = enemy.mug and enemy.mug.texture_path
      local animation_path = enemy.mug and enemy.mug.animation_path
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
      Net.remove_bot(enemy.id)

      -- stop explosions after some delay
      Async.await(Async.sleep(0.5))

      explosions:remove()
    end))
  end)
end

---Destroys the enemy without panning the camera
---@param instance Liberation.MissionInstance
---@param enemy Liberation.Enemy
function Enemy.destroy_in_focus(instance, enemy)
  return Async.create_scope(function()
    if not Enemy.is_alive(enemy) then
      -- already died
      return
    end

    -- remove from the instance
    for i, stored_enemy in pairs(instance.enemies) do
      if enemy == stored_enemy then
        table.remove(instance.enemies, i)
        break
      end
    end

    -- delete health sprite
    HealthSprites.remove_sprite(enemy.id)

    -- begin exploding the enemy
    local explosions = ExplodingEffect:new(enemy.id)

    -- display death message
    local message = enemy:get_death_message()
    local texture_path = enemy.mug and enemy.mug.texture_path
    local animation_path = enemy.mug and enemy.mug.animation_path
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
    Net.remove_bot(enemy.id)

    -- stop explosions after some delay
    Async.await(Async.sleep(0.5))

    explosions:remove()
  end)
end

return Enemy
