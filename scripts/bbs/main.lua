--== Script for user posts on BBS ==--
-- Create a tile object
--
-- Properties for Minimap:
--   Type: Board
--
-- Required Custom Properties:
--   BBS: bool (true)
--   Name: name (make sure this is unique)
--   Color: color
--
-- Optional Custom Properties:
--   Character Limit: int
--   Post Limit: int
--
-- Required libs:
--   json.lua by rxi (store as scripts/libs/json.lua)

local json = require("scripts/libs/json")
local SAVE_LOCATION = "scripts/bbs/data.json"
local TITLE_LIMIT = 14
local AUTHOR_LIMIT = 7

local player_states = {}
local save_data = {}
local saving = false
local pending_save = false

Async.read_file(SAVE_LOCATION).and_then(function(value)
  local status, err = pcall(function()
    if value ~= "" then
      save_data = json.decode(value)
    end
  end)

  if not status then
    warn("Failed to read data from \"" .. SAVE_LOCATION .. "\":")
    print(err)
  end
end)

Net:on("player_connect", function(event)
  player_states[event.player_id] = {
    join_time = os.time(),
    read_time = {}
  }
end)

Net:on("player_disconnect", function(event)
  -- free memory
  player_states[event.player_id] = nil
end)

Net:on("object_interaction", function(event)
  local player_id = event.player_id
  local area = Net.get_player_area(player_id)
  local object = Net.get_object_by_id(area, event.object_id)

  if not object or not object.custom_properties.BBS then
    return
  end

  local board_name = object.custom_properties.Name
  local color_string = object.custom_properties.Color

  local color = {
    r = tonumber(string.sub(color_string, 4, 5), 16),
    g = tonumber(string.sub(color_string, 6, 7), 16),
    b = tonumber(string.sub(color_string, 8, 9), 16)
  }

  local posts = {
    {
      id = "POST",
      read = true,
      title = "POST"
    },
  }

  local player_state = player_states[player_id]
  local last_time = player_state.read_time[board_name] or player_state.join_time

  local board_data = save_data[board_name]

  if board_data then
    -- show pinned posts at the top
    for i = #board_data.posts, 1, -1 do
      local post = board_data.posts[i]

      if post.pin then
        -- shallow copy to prevent mutation
        post = shallow_copy(post)

        post.title = "PIN: " .. string.sub(post.title, 1, TITLE_LIMIT - 5)

        -- mark post as read if we've checked the board after this was posted
        if last_time == nil or post.time < last_time then
          post.read = true
        end

        posts[#posts + 1] = post
      end
    end

    -- show normal posts
    for i = #board_data.posts, 1, -1 do
      local post = board_data.posts[i]

      if not post.pin then
        -- shallow copy to prevent mutation
        post = shallow_copy(post)

        -- mark post as read if we've checked the board after this was posted
        if last_time == nil or post.time < last_time then
          post.read = true
        end

        posts[#posts + 1] = post
      end
    end
  end

  local emitter = Net.open_board(player_id, board_name, color, posts)

  emitter:on("post_selection", function(event)
    if event.post_id == "POST" then
      send_post_form(player_id, player_state, object)
    else
      show_post(player_id, board_name, event.post_id)
    end
  end)

  emitter:on("board_close", function()
    player_state.read_time[board_name] = os.time()
  end)

  -- track what board the player is looking at
  player_state.board = object
end)

function shallow_copy(original)
  local copy = {}

  for key, value in pairs(original) do
    copy[key] = value
  end

  return copy
end

function show_post(player_id, board_name, post_id)
  local posts = save_data[board_name].posts
  local post

  for _, p in ipairs(posts) do
    if p.id == post_id then
      post = p
      break
    end
  end

  if post then
    Net.message_player(player_id, post.body)
  end
end

send_post_form = Async.create_function(function(player_id, player_state, board)
  Net.message_player(player_id, "Message:")
  local text = Async.await(Async.prompt_player(player_id, board.custom_properties["Character Limit"]))

  if not text or contains_only_whitespace(text) then
    -- blank post, cancel post
    return
  end

  local wants_to_submit = Async.await(Async.question_player(player_id, "Do you want to submit?"))

  if wants_to_submit == 0 then
    -- player decided not to submit
    return
  end

  -- player said yes
  Net.message_player(player_id, "Title:")
  local title = Async.await(Async.prompt_player(player_id, TITLE_LIMIT, sanitize_title(text, TITLE_LIMIT)))

  create_post(player_id, board, title, text)
end)

function create_post(player_id, board, title, text)
  local board_name = board.custom_properties.Name
  local board_data = save_data[board_name]

  if not board_data then
    -- start storing posts for this board if there's no data
    board_data = {
      posts = {},
      next_id = 1
    }
  end

  local player_name = Net.get_player_name(player_id)
  local character_limit = tonumber(board.custom_properties["Character Limit"])

  if contains_only_whitespace(title) then
    title = text
  end

  local post = {
    time = os.time(),
    author = sanitize_title(player_name, AUTHOR_LIMIT),
    title = sanitize_title(title, TITLE_LIMIT),
    id = tostring(board_data.next_id),
    body = string.sub(text, 1, character_limit)
  }

  board_data.next_id = board_data.next_id + 1

  local post_limit = board.custom_properties["Post Limit"]

  if post_limit and #board_data.posts >= tonumber(post_limit) then
    -- remove the oldest non pinned post
    for i, old_post in ipairs(board_data.posts) do
      if not old_post.pin then
        table.remove(board_data.posts, i)
        break
      end
    end
  end

  board_data.posts[#board_data.posts + 1] = post
  save_data[board_name] = board_data
  save()

  push_post(board_name, post)
end

function contains_only_whitespace(text)
  return not string.find(text, "[^ \t\r\n]")
end

function sanitize_title(text, limit)
  text = string.gsub(text, "[\t\r\n]", " ", limit)
  return string.sub(text, 1, utf8.offset(text, limit))
end

function push_post(board_name, post)
  local next_id = nil

  local board_data = save_data[board_name]

  if board_data then
    -- find the first non pinned post
    local posts = save_data[board_name].posts

    for i = #posts, 1, -1 do
      local post = posts[i]

      if not post.pin then
        next_id = post.id
        break
      end
    end
  end

  local push_func

  if next_id then
    push_func = Net.prepend_posts
  else
    push_func = Net.append_posts
  end

  local new_posts = { post }

  for player_id, player_state in pairs(player_states) do
    if player_state.board and player_state.board.custom_properties.Name == board_name then
      push_func(player_id, new_posts, next_id)
    end
  end
end

function save()
  if saving then
    pending_save = true
    return
  end

  saving = true

  Async.write_file(SAVE_LOCATION, json.encode(save_data)).and_then(function()
    saving = false

    if pending_save then
      pending_save = false
      save()
    end
  end)
end
