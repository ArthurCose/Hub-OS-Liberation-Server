local Preloader = require("scripts/libs/liberations/preloader")

local TEXTURE_PATH = Preloader.add_asset("/server/assets/liberations/bots/explosion.png")
local ANIMATION_PATH = Preloader.add_asset("/server/assets/liberations/bots/explosion.animation")
local SFX_PATH = Preloader.add_asset("/server/assets/liberations/sounds/explosion.ogg")

local TOTAL_EXPLOSIONS = 3
local EXPLOSION_DURATION = .6
local EXPLOSION_AXIS_RANGE = .5

---@param self Liberation.ExplodingEffect
local function update_tracked_position(self)
  local actor_id = self.tracked_actor_id

  if Net.is_actor(actor_id) then
    self.area_id = Net.get_actor_area(actor_id)
    self.position = Net.get_actor_position(actor_id)
  end
end

---@param self Liberation.ExplodingEffect
local function explode(self, explosion_bot_id)
  if not Net.is_bot(explosion_bot_id) then
    -- bot deleted from deleted instance
    return
  end

  update_tracked_position(self)

  local offset_x = (math.random() * 2 - 1) * EXPLOSION_AXIS_RANGE
  local offset_y = (math.random() * 2 - 1) * EXPLOSION_AXIS_RANGE

  Net.transfer_actor(
    explosion_bot_id,
    self.area_id,
    false,
    self.position.x + offset_x,
    self.position.y + offset_y,
    self.position.z
  )

  if self.done then
    Net.remove_bot(explosion_bot_id)
    return
  end

  Net.play_sound(self.area_id, SFX_PATH)

  if math.random(2) == 1 then
    Net.animate_actor(explosion_bot_id, "EXPLODE")
  else
    Net.animate_actor(explosion_bot_id, "SMOKE")
  end

  -- explode again
  Async.sleep(EXPLOSION_DURATION)
      .and_then(function()
        explode(self, explosion_bot_id)
      end)
end

---@param self Liberation.ExplodingEffect
local function spawn(self)
  for i = 1, TOTAL_EXPLOSIONS, 1 do
    local explosion_bot_id = Net.create_bot({
      texture_path = TEXTURE_PATH,
      animation_path = ANIMATION_PATH,
      area_id = self.area_id,
      warp_in = false,
      x = self.position.x,
      y = self.position.y,
      z = self.position.z,
    })

    if i > 1 then
      Async.sleep((i - 1) * EXPLOSION_DURATION / TOTAL_EXPLOSIONS)
          .and_then(function()
            explode(self, explosion_bot_id)
          end)
    else
      explode(self, explosion_bot_id)
    end
  end
end

---@class Liberation.ExplodingEffect
---@field tracked_actor_id Net.ActorId
---@field position? Net.Position
---@field area_id? string
local ExplodingEffect = {}

---@return Liberation.ExplodingEffect
function ExplodingEffect:new(actor_id)
  local exploding_effect = {
    tracked_actor_id = actor_id,
    position = nil,
    area_id = nil,
    done = false
  }

  setmetatable(exploding_effect, self)
  self.__index = self

  update_tracked_position(exploding_effect)
  spawn(exploding_effect)

  return exploding_effect
end

function ExplodingEffect:remove()
  self.done = true
end

return ExplodingEffect
