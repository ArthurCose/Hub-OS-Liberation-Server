local Preloader = require("scripts/libs/liberations/preloader")

local TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/poof.png")
local ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/poof.animation")

local Poof = {}

---@param state "SMALL" | "LARGE"
function Poof.spawn(area_id, state, x, y, z)
  local bot_id

  Net.synchronize(function()
    bot_id = Net.create_bot({
      area_id = area_id,
      warp_in = false,
      texture_path = TEXTURE_PATH,
      animation_path = ANIMATION_PATH,
      animation = state,
      x = x,
      y = y,
      z = z
    })

    Net.animate_actor_properties(bot_id, {
      {
        properties = {
          { property = "Z", value = z + 3, ease = "Linear" }
        },
        duration = 1
      }
    })
  end)

  Async.sleep(5).and_then(function()
    Net.remove_bot(bot_id)
  end)
end

return Poof
