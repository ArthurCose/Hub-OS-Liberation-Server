local FieldUtil = {}

---@type [number, number, TileState][]
local pending_tile_state_changes = {}

local state_delay = 5
local artifact = Artifact.new()
artifact:create_component(Lifetime.Scene).on_update_func = function()
  state_delay = state_delay - 1

  if state_delay > 0 then
    return
  end

  artifact:delete()

  for _, change in ipairs(pending_tile_state_changes) do
    local x, y, state = table.unpack(change)
    local tile = Field.tile_at(x, y)

    if tile then
      tile:set_state(state)
    end
  end
end

---Delay most tile state changes to prevent overwrite from stage augments
---@param x number
---@param y number
---@param state TileState
function FieldUtil.set_tile_state(x, y, state)
  pending_tile_state_changes[#pending_tile_state_changes + 1] = { x, y, state }
end

---Horizontally mirrors pending tile state changes
function FieldUtil.mirror_tile_states()
  for _, change in ipairs(pending_tile_state_changes) do
    change[1] = Field.width() - change[1] - 1
  end
end

return FieldUtil
