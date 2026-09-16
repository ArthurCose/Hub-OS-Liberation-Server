---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")

local VIRUS_POOL = {
    { 1, "BattleNetwork5.Spiraly.Enemy",   Rank.V1 }, -- 200 hp, 200 damage
    { 1, "BattleNetwork5.Spiraly.Enemy",   Rank.EX }, -- 230 hp, 250 damage
    -- { 2, "BattleNetwork.Enemy.Catack",     Rank.V2 }, -- 160 hp, 100 damage
    { 1, "BattleNetwork5.CanRaid.Enemy",   Rank.EX }, -- 180 hp, 100 damage
    { 1, "BattleNetwork5.CanRaid.Enemy",   Rank.EX }, -- duplicated for higher selection chance
    -- { 1, "BattleNetwork5.Canlada.Enemy",   Rank.EX }, -- 280 hp, 200 damage
    { 1, "BattleNetwork3.enemy.KillerEye", Rank.SP }, -- 260 hp, 140 damage
    { 1, "BattleNetwork5.Handum.Enemy",    Rank.EX }, --220 hp, 200 damage
    { 1, "BattleNetwork5.Handum.Enemy",    Rank.EX }, --duplicated for higher selection chance
}

---@param encounter Encounter
function encounter_init(encounter, data)
    SharedLib.add_ice_cubes()
    SharedLib.init(encounter, data)
    SharedLib.generate_ice_field()

    SharedLib.spawn_viruses(encounter, data, VIRUS_POOL)
end
