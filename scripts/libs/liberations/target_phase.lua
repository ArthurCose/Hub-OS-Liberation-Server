---@class Liberation._TargetPhase
---@field solo_target_phase number
---@field minimum_phase_target number
---@field players_joined number
local TargetPhase = {}
TargetPhase.__index = TargetPhase

---@return Liberation._TargetPhase
---@param area_id string
function TargetPhase:new(area_id)
  local base_target_phase = tonumber(Net.get_area_custom_property(area_id, "Target Phase")) or 10
  local base_player_count = tonumber(Net.get_area_custom_property(area_id, "Target Player Count")) or 1
  local solo_target_phase = base_target_phase * base_player_count

  local o = {
    solo_target_phase = solo_target_phase,
    minimum_phase_target = tonumber(Net.get_area_custom_property(area_id, "Minimum Target Phase")) or 1,
    players_joined = 0
  }

  setmetatable(o, self)

  return o
end

function TargetPhase:calculate()
  return math.max(self.minimum_phase_target, math.ceil(self.solo_target_phase / self.players_joined))
end

return TargetPhase
