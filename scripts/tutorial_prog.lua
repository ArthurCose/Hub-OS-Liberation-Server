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

local LIBERATIONS_SCRIPT = {
  "THE NET HAS BEEN TAKEN OVER BY DARKLOIDS!",
  "ENTERING THIS DOOR WILL BEGIN A MISSION TO LIBERATE AN AREA FROM THEIR CONTROL.",
  "THERE ARE DARK PANELS IN YOUR PATH.",
  "TO LIBERATE A PANEL YOU MUST WIN A BATTLE WITHIN THREE TURNS.",
  "ONCE YOU'VE COMPLETED YOUR ACTION FOR THE TURN, A CHECKMARK WILL APPEAR OVER YOUR HEAD. LIKE THIS:",
  function(player_id)
    Net.exclusive_player_emote(player_id, player_id, Emotes.GREEN_CHECK)
    Async.await(Async.sleep(2))
  end,
  "YOU WILL BE UNABLE TO MOVE UNTIL ALL PLAYERS HAVE COMPLETED THEIR TURN FOR THE PHASE.",
  "PRESSING THE [CONFIRM] BUTTON WHILE IN THIS STATE WILL CYCLE BETWEEN PLAYERS TO FOLLOW.",
  "WHEN ANY PLAYER STARTS A BATTLE YOU'LL JOIN IN AS A SPECTATOR.",
  "ALL DARK HOLES MUST BE LIBERATED BEFORE YOU CAN FACE THE DARKLOID.",
  "DEFEATING THE DARKLOID WILL COMPLETE THE MISSION!"
}

local PARTIES_SCRIPT = {
  "PARTIES ALLOW YOU TO PLAY LIBERATION MISSIONS AS A TEAM.",
  "TO START A PARTY, WALK UP TO ANOTHER PLAYER AND PRESS [CONFIRM].",
  "YOU WILL SEE A MENU THAT LOOKS LIKE THIS:",
  function(player_id)
    local mugshot = Net.get_player_mugshot(player_id)
    Net.question_player(player_id, "Recruit Anon?", mugshot.texture_path, mugshot.animation_path)
  end,
  "IF YOU SELECT YES, THE OTHER PLAYER WILL SEE A ? ABOVE YOUR HEAD. LIKE THIS:",
  function(player_id)
    Net.exclusive_player_emote(player_id, id, Emotes.QUESTION)
    Async.await(Async.sleep(2))
  end,
  "WHEN YOU SEE A PLAYER WITH A ? ABOVE THEIR HEAD, INTERACTING WITH THAT PLAYER WILL ALLOW YOU TO RESPOND TO THEIR REQUEST.",
  "IF YOU ACCEPT YOU WILL BE ADDED TO THEIR PARTY AND BOTH MEMBERS WILL BE NOTIFIED THROUGH THIS INDICATOR:",
  function(player_id)
    Net.exclusive_player_emote(player_id, id, Emotes.HAPPY)
    Net.exclusive_player_emote(player_id, player_id, Emotes.HAPPY)
    Async.await(Async.sleep(2))
  end
}

-- expects to run within an async scope
local function process_tutorial_script(player_id, script)
  for i = 1, #script do
    local current = script[i]
    local next = script[i + 1]

    if type(current) == "function" then
      current(player_id)
    elseif type(next) == "function" then
      -- need to wait
      Async.await(Async.message_player(player_id, current, prog_textbox_options))
    else
      -- don't need to wait
      Net.message_player(player_id, current, prog_textbox_options)
    end
  end
end

local receiving_help = {}

local help = Async.create_function(function(player_id)
  Net.lock_player_input(player_id)

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
      {
        mug = prog_textbox_options.mug,
        cancel_response = 2
      }
    ))

    if response == nil then
      -- disconnected
      break
    end

    if response == 0 then
      -- liberations
      process_tutorial_script(player_id, LIBERATIONS_SCRIPT)
    elseif response == 1 then
      -- parties
      process_tutorial_script(player_id, PARTIES_SCRIPT)
    elseif response == 2 then
      break
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

  Net.unlock_player_input(player_id)
  receiving_help[player_id] = nil
end)

Net:on("actor_interaction", function(event)
  if event.actor_id ~= id or event.button ~= 0 then return end

  local player_id = event.player_id

  if receiving_help[player_id] then return end

  local player_pos = Net.get_player_position(player_id)
  Net.set_bot_direction(id, Direction.from_points(spawn, player_pos))

  receiving_help[player_id] = true
  help(player_id)
end)


Net:on("player_disconnect", function(event)
  local player_id = event.player_id
  receiving_help[player_id] = nil
end)
