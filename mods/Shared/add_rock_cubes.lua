local CubesAndBouldersLib = require("BattleNetwork6.Libraries.CubesAndBoulders")
local spawn_obstacle = require("spawn_obstacle.lua")

local function cube_constructor()
  return CubesAndBouldersLib.new_rock_cube():create_obstacle()
end

local CUBE_LAYOUTS = {
  function()
    spawn_obstacle(2, 1, cube_constructor)
    spawn_obstacle(5, 3, cube_constructor)
  end,
  function()
    spawn_obstacle(2, 3, cube_constructor)
    spawn_obstacle(5, 1, cube_constructor)
  end,
  -- not a fan of this one
  -- function()
  --   spawn_obstacle(2, 2, cube_constructor)
  --   spawn_obstacle(5, 2, cube_constructor)
  -- end,
  function()
    spawn_obstacle(1, 1, cube_constructor)
    spawn_obstacle(6, 3, cube_constructor)
  end,
  function()
    spawn_obstacle(1, 3, cube_constructor)
    spawn_obstacle(6, 1, cube_constructor)
  end,
  function()
    spawn_obstacle(math.random(2, 5), math.random(1, 3), cube_constructor)
  end,
  function()
  end
}

return function()
  CUBE_LAYOUTS[math.random(#CUBE_LAYOUTS)]()
end
