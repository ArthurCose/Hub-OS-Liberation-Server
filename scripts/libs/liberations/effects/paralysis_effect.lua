---@class Liberation.ParalysisEffect
---@field sprite_id Net.SpriteId
local ParalysisEffect = {}

local SFX_PATH = "/server/assets/liberations/sounds/paralyze.ogg"

---@return Liberation.ParalysisEffect
function ParalysisEffect:new(actor_id, area_wide_sfx)
  local paralyze_effect = {
    bot_id = nil
  }

  setmetatable(paralyze_effect, self)
  self.__index = self

  local area_id, position

  if Net.is_bot(actor_id) then
    area_id = Net.get_bot_area(actor_id)
    position = Net.get_bot_position(actor_id)
  elseif Net.is_player(actor_id) then
    area_id = Net.get_player_area(actor_id)
    position = Net.get_player_position(actor_id)
  end

  if area_wide_sfx then
    Net.play_sound(area_id, SFX_PATH)
  elseif Net.is_player(actor_id) then
    Net.play_sound_for_player(actor_id, SFX_PATH)
  end

  paralyze_effect.sprite_id = Net.create_sprite({
    parent_id = actor_id,
    texture_path = "/server/assets/liberations/bots/paralyze.png",
    animation_path = "/server/assets/liberations/bots/paralyze.animation",
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
