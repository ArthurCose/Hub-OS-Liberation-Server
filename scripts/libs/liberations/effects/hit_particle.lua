local Preloader = require("scripts/libs/liberations/preloader")

local TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/hit_particles.png")
local ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/hit_particles.animation")

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
    z = z,
    sprite_layer = -1
  })

  Async.sleep(5).and_then(function()
    Net.remove_bot(bot_id)
  end)
end

return HitParticle
