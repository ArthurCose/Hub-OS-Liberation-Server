local AttackSelection = require("scripts/libs/liberations/selections/attack_selection")
local Preloader = require("scripts/libs/liberations/preloader")

local POOF_TEXTURE = Preloader.add_asset("/server/assets/liberations/bots/poof_purple.png")
local POOF_ANIM_PATH = Preloader.add_asset("/server/assets/liberations/bots/poof.animation")
local SOFT_EXPLOSION_SFX = Preloader.add_asset("/server/assets/liberations/sounds/explosion.ogg")

---@class Liberation.Enemies.CloudMan: Liberation.EnemyAi
---@field damage number
---@field selection Liberation.AttackSelection
---@field is_engaged boolean
local CloudMan = {}

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

local mob_health = { 700, 900, 1300, 1500 }
local mob_damage = { 40, 60, 120, 140 }

---@param builder Liberation.EnemyBuilder
function CloudMan:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type Liberation.Enemies.CloudMan
  local cloudman = {
    damage = mob_damage[rank_index],
    selection = AttackSelection:new(builder.instance),
    is_engaged = false
  }

  setmetatable(cloudman, self)
  self.__index = self

  local shape = {
    { 1, 1, 1 },
    { 1, 0, 1 },
    { 1, 1, 1 },
    { 1, 1, 1 }
  }

  cloudman.selection:set_shape(shape, 0, -2)

  return builder:build({
    ai = cloudman,
    name = "CloudMan",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/cloudman.png",
    animation_path = "/server/assets/liberations/bots/cloudman.animation",
    mug = {
      texture_path = "/server/assets/liberations/mugs/cloudman.png",
      animation_path = "/server/assets/liberations/mugs/cloudman.animation",
    },
  })
end

---@param actor Liberation.Enemy
---@param player Liberation.Player
function CloudMan:banter(actor, player)
  return Async.create_scope(function()
    if self.is_engaged then
      return
    end

    self.is_engaged = true

    Async.await(player:message(
      "Feel the wrath\nof my divine\npunishment!",
      actor.mug.texture_path,
      actor.mug.animation_path
    ))
  end)
end

local defeat_lines = {
  "Agh...!",
  "Defeated...?",
  "It cannot be...!",

  "But I don't think",
  "you'll be making",
  "it back alive...!",

  "ha, ha, HA!"
}

function CloudMan:get_final_message()
  return table.concat(defeat_lines, "\n")
end

---@param actor Liberation.Enemy
function CloudMan:take_turn(actor)
  return Async.create_scope(function()
    local instance = actor:instance()

    if instance:phase() == 1 then
      Async.await(Async.sleep(0.25))

      Async.await(instance:announce(
        "Hurry back, haha!\nI'll welcome you\nwith thunderclouds!",
        1.5,
        actor.mug.texture_path,
        actor.mug.animation_path
      ))

      Async.await(Async.sleep(0.5))
    end

    self.selection:move(actor.x, actor.y, actor.z, Net.get_actor_direction(actor.id))

    local caught_players = self.selection:detect_players()

    if #caught_players == 0 then
      return
    end

    local target = caught_players[math.random(#caught_players)]

    self.selection:indicate()

    Async.await(Async.sleep(1))

    Async.await(instance:announce(
      "I'll fog ya up!\nDark Cloud!",
      1.5,
      actor.mug.texture_path,
      actor.mug.animation_path
    ))

    actor:attack({ target }, function(targets)
      actor:play_attack_animation()

      Async.await(Async.sleep(.5))

      -- spawn clouds
      local spawned_bots = {}

      for _, player in ipairs(targets) do
        local player_x, player_y, player_z = player:position_multi()

        for offset = 1, 6 do
          local id = Net.create_bot({
            area_id = instance.area_id,
            texture_path = POOF_TEXTURE,
            animation_path = POOF_ANIM_PATH,
            warp_in = false,
          })

          local poof_duration = (12 + offset) / 60

          ---@type Net.ActorKeyframe[]
          local keyframes = {}

          for i = 1, 6 do
            local screen_x = (math.random() * 2 - 1) * 0.25

            local pos_x = player_x - screen_x
            local pos_y = player_y + screen_x
            local pos_z = player_z + math.random(0, 40) / 16

            keyframes[#keyframes + 1] = {
              properties = {
                { property = "Animation", value = "LARGE", ease = "Ceil" },
                { property = "X",         value = pos_x,   ease = "Ceil" },
                { property = "Y",         value = pos_y,   ease = "Ceil" },
                { property = "Z",         value = pos_z,   ease = "Ceil" }
              },
              duration = poof_duration
            }
          end

          Net.animate_actor_properties(id, keyframes)

          spawned_bots[#spawned_bots + 1] = id
        end
      end

      if #targets > 0 then
        -- nonblocking sfx loop,
        -- might be better to adjust actor property animations in the future
        -- to allow sfx to be heard by all players
        local function sfx_loop(iterations)
          Net.play_sound(instance.area_id, SOFT_EXPLOSION_SFX)
          Async.sleep(0.2).and_then(function()
            if iterations > 0 then
              sfx_loop(iterations - 1)
            end
          end)
        end

        sfx_loop(9)
      end

      Async.await(Async.sleep(1))

      for _, player in ipairs(instance.players) do
        Net.shake_player_camera(player.id, 2, .5)
      end

      for _, target in ipairs(targets) do
        if #instance.players > 1 then
          target:hurt(self.damage)
          target:paralyze()
        else
          -- we want to avoid ending the game by paralyzing solo players
          -- so we'll just deal double damage instead
          target:hurt(self.damage * 2)
        end
      end

      Async.await(Async.sleep(1))

      for _, bot_id in ipairs(spawned_bots) do
        Net.remove_bot(bot_id, false)
      end

      actor:play_idle_animation()
    end)

    self.selection:remove_indicators()
  end)
end

return CloudMan
