local PanelType = require("scripts/libs/liberations/panel_type")
local Direction = require("scripts/libs/direction")

local function static_shape_generator(offset_x, offset_y, shape)
  return function()
    return shape, offset_x, offset_y
  end
end

---@param instance Liberation.MissionInstance
---@param player Liberation.Player
---@param results Liberation.BattleResults?
local function liberate_and_loot(instance, player, results)
  if not results then
    results = {
      won = true,
      turns = 3,
      connection_failed = false
    }
  end

  if results and results.turns == 1 then
    player.selection:merge_bonus_shape()
  end

  Async.create_scope(function()
    local panels = player.selection:get_panels()
    Async.await(player:liberate_panels(panels, results))
    Async.await(player:loot_panels(panels))
    player:complete_turn()
  end)
end

---@type Liberation.Player.LootPanelsOptions
local PANEL_SEARCH_LOOT_OPTIONS = {
  remove_traps = true
}

---@param instance Liberation.MissionInstance
---@param player Liberation.Player
local function panel_search(instance, player)
  local panels = player.selection:get_panels()

  Async.create_scope(function()
    player.selection:clear()
    Async.await(player:animate_search(panels))
    local total_loot = Async.await(player:loot_panels(panels, PANEL_SEARCH_LOOT_OPTIONS))

    if total_loot == 0 then
      Async.await(player:message_with_mug("I didn't find anything!"))
    end

    player:complete_turn()
  end)
end

---@param instance Liberation.MissionInstance
---@param player Liberation.Player
local function battle_to_liberate_and_loot(instance, player)
  local encounter_path = instance.default_encounter

  player:initiate_encounter(encounter_path, {}).and_then(function(battle_results)
    if battle_results.connection_failed then
      -- avoid ending this player's turn to allow them to retry
      player:unlock_movement()
      player.selection:clear()
      -- return order points
      instance:add_order_points(1)
    elseif battle_results.won then
      liberate_and_loot(instance, player, battle_results)
    else
      Async.sleep(1).and_then(function()
        player:complete_turn()
      end)
    end
  end)
end

---@alias Liberation.Ability Liberation.ActiveAbility | Liberation.PassiveAbility

---@class Liberation.PassiveAbility
---@field name string

---@class Liberation.ActiveAbility
---@field name string
---@field question string Missing a question turns this ability into a passive
---@field cost number
---@field shadow_step? boolean
---@field generate_shape fun(instance: Liberation.MissionInstance, player: Liberation.Player): number[][], number, number
---@field activate fun(instance: Liberation.MissionInstance, player: Liberation.Player)

---@type table<string, Liberation.Ability>
local Ability = {
  ---@type Liberation.Ability[]
  ALL = {}
}

---@type fun(ability: Liberation.Ability)
Ability.register = function(ability)
  Ability.ALL[#Ability.ALL + 1] = ability
  Ability[ability.name] = ability
end

-- passive, knightman's ability
Ability.register({
  name = "Guard"
})

Ability.register({
  name = "ShadowStep",
  shadow_step = true
})

Ability.register({
  name = "LongSwrd",
  question = "Use LongSwrd?",
  cost = 1,
  generate_shape = static_shape_generator(0, 0, {
    { 1 },
    { 1 }
  }),
  activate = battle_to_liberate_and_loot
})

Ability.register({
  name = "WideSwrd",
  question = "Use WideSwrd?",
  cost = 1,
  generate_shape = static_shape_generator(0, 0, {
    { 1, 1, 1 },
  }),
  activate = battle_to_liberate_and_loot
})

Ability.register({
  name = "PanelSearch",
  question = "Search in this area?",
  cost = 1,
  generate_shape = function(instance, player)
    local shape = {}

    local root_panel = player.selection:root_panel()
    local player_x, player_y = player:position_multi()

    local direction = Direction.diagonal_from_offset(
      root_panel.x - math.floor(player_x),
      root_panel.y - math.floor(player_y)
    )

    local x_step, y_step = Direction.vector_multi(direction)

    if x_step == 0 and y_step == 0 then
      warn("Failed to resolve direction for PanelSearch")
      return shape, 0, 0
    end

    local x = root_panel.x
    local y = root_panel.y
    local z = root_panel.z

    while true do
      local panel = instance:get_panel_at(x, y, z)

      if not panel or panel.type == PanelType.DARK_HOLE then
        break
      end

      if instance:get_enemy_at(x, y, z) then
        break
      end

      shape[#shape + 1] = { 1 }

      x = x + x_step
      y = y + y_step
    end

    return shape, 0, 0
  end,
  activate = panel_search
})

Ability.register({
  name = "NumberCheck",
  question = "Remove traps and get items?",
  cost = 1,
  generate_shape = static_shape_generator(0, 0, {
    { 1, 1, 1 },
    { 1, 1, 1 },
  }),
  activate = panel_search
})

return Ability
