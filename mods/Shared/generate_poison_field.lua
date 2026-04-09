local FieldUtil = require("field_util")

local POISON_LAYOUTS = {
    function()
        -- - _
        FieldUtil.set_tile_state(2, 1, TileState.Poison)
        FieldUtil.set_tile_state(3, 1, TileState.Poison)
        FieldUtil.set_tile_state(4, 1, TileState.Poison)

        FieldUtil.set_tile_state(3, 3, TileState.Poison)
        FieldUtil.set_tile_state(4, 3, TileState.Poison)
        FieldUtil.set_tile_state(5, 3, TileState.Poison)
    end,
    function()
        -- -_-
        FieldUtil.set_tile_state(1, 1, TileState.Poison)
        FieldUtil.set_tile_state(2, 1, TileState.Poison)

        FieldUtil.set_tile_state(3, 3, TileState.Poison)
        FieldUtil.set_tile_state(4, 3, TileState.Poison)

        FieldUtil.set_tile_state(5, 1, TileState.Poison)
        FieldUtil.set_tile_state(6, 1, TileState.Poison)
    end,
    function()
        -- _-_
        FieldUtil.set_tile_state(1, 3, TileState.Poison)
        FieldUtil.set_tile_state(2, 3, TileState.Poison)

        FieldUtil.set_tile_state(3, 1, TileState.Poison)
        FieldUtil.set_tile_state(4, 1, TileState.Poison)

        FieldUtil.set_tile_state(5, 3, TileState.Poison)
        FieldUtil.set_tile_state(6, 3, TileState.Poison)
    end,
    function()
        -- ><
        FieldUtil.set_tile_state(2, 1, TileState.Poison)
        FieldUtil.set_tile_state(2, 3, TileState.Poison)

        FieldUtil.set_tile_state(3, 2, TileState.Poison)
        FieldUtil.set_tile_state(4, 2, TileState.Poison)

        FieldUtil.set_tile_state(5, 1, TileState.Poison)
        FieldUtil.set_tile_state(5, 3, TileState.Poison)
    end,
    function()
        -- stalactite stalagmite
        FieldUtil.set_tile_state(2, 1, TileState.Poison)
        FieldUtil.set_tile_state(2, 2, TileState.Poison)

        FieldUtil.set_tile_state(5, 2, TileState.Poison)
        FieldUtil.set_tile_state(5, 3, TileState.Poison)
    end,
    function()
        -- stalactite stalagmite stalactite
        FieldUtil.set_tile_state(1, 1, TileState.Poison)
        FieldUtil.set_tile_state(1, 2, TileState.Poison)

        FieldUtil.set_tile_state(3, 2, TileState.Poison)
        FieldUtil.set_tile_state(3, 3, TileState.Poison)

        FieldUtil.set_tile_state(5, 1, TileState.Poison)
        FieldUtil.set_tile_state(5, 2, TileState.Poison)
    end,
    function()
        -- stalagmite stalactite stalagmite
        FieldUtil.set_tile_state(1, 2, TileState.Poison)
        FieldUtil.set_tile_state(1, 3, TileState.Poison)

        FieldUtil.set_tile_state(3, 1, TileState.Poison)
        FieldUtil.set_tile_state(3, 2, TileState.Poison)

        FieldUtil.set_tile_state(5, 2, TileState.Poison)
        FieldUtil.set_tile_state(5, 3, TileState.Poison)
    end,
}

return function()
    POISON_LAYOUTS[math.random(#POISON_LAYOUTS)]()

    if math.random(1, 2) == 1 then
        FieldUtil.mirror_tile_states()
    end
end
