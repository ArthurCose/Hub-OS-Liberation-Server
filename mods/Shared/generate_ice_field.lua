local FieldUtil = require("field_util")

-- https://www.therockmanexezone.com/wiki/Nebula_Area_1_(Liberation_Mission)
local function create_ice_square(x, y)
    FieldUtil.set_tile_state(x, y, TileState.Ice)
    FieldUtil.set_tile_state(x, y + 1, TileState.Ice)
    FieldUtil.set_tile_state(x + 1, y, TileState.Ice)
    FieldUtil.set_tile_state(x + 1, y + 1, TileState.Ice)
end

local ICE_LAYOUTS = {
    function()
        -- small line
        FieldUtil.set_tile_state(2, 1, TileState.Ice)
        FieldUtil.set_tile_state(2, 2, TileState.Ice)
        -- small diagonal
        FieldUtil.set_tile_state(5, 2, TileState.Ice)
        FieldUtil.set_tile_state(6, 3, TileState.Ice)
    end,
    function()
        FieldUtil.set_tile_state(1, 2, TileState.Ice)

        FieldUtil.set_tile_state(2, 3, TileState.Ice)
        FieldUtil.set_tile_state(3, 2, TileState.Ice)
        FieldUtil.set_tile_state(3, 3, TileState.Ice)
        FieldUtil.set_tile_state(4, 3, TileState.Ice)

        FieldUtil.set_tile_state(5, 1, TileState.Ice)
        FieldUtil.set_tile_state(5, 2, TileState.Ice)

        FieldUtil.set_tile_state(6, 3, TileState.Ice)
    end,
    function()
        FieldUtil.set_tile_state(1, 1, TileState.Ice)
        FieldUtil.set_tile_state(1, 2, TileState.Ice)

        FieldUtil.set_tile_state(2, 3, TileState.Ice)

        FieldUtil.set_tile_state(3, 2, TileState.Ice)

        FieldUtil.set_tile_state(4, 1, TileState.Ice)
        FieldUtil.set_tile_state(5, 1, TileState.Ice)
        FieldUtil.set_tile_state(5, 2, TileState.Ice)
        FieldUtil.set_tile_state(6, 1, TileState.Ice)
    end,
    function()
        create_ice_square(2, 2)
        create_ice_square(4, 1)
    end,
    function()
        -- straight line with spikes
        for x = 1, Field.width() - 2 do
            FieldUtil.set_tile_state(x, 2, TileState.Ice)
        end

        FieldUtil.set_tile_state(2, 1, TileState.Ice)
        FieldUtil.set_tile_state(3, 3, TileState.Ice)
        FieldUtil.set_tile_state(4, 1, TileState.Ice)
        FieldUtil.set_tile_state(5, 3, TileState.Ice)
    end,
    function()
        create_ice_square(1, 1)
        FieldUtil.set_tile_state(3, 1, TileState.Ice)
        create_ice_square(5, 2)
        FieldUtil.set_tile_state(4, 3, TileState.Ice)
    end,
}

return function()
    ICE_LAYOUTS[math.random(#ICE_LAYOUTS)]()

    if math.random(1, 2) == 1 then
        FieldUtil.mirror_tile_states()
    end
end
