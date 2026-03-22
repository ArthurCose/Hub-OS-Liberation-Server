local Preloader = require("scripts/libs/liberations/preloader")

local TEXTURE_PATH = "/server/assets/liberations/bots/hit_particles.png"
local ANIMATION_PATH = "/server/assets/liberations/bots/hit_particles.animation"

Preloader.add_asset(TEXTURE_PATH)
Preloader.add_asset(ANIMATION_PATH)

local HitParticle = {}

function HitParticle.spawn(area_id, state, x, y, z)
  local bot_id = Net.create_bot({
    area_id = area_id,
    warp_in = false,
    texture_path = TEXTURE_PATH,
    animation_path = ANIMATION_PATH,
    animation = state,
    x = x,
    y = y,
    z = z
  })

  Async.sleep(5).and_then(function()
    Net.remove_bot(bot_id)
  end)
end

return HitParticle
