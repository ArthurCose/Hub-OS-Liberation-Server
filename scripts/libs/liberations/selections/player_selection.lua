local Selection = require("scripts/libs/liberations/selections/selection")
local Direction = require("scripts/libs/direction")
local PanelClass = require("scripts/libs/liberations/panel_class")

local TEXTURE_PATH = "/server/assets/liberations/bots/selection.png"
local ANIMATION_PATH = "/server/assets/liberations/bots/selection.animation"

-- private functions
local function resolve_selection_direction(panel, player_x, player_y)
  local x_diff = panel.x + panel.height / 2 - player_x
  local y_diff = panel.y + panel.height / 2 - player_y
  return Direction.diagonal_from_offset(x_diff, y_diff)
end

-- public
---@class Liberation.PlayerSelection
---@field private player Liberation.Player
---@field private instance Liberation.MissionInstance
---@field private selection Liberation.Selection
---@field private _root_panel Liberation.PanelObject
local PlayerSelection = {}

---@return Liberation.PlayerSelection
function PlayerSelection:new(player)
  local instance = player:instance()

  local player_selection = {
    player = player,
    instance = instance,
    _root_panel = nil,
    selection = Selection:new(instance),
  }

  setmetatable(player_selection, self)
  self.__index = self

  local function filter(x, y, z)
    local panel = instance:get_panel_at(x, y, z)

    if panel == nil then
      return false
    end

    if panel == player_selection._root_panel then
      return true
    end

    for _, enemy in ipairs(instance.enemies) do
      if x == enemy.x and y == enemy.y and z == enemy.z then
        -- can't liberate a panel with an enemy standing on it
        -- unless it is the _root_panel
        return false
      end
    end

    return PanelClass.ABILITY_ACTIONABLE[panel.class] ~= nil
  end

  player_selection.selection:set_filter(filter)
  player_selection.selection:set_indicator({
    texture_path = TEXTURE_PATH,
    animation_path = ANIMATION_PATH,
    state = "SELECTED",
    offset_x = 1,
    offset_y = 1,
  })

  return player_selection
end

function PlayerSelection:indicator_template()
  return self.selection:indicator_template()
end

---@param panel Liberation.PanelObject
---@param player_x number?
---@param player_y number?
---@param player_z number?
function PlayerSelection:select_panel(panel, player_x, player_y, player_z)
  self._root_panel = panel

  if not player_x or not player_y or not player_z then
    player_x, player_y, player_z = self.player:floored_position_multi()
  end

  local direction = resolve_selection_direction(panel, player_x, player_y)

  self.selection:move(player_x, player_y, player_z, direction)
  self.selection:set_shape({ { 1 } })
  self.selection:remove_indicators()
  self.selection:indicate()
end

function PlayerSelection:root_panel()
  return self._root_panel
end

---@param shape number[][] [m][n] bool array, m moves away from the player, n should be odd
---@param shape_offset_x? number
---@param shape_offset_y? number
function PlayerSelection:set_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:set_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:remove_indicators()
  self.selection:indicate()
end

---@param shape number[][] [m][n] bool array, m moves away from the player, n should be odd
---@param shape_offset_x number
---@param shape_offset_y number
function PlayerSelection:merge_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:merge_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:remove_indicators()
  self.selection:indicate()
end

local BONUS_SHAPE = {
  { 1, 1, 1 },
  { 1, 0, 1 },
  { 1, 1, 1 }
}

function PlayerSelection:merge_bonus_shape()
  self:merge_shape(BONUS_SHAPE, 0, -2)
end

---@return Liberation.PanelObject[]
function PlayerSelection:get_panels()
  local panels = {}

  if not self._root_panel then
    return panels
  end

  self.selection:for_each_tile(function(x, y, z)
    panels[#panels + 1] = self.instance:get_panel_at(x, y, z)
  end)

  return panels
end

function PlayerSelection:clear()
  self.selection:remove_indicators()
  self._root_panel = nil
end

-- todo: add an update function that is called when a player liberates a panel? may fix issues with overlapped panels

-- exports
return PlayerSelection
