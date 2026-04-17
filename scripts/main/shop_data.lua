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
    name = "LongSwrd",
    description = "Liberate a 1x2 ahead.",
    price = 0,
  },
  {
    name = "WideSwrd",
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
    requires = "WideSwrd",
    price = 25,
  },
  {
    name = "Napalm",
    description = "Liberate up to four panels ahead, destroys items.",
    requires = "WideSwrd",
    price = 25,
  },
  -- Planned, but not implemented
  -- {
  --   name = "TwinLiberation",
  --   short_name = "TwinLib",
  --   description = "Team up to liberate in a line ahead.",
  --   requires = "Napalm",
  --   price = 35,
  -- },
  {
    name = "KnightGuard",
    short_name = "KntGuard",
    description = "Avoid damage and shield one nearby ally.",
    price = 50,
  },
  {
    name = "MagnetBarrier",
    short_name = "MagBarr",
    description = "Use order points to shield all allies.",
    requires = "KnightGuard",
    price = 35,
  },
}

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
