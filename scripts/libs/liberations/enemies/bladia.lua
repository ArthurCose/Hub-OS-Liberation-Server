local EnemySelection = require("scripts/libs/liberations/selections/enemy_selection")
local PanelClass = require("scripts/libs/liberations/panel_class")
local Direction = require("scripts/libs/direction")

---@class Liberation.Enemies.Bladia: Liberation.EnemyAi
---@field damage number
---@field selection Liberation.EnemySelection
local Bladia = {}

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

local mob_health = { 200, 230, 230, 300, 340, 400 }
local mob_damage = { 50, 80, 120, 160, 200, 250 }

---@param builder Liberation.EnemyBuilder
function Bladia:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type Liberation.Enemies.Bladia
  local bladia = {
    damage = mob_damage[rank_index],
    selection = EnemySelection:new(builder.instance)
  }

  setmetatable(bladia, self)
  self.__index = self

  local shape = {
    { 1 }
  }

  bladia.selection:set_shape(shape, 0, -1)

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

---@param actor Liberation.Enemy
function Bladia:take_turn(actor)
  return Async.create_scope(function()
    local player = actor:find_closest_player(5)
    if not player then return end --No player. Don't bother.

    local instance = actor:instance()

    local player_x, player_y, player_z = player:position_multi()

    -- local distance = EnemyHelpers.chebyshev_tile_distance(self, player_x, player_y, player_z)
    -- if distance > 5 then return end --Player too far. Don't bother.
    self.selection:move(player_x, player_y, player_z, Direction.None)
    local targetx = player_x
    local targety = player_y
    local original_coordinates = { x = targetx, y = targety, z = player_z }
    local tile_to_check = Net.get_tile(instance.area_id, targetx, targety, player_z)

    --Helper function to return if we can move to this tile or not
    local function coordinate_check(checkx, checky)
      if checkx == original_coordinates.x and checky == original_coordinates.y then
        return true
      end
      return false
    end

    local function panel_check(checkx, checky)
      local spare_object = instance:get_panel_at(checkx, checky, player_z)

      if not spare_object then return false end --No panel, return false, can warp

      if actor:can_move_to(spare_object.x, spare_object.y, spare_object.z) then
        return false --can warp
      end

      return true --cannot warp
    end

    if not tile_to_check then return end --No tile, return.
    --Check initial tile location.
    if tile_to_check.gid == 0 or coordinate_check(targetx, targety) or panel_check(targetx, targety) then
      targetx = original_coordinates.x
      targety = original_coordinates.y + 1
    end

    --Reacquire the tile with new coordinates.
    tile_to_check = Net.get_tile(instance.area_id, targetx, targety, player_z)
    if not tile_to_check then return end --No tile, return.
    if tile_to_check.gid == 0 or coordinate_check(targetx, targety) or panel_check(targetx, targety) then
      targetx = original_coordinates.x
      targety = original_coordinates.y - 1
    end

    --Reacquire the tile with new coordinates.
    tile_to_check = Net.get_tile(instance.area_id, targetx, targety, player_z)
    if not tile_to_check then return end --No tile, return.
    if tile_to_check.gid == 0 or coordinate_check(targetx, targety) or panel_check(targetx, targety) then
      targety = original_coordinates.y
      targetx = original_coordinates.x + 1
    end

    --Reacquire the tile with new coordinates.
    tile_to_check = Net.get_tile(instance.area_id, targetx, targety, player_z)
    if not tile_to_check then return end --No tile, return.
    if tile_to_check.gid == 0 or coordinate_check(targetx, targety) or panel_check(targetx, targety) then
      targety = original_coordinates.y
      targetx = original_coordinates.x - 1
    end

    tile_to_check = Net.get_tile(instance.area_id, targetx, targety, player_z)
    if not tile_to_check then return end --No tile, return.
    if tile_to_check.gid == 0 or coordinate_check(targetx, targety) or panel_check(targetx, targety) then
      return                             --We can't move anywhere safe. Return.
    end

    --Get the direction to face.
    local target_direction = Direction.diagonal_from_offset((player_x - targetx), (player_y - targety))

    Async.await(actor:move(targetx, targety, player_z, target_direction))
    if not instance:get_panel_at(targetx, targety, player_z) then
      local x = math.floor(targetx)
      local y = math.floor(targety)
      local z = math.floor(player_z)

      instance:generate_panel(PanelClass.DARK, x, y, z)

      --Hold for half a second to spawn the tile.
      Async.await(Async.sleep(.5))
    end
    --Indicate the attack range.
    self.selection:indicate()

    actor:attack({ player }, function(targets)
      actor:play_attack_animation()

      for _, target in targets do
        target:hurt(self.damage)
      end

      Async.await(Async.sleep(.7))
    end)

    --Remove the indicator.
    self.selection:remove_indicators()
  end)
end

return Bladia
