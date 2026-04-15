---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

local VIRUS_POOL = {
    { 2, "BattleNetwork6.Mettaur.Enemy",  Rank.Rare1 }, -- 120 hp, 50 damage, cracks panels, purple
    { 1, "BattleNetwork5.Gnarly.Enemy",   Rank.V3 },    -- 200 hp, 160 damage
    { 1, "BattleNetwork5.Gnarly.Enemy",   Rank.V3 },    -- duplicated for higher selection chance
    { 1, "BattleNetwork5.Gnarly.Enemy",   Rank.EX },    -- 240 hp, 200 damage
    { 1, "BattleNetwork5.Cacter.Enemy",   Rank.V1 },    -- 230 hp, 150 damage
    { 1, "BattleNetwork5.Bugtank3.Enemy", Rank.V1 },    -- 240 hp, 200 damage
    { 2, "BattleNetwork5.Drixa.Enemy",    Rank.V1 },    -- 260 hp, 160 damage
}

---@param encounter Encounter
function encounter_init(encounter, data)
    -- generating before initializing the liberation lib to allow it to shift spawns based on our panels
    SharedLib.generate_poison_field()

    LiberationLib.init(encounter, data)

    encounter:set_spectate_on_delete(true)

    SharedLib.spawn_viruses(encounter, data, VIRUS_POOL)
end
