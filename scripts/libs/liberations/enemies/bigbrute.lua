local EnemySelection = require("scripts/libs/liberations/selections/enemy_selection")
local Preloader = require("scripts/libs/liberations/preloader")
local Direction = require("scripts/libs/direction")

local BEAST_BREATH_TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/beast_breath.png")
local BEAST_BREATH_ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/beast_breath.animation")
local BEAST_BREATH_SFX = Preloader.add_asset("/server/assets/liberations/sounds/beast_breath.ogg")

---@class Liberation.Enemies.BigBrute: Liberation.EnemyAi
---@field package damage number
---@field package selection Liberation.EnemySelection
local BigBrute = {}

--Setup ranked health and damage
local rank_to_index = {
  V1 = 1,
  V2 = 2,
  V3 = 3,
  V4 = 4,
  V5 = 5,
  V6 = 6,
  SP = 4,
  Alpha = 2,
  Beta = 3,
  Omega = 4,
}

local mob_health = { 120, 180, 220, 250, 300, 360 }
local mob_damage = { 30, 60, 90, 130, 170, 200 }
local textures = {
  "bigbrute.v1.png",
  "bigbrute.v2.png",
  "bigbrute.v3.png",
  "bigbrute.v4.png",
  "bigbrute.v5.png",
  "bigbrute.v6.png",
}

---@param builder Liberation.EnemyBuilder
function BigBrute:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type Liberation.Enemies.BigBrute
  local bigbrute = {
    damage = mob_damage[rank_index],
    selection = EnemySelection:new(builder.instance),
  }

  setmetatable(bigbrute, self)
  self.__index = self

  local shape = {
    { 1, 1, 1 },
    { 1, 0, 1 },
    { 1, 1, 1 }
  }

  bigbrute.selection:set_shape(shape, 0, -2)

  return builder:build({
    ai = bigbrute,
    name = "BigBrute",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/" .. textures[rank_index],
    animation_path = "/server/assets/liberations/bots/bigbrute.animation",
  })
end

function BigBrute:get_final_message()
  return "Gyaaaaahh!!"
end

---@param actor Liberation.Enemy
---@param player Liberation.Player
function BigBrute:banter(actor, player)
  return Async.create_scope(function() end)
end

local function sign(a)
  if a < 0 then
    return -1
  end

  return 1
end

---@param actor Liberation.Enemy
local function find_offset(actor, xstep, ystep, limit)
  local offset = 0
  -- adding them, as only one should be set, and the other should be set to 0
  local step = math.abs(xstep + ystep)

  for i = limit, 1, -step do
    if actor:can_move_to(actor.x + xstep * i, actor.y + ystep * i, actor.z) then
      offset = step * i
      break
    end
  end

  return offset
end

---@param actor Liberation.Enemy
---@param player Liberation.Player
local function attempt_axis_move(actor, player, diff, xfilter, yfilter)
  return Async.create_promise(function(resolve)
    local step = sign(diff)
    local limit = math.min(math.abs(diff), 2)
    local offset = find_offset(actor, step * xfilter, step * yfilter, limit)

    if offset == 0 then
      return resolve(false)
    end

    local targetx = actor.x + step * offset * xfilter
    local targety = actor.y + step * offset * yfilter

    actor:face_position(targetx + .5, targety + .5)

    local player_x, player_y = player:position_multi()
    local target_direction = Direction.diagonal_from_offset(
      player_x - (targetx + .5),
      player_y - (targety + .5)
    )

    actor:move(targetx, targety, actor.z, target_direction).and_then(function()
      return resolve(true)
    end)
  end)
end

---@param actor Liberation.Enemy
local function attempt_move(actor)
  return Async.create_scope(function()
    local player = actor:find_closest_player(4)

    if player == nil then
      -- all players left
      return false
    end

    local player_x, player_y = player:position_multi()

    local xdiff = math.floor(player_x) - actor.x
    local ydiff = math.floor(player_y) - actor.y

    if (ydiff == 0 or math.abs(xdiff) < math.abs(ydiff)) and xdiff ~= 0 then
      -- travel along the x axis, falling back to the y axis
      return
          Async.await(attempt_axis_move(actor, player, xdiff, 1, 0)) or
          Async.await(attempt_axis_move(actor, player, ydiff, 0, 1))
    elseif ydiff ~= 0 then
      -- travel along the y axis, falling back to the x axis
      return
          Async.await(attempt_axis_move(actor, player, ydiff, 0, 1)) or
          Async.await(attempt_axis_move(actor, player, xdiff, 1, 0))
    end

    return false
  end)
end

---@param self Liberation.Enemies.BigBrute
---@param actor Liberation.Enemy
local function attempt_attack(self, actor)
  return Async.create_scope(function()
    self.selection:move(actor, Net.get_bot_direction(actor.id))

    local caught_players = self.selection:detect_players()

    if #caught_players == 0 then
      return
    end

    local closest_player = actor:find_closest_player()

    if closest_player then
      local x, y = closest_player:position_multi()
      actor:face_position(x, y)
    end

    Async.await(Async.sleep(0.5))

    self.selection:indicate()

    Async.await(Async.sleep(1))

    local instance = actor.instance
    for _, player in ipairs(instance.players) do
      Net.message_player_auto(player.id, "Grrrowl!\nBeastBreath!", 0.8)
    end

    Async.await(Async.sleep(2))

    local spawned_bots = {}

    Net.synchronize(function()
      actor:play_attack_animation()

      for _, player in ipairs(caught_players) do
        local player_x, player_y, player_z = player:position_multi()

        table.insert(spawned_bots, Net.create_bot({
          texture_path = BEAST_BREATH_TEXTURE_PATH,
          animation_path = BEAST_BREATH_ANIMATION_PATH,
          animation = "ANIMATE",
          area_id = instance.area_id,
          warp_in = false,
          x = player_x + 1 / 32,
          y = player_y + 1 / 32,
          z = player_z
        }))
      end

      Net.play_sound(instance.area_id, BEAST_BREATH_SFX)
    end)

    Async.await(Async.sleep(.5))

    for _, player in ipairs(instance.players) do
      Net.shake_player_camera(player.id, 2, .5)
    end

    for _, player in ipairs(caught_players) do
      player:hurt(self.damage)
    end

    Async.await(Async.sleep(.5))

    actor:play_idle_animation()

    for _, bot_id in ipairs(spawned_bots) do
      Net.remove_bot(bot_id, false)
    end

    Async.await(Async.sleep(1))

    self.selection:remove_indicators()
  end)
end

---@param actor Liberation.Enemy
function BigBrute:take_turn(actor)
  return Async.create_scope(function()
    Async.await(attempt_move(actor))
    Async.await(attempt_attack(self, actor))
  end)
end

return BigBrute
