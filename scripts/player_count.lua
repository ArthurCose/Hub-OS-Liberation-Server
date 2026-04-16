local player_count = 0

local function print_player_count()
  print("Player Count: " .. player_count)
end

Net:on("player_request", function()
  player_count = player_count + 1
  print_player_count()
end)

Net:on("player_disconnect", function()
  player_count = player_count - 1
  print_player_count()
end)
