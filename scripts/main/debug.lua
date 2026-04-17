local ShopData = require("scripts/main/shop_data")
local Parties = require("scripts/libs/parties")

local Debug = {
  ENABLED = false
}

if not Debug.ENABLED then
  -- skip events
  return Debug
end

Net:on("player_connect", function(event)
  for _, item in ipairs(ShopData.LIST) do
    Net.give_player_item(event.player_id, item.id)
  end
end)

Parties.DEBUG = true

return Debug
