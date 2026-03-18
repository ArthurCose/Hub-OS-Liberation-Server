local PlayerSelection = require("scripts/libs/liberations/selections/player_selection")
local Loot = require("scripts/libs/liberations/loot")
local EnemyHelpers = require("scripts/libs/liberations/enemy_helpers")
local ParalysisEffect = require("scripts/libs/liberations/effects/paralysis_effect")
local RecoverEffect = require("scripts/libs/liberations/effects/recover_effect")
local PanelType = require("scripts/libs/liberations/panel_type")
local Emotes = require("scripts/libs/emotes")

---@class Liberation.Player
---@field instance Liberation.MissionInstance
---@field id Net.ActorId
---@field health number
---@field max_health number
---@field paralysis_effect Liberation.ParalysisEffect?
---@field paralysis_counter number
---@field emote_delay number
---@field order_points_sprite_id Net.SpriteId?
---@field invincible boolean
---@field completed_turn boolean
---@field selection Liberation.PlayerSelection
---@field ability Liberation.Ability?
---@field input_locked boolean
---@field disconnected boolean
local Player = {}

---@param instance Liberation.MissionInstance
---@param player_id Net.ActorId
---@return Liberation.Player
function Player:new(instance, player_id)
  local player = {
    instance = instance,
    id = player_id,
    health = 100,
    max_health = 100,
    paralysis_effect = nil,
    paralysis_counter = 0,
    emote_delay = 0,
    order_points_sprite_id = nil,
    invincible = false,
    completed_turn = false,
    selection = PlayerSelection:new(instance, player_id),
    ability = nil,
    input_locked = false,
    disconnected = false,
  }

  setmetatable(player, self)
  self.__index = self
  return player
end

function Player:emote_state()
  if Net.is_player_battling(self.id) then
    -- the client will send emotes for this
  elseif self.completed_turn then
    Net.set_player_emote(self.id, Emotes.GREEN_CHECK)
  elseif self.invincible then
    Net.set_player_emote(self.id, "HORSE")
  else
    -- clear emote
    Net.set_player_emote(self.id, "")
  end

  self.emote_delay = 1
end

function Player:update_order_points_hud()
  if self.order_points_sprite_id then
    Net.animate_sprite(self.order_points_sprite_id, tostring(self.instance.order_points))
  else
    self.order_points_sprite_id = Net.create_sprite({
      parent_id = "hud",
      texture_path = "/server/assets/liberations/ui/order_points.png",
      animation_path = "/server/assets/liberations/ui/order_points.animation",
      animation = tostring(self.instance.order_points)
    })
  end
end

function Player:position()
  return Net.get_player_position(self.id)
end

function Player:position_multi()
  return Net.get_player_position_multi(self.id)
end

function Player:lock_input()
  if not self.input_locked then
    Net.lock_player_input(self.id)
    self.input_locked = true
  end
end

function Player:unlock_input()
  if self.input_locked then
    Net.unlock_player_input(self.id)
    self.input_locked = false
  end
end

---@param message string
---@param texture_path? string
---@param animation_path? string
function Player:message(message, texture_path, animation_path)
  return Async.message_player(self.id, message, texture_path, animation_path)
end

---@param message string
---@param close_delay number
---@param texture_path? string
---@param animation_path? string
function Player:message_auto(message, close_delay, texture_path, animation_path)
  return Async.message_player_auto(self.id, message, close_delay, texture_path, animation_path)
end

---@param message string
function Player:message_with_mug(message)
  local mug = Net.get_player_mugshot(self.id)
  return self:message(message, mug.texture_path, mug.animation_path)
end

---@param question string
---@param texture_path? string
---@param animation_path? string
function Player:question(question, texture_path, animation_path)
  return Async.question_player(self.id, question, texture_path, animation_path)
end

---@param question string
function Player:question_with_mug(question)
  local mug = Net.get_player_mugshot(self.id)
  return self:question(question, mug.texture_path, mug.animation_path)
end

---@param a string
---@param b? string
---@param c? string
---@param texture_path? string
---@param animation_path? string
function Player:quiz(a, b, c, texture_path, animation_path)
  return Async.quiz_player(self.id, a, b, c, texture_path, animation_path)
end

function Player:get_ability_permission()
  local question_promise = self:question_with_mug(self.ability.question)

  question_promise.and_then(function(response)
    if response == 0 then
      -- No
      self.selection:clear()
      self:unlock_input()
      return
    end

    -- Yes
    if self.instance.order_points < self.ability.cost then
      -- not enough order points
      self:message("Not enough Order Pts!")
      return
    end

    self.instance.order_points = self.instance.order_points - self.ability.cost

    for _, p in ipairs(self.instance.players) do
      p:update_order_points_hud()
    end

    self.ability.activate(self.instance, self)
  end)
end

function Player:get_pass_turn_permission()
  local question = "End without doing anything?"

  if self.health < self.max_health then
    question = "Recover HP?"
  end

  local question_promise = self:question_with_mug(question)

  question_promise.and_then(function(response)
    if response == 0 then
      -- No
      self:unlock_input()
    elseif response == 1 then
      -- Yes
      self:pass_turn()
    end
  end)
end

local corner_offsets = {
  { 1,  -1 },
  { 1,  1 },
  { -1, -1 },
  { -1, 1 },
}

function Player:resolve_terrain()
  local function has_dark_panel(x, y, z)
    local panel = self.instance:get_panel_at(x, y, z)

    return panel and PanelType.TERRAIN[panel.type]
  end

  local x, y, z = self:position_multi()
  local x_left = has_dark_panel(x - 1, y, z)
  local x_right = has_dark_panel(x + 1, y, z)
  local y_left = has_dark_panel(x, y - 1, z)
  local y_right = has_dark_panel(x, y + 1, z)

  if (x_left and x_right) or (y_left and y_right) then
    return "surrounded"
  end

  if (x_left or x_right) and (y_left or y_right) then
    return "disadvantage"
  end

  for _, offset in ipairs(corner_offsets) do
    if has_dark_panel(x + offset[1], y + offset[2], z) then
      return "even"
    end
  end

  return "advantage"
end

---@return Net.Promise<Liberation.BattleResults>, Net.EventEmitter
function Player:initiate_encounter(encounter_path, data)
  -- rally teammates
  local x, y, z = self:position_multi()
  x, y, z = math.floor(x), math.floor(y), math.floor(z)

  local player_ids = { self.id }
  local spectator_map = {}

  for _, player in ipairs(self.instance.players) do
    if player == self then
      -- already included
      goto continue
    end

    if not Net.is_player(player.id) or Net.is_player_busy(player.id) then
      -- disconnected and pending removal, or just busy
      goto continue
    end

    if player.completed_turn then
      -- include as a spectator
      data.spectators[#player_ids] = true
      spectator_map[player.id] = true
      player_ids[#player_ids + 1] = player.id
      goto continue
    end

    if Net.is_player_input_locked(player.id) then
      goto continue
    end

    local other_x, other_y, other_z = player:position_multi()

    if x == math.floor(other_x) and y == math.floor(other_y) and z == math.floor(other_z) then
      player_ids[#player_ids + 1] = player.id
      -- spend a turn on co-op
      player:complete_turn()
    end

    ::continue::
  end

  -- begin encounter
  local emitter = Net.initiate_netplay(player_ids, encounter_path, data)

  local expected_result_events = #player_ids
  local result_events = 0

  local promise = Async.create_promise(function(resolve)
    local final_result = { won = false, turns = 0 }

    emitter:on("battle_results", function(results)
      if results ~= nil and not spectator_map[results.player_id] then
        -- contribute to final result
        final_result.won = final_result.won or results.won
        final_result.turns = math.max(final_result.turns, results.turns)

        -- update player
        local results_player = self.instance.player_map[results.player_id]

        results_player.health = results.health
        Net.set_player_health(results_player.id, results.health)
        Net.set_player_emotion(results_player.id, results.emotion)

        if results.health == 0 then
          results_player:paralyze()
        end
      end

      -- resolve final result
      result_events = result_events + 1

      if expected_result_events == result_events then
        resolve(final_result)
      end
    end)
  end)

  return promise, emitter
end

function Player:heal(amount)
  return Async.create_promise(function(resolve)
    local previous_health = self.health

    self.health = math.min(math.ceil(self.health + amount), self.max_health)

    Net.set_player_health(self.id, self.health)

    if previous_health < self.health then
      RecoverEffect:new(self.id)
    end

    return resolve(Async.sleep(0.5))
  end)
end

function Player:hurt(amount)
  if self.invincible or self.health == 0 or amount <= 0 then
    return
  end

  Net.play_sound_for_player(self.id, "/server/assets/liberations/sound effects/hurt.ogg")

  self.health = math.max(math.ceil(self.health - amount), 0)

  Net.set_player_health(self.id, self.health)

  if self.health == 0 then
    Async.sleep(1).and_then(function()
      self:paralyze()
    end)
  end
end

function Player:paralyze()
  self.paralysis_counter = 2
  self.paralysis_effect = ParalysisEffect:new(self.id)
end

function Player:pass_turn()
  -- heal up to 50% of health
  Async.await(self:heal(self.max_health / 2)).and_then(function()
    self:complete_turn()
  end)
end

function Player:complete_turn()
  if self.disconnected then
    return
  end

  self.completed_turn = true
  self.selection:clear()

  self:emote_state()

  if self.instance.ready_count < #self.instance.players then
    Net.unlock_player_camera(self.id)
  end

  self.instance.ready_count = self.instance.ready_count + 1
end

function Player:give_turn()
  self.invincible = false

  if self.paralysis_counter > 0 then
    self.paralysis_counter = self.paralysis_counter - 1

    if self.paralysis_counter > 0 then
      -- still paralyzed
      self:complete_turn()
      return
    end

    -- release
    self.paralysis_effect:remove()
    self.paralysis_effect = nil

    -- heal 50% so we don't just start battles with 0 lol
    if self.health == 0 then
      self:heal(self.max_health / 2)
    end
  end

  self.completed_turn = false
  self:unlock_input()
end

function Player:find_closest_guardian()
  local closest_guardian
  local closest_distance = math.huge

  local x, y, z = self:position_multi()

  for _, enemy in ipairs(self.instance.enemies) do
    if self.instance.boss == enemy then
      goto continue
    end

    local distance = EnemyHelpers.chebyshev_tile_distance(enemy, x, y, z)

    if distance < closest_distance then
      closest_distance = distance
      closest_guardian = enemy
    end

    ::continue::
  end

  return closest_guardian
end

---@class Liberation.BattleResults
---@field won boolean
---@field turns number

---@param results Liberation.BattleResults
function Player:liberate_panels(panels, results)
  return Async.create_scope(function()
    -- Allow time for the player to see the liberation range
    Async.await(Async.sleep(2))

    for _, panel in ipairs(panels) do
      self.instance:remove_panel(panel)
    end

    -- If the results do not exist, notify the player of the issue to start a bug report.
    if results == nil then
      Async.await(self:message_with_mug("Something's wrong!\nThere's no results!")).and_then(function()
        Async.await(self:message_with_mug("Please report this!"))
      end)
    else
      -- Message based on the results.
      if not results.won then
        Async.await(self:message_with_mug("Oh, no!\nLiberation failed!"))
      elseif results.turns == 1 then
        Async.await(self:message_with_mug("One turn liberation!"))
      else
        Async.await(self:message_with_mug("Yeah!\nI liberated it!"))
      end
    end
  end)
end

-- returns a promise that resolves after looting
function Player:loot_panels(panels, remove_traps, destroy_items)
  return Async.create_scope(function()
    for _, panel in ipairs(panels) do
      if panel.loot then
        -- loot the panel if it has loot
        Async.await(Loot.loot_item_panel(self.instance, self, panel, destroy_items))
      elseif panel.type == "Trap Panel" then
        local slide_time = .1
        local spawn_x = math.floor(panel.x) + .5
        local spawn_y = math.floor(panel.y) + .5
        local spawn_z = panel.z

        Net.slide_player_camera(
          self.id,
          spawn_x,
          spawn_y,
          spawn_z,
          slide_time
        )

        Async.await(Async.sleep(slide_time))

        if remove_traps then
          Async.await(self:message_with_mug("I found a trap! It's been removed."))
        elseif panel.custom_properties["Damage Trap"] == "true" then
          if panel.custom_properties["Trap Message"] ~= nil then
            Async.await(self:message_with_mug(panel.custom_properties["Trap Message"]))
          else
            Async.await(self:message_with_mug("Ah! A damage trap!"))
          end
          self:hurt(tonumber(panel.custom_properties["Damage Dealt"]))
        elseif panel.custom_properties["Stun Trap"] == "true" then
          if panel.custom_properties["Trap Message"] ~= nil then
            Async.await(self:message_with_mug(panel.custom_properties["Trap Message"]))
          else
            Async.await(self:message_with_mug("Ah! A paralysis trap!"))
          end
          self:paralyze()
        end
      end
    end

    -- Clear the selection so that it can be used again later.
    self.selection:clear()

    return true;
  end)
end

---@param results Liberation.BattleResults
function Player:liberate_and_loot_panels(panels, results, remove_traps, destroy_items)
  return Async.create_scope(function()
    Async.await(self:liberate_panels(panels, results))
    Async.await(self:loot_panels(panels, remove_traps, destroy_items))
    self:complete_turn()
  end)
end

function Player:handle_disconnect()
  self.selection:clear()

  if self.completed_turn then
    self.instance.ready_count = self.instance.ready_count - 1
  end

  if self.paralysis_effect then
    self.paralysis_effect:remove()
  end

  self.disconnected = true

  if self.order_points_sprite_id then
    Net.remove_sprite(self.order_points_sprite_id)
  end

  self:unlock_input()
end

-- export
return Player
