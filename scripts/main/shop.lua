local PlayerSaveData = require("scripts/main/player_data")
local ShopData = require("scripts/main/shop_data")
local Debug = require("scripts/main/debug")

local SHOP_MUG_TEXTURE = "/server/assets/mugs/normal_navi.png"
local SHOP_MUG_ANIM_PATH = "/server/assets/mugs/normal_navi.animation"

local viewing_ability_shop = {}

local function open_ability_shop(player_id)
  if viewing_ability_shop[player_id] then
    return
  end

  viewing_ability_shop[player_id] = true

  PlayerSaveData.fetch(player_id).and_then(function(save_data)
    local shop_items = {}

    for _, data in ipairs(ShopData.LIST) do
      local item = {
        id = data.id,
        name = data.name,
        price = data.price
      }

      local owned = save_data.inventory[data.id]

      if owned and owned > 0 then
        item.price = 0
      elseif data.requires then
        local required_owned = save_data.inventory[data.requires]

        if not required_owned or required_owned == 0 then
          item.name = item.name .. "*"
        end
      end

      shop_items[#shop_items + 1] = item
    end

    local events = Net.open_shop(player_id, shop_items, SHOP_MUG_TEXTURE, SHOP_MUG_ANIM_PATH)

    Net.set_shop_message(player_id, "Looking for a change?")

    events:on("shop_purchase", function(event)
      local data = ShopData.MAP[event.item_id]

      if not data then
        warn('Failed to find shop item with id: "' .. event.item_id .. '"')
        return
      end

      local owned = save_data.inventory[data.id]

      if owned and owned > 0 then
        if data.package_id then
          -- mod
          Net.refer_package(player_id, data.package_id)
        else
          -- ability
          local mug = Net.get_player_mugshot(player_id)
          Net.message_player(
            event.player_id,
            "Switched to " .. data.name .. ".",
            mug.texture_path,
            mug.animation_path
          )

          save_data.ability = data.id
          save_data:save(player_id)
        end

        return
      end

      if data.requires then
        local required_owned = save_data.inventory[data.requires]

        if not required_owned or required_owned == 0 then
          local required_data = ShopData.MAP[data.requires]

          -- not enough money
          Net.message_player(
            player_id,
            "Requires " .. required_data.name .. ".",
            SHOP_MUG_TEXTURE,
            SHOP_MUG_ANIM_PATH
          )
          return
        end
      end

      if save_data.money < data.price then
        -- not enough money
        Net.message_player(
          player_id,
          "You need more zenny for " .. data.name .. ".",
          SHOP_MUG_TEXTURE,
          SHOP_MUG_ANIM_PATH
        )
        return
      end

      Async.question_player(
        player_id, "Learn " .. data.name .. "?",
        SHOP_MUG_TEXTURE,
        SHOP_MUG_ANIM_PATH
      ).and_then(function(response)
        if response ~= 1 then
          return
        end

        Net.update_shop_item(player_id, {
          id = data.id,
          name = data.name,
          price = 0
        })

        save_data.money = save_data.money - data.price
        save_data.inventory[data.id] = 1

        if not data.package_id then
          save_data.ability = data.id
        end

        save_data:save(player_id)
        Net.set_player_money(player_id, save_data.money)

        if data.package_id then
          -- share mod
          Net.refer_package(player_id, data.package_id)
        else
          -- update ability
          Net.give_player_item(player_id, data.id)

          local mug = Net.get_player_mugshot(player_id)
          Net.message_player(
            event.player_id,
            "Switched to " .. data.name .. ".",
            mug.texture_path,
            mug.animation_path
          )
        end
      end)
    end)

    events:on("shop_description_request", function(event)
      local data = ShopData.MAP[event.item_id]

      if not data then
        warn('Failed to find shop item with id: "' .. event.item_id .. '"')
        return
      end

      Net.message_player(
        player_id,
        data.description
      )
    end)

    events:on("shop_leave", function()
      Net.set_shop_message(player_id, "Come again!")
    end)

    events:on("shop_close", function()
      viewing_ability_shop[player_id] = nil
    end)
  end)
end

Net:on("object_interaction", function(event)
  local player_id = event.player_id
  local object = Net.get_object_by_id(Net.get_actor_area(player_id), event.object_id)

  if object.name ~= "Ability Shop" then
    return
  end

  open_ability_shop(player_id)
end)

Net:on("item_use", function(event)
  if not ShopData.MAP[event.item_id] then
    return
  end

  PlayerSaveData.fetch(event.player_id).and_then(function(save_data)
    local mug = Net.get_player_mugshot(event.player_id)

    local data = ShopData.MAP[event.item_id]

    if not data then
      return
    end

    if save_data.ability == event.item_id then
      Net.message_player(event.player_id, data.name .. " is already set.", mug.texture_path, mug.animation_path)
      return
    end

    local owned = save_data.inventory[event.item_id]

    if (not owned or owned == 0) and not Debug.ENABLED then
      return
    end

    save_data.ability = event.item_id
    save_data:save(event.player_id)

    Net.message_player(
      event.player_id,
      "Switching to " .. data.name .. " next mission.",
      mug.texture_path,
      mug.animation_path
    )
  end)
end)

Net:on("player_disconnect", function(event)
  viewing_ability_shop[event.player_id] = nil
end)
