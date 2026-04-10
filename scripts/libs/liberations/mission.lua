local TableUtil = require("scripts/libs/liberations/table_util")
local Player = require("scripts/libs/liberations/player")
local Enemy = require("scripts/libs/liberations/enemy")
local EnemyHelpers = require("scripts/libs/liberations/enemy_helpers")
local Loot = require("scripts/libs/liberations/loot")
local PanelType = require("scripts/libs/liberations/panel_type")
local TargetPhase = require("scripts/libs/liberations/target_phase")
local Preloader = require("scripts/libs/liberations/preloader")
local HealthSprites = require("scripts/libs/liberations/effects/health_sprites")

local MARKERS_TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/ui/markers.png")
local MARKERS_ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/ui/markers.animation")

local ENEMY_TURN_SFX = Preloader.add_asset("/server/assets/liberations/sounds/enemy_turn.ogg")

local DEBUG_AUTO_WIN = false

-- private functions

local function is_adjacent(position_a, position_b)
  if position_a.z ~= position_b.z then
    return false
  end

  local x_diff = math.abs(math.floor(position_a.x) - math.floor(position_b.x))
  local y_diff = math.abs(math.floor(position_a.y) - math.floor(position_b.y))

  return x_diff + y_diff == 1
end

---@param self Liberation.MissionInstance
local function liberate(self)
  self.liberated = true

  for _, layer in pairs(self.panels) do
    for _, row in pairs(layer) do
      for _, panel in pairs(row) do
        Net.remove_object(self.area_id, panel.id)

        if panel.collision_id then
          Net.remove_object(self.area_id, panel.collision_id)
        end
      end
    end
  end

  self.panels = {}
  self.dark_holes = {}

  for _, enemy in ipairs(self.enemies) do
    Net.remove_bot(enemy.id, false)
  end

  self.enemies = {}

  local area_properties = Net.get_area_custom_properties(self.area_id)

  if area_properties["Victory Background Texture"] then
    Net.set_background(
      self.area_id,
      area_properties["Victory Background Texture"],
      area_properties["Victory Background Animation"],
      tonumber(area_properties["Victory Background Vel X"]),
      tonumber(area_properties["Victory Background Vel Y"])
    )
  end

  local victory_music = area_properties["Victory Music"] or area_properties["Victory Song"]

  if victory_music then
    Net.set_music(self.area_id, victory_music)
  else
    Net.set_music(self.area_id, area_properties["Music"] or area_properties["Song"])
  end

  local victory_message =
      self.area_name .. " Liberated\n" ..
      "Target: " .. self.target_phase:calculate() .. "\n" ..
      "Actual: " .. self.phase

  for _, player in ipairs(self.players) do
    player:message(victory_message).and_then(function()
      self:kick_player(player.id, "success")
    end)
  end
end

local DARK_HOLE_SHAPE = {
  { 1, 1, 1 },
  { 1, 1, 1 },
  { 1, 1, 1 },
}

-- expects execution in a coroutine
---@param self Liberation.MissionInstance
local function convert_indestructible_panels(self)
  local slide_time = .5
  local hold_time = 2

  -- notify players
  for _, player in ipairs(self.players) do
    player:message("No more DarkHoles! Nothing will save the Darkloids now!")
    local player_x, player_y, player_z = player:position_multi()

    player:stack_lock_movement()

    Net.slide_player_camera(player.id, self.boss.x, self.boss.y, self.boss.z, slide_time)

    -- hold the camera
    Net.move_player_camera(player.id, self.boss.x, self.boss.y, self.boss.z, hold_time)

    -- return the camera
    Net.slide_player_camera(player.id, player_x, player_y, player_z, slide_time)
    Net.unlock_player_camera(player.id)
  end

  Async.await(Async.sleep(slide_time + hold_time / 2))

  -- convert panels
  for _, panel in ipairs(self.indestructible_panels) do
    panel.type = PanelType.DARK

    -- update visual
    local dark_gids = self.panel_gid_map[PanelType.DARK]

    panel.data.gid = dark_gids[math.random(#dark_gids)]
    Net.set_object_data(self.area_id, panel.id, panel.data)

    -- add collision since base dark panels don't have collision for shadow step
    self.collision_template.x = panel.x
    self.collision_template.y = panel.y
    self.collision_template.z = panel.z

    panel.collision_id = Net.create_object(self.area_id, self.collision_template)
  end

  self.indestructible_panels = {}

  Async.await(Async.sleep(hold_time / 2 + slide_time))

  -- returning control
  for _, player in ipairs(self.players) do
    player:unstack_lock_movement()
  end
end

---@param self Liberation.MissionInstance
---@param player Liberation.Player
local function liberate_panel(self, player)
  return Async.create_scope(function()
    local selection = player.selection
    local panel = selection:root_panel()

    if panel.type == PanelType.BONUS then
      if panel.custom_properties["Message"] ~= nil then
        Async.await(player:message_with_mug(panel.custom_properties["Message"]))
      else
        Async.await(player:message_with_mug("A BonusPanel! What's it hiding?"))
      end

      self:remove_panel(panel)

      selection:clear()

      Async.await(Loot.loot_bonus_panel(self, player, panel))

      player:unlock_movement()
    else
      if panel.custom_properties["Message"] ~= nil then
        Async.await(player:message_with_mug(panel.custom_properties["Message"]))
      elseif panel.type == PanelType.DARK_HOLE then
        Async.await(player:message_with_mug("A Dark Hole! Begin liberation!"))
      else
        Async.await(player:message_with_mug("Let's do it! Liberate panels!"))
      end

      local encounter_path = panel.custom_properties["Encounter"] or self.default_encounter
      local data = {}

      -- Obtain enemy
      local enemy = self:get_enemy_at(panel.x, panel.y, panel.z)

      -- If an overworld enemy exists, set facing & data
      if enemy then
        local player_x, player_y = player:position_multi()

        EnemyHelpers.face_position(enemy, player_x, player_y)
        encounter_path = enemy.encounter
        data.health = enemy.health
        data.rank = enemy.rank

        Async.await(enemy:banter(player.id))
      elseif panel.enemy then
        -- hidden enemy within dark panel
        local hidden_enemy = panel.enemy
        -- spawn fully healed
        data.health = hidden_enemy.max_health
        data.rank = hidden_enemy.rank
        -- override encounter
        encounter_path = panel.custom_properties["Direct Encounter"] or hidden_enemy.encounter
      end

      ---@type (Net.BattleResults | { success: boolean })?
      local results
      local final_enemy_health = enemy and enemy.health or 0

      if DEBUG_AUTO_WIN then
        results = { won = true, turns = 1 }
      else
        local promise, emitter = player:initiate_encounter(encounter_path, data)

        emitter:on("battle_message", function(event)
          -- use the latest enemy health value
          -- might be affected by network speed, but we're just accepting this fact
          if event.data then
            final_enemy_health = tonumber(event.data.health) or final_enemy_health
          end
        end)

        results = Async.await(promise)
      end

      if results and results.connection_failed then
        -- avoid ending this player's turn to allow them to retry
        player:unlock_movement()
        selection:clear()
        return
      end

      -- update enemy health before transitions end
      if enemy and Enemy.is_alive(enemy) then
        enemy.health = final_enemy_health

        if enemy.health == 0 then
          HealthSprites.remove_sprite(enemy.id)
        else
          HealthSprites.update_sprite(enemy.id, enemy.health)
        end
      end

      if not results or not results.won then
        -- delay to allow the return transition to end
        Async.await(Async.sleep(1))

        if enemy and enemy.health <= 0 then
          Async.await(Enemy.destroy(self, enemy))

          if enemy == self.boss then
            -- we saw the delete animation,
            -- so we'll allow the players to complete the mission
            liberate(self)
            return
          end
        end

        player:complete_turn()
        return
      end

      if panel.type == PanelType.DARK_HOLE then
        selection:set_shape(DARK_HOLE_SHAPE, 0, -1)
      end

      if not results.won then
        selection:clear()
      elseif results.turns == 1 then
        selection:merge_bonus_shape()
      end

      local panels = selection:get_panels()

      Async.await(player:liberate_panels(panels, results))

      -- destroy enemy
      Async.await(Enemy.destroy(self, enemy or panel.enemy))

      if panel.type == PanelType.DARK_HOLE and #self.dark_holes == 0 then
        convert_indestructible_panels(self)
      end

      -- loot
      Async.await(player:loot_panels(panels))

      -- figure out if we've won
      if enemy == self.boss then
        liberate(self)
      else
        player:complete_turn()
      end
    end
  end)
end

---@param self Liberation.MissionInstance
local function take_enemy_turn(self)
  if self.needs_disposal then
    self:destroy()
    return
  end

  self.updating = true

  Async.create_scope(function()
    local hold_time = .15
    local slide_time = .5
    local down_count = 0

    for _, player in ipairs(self.players) do
      if player.health == 0 then
        down_count = down_count + 1
      end
    end

    if down_count == #self.players then
      for _, player in ipairs(self.players) do
        Async.create_scope(function()
          Async.await(player:message_with_mug("We're all down?\nRetreat!\nRetreat!!"))

          Net.slide_player_camera(player.id, self.boss.x + .5, self.boss.y + .5, self.boss.z, slide_time)

          Async.await(Async.sleep(slide_time + 0.5))

          Async.await(player:message_with_mug("Is this the power of " .. self.boss.name .. "...?"))

          Async.await(Async.sleep(0.5))

          Net.unlock_player_camera(player.id)

          self:kick_player(player.id, "failure")
        end)
      end

      return
    end

    for i, enemy in ipairs(self.enemies) do
      for _, player in ipairs(self.players) do
        Net.slide_player_camera(player.id, enemy.x + .5, enemy.y + .5, enemy.z, slide_time)
      end

      -- wait until the camera is done moving
      Async.await(Async.sleep(slide_time))

      if enemy == self.boss then
        -- darkloids heal up to 50% of health during their turn
        Async.await(EnemyHelpers.heal(enemy, enemy.max_health / 2))
      else
        -- regular enemies heal only 30%?
        Async.await(EnemyHelpers.heal(enemy, math.floor(enemy.max_health * .3)))
      end

      Async.await(enemy:take_turn())

      -- wait a short amount of time to look nicer if there was no action taken
      Async.await(Async.sleep(hold_time))

      if i ~= #self.enemies then
        Net.play_sound(self.area_id, ENEMY_TURN_SFX)
      end
    end

    -- dark holes!
    for _, dark_hole in ipairs(self.dark_holes) do
      -- see if we need to spawn a new enemy
      if Enemy.is_alive(dark_hole.enemy) then
        goto continue
      end

      -- find an available space
      -- todo: move out of func
      local neighbor_offsets = {
        { 1,  -1 },
        { 1,  0 },
        { 1,  1 },
        { -1, -1 },
        { -1, 0 },
        { -1, 1 },
        { 0,  1 },
        { 0,  -1 },
      }

      local neighbors = {}

      for _, neighbor_offset in ipairs(neighbor_offsets) do
        local x = dark_hole.x + neighbor_offset[1]
        local y = dark_hole.y + neighbor_offset[2]
        local z = dark_hole.z

        local panel = self:get_panel_at(x, y, z)

        if panel and PanelType.ENEMY_WALKABLE[panel.type] and not self:get_enemy_at(x, y, z) then
          neighbors[#neighbors + 1] = panel
        end
      end

      if #neighbors == 0 then
        -- no available spaces
        goto continue
      end

      -- pick a neighbor to be the destination
      local destination = neighbors[math.random(#neighbors)]

      -- move the camera here
      for _, player in ipairs(self.players) do
        Net.slide_player_camera(player.id, dark_hole.x + .5, dark_hole.y + .5, dark_hole.z, slide_time)
      end

      -- wait until the camera is done moving
      Async.await(Async.sleep(slide_time))

      -- spawn a new enemy
      local turn_order = dark_hole.enemy.turn_order
      dark_hole.enemy = Enemy.from(Enemy.options_from(self, dark_hole))
      dark_hole.enemy.turn_order = turn_order
      self.enemies[#self.enemies + 1] = dark_hole.enemy

      self:sort_enemies()

      -- Let people admire the enemy
      local admire_time = .5
      Async.await(Async.sleep(admire_time))

      -- move them out
      Async.await(EnemyHelpers.move(self, dark_hole.enemy, destination.x, destination.y, destination.z))

      -- Needs more admiration
      Async.await(Async.sleep(admire_time))

      ::continue::
    end

    -- completed turn, return camera to players
    for _, player in ipairs(self.players) do
      local x, y, z = player:position_multi()

      -- Slide camera back to the player
      Net.slide_player_camera(player.id, x, y, z, slide_time)

      -- Return camera control
      Net.unlock_player_camera(player.id)

      -- If they aren't paralyzed or otherwise unable to move, return input
      if not player.paralysis_effect then
        player:unlock_movement()
      end
    end

    -- wait for the camera
    Async.await(Async.sleep(slide_time))

    -- give turn back to players
    for _, player in ipairs(self.players) do
      player:give_turn()
    end

    self.phase = self.phase + 1
  end)
      .and_then(function()
        self.updating = false

        if self.needs_disposal then
          self:destroy()
        end
      end)
end

---@class Liberation.PanelObject: Net.Object
---@field collision_id number?
---@field marker_id number?
---@field enemy Liberation.Enemy
---@field loot Liberation.Loot?

-- public
---@class Liberation.MissionInstance
---@field area_id string
---@field area_name string
---@field default_encounter string
---@field package target_phase Liberation._TargetPhase
---@field liberated boolean
---@field phase number
---@field ready_count number
---@field order_points number
---@field MAX_ORDER_POINTS number
---@field points_of_interest Net.Object[]
---@field players Liberation.Player[]
---@field player_map table<Net.ActorId, Liberation.Player>
---@field boss Liberation.Enemy
---@field enemies Liberation.Enemy[]
---@field panels table<number, table<number, table<number, Liberation.PanelObject>>>
---@field dark_holes Liberation.PanelObject[]
---@field indestructible_panels Liberation.PanelObject[]
---@field gate_panels Liberation.PanelObject[]
---@field panel_gid_map table<string, number[]>
---@field collision_template Net.ObjectOptions
---@field marker_template Net.ObjectOptions
---@field events Net.EventEmitter "dark_hole_liberated" {}, "money" { player_id, money }, "player_kicked" { player_id, reason }, "player_disconnect" { player }, "destroyed" {}
---@field package spawn_positions Net.Object[]
---@field package abandon_points table<number, table<number, table<number, boolean>>>
---@field package net_listeners [string, fun()][]
---@field package updating boolean
---@field package needs_disposal boolean
local MissionInstance = {}

---@param area_id string
---@return Liberation.MissionInstance
function MissionInstance:new(area_id)
  local mission = {
    area_id = area_id,
    area_name = Net.get_area_name(area_id),
    default_encounter = Net.get_area_custom_property(area_id, "Liberation Encounter"),
    target_phase = TargetPhase:new(area_id),
    liberated = false,
    phase = 1,
    ready_count = 0,
    order_points = 3,
    MAX_ORDER_POINTS = 8,
    points_of_interest = {},
    players = {},
    player_map = {},
    boss = nil,
    enemies = {},
    panels = {},
    dark_holes = {},
    indestructible_panels = {},
    gate_panels = {},
    panel_gid_map = {},
    collision_template = {
      visible = false,
      x = 0,
      y = 0,
      z = 0,
      width = 2,
      height = 1,
      data = {
        type = "tile",
        gid = Net.get_tileset(area_id, "/server/assets/liberations/tiles/collision.tsx").first_gid
      },
    },
    marker_template = {
      class = "Marker",
      x = 0,
      y = 0,
      z = 0,
      custom_properties = {
        ["Texture"] = MARKERS_TEXTURE_PATH,
        ["Animation"] = MARKERS_ANIMATION_PATH,
      },
      data = {
        type = "point",
      },
    },
    spawn_positions = {},
    abandon_points = {},
    net_listeners = {},
    events = Net.EventEmitter.new(),
    updating = false,
    needs_disposal = false
  }

  for i = 1, Net.get_layer_count(area_id), 1 do
    -- create a layer of panels
    local panel_layer = {}

    for j = 1, Net.get_layer_height(area_id), 1 do
      --Now we need to create the actual row of panels we'll be using within that layer.
      panel_layer[j] = {}
    end

    mission.panels[i] = panel_layer
  end

  setmetatable(mission, self)
  self.__index = self

  mission = mission --[[@as Liberation.MissionInstance]]

  Preloader.update(area_id)

  -- resolve panels and enemies
  local object_ids = Net.list_objects(mission.area_id)
  local type_gid_seen_map = {}

  -- save boss panel for later
  local next_turn_object

  for _, object_id in ipairs(object_ids) do
    local object = Net.get_object_by_id(mission.area_id, object_id)

    if not object then
      -- deleted in a prior pass
      goto continue
    end

    if object.name == "Point of Interest" then
      -- track points of interest for the camera
      mission.points_of_interest[#mission.points_of_interest + 1] = object
      -- delete to reduce map size
      Net.remove_object(mission.area_id, object_id)
    elseif object.name == "Abandon Point" then
      -- delete to reduce map size
      Net.remove_object(mission.area_id, object_id)

      TableUtil.set(
        mission.abandon_points,
        math.floor(object.x),
        math.floor(object.y),
        math.floor(object.z),
        true
      )
    elseif object.type == "Guardian" then
      -- spawning enemies
      local enemy_options = Enemy.options_from(mission, object)
      local enemy = Enemy.from(enemy_options)
      table.insert(mission.enemies, enemy)
    elseif PanelType.ALL[object.type] then
      -- track gid
      local type_map = mission.panel_gid_map[object.type]

      if not type_map then
        type_map = {}
        mission.panel_gid_map[object.type] = type_map
        type_gid_seen_map[object.type] = {}
      end

      local gid_seen_map = type_gid_seen_map[object.type]

      if not gid_seen_map[object.data.gid] then
        gid_seen_map[object.data.gid] = true
        type_map[#type_map + 1] = object.data.gid
      end

      -- create panel
      local panel = mission:create_panel(object)

      if object.custom_properties.Boss then
        -- spawning bosses
        local enemy_options = Enemy.options_from(mission, panel)
        local enemy = Enemy.from(enemy_options)

        mission.boss = enemy
        table.insert(mission.enemies, enemy)

        -- remember boss panel for resolving turn order
        next_turn_object = object
      elseif object.custom_properties.Spawns then
        -- spawning enemies
        local enemy_options = Enemy.options_from(mission, panel)

        local position_id = panel.custom_properties.Position
        local position_object = position_id and Net.get_object_by_id(area_id, position_id)

        if position_object then
          Net.remove_object(area_id, position_id)
          enemy_options.position.x = math.floor(position_object.x)
          enemy_options.position.y = math.floor(position_object.y)
          enemy_options.position.z = position_object.z
        elseif panel.type == PanelType.DARK_HOLE then
          -- we're not allowed to block the dark hole with an enemy
          enemy_options.position = EnemyHelpers.offset_position_with_direction(
            enemy_options.position,
            enemy_options.direction
          )
        end

        local enemy = Enemy.from(enemy_options)

        panel.enemy = enemy
        table.insert(mission.enemies, enemy)
      end
    end

    ::continue::
  end

  -- resolve enemy turn order
  local visited_turns = {}
  local next_turn_order = 0

  while next_turn_object and not visited_turns[next_turn_object.id] do
    visited_turns[next_turn_object.id] = true

    local x, y, z = next_turn_object.x, next_turn_object.y, next_turn_object.z
    local enemy = mission:get_enemy_at(x, y, z)

    if not enemy then
      -- turn order is pointing to a dark hole
      local panel = mission:get_panel_at(x, y, z)
      enemy = panel and panel.enemy
    end

    if enemy then
      enemy.turn_order = next_turn_order
    end

    next_turn_order = next_turn_order + 1

    local next_turn_id = next_turn_object.custom_properties["Next Turn"]

    if next_turn_id then
      next_turn_object = Net.get_object_by_id(area_id, next_turn_id)
    else
      next_turn_object = nil
    end
  end

  mission:sort_enemies()

  -- resolve spawn positions
  local current_spawn = Net.get_object_by_name(area_id, "Spawn Point")
  mission.spawn_positions = { current_spawn }
  local spawns_loaded = {}

  while true do
    local id = current_spawn.custom_properties["Next Spawn"]

    if not id or spawns_loaded[id] then
      -- prevent infinite loops
      break
    end

    spawns_loaded[id] = true

    current_spawn = Net.get_object_by_id(mission.area_id, id)

    if not current_spawn then
      break
    end

    mission.spawn_positions[#mission.spawn_positions + 1] = current_spawn
  end

  -- add event listeners
  local function add_event_listener(name, callback)
    mission.net_listeners[#mission.net_listeners + 1] = { name, callback }
    Net:on(name, callback)
  end

  add_event_listener("tick", function(event)
    mission:tick(event.delta_time)
  end)

  add_event_listener("player_emote", function(event)
    local player = mission.player_map[event.player_id]

    if player then
      player.emote_delay = 3
    end
  end)

  add_event_listener("tile_interaction", function(event)
    mission:handle_tile_interaction(event.player_id, event.x, event.y, event.z, event.button)
  end)

  add_event_listener("object_interaction", function(event)
    mission:handle_object_interaction(event.player_id, event.object_id, event.button)
  end)

  add_event_listener("player_move", function(event)
    mission:handle_player_move(event.player_id, event.x, event.y, event.z)
  end)

  add_event_listener("player_area_transfer", function(event)
    if Net.get_player_area(event.player_id) ~= area_id then
      mission:handle_player_disconnect(event.player_id)
      return
    end

    local player = mission.player_map[event.player_id]

    player:update_order_points_hud()

    if not player or not player.ability or not player.ability.shadow_step then
      -- must be a player with shadow step to continue
      return
    end

    -- exclude optional collisions for shadow step players
    for _, layer in pairs(mission.panels) do
      for _, row in pairs(layer) do
        for _, panel in pairs(row) do
          if panel.collision_id then
            Net.exclude_object_for_player(player.id, panel.collision_id)
          end
        end
      end
    end
  end)

  add_event_listener("player_disconnect", function(event)
    local player = mission.player_map[event.player_id]

    if not player then
      return
    end

    mission:handle_player_disconnect(event.player_id)

    mission.events:emit("player_disconnect", {
      player = player
    })
  end)

  return mission
end

---@param player_id Net.ActorId
---@param ability Liberation.Ability?
function MissionInstance:transfer_player(player_id, ability)
  local spawn_position = self.spawn_positions[#self.players % #self.spawn_positions + 1]

  local player = Player:new(self, player_id)
  player.ability = ability

  self.players[#self.players + 1] = player
  self.player_map[player_id] = player
  self.target_phase.players_joined = self.target_phase.players_joined + 1

  Net.transfer_player(
    player.id,
    self.area_id,
    true,
    spawn_position.x,
    spawn_position.y,
    spawn_position.z,
    spawn_position.custom_properties.Direction
  )
end

---@alias Liberation.KickReason "success" | "failure" | "abandoned"

---@param player_id Net.ActorId
---@param reason Liberation.KickReason
function MissionInstance:kick_player(player_id, reason)
  if not self.player_map[player_id] then
    return
  end

  self:handle_player_disconnect(player_id)

  self.events:emit("player_kicked", {
    player_id = player_id,
    reason = reason
  })
end

function MissionInstance:destroy()
  if self.updating then
    -- mark as needs_disposal to clean up after async functions complete
    self.needs_disposal = true
    return
  end

  for _, id in ipairs(Net.list_bots(self.area_id)) do
    Net.remove_bot(id)
    HealthSprites.remove_sprite(id)
  end

  for i = #self.net_listeners, 1, -1 do
    local name, callback = table.unpack(self.net_listeners[i])
    self.net_listeners[i] = nil

    Net:remove_listener(name, callback)
  end

  self.events:emit("destroyed", {})
end

function MissionInstance:destroying()
  return self.needs_disposal
end

---@package
function MissionInstance:tick(elapsed)
  if not self.liberated and self.ready_count >= #self.players then
    self.ready_count = 0
    -- now we can take a turn !
    take_enemy_turn(self)
  end


  for _, player in ipairs(self.players) do
    if player.emote_delay <= 0 then
      player:emote_state()
    else
      player.emote_delay = player.emote_delay - elapsed
    end
  end
end

local IMMEDIATE_TOKEN = "\x04"

---@package
function MissionInstance:handle_tile_interaction(player_id, x, y, z, button)
  local player = self.player_map[player_id]

  if not player or Net.is_player_in_widget(player_id) then
    return
  end

  if player.completed_turn then
    player:cycle_camera_target()
    return
  end

  if Net.is_player_movement_locked(player_id) then
    return
  end

  local player_position = player:position()
  local panel_under_player = self:get_panel_at(player_position.x, player_position.y, player_position.z)

  if panel_under_player then
    -- Player is moving over dark panels with an ability and thus cannot interact.
    return
  end

  if button == 1 then
    -- Shoulder L
    return
  end

  local panel = self:get_panel_at(x, y, z)
  local panel_already_selected = false

  if panel then
    for _, p in ipairs(self.players) do
      if p.selection:root_panel() == panel then
        panel_already_selected = true
        break
      end
    end
  end

  player:lock_movement()

  if
      not panel or
      (panel_already_selected or not PanelType.LIBERATABLE[panel.type]) or
      not is_adjacent(player_position, { x = x, y = y, z = z })
  then
    -- not interactable
    local spectate_text

    if player.spectate_next_battle then
      spectate_text = "Cancel Spectating"
    else
      spectate_text = "Spectate Next Battle"
    end

    local quiz_promise = player:quiz(
      IMMEDIATE_TOKEN .. spectate_text,
      IMMEDIATE_TOKEN .. "Pass Turn",
      IMMEDIATE_TOKEN .. "Close")

    quiz_promise.and_then(function(response)
      if response == 0 then
        -- Toggle Spectating
        player.spectate_next_battle = not player.spectate_next_battle
        player:emote_state()
        player:unlock_movement()
      elseif response == 1 then
        -- Pass
        player:get_pass_turn_permission()
      elseif response == 2 then
        -- Cancel
        player:unlock_movement()
      end
    end)

    return
  end

  local ability = player.ability
  local can_use_ability = (
    ability ~= nil and
    ability.question and                                 -- no question = passive ability
    not self:get_enemy_at(panel.x, panel.y, panel.z) and -- cant have an enemy standing on this tile
    self.order_points >= ability.cost and
    PanelType.ABILITY_ACTIONABLE[panel.type]
  )

  player.selection:select_panel(panel)

  if ability and can_use_ability then
    local quiz_promise = player:quiz(
      IMMEDIATE_TOKEN .. "Liberation",
      IMMEDIATE_TOKEN .. ability.name,
      IMMEDIATE_TOKEN .. "Pass Turn"
    )

    quiz_promise.and_then(function(response)
      if response == 0 then
        -- Liberate
        liberate_panel(self, player)
      elseif response == 1 then
        -- Ability
        local selection_shape, shape_offset_x, shape_offset_y = ability.generate_shape(self, player)
        player.selection:set_shape(selection_shape, shape_offset_x, shape_offset_y)

        -- ask if we should use the ability
        player:get_ability_permission()
      elseif response == 2 then
        -- Pass
        player.selection:clear()
        player:get_pass_turn_permission()
      end
    end)
    return
  end

  local quiz_promise = player:quiz(
    IMMEDIATE_TOKEN .. "Liberation",
    IMMEDIATE_TOKEN .. "Pass Turn",
    IMMEDIATE_TOKEN .. "Cancel"
  )

  quiz_promise.and_then(function(response)
    if response == 0 then
      -- Liberation
      liberate_panel(self, player)
    elseif response == 1 then
      -- Pass
      player.selection:clear()
      player:get_pass_turn_permission()
    elseif response == 2 then
      -- Cancel
      player.selection:clear()
      player:unlock_movement()
    end
  end)
end

---@package
function MissionInstance:handle_object_interaction(player_id, object_id, button)
  local object = Net.get_object_by_id(self.area_id, object_id)

  if not object then
    -- must have been liberated
    return
  end

  self:handle_tile_interaction(player_id, object.x, object.y, object.z, button)
end

---@package
function MissionInstance:handle_player_move(player_id, x, y, z)
  local player = self.player_map[player_id]

  if not player then
    return
  end

  local abandoning = TableUtil.get(
    self.abandon_points,
    math.floor(x),
    math.floor(y),
    math.floor(z)
  )

  if abandoning == player.abandoning then
    return
  end

  player.abandoning = abandoning

  if abandoning then
    player:question_with_mug("Abandon mission?").and_then(function(response)
      if response == 1 then
        self:kick_player(player_id, "abandoned")
      end
    end)
  end
end

---@package
function MissionInstance:handle_player_disconnect(player_id)
  local player = self.player_map[player_id]

  if not player then return end

  self.player_map[player_id] = nil

  for i, p in ipairs(self.players) do
    if player == p then
      table.remove(self.players, i)
      break
    end
  end

  player:handle_disconnect()
end

function MissionInstance:get_players()
  return self.players
end

-- helper functions
function MissionInstance:get_panel_at(x, y, z)
  z = math.floor(z) + 1

  local layer = self.panels[z]

  if not layer then
    return nil
  end

  y = math.floor(y) + 1
  local row = layer[y]

  if row == nil then
    return nil
  end

  x = math.floor(x) + 1
  return row[x]
end

function MissionInstance:remove_panel(panel)
  local y = math.floor(panel.y) + 1
  local z = math.floor(panel.z) + 1
  local row = self.panels[z][y]

  if row == nil then
    return nil
  end

  local x = math.floor(panel.x) + 1

  if row[x] == nil then
    return
  end

  if panel.collision_id then
    Net.remove_object(self.area_id, panel.collision_id)
  end

  if panel.marker_id then
    Net.remove_object(self.area_id, panel.marker_id)
  end

  Net.remove_object(self.area_id, panel.id)

  row[x] = nil

  if panel.type == PanelType.DARK_HOLE then
    for i, dark_hole in ipairs(self.dark_holes) do
      if panel == dark_hole then
        table.remove(self.dark_holes, i)
        break
      end
    end

    self.events:emit("dark_hole_liberated", {})
  end
end

function MissionInstance:get_enemy_at(x, y, z)
  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  for _, enemy in ipairs(self.enemies) do
    if enemy.x == x and enemy.y == y and enemy.z == z then
      return enemy
    end
  end

  return nil
end

---Resorts enemies based on their turn order
function MissionInstance:sort_enemies()
  table.sort(self.enemies, function(a, b)
    if not a.turn_order then
      -- put `a` after `b`
      return false
    end

    if not b.turn_order then
      -- put `b` after `a`
      return true
    end

    -- sort based on turn_order
    return a.turn_order < b.turn_order
  end)
end

local MARKED_PANEL_STATES = {
  [PanelType.ITEM] = "ITEM",
  [PanelType.TRAP] = "ITEM",
  [PanelType.BONUS] = "BONUS",
  [PanelType.DARK_HOLE] = "DARK_HOLE",
  [PanelType.GATE] = "GATE",
}

---@param object Net.Object
---@return Liberation.PanelObject
function MissionInstance:create_panel(object)
  local new_panel = object --[[@as Liberation.PanelObject]]

  if PanelType.OPTIONAL_COLLISION[object.type] then
    -- we can disable the collision on this panel, so we need to generate one for when it's enabled
    self.collision_template.x = object.x
    self.collision_template.y = object.y
    self.collision_template.z = object.z

    new_panel.collision_id = Net.create_object(self.area_id, self.collision_template)

    for _, player in ipairs(self.players) do
      if player.ability and player.ability.shadow_step then
        Net.exclude_object_for_player(player.id, new_panel.collision_id)
      end
    end
  end

  local marker_state = MARKED_PANEL_STATES[object.type]

  if marker_state then
    if object.type == PanelType.GATE then
      -- special numbered gate case
      local key = object.custom_properties["Gate Key"]

      if key == "1" or key == "2" then
        marker_state = "GATE_" .. key
      end
    end

    self.marker_template.x = object.x + 0.5
    self.marker_template.y = object.y + 0.5
    self.marker_template.z = object.z
    self.marker_template.custom_properties.State = marker_state
    new_panel.marker_id = Net.create_object(self.area_id, self.marker_template)
  end

  -- insert the panel before spawning enemies
  local x = math.floor(object.x) + 1
  local y = math.floor(object.y) + 1
  local z = math.floor(object.z) + 1
  self.panels[z][y][x] = new_panel

  if object.type == PanelType.ITEM then
    -- if it has a set drop, try to apply it.
    if object.custom_properties["Specific Loot"] ~= nil then
      local name = object.custom_properties["Specific Loot"]
      new_panel.loot = Loot[name]

      if type(new_panel.loot) ~= "table" then
        warn("Specified Loot: " .. name .. " does not exist!")
      end
    end

    if not new_panel.loot then
      -- otherwise, give it random loot from the basic pool.
      new_panel.loot = Loot.DEFAULT_POOL[math.random(#Loot.DEFAULT_POOL)]
    end
  elseif object.type == PanelType.DARK_HOLE then
    -- track dark holes for converting indestructible panels
    table.insert(self.dark_holes, new_panel)
  elseif object.type == PanelType.INDESTRUCTIBLE then
    -- track indestructible panels for conversion
    table.insert(self.indestructible_panels, new_panel)
  elseif object.type == PanelType.GATE then
    table.insert(self.gate_panels, new_panel)
  end

  return new_panel
end

---@param points number
function MissionInstance:add_order_points(points)
  self.order_points = math.max(math.min(self.order_points + points, self.MAX_ORDER_POINTS), 0)

  for _, p in ipairs(self.players) do
    p:update_order_points_hud()
  end
end

-- exporting
return MissionInstance
