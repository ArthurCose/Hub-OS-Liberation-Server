local function static_shape_generator(offset_x, offset_y, shape)
  return function()
    return shape, offset_x, offset_y
  end
end

---@param instance Liberation.MissionInstance
---@param player Liberation.Player
---@param results Liberation.BattleResults
local function liberate_and_loot(instance, player, results)
  local remove_traps, destroy_items = player.ability.remove_traps, player.ability.destroy_items
  local panels = player.selection:get_panels()

  player:liberate_and_loot_panels(panels, results, remove_traps, destroy_items).and_then(function()
    player:complete_turn()
  end)
end

---@param instance Liberation.MissionInstance
---@param player Liberation.Player
local function panel_search(instance, player)
  local remove_traps, destroy_items = player.ability.remove_traps, player.ability.destroy_items
  local panels = player.selection:get_panels()

  player:loot_panels(panels, remove_traps, destroy_items).and_then(function()
    player:complete_turn()
  end)
end

---@param instance Liberation.MissionInstance
---@param player Liberation.Player
local function initiate_encounter(instance, player)
  local data = {
    terrain = player:resolve_terrain(),
    start_invincible = player.invincible,
    spectators = {}
  }

  local encounter_path = instance.default_encounter

  return player:initiate_encounter(encounter_path, data)
end

local function battle_to_liberate_and_loot(instance, player)
  initiate_encounter(instance, player).and_then(function(battle_results)
    if battle_results.won then
      liberate_and_loot(instance, player, battle_results)
    else
      player:complete_turn()
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
---@field remove_traps? boolean
---@field destroy_items? boolean
---@field generate_shape fun(instance: Liberation.MissionInstance, player: Liberation.Player): boolean[][], number, number
---@field activate fun(instance: Liberation.MissionInstance, player: Liberation.Player)

local Ability = {
  -- passive, knightman's ability:
  Guard = { name = "Guard" },
  -- passive, Shadowman's ability:
  ShadowStep = {
    name = "ShadowStep",
    shadow_step = true
  },
  LongSwrd = {
    name = "LongSwrd",
    question = "Use LongSwrd?",
    cost = 1,
    generate_shape = static_shape_generator(0, 0, {
      { 1 },
      { 1 }
    }),
    activate = battle_to_liberate_and_loot
  },
  WideSwrd = {
    name = "WideSwrd",
    question = "Use WideSwrd?",
    cost = 1,
    generate_shape = static_shape_generator(0, 0, {
      { 1, 1, 1 },
    }),
    activate = battle_to_liberate_and_loot
  },
  GutsWave = {
    name = "GutsWave",
    question = "Destroy with GutsWave?",
    cost = 2,
    destroy_items = true,
    generate_shape = static_shape_generator(0, 0, {
      { 1 },
      { 1 },
      { 1 },
      { 1 },
      { 1 }
    }),
    activate = liberate_and_loot
  },
  ScrenDiv = {
    name = "ScrenDiv",
    question = "Use ScrenDiv to liberate?",
    cost = 3,
    generate_shape = static_shape_generator(0, 0, {
      { 1, 0, 1 },
      { 0, 1, 0 },
      { 1, 0, 1 }
    }),
    activate = battle_to_liberate_and_loot
  },
  PanelSearch = {
    name = "PanelSearch",
    question = "Search in this area?",
    cost = 1,
    remove_traps = true,
    -- todo: this should stretch to select all item panels in a line with dark panels between?
    generate_shape = static_shape_generator(0, 0, {
      { 0, 1, 0 },
      { 0, 1, 0 },
      { 1, 1, 1 },
      { 0, 1, 0 },
    }),
    activate = panel_search
  },
  NumberSearch = {
    name = "NumberSearch",
    question = "Remove traps & get items?",
    cost = 1,
    remove_traps = true,
    generate_shape = static_shape_generator(0, 0, {
      { 1, 1, 1 },
      { 1, 1, 1 },
    }),
    activate = panel_search
  },
  -- Extra
  HexSickle = {
    name = "HexSickle",
    question = "Should I cut panels with HexSickle?",
    cost = 1,
    remove_traps = true,
    generate_shape = static_shape_generator(0, 1, {
      { 1, 1, 1 }
    }),
    activate = battle_to_liberate_and_loot
  },
}

---@type Liberation.Ability[]
Ability.ALL = {}

for _, ability in pairs(Ability) do
  Ability.ALL[#Ability.ALL + 1] = ability
end

return Ability
