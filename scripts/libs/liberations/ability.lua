local PanelClass = require("scripts/libs/liberations/panel_class")
local Player = require("scripts/libs/liberations/player")
local Direction = require("scripts/libs/direction")

local function static_shape_generator(offset_x, offset_y, shape)
  return function()
    return shape, offset_x, offset_y
  end
end

---@type Liberation.Player.LootPanelsOptions
local PANEL_SEARCH_LOOT_OPTIONS = {
  destroy_traps = true
}

---@param player Liberation.Player
local function panel_search(player)
  local panels = player:selection():get_panels()

  Async.create_scope(function()
    player:selection():clear()
    Async.await(player:animate_search(panels))
    local total_loot = Async.await(player:loot_panels(panels, PANEL_SEARCH_LOOT_OPTIONS))

    if total_loot == 0 then
      Async.await(player:message_with_mug("I didn't find anything!"))
    end

    player:complete_turn()
  end)
end

---@param player Liberation.Player
---@param loot_options Liberation.Player.LootPanelsOptions?
local function battle_to_liberate_and_loot(player, loot_options)
  local instance = player:instance()
  local encounter_path = instance.default_encounter

  Async.create_scope(function()
    local battle_results = Async.await(player:initiate_encounter(encounter_path, {}))

    if battle_results.connection_failed then
      -- avoid ending this player's turn to allow them to retry
      player:unlock_movement()
      player:selection():clear()
      -- return order points
      if player.ability.cost then
        instance:add_order_points(player.ability.cost)
      end
    elseif battle_results.won then
      if battle_results.turns == 1 then
        player:selection():merge_bonus_shape()
      end

      -- Allow time for the player to see the liberation range
      Async.await(Async.sleep(1.5))

      local panels = player:selection():get_panels()
      Async.await(player:liberate_panels(panels, battle_results))
      Async.await(player:loot_panels(panels, loot_options))
      player:complete_turn()
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
---@field shadow_step? boolean
---@field init? fun(player: Liberation.Player)

---@class Liberation.ActiveAbility: Liberation.PassiveAbility
---@field question string
---@field cost number
---@field generate_shape fun(player: Liberation.Player): number[][], number, number
---@field activate fun(player: Liberation.Player)

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
  name = "KnightGuard",
  init = function(player)
    local swapped_player
    local swapped_position
    local swapped_direction
    local original_position
    local original_direction

    local relax = function()
      if not swapped_player then
        return
      end

      Net.animate_player_properties(player.id, {
        {
          properties = {
            { property = "X",         value = original_position.x, ease = "Ceil" },
            { property = "Y",         value = original_position.y, ease = "Ceil" },
            { property = "Z",         value = original_position.z, ease = "Ceil" },
            { property = "Direction", value = original_direction,  ease = "Ceil" },
          },
          duration = 1
        }
      })

      Net.animate_player_properties(swapped_player.id, {
        {
          properties = {
            { property = "X",         value = swapped_position.x, ease = "Ceil" },
            { property = "Y",         value = swapped_position.y, ease = "Ceil" },
            { property = "Z",         value = swapped_position.z, ease = "Ceil" },
            { property = "Direction", value = swapped_direction,  ease = "Ceil" },
          },
          duration = 1
        }
      })

      swapped_player = nil
    end

    ---@type Liberation.Player.Defense
    local defense = {
      priority = Player.DefensePriority.Last,
      prepare = function(attacker, targets)
        if #targets == 0 then
          return
        end

        for _, target in ipairs(targets) do
          if target == player then
            -- can't defend anyone if we're a target
            return
          end
        end

        -- find a player to defend
        local x, y, z = player:floored_position_multi()

        local swapped_index

        for i, target in ipairs(targets) do
          local target_x, target_y, target_z = target:floored_position_multi()

          if math.abs(target_x - x) <= 1 and math.abs(target_y - y) <= 1 and target_z == z and target.ability ~= Ability.KnightGuard then
            -- in range
            swapped_index = i
          end
        end

        if not swapped_index then
          -- no one to defend
          return
        end

        swapped_player = targets[swapped_index]
        swapped_position = swapped_player:position()
        swapped_direction = swapped_player:direction()
        original_position = player:position()
        original_direction = player:direction()

        local confront_direction = Direction.from_points(swapped_player:floored_position(), attacker:floored_position())

        local position_offset = Direction.vector(confront_direction)
        position_offset.x = position_offset.x * 0.25
        position_offset.y = position_offset.y * 0.25

        Net.animate_player_properties(player.id, {
          {
            properties = {
              -- jump in front
              { property = "X",         value = swapped_position.x + position_offset.x, ease = "Ceil" },
              { property = "Y",         value = swapped_position.y + position_offset.y, ease = "Ceil" },
              { property = "Z",         value = swapped_position.z,                     ease = "Ceil" },
              -- face the boss
              { property = "Direction", value = confront_direction,                     ease = "Ceil" },
            },
            duration = 1
          }
        })

        Net.animate_player_properties(swapped_player.id, {
          {
            properties = {
              -- move aside
              { property = "X",         value = swapped_position.x - position_offset.x, ease = "Ceil" },
              { property = "Y",         value = swapped_position.y - position_offset.y, ease = "Ceil" },
              { property = "Z",         value = swapped_position.z,                     ease = "Ceil" },
              -- retain old position
              { property = "Direction", value = swapped_direction,                      ease = "Ceil" },
            },
            duration = 1
          }
        })

        local new_targets = table.pack(table.unpack(targets))
        new_targets[swapped_index] = player
        return new_targets
      end,
      defend = function()
        return 0
      end,
      relax = relax,
      on_disconnect = relax
    }
    player:add_defense(defense)
  end
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
  name = "TomahawkSwing",
  question = "Want to chop around this area?",
  cost = 1,
  generate_shape = static_shape_generator(0, 0, {
    { 1, 1, 1 },
    { 1, 1, 1 },
  }),
  activate = battle_to_liberate_and_loot
})

Ability.register({
  name = "Napalm",
  question = "Use Napalm?",
  cost = 1,
  generate_shape = static_shape_generator(0, 0, {
    { 0, 1, 0 },
    { 0, 1, 0 },
    { 1, 1, 1 },
    { 0, 1, 0 },
  }),
  activate = function(player)
    battle_to_liberate_and_loot(player, { destroy_items = true, silent = true })
  end
})

Ability.register({
  name = "PanelSearch",
  question = "Search in this area?",
  cost = 1,
  generate_shape = function(player)
    local instance = player:instance()
    local shape = {}

    local root_panel = player:selection():root_panel()
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

      if not panel or panel.class == PanelClass.DARK_HOLE then
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
