local AttackSelection = require("scripts/libs/liberations/selections/attack_selection")
local Preloader = require("scripts/libs/liberations/preloader")

local PLANET_BIG_SFX = Preloader.add_asset("/server/assets/liberations/sounds/cosmoman_planet_big.ogg")
local PLANET_SFX = Preloader.add_asset("/server/assets/liberations/sounds/cosmoman_planet.ogg")
local PLANET_RINGED_SFX = Preloader.add_asset("/server/assets/liberations/sounds/cosmoman_ringed_planet.ogg")

local PLANET_TEXTURE = Preloader.add_asset("/server/assets/liberations/bots/cosmoman_planet.png")
local PLANET_ANIM_PATH = Preloader.add_asset("/server/assets/liberations/bots/cosmoman_planet.animation")

---@class LiberationServer.CustomEnemies.CosmoMan: Liberation.EnemyAi
---@field damage number
---@field selection Liberation.AttackSelection
---@field is_engaged boolean
local CosmoMan = {}

--Setup ranked health and damage
local rank_to_index = {
  V1 = 1,
  V2 = 2,
  V3 = 3,
  SP = 4,
  Alpha = 2,
  Beta = 3,
  Omega = 4,
}

local mob_health = { 1000, 1200, 1500, 1800 }
local mob_damage = { 80, 100, 200, 220 }

---@param builder Liberation.EnemyBuilder
function CosmoMan:new(builder)
  local rank_index = rank_to_index[builder.rank]

  ---@type LiberationServer.CustomEnemies.CosmoMan
  local cosmoman = {
    damage = mob_damage[rank_index],
    selection = AttackSelection:new(builder.instance),
    is_engaged = false
  }

  setmetatable(cosmoman, self)
  self.__index = self

  local shape = {
    { 0, 1, 1, 1, 1, 1, 0 },
    { 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 0, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1 },
    { 0, 1, 1, 1, 1, 1, 0 },
  }

  cosmoman.selection:set_shape(shape, 0, -4)

  return builder:build({
    ai = cosmoman,
    name = "CosmoMan",
    health = mob_health[rank_index],
    max_health = mob_health[rank_index],
    texture_path = "/server/assets/liberations/bots/cosmoman.png",
    animation_path = "/server/assets/liberations/bots/cosmoman.animation",
    mug = {
      texture_path = "/server/assets/liberations/mugs/cosmoman.png",
      animation_path = "/server/assets/liberations/mugs/cosmoman.animation",
    },
  })
end

local BANTER_LINES = {
  {
    "I didn't expect to",
    "see you make it.",
    "",
    "It's actually very",
    "unfortunate for you",
    "that you did...!",
  },
  {
    "You'll never ever",
    "catch me off guard.",
    "",
    "Because of that,",
    "your survival rate",
    "is less than zero!",
  },
  {
    "Welcome to my",
    "never-ending",
    "world of darkness!",
  }
}

---@param actor Liberation.Enemy
---@param player Liberation.Player
function CosmoMan:banter(actor, player)
  return Async.create_scope(function()
    if self.is_engaged then
      return
    end

    self.is_engaged = true

    -- randomize dialogue to keep his lines short
    local dialogue = BANTER_LINES[math.random(#BANTER_LINES)]

    Async.await(player:message(
      table.concat(dialogue, "\n"),
      actor.mug.texture_path,
      actor.mug.animation_path
    ))
  end)
end

local FINAL_LINES = {
  "NO! I take my power",
  "from the cosmos!",
  "I am...invincible...!",

  "NOOOOOOOOO!",
}

function CosmoMan:get_final_message()
  return table.concat(FINAL_LINES, "\n")
end

local ENTRANCE_LINES = {
  {
    "You're nothing",
    "but dust-motes",
    "compared to me!",
  },
  {
    "I control the",
    "world of darkness."
  },
  {
    "Let's see how",
    "you managed to",
    "make it this far!",
  },
}

local PLANET_PROPERTIES = {
  {
    state = "DEFAULT",
    sfx = PLANET_SFX,
  },
  {
    state = "SMALL",
    sfx = PLANET_SFX,
  },
  {
    state = "SMALL_RINGED",
    sfx = PLANET_RINGED_SFX,
  },
}

---@param target Liberation.Player
---@param damage number
---@param spawn_large boolean?
local function spawn_planet(target, damage, spawn_large)
  local instance = target:instance()

  -- resolve the type of planet
  local planet_properties = PLANET_PROPERTIES[math.random(#PLANET_PROPERTIES)]
  local sfx = planet_properties.sfx

  if spawn_large == true then
    planet_properties = PLANET_PROPERTIES[1]
    sfx = PLANET_BIG_SFX
  end

  -- resolve animation positions
  local x, y, z = target:position_multi()

  local start_delay = 25 / 60
  local half_duration = 25 / 60
  local h_dist = 3
  local elevation = z + 8

  local start_x = x + h_dist + 1
  local start_y = y - h_dist - 1

  local end_x = x - h_dist + 1
  local end_y = y + h_dist - 1

  local center_x = (start_x + end_x) * 0.5
  local center_y = (start_y + end_y) * 0.5

  -- create bot
  local bot_id = Net.create_bot({
    area_id = instance.area_id,
    x = start_x,
    y = start_y,
    z = elevation,
    warp_in = false,
    texture_path = PLANET_TEXTURE,
    animation_path = PLANET_ANIM_PATH,
    animation = planet_properties.state,
    loop_animation = true,
  })

  -- animate
  Net.animate_actor_properties(bot_id, {
    {
      properties = {
        -- hold initial properties for a sec
        { property = "Animation", value = planet_properties.state },
        { property = "X",         value = start_x },
        { property = "Y",         value = start_y },
        { property = "Z",         value = elevation },
      },
      duration = start_delay
    },
    {
      properties = {
        { property = "X", value = center_x, ease = "Linear" },
        { property = "Y", value = center_y, ease = "Linear" },
        { property = "Z", value = z,        ease = "Out" },
      },
      duration = half_duration
    },
    {
      properties = {
        { property = "X", value = end_x,     ease = "Linear" },
        { property = "Y", value = end_y,     ease = "Linear" },
        { property = "Z", value = elevation, ease = "In" },
      },
      duration = half_duration
    }
  })

  -- play sfx when the animation starts
  Async.sleep(start_delay).and_then(function()
    Net.play_sound(instance.area_id, sfx)
  end)

  -- hit the target on the way up
  local hit_delay = start_delay + half_duration + 7 / 60

  Async.sleep(hit_delay).and_then(function()
    target:hurt(damage)
  end)

  -- cleanup
  return Async.create_scope(function()
    local total_duration = start_delay + half_duration * 2

    Async.await(Async.sleep(total_duration))

    Net.remove_bot(bot_id, false)
  end)
end

---@param actor Liberation.Enemy
function CosmoMan:take_turn(actor)
  return Async.create_scope(function()
    local instance = actor:instance()

    if instance:phase() == 1 then
      Async.await(Async.sleep(0.25))

      local dialogue = ENTRANCE_LINES[math.random(#ENTRANCE_LINES)]
      Async.await(instance:announce(
        table.concat(dialogue, "\n"),
        1.5,
        actor.mug.texture_path,
        actor.mug.animation_path
      ))

      Async.await(Async.sleep(0.5))
    end

    self.selection:move(actor.x, actor.y, actor.z, Net.get_actor_direction(actor.id))

    local caught_players = self.selection:detect_players()

    if #caught_players == 0 then
      return
    end

    self.selection:indicate()

    actor:play_attack_animation()

    Async.await(Async.sleep(1))

    Async.await(instance:announce(
      "Fall into darkness!\nCosmo Planet!",
      1.5,
      actor.mug.texture_path,
      actor.mug.animation_path
    ))

    actor:attack(caught_players, function(targets)
      -- pan to the action
      if #targets > 0 then
        local camera_min_x = math.huge
        local camera_min_y = math.huge
        local camera_min_z = math.huge
        local camera_max_x = -math.huge
        local camera_max_y = -math.huge
        local camera_max_z = -math.huge

        for _, target in ipairs(targets) do
          local x, y, z = target:position_multi()

          camera_min_x = math.min(camera_min_x, x)
          camera_min_y = math.min(camera_min_y, y)
          camera_min_z = math.min(camera_min_z, z)
          camera_max_x = math.max(camera_max_x, x)
          camera_max_y = math.max(camera_max_y, y)
          camera_max_z = math.max(camera_max_z, z)
        end

        local camera_x = (camera_min_x + camera_max_x) * 0.5
        local camera_y = (camera_min_y + camera_max_y) * 0.5
        local camera_z = (camera_min_z + camera_max_z) * 0.5

        for _, player in ipairs(instance.players) do
          Net.slide_player_camera(player.id, camera_x, camera_y, camera_z, 0.5)
        end

        Async.await(Async.sleep(0.75))
      end

      -- spawn planets
      local last_promise

      for _, target in ipairs(targets) do
        if last_promise then
          Async.await(Async.sleep(0.266))
        end

        last_promise = spawn_planet(target, self.damage, #targets == 1)
      end

      -- wait for the last planet to despawn
      if last_promise then
        Async.await(last_promise)
      end

      -- pan back
      if #targets > 0 then
        local x, y, z = actor:floored_position_multi()
        x = x + 0.5
        y = y + 0.5

        for _, player in ipairs(instance.players) do
          Net.slide_player_camera(player.id, x, y, z, 0.5)
        end
      end

      Async.await(Async.sleep(1))
    end)

    actor:play_idle_animation()

    self.selection:remove_indicators()
  end)
end

return CosmoMan
