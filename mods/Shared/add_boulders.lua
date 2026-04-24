local CubesAndBouldersLib = require("BattleNetwork6.Libraries.CubesAndBoulders")
local spawn_obstacle = require("spawn_obstacle.lua")

local function boulder_constructor()
  return CubesAndBouldersLib.new_boulder():create_obstacle()
end

local BOULDER_LAYOUTS = {
  function()
    spawn_obstacle(2, 1, boulder_constructor)
    spawn_obstacle(5, 3, boulder_constructor)
  end,
  function()
    spawn_obstacle(2, 3, boulder_constructor)
    spawn_obstacle(5, 1, boulder_constructor)
  end,
  -- not a fan of this one
  -- function()
  --   spawn_obstacle(2, 2, boulder_constructor)
  --   spawn_obstacle(5, 2, boulder_constructor)
  -- end,
  function()
    spawn_obstacle(1, 1, boulder_constructor)
    spawn_obstacle(6, 3, boulder_constructor)
  end,
  function()
    spawn_obstacle(1, 3, boulder_constructor)
    spawn_obstacle(6, 1, boulder_constructor)
  end,
  function()
    spawn_obstacle(math.random(2, 5), math.random(1, 3), boulder_constructor)
  end,
  function()
  end
}

return function()
  BOULDER_LAYOUTS[math.random(#BOULDER_LAYOUTS)]()
end
