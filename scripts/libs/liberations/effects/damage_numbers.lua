local Preloader = require("scripts/libs/liberations/preloader")

local TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/damage_numbers.png")
local ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/damage_numbers.animation")

---@type Net.TextStyle
local TEXT_STYLE = {
  font = "DAMAGE_NUMBERS",
  custom_atlas = {
    texture_path = TEXTURE_PATH,
    animation_path = ANIMATION_PATH,
  },
  letter_spacing = 0
}

local DamageNumbers = {}

function DamageNumbers.spawn(area_id, number, x, y, z)
  local bot_id

  Net.synchronize(function()
    bot_id = Net.create_bot({
      area_id = area_id,
      warp_in = false,
      x = x,
      y = y,
      z = z
    })

    Net.create_text_sprite({
      parent_id = bot_id,
      text = tostring(number),
      text_style = TEXT_STYLE,
      h_align = "center",
      v_align = "center",
    })

    Net.animate_bot_properties(bot_id, {
      {
        properties = { { property = "Z", value = z, ease = "Floor" } },
        duration = 1 / 60,
      },
      {
        properties = { { property = "Z", value = z + 0.25, ease = "Floor" } },
        duration = 1 / 60,
      },
      {
        properties = { { property = "Z", value = z, ease = "Out" } },
        duration = 5 / 60,
      },
      {
        properties = { { property = "Z", value = z + 0.2, ease = "Floor" } },
        duration = 1 / 60,
      },
      {
        properties = { { property = "Z", value = z, ease = "Out" } },
        duration = 5 / 60,
      },
      {
        properties = { { property = "Z", value = z + 0.1, ease = "Floor" } },
        duration = 1 / 60,
      },
      {
        properties = { { property = "Z", value = z, ease = "Out" } },
        duration = 5 / 60,
      }
    })
  end)

  Async.sleep(1).and_then(function()
    Net.remove_bot(bot_id)
  end)
end

return DamageNumbers
