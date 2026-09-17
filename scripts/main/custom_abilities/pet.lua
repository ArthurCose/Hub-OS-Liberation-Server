local Ability = require("scripts/libs/liberations/ability")
local Preloader = require("scripts/libs/liberations/preloader")
local Direction = require("scripts/libs/direction")

local HEARTS_TEXTURE = Preloader.add_asset("/server/assets/bots/hearts.png")
local HEARTS_ANIM_PATH = Preloader.add_asset("/server/assets/bots/hearts.animation")
local PET_SFX = Preloader.add_asset("/server/assets/liberations/sounds/recover.ogg")

local pacified = {}

---@param enemy Liberation.Enemy
local function pacify(enemy)
  local enemy_id = enemy.id
  if pacified[enemy_id] then
    return
  end
  pacified[enemy_id] = true

  -- save old ai
  local old_ai = enemy.ai

  -- pacify
  enemy.ai = {
    pacified = true,
    new = function(_, options)
      return old_ai:new(options)
    end,
    take_turn = function()
      return Async.create_promise(function(resolve)
        resolve(nil)
      end)
    end,
    get_final_message = function(_, actor)
      return old_ai:get_final_message(actor)
    end,
    banter = function(_, actor, player)
      return old_ai:banter(actor, player)
    end,
  }

  -- create hearts
  local instance = enemy:instance()
  local sprite_id = Net.create_sprite({
    parent_id = enemy.id,
    texture_path = HEARTS_TEXTURE,
    animation_path = HEARTS_ANIM_PATH,
    animation = "DEFAULT",
    loop_animation = true,
    layer = -1,
  })

  Net.play_sound(instance.area_id, PET_SFX)

  -- event handlers
  local events = instance:events()

  local effect_cleanup
  local phase_end_listener = function(event)
    if event.team ~= "darkloid" then
      return
    end

    enemy.ai = old_ai
    effect_cleanup()
  end
  events:on("phase_end", phase_end_listener)

  effect_cleanup = function()
    pacified[enemy_id] = nil
    events:remove_listener("phase_end", phase_end_listener)
    events:remove_listener("destroyed", effect_cleanup)
    Net.remove_sprite(sprite_id)
  end

  events:on("destroyed", effect_cleanup)
end

Ability.register({
  name = "PetDoggy",
  question = "Can I pet the dog?",
  cost = 1,
  per_turn_limit = 1,
  generate_shape = function(player)
    local instance = player:instance()
    local panel = player:selection():root_panel()

    if not panel then
      return {}, 0, 0
    end

    local enemy = instance:get_enemy_at(panel.x, panel.y, panel.z)

    if not enemy then
      return {}, 0, 0
    end

    return { { 1 } }, 0, 0
  end,
  indicate = function(player)
    local panel = player:selection():root_panel()

    Net.slide_player_camera(
      player.id,
      panel.x + 0.5,
      panel.y + 0.5,
      panel.z,
      0.5
    )

    return function(activating)
      if not activating then
        local x, y, z = player:position_multi()

        Net.slide_player_camera(player.id, x, y, z, 0.5)
        Net.unlock_player_camera(player.id)
      end
    end
  end,
  activate = function(player)
    Async.create_scope(function()
      local instance = player:instance()
      local panel = player:selection():root_panel()
      local enemy = instance:get_enemy_at(panel.x, panel.y, panel.z)

      if not enemy or enemy == instance.boss then
        player:refund_ability()

        Async.await(player:message_with_mug("Doggy?"))
      else
        pacify(enemy)

        Async.await(Async.sleep(1.6))
      end

      -- return camera to the original position
      local player_x, player_y, player_z = player:position_multi()
      Net.slide_player_camera(
        player.id,
        player_x,
        player_y,
        player_z,
        0.5
      )
      Net.unlock_player_camera(player.id)
      player:unlock_movement()
    end)
  end
})
