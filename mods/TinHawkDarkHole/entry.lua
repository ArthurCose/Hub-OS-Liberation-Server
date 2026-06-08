---@type dev.konstinople.LiberationServer.Shared
local SharedLib = require("dev.konstinople.LiberationServer.Shared")

---@param encounter Encounter
function encounter_init(encounter, data)
    -- overriding the terrain
    data.terrain = "surrounded"
    SharedLib.init(encounter, data)

    SharedLib.shuffle_dark_hole_guardians(encounter, "BattleNetwork5.TinHawk.Enemy", Rank[data.rank])
end
