local RecoverEffect = {}

local SFX_PATH = "/server/assets/liberations/sound effects/recover.ogg"

function RecoverEffect:new(actor_id, area_wide_sfx)
  local recover_effect = {
    promise = nil
  }

  setmetatable(recover_effect, self)
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

  local recover_bot_id = Net.create_bot({
    texture_path = "/server/assets/liberations/bots/recover.png",
    animation_path = "/server/assets/liberations/bots/recover.animation",
    area_id = area_id,
    warp_in = false,
    x = position.x + 1 / 32,
    y = position.y + 1 / 32,
    z = position.z,
  })

  Net.animate_bot(recover_bot_id, "RECOVER")

  Async.sleep(.5).and_then(function()
    Net.remove_bot(recover_bot_id)
  end)

  return recover_effect
end

return RecoverEffect
