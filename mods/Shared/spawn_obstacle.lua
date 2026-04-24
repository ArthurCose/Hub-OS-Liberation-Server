return function(x, y, constructor)
  local tile = Field.tile_at(x, y)

  if not tile then
    return
  end

  ---@type Entity
  local obstacle = constructor()
  obstacle:set_team(Team.Other)
  obstacle:set_owner(Team.Other)
  Field.spawn(obstacle, tile)

  -- reserve the tile before the cube is spawned
  tile:reserve_for(obstacle)

  -- make sure to clean up the reservation
  local action = Action.new(obstacle)
  action.on_action_end_func = function()
    tile:remove_reservation_for(obstacle)
  end

  obstacle:queue_action(action)
end
