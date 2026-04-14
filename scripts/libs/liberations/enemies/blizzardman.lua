local EnemySelection = require("scripts/libs/liberations/selections/enemy_selection")
local Preloader = require("scripts/libs/liberations/preloader")

local SNOWBALL_TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/snowball.png")
local SNOWBALL_ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/snowball.animation")

---@class Liberation.Enemies.BlizzardMan: Liberation.EnemyAi
---@field damage number
---@field selection Liberation.EnemySelection
---@field is_engaged boolean
local BlizzardMan = {}

--Setup ranked health and damage
local rank_to_index = {
  V1 = 1,
  V2 = 2,
  V3 = 3,
  SP = 4,
  Alpha = 2,
  Beta = 3,
  Omega = 4,
}

local mob_health = { 400, 1200, 1600, 2000 }
local mob_damage = { 40, 80, 120, 160 }

---@param builder Liberation.EnemyBuilder
function BlizzardMan:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type Liberation.Enemies.BlizzardMan
  local blizzardman = {
    damage = mob_damage[rank_index],
    selection = EnemySelection:new(builder.instance),
    is_engaged = false
  }

  setmetatable(blizzardman, self)
  self.__index = self

  local shape = {
    { 1, 1, 1 },
    { 1, 0, 1 },
    { 1, 1, 1 },
    { 1, 1, 1 }
  }

  blizzardman.selection:set_shape(shape, 0, -2)

  return builder:build({
    ai = blizzardman,
    name = "BlizzardMan",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/blizzardman.png",
    animation_path = "/server/assets/liberations/bots/blizzardman.animation",
    mug = {
      texture_path = "/server/assets/liberations/mugs/blizzardman.png",
      animation_path = "/server/assets/liberations/mugs/blizzardman.animation",
    },
  })
end

---@param actor Liberation.Enemy
---@param player Liberation.Player
function BlizzardMan:banter(actor, player)
  return Async.create_scope(function()
    if self.is_engaged then
      return
    end

    self.is_engaged = true

    Async.await(player:message(
      "I didn't think you would make it this far! *Whoosh*",
      actor.mug.texture_path,
      actor.mug.animation_path
    ))
    Async.await(player:message(
      "I'll freeze you to the bone!",
      actor.mug.texture_path,
      actor.mug.animation_path
    ))
  end)
end

function BlizzardMan:get_final_message()
  return "Woosh!\nI can't believe\nit. I can't lose.\nNOOOO!"
end

function BlizzardMan:take_turn(actor)
  return Async.create_scope(function()
    local instance = actor.instance

    if not debug and instance.phase == 1 then
      for _, player in ipairs(instance.players) do
        player:message_auto(
          "I'll turn this area into a Nebula ski resort! Got it?",
          2,
          actor.mug.texture_path,
          actor.mug.animation_path
        )
      end
    end

    self.selection:move(actor, Net.get_bot_direction(actor.id))

    local caught_players = self.selection:detect_players()

    if #caught_players == 0 then
      return
    end

    self.selection:indicate()

    Async.await(Async.sleep(1))

    for _, player in ipairs(instance.players) do
      player:message_auto(
        "Shiver in my\ndeep winter!",
        1.5,
        actor.mug.texture_path,
        actor.mug.animation_path
      )
      player:message_auto(
        "Snowball!",
        1.5,
        actor.mug.texture_path,
        actor.mug.animation_path
      )
    end

    Async.await(Async.sleep(4.5))

    actor:play_attack_animation()

    Async.await(Async.sleep(.5))

    local spawned_bots = {}

    Net.synchronize(function()
      for _, player in ipairs(caught_players) do
        local player_x, player_y, player_z = player:position_multi()
        local snowball_bot_id = Net.create_bot({
          texture_path = SNOWBALL_TEXTURE_PATH,
          animation_path = SNOWBALL_ANIMATION_PATH,
          area_id = instance.area_id,
          warp_in = false,
          x = player_x + 1 / 32,
          y = player_y + 1 / 32,
          z = player_z + 8.5
        })

        Net.animate_bot_properties(snowball_bot_id, {
          {
            properties = {
              { property = "Animation", value = "FALL" },
            },
          },
          {
            properties = {
              { property = "Z", ease = "Linear", value = player_z + 1.25 },
            },
            duration = .5
          },
          {
            properties = {
              { property = "Animation", value = "" },
            },
            duration = .5
          },
        })

        spawned_bots[#spawned_bots + 1] = snowball_bot_id
      end
    end)

    Async.await(Async.sleep(.5))

    for _, player in ipairs(instance.players) do
      Net.shake_player_camera(player.id, 2, .5)
    end

    for _, player in ipairs(caught_players) do
      player:hurt(self.damage)
    end

    Async.await(Async.sleep(1.5))

    for _, bot_id in ipairs(spawned_bots) do
      Net.remove_bot(bot_id, false)
    end

    actor:play_idle_animation()

    self.selection:remove_indicators()
  end)
end

return BlizzardMan
