---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

local VIRUS_POOL = {
    { 1, "BattleNetwork5.Fatty.Enemy",     Rank.EX }, -- 170 hp, 120 damage
    { 1, "BattleNetwork5.Fatty.Enemy",     Rank.EX }, -- duplicated for higher selection chance
    { 1, "BattleNetwork5.Spiraly.Enemy",   Rank.V1 }, -- 200 hp, 200 damage
    { 1, "BattleNetwork5.Spiraly.Enemy",   Rank.V1 }, -- duplicated for higher selection chance
    { 1, "BattleNetwork5.Draglet.Enemy",   Rank.EX }, -- 260 hp, 140 damage
    { 1, "BattleNetwork5.Draglet.Enemy",   Rank.EX }, -- duplicated for higher selection chance
    { 2, "BattleNetwork3.enemy.KillerEye", Rank.SP }, -- 260 hp, 140 damage
    { 2, "BattleNetwork5.CanRaid.Enemy",   Rank.EX }, -- 180 hp, 100 damage
}

---@param encounter Encounter
function encounter_init(encounter, data)
    SharedLib.add_boulders()

    SharedLib.crack_panels(6)

    LiberationLib.init(encounter, data)

    encounter:set_spectate_on_delete(true)

    SharedLib.spawn_viruses(encounter, data, VIRUS_POOL)
end
