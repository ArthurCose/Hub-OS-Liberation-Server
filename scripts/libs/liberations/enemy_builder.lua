local Enemy = require("scripts/libs/liberations/enemy")
local HealthSprites = require("scripts/libs/liberations/effects/health_sprites")

local GUARDIAN_MINIMAP_MARKER = { 104, 28, 255 }

local BUILT_IN_ENEMIES = {
  BigBrute = require("scripts/libs/liberations/enemies/bigbrute"),
  TinHawk = require("scripts/libs/liberations/enemies/tinhawk"),
  Bladia = require("scripts/libs/liberations/enemies/bladia"),
  BlizzardMan = require("scripts/libs/liberations/enemies/blizzardman"),
  ShadeMan = require("scripts/libs/liberations/enemies/shademan"),
}

---@class Liberation.EnemyBuilder
---@field instance Liberation.MissionInstance
---@field require_name_or_path string
---@field position Net.Position
---@field direction string
---@field rank string
---@field encounter string
local EnemyBuilder = {}
EnemyBuilder.__index = EnemyBuilder

---@param instance Liberation.MissionInstance
---@param panel Net.Object
function EnemyBuilder.from_panel(instance, panel)
  ---@type Liberation.EnemyBuilder
  local builder = {
    instance = instance,
    require_name_or_path = panel.custom_properties.Boss or panel.custom_properties.Spawns,
    position = { x = math.floor(panel.x), y = math.floor(panel.y), z = math.floor(panel.z) },
    direction = panel.custom_properties.Direction:upper(),
    rank = panel.custom_properties.Rank or "V1",
    encounter = panel.custom_properties.Encounter or instance.default_encounter,
  }
  setmetatable(builder, EnemyBuilder)

  return builder
end

function EnemyBuilder:build_from_require()
  local ResolvedEnemyAi = BUILT_IN_ENEMIES[self.require_name_or_path] or require(self.require_name_or_path)
  ResolvedEnemyAi = ResolvedEnemyAi --[[@as Liberation.EnemyAi]]

  local enemy = ResolvedEnemyAi:new(self)

  -- display health
  HealthSprites.update_sprite(enemy.id, enemy.health)

  Net.set_actor_map_color(enemy.id, GUARDIAN_MINIMAP_MARKER)

  return enemy
end

---@class Liberation.EnemyBuilderOptions
---@field ai Liberation.EnemyAi
---@field name string
---@field health number
---@field max_health number
---@field texture_path string
---@field animation_path string
---@field mug Net.TextureAnimationPair?

---@param options Liberation.EnemyBuilderOptions
function EnemyBuilder:build(options)
  ---@type Liberation.Enemy
  local enemy = {
    _instance = self.instance,
    ai = options.ai,
    rank = self.rank,
    encounter = self.encounter,
    health = options.health,
    max_health = options.max_health,
    x = self.position.x,
    y = self.position.y,
    z = self.position.z,
    mug = options.mug,
    id = Net.create_bot({
      name = options.name,
      texture_path = options.texture_path,
      animation_path = options.animation_path,
      area_id = self.instance.area_id,
      direction = self.direction,
      warp_in = false,
      x = self.position.x + .5,
      y = self.position.y + .5,
      z = self.position.z
    })
  }
  setmetatable(enemy, Enemy)

  -- enable panel collisions
  local panel = self.instance:get_panel_at(self.position.x, self.position.y, self.position.z)

  if panel and panel.collision_id then
    for _, player in ipairs(self.instance.players) do
      if player.ability and player.ability.shadow_step then
        Net.include_object_for_player(player.id, panel.collision_id)
      end
    end
  end

  return enemy
end

return EnemyBuilder
