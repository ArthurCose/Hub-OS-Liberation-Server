local AttackSelection = require("scripts/libs/liberations/selections/attack_selection")
local Preloader = require("scripts/libs/liberations/preloader")

local BLUR_SFX = Preloader.add_asset("/server/assets/liberations/sounds/move.ogg")

---@class LiberationServer.CustomEnemies.ProtoMan: Liberation.EnemyAi
---@field damage number
---@field selection Liberation.AttackSelection
---@field is_engaged boolean
local ProtoMan = {}

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

local mob_health = { 300, 1000, 1600, 2000 }
local mob_damage = { 70, 120, 150, 200 }

---@param builder Liberation.EnemyBuilder
function ProtoMan:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type LiberationServer.CustomEnemies.ProtoMan
  local protoman = {
    damage = mob_damage[rank_index],
    selection = AttackSelection:new(builder.instance),
    is_engaged = false
  }

  setmetatable(protoman, self)
  self.__index = self

  local shape = {
    { 1, 1, 1 },
    { 1, 0, 1 },
    { 1, 1, 1 }
  }

  protoman.selection:set_shape(shape, 0, -2)

  return builder:build({
    ai = protoman,
    name = "ProtoMan",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/protoman.png",
    animation_path = "/server/assets/liberations/bots/protoman.animation",
    mug = {
      texture_path = "/server/assets/liberations/mugs/protoman.png",
      animation_path = "/server/assets/liberations/mugs/protoman.animation",
    },
  })
end

local BANTER_LINES = {
  {
    "Master granted me",
    "my DarkPower.",
    "",

    "Now I get the",
    "chance to try it!",
    "",

    "RIGHT NOW!!",
  },
}

---@param actor Liberation.Enemy
---@param player Liberation.Player
function ProtoMan:banter(actor, player)
  return Async.create_scope(function()
    if self.is_engaged then
      return
    end

    self.is_engaged = true

    -- randomize dialogue to keep his lines short
    local dialogue = BANTER_LINES[math.random(#BANTER_LINES)]

    Async.await(player:message(
      table.concat(dialogue, "\n"),
      actor.mug.texture_path,
      actor.mug.animation_path
    ))
  end)
end

local FINAL_LINES = {
  "What is this",
  "strong energy I",
  "feel from you...?",

  "Is this your idea of",
  "the \"power of justice\"?",
  "",

  "...Uurgh.",
}

function ProtoMan:get_final_message()
  return table.concat(FINAL_LINES, "\n")
end

local ENTRANCE_LINES = {
  {
    "So, you're the",
    "enemy of the",
    "Officials, huh?",
  },
  {
    "Master Regal saved",
    "my life. I pledged",
    "my loyalty to him.",
  },
  {
    "Protecting this",
    "area is my task.",
  },
}

-- should be called in an async scope
---@param actor Liberation.Enemy
---@param target Liberation.Player
local function try_teleporting_to_target(actor, target)
  local instance = actor:instance()
  local p_x, p_y, p_z = target:position_multi()
  local warps = {}

  local function try_add(x, y, direction)
    local tile_data = Net.get_tile(instance.area_id, x, y, p_z)

    if tile_data.gid ~= 0 then
      warps[#warps + 1] = { x, y, direction }
    end
  end

  local dist = 0.75

  try_add(p_x - dist, p_y, "Down Right")
  try_add(p_x + dist, p_y, "Up Left")
  try_add(p_x, p_y - dist, "Down Left")
  try_add(p_x, p_y + dist, "Up Right")

  if #warps == 0 then
    return false
  end

  local x, y, direction = table.unpack(warps[math.random(#warps)])

  Net.play_sound(instance.area_id, BLUR_SFX)
  Net.transfer_actor(actor.id, instance.area_id, false, x, y, p_z, direction)

  return true
end

---@param actor Liberation.Enemy
function ProtoMan:take_turn(actor)
  return Async.create_scope(function()
    local instance = actor:instance()

    if instance:phase() == 1 then
      Async.await(Async.sleep(0.25))

      local dialogue = ENTRANCE_LINES[math.random(#ENTRANCE_LINES)]
      Async.await(instance:announce(
        table.concat(dialogue, "\n"),
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

    self.selection:indicate()

    Async.await(Async.sleep(1))

    Async.await(instance:announce(
      "ProtoSword.",
      1.5,
      actor.mug.texture_path,
      actor.mug.animation_path
    ))

    actor:attack(caught_players, function(targets)
      local return_x, return_y, return_z = actor:floored_position_multi()
      local original_direction = Net.get_actor_direction(actor.id)

      Async.await(Async.sleep(.5))

      for _, target in ipairs(targets) do
        if try_teleporting_to_target(actor, target) then
          actor:play_attack_animation()

          Async.await(Async.sleep(.4))
        end
      end

      Async.await(Async.sleep(0.15))

      Net.synchronize(function()
        for _, target in ipairs(targets) do
          target:hurt(self.damage)
        end
      end)

      Async.await(Async.sleep(0.5))

      Async.await(actor:move(return_x, return_y, return_z, original_direction))

      actor:play_idle_animation()
    end)

    self.selection:remove_indicators()
  end)
end

return ProtoMan
