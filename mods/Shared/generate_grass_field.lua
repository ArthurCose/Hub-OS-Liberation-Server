local FieldUtil = require("field_util")

local function create_grass_square(x, y)
    FieldUtil.set_tile_state(x, y, TileState.Grass)
    FieldUtil.set_tile_state(x, y + 1, TileState.Grass)
    FieldUtil.set_tile_state(x + 1, y, TileState.Grass)
    FieldUtil.set_tile_state(x + 1, y + 1, TileState.Grass)
end

local GRASS_LAYOUTS = {
    function()
        create_grass_square(1, 1)
        FieldUtil.set_tile_state(3, 1, TileState.Grass)
        FieldUtil.set_tile_state(1, 3, TileState.Grass)

        create_grass_square(5, 2)
        FieldUtil.set_tile_state(6, 1, TileState.Grass)
        FieldUtil.set_tile_state(4, 3, TileState.Grass)
    end,
    function()
        -- Ts
        FieldUtil.set_tile_state(1, 1, TileState.Grass)
        FieldUtil.set_tile_state(2, 1, TileState.Grass)
        FieldUtil.set_tile_state(2, 2, TileState.Grass)
        FieldUtil.set_tile_state(3, 1, TileState.Grass)

        FieldUtil.set_tile_state(4, 3, TileState.Grass)
        FieldUtil.set_tile_state(5, 3, TileState.Grass)
        FieldUtil.set_tile_state(5, 2, TileState.Grass)
        FieldUtil.set_tile_state(6, 3, TileState.Grass)
    end,
    function()
        -- zipper
        FieldUtil.set_tile_state(1, 1, TileState.Grass)
        FieldUtil.set_tile_state(3, 1, TileState.Grass)
        FieldUtil.set_tile_state(5, 1, TileState.Grass)

        FieldUtil.set_tile_state(2, 3, TileState.Grass)
        FieldUtil.set_tile_state(4, 3, TileState.Grass)
        FieldUtil.set_tile_state(6, 3, TileState.Grass)
    end,
    function()
        -- wider zipper
        FieldUtil.set_tile_state(1, 1, TileState.Grass)
        FieldUtil.set_tile_state(2, 1, TileState.Grass)
        FieldUtil.set_tile_state(4, 1, TileState.Grass)
        FieldUtil.set_tile_state(5, 1, TileState.Grass)

        FieldUtil.set_tile_state(2, 3, TileState.Grass)
        FieldUtil.set_tile_state(3, 3, TileState.Grass)
        FieldUtil.set_tile_state(5, 3, TileState.Grass)
        FieldUtil.set_tile_state(6, 3, TileState.Grass)
    end,
    function()
    end
}

return function()
    GRASS_LAYOUTS[math.random(#GRASS_LAYOUTS)]()

    if math.random(1, 2) == 1 then
        FieldUtil.mirror_tile_states()
    end

    FieldUtil.apply()
end
