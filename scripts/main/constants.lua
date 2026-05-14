local Debug = require("scripts/main/debug")

local MISSION_AREAS = {
  "acdc3",
  "oran_area_3",
  "nebula_area_3",
}

if Debug.ENABLED then
  table.insert(MISSION_AREAS, "undernet_4")
  table.insert(MISSION_AREAS, "test_area")
end

return {
  MISSION_AREAS = MISSION_AREAS
}
