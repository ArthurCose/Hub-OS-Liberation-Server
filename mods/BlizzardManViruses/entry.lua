---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

local VIRUS_POOL = {
    { 2, "BattleNetwork3.enemy.Gloomer",  Rank.V1 }, -- 140 hp, 60 damage
    { 2, "BattleNetwork6.Mettaur.Enemy",  Rank.V3 }, -- 120 hp, 50 damage, blue
    { 1, "BattleNetwork6.Mettaur.Enemy",  Rank.SP }, -- 160 hp, 70 damage, grey / blue symbols
    { 1, "BattleNetwork6.Swordy.Enemy",   Rank.V3 }, -- 160 hp, 80 damage
    { 2, "BattleNetwork5.Cactroll.Enemy", Rank.EX }, -- 190 hp, 100 damage
}

---@param encounter Encounter
function encounter_init(encounter, data)
    LiberationLib.init(encounter, data)

    encounter:set_spectate_on_delete(true)

    SharedLib.generate_ice_field()
    SharedLib.spawn_viruses(encounter, data, VIRUS_POOL)
end
