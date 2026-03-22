local HealthSprites = {}

local sprite_ids = {}

---Creates or updates a sprite for the actor
---@param actor_id Net.ActorId
---@param health number
function HealthSprites.update_sprite(actor_id, health)
  HealthSprites.remove_sprite(actor_id)

  sprite_ids[actor_id] = Net.create_text_sprite({
    parent_id = actor_id,
    text = tostring(health),
    text_style = {
      font = "ENTITY_HP",
      letter_spacing = 0
    },
    v_align = "top",
    h_align = "center",
    y = 2,
  })
end

---Deletes the associated health sprite for this actor
---@param actor_id Net.ActorId
function HealthSprites.remove_sprite(actor_id)
  local sprite_id = sprite_ids[actor_id]

  if sprite_id then
    Net.remove_sprite(sprite_id)
    sprite_ids[actor_id] = nil
  end
end

return HealthSprites
