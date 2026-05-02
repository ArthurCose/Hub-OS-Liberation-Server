local GUARDIAN_ENCOUNTERS = {
  BigBrute = { "/server/mods/BigBruteDarkHole", "/server/mods/BigBrute" },
  TinHawk = { "/server/mods/TinHawkDarkHole", "/server/mods/TinHawk" },
  Bladia = { "/server/mods/BladiaDarkHole", "/server/mods/Bladia" },
}

local GUARDIAN_POOLS = {
  acdc3 = {
    { "BigBrute", "V5" },
    { "BigBrute", "V4" },
  },
  oran_area_3 = {
    { "BigBrute", "V4" },
    { "BigBrute", "V5" },
    { "TinHawk",  "V4" },
    { "TinHawk",  "V5" },
  },
  undernet_4 = {
    BigBrute = { "V5", "V6" },
    TinHawk = { "V4", "V5" },
    Bladia = { "V5", "V5", "V6", "V6" },
  },
  nebula_area_3 = {
    BigBrute = { "V5", "V6" },
    TinHawk = { "V5", "V6" },
    Bladia = { "V4", "V5" },
  },
}

local GUARDIAN_HEALTH = {
  BigBrute = { 240, 360, 440, 500, 600, 720 },
  TinHawk = { 200, 300, 360, 400, 500, 600 },
  Bladia = { 400, 460, 460, 600, 680, 800 },
}

local GUARDIAN_RANK_TO_INDEX = {
  V1 = 1,
  V2 = 2,
  V3 = 3,
  V4 = 4,
  V5 = 5,
  V6 = 6
}

local CUSTOM_BOSSES = {
  ShadeMan = "scripts/main/custom_enemies/shademan"
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

local function randomize_mission(base_area_id, area_id)
  if not GUARDIAN_POOLS[base_area_id] then
    warn("Missing randomization data for " .. base_area_id)
    return
  end

  local guardians = {}

  for key, option in pairs(GUARDIAN_POOLS[base_area_id]) do
    guardians[key] = table.pack(table.unpack(option))
  end

  for _, object_id in ipairs(Net.list_objects(area_id)) do
    local object = Net.get_object_by_id(area_id, object_id)

    if (object.class == "Item Panel" or object.class == "Trap Panel") and not object.custom_properties["Specific Loot"] then
      -- specify loot
      if math.random(3) == 1 then
        -- 100 damage trap
        Net.set_object_class(area_id, object_id, "Trap Panel")
        Net.set_object_custom_property(area_id, object_id, "Damage", "150")
      else
        local loot = LOOT_POOL[math.random(#LOOT_POOL)]
        Net.set_object_custom_property(area_id, object_id, "Specific Loot", loot)
      end
    elseif object.class == "Bonus Panel" then
      -- specify bonus loot
      local loot = BONUS_LOOT_POOL[math.random(#BONUS_LOOT_POOL)]
      Net.set_object_custom_property(area_id, object_id, "Specific Loot", loot)
    elseif object.class == "Dark Hole" or object.class == "Guardian" then
      -- randomize guardians

      local guardian = object.custom_properties.Spawns
      local rank_list = guardians[guardian]
      local rank

      if rank_list then
        rank = table.remove(rank_list, math.random(#rank_list))
        Net.set_object_custom_property(area_id, object_id, "Rank", rank)
      else
        local guardian_tuple = table.remove(guardians, math.random(#guardians))
        guardian, rank = table.unpack(guardian_tuple)

        Net.set_object_custom_property(area_id, object_id, "Spawns", guardian)
        Net.set_object_custom_property(area_id, object_id, "Rank", rank)
      end

      local direct_encounter, encounter = table.unpack(GUARDIAN_ENCOUNTERS[guardian])

      Net.set_object_custom_property(area_id, object_id, "Direct Encounter", direct_encounter)
      Net.set_object_custom_property(area_id, object_id, "Encounter", encounter)

      local rank_index = GUARDIAN_RANK_TO_INDEX[rank]
      local health = GUARDIAN_HEALTH[guardian][rank_index]
      Net.set_object_custom_property(area_id, object_id, "Health", tostring(health))
    end

    if object.custom_properties.Boss then
      local custom_boss = CUSTOM_BOSSES[object.custom_properties.Boss]

      if custom_boss then
        Net.set_object_custom_property(area_id, object_id, "Boss", custom_boss)
      end
    end
  end
end

return randomize_mission
