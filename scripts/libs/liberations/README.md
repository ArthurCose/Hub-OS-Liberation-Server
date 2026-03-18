# Hub OS Nebulous Liberations Lib

## Setting Up

The server side library comes in two pieces, assets and scripts.

Assets are found in `assets/liberations`, it must always have this path as the Lua library references files in this location.

You can find the Lua library in `scripts/libs/liberations`, it must always be at this path. This library also depends on `scripts/libs/direction.lua` and `scripts/libs/emotes.lua`

As for client side dependencies, the following list of IDs should be added to the `mod_downloader_entry.lua` file to keep dependencies up to date.

```lua
-- boss dependencies:
"BattleNetwork5.Virus.BigBrute", -- defines BattleNetwork5.Character.BigBrute for use in encounters
"BattleNetwork5.BlizzardMan", -- defines BattleNetwork5.BlizzardMan.Enemy for use in encounters
"com.Dawn.Shademan", -- defines com.Dawn.Enemy.Shademan[Alpha/Beta] for use in encounters
"BattleNetwork.Assets",
"BattleNetwork.SmokePoof",
"BattleNetwork6.TileStates.Ice",
"dev.konstinople.library.ai"
-- custom liberation encounter dependencies:
"dev.konstinople.library.liberation",
"BattleNetwork6.Statuses.Invincible",
```

Once you have this set up with a minimal map, you can tinker with the [Lua example](#example-lua-setup) at the bottom of this README to start playing.

### Minimal Map

- At least 1 [Spawn Point](#spawn-point) placed on the map for spawning players.
- A single [Dark Panel](#dark-panel) with a `Boss` set to allow players to complete the mission.
- The map custom property `Liberation Encounter` should be set to decide the default encounter for dark panels.
- `assets/liberations/tiles/collision.tsx` should be included as a tileset, even if it is unused in the map.
  - This tile set is used to toggle collision on panels for shadow step.
  - You can include this tileset by applying it to a tile or new object in the map, then deleting it.

### Encounters

The `data` param in `encounter_init(encounter, data)` is used by the server to pass relevant state into your encounter.

Keys on the `data` table and how you should handle them:

- `terrain`
  - `even`
    - The default field layout should be used.
  - `advantage`
    - The red team should have an extra column.
  - `disadvantage`
    - The blue team should have an extra column.
  - `surrounded`
    - The encounter should set two blue columns on each side of the field, with the red team stuck in the middle.
- `rank`
  - Only appears when the player is fighting a boss / miniboss.
  - It should be possible to use `Rank[data.rank]` to resolve the rank to pass for spawning this enemy.
- `health`
  - Only appears when the player is fighting a boss / miniboss. Used to restore the enemy's health from a previous battle.
  - The [:mutate()](https://docs.hubos.dev/client/lua-api/field-api/encounter#mutatormutatefunctionentity) function can be chained with `encounter:spawn_at()` to modify enemies spawned by `encounter`.
- `start_invincible`
  - Whether to apply one turn of invincibility to players in the encounter.
- `spectators`
  - Table mapping player indices to booleans for deciding which players to convert into spectators.

Basic encounter:

```lua
local LiberationLib = require("dev.konstinople.library.liberation")

---@param encounter Encounter
function encounter_init(encounter, data)
  -- LiberationLib.resolve_spectators(encounter, data)
  -- LiberationLib.apply_spawn_positions_for_terrain(encounter, data.terrain)
  -- LiberationLib.apply_terrain(data.terrain)
  -- LiberationLib.apply_statuses(data)
  -- encounter:enable_automatic_turn_end(true)
  -- encounter:set_turn_limit(3)

  -- this is a faster way to call the functions commented above
  LiberationLib.init(encounter, data)

  if data.terrain == "disadvantage" or data.terrain == "surrounded" then
    -- adapting enemies based on the terrain
    encounter:create_spawner("BattleNetwork3.Canodumb.Enemy", Rank.V1)
      :spawn_at(5, 2)
  else
    encounter:create_spawner("BattleNetwork3.Canodumb.Enemy", Rank.V1)
      :spawn_at(4, 2)
  end
```

Boss encounter:

```lua
local LiberationLib = require("dev.konstinople.library.liberation")

---@param encounter Encounter
function encounter_init(encounter, data)
  LiberationLib.init(data)

  local rank = Rank[data.rank] -- utilizing rank from the server
  encounter:create_spawner("BattleNetwork5.Character.BigBrute", rank)
    :spawn_at(5, 2)
    :mutate(function(entity)
      -- Restores health from data,
      -- and sends the final health back to the server when battle ends
      LiberationLib.sync_enemy_health(entity, encounter, data)
  end)
end
```

## Map Custom Properties

- `Liberation Encounter` a server path to the default encounter
  - example: `/server/mods/default-encounter`
- `Target Phase` number, optional. Defaults to 10
  - Used to resolve a reasonable target phase based on the player count
- `Target Player Count` number, optional. Defaults to 1
  - Used to resolve a reasonable target phase based on the player count
- `Minimum Target Phase` number, optional. Defaults to 1
  - Used to resolve a reasonable target phase based on the player count
- `Victory Music` string, optional. Path to music to play when players win.
- `Victory Background Texture` string, optional
- `Victory Background Animation` string, optional
- `Victory Background Vel X` number, optional
- `Victory Background Vel Y` number, optional

## Spawn Point

You should have one point object named `Spawn Point` somewhere on the map to decide where players spawn in.

You can chain multiple spawn points for the library to cycle through by adding a `Next Point` custom property with type object, pointing to another point (which may also have this property).

## Panels

Panels are Tile Objects, identified by the library using the `Type` field.

Every panel aside from `Dark Panel`, `Item Panel`, and `Trap Panel` should have a collision slightly larger than a tile defined. You can copy the collision from `assets/liberations/tiles/collision.tsx`.

The panels in `assets/liberations/tiles/panels.tsx` already have collisions properly set.

Supported panel `Type`s and custom properties can be found below.

### `Dark Panel`

- `Encounter` a server path to the encounter, uses the map's default when missing.
- `Boss` the name of the boss to spawn, overrides the `Encounter`
- `Rank` the rank of the boss, ex: `V1`, `SP`, `Omega`. Passed as `rank` in the encounter's data param.

### `Dark Hole`

- `Direction` the direction the character spawned should face.
- `Spawns` the name of the enemy to spawn, overrides `Encounter` when this character moves over another panel.
- `Encounter` the encounter for the dark hole and enemy, uses the map's default when missing.
- `Rank` the rank of the spawned enemy, ex: `V1`, `SP`, `Omega`. Passed as `rank` in the encounter's data param.

### `Trap Panel`

- `Encounter` a server path to the encounter, uses the map's default when missing.

### `Item Panel`

- `Specific Loot` the name of a specific loot, falls back to a pool otherwise
- `Encounter` a server path to the encounter, uses the map's default when missing.

### `Bonus Panel`

- `Specific Loot` the name of a specific loot, falls back to a pool otherwise

### `Gate Panel`

- `Gate Key` unlocks when a `KEY` with a matching property is looted

### `Indestructible Panel`

Converts into a Dark Panel when every `Dark Hole` is destroyed

## Specific Loot

Additional custom properties are supported by loot.

- `HEART` - Heals 50% of the player's health
- `CHIP` - WIP
- `MONEY` - Rewards money to the player. WIP
  - `Money` Determines how much money to give
- `BUGFRAG` - WIP
- `ORDER_POINT` - Grants the player 3 Order Points, the player can have at most 8 at a time.
- `INVINCIBILITY` - Grants the player on-map and a short in-battle invincibility, stopping Guardian and Darkloid attacks from harming them.
- `MAJOR_HIT` - Destroys a nearby Guardian. Won’t destroy bosses.
- `KEY`
  - `Gate Key` unlocks every `Gate Panel` with a matching value in the `Gate Key` property

## Example Lua Setup

```lua
local Mission = require("scripts/libs/liberations/mission")
local Ability = require("scripts/libs/liberations/ability")

---@param scripts ScriptNodes optional, used for instancing
---@param base_area string
---@param player_ids Net.ActorId[]
local function start_mission(scripts, base_area, player_ids)
  -- optional, create an instance with an instancer:
  local instancer = scripts:instancer()
  local instance_id = instancer:create_instance()
  local area_id = instancer:clone_area_to_instance(instance_id, base_area) --[[@as string]]

  -- create a new liberation mission:
  local mission = Mission:new(area_id)

  -- load players, we'll just give everyone LongSwrd
  -- but you can pass:
  -- - preset abilities from Ability
  -- - custom abilities that conform to the Liberation.Ability type
  -- - or nil for no ability
  for _, player_id in ipairs(player_ids) do
    mission:transfer_player(player_id, Ability.LongSwrd)
  end

  -- handling events:

  mission.events:on("money", function(event)
    -- update save data...

    -- update UI:
    local prev_money = Net.get_player_money(event.player_id)
    Net.set_player_money(event.player_id, prev_money + event.money)
  end)

  mission.events:on("player_kicked", function(event)
    -- send the player somewhere else
    Net.transfer_player(event.player_id, "default", true)

    if event.success then
      -- optional, reward the player in some way
    end
  end)

  -- instance cleanup
  local function cleanup_tick()
    if #mission:get_players() > 0 or mission:destroying() then
      return
    end

    Net:remove_listener("tick", cleanup_tick)

    mission:destroy().and_then(function()
      scripts:unload(area_id)
      instancer:remove_instance(instance_id)
    end)
  end

  Net:on("tick", cleanup_tick)
end

-- call start_mission somewhere else...
return start_mission
```
