local EnemyHelpers = require("scripts/libs/liberations/enemy_helpers")
local EnemySelection = require("scripts/libs/liberations/selections/enemy_selection")
local Preloader = require("scripts/libs/liberations/preloader")
local Direction = require("scripts/libs/direction")

local BEAST_BREATH_TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/beast_breath.png")
local BEAST_BREATH_ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/beast_breath.animation")
local BEAST_BREATH_SFX = Preloader.add_asset("/server/assets/liberations/sounds/beast_breath.ogg")

---@class Liberation.Enemies.BigBrute: Liberation.Enemy
---@field package instance Liberation.MissionInstance
---@field package selection Liberation.EnemySelection
---@field package damage number
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

---@param options Liberation.EnemyOptions
function BigBrute:new(options)
  local rank_index = rank_to_index[options.rank]

  local bigbrute = {
    instance = options.instance,
    id = nil,
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    damage = mob_damage[rank_index],
    rank = options.rank,
    x = math.floor(options.position.x),
    y = math.floor(options.position.y),
    z = math.floor(options.position.z),
    selection = EnemySelection:new(options.instance),
    encounter = options.encounter
  }

  setmetatable(bigbrute, self)
  self.__index = self

  local shape = {
    { 1, 1, 1 },
    { 1, 0, 1 },
    { 1, 1, 1 }
  }

  bigbrute.selection:set_shape(shape, 0, -2)
  bigbrute:spawn(options.direction)

  return bigbrute
end

function BigBrute:spawn(direction)
  local rank_index = rank_to_index[self.rank]

  self.id = Net.create_bot({
    name = "BigBrute",
    texture_path = "/server/assets/liberations/bots/" .. textures[rank_index],
    animation_path = "/server/assets/liberations/bots/bigbrute.animation",
    area_id = self.instance.area_id,
    direction = direction,
    warp_in = false,
    x = self.x + .5,
    y = self.y + .5,
    z = self.z
  })
  Net.set_bot_map_color(self.id, EnemyHelpers.GUARDIAN_MINIMAP_MARKER)
end

function BigBrute:get_death_message()
  return "Gyaaaaahh!!"
end

function BigBrute:banter()
  return Async.create_scope(function() end)
end

local function sign(a)
  if a < 0 then
    return -1
  end

  return 1
end

local function find_offset(self, xstep, ystep, limit)
  local offset = 0
  -- adding them, as only one should be set, and the other should be set to 0
  local step = math.abs(xstep + ystep)

  for i = limit, 1, -step do
    if EnemyHelpers.can_move_to(self.instance, self.x + xstep * i, self.y + ystep * i, self.z) then
      offset = step * i
      break
    end
  end

  return offset
end

---@param player Liberation.Player
local function attempt_axis_move(self, player, diff, xfilter, yfilter)
  return Async.create_promise(function(resolve)
    local step = sign(diff)
    local limit = math.min(math.abs(diff), 2)
    local offset = find_offset(self, step * xfilter, step * yfilter, limit)

    if offset == 0 then
      return resolve(false)
    end

    local targetx = self.x + step * offset * xfilter
    local targety = self.y + step * offset * yfilter

    EnemyHelpers.face_position(self, targetx + .5, targety + .5)

    local player_x, player_y = player:position_multi()
    local target_direction = Direction.diagonal_from_offset(
      player_x - (targetx + .5),
      player_y - (targety + .5)
    )

    EnemyHelpers.move(self.instance, self, targetx, targety, self.z, target_direction).and_then(function()
      return resolve(true)
    end)
  end)
end

local function attempt_move(self)
  return Async.create_scope(function()
    local player = EnemyHelpers.find_closest_player(self.instance, self, 4)

    if player == nil then
      -- all players left
      return false
    end

    local player_x, player_y = player:position_multi()

    local xdiff = math.floor(player_x) - self.x
    local ydiff = math.floor(player_y) - self.y

    if (ydiff == 0 or math.abs(xdiff) < math.abs(ydiff)) and xdiff ~= 0 then
      -- travel along the x axis, falling back to the y axis
      return
          Async.await(attempt_axis_move(self, player, xdiff, 1, 0)) or
          Async.await(attempt_axis_move(self, player, ydiff, 0, 1))
    elseif ydiff ~= 0 then
      -- travel along the y axis, falling back to the x axis
      return
          Async.await(attempt_axis_move(self, player, ydiff, 0, 1)) or
          Async.await(attempt_axis_move(self, player, xdiff, 1, 0))
    end

    return false
  end)
end

---@param self Liberation.Enemies.BigBrute
local function attempt_attack(self)
  return Async.create_scope(function()
    self.selection:move(self, Net.get_bot_direction(self.id))

    local caught_players = self.selection:detect_players()

    if #caught_players == 0 then
      return
    end

    local closest_player = EnemyHelpers.find_closest_player(self.instance, self)

    if closest_player then
      local x, y = closest_player:position_multi()
      EnemyHelpers.face_position(self, x, y)
    end

    Async.await(Async.sleep(0.5))

    self.selection:indicate()

    Async.await(Async.sleep(1))

    for _, player in ipairs(self.instance.players) do
      Net.message_player_auto(player.id, "Grrrowl!\nBeastBreath!", 0.8)
    end

    Async.await(Async.sleep(2))

    local spawned_bots = {}

    Net.synchronize(function()
      EnemyHelpers.play_attack_animation(self)

      for _, player in ipairs(caught_players) do
        local player_x, player_y, player_z = player:position_multi()

        table.insert(spawned_bots, Net.create_bot({
          texture_path = BEAST_BREATH_TEXTURE_PATH,
          animation_path = BEAST_BREATH_ANIMATION_PATH,
          animation = "ANIMATE",
          area_id = self.instance.area_id,
          warp_in = false,
          x = player_x + 1 / 32,
          y = player_y + 1 / 32,
          z = player_z
        }))
      end

      Net.play_sound(self.instance.area_id, BEAST_BREATH_SFX)
    end)

    Async.await(Async.sleep(.5))

    for _, player in ipairs(self.instance.players) do
      Net.shake_player_camera(player.id, 2, .5)
    end

    for _, player in ipairs(caught_players) do
      player:hurt(self.damage)
    end

    Async.await(Async.sleep(.5))

    EnemyHelpers.play_idle_animation(self)

    for _, bot_id in ipairs(spawned_bots) do
      Net.remove_bot(bot_id, false)
    end

    Async.await(Async.sleep(1))

    self.selection:remove_indicators()
  end)
end

function BigBrute:take_turn()
  return Async.create_scope(function()
    Async.await(attempt_move(self))
    Async.await(attempt_attack(self))
  end)
end

return BigBrute
