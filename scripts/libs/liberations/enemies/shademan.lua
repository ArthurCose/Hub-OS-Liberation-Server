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
    rank = options.rank,
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
      Async.await(Async.sleep(0.5))

      for _, player in ipairs(self.instance.players) do
        player:message_auto(
          "Heh heh...let's party!",
          1.5,
          self.mug.texture_path,
          self.mug.animation_path
        )
      end

      -- allow time for the players to read this message
      Async.await(Async.sleep(3))

      return
    end

    local possible_targets = {}

    -- filter out players that we can't reach
    for _, player in ipairs(self.instance.players) do
      if player.health <= 0 then
        goto continue
      end

      local player_x, player_y, player_z = player:position_multi()

      if
          not self.instance:get_panel_at(player_x - 1, player_y, player_z) and
          not self.instance:get_panel_at(player_x + 1, player_y, player_z) and
          not self.instance:get_panel_at(player_x, player_y - 1, player_z) and
          not self.instance:get_panel_at(player_x, player_y + 1, player_z)
      then
        -- no dark panels nearby
        goto continue
      end

      local x_enemy = self.instance:get_enemy_at(player_x - 1, player_y, player_z)
      local y_enemy = self.instance:get_enemy_at(player_x, player_y - 1, player_z)

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
    for _, players in ipairs(self.instance.players) do
      Async.message_player_auto(players.id,
        "Don't underestimate\nthe Darkloids!",
        0.8,
        self.mug.texture_path,
        self.mug.animation_path
      )
    end

    Async.await(Async.sleep(2))

    -- resolve movement
    local warp_back_pos = { x = self.x, y = self.y, z = self.z }
    local warp_back_direction = self.direction
    local target_x, target_y = math.floor(player_position.x), math.floor(player_position.y)

    local x_enemy = self.instance:get_enemy_at(target_x - 1, target_y, player_position.z)
    local y_enemy = self.instance:get_enemy_at(target_x, target_y - 1, player_position.z)

    if not (x_enemy and x_enemy ~= self) and ((y_enemy and y_enemy ~= self) or math.random(2) == 1) then
      target_x = target_x - 1
    else
      target_y = target_y - 1
    end

    local moving = target_x ~= self.x or target_y ~= self.y

    if moving then
      local target_direction = Direction.diagonal_from_offset(
        player_position.x - target_x,
        player_position.y - target_y
      )

      Async.await(EnemyHelpers.move(self.instance, self, target_x, target_y, player_position.z, target_direction))
    else
      EnemyHelpers.face_position(self, player_position.x, player_position.y)
    end

    -- indicate and attack
    self.selection:move(player_position, Direction.None)
    self.selection:indicate()

    EnemyHelpers.play_attack_animation(self)

    Async.await(Async.sleep(.2))

    player:hurt(self.damage)

    Async.await(Async.sleep(.5))

    if moving then
      -- warp back
      Async.await(
        EnemyHelpers.move(
          self.instance,
          self,
          warp_back_pos.x,
          warp_back_pos.y,
          warp_back_pos.z,
          warp_back_direction
        )
      )
    else
      Net.set_bot_direction(self.id, self.direction)
      EnemyHelpers.play_idle_animation(self)
    end

    self.selection:remove_indicators()
  end)
end

return ShadeMan
