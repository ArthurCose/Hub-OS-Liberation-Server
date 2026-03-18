local Selection = require("scripts/libs/liberations/selections/selection")
local Direction = require("scripts/libs/direction")
local PanelType = require("scripts/libs/liberations/panel_type")

local TEXTURE_PATH = "/server/assets/liberations/bots/selection.png"
local ANIMATION_PATH = "/server/assets/liberations/bots/selection.animation"

-- private functions
local function resolve_selection_direction(player_pos, panel_object)
  local x_diff = panel_object.x + panel_object.height / 2 - player_pos.x
  local y_diff = panel_object.y + panel_object.height / 2 - player_pos.y
  return Direction.diagonal_from_offset(x_diff, y_diff)
end

-- public
---@class Liberation.PlayerSelection
---@field private player_id Net.ActorId
---@field private instance Liberation.MissionInstance
---@field private selection Liberation._Selection
local PlayerSelection = {}

---@return Liberation.PlayerSelection
function PlayerSelection:new(instance, player_id)
  local player_selection = {
    player_id = player_id,
    instance = instance,
    root_panel = nil,
    selection = Selection:new(instance),
  }

  setmetatable(player_selection, self)
  self.__index = self

  local function filter(x, y, z)
    local panel = instance:get_panel_at(x, y, z)

    if panel == nil then
      return false
    end

    if panel == player_selection.root_panel then
      return true
    end

    for _, enemy in ipairs(instance.enemies) do
      if x == enemy.x and y == enemy.y and z == enemy.z then
        -- can't liberate a panel with an enemy standing on it
        -- unless it is the root_panel
        return false
      end
    end

    return (
      panel.type == PanelType.DARK or
      panel.type == PanelType.ITEM
    )
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

function PlayerSelection:select_panel(panel_object)
  self.root_panel = panel_object

  local player_pos = Net.get_player_position(self.player_id)
  local direction = resolve_selection_direction(player_pos, panel_object)
  self.selection:move(player_pos, direction)
  self.selection:set_shape({ { 1 } })
  self.selection:remove_indicators()
  self.selection:indicate()
end

-- shape = [m][n] bool array, n being odd, just below bottom center is player position
function PlayerSelection:set_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:set_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:remove_indicators()
  self.selection:indicate()
end

-- shape = [m][n] bool array, n being odd, just below bottom center is player position
function PlayerSelection:merge_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:merge_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:remove_indicators()
  self.selection:indicate()
end

function PlayerSelection:get_panels()
  local panels = {}

  if not self.root_panel then
    return panels
  end

  self.selection:for_each_tile(function(x, y, z)
    panels[#panels + 1] = self.instance:get_panel_at(x, y, z)
  end)

  return panels
end

function PlayerSelection:clear()
  self.selection:remove_indicators()
  self.root_panel = nil
end

-- todo: add an update function that is called when a player liberates a panel? may fix issues with overlapped panels

-- exports
return PlayerSelection
