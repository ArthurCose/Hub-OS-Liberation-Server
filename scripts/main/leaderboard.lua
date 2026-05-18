local Constants = require("scripts/main/constants")
local Time = require("scripts/libs/liberations/time")
local json = require("scripts/libs/json")

local BOARD_COLOR = { r = 216, g = 144, b = 31 }
local FILE_PATH = "scripts/main/_data/leaderboard.json"

local RECENT_DURATION = 24 * 60 * 60

---@class LiberationServer.LeaderboardPlayer
---@field identity string
---@field name string
---@field navi string
---@field ability? string

---@class LiberationServer.LeaderboardResult
---@field creation_time number
---@field score number time or phases
---@field team LiberationServer.LeaderboardPlayer[] name and ability pair

---@class LiberationServer.AreaLeaderboard
---@field last_update number
---@field categories table<string, LiberationServer.LeaderboardResult?>

---@class LiberationServer.Leaderboard
---@field data table<string, LiberationServer.AreaLeaderboard> area_id to list
local Leaderboard = {
  data = {}
}

---@class LiberationServer.LeaderboardMissionLog
---@field area_id string
---@field phase number
---@field duration number seconds
---@field team LiberationServer.LeaderboardPlayer[] name and ability pair

---@param mission_log LiberationServer.LeaderboardMissionLog
function Leaderboard.log_mission(mission_log)
  local area_data = Leaderboard.data[mission_log.area_id]

  if not area_data then
    area_data = {
      last_update = 0,
      categories = {},
    }
    Leaderboard.data[mission_log.area_id] = area_data
  end

  local modified = false

  ---@param category string
  ---@param score number
  local function try_set(category, score)
    if not area_data.categories[category] or score < area_data.categories[category].score then
      ---@type LiberationServer.LeaderboardResult
      local result = {
        creation_time = os.time(),
        score = score,
        team = mission_log.team
      }
      area_data.categories[category] = result
      modified = true
    end
  end

  if #mission_log.team == 1 then
    try_set("solo_phase", mission_log.phase)
    try_set("solo_time", mission_log.duration)
  else
    -- skip saving team phase until we know how to handle this
    -- try_set("team_phase", mission_log.phase)
    try_set("team_time", mission_log.duration)
  end

  if modified then
    area_data.last_update = os.time()
    Leaderboard.save()
  end
end

-- these posts are recycled, with the author field modified every time the board is opened
local area_board_posts = {
  { read = true, id = "solo_phase", title = "Solo Phase" },
  { read = true, id = "solo_time",  title = "Solo Time", time = true },
  { read = true, id = "team_phase", title = "Team Phase" },
  { read = true, id = "team_time",  title = "Team Time", time = true }
}
---@type Net.BoardPost
local BACK_POST = { read = true, id = "back", title = "Back" }

local display_areas, display_area_scores, display_team

---@param player_id Net.ActorId
---@param result LiberationServer.LeaderboardResult
function display_team(player_id, area_id, result)
  ---@type Net.BoardPost[]
  local posts = { BACK_POST }

  for i, member in ipairs(result.team) do
    posts[#posts + 1] = {
      read = true,
      id = tostring(i),
      title = member.name,
      author = member.ability,
    }
  end

  local listener = function(post_id)
    if post_id == BACK_POST.id then
      return display_area_scores(player_id, area_id)
    end
  end

  return posts, listener
end

---@param player_id Net.ActorId
---@param area_id string
function display_area_scores(player_id, area_id)
  local data = Leaderboard.data[area_id]

  if not data then
    warn("Displayed leaderboard data to the player for" .. area_id .. ", but the data is missing?")
    return
  end

  local time = os.time()
  local posts = { BACK_POST }

  for _, post in ipairs(area_board_posts) do
    local result = data.categories[post.id]

    if result then
      if post.time then
        local HH = Time.floored_hours(result.score)
        local MM = Time.floored_minutes(result.score)
        local SS = Time.floored_seconds(result.score)
        post.author = HH .. ":" .. Time.pad_unit(MM) .. ":" .. Time.pad_unit(SS)
      else
        post.author = result.score
      end

      post.read = os.difftime(time, result.creation_time) > RECENT_DURATION

      posts[#posts + 1] = post
    end
  end

  local listener = function(post_id)
    if post_id == BACK_POST.id then
      return display_areas(player_id)
    end

    return display_team(player_id, area_id, data.categories[post_id])
  end

  return posts, listener
end

---@param player_id Net.ActorId
function display_areas(player_id)
  local time = os.time()

  ---@type Net.BoardPost[]
  local posts = {}

  for _, area_id in ipairs(Constants.MISSION_AREAS) do
    local area_data = Leaderboard.data[area_id]

    if area_data then
      local area_name = Net.get_area_name(area_id)
      posts[#posts + 1] = {
        read = os.difftime(time, area_data.last_update) > RECENT_DURATION,
        id = area_id,
        title = area_name
      }
    end
  end

  local listener = function(post_id)
    return display_area_scores(player_id, post_id)
  end

  return posts, listener
end

---@param player_id Net.ActorId
function Leaderboard.open(player_id)
  local posts, listener = display_areas(player_id)

  local emitter = Net.open_board(player_id, "Leaderboard", BOARD_COLOR, posts)

  emitter:on("post_selection", function(event)
    -- validate user input, mainly to handle asynchronous menu changes
    local found_post = false

    for _, post in ipairs(posts) do
      if post.id == event.post_id then
        found_post = true
      end
    end

    if not found_post then
      return
    end

    local new_posts, new_listener = listener(event.post_id)

    if new_posts then
      Net.synchronize(function()
        -- remove old posts
        for _, post in ipairs(posts) do
          Net.remove_post(player_id, post.id)
        end

        -- send new posts
        Net.append_posts(player_id, new_posts)
      end)

      posts = new_posts
    end

    if new_listener then
      listener = new_listener
    end
  end)

  display_areas(player_id)
end

function Leaderboard.save()
  Async.write_file(FILE_PATH, json.encode(Leaderboard.data))
end

Async.read_file(FILE_PATH).and_then(function(contents)
  if contents == "" then
    return
  end

  local loaded = json.decode(contents)

  if loaded then
    Leaderboard.data = loaded
  end
end)

return Leaderboard
