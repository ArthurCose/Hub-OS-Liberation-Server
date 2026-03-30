local Parties = require("scripts/libs/parties")

local PartiesMenu = {
  BOARD_COLOR = { r = 72, g = 216, b = 120 },
}

local names = {}
local statuses = {}

---A 7 character string to display in the menu
---@param player_id Net.ActorId
---@param status string
function PartiesMenu.set_player_status(player_id, status)
  if Parties.player_dropped(player_id) then
    return
  end

  local key = Parties.key_from_player_id(player_id)

  if key then
    statuses[key] = status
  end
end

local INVITE_PREFIX = "invite:"

---@param player_id Net.ActorId
function PartiesMenu.view(player_id)
  ---@type Net.BoardPost[]
  local posts = {}

  -- list members
  local member_keys = Parties.list_all_members(player_id)
  local member_ids = {}

  for i, key in ipairs(member_keys) do
    posts[#posts + 1] = {
      id = "member:" .. i,
      title = names[key],
      author = statuses[key],
      read = true
    }

    local id = Parties.id_from_player_key(key)

    if id then
      member_ids[id] = true
    end
  end

  -- list nearby players
  local nearby_ids = Net.list_players(Net.get_player_area(player_id))
  local nearby_data = {}

  for _, id in ipairs(nearby_ids) do
    if not member_ids[id] then
      local name = names[Parties.key_from_player_id(player_id)]
      local i = #nearby_data + 1

      local post = {
        id = INVITE_PREFIX .. i,
        title = "[+] " .. name,
        author = "Invite",
        read = true
      }

      if Parties.has_invite_from(player_id, id) then
        post.author = "Join?"
      end

      posts[#posts + 1] = post

      nearby_data[i] = {
        id = id,
        name = name
      }
    end
  end

  local emitter = Net.open_board(
    player_id,
    "Party",
    PartiesMenu.BOARD_COLOR,
    posts
  )

  local textbox_options = {
    mug = Net.get_player_mugshot(player_id)
  }

  emitter:on("post_selection", function(event)
    if event.post_id:sub(1, #INVITE_PREFIX) ~= INVITE_PREFIX then
      return
    end

    -- selected a player to invite
    local i = tonumber(event.post_id:sub(#INVITE_PREFIX + 1))
    local invited = nearby_data[i]

    if not Parties.has_invite_from(player_id, invited.id) then
      -- invite this player
      Parties.invite(player_id, invited.id)
      Net.message_player(
        player_id,
        "Inviting " .. invited.name .. " to join the party.",
        textbox_options
      )
      return
    end

    Async.create_scope(function()
      local response = Async.await(Async.question_player(
        player_id,
        "Join " .. invited.name .. "'s party?",
        textbox_options
      ))

      if not response then
        -- no response, disconnected
        return
      end

      if response == 1 then
        if Parties.accept(player_id, invited.id) then
          -- refresh the menu
          PartiesMenu.view(player_id)
        else
          Net.message_player(player_id, "Invite expired.", textbox_options)
        end
        return
      end

      -- didn't want to join, try to invite the other player
      if Parties.has_invite_from(invited.id, player_id) then
        return
      end

      response = Async.await(Async.question_player(
        player_id,
        "Invite " .. invited.name .. " to join our party?",
        textbox_options
      ))

      if response == 1 then
        -- invite this player
        Parties.invite(player_id, invited.id)
        Net.message_player(
          player_id,
          "Invited " .. invited.name .. " to join the party.",
          textbox_options
        )
      end
    end)
  end)
end

Parties.events():on("player_dropped", function(event)
  names[event.key] = nil
  statuses[event.key] = nil
end)

Net:on("player_connect", function(event)
  local key = Parties.key_from_player_id(event.player_id)
  names[key] = Net.get_player_name(event.player_id)
  PartiesMenu.set_player_status(event.player_id, "Online")
end)

Net:on("player_disconnect", function(event)
  PartiesMenu.set_player_status(event.player_id, "Offline")
end)

return PartiesMenu
