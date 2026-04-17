local EnemySelection = require("scripts/libs/liberations/selections/enemy_selection")
local Direction = require("scripts/libs/direction")

---@class Liberation.Enemies.ShadeMan: Liberation.EnemyAi
---@field selection Liberation.EnemySelection
---@field damage number
---@field direction string
---@field is_engaged boolean
local ShadeMan = {}

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

local mob_health = { 600, 1000, 1200, 1500 }
local mob_damage = { 60, 70, 80, 100 }

---@param builder Liberation.EnemyBuilder
function ShadeMan:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type Liberation.Enemies.ShadeMan
  local shademan = {
    selection = EnemySelection:new(builder.instance),
    damage = mob_damage[rank_index],
    direction = builder.direction,
    is_engaged = false
  }

  setmetatable(shademan, self)
  self.__index = self

  local shape = {
    { 1 }
  }

  shademan.selection:set_shape(shape, 0, -1)

  return builder:build({
    ai = shademan,
    name = "ShadeMan",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/shademan.png",
    animation_path = "/server/assets/liberations/bots/shademan.animation",
    mug = {
      texture_path = "/server/assets/liberations/mugs/shademan.png",
      animation_path = "/server/assets/liberations/mugs/shademan.animation",
    }
  })
end

function ShadeMan:get_final_message()
  return "Grr! I can't\nbelieve I've been\ndisgraced again...!\nGyaaaahh!!"
end

---@param actor Liberation.Enemy
---@param player Liberation.Player
function ShadeMan:banter(actor, player)
  return Async.create_scope(function()
    if self.is_engaged then
      return
    end

    self.is_engaged = true

    Async.await(player:message(
      "Your deletion will be delicious!",
      actor.mug.texture_path,
      actor.mug.animation_path
    ))
  end)
end

---@param actor Liberation.Enemy
function ShadeMan:take_turn(actor)
  return Async.create_scope(function()
    local instance = actor:instance()

    if instance:phase() == 1 then
      Async.await(Async.sleep(0.5))

      for _, player in ipairs(instance.players) do
        player:message_auto(
          "Heh heh...let's party!",
          1.5,
          actor.mug.texture_path,
          actor.mug.animation_path
        )
      end

      -- allow time for the players to read this message
      Async.await(Async.sleep(3))

      return
    end

    local possible_targets = {}

    -- filter out players that we can't reach
    for _, player in ipairs(instance.players) do
      if player:health() <= 0 then
        goto continue
      end

      local player_x, player_y, player_z = player:position_multi()

      if
          not instance:get_panel_at(player_x - 1, player_y, player_z) and
          not instance:get_panel_at(player_x + 1, player_y, player_z) and
          not instance:get_panel_at(player_x, player_y - 1, player_z) and
          not instance:get_panel_at(player_x, player_y + 1, player_z)
      then
        -- no dark panels nearby
        goto continue
      end

      local x_enemy = instance:get_enemy_at(player_x - 1, player_y, player_z)
      local y_enemy = instance:get_enemy_at(player_x, player_y - 1, player_z)

      if x_enemy and x_enemy ~= self and y_enemy and y_enemy ~= self then
        -- enemy in the way
        goto continue
      end

      possible_targets[#possible_targets + 1] = player

      ::continue::
    end

    if #possible_targets == 0 then
      return
    end

    local player = possible_targets[math.random(#possible_targets)]

    local player_position = player:position()

    Async.await(Async.sleep(0.5))

    -- message all players.
    for _, players in ipairs(instance.players) do
      Async.message_player_auto(players.id,
        "Don't underestimate\nthe Darkloids!",
        0.8,
        actor.mug.texture_path,
        actor.mug.animation_path
      )
    end

    Async.await(Async.sleep(2))

    -- resolve movement
    local warp_back_pos = actor:floored_position()
    local warp_back_direction = self.direction
    local target_x, target_y = math.floor(player_position.x), math.floor(player_position.y)

    local x_enemy = instance:get_enemy_at(target_x - 1, target_y, player_position.z)
    local y_enemy = instance:get_enemy_at(target_x, target_y - 1, player_position.z)

    if not (x_enemy and x_enemy ~= self) and ((y_enemy and y_enemy ~= self) or math.random(2) == 1) then
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

    -- indicate and attack
    self.selection:move(player_position, Direction.None)
    self.selection:indicate()

    actor:attack({ player }, function(targets)
      actor:play_attack_animation()

      Async.await(Async.sleep(.2))

      for _, target in ipairs(targets) do
        target:hurt(self.damage)
      end

      Async.await(Async.sleep(.5))
    end)

    if moving then
      -- warp back
      Async.await(
        actor:move(
          warp_back_pos.x,
          warp_back_pos.y,
          warp_back_pos.z,
          warp_back_direction
        )
      )
    else
      Net.set_actor_direction(actor.id, self.direction)
      actor:play_idle_animation()
    end

    self.selection:remove_indicators()
  end)
end

return ShadeMan
