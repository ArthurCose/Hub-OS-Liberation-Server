local Emotes = require("scripts/libs/emotes")
local Direction = require("scripts/libs/direction")

local area = "default"
local prog_textbox_options = {
  mug = {
    texture_path = "/server/assets/mugs/prog.png",
    animation_path = "/server/assets/mugs/prog.animation",
  }
}

local spawn = Net.get_object_by_name(area, "Help Spawn")

local id = Net.create_bot({
  area_id = area,
  texture_path = "/server/assets/bots/prog.png",
  animation_path = "/server/assets/bots/prog.animation",
  x = spawn.x,
  y = spawn.y,
  z = spawn.z,
  direction = Direction.DOWN_RIGHT,
  solid = true
})

local LIBERATIONS_HELP_TEXT = [[
LIBERATION MISSIONS ARE A GAME MODE ADDED IN MMBN5.
THE GOAL OF A LIBERATION MISSION IS TO DEFEAT THE BOSS AT THE END OF THE AREA.
IN THE WAY OF YOUR PATH ARE PURPLE TILES CALLED DARK PANELS. TO LIBERATE A PANEL YOU MUST WIN A BATTLE WITHIN THREE TURNS.
]]

local PARTIES_INTRO_TEXT = [[
PARTIES ALLOW YOU TO PLAY LIBERATION MISSIONS IN A GROUP. TO START A PARTY, WALK UP TO ANOTHER PLAYER AND PRESS interact. YOU WILL SEE A MENU THAT LOOKS LIKE THIS:
]]

local PARTIES_SIGNAL_TEXT = [[
IF YOU SELECT YES, THE OTHER PLAYER WILL SEE A ? ABOVE YOUR HEAD. LIKE THIS:
]]

local PARTIES_RESPONSE_TEXT = [[
WHEN YOU SEE A PLAYER WITH A ? ABOVE THEIR HEAD, INTERACTING WITH THAT PLAYER WILL ALLOW YOU TO RESPOND TO THEIR REQUEST. IF YOU ACCEPT YOU WILL BE ADDED TO THEIR PARTY AND BOTH MEMBERS WILL BE NOTIFIED THROUGH THIS INDICATOR:
]]

local help = Async.create_function(function(player_id)
  Net.message_player(
    player_id,
    "I'M THE TUTORIAL PROG. FOR BASIC INFORMATION YOU CAN VISIT ME!\nWHAT WOULD YOU LIKE TO KNOW?",
    prog_textbox_options
  )

  while true do
    local response = Async.await(Async.quiz_player(
      player_id,
      "Liberations",
      "Parties",
      "Nothing",
      prog_textbox_options
    ))

    if response == nil then
      -- disconnected
      break
    end

    if response == 0 then
      -- liberations
      Net.message_player(player_id, LIBERATIONS_HELP_TEXT, prog_textbox_options)
    elseif response == 1 then
      -- parties
      local mugshot = Net.get_player_mugshot(player_id)

      -- initial explanation
      Net.message_player(player_id, PARTIES_INTRO_TEXT, prog_textbox_options)
      Net.question_player(player_id, "Recruit Anon?", mugshot.texture_path, mugshot.animation_path) -- recruit example

      -- show how request signaling works
      Async.await(Async.message_player(player_id, PARTIES_SIGNAL_TEXT, prog_textbox_options))
      Net.exclusive_player_emote(player_id, id, Emotes.QUESTION)
      Async.await(Async.sleep(2))

      -- show what an accepted request looks like
      Async.await(Async.message_player(player_id, PARTIES_RESPONSE_TEXT, prog_textbox_options))
      Net.exclusive_player_emote(player_id, id, Emotes.HAPPY)
      Net.exclusive_player_emote(player_id, player_id, Emotes.HAPPY)
      Async.await(Async.sleep(2))
    end

    response = Async.await(Async.question_player(
      player_id,
      "IS THERE ANYTHING ELSE YOU WOULD LIKE TO KNOW?",
      prog_textbox_options
    ))

    if response ~= 1 then
      -- said no or disconnected
      break
    end
  end
end)

local receiving_help = {}
Net:on("actor_interaction", function(event)
  if event.actor_id ~= id or event.button ~= 0 then return end

  local player_id = event.player_id

  if receiving_help[player_id] then return end

  local player_pos = Net.get_player_position(player_id)
  Net.set_bot_direction(id, Direction.from_points(spawn, player_pos))

  Net.lock_player_input(player_id)

  receiving_help[player_id] = true
  help(player_id)
  receiving_help[player_id] = nil

  Net.unlock_player_input(player_id)
end)


Net:on("player_disconnect", function(event)
  local player_id = event.player_id
  receiving_help[player_id] = nil
end)
