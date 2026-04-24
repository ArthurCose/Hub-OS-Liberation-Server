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
    local reserved = {}

    ---@param x number
    ---@param y number
    local function hash_position(x, y)
        return FIELD_W * y + x
    end

    ---@param tile Tile
    local function hash_tile(tile)
        return hash_position(tile:x(), tile:y())
    end

    Field.find_tiles(function(tile)
        if tile:is_reserved() then
            reserved[hash_tile(tile)] = true
        end
        return false
    end)

    local function claim_in_col(x)
        local remaining_checks = { 1, 2, 3 }

        for _ = 1, 3 do
            -- check random rows
            local y = table.remove(remaining_checks, math.random(#remaining_checks))
            local hash = hash_position(x, y)

            -- avoid sharing a row with direct neighbors
            if
                not reserved[hash] and
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
        local attempts = 1

        local function claim_v_formation(col_a, col_b)
            local tiles = {
                Field.tile_at(col_a, 1),
                Field.tile_at(col_b, 2),
                Field.tile_at(col_a, 3),
            }

            if attempts == 1 then
                for _, tile in ipairs(tiles) do
                    if tile:is_reserved() then
                        attempts = 2
                        claim_v_formation(col_b, col_a)
                        return
                    end
                end
            end

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

---@param encounter Encounter
---@param id string
---@param rank Rank
function Lib.shuffle_dark_hole_guardians(encounter, id, rank)
    local demoted_rank_map = {
        [Rank.V3] = Rank.V1,
        [Rank.V4] = Rank.V2,
        [Rank.V5] = Rank.V3,
        [Rank.V6] = Rank.V4,
    }

    local rank_b = demoted_rank_map[rank] or Rank.V1

    if math.random(2) == 1 then
        rank_b, rank = rank, rank_b
    end

    if math.random(2) == 1 then
        encounter:create_spawner(id, rank)
            :spawn_at(1, 1)

        encounter:create_spawner(id, rank_b)
            :spawn_at(6, 3)
    else
        encounter:create_spawner(id, rank)
            :spawn_at(1, 3)

        encounter:create_spawner(id, rank_b)
            :spawn_at(6, 1)
    end
end

function Lib.buff_terrain(data)
    local TERRAIN_BOOST = {
        advantage = "even",
        even = "disadvantage",
        disadvantage = "surrounded",
        surrounded = "surrounded",
    }

    data.terrain = TERRAIN_BOOST[data.terrain]
end

---@param character Entity
local function nerf_stun(character)
    local MAX_STUN_TIME = 45
    local component = character:create_component(Lifetime.ActiveBattle)

    component.on_update_func = function()
        if not character:is_inactionable() then
            return
        end

        local remaining_blockers = Hit.action_blockers()
        local flag = 1

        while remaining_blockers ~= 0 do
            if remaining_blockers & 1 ~= 0 then
                local remaining_time = character:remaining_status_time(flag --[[@as Hit]])

                if remaining_time > MAX_STUN_TIME then
                    character:set_remaining_status_time(flag --[[@as Hit]], MAX_STUN_TIME)
                end
            end

            remaining_blockers = remaining_blockers >> 1
            flag = flag << 1
        end
    end
end

---@param character Entity
local function guard_area(character)
    local grab_revenge = CardProperties.from_package("BattleNetwork6.Class01.Standard.167")
    local revenge_queued = false

    local component = character:create_component(Lifetime.ActiveBattle)
    component.on_update_func = function()
        if revenge_queued then
            return
        end

        local extra_count = 0
        local stolen_count = 0

        local team = character:team()
        Field.find_tiles(function(tile)
            if tile:is_edge() then
                return false
            end

            if tile:original_team() ~= team then
                return false
            end

            if tile:team() ~= team then
                stolen_count = stolen_count + 1
                return false
            end

            local behind_tile = tile:get_tile(Direction.reverse(tile:facing()), 1)

            if behind_tile and behind_tile:is_edge() then
                return false
            end

            extra_count = extra_count + 1

            return false
        end)

        local needs_revenge = stolen_count > 0 and extra_count <= 2

        if not needs_revenge then
            -- wait for more area to be lost
            return
        end

        local spell = Spell.new(character:team())

        spell.on_spawn_func = function()
            spell:queue_action(Action.from_card(spell, grab_revenge) --[[@as Action]])
        end

        spell.on_update_func = function()
            if not spell:has_actions() then
                spell:delete()
                revenge_queued = false
            end
        end

        spell:on_erase(function()
            revenge_queued = false
        end)

        Field.spawn(spell, 0, 0)

        revenge_queued = true
    end
end

---@param character Entity
function Lib.buff_boss(character)
    nerf_stun(character)
    guard_area(character)
end

function Lib.generate_ice_field()
    require("generate_ice_field")()
end

function Lib.generate_poison_field()
    require("generate_poison_field")()
end

function Lib.generate_beach_field()
    require("generate_beach_field")()
end

function Lib.add_boulders()
    require("add_boulders")()
end

function Lib.crack_panels(n)
    ---@type Tile[]
    local tiles = {}

    for y = 1, 3 do
        for x = 1, 6 do
            tiles[#tiles + 1] = Field.tile_at(x, y)
        end
    end

    n = n or 6
    for _ = 1, n do
        local tile = table.remove(tiles, math.random(#tiles))
        tile:set_state(TileState.Cracked)
    end
end

return Lib
