-- enemy implementations are in the enemies folder

---@class Liberation.Enemy: Net.Position
---@field id Net.ActorId
---@field battle_name string
---@field name string? reserved, will automatically be set on creation
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
---@field banter fun(self: Liberation.Enemy, player_id: Net.ActorId): Net.Promise

local BlizzardMan = require("scripts/libs/liberations/enemies/blizzardman")
local BigBrute = require("scripts/libs/liberations/enemies/bigbrute")
local ShadeMan = require("scripts/libs/liberations/enemies/shademan")
local Bladia = require("scripts/libs/liberations/enemies/bladia")
local ExplodingEffect = require("scripts/libs/liberations/effects/exploding_effect")

local Enemy = {}

local name_to_enemy = {
  BlizzardMan = BlizzardMan,
  BigBrute = BigBrute,
  ShadeMan = ShadeMan,
  Bladia = Bladia
}

---@class Liberation.EnemyOptions
---@field instance Liberation.MissionInstance
---@field name string
---@field position Net.Position
---@field direction string
---@field rank string
---@field encounter string

---@param instance Liberation.MissionInstance
---@param panel Liberation.PanelObject
function Enemy.options_from(instance, panel)
  ---@type Liberation.EnemyOptions
  return {
    instance = instance,
    name = panel.custom_properties.Boss or panel.custom_properties.Spawns,
    position = { x = panel.x, y = panel.y, z = panel.z },
    direction = panel.custom_properties.Direction:upper(),
    rank = panel.custom_properties.Rank or "V1",
    encounter = panel.custom_properties.Encounter or instance.default_encounter,
  }
end

---@param options Liberation.EnemyOptions
---@return Liberation.Enemy
function Enemy.from(options)
  local enemy = name_to_enemy[options.name]:new(options)
  enemy.name = enemy.name or options.name

  Net.set_bot_name(enemy.id, enemy.name .. ": " .. enemy.health)

  return enemy
end

function Enemy.is_alive(enemy)
  if enemy == nil then return false end
  return Net.is_bot(enemy.id)
end

function Enemy.get_death_message()
  return ""
end

---@param instance Liberation.MissionInstance
function Enemy.destroy(instance, enemy)
  return Async.create_promise(function(resolve)
    local success = false
    if not Enemy.is_alive(enemy) then
      -- already died
      return resolve(success)
    end

    -- remove from the instance
    for i, stored_enemy in pairs(instance.enemies) do
      if enemy == stored_enemy then
        table.remove(instance.enemies, i)
        break
      end
    end

    -- begin exploding the enemy
    local explosions = ExplodingEffect:new(enemy.id)

    -- moving every player's camera to the enemy
    local slide_time = .2
    local hold_time = 3
    local extra_explosion_time = .5

    for _, player in ipairs(instance.players) do
      player:lock_input()

      Net.slide_player_camera(player.id, enemy.x + .5, enemy.y + .5, enemy.z, slide_time)
      Net.move_player_camera(player.id, enemy.x + .5, enemy.y + .5, enemy.z, hold_time)

      local player_x, player_y, player_z = player:position_multi()
      Net.slide_player_camera(player.id, player_x, player_y, player_z, slide_time)
      Net.unlock_player_camera(player.id)
    end

    Async.await(Async.sleep(slide_time))

    -- display death message
    local message = enemy:get_death_message()
    local texture_path = enemy.mug and enemy.mug.texture_path
    local animation_path = enemy.mug and enemy.mug.animation_path
    if message ~= nil then
      for _, player in ipairs(instance.players) do
        player:message(message, texture_path, animation_path)
      end
    end

    Async.await(Async.sleep(hold_time + extra_explosion_time))

    -- remove from the server
    Net.remove_bot(enemy.id)

    Async.await(Async.sleep(extra_explosion_time))

    -- stop explosions
    explosions:remove()

    -- padding time to fix issues with unlock_player_camera
    -- also looks nice with items
    local unlock_padding = .3

    Async.await(Async.sleep(slide_time + unlock_padding))

    -- unlock players who were not locked
    for _, player in ipairs(instance.players) do
      player:unlock_input()
    end

    success = true

    return resolve(success)
  end)
end

return Enemy
