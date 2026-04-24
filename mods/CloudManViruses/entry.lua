---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

local VIRUS_POOL = {
    { 1, "BattleNetwork5.Fatty.Enemy",     Rank.EX }, -- 170 hp, 120 damage
    { 2, "BattleNetwork5.Spiraly.Enemy",   Rank.V1 }, -- 200 hp, 200 damage
    { 2, "BattleNetwork5.Draglet.Enemy",   Rank.EX }, -- 260 hp, 140 damage
    { 2, "BattleNetwork3.enemy.KillerEye", Rank.SP }, -- 260 hp, 140 damage
}

---@param encounter Encounter
function encounter_init(encounter, data)
    local use_beach = math.random(1, 2) == 1

    SharedLib.add_boulders()

    if not use_beach then
        SharedLib.crack_panels(6)
    end

    LiberationLib.init(encounter, data)

    if use_beach then
        SharedLib.generate_beach_field()
    end

    encounter:set_spectate_on_delete(true)

    SharedLib.spawn_viruses(encounter, data, VIRUS_POOL)
end
