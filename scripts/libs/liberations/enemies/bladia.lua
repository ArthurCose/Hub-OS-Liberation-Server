local AttackSelection = require("scripts/libs/liberations/selections/attack_selection")
local Selection = require("scripts/libs/liberations/selections/selection")
local PanelClass = require("scripts/libs/liberations/panel_class")
local Direction = require("scripts/libs/direction")

---@class Liberation.Enemies.Bladia: Liberation.EnemyAi
---@field damage number
---@field selection Liberation.AttackSelection
---@field movement_selection Liberation.Selection
---@field home_initialized boolean
---@field home Net.Position
---@field home_direction string
local Bladia = {}

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

local mob_health = { 200, 230, 230, 300, 340, 400 }
local mob_damage = { 50, 80, 120, 160, 200, 250 }

local ATTACK_SHAPE = {
  { 1, 1, 1 },
  { 1, 0, 1 },
  { 1, 1, 1 },
}

local MOVE_SHAPE = {
  { 0, 1, 1, 1, 0 },
  { 1, 1, 1, 1, 1 },
  { 1, 1, 0, 1, 1 },
  { 1, 1, 1, 1, 1 },
  { 0, 1, 1, 1, 0 },
}

---@param builder Liberation.EnemyBuilder
function Bladia:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type Liberation.Enemies.Bladia
  local bladia = {
    damage = mob_damage[rank_index],
    selection = AttackSelection:new(builder.instance),
    movement_selection = Selection:new(builder.instance),
    home_initialized = false,
    home = { x = builder.position.x, y = builder.position.y, z = builder.position.z },
    home_direction = builder.direction,
  }

  setmetatable(bladia, self)
  self.__index = self

  bladia.selection:set_shape(ATTACK_SHAPE, 0, - #ATTACK_SHAPE // 2)
  bladia.movement_selection:set_shape(MOVE_SHAPE, 0, - #MOVE_SHAPE // 2)

  return builder:build({
    ai = bladia,
    name = "Bladia",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/bladia.png",
    animation_path = "/server/assets/liberations/bots/bladia.animation",
  })
end

function Bladia:get_final_message()
  return "Gyaaaahh!!"
end

---@param actor Liberation.Enemy
---@param player Liberation.Player
function Bladia:banter(actor, player)
  return Async.create_scope(function() end)
end

---@param self Liberation.Enemies.Bladia
---@param actor Liberation.Enemy
---@param moved boolean
local function try_attack(self, actor, moved)
  return Async.create_scope(function()
    self.selection:move(actor.x, actor.y, actor.z, Net.get_actor_direction(actor.id))
    local caught_players = self.selection:detect_players()

    if #caught_players == 0 then
      return
    end

    local player = caught_players[math.random(#caught_players)]
    local player_x, player_y = player:position_multi()

    if not moved then
      -- face player
      actor:face_position(player_x, player_y)

      Async.await(Async.sleep(0.5))
    end

    self.selection:indicate()

    -- delay before speaking
    Async.await(Async.sleep(1))

    local instance = actor:instance()

    Async.await(instance:announce("Get out of here,\nyou fools!\nDarkSlash!", 0.8))

    -- attack players
    actor:attack({ player }, function(targets)
      actor:play_attack_animation()

      for _, target in ipairs(targets) do
        target:hurt(self.damage)
      end

      Async.await(Async.sleep(.7))
    end)

    actor:play_idle_animation()

    self.selection:remove_indicators()

    return true
  end)
end

local movement_tests = {
  { -1, 0 },
  { 1,  0 },
  { 0,  -1 },
  { 0,  1 },
}

---@param self Liberation.Enemies.Bladia
---@param actor Liberation.Enemy
local function try_moving_to_players(self, actor)
  return Async.create_scope(function()
    local player = actor:find_closest_player(3)

    if not player then
      return false
    end

    local instance = actor:instance()
    local player_x, player_y, player_z = player:floored_position_multi()

    local closest_distance = 64
    local target_x = actor.x
    local target_y = actor.y

    for _, tuple in ipairs(movement_tests) do
      local offset_x, offset_y = table.unpack(tuple)
      local test_x = player_x + offset_x
      local test_y = player_y + offset_y

      local distance = math.abs(test_x - actor.x) + math.abs(test_y - actor.y)

      if distance > closest_distance then
        goto continue
      end

      if not self.movement_selection:is_within(test_x, test_y, actor.z) then
        goto continue
      end

      -- custom can_move_to logic
      local panel = instance:get_panel_at(test_x, test_y, actor.z)

      if panel and not PanelClass.ENEMY_WALKABLE[panel.class] then
        goto continue
      end

      if instance:get_enemy_at(test_x, test_y, actor.z) then
        goto continue
      end

      for _, p in ipairs(instance.players) do
        local p_x, p_y, p_z = p:floored_position_multi()

        if
            p_x == test_x and
            p_y == test_y and
            p_z == actor.z
        then
          goto continue
        end
      end

      -- passed
      closest_distance = distance
      target_x = test_x
      target_y = test_y

      ::continue::
    end

    if target_x == actor.x and target_y == actor.y then
      return false
    end

    -- face player
    actor:face_position(player_x, player_y)

    -- get the direction to face after movement
    local target_direction = Direction.diagonal_from_offset(
      player_x - target_x,
      player_y - target_y
    )

    -- move
    Async.await(actor:move(target_x, target_y, player_z, target_direction))

    -- generate dark panel
    if not instance:get_panel_at(actor.x, actor.y, actor.z) then
      instance:generate_panel(PanelClass.DARK, actor.x, actor.y, actor.z)

      Async.await(Async.sleep(.5))
    end

    return true
  end)
end

---@param self Liberation.Enemies.Bladia
---@param actor Liberation.Enemy
local function return_home(self, actor)
  return Async.create_scope(function()
    local instance = actor:instance()

    if self.home.x == actor.x and self.home.y == actor.y and self.home.z == actor.z then
      return false
    end

    -- face home
    actor:face_position(self.home.x + 0.5, self.home.y + 0.5)

    -- move
    Async.await(actor:move(self.home.x, self.home.y, self.home.z, self.home_direction))

    -- generate dark panel
    if not instance:get_panel_at(actor.x, actor.y, actor.z) then
      instance:generate_panel(PanelClass.DARK, actor.x, actor.y, actor.z)

      Async.await(Async.sleep(.5))
    end

    return true
  end)
end

---@param actor Liberation.Enemy
function Bladia:take_turn(actor)
  if not self.home_initialized then
    -- lock movements around our initial position
    self.home_initialized = true
    self.home.x = actor.x
    self.home.y = actor.y
    self.home.z = actor.z
    self.movement_selection:move(actor.x, actor.y, actor.z, Net.get_actor_direction(actor.id))
  end

  return Async.create_scope(function()
    if Async.await(try_attack(self, actor, false)) then
      return
    end

    if Async.await(try_moving_to_players(self, actor)) then
      Async.await(try_attack(self, actor, true))
      return
    end

    Async.await(return_home(self, actor))
  end)
end

return Bladia
