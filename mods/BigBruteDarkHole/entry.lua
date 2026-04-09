---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")
local LiberationLib = require("dev.konstinople.library.liberation")

---@param encounter Encounter
function encounter_init(encounter, data)
    -- overriding the terrain
    data.terrain = "surrounded"
    LiberationLib.init(encounter, data)

    encounter:set_spectate_on_delete(true)

    SharedLib.shuffle_dark_hole_guardians(encounter, "BattleNetwork5.Character.BigBrute", Rank[data.rank])
end
