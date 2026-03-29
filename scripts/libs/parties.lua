local Emotes = require("scripts/libs/emotes")

-- enabling tracks by actor id instead of secret
-- making it easier to join a party from the same PC
local DEBUG = false
local REQUEST_EMOTE = Emotes.QUESTION
local ACCEPT_EMOTE = Emotes.HAPPY


---@type table<string, Net.ActorId[]>
local player_ids_by_key = {}

local function resolve_player_id(key)
  local ids = player_ids_by_key[key]
  return ids and ids[1]
end

local function resolve_player_key(id)
  if not DEBUG then
    return Net.get_player_secret(id)
  elseif Net.is_player(id) then
    return id
  end
end

local function remove_by_value(list, value)
  for i = 1, #list do
    if list[i] == value then
      table.remove(list, i)
      break
    end
  end
end

---@type table<string, string[]>
local parties_by_key = {}
---@type table<string, string[]>
local pending_invites = {}
---@type table<string, string[]>
local outgoing_invites = {}
---@type table<table, any> values stored in parties_by_key are keys for this table
local party_data = {}

local Parties = {}

---@param player_id Net.ActorId
function Parties.list_members(player_id)
  local key = resolve_player_key(player_id)
  local keys = parties_by_key[key]

  local ids = {}

  if keys then
    for i = 1, #keys do
      ids[#ids + 1] = resolve_player_id(keys[i])
    end
  end

  if #ids == 0 then
    ids[#ids + 1] = player_id
  end

  return ids
end

---Retrieves data associated with the party
---@param player_id Net.ActorId
function Parties.data(player_id)
  local key = resolve_player_key(player_id)
  local keys = parties_by_key[key]

  if keys then
    return party_data[keys]
  end
end

---Associates data with the player's party
---
---Ignored if the player is not in a party
---@param player_id Net.ActorId
function Parties.set_data(player_id, data)
  local key = resolve_player_key(player_id)
  local keys = parties_by_key[key]

  if keys then
    party_data[keys] = data
  end
end

---Returns true if the players are partied or if they have a shared identity
---@param player_a Net.ActorId
---@param player_b Net.ActorId
function Parties.is_in_same_party(player_a, player_b)
  local key_a = resolve_player_key(player_a)
  local key_b = resolve_player_key(player_b)

  if key_a == key_b then
    return true
  end

  local party_a = parties_by_key[key_a]
  return party_a ~= nil and party_a == parties_by_key[key_b]
end

---@param inviter_id Net.ActorId
---@param invited_id Net.ActorId
function Parties.invite(inviter_id, invited_id)
  local invited_key = resolve_player_key(invited_id)
  local inviter_key = resolve_player_key(inviter_id)

  if not invited_key or not inviter_key then
    -- someone disconnected?
    return
  end

  Net.exclusive_player_emote(invited_id, inviter_id, REQUEST_EMOTE)

  -- create invite
  local invites = pending_invites[invited_key]

  if not invites then
    invites = {}
    pending_invites[invited_key] = invites
  end

  invites[#invites + 1] = inviter_key

  -- track in the other direction
  local sent_by_inviter = outgoing_invites[inviter_key]

  if not sent_by_inviter then
    sent_by_inviter = {}
    outgoing_invites[inviter_key] = sent_by_inviter
  end

  sent_by_inviter[#sent_by_inviter + 1] = invited_key
end

local function find_invite_index(invites, inviter_key)
  if not invites then
    return
  end

  for i, stored_inviter_key in ipairs(invites) do
    if stored_inviter_key == inviter_key then
      return i
    end
  end
end

local function delete_invite(inviter_key, invited_key)
  local invites = pending_invites[invited_key]

  if invites then
    remove_by_value(invites, inviter_key)

    if #invites == 0 then
      pending_invites[invited_key] = nil
    end
  end

  local sent_by_inviter = outgoing_invites[inviter_key]
  if sent_by_inviter then
    remove_by_value(sent_by_inviter, invited_key)
  end
end

---@param inviter_id Net.ActorId
---@param invited_id Net.ActorId
function Parties.cancel_invite(inviter_id, invited_id)
  local invited_key = resolve_player_key(invited_id)
  local inviter_key = resolve_player_key(inviter_id)

  if not invited_key or not inviter_key then
    -- someone disconnected?
    return
  end

  delete_invite(inviter_key, invited_key)
end

---@param inviter_id Net.ActorId
---@param invited_id Net.ActorId
function Parties.has_invite_from(invited_id, inviter_id)
  local invited_key = resolve_player_key(invited_id)
  local inviter_key = resolve_player_key(inviter_id)

  if not invited_key or not inviter_key then
    -- someone disconnected?
    return
  end

  return find_invite_index(pending_invites[invited_key], inviter_key) ~= nil
end

---@param inviter_id Net.ActorId
---@param invited_id Net.ActorId
function Parties.accept(invited_id, inviter_id)
  local invited_key = resolve_player_key(invited_id)
  local inviter_key = resolve_player_key(inviter_id)

  if not invited_key or not inviter_key then
    -- someone disconnected?
    return
  end

  local invites = pending_invites[invited_key]
  local invite_index = find_invite_index(invites, inviter_key)

  if not invite_index then
    -- no invite or already accepted
    return
  end

  -- delete the invite
  delete_invite(inviter_key, invited_key)

  -- join visual
  Net.exclusive_player_emote(invited_id, inviter_id, ACCEPT_EMOTE)
  Net.exclusive_player_emote(inviter_id, invited_id, ACCEPT_EMOTE)
  Net.exclusive_player_emote(invited_id, invited_id, ACCEPT_EMOTE)
  Net.exclusive_player_emote(inviter_id, inviter_id, ACCEPT_EMOTE)

  -- leave existing party to join the new one
  Parties.leave(invited_id)

  local members = parties_by_key[inviter_key]

  if members == nil then
    members = { inviter_key, invited_key }
    parties_by_key[inviter_key] = members
  else
    members[#members + 1] = invited_key
  end

  parties_by_key[invited_key] = members
end

function Parties.leave(player_id)
  local key = resolve_player_key(player_id)
  local member_keys = parties_by_key[key]

  if member_keys == nil then
    return
  end

  parties_by_key[key] = nil

  -- remove from party
  remove_by_value(member_keys, key)

  -- let everyone know you left
  local name = Net.get_player_name(player_id)

  for _, member_key in ipairs(member_keys) do
    local member_id = resolve_player_id(member_key)

    if member_id then
      Net.message_player(member_id, name .. " has left your party.")
    end
  end

  if #member_keys == 1 then
    local member_key = member_keys[1]
    local member_id = resolve_player_id(member_key)

    if member_id then
      Net.message_player(member_id, "Party disbanded!")
    end

    parties_by_key[member_key] = nil
    party_data[member_keys] = nil
  end
end

Net:on("player_request", function(event)
  local key = resolve_player_key(event.player_id)
  local ids = player_ids_by_key[key]

  if not ids then
    ids = {}
    player_ids_by_key[key] = ids
  end

  ids[#ids + 1] = event.player_id

  if #ids > 1 then
    -- we were already online with another device
    -- skip notifying
    return
  end

  -- notify party that you've reconnected
  local members = Parties.list_members(event.player_id)

  local resolved_id = resolve_player_id(key)
  local message = Net.get_player_name(event.player_id) .. " reconnected!"

  for _, member_id in ipairs(members) do
    if member_id ~= resolved_id then
      Net.message_player(member_id, message)
    end
  end
end)

Net:on("player_disconnect", function(event)
  -- untrack id
  local key = resolve_player_key(event.player_id)
  local ids = player_ids_by_key[key]

  remove_by_value(ids, event.player_id)

  if #ids > 0 then
    return
  end

  player_ids_by_key[key] = nil

  -- delete every outgoing invite
  local sent_invites = outgoing_invites[key]

  if sent_invites then
    outgoing_invites[key] = nil

    for i = 1, #sent_invites do
      delete_invite(key, sent_invites[i])
    end
  end

  -- see if we're partied
  local member_keys = parties_by_key[key]

  if not member_keys then
    -- not in a party
    return
  end

  -- see if we should drop this party
  local members = Parties.list_members(event.player_id)

  if members[1] == nil or members[1] == event.player_id then
    -- we were the last member

    for _, member_key in ipairs(member_keys) do
      parties_by_key[member_key] = nil
    end

    party_data[member_keys] = nil
    return
  end

  -- notify the party about the disconnect
  local message = Net.get_player_name(event.player_id) .. " disconnected!"

  for _, member_id in ipairs(members) do
    Net.message_player(member_id, message)
  end
end)

return Parties
