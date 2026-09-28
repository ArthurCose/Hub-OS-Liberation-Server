local FieldUtil = require("field_util")

local LAVA_LAYOUTS = {
    function()
        -- small diagonal
        FieldUtil.set_tile_state(2, 2, TileState.Lava)
        FieldUtil.set_tile_state(3, 1, TileState.Lava)
        -- small diagonal
        FieldUtil.set_tile_state(4, 3, TileState.Lava)
        FieldUtil.set_tile_state(5, 2, TileState.Lava)
    end,
    function()
        -- small horiz
        FieldUtil.set_tile_state(2, 1, TileState.Lava)
        FieldUtil.set_tile_state(3, 1, TileState.Lava)
        -- small horiz
        FieldUtil.set_tile_state(4, 3, TileState.Lava)
        FieldUtil.set_tile_state(5, 3, TileState.Lava)
    end,
    function()
        -- spikes
        FieldUtil.set_tile_state(2, 1, TileState.Lava)
        FieldUtil.set_tile_state(3, 3, TileState.Lava)
        FieldUtil.set_tile_state(4, 1, TileState.Lava)
        FieldUtil.set_tile_state(5, 3, TileState.Lava)
    end,
    function()
        -- teeth
        FieldUtil.set_tile_state(2, 1, TileState.Lava)
        FieldUtil.set_tile_state(2, 2, TileState.Lava)
        FieldUtil.set_tile_state(5, 2, TileState.Lava)
        FieldUtil.set_tile_state(5, 3, TileState.Lava)
    end,
    function()
    end
}

return function()
    LAVA_LAYOUTS[math.random(#LAVA_LAYOUTS)]()

    if math.random(1, 2) == 1 then
        FieldUtil.mirror_tile_states()
    end
end
