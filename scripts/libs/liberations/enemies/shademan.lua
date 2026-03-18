local EnemySelection = require("scripts/libs/liberations/selections/enemy_selection")
local EnemyHelpers = require("scripts/libs/liberations/enemy_helpers")
local Direction = require("scripts/libs/direction")

---@class Liberation.Enemies.ShadeMan: Liberation.Enemy
---@field instance Liberation.MissionInstance
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
local mob_damage = { 60, 90, 120, 200 }
local mob_ranks = { "V1", "Alpha", "Beta", "V1" }

---@param options Liberation.EnemyOptions
---@return Liberation.Enemies.ShadeMan
function ShadeMan:new(options)
  local rank_index = rank_to_index[options.rank]

  local shademan = {
    instance = options.instance,
    id = nil,
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    damage = mob_damage[rank_index],
    rank = mob_ranks[rank_index],
    x = math.floor(options.position.x),
    y = math.floor(options.position.y),
    z = math.floor(options.position.z),
    direction = options.direction,
    mug = {
      texture_path = "/server/assets/liberations/mugs/shademan.png",
      animation_path = "/server/assets/liberations/mugs/shademan.animation",
    },
    encounter = options.encounter,
    selection = EnemySelection:new(options.instance),
    is_engaged = false
  }

  setmetatable(shademan, self)
  self.__index = self

  local shape = {
    { 1 }
  }

  shademan.selection:set_shape(shape, 0, -1)
  shademan:spawn(options.direction)

  return shademan
end

function ShadeMan:spawn(direction)
  self.id = Net.create_bot({
    texture_path = "/server/assets/liberations/bots/shademan.png",
    animation_path = "/server/assets/liberations/bots/shademan.animation",
    area_id = self.instance.area_id,
    direction = direction,
    warp_in = false,
    x = self.x + .5,
    y = self.y + .5,
    z = self.z
  })
  Net.set_bot_map_color(self.id, EnemyHelpers.BOSS_MINIMAP_COLOR)
end

function ShadeMan:get_death_message()
  return "Grr! I can't\nbelieve I've been\ndisgraced again...!\nGyaaaahh!!"
end

function ShadeMan:banter(player_id)
  return Async.create_scope(function()
    if self.is_engaged then
      return
    end

    self.is_engaged = true

    Async.await(Async.message_player(player_id, "Your deletion will be delicious!", self.mug.texture_path,
      self.mug.animation_path))
  end)
end

function ShadeMan:take_turn()
  return Async.create_scope(function()
    if self.instance.phase == 1 then
      for _, player in ipairs(self.instance.players) do
        player:message_auto(
          "Heh heh...let's party!",
          2,
          self.mug.texture_path,
          self.mug.animation_path
        )
      end

      -- Allow time for the players to read this message
      Async.await(Async.sleep(3))
    end

    local player = EnemyHelpers.find_closest_player(self.instance, self, 10)

    if not player then
      --No player. Don't bother.
      return
    end

    local player_position = player:position()

    -- local distance = EnemyHelpers.chebyshev_tile_distance(self, player_position.x, player_position.y, player_position.z)
    -- if distance > 10 then return end --Player too far. Don't bother.
    self.selection:move(player_position, Direction.None)

    --Message all players.
    for _, players in ipairs(self.instance.players) do
      Async.message_player(players.id,
        "Don't underestimate\nthe Darkloids!",
        self.mug.texture_path,
        self.mug.animation_path
      )
    end

    Async.await(Async.sleep(0.7))


    local warp_back_pos = { x = self.x, y = self.y, z = self.z }
    local warp_back_direction = self.direction
    local targetx = player_position.x
    local targety = player_position.y - 1
    local target_direction = Direction.diagonal_from_offset(
      player_position.x - (targetx + .5),
      player_position.y - (targety + .5)
    )

    Async.await(EnemyHelpers.move(self.instance, self, targetx, targety, player_position.z, target_direction))

    self.selection:indicate()

    EnemyHelpers.play_attack_animation(self)
    player:hurt(self.damage)

    Async.await(Async.sleep(.7))

    Async.await(EnemyHelpers.move(self.instance, self, warp_back_pos.x, warp_back_pos.y, warp_back_pos.z,
      warp_back_direction))

    self.selection:remove_indicators()
  end)
end

return ShadeMan
