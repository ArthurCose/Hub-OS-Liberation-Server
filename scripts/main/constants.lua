local Debug = require("scripts/main/debug")

local MISSION_AREAS = {
  "acdc3",
  "oran_area_3",
  "undernet_4",
  "nebula_area_3",
}

local LEADERBOARD_EXCLUDED = {
  ["undernet_4"] = true,
}

if Debug.ENABLED then
  table.insert(MISSION_AREAS, "test_area")
end

return {
  MISSION_AREAS = MISSION_AREAS,
  LEADERBOARD_EXCLUDED = LEADERBOARD_EXCLUDED,
}
