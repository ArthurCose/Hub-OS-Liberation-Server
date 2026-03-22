---@class dev.konstinople.LiberationServer.Shared
local Lib = {}

---@param encounter Encounter
---@param pool [number, string, Rank][] will subtract and delete exhausted options
---@param tile Tile
local function spawn_from_pool(encounter, pool, tile)
    local index = math.random(#pool)
    local details = pool[index]

    -- update count
    details[1] = details[1] - 1

    if details[1] == 0 then
        table.remove(pool, index)
    end

    local _, id, rank = table.unpack(details)

    encounter:create_spawner(id, rank)
        :spawn_at(tile:x(), tile:y())
end

---Returns unused enemy tiles for spawning obstacles
---@param encounter Encounter
---@param pool [number, string, Rank][] will be modified
function Lib.spawn_viruses(encounter, data, pool)
    local FIELD_W = Field.width()
    local claimed_tiles = {}
    local pending_spawn = {}

    ---@param x number
    ---@param y number
    local function hash_position(x, y)
        return FIELD_W * y + x
    end

    ---@param tile Tile
    local function hash_tile(tile)
        return hash_position(tile:x(), tile:y())
    end

    local function claim_in_col(x)
        local remaining_checks = { 1, 2, 3 }

        for _ = 1, 3 do
            -- check random rows
            local y = table.remove(remaining_checks, math.random(#remaining_checks))
            local hash = hash_position(x, y)

            -- avoid sharing a row with direct neighbors
            if
                not claimed_tiles[hash] and
                not claimed_tiles[hash_position(x - 1, y)] and
                not claimed_tiles[hash_position(x + 1, y)] and
                not claimed_tiles[hash_position(x, y - 1)] and
                not claimed_tiles[hash_position(x, y + 1)]
            then
                claimed_tiles[hash] = true
                pending_spawn[#pending_spawn + 1] = { x, y }
                return true
            end
        end

        return false
    end

    if data.terrain == "advantage" then
        local function claim_v_formation(col_a, col_b)
            local tiles = {
                Field.tile_at(col_a, 1),
                Field.tile_at(col_b, 2),
                Field.tile_at(col_a, 3),
            }

            for _, tile in ipairs(tiles) do
                local hash = hash_tile(tile)
                claimed_tiles[hash] = true
                pending_spawn[#pending_spawn + 1] = { tile:x(), tile:y() }
            end
        end

        if math.random(1, 2) == 1 then
            claim_v_formation(5, 6)
        else
            claim_v_formation(6, 5)
        end
    elseif data.terrain == "surrounded" then
        claim_in_col(5)
        claim_in_col(6)
        claim_in_col(1)

        if math.random(1, 2) == 1 then
            claim_in_col(2)
        end
    else
        -- normal terrain, avoid spawning more than one enemy at the front to stay difficult
        -- disadvantage uses this same logic to avoid spawning any enemies in the front
        local col_pool = { 4, 5, 5, 6, 6 }

        local spawns = 0
        while spawns < 3 do
            local x = table.remove(col_pool, math.random(#col_pool))

            if claim_in_col(x) then
                spawns = spawns + 1
            end
        end
    end

    -- sort to avoid randomized intro order
    table.sort(pending_spawn, function(a, b)
        return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
    end)

    for _, position in ipairs(pending_spawn) do
        local tile = Field.tile_at(position[1], position[2]) --[[@as Tile]]
        spawn_from_pool(encounter, pool, tile)
    end

    -- return unused tiles for spawning obstacles
    return Field.find_tiles(function(tile)
        return
            tile:team() == Team.Blue
            and not tile:is_edge()
            and not claimed_tiles[hash_tile(tile)]
    end)
end

function Lib.generate_ice_field()
    require("generate_ice_field")()
end

return Lib
