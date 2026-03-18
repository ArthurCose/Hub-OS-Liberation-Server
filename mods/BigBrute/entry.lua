local LiberationLib = require("dev.konstinople.library.liberation")

---@param encounter Encounter
function encounter_init(encounter, data)
    LiberationLib.init(encounter, data)

    encounter:set_spectate_on_delete(true)

    local rank = Rank[data.rank] -- utilizing rank from the server
    encounter:create_spawner("BattleNetwork5.Character.BigBrute", rank)
        :spawn_at(5, 2)
        :mutate(function(entity)
            -- Restores health from data,
            -- and sends the final health back to the server when battle ends
            LiberationLib.sync_enemy_health(entity, encounter, data)
        end)
end
