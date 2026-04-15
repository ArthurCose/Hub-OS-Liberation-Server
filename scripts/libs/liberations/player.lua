local PlayerSelection = require("scripts/libs/liberations/selections/player_selection")
local Loot = require("scripts/libs/liberations/loot")
local HealthSprites = require("scripts/libs/liberations/effects/health_sprites")
local ParalysisEffect = require("scripts/libs/liberations/effects/paralysis_effect")
local RecoverEffect = require("scripts/libs/liberations/effects/recover_effect")
local DamageNumbers = require("scripts/libs/liberations/effects/damage_numbers")
local Poof = require("scripts/libs/liberations/effects/poof")
local PanelClass = require("scripts/libs/liberations/panel_class")
local Emotes = require("scripts/libs/emotes")
local Preloader = require("scripts/libs/liberations/preloader")

local ORDER_POINTS_TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/ui/order_points.png")
local ORDER_POINTS_ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/ui/order_points.animation")

local GUARD_SFX = Preloader.add_asset("/server/assets/liberations/sounds/guard.ogg")
local HURT_SFX = Preloader.add_asset("/server/assets/liberations/sounds/hurt.ogg")

---@class Liberation.Player
---@field _instance Liberation.MissionInstance
---@field id Net.ActorId
---@field ability Liberation.Ability?
---@field spectate_next_battle boolean
---@field invincible boolean
---@field package _health number
---@field package _defenses Liberation.Player.Defense[]
---@field package paralysis_effect Liberation.ParalysisEffect?
---@field package paralysis_counter number
---@field package emote_delay number
---@field package order_points_sprite_id Net.SpriteId?
---@field package _completed_turn boolean
---@field package _selection Liberation.PlayerSelection
---@field package movement_locked boolean
---@field package stacked_movement_locks number
---@field package viewing_player Net.ActorId?
---@field package kick_votes table<Liberation.Player, boolean>
---@field package total_kick_votes number
---@field package kick_vote_successful? boolean
---@field package unresolved_promises table
---@field package disconnected boolean
---@field package disconnected_position Net.Position?
---@field package disconnected_direction string?
local Player = {}

---@param instance Liberation.MissionInstance
---@param player_id Net.ActorId
---@return Liberation.Player
function Player:new(instance, player_id)
  local player = {
    _instance = instance,
    id = player_id,
    _health = Net.get_player_health(player_id),
    _defenses = {},
    paralysis_effect = nil,
    paralysis_counter = 0,
    emote_delay = 0,
    order_points_sprite_id = nil,
    invincible = false,
    _completed_turn = false,
    ability = nil,
    spectate_next_battle = false,
    movement_locked = false,
    stacked_movement_locks = 0,
    viewing_player = self.id,
    kick_votes = {},
    total_kick_votes = 0,
    unresolved_promises = {},
    disconnected = false,
  }

  setmetatable(player, self)
  self.__index = self

  player._selection = PlayerSelection:new(player)

  HealthSprites.update_sprite(player.id, player.health)

  return player
end

function Player:instance()
  return self._instance
end

function Player:selection()
  return self._selection
end

---@param elapsed number
function Player:tick(elapsed)
  if self.emote_delay <= 0 then
    self:emote_state()
  else
    self.emote_delay = self.emote_delay - elapsed
  end
end

function Player:emote_state()
  if Net.is_player_battling(self.id) then
    -- the client will send emotes for this
  elseif self._completed_turn then
    Net.set_player_emote(self.id, Emotes.GREEN_CHECK)
  elseif self.spectate_next_battle then
    Net.set_player_emote(self.id, Emotes.POPCORN_AND_SODA)
  elseif self.invincible then
    Net.set_player_emote(self.id, "HORSE")
  else
    -- clear emote
    Net.set_player_emote(self.id, "")
  end

  self.emote_delay = 1
end

function Player:update_order_points_hud()
  if self.disconnected then
    return
  end

  local instance = self._instance

  if self.order_points_sprite_id then
    Net.animate_sprite(self.order_points_sprite_id, tostring(instance.order_points))
  else
    self.order_points_sprite_id = Net.create_sprite({
      player_id = self.id,
      parent_id = "hud",
      texture_path = ORDER_POINTS_TEXTURE_PATH,
      animation_path = ORDER_POINTS_ANIMATION_PATH,
      animation = tostring(instance.order_points)
    })
  end
end

function Player:direction()
  if self.disconnected then
    return self.disconnected_direction --[[@as string]]
  end

  return Net.get_player_direction(self.id)
end

function Player:position()
  local x, y, z = Net.get_player_position_multi(self.id)
  return { x = x, y = y, z = z }
end

function Player:position_multi()
  if self.disconnected then
    local position = self.disconnected_position --[[@as Net.Position]]
    return position.x, position.y, position.z
  end

  return Net.get_player_position_multi(self.id)
end

function Player:floored_position()
  local position = self:position()
  position.x = math.floor(position.x)
  position.y = math.floor(position.y)
  position.z = math.floor(position.z)
  return position
end

function Player:floored_position_multi()
  local x, y, z = self:position_multi()
  return math.floor(x), math.floor(y), math.floor(z)
end

--- Used for direct control, locking due to the player's action or by the mission
function Player:lock_movement()
  if not self.movement_locked then
    Net.lock_player_movement(self.id)
    self.movement_locked = true
  end
end

--- Used for direct control, locking due to the player's action or by the mission
function Player:unlock_movement()
  if self.movement_locked then
    Net.unlock_player_movement(self.id)
    self.movement_locked = false
  end
end

--- Used for indirect control, locking from another player's action
function Player:stack_lock_movement()
  self.stacked_movement_locks = self.stacked_movement_locks + 1
  Net.lock_player_movement(self.id)
end

--- Used for indirect control, unlocking from another player's action
function Player:unstack_lock_movement()
  self.stacked_movement_locks = self.stacked_movement_locks - 1
  Net.unlock_player_movement(self.id)
end

---Wraps promises to end immediately if the player was kicked or disconnected
---@generic T
---@param promise_constructor fun(): Net.Promise<T>
---@returns Net.Promise<T|nil>
function Player:wrap_promise(promise_constructor)
  return Async.create_promise(function(resolve)
    local resolved = false

    if self.kick_vote_successful or self.disconnected then
      resolve(nil)
      return
    end

    local resolve_once = function(value)
      if not resolved then
        resolve(value)
      end
    end

    self.unresolved_promises[resolve_once] = true

    promise_constructor().and_then(function(value)
      resolve_once(value)
      self.unresolved_promises[resolve_once] = nil
    end)
  end)
end

---@param message string
---@param texture_path? string
---@param animation_path? string
function Player:message(message, texture_path, animation_path)
  return self:wrap_promise(function()
    return Async.message_player(self.id, message, texture_path, animation_path)
  end)
end

---@param message string
---@param close_delay number
---@param texture_path? string
---@param animation_path? string
function Player:message_auto(message, close_delay, texture_path, animation_path)
  return self:wrap_promise(function()
    return Async.message_player_auto(self.id, message, close_delay, texture_path, animation_path)
  end)
end

---@param message string
function Player:message_with_mug(message)
  return self:wrap_promise(function()
    local mug = Net.get_player_mugshot(self.id)
    return Async.message_player(self.id, message, mug.texture_path, mug.animation_path)
  end)
end

---@param question string
---@param texture_path? string
---@param animation_path? string
function Player:question(question, texture_path, animation_path)
  return self:wrap_promise(function()
    return Async.question_player(self.id, question, texture_path, animation_path)
  end)
end

---@param question string
function Player:question_with_mug(question)
  return self:wrap_promise(function()
    local mug = Net.get_player_mugshot(self.id)
    return Async.question_player(self.id, question, mug.texture_path, mug.animation_path)
  end)
end

---@param a string
---@param b? string
---@param c? string
---@param textbox_options? Net.TextboxOptions
function Player:quiz(a, b, c, textbox_options)
  return self:wrap_promise(function()
    return Async.quiz_player(self.id, a, b, c, textbox_options)
  end)
end

function Player:get_ability_permission()
  local question_promise = self:question_with_mug(self.ability.question)

  question_promise.and_then(function(response)
    if response == 0 then
      -- No
      self._selection:clear()
      self:unlock_movement()
      return
    end

    local instance = self._instance

    -- Yes
    if instance.order_points < self.ability.cost then
      -- not enough order points
      self:message("Not enough Order Pts!")
      return
    end

    instance.order_points = instance.order_points - self.ability.cost

    for _, p in ipairs(instance.players) do
      p:update_order_points_hud()
    end

    self.ability.activate(self)
  end)
end

function Player:get_pass_turn_permission()
  local question = "End without doing anything?"

  if self._health < self:max_health() then
    question = "Recover HP?"
  end

  local question_promise = self:question_with_mug(question)

  question_promise.and_then(function(response)
    if response == 0 then
      -- No
      self:unlock_movement()
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

---Resolves the terrain without accounting for selection
function Player:resolve_surrounding_terrain()
  local instance = self._instance

  local function has_dark_panel(x, y, z)
    local panel = instance:get_panel_at(x, y, z)

    return panel and PanelClass.TERRAIN[panel.class]
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

local TERRAIN_BOOST = {
  advantage = "even",
  even = "disadvantage",
  disadvantage = "surrounded",
  surrounded = "surrounded",
}

function Player:resolve_terrain()
  local terrain = self:resolve_surrounding_terrain()

  if #self._selection:get_panels() > 1 then
    terrain = TERRAIN_BOOST[terrain]
  end

  return terrain
end

---@class Liberation.InitiateEncounterData
---@field health number? HP for a synced enemy
---@field max_health number? Max HP for a synced enemy
---@field rank string? Rank for a synced enemy

---@param encounter_path string
---@param data Liberation.InitiateEncounterData
---@return Net.Promise<Liberation.BattleResults>, Net.EventEmitter
function Player:initiate_encounter(encounter_path, data)
  -- erase type so we can add more properties
  ---@type table
  local data = data

  data.terrain = self:resolve_terrain()
  data.spectators = {}
  data.start_invincible = self.invincible

  -- rally teammates
  local x, y, z = self:position_multi()
  x, y, z = math.floor(x), math.floor(y), math.floor(z)

  local player_ids = { self.id }
  local spectator_map = {}

  -- disable spectating if we started a battle
  self.spectate_next_battle = false

  local instance = self._instance

  for _, player in ipairs(instance.players) do
    if player == self then
      -- already included
      goto continue
    end

    if not Net.is_player(player.id) then
      -- disconnected
      goto continue
    end

    if (not player.spectate_next_battle and Net.is_player_busy(player.id)) or Net.is_player_battling(player.id) then
      -- in a menu or already spectating
      goto continue
    end

    if player._completed_turn or player.spectate_next_battle then
      -- include as a spectator
      data.spectators[#player_ids] = true
      spectator_map[player.id] = true
      player_ids[#player_ids + 1] = player.id
      player.spectate_next_battle = false
      goto continue
    end

    if Net.is_player_movement_locked(player.id) then
      goto continue
    end

    local other_x, other_y, other_z = player:position_multi()

    if x == math.floor(other_x) and y == math.floor(other_y) and z == math.floor(other_z) then
      player_ids[#player_ids + 1] = player.id
      -- prepare to spend a turn on co-op
      player:lock_movement()
      player._selection:clear()
      player.spectate_next_battle = false
    end

    ::continue::
  end

  -- begin encounter
  local emitter = Net.initiate_netplay(player_ids, encounter_path, data)

  local expected_result_events = #player_ids
  local result_events = 0

  local promise = Async.create_promise(function(resolve)
    local final_result = { won = false, turns = 0 }
    local resolved = false

    emitter:on("battle_results", function(results)
      local results_player = instance.player_map[results.player_id]

      -- update player
      if results ~= nil and not spectator_map[results.player_id] and results_player then
        if results.connection_failed then
          -- connection failed, free players that joined in
          if self.id ~= results_player.id then
            results_player:unlock_movement()
          end

          if not resolved then
            -- resolve immediately
            resolve(results)
            resolved = true
          end

          return
        end

        local max_health = Net.get_player_max_health(results_player.id)

        results_player._health = results.health
        Net.set_player_health(results_player.id, math.min(results.health, max_health))
        Net.set_player_emotion(results_player.id, results.emotion)
        HealthSprites.update_sprite(self.id, self._health)

        if results.health == 0 then
          results_player:paralyze()
        end

        if self.id ~= results_player.id then
          results_player:complete_turn()
        end

        -- contribute to final result
        final_result.won = final_result.won or results.won
        final_result.turns = math.max(final_result.turns, results.turns)
      end

      if resolved then
        return
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

function Player:health()
  return self._health
end

function Player:max_health()
  return Net.get_player_max_health(self.id)
end

function Player:heal(amount)
  return Async.create_promise(function(resolve)
    local previous_health = self._health

    self._health = math.min(math.ceil(self._health + amount), self:max_health())

    Net.set_player_health(self.id, self._health)
    HealthSprites.update_sprite(self.id, self._health)

    if previous_health < self._health then
      RecoverEffect:new(self.id)
    end

    return resolve(Async.sleep(0.5))
  end)
end

---@param amount number
function Player:hurt(amount)
  if self.disconnected or self._health == 0 or amount <= 0 then
    return
  end

  if self.invincible then
    amount = 0
  else
    -- copy to protect against additions + removal during loop
    local defenses_copy = table.pack(table.unpack(self._defenses))

    for _, defense in ipairs(defenses_copy) do
      amount = defense.defend(amount)
    end
  end

  local prev_health = self._health

  if amount > 0 then
    Net.play_sound_for_player(self.id, HURT_SFX)

    self._health = math.max(math.ceil(self._health - amount), 0)
  else
    Net.play_sound_for_player(self.id, GUARD_SFX)
  end

  -- spawn damage numbers
  local instance = self._instance
  local x, y, z = Net.get_player_position_multi(self.id)
  DamageNumbers.spawn(
    instance.area_id,
    prev_health - self._health,
    x + 2 / 32,
    y + 2 / 32,
    z + 0.5
  )

  if amount == 0 then
    return
  end

  -- update UI
  Net.set_player_health(self.id, self._health)
  HealthSprites.update_sprite(self.id, self._health)

  if self._health == 0 then
    Async.sleep(1).and_then(function()
      self:paralyze()
    end)
  end
end

---@enum Liberation.Player.DefensePriority
Player.DefensePriority = {
  Barrier = 0,
  Action = 1,
  Body = 2,
  Trap = 3,
  Last = 4
}

---@class Liberation.Player.Defense
---@field priority Liberation.Player.DefensePriority avoid changing this once set
---@field prepare? fun(attacker: Liberation.Enemy, targets: Liberation.Player[]): Liberation.Player[]? Called when any enemy is attacking, used to change who the enemy targets
---@field defend? fun(damage: number): number
---@field relax? fun() Called after the enemy finishes attacking
---@field on_remove? fun() Called when removed directly, a defense with the same priority was added, or the mission was completed / abandoned
---@field on_disconnect? fun() Called when a player disconnects, the player may still rejoin after this
---@field on_rejoin? fun()

---@param defense Liberation.Player.Defense
function Player:add_defense(defense)
  local priority = defense.priority

  if priority == Player.DefensePriority.Last then
    -- always place at the end
    self._defenses[#self._defenses + 1] = defense
    return
  end

  for i, existing_defense in ipairs(self._defenses) do
    if priority < existing_defense.priority then
      -- higher priority, place before existing defense
      table.insert(self._defenses, i, defense)
      return
    elseif priority == existing_defense.priority then
      -- replace existing defenes
      local prev_defense = self._defenses[i]
      self._defenses[i] = defense

      if prev_defense.on_remove then
        prev_defense.on_remove()
      end

      return
    end
  end

  -- place at the end
  self._defenses[#self._defenses + 1] = defense
end

---@param defense Liberation.Player.Defense
function Player:remove_defense(defense)
  for i, existing_defense in ipairs(self._defenses) do
    if existing_defense == defense then
      table.remove(self._defenses, i)

      if defense.on_remove then
        defense.on_remove()
      end

      break
    end
  end
end

function Player:remove_all_defenses()
  local old_defenses = self._defenses
  self._defenses = {}

  for _, defense in ipairs(old_defenses) do
    if defense.on_remove then
      defense.on_remove()
    end
  end
end

---Automatically called by enemy:attack()
---@param enemy Liberation.Enemy
---@param targets Liberation.Player[]
function Player:prepare_for_attack(enemy, targets)
  for _, defense in ipairs(self._defenses) do
    if defense.prepare then
      local new_targets = defense.prepare(enemy, targets)

      if new_targets then
        targets = new_targets
      end
    end
  end

  return targets
end

---Automatically called by enemy:attack()
function Player:relax_after_attack()
  for _, defense in ipairs(self._defenses) do
    if defense.relax then
      defense.relax()
    end
  end
end

function Player:paralyzed()
  return self.paralysis_effect ~= nil
end

function Player:paralyze()
  if self.disconnected then
    return
  end

  self.paralysis_counter = 2
  self.paralysis_effect = ParalysisEffect:new(self.id)
end

function Player:pass_turn()
  -- heal up to 50% of health
  Async.await(self:heal(self:max_health() / 2)).and_then(function()
    self:complete_turn()
  end)
end

function Player:completed_turn()
  return self._completed_turn
end

function Player:complete_turn()
  if self.disconnected or self._completed_turn then
    return
  end

  self._completed_turn = true
  self._selection:clear()

  -- make sure input is locked
  self:lock_movement()

  -- cancel spectating
  self.spectate_next_battle = false

  self:emote_state()

  local instance = self._instance

  if instance.ready_count < #instance.players then
    Net.unlock_player_camera(self.id)
  end

  instance.ready_count = instance.ready_count + 1
end

function Player:give_turn()
  if self.kick_vote_successful then
    -- kick next cycle if we somehow missed this player
    return
  end

  self._completed_turn = false
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
    if self._health == 0 then
      self:heal(self:max_health() / 2)
    end
  end

  self:unlock_movement()
  self.viewing_player = nil
  Net.track_with_player_camera(self.id, self.id)
end

function Player:find_closest_guardian()
  local closest_guardian
  local closest_distance = math.huge

  local x, y, z = self:position_multi()

  local instance = self._instance

  for _, enemy in ipairs(instance.enemies) do
    if instance.boss == enemy then
      goto continue
    end

    local distance = enemy:chebyshev_tile_distance(x, y, z)

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
---@field connection_failed boolean
---@field turns number

---@param results Liberation.BattleResults
function Player:liberate_panels(panels, results)
  return Async.create_scope(function()
    -- Allow time for the player to see the liberation range
    Async.await(Async.sleep(2))

    local instance = self._instance

    for _, panel in ipairs(panels) do
      instance:remove_panel(panel)
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

---@param panels Liberation.PanelObject[]
function Player:animate_search(panels)
  return Async.create_scope(function()
    local indicator_template = self._selection:indicator_template()

    local instance = self._instance
    local bot_id = Net.create_bot({
      area_id = instance.area_id,
      x = -10000,
      texture_path = indicator_template.texture_path,
      animation_path = indicator_template.animation_path,
      animation = "SEARCHING",
      loop_animation = true,
      warp_in = false
    })

    local KEY_FRAME_DURATION = 8 / 60
    ---@type Net.ActorKeyframe[]
    local keyframes = {}

    for _ = 1, 3 do
      for _, panel in ipairs(panels) do
        keyframes[#keyframes + 1] = {
          properties = {
            { property = "X", value = panel.x + 1 / 32, ease = "Floor" },
            { property = "Y", value = panel.y + 1 / 32, ease = "Floor" },
            { property = "Z", value = panel.z,          ease = "Floor" },
          },
          duration = KEY_FRAME_DURATION,
        }
      end
    end

    keyframes[#keyframes + 1] = {
      properties = {
        { property = "Animation", value = "HIDDEN" },
      },
      duration = KEY_FRAME_DURATION,
    }

    Net.animate_bot_properties(bot_id, keyframes)

    -- wait for the animation to finish before
    Async.await(Async.sleep(3 * #panels * KEY_FRAME_DURATION + 0.5))
    Net.remove_bot(bot_id)
  end)
end

---@class Liberation.Player.LootPanelsOptions
---@field remove_traps boolean?
---@field destroy_items boolean?

local default_loot_options = {}
local loot_slide_time = .1

---@param instance Liberation.MissionInstance
---@param panel Liberation.PanelObject
local function convert_loot_panel(instance, panel)
  -- we only convert if the panel been liberated already
  if instance:get_panel_at(panel.x, panel.y, panel.z) == panel then
    instance:remove_panel(panel)
    instance:generate_panel(PanelClass.DARK, panel.x, panel.y, panel.z)
  end
end

---@param panels Liberation.PanelObject[]
---@param options Liberation.Player.LootPanelsOptions?
function Player:loot_panels(panels, options)
  options = options or default_loot_options

  return Async.create_scope(function()
    local instance = self._instance
    local total_looted = 0

    for _, panel in ipairs(panels) do
      local loot = panel.loot

      -- prevent other players from looting this panel again
      panel.loot = nil

      if not loot and panel.class ~= PanelClass.TRAP then
        goto continue
      end

      total_looted = total_looted + 1

      local spawn_x = math.floor(panel.x) + .5
      local spawn_y = math.floor(panel.y) + .5
      local spawn_z = panel.z

      Net.slide_player_camera(
        self.id,
        spawn_x,
        spawn_y,
        spawn_z,
        loot_slide_time
      )

      Async.await(Async.sleep(loot_slide_time))

      if loot then
        -- replace with a regular dark panel
        convert_loot_panel(instance, panel)

        -- spawn loot item
        local remove_item_bot = Async.await(Loot.spawn_item_bot(loot, instance.area_id, spawn_x, spawn_y, spawn_z))

        if loot.breakable and options.destroy_items then
          Async.await(self:message_with_mug("Ah!! The item was destroyed!"))
        else
          Async.await(loot.activate(self, panel))
        end

        remove_item_bot()
      elseif panel.class == PanelClass.TRAP then
        local trap_damage = tonumber(panel.custom_properties["Damage"])

        if options.remove_traps then
          Async.await(self:message_with_mug("A trap panel!\nI'll remove it!"))

          Poof.spawn(instance.area_id, "LARGE", panel.x + 0.5, panel.y + 0.5, panel.z + 0.5)
          convert_loot_panel(instance, panel)

          Async.await(Async.sleep(1))
        elseif trap_damage then
          if panel.custom_properties["Message"] ~= nil then
            Async.await(self:message_with_mug(panel.custom_properties["Message"]))
          else
            Async.await(self:message_with_mug("Ah! A damage trap!"))
          end

          Async.await(Async.sleep(0.25))

          self:hurt(trap_damage)
          convert_loot_panel(instance, panel)

          Async.await(Async.sleep(1))
        else
          if panel.custom_properties["Message"] ~= nil then
            Async.await(self:message_with_mug(panel.custom_properties["Message"]))
          else
            Async.await(self:message_with_mug("Ah! A paralysis trap!"))
          end

          self:paralyze()
          convert_loot_panel(instance, panel)

          Async.await(Async.sleep(1))
        end
      end

      ::continue::
    end

    -- Clear the selection so that it can be used again later.
    self._selection:clear()

    return total_looted
  end)
end

---@package
function Player:cycle_camera_target()
  local instance = self._instance

  if not instance.player_map[self.viewing_player] then
    self.viewing_player = self.id
  end

  local index

  for i = 1, #instance.players do
    local player = instance.players[i]

    if player.id == self.viewing_player then
      index = i
      break
    end
  end

  index = index % #instance.players + 1

  self.viewing_player = instance.players[index].id

  Net.track_with_player_camera(self.id, self.viewing_player)
end

function Player:handle_spectator_input(button)
  if button == 1 then
    -- cycle when L is pressed
    self:cycle_camera_target()
    return
  end

  if button ~= 0 then
    -- just in case we add more buttons
    return
  end

  if Net.is_player_busy(self.id) then
    -- menu may already open
    return
  end

  local IMMEDIATE_TOKEN = "\x04"
  local VOTE_TO_KICK = IMMEDIATE_TOKEN .. "Vote to Kick"
  local CANCEL_VOTE_TO_KICK = IMMEDIATE_TOKEN .. "Remove Vote"
  local ABANDON = IMMEDIATE_TOKEN .. "Abandon Mission"
  local CANCEL = IMMEDIATE_TOKEN .. "Close"

  local options = { ABANDON, CANCEL }

  local instance = self._instance
  ---@type Liberation.Player
  local viewed_player = instance.player_map[self.viewing_player]

  if viewed_player and self.viewing_player ~= self.id and #instance.players > 2 and not self.kick_vote_successful then
    if viewed_player.kick_votes[self] then
      table.insert(options, 2, CANCEL_VOTE_TO_KICK)
    else
      table.insert(options, 2, VOTE_TO_KICK)
    end
  end

  Async.create_scope(function()
    local response = Async.await(Async.quiz_player(
      self.id,
      options[1],
      options[2],
      options[3],
      { cancel_response = 4 }
    ))

    if not response then
      return
    end

    local option = options[response + 1]

    if option == VOTE_TO_KICK and not self.kick_vote_successful then
      viewed_player.kick_votes[self] = true
      viewed_player.total_kick_votes = viewed_player.total_kick_votes + 1
      if viewed_player:resolve_kick_vote() then
        viewed_player:complete_turn()
      end
    elseif option == CANCEL_VOTE_TO_KICK and not self.kick_vote_successful then
      viewed_player.kick_votes[self] = nil
      viewed_player.total_kick_votes = viewed_player.total_kick_votes - 1
      if viewed_player:resolve_kick_vote() then
        viewed_player:complete_turn()
      end
    elseif option == ABANDON then
      local abandon_response = Async.await(self:question_with_mug("Abandon mission?"))

      if abandon_response == 1 then
        if instance:taking_enemy_turn() then
          -- vote self out
          self.kick_vote_successful = true
        else
          instance:kick_player(self.id, "abandoned")
        end
      end
    end
  end)
end

function Player:resolve_kick_vote()
  if not self.kick_vote_successful then
    local instance = self._instance

    self.kick_vote_successful = self.total_kick_votes >= math.ceil(#instance.players / 2)

    if self.kick_vote_successful then
      for _, player in ipairs(instance.players) do
        if player.kick_votes[self] then
          player.kick_votes[self] = nil
          player.total_kick_votes = player.total_kick_votes - 1
        end
      end

      for resolve in pairs(self.unresolved_promises) do
        resolve(nil)
      end
    end
  end

  return self.kick_vote_successful
end

function Player:handle_emote()
  self.emote_delay = 3
end

function Player:handle_disconnect()
  self.disconnected_position = self:position()
  self.disconnected_direction = self:direction()
  self.disconnected = true

  self._selection:clear()

  if self._completed_turn then
    local instance = self._instance
    instance.ready_count = instance.ready_count - 1
  end

  if self.paralysis_effect then
    self.paralysis_effect:remove()
  end

  if self.order_points_sprite_id then
    Net.remove_sprite(self.order_points_sprite_id)
    self.order_points_sprite_id = nil
  end

  HealthSprites.remove_sprite(self.id)

  if self.movement_locked then
    Net.unlock_player_movement(self.id)
  end

  for _ = 1, self.stacked_movement_locks do
    Net.unlock_player_movement(self.id)
  end

  if self.viewing_player and self.viewing_player ~= self.id then
    self.viewing_player = nil
    Net.track_with_player_camera(self.id, self.id)
  end

  for _, defense in ipairs(self._defenses) do
    if defense.on_disconnect then
      defense.on_disconnect()
    end
  end
end

---@param player_id Net.ActorId
function Player:try_reconnect(player_id)
  if not self.disconnected then
    -- already connected?
    return false
  end

  local instance = self._instance

  if
      instance.liberated or
      instance:destroying() or
      not Net.is_area(instance.area_id)
  then
    return false
  end

  self.id = player_id
  self.viewing_player = self.id
  self.disconnected = false
  self.spectate_next_battle = false

  -- paralyze for one turn to discourage intentional disconnecting
  self.paralysis_counter = math.max(self.paralysis_counter, 1)
  self._completed_turn = true
  self.movement_locked = true

  if self._completed_turn then
    instance.ready_count = instance.ready_count + 1
  end

  if self.paralysis_counter > 0 then
    self.paralysis_effect = ParalysisEffect:new(self.id)
  end

  self:update_order_points_hud()

  HealthSprites.update_sprite(self.id, self._health)

  if self.movement_locked then
    Net.lock_player_movement(self.id)
  end

  self.stacked_movement_locks = 0

  -- add this player back to the instance
  instance.player_map[self.id] = self
  instance.players[#instance.players + 1] = self

  -- restore client data
  local position = self.disconnected_position --[[@as Net.Position]]
  local direction = self.disconnected_direction
  Net.transfer_player(player_id, instance.area_id, true, position.x, position.y, position.z, direction)
  Net.set_player_health(player_id, self._health)

  for _, defense in ipairs(self._defenses) do
    if defense.on_rejoin then
      defense.on_rejoin()
    end
  end

  return true
end

-- export
return Player
