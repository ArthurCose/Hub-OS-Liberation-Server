local Leaderboard = require("scripts/main/leaderboard")

---@param scripts ScriptNodes
return function(scripts)
  scripts:implement_node("open leaderboard", function(context, object)
    Leaderboard.open(context.player_id)
  end)
end
