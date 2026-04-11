local PanelClass = {
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

-- generate a list of all panel classes
local ALL = {}

for _, value in pairs(PanelClass) do
  ALL[#ALL + 1] = value
end

PanelClass.ALL = add_values_as_keys(ALL)

PanelClass.ENEMY_WALKABLE = add_values_as_keys({
  PanelClass.DARK,
  PanelClass.ITEM,
  PanelClass.TRAP,
})

PanelClass.LIBERATABLE = add_values_as_keys({
  PanelClass.DARK,
  PanelClass.DARK_HOLE,
  PanelClass.BONUS,
  PanelClass.ITEM,
  PanelClass.TRAP,
})

PanelClass.ABILITY_ACTIONABLE = add_values_as_keys({
  PanelClass.DARK,
  PanelClass.ITEM,
  PanelClass.TRAP,
})

PanelClass.TERRAIN = add_values_as_keys({
  PanelClass.DARK,
  PanelClass.DARK_HOLE,
  PanelClass.ITEM,
  PanelClass.INDESTRUCTIBLE,
  PanelClass.TRAP,
})

PanelClass.OPTIONAL_COLLISION = add_values_as_keys({
  PanelClass.DARK,
  PanelClass.ITEM,
  PanelClass.TRAP,
})

return PanelClass
