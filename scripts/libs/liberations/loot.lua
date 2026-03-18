local Enemy = require("scripts/libs/liberations/enemy")
local ITEM_ASSET_PATH = "/server/assets/liberations/bots/item.png"
local ITEM_ANIMATION_PATH = "/server/assets/liberations/bots/item.animation"

---@class Liberation.Loot
---@field animation string
---@field breakable boolean
---@field activate fun(instance: Liberation.MissionInstance, player: Liberation.Player, panel: Liberation.PanelObject): Net.Promise

local Loot = {}

---@type Liberation.Loot
Loot.HEART = {
  animation = "HEART",
  breakable = true,
  activate = function(instance, player)
    return Async.create_scope(function()
      Async.await(player:message_with_mug("I found\na heart!"))
      player:heal(player.max_health / 2)
    end)
  end
}

---@type Liberation.Loot
Loot.CHIP = {
  animation = "CHIP",
  breakable = true,
  activate = function(instance, player)
    return Async.create_scope(function()
      Async.await(player:message_with_mug("I found a\nBattleChip!"))
    end)
  end
}

---@type Liberation.Loot
Loot.MONEY = {
  animation = "MONEY",
  breakable = true,
  activate = function(instance, player, panel)
    return Async.create_scope(function()
      local money = tonumber(panel.custom_properties["Money"]) or 100

      Async.await(player:message_with_mug("I found some\nZenny!"))
      Async.await(player:message("Obtained " .. tostring(money) .. "z!"))

      instance.events:emit("money", {
        player_id = player.id,
        money = money
      })
    end)
  end
}

---@type Liberation.Loot
Loot.BUGFRAG = {
  animation = "BUGFRAG",
  breakable = true,
  activate = function(instance, player)
    return Async.create_scope(function()
      Async.await(player:message_with_mug("I found a\nBugFrag!"))
    end)
  end
}

---@type Liberation.Loot
Loot.ORDER_POINT = {
  animation = "ORDER_POINT",
  breakable = false,
  activate = function(instance, player)
    return Async.create_scope(function()
      Async.await(player:message_with_mug("I found\nOrder Points!"))

      local previous_points = instance.order_points
      instance.order_points = math.min(instance.order_points + 3, instance.MAX_ORDER_POINTS)

      for _, p in ipairs(instance.players) do
        p:update_order_points_hud()
      end

      local recovered_points = instance.order_points - previous_points
      Async.await(player:message(recovered_points .. "\nOrder Pts Recovered!"))
    end)
  end
}

---@type Liberation.Loot
Loot.INVINCIBILITY = {
  animation = "INVINCIBILITY",
  breakable = false,
  activate = function(instance, player)
    return Async.create_scope(function()
      for _, other_player in pairs(instance.players) do
        other_player.invincible = true
      end

      Async.await(player:message("Team becomes invincible for\n 1 phase!!"))
    end)
  end
}

---@type Liberation.Loot
Loot.MAJOR_HIT = {
  animation = "MAJOR_HIT",
  breakable = false,
  activate = function(instance, player)
    return Async.create_scope(function()
      Async.await(player:message("Damages the closest Guardian the most!"))

      local enemy = player:find_closest_guardian()

      if not enemy then
        Async.await(player:message("No Guardians found"))
        return
      end

      Async.await(Enemy.destroy(instance, enemy))
    end)
  end
}

---@param player Liberation.Player
---@param key_id string
local function find_matching_gates(player, key_id)
  local gates = {}

  for i = 1, #player.instance.gate_panels do
    local gate = player.instance.gate_panels[i]

    if gate.custom_properties["Gate Key"] == key_id then
      table.insert(gates, gate)
    end
  end

  return gates
end

---@param instance Liberation.MissionInstance
---@param key_id string
local function find_gate_points(instance, key_id)
  local points = {}

  for i = 1, #instance.points_of_interest, 1 do
    local prospective_point = instance.points_of_interest[i]
    if prospective_point.custom_properties["Gate ID"] == key_id then
      table.insert(points, prospective_point)
    end
  end

  return points
end

---@type Liberation.Loot
Loot.KEY = {
  animation = "KEY",
  breakable = false,
  activate = function(instance, player, panel)
    return Async.create_scope(function()
      local player_x, player_y, player_z = player:position_multi()

      Async.await(player:message_with_mug("I found a Key!"))

      local key_id = panel.custom_properties["Gate Key"]
      local gates = find_matching_gates(player, key_id)

      if #gates == 0 then
        Async.await(player:message_with_mug("But it doesn't open anything..."))
        return
      end

      local points = find_gate_points(instance, key_id)

      local function unlock_gates()
        for i = 1, #gates, 1 do
          instance:remove_panel(gates[i])
        end
      end

      if #points > 0 then
        local hold_time = .4
        local slide_time = .4
        local camera_time = 0

        for j = 1, #points, 1 do
          local point = points[j]
          Net.slide_player_camera(player.id, point.x, point.y, point.z, slide_time)
          Net.move_player_camera(player.id, point.x, point.y, point.z, hold_time)

          camera_time = camera_time + slide_time + hold_time

          if point == points[1] then
            Async.await(Async.sleep(camera_time + 0.5))

            unlock_gates()

            Async.await(Async.sleep(1))

            Async.await(player:message_with_mug("The gate opened!"))

            Net.move_player_camera(player.id, point.x, point.y, point.z, hold_time)

            -- intentionally resetting here
            camera_time = hold_time
          end
        end

        camera_time = camera_time + slide_time

        Net.slide_player_camera(player.id, player_x, player_y, player_z, slide_time)

        Async.await(Async.sleep(camera_time))
      else
        unlock_gates()
      end
    end)
  end
}

Loot.DEFAULT_POOL = {
  Loot.HEART,
  -- Loot.CHIP,
  Loot.MONEY,
  -- Loot.BUGFRAG,
  Loot.ORDER_POINT,
}

Loot.BONUS_POOL = {
  Loot.HEART,
  -- Loot.CHIP,
  Loot.ORDER_POINT,
  Loot.INVINCIBILITY,
  Loot.MAJOR_HIT,
  Loot.MONEY,
}

---@type Liberation.Loot[]
Loot.FULL_POOL = {
  Loot.HEART,
  Loot.CHIP,
  Loot.MONEY,
  Loot.BUGFRAG,
  Loot.ORDER_POINT,
  Loot.INVINCIBILITY,
  Loot.KEY,
  Loot.MAJOR_HIT,
}

local RISE_DURATION = .1

-- private functions

local function spawn_item_bot(bot_data, property_animation)
  local shadow_id = Net.create_bot(
    {
      area_id = bot_data.area_id,
      texture_path = ITEM_ASSET_PATH,
      animation_path = ITEM_ANIMATION_PATH,
      animation = "SHADOW",
      warp_in = false,
      x = bot_data.x - (1 / 32),
      y = bot_data.y - (1 / 32),
      z = bot_data.z,
    }
  )

  local id = Net.create_bot(bot_data)

  Net.animate_bot_properties(id, property_animation)

  local function cleanup()
    Net.remove_bot(shadow_id)
    Net.remove_bot(id)
  end

  return cleanup
end

-- public functions

-- returns a promise that resolves when the animation finishes
-- resolved value is a function that cleans up the bot
---@param item Liberation.Loot
---@param area_id string
---@param x number
---@param y number
---@param z number
function Loot.spawn_item_bot(item, area_id, x, y, z)
  local bot_data = {
    area_id = area_id,
    texture_path = ITEM_ASSET_PATH,
    animation_path = ITEM_ANIMATION_PATH,
    animation = item.animation,
    warp_in = false,
    x = x,
    y = y,
    z = z,
  }

  local property_animation = {
    {
      properties = {
        { property = "Z", ease = "Linear", value = z + 1 }
      },
      duration = RISE_DURATION
    },
  }

  -- return a promise that resolves when the animation finishes
  return Async.create_promise(function(resolve)
    local cleanup = spawn_item_bot(bot_data, property_animation)

    Async.sleep(RISE_DURATION).and_then(function()
      resolve(cleanup)
    end)
  end)
end

-- returns a promise that resolves when the animation finishes
-- resolved value is a function that cleans up the bot
function Loot.spawn_randomized_item_bot(loot_pool, item_index, area_id, x, y, z)
  local target_duration = 2
  local frame_duration = .075
  local total_frames = math.ceil(target_duration / frame_duration)

  local start_index = (item_index - total_frames - 2) % #loot_pool + 1

  local bot_data = {
    area_id = area_id,
    texture_path = ITEM_ASSET_PATH,
    animation_path = ITEM_ANIMATION_PATH,
    animation = loot_pool[start_index].animation,
    warp_in = false,
    x = x,
    y = y,
    z = z,
  }

  local property_animation = {}

  local total_duration = 0
  local added_rise = false

  for i = 1, total_frames, 1 do
    local current_item_index = (start_index + i) % #loot_pool + 1

    local key_frame = {
      properties = {
        { property = "Animation", value = loot_pool[current_item_index].animation }
      },
      duration = frame_duration
    }

    total_duration = total_duration + frame_duration

    if not added_rise and total_duration >= RISE_DURATION then
      -- animate rising
      key_frame.properties[#key_frame.properties] = { property = "Z", ease = "Linear", value = z + 1 }
      added_rise = true
    end

    table.insert(property_animation, key_frame)
  end

  -- return a promise that resolves when the animation finishes
  return Async.create_promise(function(resolve)
    local cleanup = spawn_item_bot(bot_data, property_animation)

    Async.sleep(total_duration).and_then(function()
      resolve(cleanup)
    end)
  end)
end

-- returns a promise, resolves when looting is completed
---@param instance Liberation.MissionInstance
---@param player Liberation.Player
---@param panel Liberation.PanelObject
---@param destroy_items boolean
function Loot.loot_item_panel(instance, player, panel, destroy_items)
  local loot = panel.loot

  if not loot then
    return Async.create_scope(function() end)
  end

  local slide_time = .1

  local spawn_x = math.floor(panel.x) + .5
  local spawn_y = math.floor(panel.y) + .5
  local spawn_z = panel.z

  Net.slide_player_camera(
    player.id,
    spawn_x,
    spawn_y,
    spawn_z,
    slide_time
  )

  local breakable = panel.loot.breakable

  -- prevent other players from looting this panel again
  panel.loot = nil

  return Async.create_scope(function()
    Async.await(Async.sleep(slide_time))

    local remove_item_bot = Async.await(Loot.spawn_item_bot(loot, instance.area_id, spawn_x, spawn_y, spawn_z))

    if breakable and destroy_items then
      Async.await(player:message_with_mug("Ah!! The item was destroyed!"))
    else
      Async.await(loot.activate(instance, player, panel))
    end

    remove_item_bot()
  end)
end

-- returns a promise, resolves when looting is completed
---@param instance Liberation.MissionInstance
---@param player Liberation.Player
---@param panel Liberation.PanelObject
function Loot.loot_bonus_panel(instance, player, panel)
  local loot_index = math.random(#Loot.BONUS_POOL)

  local spawn_x = math.floor(panel.x) + .5
  local spawn_y = math.floor(panel.y) + .5
  local spawn_z = panel.z

  return Async.create_scope(function()
    local remove_item_bot = Async.await(
      Loot.spawn_randomized_item_bot(
        Loot.BONUS_POOL,
        loot_index,
        instance.area_id,
        spawn_x,
        spawn_y,
        spawn_z
      )
    )

    local loot = Loot.BONUS_POOL[loot_index]
    Async.await(loot.activate(instance, player, panel))
    remove_item_bot()
  end)
end

return Loot
