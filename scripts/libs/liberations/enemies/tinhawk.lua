local EnemyHelpers = require("scripts/libs/liberations/enemy_helpers")
local EnemySelection = require("scripts/libs/liberations/selections/enemy_selection")
local Preloader = require("scripts/libs/liberations/preloader")
local Direction = require("scripts/libs/direction")

local ATTACK_SFX = Preloader.add_asset("/server/assets/liberations/sounds/tinhawk_attack.ogg")

---@class Liberation.Enemies.TinHawk: Liberation.Enemy
---@field package instance Liberation.MissionInstance
---@field package selection Liberation.EnemySelection
---@field package direction string
---@field package damage number
local TinHawk = {}

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

local mob_health = { 100, 150, 180, 200, 250, 300 }
local mob_damage = { 30, 50, 70, 90, 120, 150 }
local textures = {
  "tinhawk.v1.png",
  "tinhawk.v2.png",
  "tinhawk.v3.png",
  "tinhawk.v4.png",
  "tinhawk.v5.png",
  "tinhawk.v6.png",
}

local ATTACK_SHAPE = {
  { 0, 1, 1, 1, 1, 1, 0 },
  { 1, 1, 1, 1, 1, 1, 1 },
  { 1, 1, 1, 1, 1, 1, 1 },
  { 1, 1, 1, 0, 1, 1, 1 },
  { 1, 1, 1, 1, 1, 1, 1 },
  { 1, 1, 1, 1, 1, 1, 1 },
  { 0, 1, 1, 1, 1, 1, 0 },
}

local MOVE_SHAPE = {
  { 0, 0, 1, 1, 1, 0, 0 },
  { 0, 1, 1, 1, 1, 1, 0 },
  { 1, 1, 1, 1, 1, 1, 1 },
  { 1, 1, 1, 0, 1, 1, 1 },
  { 1, 1, 1, 1, 1, 1, 1 },
  { 0, 1, 1, 1, 1, 1, 0 },
  { 0, 0, 1, 1, 1, 0, 0 },
}

---@param options Liberation.EnemyOptions
function TinHawk:new(options)
  local rank_index = rank_to_index[options.rank]

  local tinhawk = {
    instance = options.instance,
    id = nil,
    battle_name = "TinHawk",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    damage = mob_damage[rank_index],
    rank = options.rank,
    x = math.floor(options.position.x),
    y = math.floor(options.position.y),
    z = math.floor(options.position.z),
    direction = options.direction,
    selection = EnemySelection:new(options.instance),
    encounter = options.encounter
  }

  setmetatable(tinhawk, self)
  self.__index = self


  tinhawk.selection:set_shape(ATTACK_SHAPE, 0, - #ATTACK_SHAPE // 2)
  tinhawk:spawn(options.direction)

  return tinhawk
end

function TinHawk:spawn(direction)
  local rank_index = rank_to_index[self.rank]

  self.id = Net.create_bot({
    texture_path = "/server/assets/liberations/bots/" .. textures[rank_index],
    animation_path = "/server/assets/liberations/bots/tinhawk.animation",
    area_id = self.instance.area_id,
    direction = direction,
    warp_in = false,
    x = self.x + .5,
    y = self.y + .5,
    z = self.z
  })
  Net.set_bot_map_color(self.id, EnemyHelpers.GUARDIAN_MINIMAP_MARKER)
end

function TinHawk:get_death_message()
  return "Gyaaaaahh!!"
end

function TinHawk:banter()
  return Async.create_scope(function() end)
end

---@param self Liberation.Enemies.TinHawk
local function attempt_move(self)
  return Async.create_scope(function()
    local player = EnemyHelpers.find_closest_player(self.instance, self)

    if not player then
      return
    end

    ---@type [boolean, number, number, Liberation.PanelObject][]
    local valid_panels = {}

    local player_x, player_y = player:position_multi()
    local player_tile_x = math.floor(player_x)
    local player_tile_y = math.floor(player_y)

    local initial_chebyshev = math.max(
      math.abs(self.x - player_tile_x),
      math.abs(self.y - player_tile_y)
    )
    local initial_manhatten =
        math.abs(self.x - player_tile_x) +
        math.abs(self.y - player_tile_y)

    self.selection:set_shape(MOVE_SHAPE, 0, - #MOVE_SHAPE // 2)
    self.selection:for_each_tile(function(x, y, z)
      if not EnemyHelpers.can_move_to(self.instance, x, y, z) then
        return
      end

      valid_panels[#valid_panels + 1] = {
        -- resolved later
        false,
        -- chebyshev distance
        math.max(
          math.abs(x - player_tile_x),
          math.abs(y - player_tile_y)
        ),
        -- manhatten distance
        math.abs(x - player_tile_x) + math.abs(y - player_tile_y),
        self.instance:get_panel_at(x, y, z)
      }
    end)

    -- see which panels we can jump to, to strike a player
    self.selection:set_shape(ATTACK_SHAPE, 0, -4)
    local test_position = {}

    for _, tuple in ipairs(valid_panels) do
      local panel = tuple[4]
      test_position.x = panel.x
      test_position.y = panel.y
      test_position.z = panel.z

      self.selection:move(test_position, self.direction)
      tuple[1] = self.selection:is_within(player_x, player_y, self.z)
    end

    if #valid_panels == 0 then
      return false
    end

    table.sort(valid_panels, function(a, b)
      if a[1] ~= b[1] then
        -- prioritize panels where we can hit a player
        return a[1]
      end

      -- otherwise prioritize panels closer to the target
      if a[2] == b[2] then
        return a[3] < b[3]
      end

      return a[2] < b[2]
    end)

    local can_hit, chebyshev, manhatten, panel = table.unpack(valid_panels[1])

    if not can_hit and chebyshev >= initial_chebyshev and manhatten >= initial_manhatten then
      -- target tile doesn't bring us closer
      return false
    end

    Async.await(EnemyHelpers.move(
      self.instance,
      self,
      panel.x,
      panel.y,
      panel.z
    ))

    EnemyHelpers.face_position(self, player_x, player_y)

    return true
  end)
end

---@param self Liberation.Enemies.TinHawk
local function attempt_attack(self)
  return Async.create_scope(function()
    self.selection:move(self, Net.get_bot_direction(self.id))

    -- find target
    local caught_players = self.selection:detect_players()

    if #caught_players == 0 then
      return false
    end

    local player = caught_players[math.random(#caught_players)]

    -- face player
    local player_position = player:position()
    EnemyHelpers.face_position(self, player_position.x, player_position.y)

    -- delay before indicating
    Async.await(Async.sleep(0.5))

    self.selection:indicate()

    -- delay before speaking
    Async.await(Async.sleep(1))

    for _, player in ipairs(self.instance.players) do
      Net.message_player_auto(player.id, "Gyaaaah!\nHawkAttack!", 0.8)
    end

    -- delay before attacking
    Async.await(Async.sleep(2))

    -- resolve movement
    local warp_back_pos = { x = self.x, y = self.y, z = self.z }
    local warp_back_direction = self.direction
    local target_x, target_y = player_position.x, player_position.y

    if math.random(2) == 1 then
      target_x = target_x - 1
    else
      target_y = target_y - 1
    end

    local target_direction = Direction.diagonal_from_offset(
      player_position.x - target_x,
      player_position.y - target_y
    )

    Async.await(EnemyHelpers.move(self.instance, self, target_x, target_y, player_position.z, target_direction))

    -- attack
    EnemyHelpers.play_attack_animation(self)
    Net.play_sound(self.instance.area_id, ATTACK_SFX)

    Async.await(Async.sleep(.4))

    player:hurt(self.damage)

    Async.await(Async.sleep(.2))

    -- warp back
    Async.await(EnemyHelpers.move(self.instance, self, warp_back_pos.x, warp_back_pos.y, warp_back_pos.z,
      warp_back_direction))

    self.selection:remove_indicators()

    return true
  end)
end

function TinHawk:take_turn()
  return Async.create_scope(function()
    if not Async.await(attempt_attack(self)) then
      Async.await(attempt_move(self))
    end
  end)
end

return TinHawk
