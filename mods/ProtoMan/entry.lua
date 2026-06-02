---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

---@param encounter Encounter
function encounter_init(encounter, data)
    SharedLib.buff_terrain(data)
    SharedLib.crack_panels(6)

    SharedLib.init(encounter, data)

    encounter:set_spectate_on_delete(true)

    local rank = Rank[data.rank] -- utilizing rank from the server
    encounter:create_spawner("Tim.ProtoMan.Enemy", rank)
        :spawn_at(6, 2)
        :mutate(function(entity)
            entity:set_name("DarkProt")
            entity:hide_rank()

            SharedLib.darken(entity)

            -- Restores health from data,
            -- and sends the final health back to the server when battle ends
            LiberationLib.sync_enemy_health(entity, encounter, data)
            SharedLib.buff_boss(entity)
        end)
end
