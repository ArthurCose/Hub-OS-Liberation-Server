---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

local VIRUS_POOL = {
    { 1, "BattleNetwork5.Dominerd.Enemy",  Rank.V1 },    -- 160 hp, 60 damage
    { 1, "BattleNetwork5.Dominerd.Enemy",  Rank.V1 },    -- duplicated for higher selection chance
    { 2, "BattleNetwork5.CanRaid.Enemy",   Rank.EX },    -- 180 hp, 100 damage
    -- { 1, "BattleNetwork6.Swordy.Enemy",   Rank.Rare1 }, -- 160 hp, 90 damage
    { 2, "BattleNetwork6.Swordy.Enemy",    Rank.Rare2 }, -- 220 hp, 120 damage
    { 2, "BattleNetwork6.BigHat.Enemy",    Rank.V2 },    -- 150 hp, 50 damage
    { 1, "BattleNetwork6.BigHat.Enemy",    Rank.SP },    -- 250 hp, 100 damage
    { 1, "BattleNetwork3.enemy.KillerEye", Rank.SP },    -- 230 hp, 200 damage
}

---@param encounter Encounter
function encounter_init(encounter, data)
    SharedLib.crack_panels(6)

    LiberationLib.init(encounter, data)

    encounter:set_spectate_on_delete(true)

    SharedLib.spawn_viruses(encounter, data, VIRUS_POOL)
end
