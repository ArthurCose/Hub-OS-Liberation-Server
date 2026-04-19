local Parties = require("scripts/libs/parties")

local Debug = {
  ENABLED = false,
  AUTO_WIN = false
}

if not Debug.ENABLED then
  -- skip events
  return Debug
end

Parties.DEBUG = true

return Debug
