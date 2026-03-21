--- Custom Data:

local NAME =
"ACDC2"                                      -- This server's name (currently unused, but may be used in the future)
local MESSAGE = "Liberation Missions - WIP"  -- Dialog for the ampstr
local WARP_ADDRESS = "hubos.konstinople.dev" -- What address should the warp link to (port is ignored)
local WARP_DATA = "index"                    -- What data should the warp from the index contain

--- Script (do not modify):

local INDEX_ADDRESS = "servers.hubos.dev"
local POLL_RATE = 5 * 60

local online_count = 0

Net:on("player_join", function()
  online_count = online_count + 1
end)

Net:on("player_disconnect", function()
  online_count = online_count - 1
end)

local function send_analytics(address)
  Async.message_server(address, "index_analytics:online=" .. online_count)
end

local function send_register(address)
  local response = "index_register:name=" .. Net.encode_uri_component(NAME) ..
      "&message=" .. Net.encode_uri_component(MESSAGE) ..
      "&address=" .. Net.encode_uri_component(WARP_ADDRESS) ..
      "&data=" .. Net.encode_uri_component(WARP_DATA)

  Async.message_server(address, response)
end

local server_message_handlers = {
  index_request = function(event)
    send_register(event.address)
  end,
  index_verify = function(event, data)
    Async.message_server(event.address, "index_verify:" .. data)
    send_analytics(event.address)
  end
}

Net:on("server_message", function(event)
  local colon_index = string.find(event.data, ":", 1, true)

  if not colon_index then
    -- invalid messsage
    return
  end

  local prefix = string.sub(event.data, 1, colon_index - 1)
  local handler = server_message_handlers[prefix]

  if handler then
    handler(event, string.sub(event.data, colon_index + 1))
  end
end)

local function loop()
  send_analytics(INDEX_ADDRESS)
  Async.sleep(POLL_RATE).and_then(loop)
end

send_register(INDEX_ADDRESS)
loop()
