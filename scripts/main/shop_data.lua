---@class LiberationServer.AbilityShopData
---@field id string
---@field name string
---@field short_name string?
---@field requires string?
---@field description string
---@field package_id string?
---@field price number

local SHOP_LIST = {
  {
    name = "LongSword",
    short_name = "LongSwrd",
    description = "Liberate a 1x2 ahead.",
    price = 0,
  },
  {
    name = "WideSword",
    short_name = "WideSwrd",
    description = "Liberate in a 3x1 ahead.",
    price = 15,
  },
  {
    name = "PanelSearch",
    short_name = "PanlSrch",
    description = "Disarm traps and find items in a line ahead.",
    price = 15,
  },
  {
    name = "NumberCheck",
    short_name = "NumCheck",
    description = "Disarm traps and find items in a 3x2 ahead.",
    requires = "PanelSearch",
    price = 20,
  },
  {
    name = "TomahawkSwing",
    short_name = "ThwkSwng",
    description = "Liberate in a 3x2 ahead.",
    requires = "WideSword",
    price = 30,
  },
  {
    name = "Napalm",
    description = "Liberate up to four panels ahead, destroys items.",
    requires = "WideSword",
    price = 35,
  },
  -- Planned, but not implemented
  -- {
  --   name = "TwinLiberation",
  --   short_name = "TwinLib",
  --   description = "Team up to liberate in a line ahead.",
  --   requires = "Napalm",
  --   price = 40,
  -- },
  {
    name = "KnightGuard",
    short_name = "KntGuard",
    description = "Avoid damage and shield one nearby ally.",
    price = 50,
  },
  {
    name = "Barrier",
    description = "Use order points to shield 10 damage on all allies.",
    price = 35,
  },
  {
    name = "MagnetBarrier",
    short_name = "MagBarr",
    description = "Use turn and points to shield all allies.",
    requires = "Barrier",
    price = 35,
  },

if Debug.ENABLED then
  SHOP_LIST[#SHOP_LIST + 1] = {
    name = "ShadowStep",
    short_name = "ShdwStep",
    description = "",
    price = 0
  }

  Net:on("player_connect", function(event)
    for _, item in ipairs(SHOP_LIST) do
      Net.give_player_item(event.player_id, item.id)
    end
  end)
end

local SHOP_MAP = {}

for _, item in ipairs(SHOP_LIST) do
  if not item.id then
    item.id = item.name
  end

  SHOP_MAP[item.id] = item

  Net.register_item(item.id, {
    name = item.short_name or item.name,
    description = "Mission Ability",
    consumable = not item.package_id
  })
end

return {
  ---@type LiberationServer.AbilityShopData[]
  LIST = SHOP_LIST,
  ---@type table<string, LiberationServer.AbilityShopData>
  MAP = SHOP_MAP
}
