local Selection = require("scripts/libs/liberations/selections/selection")

local TEXTURE_PATH = "/server/assets/liberations/bots/selection.png"
local ANIMATION_PATH = "/server/assets/liberations/bots/selection.animation"

---@class Liberation.AttackSelection
---@field package instance Liberation.MissionInstance
---@field package selection Liberation.Selection
local AttackSelection = {}

---@return Liberation.AttackSelection
function AttackSelection:new(instance)
  local attack_selection = {
    instance = instance,
    selection = Selection:new(instance)
  }

  setmetatable(attack_selection, self)
  self.__index = self

  attack_selection.selection:set_filter(function(x, y, z)
    local tile = Net.get_tile(instance.area_id, x, y, z)

    return tile.gid > 0
  end)

  attack_selection.selection:set_indicator({
    texture_path = TEXTURE_PATH,
    animation_path = ANIMATION_PATH,
    state = "ATTACK",
  })

  return attack_selection
end

---@param shape number[][] [m][n] bool array, n being odd, just below bottom center is the enemy position
---@param shape_offset_x number
---@param shape_offset_y number
function AttackSelection:set_shape(shape, shape_offset_x, shape_offset_y)
  self.selection:set_shape(shape, shape_offset_x, shape_offset_y)
end

---@param x number
---@param y number
---@param z number
---@param direction string
function AttackSelection:move(x, y, z, direction)
  self.selection:move(x, y, z, direction)
end

-- returns players that collide
---@return Liberation.Player[]
function AttackSelection:detect_players()
  local players = {}

  for _, player in ipairs(self.instance.players) do
    local x, y, z = player:position_multi()

    if player:health() ~= 0 and self.selection:is_within(x, y, z) then
      players[#players + 1] = player
    end
  end

  return players
end

function AttackSelection:indicate()
  self.selection:indicate()
end

function AttackSelection:remove_indicators()
  -- delete objects
  self.selection:remove_indicators()
end

function AttackSelection:is_within(x, y, z)
  return self.selection:is_within(x, y, z)
end

---@param callback fun(x: number, y: number, z: number)
function AttackSelection:for_each_tile(callback)
  self.selection:for_each_tile(callback)
end

-- exports
return AttackSelection
