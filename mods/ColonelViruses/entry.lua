---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")

local VIRUS_POOL = {
    { 1, "BattleNetwork6.Gunner.Enemy",   Rank.V2 }, -- 140 hp, 30 damage
    { 2, "BattleNetwork6.Gunner.Enemy",   Rank.V3 }, -- 220 hp, 50 damage
    { 2, "BattleNetwork.Enemy.Catack",    Rank.V2 }, -- 160 hp, 100 damage
    { 1, "BattleNetwork6.DarkMech.Enemy", Rank.V1 }, -- 180 hp, 100 damager
    { 2, "BattleNetwork5.Gnarly.Enemy",   Rank.V1 }, -- 200 hp, 160 damage
}

---@param encounter Encounter
function encounter_init(encounter, data)
    SharedLib.add_rock_cubes()

    SharedLib.init(encounter, data)

    SharedLib.spawn_viruses(encounter, data, VIRUS_POOL)
end
