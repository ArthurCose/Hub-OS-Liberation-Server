local AttackSelection = require("scripts/libs/liberations/selections/attack_selection")
local Preloader = require("scripts/libs/liberations/preloader")
local Direction = require("scripts/libs/direction")

local ATTACK_SFX = Preloader.add_asset("/server/assets/liberations/sounds/tinhawk_attack.ogg")

---@class Liberation.Enemies.TinHawk: Liberation.EnemyAi
---@field package selection Liberation.AttackSelection
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

---@param builder Liberation.EnemyBuilder
function TinHawk:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type Liberation.Enemies.TinHawk
  local tinhawk = {
    selection = AttackSelection:new(builder.instance),
    damage = mob_damage[rank_index],
  }

  setmetatable(tinhawk, self)
  self.__index = self

  tinhawk.selection:set_shape(ATTACK_SHAPE, 0, - #ATTACK_SHAPE // 2)

  return builder:build({
    ai = tinhawk,
    name = "TinHawk",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/" .. textures[rank_index],
    animation_path = "/server/assets/liberations/bots/tinhawk.animation",
  })
end

function TinHawk:get_final_message()
  return "Gyaaaaahh!!"
end

---@param actor Liberation.Enemy
---@param player Liberation.Player
function TinHawk:banter(actor, player)
  return Async.create_scope(function() end)
end

---@param self Liberation.Enemies.TinHawk
---@param actor Liberation.Enemy
local function attempt_move(self, actor)
  return Async.create_scope(function()
    local player = actor:find_closest_player()

    if not player then
      return
    end

    ---@type [boolean, number, number, Liberation.PanelObject][]
    local valid_panels = {}

    local player_x, player_y = player:position_multi()
    local player_tile_x = math.floor(player_x)
    local player_tile_y = math.floor(player_y)

    local initial_chebyshev = math.max(
      math.abs(actor.x - player_tile_x),
      math.abs(actor.y - player_tile_y)
    )
    local initial_manhatten =
        math.abs(actor.x - player_tile_x) +
        math.abs(actor.y - player_tile_y)

    self.selection:set_shape(MOVE_SHAPE, 0, - #MOVE_SHAPE // 2)
    self.selection:for_each_tile(function(x, y, z)
      if not actor:can_move_to(x, y, z) then
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
        actor:instance():get_panel_at(x, y, z)
      }
    end)

    -- see which panels we can jump to, to strike a player
    self.selection:set_shape(ATTACK_SHAPE, 0, -4)

    for _, tuple in ipairs(valid_panels) do
      local panel = tuple[4]
      self.selection:move(panel.x, panel.y, panel.z, Direction.DOWN_LEFT)
      tuple[1] = self.selection:is_within(player_x, player_y, actor.z)
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

    Async.await(actor:move(
      panel.x,
      panel.y,
      panel.z
    ))

    actor:face_position(player_x, player_y)

    return true
  end)
end

---@param self Liberation.Enemies.TinHawk
---@param actor Liberation.Enemy
local function attempt_attack(self, actor)
  return Async.create_scope(function()
    self.selection:move(actor.x, actor.y, actor.z, Net.get_actor_direction(actor.id))

    -- find target
    local caught_players = self.selection:detect_players()

    -- filter out players that we can't reach
    local instance = actor:instance()

    for i = #caught_players, 1, -1 do
      local player = caught_players[i]

      local player_x, player_y, player_z = player:position_multi()

      local x_enemy = instance:get_enemy_at(player_x - 1, player_y, player_z)
      local y_enemy = instance:get_enemy_at(player_x, player_y - 1, player_z)

      if x_enemy and x_enemy ~= actor and y_enemy and y_enemy ~= actor then
        -- swap remove
        caught_players[i] = caught_players[#caught_players]
        caught_players[#caught_players] = nil
      end
    end

    if #caught_players == 0 then
      return false
    end

    local player = caught_players[math.random(#caught_players)]

    -- face player
    local player_position = player:position()
    actor:face_position(player_position.x, player_position.y)

    -- delay before indicating
    Async.await(Async.sleep(0.5))

    self.selection:indicate()

    -- delay before speaking
    Async.await(Async.sleep(1))

    for _, player in ipairs(instance.players) do
      Net.message_player_auto(player.id, "Gyaaaah!\nHawkAttack!", 0.8)
    end

    -- delay before attacking
    Async.await(Async.sleep(2))

    -- resolve movement
    local warp_back_pos = { x = actor.x, y = actor.y, z = actor.z }
    local target_x, target_y = math.floor(player_position.x), math.floor(player_position.y)

    local x_enemy = instance:get_enemy_at(target_x - 1, target_y, player_position.z)
    local y_enemy = instance:get_enemy_at(target_x, target_y - 1, player_position.z)

    if not (x_enemy and x_enemy ~= actor) and ((y_enemy and y_enemy ~= actor) or math.random(2) == 1) then
      target_x = target_x - 1
    else
      target_y = target_y - 1
    end

    local moving = target_x ~= actor.x or target_y ~= actor.y

    if moving then
      local target_direction = Direction.diagonal_from_offset(
        player_position.x - target_x,
        player_position.y - target_y
      )

      Async.await(actor:move(target_x, target_y, player_position.z, target_direction))
    else
      actor:face_position(player_position.x, player_position.y)
    end

    -- attack
    actor:attack({ player }, function(targets)
      actor:play_attack_animation()
      Net.play_sound(instance.area_id, ATTACK_SFX)

      for _, target in ipairs(targets) do
        target:hurt(self.damage)
      end

      Async.await(Async.sleep(.5))
    end)

    if moving then
      -- warp back
      local final_direction = Direction.diagonal_from_offset(
        player_position.x - warp_back_pos.x,
        player_position.y - warp_back_pos.y
      )

      Async.await(
        actor:move(
          warp_back_pos.x,
          warp_back_pos.y,
          warp_back_pos.z,
          final_direction
        )
      )
    else
      actor:face_position(player_position.x, player_position.y)
    end

    self.selection:remove_indicators()

    return true
  end)
end

---@param actor Liberation.Enemy
function TinHawk:take_turn(actor)
  return Async.create_scope(function()
    if not Async.await(attempt_attack(self, actor)) then
      Async.await(attempt_move(self, actor))
    end
  end)
end

return TinHawk
