local Preloader = require("scripts/libs/liberations/preloader")

local TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/paralyze.png")
local ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/paralyze.animation")
local SFX_PATH = Preloader.add_asset("/server/assets/liberations/sounds/paralyze.ogg")

---@class Liberation.ParalysisEffect
---@field sprite_id Net.SpriteId
local ParalysisEffect = {}

---@return Liberation.ParalysisEffect
function ParalysisEffect:new(actor_id, area_wide_sfx)
  local paralyze_effect = {
    bot_id = nil
  }

  setmetatable(paralyze_effect, self)
  self.__index = self

  local area_id

  if Net.is_bot(actor_id) then
    area_id = Net.get_bot_area(actor_id)
  elseif Net.is_player(actor_id) then
    area_id = Net.get_player_area(actor_id)
  end

  if area_wide_sfx then
    Net.play_sound(area_id, SFX_PATH)
  elseif Net.is_player(actor_id) then
    Net.play_sound_for_player(actor_id, SFX_PATH)
  end

  paralyze_effect.sprite_id = Net.create_sprite({
    parent_id = actor_id,
    texture_path = TEXTURE_PATH,
    animation_path = ANIMATION_PATH,
    animation = "THIN",
    loop_animation = true,
    area_id = area_id,
    warp_in = false,
  })

  return paralyze_effect
end

function ParalysisEffect:remove()
  Net.remove_sprite(self.sprite_id)
end

return ParalysisEffect
