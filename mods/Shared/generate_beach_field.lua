local FieldUtil = require("field_util")

local function create_sand_square(x, y)
    FieldUtil.set_tile_state(x, y, TileState.Sand)
    FieldUtil.set_tile_state(x, y + 1, TileState.Sand)
    FieldUtil.set_tile_state(x + 1, y, TileState.Sand)
    FieldUtil.set_tile_state(x + 1, y + 1, TileState.Sand)
end

local SAND_LAYOUTS = {
    function()
        create_sand_square(1, 1)
        FieldUtil.set_tile_state(3, 1, TileState.Sand)
        FieldUtil.set_tile_state(1, 3, TileState.Sand)

        create_sand_square(5, 2)
        FieldUtil.set_tile_state(6, 1, TileState.Sand)
        FieldUtil.set_tile_state(4, 3, TileState.Sand)
    end,
    function()
        -- Ts
        FieldUtil.set_tile_state(1, 1, TileState.Sand)
        FieldUtil.set_tile_state(2, 1, TileState.Sand)
        FieldUtil.set_tile_state(2, 2, TileState.Sand)
        FieldUtil.set_tile_state(3, 1, TileState.Sand)

        FieldUtil.set_tile_state(4, 3, TileState.Sand)
        FieldUtil.set_tile_state(5, 3, TileState.Sand)
        FieldUtil.set_tile_state(5, 2, TileState.Sand)
        FieldUtil.set_tile_state(6, 3, TileState.Sand)
    end,
    function()
        -- zipper
        FieldUtil.set_tile_state(1, 1, TileState.Sand)
        FieldUtil.set_tile_state(3, 1, TileState.Sand)
        FieldUtil.set_tile_state(5, 1, TileState.Sand)

        FieldUtil.set_tile_state(2, 3, TileState.Sand)
        FieldUtil.set_tile_state(4, 3, TileState.Sand)
        FieldUtil.set_tile_state(6, 3, TileState.Sand)
    end,
    function()
        -- wider zipper
        FieldUtil.set_tile_state(1, 1, TileState.Sand)
        FieldUtil.set_tile_state(2, 1, TileState.Sand)
        FieldUtil.set_tile_state(4, 1, TileState.Sand)
        FieldUtil.set_tile_state(5, 1, TileState.Sand)

        FieldUtil.set_tile_state(2, 3, TileState.Sand)
        FieldUtil.set_tile_state(3, 3, TileState.Sand)
        FieldUtil.set_tile_state(5, 3, TileState.Sand)
        FieldUtil.set_tile_state(6, 3, TileState.Sand)
    end,
}

return function()
    SAND_LAYOUTS[math.random(#SAND_LAYOUTS)]()

    if math.random(1, 2) == 1 then
        FieldUtil.mirror_tile_states()
    end

    FieldUtil.apply()
end
