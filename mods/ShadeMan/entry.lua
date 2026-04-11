---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

---@param encounter Encounter
function encounter_init(encounter, data)
    SharedLib.buff_terrain(data)
    LiberationLib.init(encounter, data)
    SharedLib.generate_poison_field()

    encounter:set_spectate_on_delete(true)

    local rank = Rank[data.rank] -- utilizing rank from the server
    encounter:create_spawner("BattleNetwork5.ShadeMan.Enemy", rank)
        :spawn_at(5, 2)
        :mutate(function(entity)
            -- Restores health from data,
            -- and sends the final health back to the server when battle ends
            LiberationLib.sync_enemy_health(entity, encounter, data)
            SharedLib.buff_boss(entity)
        end)
end
