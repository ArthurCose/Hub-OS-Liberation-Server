local AttackSelection = require("scripts/libs/liberations/selections/attack_selection")
local Preloader = require("scripts/libs/liberations/preloader")
local PanelClass = require("scripts/libs/liberations/panel_class")
local TileHasher = require("scripts/libs/tile_hasher")
local Direction = require("scripts/libs/direction")

local BLUR_SFX = Preloader.add_asset("/server/assets/liberations/sounds/move.ogg")
local DARK_SFX = Preloader.add_asset("/server/assets/sounds/darkhole.ogg")

---@class LiberationServer.CustomEnemies.Colonel: Liberation.EnemyAi
---@field damage number
---@field selection Liberation.AttackSelection
---@field is_engaged boolean
local Colonel = {}

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

local mob_health = { 400, 1200, 1800, 2000 }
local mob_damage = { 30, 120, 140, 200 }

---@param builder Liberation.EnemyBuilder
function Colonel:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type LiberationServer.CustomEnemies.Colonel
  local colonel = {
    damage = mob_damage[rank_index],
    selection = AttackSelection:new(builder.instance),
    is_engaged = false
  }

  setmetatable(colonel, self)
  self.__index = self

  local shape = {
    { 1, 1, 1 },
    { 1, 0, 1 },
    { 1, 1, 1 }
  }

  colonel.selection:set_shape(shape, 0, -2)

  return builder:build({
    ai = colonel,
    name = "Colonel",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/colonel.png",
    animation_path = "/server/assets/liberations/bots/colonel.animation",
    mug = {
      texture_path = "/server/assets/liberations/mugs/colonel.png",
      animation_path = "/server/assets/liberations/mugs/colonel.animation",
    },
  })
end

local BANTER_LINES = {
  {
    "You look familiar",
    "to me. Why am I so",
    "nervous...?",
  },
  {
    "Why? What is this?",
    "Why do I",
    "hesitate?!",
  },
  {
    "Master Regal is",
    "the one I serve!",
  },
  {
    "Master granted me",
    "my DarkPower.",
    "",

    "Now I get the",
    "chance to try it!",
  }
}

---@param actor Liberation.Enemy
---@param player Liberation.Player
function Colonel:banter(actor, player)
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
  "This is nonsense!",
  "I'm the superior",
  "Navi here...!",

  "So this is the",
  "\"power of justice\"...",
}

function Colonel:get_final_message()
  return table.concat(FINAL_LINES, "\n")
end

local ENTRANCE_LINES = {
  {
    "..."
  },
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

---@param instance Liberation.MissionInstance
---@param targets Liberation.Player[]
---@param tile_x number
---@param tile_y number
---@param tile_z number
---@param split_by_x boolean
local function divide_players(instance, targets, tile_x, tile_y, tile_z, split_by_x)
  local function tile_gid_at(x, y, z)
    return Net.get_tile(instance.area_id, x, y, z).gid
  end

  -- acts as toggles + can nullify operations
  local x_split = 0
  local y_split = 0

  if split_by_x then
    x_split = 1
  else
    y_split = 1
  end

  local top_panel = instance:get_panel_at(tile_x - x_split, tile_y - y_split, tile_z)
  local bottom_panel = instance:get_panel_at(tile_x + x_split, tile_y + y_split, tile_z)

  local top_walkable = not top_panel and tile_gid_at(tile_x, tile_y - 1, tile_z) ~= 0
  local bottom_walkable = not bottom_panel and tile_gid_at(tile_x, tile_y + 1, tile_z) ~= 0

  for _, target in ipairs(targets) do
    local x, y, z = target:position_multi()
    local diff =
        (x - tile_x) * x_split +
        (y - tile_y) * y_split

    local move_multiplier = 0

    if diff < 0.5 and diff >= 0 and top_walkable then
      move_multiplier = -1
    elseif diff >= 0.5 and diff <= 1 and bottom_walkable then
      move_multiplier = 1
    end

    move_multiplier = move_multiplier * 0.6

    Net.animate_actor_properties(target.id, {
      {
        properties = {
          { property = "X", value = x + x_split * move_multiplier, ease = "Linear" },
          { property = "Y", value = y + y_split * move_multiplier, ease = "Linear" },
        },
        duration = 0.2
      }
    })
  end
end

---@param actor Liberation.Enemy
function Colonel:take_turn(actor)
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
      "ScreenDivide.",
      1.5,
      actor.mug.texture_path,
      actor.mug.animation_path
    ))

    self.selection:remove_indicators()

    -- group caught players by tile
    local hasher = TileHasher:from_area(instance.area_id)
    local players_by_tile = {}

    for _, player in ipairs(caught_players) do
      local hash = hasher:hash(player:floored_position_multi())
      local list = players_by_tile[hash]

      if not list then
        list = {}
        players_by_tile[hash] = list
      end

      list[#list + 1] = player
    end

    -- find the tile with the most players
    local target_x, target_y, target_z
    local players_in_tile = {}

    for hash, list in pairs(players_by_tile) do
      if #players_in_tile < #list then
        players_in_tile = list
        target_x, target_y, target_z = hasher:decode(hash)
      end
    end

    actor:attack(players_in_tile, function(targets)
      local original_direction = Net.get_actor_direction(actor.id)

      Async.await(Async.sleep(.5))

      -- slash
      actor:face_position(target_x + .5, target_y + .5)
      actor:play_attack_animation()

      Async.await(Async.sleep(.2))

      for _, target in ipairs(targets) do
        target:hurt(self.damage)
      end

      -- move players
      local actor_x, actor_y = actor:floored_position_multi()
      local target_direction = Direction.from_offset(target_x - actor_x, target_y - actor_y)

      if target_direction == Direction.UP_LEFT or target_direction == Direction.DOWN_RIGHT then
        divide_players(instance, targets, target_x, target_y, target_z, false)
      elseif target_direction == Direction.UP_RIGHT or target_direction == Direction.DOWN_LEFT then
        divide_players(instance, targets, target_x, target_y, target_z, true)
      end

      -- dramatic pause, and give time to move players
      Async.await(Async.sleep(1))

      -- try to summon dark panels
      local summon_dark_panel = true

      if #instance.players < 2 then
        -- fail if there's less than two players to avoid stalling
        summon_dark_panel = false
      else
        for _, player in ipairs(instance.players) do
          local x, y, z = player:floored_position_multi()

          if x == target_x and y == target_y and z == target_z then
            summon_dark_panel = false
            break
          end
        end
      end

      -- summon dark panels
      if summon_dark_panel then
        Net.set_actor_direction(actor.id, Direction.DOWN_LEFT)
        actor:play_idle_animation()
        Async.await(Async.sleep(0.75))

        Net.animate_actor(actor.id, "OPEN_HAND_DL")
        Async.await(Async.sleep(0.2))

        Net.play_sound(instance.area_id, DARK_SFX)
        Async.await(Async.sleep(0.05))

        instance:generate_panel(PanelClass.DARK, target_x, target_y, target_z)
        Async.await(Async.sleep(1))
      end

      -- return to idle
      Net.set_actor_direction(actor.id, original_direction)
      actor:play_idle_animation()

      if summon_dark_panel then
        Async.await(Async.sleep(1))
      end
    end)
  end)
end

return Colonel
