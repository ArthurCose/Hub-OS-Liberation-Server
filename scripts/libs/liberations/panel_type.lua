local PanelType = {
  DARK = "Dark Panel",
  DARK_HOLE = "Dark Hole",
  BONUS = "Bonus Panel",
  TRAP = "Trap Panel",
  ITEM = "Item Panel",
  GATE = "Gate Panel",
  INDESTRUCTIBLE = "Indestructible Panel",
}

---Adds values as keys,
---allowing us to use list[value] to test if the values is in the list
local function add_values_as_keys(list)
  for _, value in ipairs(list) do
    list[value] = true
  end

  return list
end

-- generate a list of all panel types
local ALL = {}

for _, value in pairs(PanelType) do
  ALL[#ALL + 1] = value
end

PanelType.ALL = add_values_as_keys(ALL)

PanelType.ENEMY_WALKABLE = add_values_as_keys({
  PanelType.DARK,
  PanelType.ITEM,
  PanelType.TRAP,
})

PanelType.LIBERATABLE = add_values_as_keys({
  PanelType.DARK,
  PanelType.DARK_HOLE,
  PanelType.BONUS,
  PanelType.ITEM,
  PanelType.TRAP,
})

PanelType.ABILITY_ACTIONABLE = add_values_as_keys({
  PanelType.DARK,
  PanelType.ITEM,
  PanelType.TRAP,
})

PanelType.TERRAIN = add_values_as_keys({
  PanelType.DARK,
  PanelType.DARK_HOLE,
  PanelType.ITEM,
  PanelType.INDESTRUCTIBLE,
  PanelType.TRAP,
})

PanelType.OPTIONAL_COLLISION = add_values_as_keys({
  PanelType.DARK,
  PanelType.ITEM,
  PanelType.TRAP,
})

return PanelType
