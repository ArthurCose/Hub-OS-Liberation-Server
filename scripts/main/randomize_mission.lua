local BOSSES = {
  { "BlizzardMan", "/server/mods/BlizzardMan", "Beta", "/server/mods/BlizzardManViruses" },
}

local GUARDIANS = {
  { "BigBrute", "/server/mods/BigBrute", "V4" },
  { "BigBrute", "/server/mods/BigBrute", "V3" },
}

local LOOT_POOL = {
  "HEART",
  "ORDER_POINT",
  -- "MONEY",
}

local BONUS_LOOT_POOL = {
  "HEART",
  "ORDER_POINT",
  "INVINCIBILITY",
  "MAJOR_HIT",
  -- "MONEY",
}

local function randomize_mission(area_id)
  for _, object_id in ipairs(Net.list_objects(area_id)) do
    local object = Net.get_object_by_id(area_id, object_id)

    if object.class == "Item Panel" and not object.custom_properties["Specific Loot"] then
      -- specify loot
      if math.random(3) == 1 then
        -- 100 damage trap
        Net.set_object_type(area_id, object_id, "Trap Panel")
        Net.set_object_custom_property(area_id, object_id, "Damage", "100")
      else
        local loot = LOOT_POOL[math.random(#LOOT_POOL)]
        Net.set_object_custom_property(area_id, object_id, "Specific Loot", loot)
      end
    elseif object.class == "Bonus Panel" then
      -- specify bonus loot
      local loot = BONUS_LOOT_POOL[math.random(#BONUS_LOOT_POOL)]
      Net.set_object_custom_property(area_id, object_id, "Specific Loot", loot)
    elseif object.custom_properties.Boss then
      -- randomize bosses
      local boss, encounter_path, rank, virus_encounter_path = table.unpack(BOSSES[math.random(#BOSSES)])
      Net.set_object_custom_property(area_id, object_id, "Boss", boss)
      Net.set_object_custom_property(area_id, object_id, "Encounter", encounter_path)
      Net.set_object_custom_property(area_id, object_id, "Rank", rank)

      Net.set_area_custom_property(area_id, "Liberation Encounter", virus_encounter_path)
    elseif object.class == "Dark Hole" then
      -- randomize guardians
      local boss, encounter_path, rank = table.unpack(GUARDIANS[math.random(#GUARDIANS)])
      Net.set_object_custom_property(area_id, object_id, "Spawns", boss)
      Net.set_object_custom_property(area_id, object_id, "Encounter", encounter_path)
      Net.set_object_custom_property(area_id, object_id, "Rank", rank)
    end
  end
end

return randomize_mission
