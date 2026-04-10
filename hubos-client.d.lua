---@meta
-- https://luals.github.io/wiki/annotations/
---@diagnostic disable: missing-return, unused-local, inject-field

---@type string
_folder_path = nil

---@class EntityId

---@class Namespace

---@enum Lifetime
Lifetime = {
  Local = 0,
  ActiveBattle = 0,
  Battle = 0,
  Scene = 0,
  CardSelectOpen = 0,
  CardSelectClose = 0,
  CardSelectComplete = 0,
  Nil = 0,
}

--- - `Direction.None`
--- - `Direction.Up`
--- - `Direction.Left`
--- - `Direction.Down`
--- - `Direction.Right`
--- - `Direction.UpLeft`
--- - `Direction.UpRight`
--- - `Direction.DownLeft`
--- - `Direction.DownRight`
---@enum Direction
Direction = {
  None = 0,
  Up = 0,
  Left = 0,
  Down = 0,
  Right = 0,
  UpLeft = 0,
  UpRight = 0,
  DownLeft = 0,
  DownRight = 0,
}

--- - `Element.None`
--- - `Element.Fire`
--- - `Element.Aqua`
--- - `Element.Elec`
--- - `Element.Wood`
--- - `Element.Sword`
--- - `Element.Wind`
--- - `Element.Cursor`
--- - `Element.Summon`
--- - `Element.Plus`
--- - `Element.Break`
---@enum Element
Element = {
  None = 0,
  Fire = 0,
  Aqua = 0,
  Elec = 0,
  Wood = 0,
  Sword = 0,
  Wind = 0,
  Cursor = 0,
  Summon = 0,
  Plus = 0,
  Break = 0,
}

---@enum Rank
Rank = {
  V1 = 0,
  V2 = 0,
  V3 = 0,
  V4 = 0,
  V5 = 0,
  V6 = 0,
  SP = 0,
  EX = 0,
  Rare1 = 0,
  Rare2 = 0,
  NM = 0,
  RV = 0,
  DS = 0,
  Alpha = 0,
  Beta = 0,
  Omega = 0,
  Sigma = 0,
}

---@enum Highlight
Highlight = {
  None = 0,
  Flash = 0,
  Solid = 0,
}

---@enum CardClass
CardClass = {
  Standard = 0,
  Mega = 0,
  Giga = 0,
  Dark = 0,
  Recipe = 0,
}

---@enum Team
Team = {
  Other = 0,
  Red = 0,
  Blue = 0,
}

---
---@enum AudioBehavior
AudioBehavior = {
  --- Audio will play regardless of other audio. Same as `AudioBehavior.Overlap`
  Default = 0,
  --- Audio will play regardless of other audio.
  Overlap = 0,
  --- Audio will not play if another instance of itself is playing with NoOverlap, Restart, or LoopSection.
  NoOverlap = 0,
  --- If this audio is already playing with NoOverlap or Restart, it will be restarted. Looping audio will not be restarted.
  ---
  --- Plays the audio as normal if there is no other instance of itself.
  Restart = 0,
  --- The sound will continue playing if it was already playing. If AudioBehavior.LoopSection was applied, it will stop looping at `end_sample`
  EndLoop = 0,
}

---@enum Playback
Playback = {
  Once = 0,
  Loop = 0,
  Bounce = 0,
  Reverse = 0,
}

---@enum ColorMode
ColorMode = {
  Add = 0,
  Multiply = 0,
  Adopt = 0,
}

---@enum SpriteShaderEffect
SpriteShaderEffect = {
  None = 0,
  Grayscale = 0,
  Pixelate = 0,
}

--- - `Compare.LT`
---   - Less Than `<`
--- - `Compare.LE`
---   - Less Than Equal `<=`
--- - `Compare.NE`
---   - Not Equal `~=`
--- - `Compare.EQ`
---   - Equal `==`
--- - `Compare.GT`
---   - Greater Than `>`
--- - `Compare.GE`
---   - Greater Than Equal `>=`
---@enum Compare
Compare = {
  LT = 0,
  LE = 0,
  EQ = 0,
  NE = 0,
  GT = 0,
  GE = 0,
}

---@enum DefensePriority
DefensePriority = {
  Barrier = 0,
  Action = 0,
  Body = 0,
  Trap = 0,
  Last = 0,
}

---@enum DefenseOrder
DefenseOrder = {
  Always = 0,
  CollisionOnly = 0,
}

---@enum ActionType
ActionType = {
  All = 0,
  Normal = 0,
  Charged = 0,
  Special = 0,
  Card = 0,
  Scripted = 0,
}

---@enum TimeFreezeChainLimit
TimeFreezeChainLimit = {
  Unlimited = {} --[[@as TimeFreezeChainLimit]],
  PerTeam =
  ---@param n number
  ---@return TimeFreezeChainLimit
      function(n) end,
  PerEntity =
  ---@param n number
  ---@return TimeFreezeChainLimit
      function(n) end,
}

---@enum Shadow
Shadow = {
  None = "",
  Small = "",
  Big = "",
}

---
---@enum Hit
---@type { [string]: Hit }
Hit = {}
Hit.None = Hit._
Hit.RetainIntangible = Hit._
Hit.NoCounter = Hit._
Hit.Drag = Hit._
Hit.Drain = Hit._
Hit.Flinch = Hit._
Hit.Flash = Hit._
Hit.PierceInvis = Hit._
Hit.PierceGuard = Hit._
Hit.PierceGround = Hit._
Hit.Freeze = Hit._
Hit.Paralyze = Hit._
Hit.Root = Hit._
Hit.Blind = Hit._
Hit.Confuse = Hit._

---@enum TileState
---@type { [string]: TileState }
TileState = {}
TileState.Void = TileState._
TileState.Normal = TileState._
TileState.PermaHole = TileState._
TileState.Cracked = TileState._
TileState.Broken = TileState._

---@enum Input
local _Input = { _ = 0 }

Input = {
  Held = {
    Up = _Input._,
    Left = _Input._,
    Right = _Input._,
    Down = _Input._,
    Use = _Input._,
    Special = _Input._,
    Shoot = _Input._,
    FaceLeft = _Input._,
    FaceRight = _Input._,
    LeftShoulder = _Input._,
    RightShoulder = _Input._,
    Confirm = _Input._,
    Cancel = _Input._,
    EndTurn = _Input._,
    Ready = _Input._,
  },
  Pressed = {
    Up = _Input._,
    Left = _Input._,
    Right = _Input._,
    Down = _Input._,
    Use = _Input._,
    Special = _Input._,
    Shoot = _Input._,
    FaceLeft = _Input._,
    FaceRight = _Input._,
    LeftShoulder = _Input._,
    RightShoulder = _Input._,
    Confirm = _Input._,
    Cancel = _Input._,
    EndTurn = _Input._,
    Ready = _Input._,
  },
  Pulsed = {
    Up = _Input._,
    Left = _Input._,
    Right = _Input._,
    Down = _Input._,
    Use = _Input._,
    Special = _Input._,
    Shoot = _Input._,
    FaceLeft = _Input._,
    FaceRight = _Input._,
    LeftShoulder = _Input._,
    RightShoulder = _Input._,
    Confirm = _Input._,
    Cancel = _Input._,
    EndTurn = _Input._,
    Ready = _Input._,
  },
}

--- Most of these functions will throw if the entity has been erased. `entity:will_erase_eof()` and `entity:deleted()` will never throw and can be used to see if the entity is still safe to use.
---@class Entity
--- Called after processing defenses on the hit entity, if damage isn't blocked by [DefenseRules](https://docs.hubos.dev/client/lua-api/defense-api/defense-rule).
---
--- Commonly used for spawning hit particles or applying secondary effects.
---@field on_attack_func fun(self: Entity, entity: Entity)
--- Called when the spell hits an entity and isn't blocked by [intangibility](https://docs.hubos.dev/client/lua-api/entity-api/living#livingset_intangibleintangible-intangible_rule).
---
--- Commonly used by spells that delete on collision.
---@field on_collision_func fun(self: Entity, entity: Entity)
--- Called at the start of the intro state (the state before card select first opens).
---
--- When unset or returning nil, the default intro for the character type will be used.
---
--- The returned action will not be immediately executed. When the action is completed, the next character's intro will begin or the intro state will end.
---@field intro_func fun(self: Entity): Action|nil
--- Used to handle movement input, setting this overrides the default handling.
---@field movement_func fun(self: Entity, direction: Direction)
--- Used to generate movement input, setting this overrides the input gathering method.
---@field movement_input_func fun(self: Entity): Direction?
--- Will not be called if there's no matching `calculate_card_charge_time_func`
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) or `nil` is expected as a return value.
---@field charged_card_func fun(self: Entity, card_properties: CardProperties): Action|nil
--- Will not be called if there's no matching `charged_card_func`
---
--- Return a number representing the minimum amount of time the card use button must be held for `charged_card_func` to be called to handle this card.
---@field calculate_card_charge_time_func fun(self: Entity, card_properties: CardProperties): number|nil
--- Should return an [Action](https://docs.hubos.dev/client/lua-api/attack-api/action)
---@field special_attack_func fun(self: Entity): Action|nil
--- Should return an [Action](https://docs.hubos.dev/client/lua-api/attack-api/action)
---
--- Many player mods use [Buster](https://docs.hubos.dev/client/lua-api/attack-api/action#buster) for their return value.
---
--- ```lua
--- player.charged_attack_func = function(self)
---   return Buster.new(self, true, player:attack_level() * 10)
--- end
--- ```
---@field charged_attack_func fun(self: Entity): Action|nil
--- Should return an [Action](https://docs.hubos.dev/client/lua-api/attack-api/action)
---
--- Many player mods use [Buster](https://docs.hubos.dev/client/lua-api/attack-api/action#buster) for their return value.
---
--- ```lua
--- player.normal_attack_func = function(self)
---   return Buster.new(self, false, player:attack_level())
--- end
--- ```
---@field normal_attack_func fun(self: Entity): Action|nil
--- Should return the amount of time in game frames, the `Shoot` button should be held for a fully charged attack.
---@field calculate_charge_time_func fun(self: Entity): number
--- Called when this entity has been countered.
---
--- Not to be confused with [entity.on_counter_func](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityon_counter_func--functionself)
---@field on_countered_func fun(self: Entity)
--- This function is predefined for all entities.
---
--- When overriding, you may want to check for whether the tile is [reserved](https://docs.hubos.dev/client/lua-api/field-api/tile#tileis_reservedexclude_list) or [walkable](https://docs.hubos.dev/client/lua-api/field-api/tile#tileis_walkable). If this overridden on a character, you may also want to check if the entity is [immobile](https://docs.hubos.dev/client/lua-api/entity-api/living#livingis_immobile).
---@field can_move_to_func fun(tile: Tile): boolean
--- Called when the battle has completed (win or loss).
---@field on_battle_end_func fun(self: Entity, won: boolean)
--- Called when battle starts for the first time, or when the entity is spawned if battle has already started.
---@field on_battle_start_func fun(self: Entity)
--- Called when health is 0 or `entity:delete()` is called. `entity:erase()` must be called to truly delete the entity.
---
--- This function is pre-set for all entities, and may be skipped if `entity:erase()` is called.
---
--- Use [entity:on_erase()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityon_erasefunctionentity) if you need a callback that runs in all situations.
---@field on_delete_func fun(self: Entity)
--- Called when an attack using this entity's [context](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#attackcontext) counters another entity.
---
--- Not to be confused with [living.on_countered_func](https://docs.hubos.dev/client/lua-api/entity-api/living#livingon_countered_func--functionself)
---@field on_counter_func fun(self: Entity)
--- Called when [Actions](https://docs.hubos.dev/client/lua-api/attack-api/action) complete or when [entity:set_idle()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_idle) is called. For [Players](https://docs.hubos.dev/client/lua-api/entity-api/player), it is additionally called when the movement animation ends.
---@field on_idle_func fun(self: Entity)
--- Called during battle, when not frozen from time freeze or blocked by statuses.
---@field on_update_func fun(self: Entity)
--- Called when the entity is spawned by [Field.spawn()](https://docs.hubos.dev/client/lua-api/field-api/field/#fieldspawnentity-tile)
---@field on_spawn_func fun(self: Entity)
Entity = {}

--- Data tracking the attacker and [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props) overrides.
--- Obtained by [entity:context()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entitycontext) and passed through HitProps.
--- Updates when a player or character starts an attack, or when HitProps are set on an entity.
--- By default, the context is used by the engine to pass flags related to countering, see [living:set_counterable()](https://docs.hubos.dev/client/lua-api/entity-api/living#livingset_counterableenabled).
---@class AttackContext
--- [Drag](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#drag)
---@field drag Drag
--- A table that maps frame durations for status hit flags.
---
--- See [Hit.duration_for()](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hitduration_forhit_flag-level)
---@field status_durations table<Hit, number>
--- See [HitProps.flags](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---@field flags Hit | number
--- The EntityId of the attacking entity.
---@field aggressor Entity
AttackContext = {}

---
---@class Sprite
Sprite = {}

---
---@class Animation
Animation = {}

--- While actions execute, their owners will stop auto reserving tiles.
---
--- [Players](https://docs.hubos.dev/client/lua-api/entity-api/player), [Characters](https://docs.hubos.dev/client/lua-api/entity-api/character), and [Obstacles](https://docs.hubos.dev/client/lua-api/entity-api/obstacle) automatically reserve tiles outside of executing actions.
---@class Action
--- Override's the owner's [can_move_to_func](https://docs.hubos.dev/client/lua-api/entity-api/entity/#entitycan_move_to_func--functiontile-boolean) while executing.
---
--- Ignored on async actions when the entity regains control.
---@field can_move_to_func fun(tile: Tile): boolean
--- Called when the action ends execution, including cancellation without execution.
---@field on_action_end_func fun(self: Action)
--- Called when the action's animation ends.
---@field on_animation_end_func fun(self: Action)
--- Called while the action is executing.
---@field on_update_func fun(self: Action)
--- Called when the action begins execution.
---@field on_execute_func fun(self: Action, owner: Entity)
Action = {}

--- See [living:add_defense_rule()](https://docs.hubos.dev/client/lua-api/entity-api/living#livingadd_defense_ruledefense_rule)
---@class DefenseRule
--- Called before applying damage and statuses to the entity.
---
--- Should return [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- The return value replaces the HitProps applied to the entity.
---@field filter_func fun(hit_props: HitProps): HitProps
--- If the defense order is `DefenseOrder.Always`, this function will be called on every hit.
---
--- If the defense order is `DefenseOrder.CollisionOnly`, this function will be called after intangibility is determined to not block the attack.
---
--- - `defense`: [Defense](https://docs.hubos.dev/client/lua-api/defense-api/defense-rule#defense)
--- - `attacker`: [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity)
--- - `defender`: [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity)
--- - `hit_props`: [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---@field defense_func fun(defense: Defense, attacker?: Entity, defender: Entity, hit_props: HitProps)
--- Called when a DefenseRule with the same priority replaced this rule.
---@field on_replace_func fun()
DefenseRule = {}

--- Created for each attack resolution and passed through DefenseRule callbacks.
---@class Defense
Defense = {}

--- See [living:set_intangible()](https://docs.hubos.dev/client/lua-api/entity-api/living#livingset_intangibleintangible-intangible_rule)
---@class IntangibleRule
--- Called when the duration runs out, or when the defense is pierced.
---@field on_deactivate_func fun()
--- A list of [Elements](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- The default value is `{}`
---@field element_weaknesses Element[]
--- Hit flags combined into a single value see [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- The default value is `Hit.PierceInvis`
---@field hit_weaknesses Hit | number
--- The maximum time the rule should last for in game frames.
---
--- The default value is 120.
---@field duration number
IntangibleRule = {}

--- AuxProps are structures for generating conditional behavior that composes well with other AuxProps, without requiring writers to be aware of all content to avoid ordering conflicts. AuxProps achieves this using a priority system that uses the effect and requirements to generate a clear order for behavior.
---
--- AuxProps can only be tied to a single entity and can not be updated once bound. To update an AuxProp it must be removed and added again.
---@class AuxProp
AuxProp = {}

--- See [Status Package Documentation](https://docs.hubos.dev/client/packages#statuses) for creating new statuses.
---@class Status
--- Called when the status wears off, used for clean up.
---@field on_delete_func fun(self: Status)
Status = {}

---
---@class ActionStep
--- Called every tick while the associated action is active if this step is not marked as complete, and there are no steps created before this step that haven't been marked as complete.
---@field on_update_func fun(self: ActionStep)
ActionStep = {}

---
---@class Attachment
Attachment = {}

--- Spawns characters at the start of battle.
---
--- See [encounter:create_spawner()](https://docs.hubos.dev/client/lua-api/field-api/encounter#encountercreate_spawnerpackage_id-rank) for creating a spawner.
---@class Spawner
Spawner = {}

--- Allows for modification of a spawned character. Usage is optional.
---@class Mutator
Mutator = {}

---
---@class Encounter
Encounter = {}

--- Tiles have a custom comparison function that allows two instances to be compared directly: `tile_a == tile_b`
---@class Tile
Tile = {}

---
---@class Field
Field = {}

---
---@class Augment
--- Called when the player is deleted or when this augment's level is boosted to `<= 0`.
---@field on_delete_func fun(self: Augment)
--- Overrides [player.movement_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playermovement_func--functionself-direction).
---
--- Used to handle movement input.
---@field movement_func fun(self: Augment, direction: Direction)
--- Overrides [player.movement_input_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playermovement_input_func--functionself-direction).
---
--- Used to generate movement input.
---@field movement_input_func fun(self: Augment): Direction?
--- Will not be called if there's no matching `calculate_card_charge_time_func`
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) or `nil` is expected as a return value.
---@field charged_card_func fun(self: Augment, card_properties: CardProperties): Action|nil
--- Will not be called if there's no matching `charged_card_func`
---
--- Return a number representing the minimum amount of time the card use button must be held for this augment's `charged_card_func` to be called to handle this card.
---@field calculate_card_charge_time_func fun(self: Augment, card_properties: CardProperties): number|nil
--- Overrides [player.special_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playerspecial_attack_func--functionself-actionnil)
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) is expected as a return value.
---
--- Return `nil` to fallback to the next implementation (augment, form, or player).
---@field special_attack_func fun(self: Augment): Action|nil
--- Overrides [player.charged_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercharged_attack_func--functionself-actionnil)
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) is expected as a return value.
---
--- Return `nil` to fallback to the next implementation (augment, form, or player).
---@field charged_attack_func fun(self: Augment): Action|nil
--- Overrides [player.normal_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playernormal_attack_func--functionself-actionnil)
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) is expected as a return value.
---
--- Return `nil` to fallback to the next implementation (augment, form, or player).
---@field normal_attack_func fun(self: Augment): Action|nil
--- Overrides [player.calculate_charge_time_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercalculate_charge_time_func--functionself-number)
---
--- A number representing the minimum Shoot button held time in game frames is expected as a return value.
---@field calculate_charge_time_func fun(self: Augment): number
Augment = {}

--- Created through [player:create_form()](https://docs.hubos.dev/client/lua-api/entity-api/player#playercreate_form)
---@class PlayerForm
--- Overrides [player.movement_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playermovement_func--functionself-direction) when this form is active.
--- Also overrides any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment)'s override.
---
--- Used to handle movement input.
---@field movement_func fun(self: PlayerForm)
--- Overrides [player.movement_input_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playermovement_input_func--functionself-direction) when this form is active.
--- Also overrides any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment)'s override.
---
--- Used to generate movement input.
---@field movement_input_func fun(self: PlayerForm): Direction?
--- Will not be called if there's no matching `calculate_card_charge_time_func`
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) or `nil` is expected as a return value.
---@field charged_card_func fun(self: PlayerForm, card_properties: CardProperties): Action|nil
--- Will not be called if there's no matching `charged_card_func`
---
--- Return a number representing the minimum amount of time the card use button must be held for this form's `charged_card_func` to be called to handle this card.
---@field calculate_card_charge_time_func fun(self: PlayerForm, card_properties: CardProperties): number|nil
--- Overrides [player.special_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playerspecial_attack_func--functionself-actionnil) when this form is active.
--- Also overrides any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment)'s override.
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) is expected as a return value.
---
--- Return `nil` to fallback to the player's implementation.
---@field special_attack_func fun(self: PlayerForm): Action|nil
--- Overrides [player.charged_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercharged_attack_func--functionself-actionnil) when this form is active.
--- Also overrides any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment)'s override.
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) is expected as a return value.
---
--- Return `nil` to fallback to the player's implementation.
---@field charged_attack_func fun(self: PlayerForm): Action|nil
--- Overrides [player.normal_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playernormal_attack_func--functionself-actionnil) when this form is active.
--- Also overrides any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment)'s override.
---
--- An [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) is expected as a return value.
---
--- Return `nil` to fallback to the player's implementation.
---@field normal_attack_func fun(self: PlayerForm): Action|nil
--- Overrides [player.calculate_charge_time_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercalculate_charge_time_func--functionself-number) when this form is active.
--- Also overrides any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment)'s override.
---
--- A number representing the minimum Shoot button held time in game frames is expected as a return value.
---@field calculate_charge_time_func fun(self: PlayerForm): number
--- Called after [player.on_update_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playernormal_attack_func--functionself-actionnil) when this form is active.
---@field on_update_func fun(self: PlayerForm)
--- Called when the form is deactivated, the player's appearance should be reverted here.
---@field on_deactivate_func fun(self: PlayerForm)
--- Called when the form is activated, the player's appearance should be modified here.
---@field on_activate_func fun(self: PlayerForm)
--- Called when the form is deselected or unstaged, the player's emotions should be reverted here.
---@field on_deselect_func fun(self: PlayerForm)
--- Called when the form is selected or staged, the player's emotions should be modified here.
---@field on_select_func fun(self: PlayerForm)
PlayerForm = {}

---
---@class CardSelectButton
--- Return true if the button's usage effect was successful. The result will affect the played sound.
---@field use_func fun(self: CardSelectButton): boolean
--- Called when any changes are made to [player:staged_items()](https://docs.hubos.dev/client/lua-api/entity-api/player#playerstaged_items)
---@field on_selection_change_func fun(self: CardSelectButton)
CardSelectButton = {}

--- See [entity:create_component()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entitycreate_componentlifetime)
---@class Component
--- Called when the lifetime is relevant.
---
--- See [entity:create_component()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entitycreate_componentlifetime)
---@field on_update_func fun(self: Component)
--- Called when the entity is spawned, or immediately if the entity has already spawned.
---@field on_init_func fun(self: Component)
Component = {}

--- SyncNodes are a sprite animation pair that sync settings, state, and progress with an entity's root animation.
---@class SyncNode
SyncNode = {}

--- Controls when Actions complete.
---@class ActionLockout
ActionLockout = {}

---@class CustomTileState
--- Called when an entity finishes movement on the tile or is added by [tile:add_entity()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileadd_entityentity).
---@field on_entity_stop_func fun(self: CustomTileState, entity: Entity, prev_tile: Tile)
--- Called when an entity moves to another tile from a movement or [tile:add_entity()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileadd_entityentity).
---
--- `tile` is the tile the entity left.
---@field on_entity_leave_func fun(self: CustomTileState, entity: Entity, prev_tile: Tile)
--- Called when an entity enters the tile during a movement, [tile:add_entity()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileadd_entityentity), [tile:set_state()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileset_statetile_state), or spawning.
---@field on_entity_enter_func fun(self: CustomTileState, entity: Entity)
--- Called for every tile matching the state while time isn't frozen.
---@field on_update_func fun(self: CustomTileState, tile: Tile)
--- Called when [tile:set_state()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileset_statetile_state) is called and passes [custom_tile_state.can_replace_func](https://docs.hubos.dev/client/lua-api/field-api/custom-tile-state#custom_tile_statecan_replace_func--functionself-tile-tile_state-boolean).
---@field on_replace_func fun(self: CustomTileState, tile: Tile)
--- Called when [tile:set_state()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileset_statetile_state) or [tile:can_set_state()](https://docs.hubos.dev/client/lua-api/field-api/tile#tilecan_set_statetile_state) is called. Used to accept or deny the change.
---@field can_replace_func fun(self: CustomTileState, tile: Tile, tile_state: TileState): boolean
CustomTileState = {}

--- A global sprite node, used to add sprites to the HUD.
---
--- Hiding this node will also hide engine Hud elements.
---
--- ```lua
--- local sprite = Hud:create_node()
--- ```
---@class Hud: Sprite
Hud = {}

--- Colors are tables with an `r`, `g`, `b`, and `a` key, with each value set to a 0-255 integer.
---
--- There's a global table named `Color` with helpers for making new color tables.
---@class Color
--- The alpha or transparency component of the color. Stored as a number in the range [0, 255].
---@field a number
--- The blue component of the color. Stored as a number in the range [0, 255].
---@field b number
--- The green component of the color. Stored as a number in the range [0, 255].
---@field g number
--- The red component of the color. Stored as a number in the range [0, 255].
---@field r number

Color = {}

---
---@class TextStyle
--- Number or nil. Additional vertical space given to new lines. Line height is calculated using the height of either the space character or `A`, added to the line spacing.
---
--- When unset the text style will use the engine default value of 1.
---@field line_spacing number|nil
--- Number or nil. Additional horizontal space between glyphs.
---
--- When unset the text style will use the engine default value of 1.
---@field letter_spacing number|nil
--- Number or nil. The minimum amount of space allocated for a single glyph for resolving glyph placement.
---
--- When unset the text style will use the engine default value of 0.
---@field min_glyph_width number|nil
--- Boolean or nil. When set to true, text created using this text style will use the width of either the space character or `A` to decide how much width will be allocated for a single glyph, instead of the width of the glyph itself.
---@field monospace boolean|nil

TextStyle = {}

---
---@class TextMetrics
--- The height of the text.
---@field height number
--- The width of the text.
---@field width number

TextMetrics = {}

--- See [entity:queue_movement](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityqueue_movementmovement)
---@class Movement
--- Called when the movement completes or is cancelled.
---@field on_end_func fun()
--- Called when the movement begins processing. If the movement is cancelled before executing it won't be called.
---@field on_begin_func fun()
--- The tile where the movement will complete.
---@field dest_tile Tile
--- The distance above the ground for the entity to jump.
---@field height number
--- The duration in game frames for the movement to drop after delta + delay.
---@field endlag number
--- The required duration in game frames for the movement animation to start.
---@field delay number
--- The duration in game frames for the movement animation to play.
---
--- If the delta is greater than zero the entity will slide. If [height](https://docs.hubos.dev/client/lua-api/field-api/movement#movementheight) isn't 0, the entity will jump instead.
---@field delta number
--- The elapsed time in game frames since the movement began.
---@field elapsed number

Movement = {}

---
---@class Drag
--- Number, the amount of tiles to drag the entity.
---@field distance number
--- Direction, the direction to move the entity.
---@field direction Direction

Drag = {}
---@type Drag
Drag.None = nil

--- See [spell:set_hit_props()](https://docs.hubos.dev/client/lua-api/entity-api/spell#spellset_hit_propshit_props)
---@class HitProps
--- The [AttackContext](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#attackcontext) obtained by [entity:context()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entitycontext)
---@field context AttackContext
--- [Drag](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#drag)
---@field drag Drag
--- An [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element). If element or secondary_element is super effective against an entity's element, this attack will deal 2x damage.
---@field secondary_element Element
--- An [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element). If element or secondary_element is super effective against an entity's element, this attack will deal 2x damage.
---@field element Element
--- A table that maps frame durations for status hit flags.
---
--- See [Hit.duration_for()](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hitduration_forhit_flag-level)
---@field status_durations table<Hit, number>
--- Any of the values below, or combined using bitwise or (`|`)
---
--- - `Hit.None`
--- - `Hit.RetainIntangible` prevents intangibility from being lost if the attack pierces.
--- - `Hit.NoCounter` prevents the attack from countering.
--- - `Hit.Drag` Allows the [drag property](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsdrag) to drag the entity.
--- - `Hit.Drain` disables the hit flash and countering, most defense rules should check for Drain to ignore hits.
--- - `Hit.Flinch` read by the hit entity to cancel attacks and play a flinch animation.
--- - `Hit.Flash` applies the default intangible rule to the hit entity and flickers the entity's sprite.
--- - `Hit.PierceInvis` read by defense rules to pierce defenses.
--- - `Hit.PierceGuard` read by defense rules to pierce defenses.
--- - `Hit.PierceGround` read by defense rules to pierce defenses.
--- - `Hit.Freeze` applies freeze status on hit.
--- - `Hit.Paralyze` applies paralyze status on hit.
--- - `Hit.Root` applies root status on hit.
--- - `Hit.Blind` applies blindness status on hit.
--- - `Hit.Confuse` applies confusion status on hit.
--- - [Hit.[flag_name]](https://docs.hubos.dev/client/packages#statuses)
---@field flags Hit | number
--- A number, used to calculate how much health to take away from entities hit by the attack.
---@field damage number

HitProps = {}

--- A card sitting in a [Player's](https://docs.hubos.dev/client/lua-api/entity-api/player) deck.
---@class DeckCard
--- Undefined type, used to resolve to an [Action](https://docs.hubos.dev/client/lua-api/attack-api/action).
---@field namespace Namespace?
--- String, passed to [CardProperties.from_package()](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardpropertiesfrom_packagepackage_id-code).
---@field code string
--- String, passed to [CardProperties.from_package()](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardpropertiesfrom_packagepackage_id-code).
---@field package_id string

DeckCard = {}

---
---@class CardProperties
--- A list of strings, used by other mods for conditional behavior.
---@field tags string[]
--- Boolean or nil, hides damage and displays question marks when the card's name is displayed to opponents.
---@field conceal boolean
--- Boolean or nil, used to decide if a time freezing [Action](https://docs.hubos.dev/client/lua-api/attack-api/action) can be countered.
---@field prevent_time_freeze_counter boolean
--- Boolean or nil, used by [Actions](https://docs.hubos.dev/client/lua-api/attack-api/action) to skip displaying the name of the attack and prevent time freeze countering.
---
--- Additionally the time freeze caused by this Action will not dim the screen.
---@field skip_time_freeze_intro boolean
--- Boolean or nil, enables time freeze for the [Action](https://docs.hubos.dev/client/lua-api/attack-api/action).
---@field time_freeze boolean
--- Boolean or nil, used by other mods for conditional behavior.
---@field can_charge boolean
--- Boolean or nil, used by other mods for conditional behavior.
---@field can_boost boolean
--- A table that maps frame durations for status hit flags.
---
--- See [Hit.duration_for()](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hitduration_forhit_flag-level)
---@field status_durations table<Hit, number>
--- [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags), influences generated [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---@field hit_flags Hit | number
--- Number, used by other mods for conditional behavior, defaults to 0.
---@field limit number
--- Any of the values below:
---
--- - `CardClass.Standard`
--- - `CardClass.Mega`
--- - `CardClass.Giga`
--- - `CardClass.Dark`
--- - `CardClass.Recipe`
---@field card_class CardClass
--- [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element), influences generated [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---@field secondary_element Element
--- [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element), influences generated [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---@field element Element
--- String, used by other mods for conditional behavior.
---@field code string
--- Number, used by other mods for conditional behavior.
---@field recover number
--- Boolean or nil, decides whether `function card_dynamic_damage(entity): number` should be called to resolve damage on frames where this card is unused and visible.
---
--- [CardProperties.resolve_damage()](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardpropertiesresolve_damagecard_properties-entity) can be used to calculate the latest damage value.
---@field dynamic_damage boolean
--- Number, represents the increase in damage from boosts. You should also modify `damage` when adjusting this value, as `damage` represents the final damage value.
--- Subtract this value from `damage` to get the original damage value.
---@field boosted_damage number
--- Number, influences generated [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props).
---
--- Displayed during time freeze.
---@field damage number
--- String, displayed during time freeze.
---@field short_name string
--- Undefined type, used for resolving to an [Action](https://docs.hubos.dev/client/lua-api/attack-api/action).
---@field namespace Namespace?
--- String, used for resolving to an [Action](https://docs.hubos.dev/client/lua-api/attack-api/action).
---@field package_id string

CardProperties = {}

--- An item displayed as a pending selection in Card Select.
---@class StagedItem
--- [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties) for `"card"`
---
--- Otherwise: `nil`
---@field card_properties CardProperties
--- A number for `"deck_card"`, `"deck_discard"`, and `"form"`
---
--- Otherwise `nil`
---@field index number
--- - `"deck_card"`
--- - `"deck_discard"`
--- - `"card"`
--- - `"form"`
--- - `"icon"`
---@field category string

StagedItem = {}

--- Instance of [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity).
Artifact = {}

--- Instance of [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity). All [Living](https://docs.hubos.dev/client/lua-api/entity-api/living) and [Character](https://docs.hubos.dev/client/lua-api/entity-api/character) functions are available as well.
---
--- Player functions are accessible to all entities, but will throw if the entity is not a Player.
Player = {}

--- Instance of [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity).
---
--- Spell functions are accessible to all entities, but will throw if the entity is not a Spell or [Obstacle](https://docs.hubos.dev/client/lua-api/entity-api/obstacle).
Spell = {}

--- Instance of [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity). All [Living](https://docs.hubos.dev/client/lua-api/entity-api/living) functions are available as well.
---
--- Character functions are accessible to all entities, but will throw if the entity is not a Character or [Player](https://docs.hubos.dev/client/lua-api/entity-api/player).
Character = {}

--- Instance of [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity).
---
--- Living functions are accessible to all entities, but will throw if the entity is not a [Player](https://docs.hubos.dev/client/lua-api/entity-api/player), [Character](https://docs.hubos.dev/client/lua-api/entity-api/character), or [Obstacle](https://docs.hubos.dev/client/lua-api/entity-api/obstacle).
Living = {}

--- Instance of [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity). All [Spell](https://docs.hubos.dev/client/lua-api/entity-api/spell) and [Living](https://docs.hubos.dev/client/lua-api/entity-api/living) functions are available as well.
Obstacle = {}

--- Adopts the parent spell's [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props) and [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam). Attacks every frame until deleted.
---
--- The SharedHitbox's `on_collision_func` and `on_attack_func` calls the parent spell's `on_collision_func` and `on_attack_func`.
SharedHitbox = {}

--- Attacks on first update then deletes self.
Hitbox = {}

Explosion = {}

Poof = {}

Alert = {}

TrapAlert = {}

---
Resources = {}

---
StandardEnemyAux = {}

---
TurnGauge = {}

---
Buster = {}

--- Returns the id for the entity.
---@return EntityId
function Entity:id() end

--- Returns the displayed name for the entity.
---@return string
function Entity:name() end

--- Sets the displayed name for the entity.
---
--- Automatically set for [Players](https://docs.hubos.dev/client/lua-api/entity-api/player).
---@param name string
function Entity:set_name(name) end

--- Returns the [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element) for the entity.
---@return Element
function Entity:element() end

--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- Sets the Element for the entity, affects super effectiveness of incoming attacks.
---
--- Automatically set for [Players](https://docs.hubos.dev/client/lua-api/entity-api/player).
---@param element Element
function Entity:set_element(element) end

--- Returns the facing [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction) of the entity.
---
--- Many mods use this to decide which direction to move in.
---@return Direction
function Entity:facing() end

--- Returns [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction)
---
--- Same as `Direction.reverse(entity:facing())`
---@return Direction
function Entity:facing_away() end

--- Returns the facing [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction) of the entity.
---
--- Used by the engine to resolve how to display the visual based on perspective.
--- This should be set to either `Direction.Left` or `Direction.Right` generally.
---
--- Many mods use this to decide which direction to move in.
---@param direction Direction
---@return Direction
function Entity:set_facing(direction) end

--- Returns the [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam) of the entity
---@return Team
function Entity:team() end

--- - `team`
---   - `Team.Other`
---   - `Team.Red`
---   - `Team.Blue`
---
--- Modifies which team the entity is on. If the entity is a [Player](https://docs.hubos.dev/client/lua-api/entity-api/player) the perspective may flip.
---@param team Team
function Entity:set_team(team) end

--- Returns a boolean.
---
--- Same as `entity:team() == team and team ~= Team.Other`
---@param team Team
---@return boolean
function Entity:is_team(team) end

--- Returns an Entity, Team, or `nil`
---@return Entity|Team|nil
function Entity:owner() end

--- Marks a team or entity as the owner of this entity. If `team_or_entity` is unset the entity will be reverted to having no owner.
---
--- If a team or entity has too many entities claimed, the oldest claimed entity will be deleted.
---
--- By default, entities can own one other entity, teams can own two entities.
---@param team_or_entity? Team|Entity
function Entity:set_owner(team_or_entity) end

--- - `direction`: [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction)
--- - `distance`: integer
---
--- Returns a tile `distance` many tiles in `direction`'s direction, or `nil`.
--- Returns the current tile if any parameters are unset.
---@param direction? Direction
---@param distance? number
---@return Tile|nil
function Entity:get_tile(direction, distance) end

--- Returns the tile at the same position as the entity.
---@return Tile
function Entity:current_tile() end

--- Deprecated. Use [Field](https://docs.hubos.dev/client/lua-api/field-api/field) directly.
function Entity:field() end

--- Returns true if the entity has spawned.
---
--- Usually set to true the frame after [Field.spawn()](https://docs.hubos.dev/client/lua-api/field-api/field#fieldspawnentity-tile) is called with this entity.
---@return boolean
function Entity:spawned() end

--- Returns true if the entity:
---
--- - Is [Living](https://docs.hubos.dev/client/lua-api/entity-api/living)
--- - [Hitbox is enabled](https://docs.hubos.dev/client/lua-api/entity-api/living#livinghitbox_enabled)
--- - Has health > 0
--- - On the field
--- - Not deleted
---
--- Different from [living:hitbox_enabled()](https://docs.hubos.dev/client/lua-api/entity-api/living#livinghitbox_enabled)
---@return boolean
function Entity:hittable() end

--- Returns true if other entities can stand on this tile.
---@return boolean
function Entity:sharing_tile() end

--- Allows other entities to stand on tiles reserved by this entity.
---@param enable? boolean
function Entity:enable_sharing_tile(enable) end

--- Returns true automatic tile reservation is enabled.
---@return boolean
function Entity:auto_reserves() end

--- Controls whether tiles are automatically reserved when this entity changes tiles.
---@param enable? boolean
function Entity:set_auto_reserve(enable) end

--- Returns true if negative tile effects should be ignored for this entity.
---
--- Affects only movement and idle effects, such as Cracked tiles converting to Broken or damage from Poison tiles.
--- Does not affect tile interactions with attacks, such as freezing on Ice tiles when hit with an Aqua attack.
---@return boolean
function Entity:ignoring_negative_tile_effects() end

--- The entity will ignore negative tile effects when active.
---
--- Automatically set for [Spells](https://docs.hubos.dev/client/lua-api/entity-api/spell) and [Artifacts](https://docs.hubos.dev/client/lua-api/entity-api/artifact).
---@param enabled? boolean
function Entity:ignore_negative_tile_effects(enabled) end

--- Returns true if the entity should be able to walk on Broken and PermaHole tiles.
---@return boolean
function Entity:ignoring_hole_tiles() end

--- Allows the entity to walk on Broken and PermaHole tiles.
---
--- Automatically set for [Spells](https://docs.hubos.dev/client/lua-api/entity-api/spell) and [Artifacts](https://docs.hubos.dev/client/lua-api/entity-api/artifact).
---@param enabled? boolean
function Entity:ignore_hole_tiles(enabled) end

--- Returns `{ x: number, y: number }`.
---
--- This table represents the temporary offset applied to the entity by movement.
---@return { x: number, y: number }
function Entity:movement_offset() end

--- Overwrites the frame temporary movement offset.
---@param x number
---@param y number
function Entity:set_movement_offset(x, y) end

--- Returns `{ x: number, y: number }`
---
--- Same as `entity:sprite():offset()`
---@return { x: number, y: number }
function Entity:offset() end

--- Same as `entity:sprite():set_offset(x, y)`
---@param x number
---@param y number
function Entity:set_offset(x, y) end

--- Returns the elevation of the entity.
---@return number
function Entity:elevation() end

--- Vertical offset for the entity. When the elevation changes the sprite moves, but health will stay in the same position.
---
--- Positive elevation moves the entity upwards.
---@param elevation number
function Entity:set_elevation(elevation) end

--- Returns the height of the entity, used to determine the range where hit artifacts should appear.
---@return number
function Entity:height() end

--- Sets the height of the entity.
---@param height number
function Entity:set_height(height) end

--- Returns a [Sprite](https://docs.hubos.dev/client/lua-api/resource-api/sprite), can be used to modify the entity's appearance.
---@return Sprite
function Entity:sprite() end

--- Returns a string.
---
--- Same as `entity:sprite():texture()`
---@return string
function Entity:texture() end

--- Same as `entity:sprite():set_texture(path)`
---@param path string
function Entity:set_texture(path) end

--- Returns a string or `nil`
---
--- Same as `entity:sprite():palette()`
---@return string|nil
function Entity:palette() end

--- Same as `entity:sprite():set_palette(path)`
---@param path? string
function Entity:set_palette(path) end

--- Same as `entity:sprite():hide()`
function Entity:hide() end

--- Same as `entity:sprite():reveal()`
function Entity:reveal() end

--- Returns a number.
---
--- Same as `entity:sprite():layer()`
---@return number
function Entity:layer() end

--- Same as `entity:sprite():set_layer(layer)`
---@param layer number
function Entity:set_layer(layer) end

--- Returns [Color](https://docs.hubos.dev/client/lua-api/resource-api/sprite#color)
---
--- Same as `entity:sprite():color()`
---@return Color
function Entity:color() end

--- Same as `entity:sprite():set_color(color)`
---@param color Color
function Entity:set_color(color) end

--- Returns a boolean.
---
--- Same as `entity:sprite():never_flip()`
---@return boolean
function Entity:never_flip() end

--- Same as `entity:sprite():set_never_flip(never_flip)`
---@param never_flip? boolean
function Entity:set_never_flip(never_flip) end

--- Returns a [Sprite](https://docs.hubos.dev/client/lua-api/resource-api/sprite)
---
--- Same as `entity:sprite():create_node()`
---@return Sprite
function Entity:create_node() end

--- Same as `entity:sprite():remove_node(sprite)`
---@param sprite Sprite
function Entity:remove_node(sprite) end

--- Returns a [SyncNode](https://docs.hubos.dev/client/lua-api/resource-api/sprite#syncnode).
---@return SyncNode
function Entity:create_sync_node() end

--- Removes the sync node from the entity.
---@param sync_node SyncNode
function Entity:remove_sync_node(sync_node) end

--- Use values returned from [Resources.load_texture()](https://docs.hubos.dev/client/lua-api/resource-api/resources#resourcesload_texturepath) for better performance.
---
--- There are built-in shadow textures that can be used as well:
---
--- - `Shadow.None`
--- - `Shadow.Small`
--- - `Shadow.Big`
---@param texture_path string
---@param animation_path? string
function Entity:set_shadow(texture_path, animation_path) end

--- Sets whether the shadow is visible or not.
---@param visible? boolean
function Entity:show_shadow(visible) end

--- Returns an [Animation](https://docs.hubos.dev/client/lua-api/resource-api/animation), can be used to modify the entity's animation data.
---@return Animation
function Entity:animation() end

--- Same as `entity:animation():load(path)`
---@param path string
function Entity:load_animation(path) end

--- - `lifetime` affects when the component's update callback is called.
---   - `Lifetime.Local` when the entity update callback is called (affected by time freeze and status effects)
---   - `Lifetime.ActiveBattle` after every entity has updated and battle is active as long as time is not frozen.
---   - `Lifetime.Battle` after every entity has updated and battle is active.
---   - `Lifetime.Scene` near the end of every tick.
---   - `Lifetime.CardSelectOpen` the frame where card select begins to open.
---   - `Lifetime.CardSelectClose` the frame where card select begins to close.
---   - `Lifetime.CardSelectComplete` the frame where all players have confirmed card select.
---   - `Lifetime.Nil` never.
---
---   Returns a [Component](https://docs.hubos.dev/client/lua-api/entity-api/entity#component)
---@param lifetime Lifetime
---@return Component
function Entity:create_component(lifetime) end

--- Returns a value that can be used to decide if an attack can counter an opponent, and to resolve the owner of an attack.
---
--- Countering an attack can be achieved by hitting an enemy with [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props) containing context obtained during [card_init](https://docs.hubos.dev/client/packages#cards) or within [action.on_execute_func](https://docs.hubos.dev/client/lua-api/attack-api/action#actionon_execute_func--functionself-owner)
---
--- Make sure to obtain context in card_init and not within a callback for countering.
---@return AttackContext
function Entity:context() end

--- Starts a new context using the specified [action type](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#aux_proprequire_actionaction_types).
--- Not necessary, but useful for actions queued in a script context.
---
--- ```lua
--- player.on_update_func = function()
---   if player:input_has(Input.Pressed.Left) and not player:is_inactionable() and not player:has_actions() then
---     player:start_context(ActionType.Normal) -- may activate AuxProps which can influence HitProps using context
---
---     local action = Action.new(player, "CHARACTER_SHOOT")
---     player:queue_action(action)
---   end
--- end
--- ```
---@param action_type ActionType
function Entity:start_context(action_type) end

--- Returns true if the entity has an executing action or pending actions.
---@return boolean
function Entity:has_actions() end

--- Returns true if the entity can queue a time freeze action on this frame to counter an opponent's time freeze action.
---@return boolean
function Entity:can_time_freeze_counter() end

--- Returns true if the entity is frozen from time freezing.
---@return boolean
function Entity:frozen() end

--- Freezes the entity for time freeze, will unfreeze when time freeze ends.
---
--- It is recommended to use `entity:set_frozen(TurnGauge.frozen())` when spawning entities during time freeze that should only be active when time isn't frozen.
---
--- This allows the summon to work properly even when spawned outside of time freeze.
---@param bool? boolean
function Entity:set_frozen(bool) end

--- - `action`: [Action](https://docs.hubos.dev/client/lua-api/attack-api/action)
---
--- Note: During time freeze, Actions that freeze time skip to the front of the line.
---@param action Action
function Entity:queue_action(action) end

--- Ends and deletes synchronous and pending actions.
function Entity:cancel_actions() end

--- Returns true if the entity can move to the target tile.
---@param tile? Tile
---@return boolean
function Entity:can_move_to(tile) end

--- - `tile`: [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile), if unset nothing happens.
--- - callback is called when the movement begins processing
---@param tile? Tile
---@param callback? fun()
function Entity:teleport(tile, callback) end

--- - `tile`: [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile), if unset nothing happens.
--- - `duration` is in game frames.
--- - callback is called when the movement begins processing
---@param tile? Tile
---@param duration? number
---@param callback? fun()
function Entity:slide(tile, duration, callback) end

--- - `tile`: [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile), if unset nothing happens.
--- - `height` how many pixels to offset the entity at the peak of the jump
--- - `duration` is in game frames.
--- - callback is called when the movement begins processing
---@param tile? Tile
---@param height number
---@param duration number
---@param callback? fun()
function Entity:jump(tile, height, duration, callback) end

--- - `movement`: [Movement](https://docs.hubos.dev/client/lua-api/field-api/movement)
---@param movement Movement
function Entity:queue_movement(movement) end

--- - `tile`: [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile)
---
--- Queues a movement with the same animation and timing as one caused by player input.
---@param tile Tile
function Entity:queue_default_player_movement(tile) end

--- Cancels non-drag movement.
function Entity:cancel_movement() end

--- Returns true if the entity is moving.
---@return boolean
function Entity:is_moving() end

--- Returns true if the entity is sliding.
---@return boolean
function Entity:is_sliding() end

--- Returns true if the entity is jumping.
---@return boolean
function Entity:is_jumping() end

--- Returns true if the entity is teleporting.
---@return boolean
function Entity:is_teleporting() end

--- Returns true if the entity's current movement was caused by drag.
---
--- This does return true during the drag lockout, use [living:is_immobile()](https://docs.hubos.dev/client/lua-api/entity-api/living#livingis_immobile) to detect the immobility caused from lockout.
---@return boolean
function Entity:is_dragged() end

--- Calls [entity:on_idle_func()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityon_idle_func--functionself)
function Entity:set_idle() end

--- Returns true if the entity has been marked for deletion, or has been erased.
---@return boolean
function Entity:deleted() end

--- Returns true if the entity will be completely deleted at the end of the frame, or already has been erased.
---@return boolean
function Entity:will_erase_eof() end

--- Skips delete animations, marks the entity to be erased at the end of the frame.
---
--- Clears `entity.on_delete_func` and calls `entity:delete()`
function Entity:erase() end

--- Calls delete callbacks, the entity won't be truly deleted unleses `entity:erase()` is called.
---
--- Ignored if `entity:delete()` was already called.
function Entity:delete() end

--- Calls `entity:delete()`, then plays an animation.
---
--- Calls `entity:erase()` at the end of the animation.
function Entity:default_player_delete() end

--- Calls `entity:delete()`, then plays an animation.
---
--- Calls `entity:erase()` at the end of the animation.
function Entity:default_character_delete() end

--- Adds a callback listener for entity deletion.
---
--- This callback can be skipped if `entity:erase()` was called before `entity:delete()`
---
--- Use [entity:on_erase()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityon_erasefunctionentity) if you need a callback that runs in all situations.
---@param callback fun(entity: Entity)
function Entity:on_delete(callback) end

--- Removes a callback set by [entity:on_delete()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityon_deletefunctionentity)
---@param callback fun(entity: Entity)
function Entity:remove_on_delete(callback) end

--- Adds a callback listener for entity erasure.
---@param callback fun(entity: Entity)
function Entity:on_erase(callback) end

--- Removes a callback set by [entity:on_erase()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityon_erasefunctionentity)
---@param callback fun(entity: Entity)
function Entity:remove_on_erase(callback) end

--- Returns an [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity)
---@return Entity
function Component:owner() end

--- Removes the component from the owner.
function Component:eject() end

--- Returns the entity passed in if the entity is considered living, otherwise returns `nil`.
---@param entity Entity
---@return Entity
function Living.from(entity) end

--- Returns the entity's max health.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return number
function Entity:max_health() end

--- Returns the entity's current health.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return number
function Entity:health() end

--- Sets the entity's max health.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param health number
function Entity:set_health(health) end

--- - `hit_props`: [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- Queues a hit for processing, in most cases [spell:attack_tile()](https://docs.hubos.dev/client/lua-api/entity-api/spell#spellattack_tiletile) should be used instead.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param hit_props HitProps
function Entity:hit(hit_props) end

--- Returns true if the entity can interact with attacks.
---
--- Different from [entity:hittable()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityhittable)
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return boolean
function Entity:hitbox_enabled() end

--- Passing false will allow attacks to pass through as if the entity didn't exist.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param enabled? boolean
function Entity:enable_hitbox(enabled) end

--- Returns true if the entity can currently be countered.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return boolean
function Entity:counterable() end

--- Allows the entity to be countered when hit by an attack with a [context](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#attackcontext) created in [card_init](https://docs.hubos.dev/client/packages/#cards)
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param enabled? boolean
function Entity:set_counterable(enabled) end

--- Returns true if an [IntangibleRule](https://docs.hubos.dev/client/lua-api/defense-api/intangible-rule) is active.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return boolean
function Entity:intangible() end

--- - `intangible`: bool, if false the active rule is removed.
--- - `intangible_rule`: [IntangibleRule](https://docs.hubos.dev/client/lua-api/defense-api/intangible-rule)
---   - Ignored if `intangible` is false.
---   - A default will be used if `intangible_rule` is unset.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param intangible boolean
---@param intangible_rule? IntangibleRule
function Entity:set_intangible(intangible, intangible_rule) end

--- - `defense_rule`: [DefenseRule](https://docs.hubos.dev/client/lua-api/defense-api/defense-rule)
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param defense_rule DefenseRule
function Entity:add_defense_rule(defense_rule) end

--- - `defense_rule`: [DefenseRule](https://docs.hubos.dev/client/lua-api/defense-api/defense-rule)
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param defense_rule DefenseRule
function Entity:remove_defense_rule(defense_rule) end

--- Removes the first defense with the matching priority and calls its [replace callback](https://docs.hubos.dev/client/lua-api/defense-api/defense-rule#defense_ruleon_replace_func--function).
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param defense_priority DefensePriority
function Entity:remove_defense(defense_priority) end

--- Returns true if the entity has a defense rule with a matching priority.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param defense_priority DefensePriority
---@return boolean
function Entity:has_defense(defense_priority) end

--- - `aux_prop`: [AuxProp](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop)
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param aux_prop AuxProp
function Entity:add_aux_prop(aux_prop) end

--- - `aux_prop`: [AuxProp](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop)
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param aux_prop AuxProp
function Entity:remove_aux_prop(aux_prop) end

--- - `hit_flag` a single hit flag, see [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
--- - `duration` number, how many battle frames the effect should last
---
--- Queues a status update. If the status is already applied, the remaining time will be updated to use the longer duration.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param hit_flag Hit
---@param duration number
function Entity:apply_status(hit_flag, duration) end

--- - `hit_flags` one or more hit flags stored as a single number, see [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param hit_flags Hit | number
function Entity:remove_status(hit_flags) end

--- Returns a number, representing the hit flags the entity is currently immune to.
---
--- This won't cover checks inside of statuses, such as a the `CHARACTER_HIT` animation required by `Hit.Flinch`
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return number
function Entity:status_immunities() end

--- - `hit_flag` a single hit flag, see [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- Returns a number representing the amount of battle frames until the status wears off.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param hit_flag Hit
---@return number
function Entity:remaining_status_time(hit_flag) end

--- - `hit_flag` a single hit flag, see [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
--- - `duration` number, how many battle frames the effect should last.
---
--- Updates remaining time for a status already applied, or queues a new status update if isn't.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param hit_flag Hit
---@param duration number
function Entity:set_remaining_status_time(hit_flag, duration) end

--- - `hit_flag` a single hit flag, see [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- The callback will be called when the `hit_flag` is applied to the entity.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@param hit_flag Hit
---@param callback fun()
function Entity:register_status_callback(hit_flag, callback) end

--- Returns true if status effects that block actions are applied.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return boolean
function Entity:is_inactionable() end

--- Returns true if status effects that immobilize are applied.
---
--- Throws if the Entity doesn't pass [Living.from()](https://docs.hubos.dev/client/lua-api/entity-api/living)
---@return boolean
function Entity:is_immobile() end

--- Returns the entity passed in if the entity is a player, otherwise returns `nil`.
---@param entity Entity
---@return Entity
function Player.from(entity) end

--- Used for creating small private differences between players, such as playing a sound effect, hiding a sprite, or changing a sprites color.
---
--- Returns true if the player is the local player.
---
--- Warning: Can cause unintentional desyncs. Limit behavior driven by this.
---
--- Creating or deleting sprites, entities, and animations can cause non obvious unintentional desyncs. Of course those aren't the only ways to cause unintentional desyncs.
---
--- Even modifying a sprite's color can cause a desync if another script attempts to read the sprite's color to drive behavior.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return boolean
function Entity:is_local() end

--- Returns a number, represents the index of the player in the list of players sent from the server.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:player_index() end

--- Returns a list of valid values for `player:set_emotion()`.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return string[]
function Entity:emotions() end

--- Returns the name of the current emotion animation state.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return string
function Entity:emotion() end

--- Sets the current animation state for the player's emotion.
---
--- If the state doesn't exist, this does nothing.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param state string
function Entity:set_emotion(state) end

--- Returns a string.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return string
function Entity:emotions_texture() end

--- Returns a string.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return string
function Entity:emotions_animation_path() end

--- Returns a [Sprite](https://docs.hubos.dev/client/lua-api/resource-api/sprite)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return Sprite
function Entity:emotion_node() end

--- - `path`: file path relative to script file, use values returned from `Resources.load_texture()` for better performance.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param path string
function Entity:set_emotions_texture(path) end

--- - `path`: file path relative to script file, use values returned from `Resources.load_texture()` for better performance.
---
--- If the animation doesn't have a state matching the current emotion, it will reset the player's emotion to "DEFAULT"
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param path string
function Entity:load_emotions_animation(path) end

--- - `input_query`
---   - `Input.Held.*`
---   - `Input.Pressed.*`
---   - `Input.Pulsed.*`
---     - `Left`
---     - `Right`
---     - `Down`
---     - `Use`
---     - `Special`
---     - `Shoot`
---     - `FaceLeft`
---     - `FaceRight`
---     - `LeftShoulder`
---     - `RightShoulder`
---     - `Confirm`
---     - `Cancel`
---     - `EndTurn`
---     - `Ready`
---
--- Returns true if `input_query` matches the player's current input state.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param input_query Input
---@return boolean
function Entity:input_has(input_query) end

--- Returns a number, represents the configured input delay for this player.
---
--- Useful for timing based selection, most mods will not need to use this value.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:input_delay() end

--- Stores a value that can be read in future battles.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param key string
---@param number_or_string number|string
function Entity:remember(key, number_or_string) end

--- Returns a number, string, or nil, store values with to [player:remember()](https://docs.hubos.dev/client/lua-api/entity-api/player#playerrememberkey-number_or_string)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param key string
---@return number|string|nil
function Entity:recall(key) end

--- Clears a value stored through [player:remember()](https://docs.hubos.dev/client/lua-api/entity-api/player#playerrememberkey-number_or_string)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param key string
function Entity:forget(key) end

--- - `path`: file path relative to script file, use values returned from `Resources.load_audio()` for better performance.
--- - `audio_behavior`: [AudioBehavior](https://docs.hubos.dev/client/lua-api/resource-api/resources#audiobehavior)
---
--- Plays an audio file to only this player.
---
--- See [Resources.play_audio()](https://docs.hubos.dev/client/lua-api/resource-api/resources#resourcesplay_audiopath-audio_behavior) for playing audio for all players.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param path string
---@param audio_behavior? AudioBehavior
function Entity:play_audio(path, audio_behavior) end

--- - `color`: [Color](https://docs.hubos.dev/client/lua-api/resource-api/sprite#color)
---
--- Sets the color of the fully charged sprite.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param color Color
function Entity:set_fully_charged_color(color) end

--- Returns `{ x: number, y: number }`.
---
--- This table represents the offset for the attack charge animation.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return { x: number, y: number }
function Entity:charge_position() end

--- Sets the offset for the attack charge animation.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param x number
---@param y number
function Entity:set_charge_position(x, y) end

--- Returns a number in the range `[0, 1]`
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:charge_progress() end

--- Returns a bool.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return boolean
function Entity:slide_when_moving() end

--- Returns true if holding movement buttons causes the player to move.
---
--- With no calls to `*:set_movement_on_input()`, the default is true.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return boolean
function Entity:movement_on_input() end

--- Configures whether holding movement buttons causes the player to move, when no other augments or forms are overriding this behavior.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param bool? boolean
function Entity:set_movement_on_input(bool) end

--- When `true`, the player will slide to tiles and continue using the `CHARACTER_IDLE` state.
---
--- When `false`, the player will teleport to tiles and animate with the `CHARACTER_MOVE` state.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param bool? boolean
function Entity:set_slide_when_moving(bool) end

--- Queues an action from a [Form](https://docs.hubos.dev/client/lua-api/entity-api/player#playerform), [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment), or the base player mod.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
function Entity:queue_normal_attack() end

--- Queues an action from a [Form](https://docs.hubos.dev/client/lua-api/entity-api/player#playerform), [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment), or the base player mod.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
function Entity:queue_charged_attack() end

--- Queues an action from a [Form](https://docs.hubos.dev/client/lua-api/entity-api/player#playerform), [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment), or the base player mod.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
function Entity:queue_special_attack() end

--- Returns true if pressing the Special button activates the special attack.
---
--- With no calls to `*:set_special_on_input()`, the default is true.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return boolean
function Entity:special_on_input() end

--- Configures whether the Special button should activate the special attack, when no other augments or forms are overriding this behavior.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param bool? boolean
function Entity:set_special_on_input(bool) end

--- Returns a bool.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return boolean
function Entity:has_regular_card() end

--- Returns a list of [DeckCard](https://docs.hubos.dev/client/lua-api/attack-api/cards#deckcard).
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return DeckCard[]
function Entity:deck_cards() end

--- - `index`: number, 1 is the first card in the deck.
---
--- Returns [DeckCard](https://docs.hubos.dev/client/lua-api/attack-api/cards#deckcard) or nil.
---
--- Creating CardProperties through this function rather than [player:deck_card_properties()](https://docs.hubos.dev/client/lua-api/entity-api/player#playerdeck_card_propertiesindex) may cause desyncs when the mod is installed on multiple clients in battle.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param index number
---@return DeckCard
function Entity:deck_card(index) end

--- - `index`: number, 1 is the first card in the deck.
---
--- Returns [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties) or nil.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param index number
---@return CardProperties
function Entity:deck_card_properties(index) end

--- - `index`: number, 1 is the first card in the deck.
--- - `deck_card`: [DeckCard](https://docs.hubos.dev/client/lua-api/attack-api/cards#deckcard)
---
--- If there's no card at this index, nothing happens.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param index number
---@param deck_card DeckCard
function Entity:set_deck_card(index, deck_card) end

--- - `index`: number, 1 is the first card in the deck.
---
--- Removes a card from the player's deck.
---
--- Any [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem) referencing this card will be dropped.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param index number
function Entity:remove_deck_card(index) end

--- - `index`: number, 1 is the first card in the deck.
--- - `deck_card`: [DeckCard](https://docs.hubos.dev/client/lua-api/attack-api/cards#deckcard)
---
--- Inserts a card into the player's deck.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param index number
---@param deck_card DeckCard
function Entity:insert_deck_card(index, deck_card) end

--- Returns true if Card Select can close.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return boolean
function Entity:staged_items_confirmed() end

--- Allows Card Select to close.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
function Entity:confirm_staged_items() end

--- - `card_properties`: [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties)
--- - The callback will be called when the player removes the StagedItem.
---
--- Appends a new [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem) to display in Card Select.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param card_properties CardProperties
---@param callback? fun()
function Entity:stage_card(card_properties, callback) end

--- - `deck_index`: number, 1 is the first card in the deck.
--- - The callback will be called when the player removes the StagedItem.
---
--- Appends a new [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem) to display in Card Select.
---
--- Any StagedItems already referencing `deck_index` will be removed.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param deck_index number
---@param callback? fun()
function Entity:stage_deck_card(deck_index, callback) end

--- - `deck_index`: number, 1 is the first card in the deck.
--- - The callback will be called when the player removes the StagedItem.
---
--- Appends a new [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem) to display in Card Select.
---
--- Any StagedItems already referencing `deck_index` will be removed.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param deck_index number
---@param callback? fun()
function Entity:stage_deck_discard(deck_index, callback) end

--- - `form`: [PlayerForm](https://docs.hubos.dev/client/lua-api/entity-api/player#playerform)
--- - `texture_path`: The texture to use for the icon.
--- - The callback will be called when the player removes the StagedItem.
---
--- Prepends a new [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem) that will be displayed in card select if a texture is set. If a form is already staged this StagedItem will replace the existing item.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param form PlayerForm
---@param texture_path? string
---@param callback? fun()
function Entity:stage_form(form, texture_path, callback) end

--- - `texture_path`: The texture to use for the icon.
--- - The callback will be called when the player removes the StagedItem.
---
--- Appends a new [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem) to display in Card Select.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param texture_path string
---@param callback? fun()
function Entity:stage_icon(texture_path, callback) end

--- Removes the latest [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem), calling the undo callback.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
function Entity:pop_staged_item() end

--- Returns a list of [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return StagedItem[]
function Entity:staged_items() end

--- - `index`: number, starts with 1.
---
--- Returns a [StagedItem](https://docs.hubos.dev/client/lua-api/entity-api/player#stageditem) or `nil`.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param index number
---@return StagedItem|nil
function Entity:staged_item(index) end

--- - `index`: number, starts with 1.
---
--- Returns a string. Represents the path to the StagedItem's icon texture.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param index number
---@return string
function Entity:staged_item_texture(index) end

--- Returns `{ package_id?: string, code?: string }`. Cards must match any of the set fields.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return { package_id?: string, code?: string }
function Entity:card_select_restriction() end

--- Prevents selection in Card Select and hides the cursor.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param bool boolean
function Entity:set_card_selection_blocked(bool) end

--- Dedicates a button slot in Card Select to the specified card. Internally defined as a [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton).
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param card_properties CardProperties
---@param card_button_slot? number
---@return CardSelectButton
function Entity:set_fixed_card(card_properties, card_button_slot) end

--- Creates a button embedded in the end of the card list in Card Select.
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param slot_count number
---@param card_button_slot? number
---@return CardSelectButton
function Entity:create_card_button(slot_count, card_button_slot) end

--- Creates a button under the "Confirm" button in Card Select.
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return CardSelectButton
function Entity:create_special_button() end

--- Returns a new [PlayerForm](https://docs.hubos.dev/client/lua-api/entity-api/player#playerform).
---
--- Can be used up to five times before throwing.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return PlayerForm
function Entity:create_form() end

--- Returns a new [PlayerForm](https://docs.hubos.dev/client/lua-api/entity-api/player#playerform).
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return PlayerForm
function Entity:create_hidden_form() end

--- Returns an [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment) or `nil` if the player doesn't have an augment with that `package_id`.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param package_id string
---@return Augment|nil
function Entity:get_augment(package_id) end

--- Returns a list of [Augments](https://docs.hubos.dev/client/lua-api/entity-api/player#augment)
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return Augment[]
function Entity:augments() end

--- If the level before boosting is 0, the [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment) is initialized.
---
--- If the level after boosting is 0, the Augment's delete callback is called and the Augment is removed.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param package_id string
---@param level_increment number
function Entity:boost_augment(package_id, level_increment) end

--- - `health`: integer
---
--- Adds the `health` value to the max health.
---
--- If it is the player's health is greater than the new max health it will be reduced to the new max health.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param health number
function Entity:boost_max_health(health) end

--- Returns the max amount of cards the player can view from the deck accounting for boosts.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:hand_size() end

--- - `size`: integer
---
--- Adds the `size` value to the `hand_size` or the amount of cards the player can view from the deck.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param size number
function Entity:boost_hand_size(size) end

--- Returns the player's total attack level, a combination of `boost_attack_level` and [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment) boosts.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:attack_level() end

--- - `increment`: integer
---
--- Adds the `increment` value to the attack level. The attack level can only be boosted by five through this method.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param increment number
function Entity:boost_attack_level(increment) end

--- Returns the player's total rapid level, a combination `boost_rapid_level` and [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment) boosts.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:rapid_level() end

--- - `increment`: integer
---
--- Adds the `increment` value to the rapid level. The rapid level can only be boosted by five through this method.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param increment number
function Entity:boost_rapid_level(increment) end

--- Returns the player's total charge level, a combination `boost_charge_level` and [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment) boosts.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:charge_level() end

--- - `increment`: integer
---
--- Adds the `increment` value to the charge level. The charge level can only be boosted by five through this method.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param increment number
function Entity:boost_charge_level(increment) end

--- Returns true if holding the Shoot button is tied to charging for [player.charged_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercharged_attack_func--functionself-actionnil)
---
--- With no calls to `*:set_charge_with_shoot()`, the default is true.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return boolean
function Entity:charges_with_shoot() end

--- Configures whether the Shoot button is tied to charging for [player.charged_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercharged_attack_func--functionself-actionnil), when no other augments or forms are overriding this behavior.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param bool? boolean
function Entity:set_charge_with_shoot(bool) end

--- Marks the player as trying to charge an attack for [player.charged_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercharged_attack_func--functionself-actionnil)
---
--- Automatically resets to false when the value is used by the engine.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@param bool? boolean
function Entity:mark_charging(bool) end

--- Returns the amount of time in game frames, the `Shoot` button would need to be held for a fully charged attack if the [player.calculate_charge_time](https://docs.hubos.dev/client/lua-api/entity-api/player#playercalculate_charge_time) function was not set.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:calculate_default_charge_time() end

--- Returns the amount of time in game frames, the `Shoot` button should be held for a fully charged attack.
---
--- Throws if the Entity doesn't pass [Player.from()](https://docs.hubos.dev/client/lua-api/entity-api/player)
---@return number
function Entity:calculate_charge_time() end

--- Returns a number. Used internally to identify the form.
---@return number
function PlayerForm:index() end

--- - `path`: file path relative to script file, use values returned from `Resources.load_texture()` for better performance.
---
--- This texture is used for the form selection menu.
---@param path string
function PlayerForm:set_mugshot_texture(path) end

--- Sets the description to display when the player requests for info.
---@param description? string
function PlayerForm:set_description(description) end

--- Sets whether Form Select closes when this form is selected.
---@param bool boolean
function PlayerForm:set_close_on_select(bool) end

--- Sets whether the transition and audio effect plays when this form is selected.
---@param bool boolean
function PlayerForm:set_transition_on_select(bool) end

--- Deactivates the form.
function PlayerForm:deactivate() end

--- Dedicates a button slot in Card Select to the specified card. Internally defined as a [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton).
--- Overrides the card button created on the Player and any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment).
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---@param card_properties CardProperties
---@param card_button_slot? number
---@return CardSelectButton
function PlayerForm:set_fixed_card(card_properties, card_button_slot) end

--- Creates a button embedded in the end of the card list in Card Select.
--- Overrides card buttons created on the Player and any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment).
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---@param slot_count number
---@param card_button_slot? number
---@return CardSelectButton
function PlayerForm:create_card_button(slot_count, card_button_slot) end

--- Creates a button under the "Confirm" button in Card Select.
--- Overrides the special button created on the Player and any [Augment](https://docs.hubos.dev/client/lua-api/entity-api/player#augment).
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---@return CardSelectButton
function PlayerForm:create_special_button() end

--- Configures whether the Shoot button is tied to charging for [player.charged_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercharged_attack_func--functionself-actionnil), when no other augments or forms are overriding this behavior.
---
--- When set to nil (default), the final value will try to fall back to a specified non-nil value with a lower priority or true.
---@param bool? boolean
function PlayerForm:set_charge_with_shoot(bool) end

--- Configures whether the Special button activate the special attack, when no other augments or forms are overriding this behavior.
---
--- When set to nil (default), the final value will try to fall back to a specified non-nil value with a lower priority or true.
---@param bool? boolean
function PlayerForm:set_special_on_input(bool) end

--- Configures whether holding movement buttons causes the player to move, when no other augments or forms are overriding this behavior.
---
--- When set to nil (default), the final value will try to fall back to a specified non-nil value with a lower priority or true.
---@param bool? boolean
function PlayerForm:set_movement_on_input(bool) end

--- Returns the package id of the augment.
---@return string
function Augment:id() end

--- Returns an integer.
---@return number
function Augment:level() end

--- Returns an [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity)
---@return Entity
function Augment:owner() end

--- - `tag`: string
---
--- Returns true if the augment has a matching tag.
---@param tag string
---@return boolean
function Augment:has_tag(tag) end

--- Returns true if the augment was deleted from the owner. Calls to other functions will error if this is true.
---@return boolean
function Augment:deleted() end

--- Dedicates a button slot in Card Select to the specified card. Internally defined as a [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton).
--- Overrides the card button created on the Player.
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---@param card_properties CardProperties
---@param card_button_slot? number
---@return CardSelectButton
function Augment:set_fixed_card(card_properties, card_button_slot) end

--- Creates a button embedded in the end of the card list in Card Select.
--- Overrides card buttons created on the Player.
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---@param slot_count number
---@param card_button_slot? number
---@return CardSelectButton
function Augment:create_card_button(slot_count, card_button_slot) end

--- Creates a button under the "Confirm" button in Card Select.
--- Overrides the special button created on the Player.
---
--- Returns [CardSelectButton](https://docs.hubos.dev/client/lua-api/entity-api/player#cardselectbutton)
---@return CardSelectButton
function Augment:create_special_button() end

--- Configures whether the Shoot button is tied to charging for [player.charged_attack_func](https://docs.hubos.dev/client/lua-api/entity-api/player#playercharged_attack_func--functionself-actionnil), when no other augments or forms are overriding this behavior.
---
--- When set to nil (default), the final value will try to fall back to a specified non-nil value with a lower priority or true.
---@param bool? boolean
function Augment:set_charge_with_shoot(bool) end

--- Configures whether the Special button activate the special attack, when no other augments or forms are overriding this behavior.
---
--- When set to nil (default), the final value will try to fall back to a specified non-nil value with a lower priority or true.
---@param bool? boolean
function Augment:set_special_on_input(bool) end

--- Configures whether holding movement buttons causes the player to move, when no other augments or forms are overriding this behavior.
---
--- When set to nil (default), the final value will try to fall back to a specified non-nil value with a lower priority or true.
---@param bool? boolean
function Augment:set_movement_on_input(bool) end

--- Returns a [Sprite](https://docs.hubos.dev/client/lua-api/resource-api/sprite)
---@return Sprite
function CardSelectButton:sprite() end

--- Returns a string.
---
--- Same as `button:sprite():texture()`
---@return string
function CardSelectButton:texture() end

--- Same as `button:sprite():set_texture(path)`
---
--- Use values returned from [Resources.load_texture()](https://docs.hubos.dev/client/lua-api/resource-api/resources#resourcesload_texturepath) for better performance.
---@param path string
function CardSelectButton:set_texture(path) end

--- Returns an [Animation](https://docs.hubos.dev/client/lua-api/resource-api/animation)
---@return Animation
function CardSelectButton:animation() end

--- Returns a [Sprite](https://docs.hubos.dev/client/lua-api/resource-api/sprite)
---@return Sprite
function CardSelectButton:preview_sprite() end

--- Returns a string.
---
--- Same as `button:preview_sprite():texture()`
---@return string
function CardSelectButton:preview_texture() end

--- Use values returned from [Resources.load_texture()](https://docs.hubos.dev/client/lua-api/resource-api/resources#resourcesload_texturepath) for better performance.
---
--- Same as `button:preview_sprite():set_texture(path)`
---@param path string
function CardSelectButton:set_preview_texture(path) end

--- Returns an [Animation](https://docs.hubos.dev/client/lua-api/resource-api/animation)
---@return Animation
function CardSelectButton:preview_animation() end

--- Replaces the set preview sprite and animation with a preview generated by the `card_properties` parameter.
---@param card_properties CardProperties
function CardSelectButton:use_card_preview(card_properties) end

--- Changes the cursor (when hovered) from a dynamic cursor based on button width to a fixed card cursor locked to the last card slot.
---@param bool boolean
function CardSelectButton:use_fixed_card_cursor(bool) end

--- A method to disable successful button use audio.
---@param bool boolean
function CardSelectButton:use_default_audio(bool) end

--- Sets the description to display when the player requests for info.
---@param description? string
function CardSelectButton:set_description(description) end

--- Sets the button's description to match a specified card.
---@param card_properties CardProperties
function CardSelectButton:use_card_description(card_properties) end

--- Returns an [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity)
---@return Entity
function CardSelectButton:owner() end

--- Deletes the button.
function CardSelectButton:delete() end

--- Returns true if the button was deleted.
---@return boolean
function CardSelectButton:deleted() end

--- Returns the entity passed in if the entity is a character or player, otherwise returns `nil`.
---@param entity Entity
---@return Entity
function Character.from(entity) end

--- - `package_id`: string, the package id of the character
--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
--- - `rank`
---   - `Rank.V1`
---   - `Rank.V2`
---   - `Rank.V3`
---   - `Rank.V4`
---   - `Rank.V5`
---   - `Rank.V6`
---   - `Rank.SP`
---   - `Rank.EX`
---   - `Rank.Rare1`
---   - `Rank.Rare2`
---   - `Rank.NM`
---   - `Rank.RV`
---   - `Rank.DS`
---   - `Rank.Alpha`
---   - `Rank.Beta`
---   - `Rank.Omega`
---   - `Rank.Sigma`
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity), throws if the package doesn't exist.
---@param package_id string
---@param team Team
---@param rank Rank
---@return Entity
function Character.from_package(package_id, team, rank) end

--- Returns the character's rank.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
---@return Rank
function Entity:rank() end

--- Hides the character's rank when displaying names.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
function Entity:hide_rank() end

--- Returns the namespace of the mod used to create the character.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
---@return Namespace
function Entity:namespace() end

--- Returns a list of [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties), the first card is the next card that can be used.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
---@return CardProperties[]
function Entity:field_cards() end

--- - `index`: number, 1 represents the next card that can be used.
---
--- Returns [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties) or nil.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
---@param index number
---@return CardProperties
function Entity:field_card(index) end

--- - `index`: number, 1 represents the next card that can be used.
--- - `card_properties`: [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties)
---
--- Changing package_id will cause [card_mutate()](https://docs.hubos.dev/client/packages#cards) to restart or run again next frame.
---
--- If there's no card at this index, nothing happens.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
---@param index number
---@param card_properties CardProperties
function Entity:set_field_card(index, card_properties) end

--- - `index`: number, 1 represents the next card that can be used.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
---@param index number
function Entity:remove_field_card(index) end

--- - `index`: number, 1 represents the next card that can be used.
--- - `card_properties`: [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties)
---
--- Inserts a card at this index, shifting cards at this position and after to the right.
---
--- Will cause [card_mutate()](https://docs.hubos.dev/client/packages#cards) to restart or run again next frame.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
---@param index number
---@param card_properties CardProperties
function Entity:insert_field_card(index, card_properties) end

--- Causes the character to use the next field card when actions and movements end.
---
--- This request will be cancelled in time freeze, but can be used to TFC when appropriate.
---
--- The card will remain in field_cards until it's used.
---
--- Using this method will allow AuxProps to affect the card, unlike queued actions generated from a card.
---
--- Throws if the Entity doesn't pass [Character.from()](https://docs.hubos.dev/client/lua-api/entity-api/character)
function Entity:use_card() end

--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---@param team? Team
---@return Entity
function Spell.new(team) end

--- Returns the entity passed in if the entity is a spell, otherwise returns `nil`.
---@param entity Entity
---@return Entity
function Spell.from(entity) end

--- Sets the highlight mode for tiles the spell passes over.
---
--- See [tile:set_highlight()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileset_highlighthighlight)
---
--- Throws if the Entity doesn't pass [Spell.from()](https://docs.hubos.dev/client/lua-api/entity-api/spell)
---@param highlight Highlight
function Entity:set_tile_highlight(highlight) end

--- Returns a copy of the spell's [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- Throws if the Entity doesn't pass [Spell.from()](https://docs.hubos.dev/client/lua-api/entity-api/spell)
---@return HitProps
function Entity:copy_hit_props() end

--- - `hit_props`: [HitProps](https://docs.hubos.dev/client/lua-api/attack-api/hit-props)
---
--- Throws if the Entity doesn't pass [Spell.from()](https://docs.hubos.dev/client/lua-api/entity-api/spell)
---@param hit_props HitProps
function Entity:set_hit_props(hit_props) end

--- Attack entities on the target tile, defaults to the spell's current tile.
---
--- If this function is called on every frame by this spell, attacks queued for the same tile will be ignored after the first frame hits occur in.
---
--- To allow a spell to hit multiple times on the same tile, calls to this function should be skipped for at least a frame, or a new spell should be spawned to perform the attack.
---
--- See [SharedHitbox](https://docs.hubos.dev/client/lua-api/entity-api/spell#sharedhitbox) for a convenience spell to handle attacks.
---
--- Throws if the Entity doesn't pass [Spell.from()](https://docs.hubos.dev/client/lua-api/entity-api/spell)
---@param tile? Tile
function Entity:attack_tile(tile) end

--- Same as calling [spell:attack_tile(tile)](https://docs.hubos.dev/client/lua-api/entity-api/spell#spellattack_tiletile) for each tile.
---
--- Throws if the Entity doesn't pass [Spell.from()](https://docs.hubos.dev/client/lua-api/entity-api/spell)
---@param tiles Tile[]
function Entity:attack_tiles(tiles) end

--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---@param team? Team
---@param damage? number
---@return Entity
function Hitbox.new(team, damage) end

--- - `duration`: The amount of frames this spell should exist for. If unset, it will require manual deletion.
---
--- Creates a SharedHitbox.
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---@param spell Entity
---@param duration? number
---@return Entity
function SharedHitbox.new(spell, duration) end

--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---@param team? Team
---@return Entity
function Obstacle.new(team) end

--- Returns the entity passed in if the entity is an obstacle, otherwise returns `nil`.
---@param entity Entity
---@return Entity
function Obstacle.from(entity) end

--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---@param team? Team
---@return Entity
function Artifact.new(team) end

--- Returns the entity passed in if the entity is an artifact, otherwise returns `nil`.
---@param entity Entity
---@return Entity
function Artifact.from(entity) end

--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---
--- The entity will play an animation and sound, automatically deletes on completion.
---@param team? Team
---@return Entity
function Explosion.new(team) end

--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---
--- The entity will play an animation, automatically deletes on completion.
---@param team? Team
---@return Entity
function Poof.new(team) end

--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---
--- Returns a new [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) instance.
---
--- The entity will play an animation, automatically deletes on completion.
---@param team? Team
---@return Entity
function Alert.new(team) end

--- - `path`: file path relative to script file
---
--- Caches the texture and returns a normalized path for faster access.
---
--- Returns a string.
---
--- Should be used in global scope for better performance.
---@param path string
---@return string
function Resources.load_texture(path) end

--- - `path`: file path relative to script file
---
--- Caches the audio and returns a normalized path for faster access.
---
--- Returns a string.
---
--- Should be used in global scope for better performance.
---@param path string
---@return string
function Resources.load_audio(path) end

--- Returns the path to the folder containing the game files.
---
--- Useful for loading assets that ship by default.
---@return string
function Resources.game_folder() end

--- - `path`: file path relative to script file, use values returned from `Resources.load_audio()` for better performance.
--- - `audio_behavior`: [AudioBehavior](https://docs.hubos.dev/client/lua-api/resource-api/resources#audiobehavior)
---
--- Plays a sound with the specified priority.
---
--- See [player:play_audio()](https://docs.hubos.dev/client/lua-api/entity-api/player#playerplay_audiopath-audio_behavior) for playing audio to a specific player.
---@param path string
---@param audio_behavior? AudioBehavior
function Resources.play_audio(path, audio_behavior) end

--- Stops the currently playing music.
function Resources.stop_music() end

--- - `path`: file path relative to script file, use values returned from `Resources.load_audio()` for better performance.
---
--- Plays audio stored at `path` as music. Loops by default.
---@param path string
---@param loops? boolean
function Resources.play_music(path, loops) end

--- Returns [Color](https://docs.hubos.dev/client/lua-api/resource-api/sprite#color), tied to the Flash Brightness setting and seen as the color used for transitions to white.
---
--- Be careful when reading properties from the returned value, as settings will differ between players, and driving logic using these values can cause each client to desync.
---@return Color
function Resources.white_flash_color() end

--- Returns true if the index represents the local player.
---@param player_index number
---@return boolean
function Resources.is_local(player_index) end

--- Returns a number, represents the index of the local player in the list of players sent from the server.
---@return number
function Resources.local_index() end

--- Same as [player:input_has()](https://docs.hubos.dev/client/lua-api/entity-api/player#playerinput_hasinput_query).
---
--- Allows for spectator input to be read.
---@param player_index number
---@param input_query Input
function Resources.input_has(player_index, input_query) end

--- Returns the namespace of the VM the calling mod is currently loaded in.
---@return Namespace
function Resources.namespace() end

--- Audio will play from the beginning (sample 0), looping back to `start_sample` when `end_sample` is reached.
---
--- Stops existing playback of the sound if it has `AudioBehavior.NoOverlap`.
---
--- Returns an AudioBehavior.
---@param start_sample number
---@param end_sample number
---@return AudioBehavior
function AudioBehavior.LoopSection(start_sample, end_sample) end

--- Returns a new Animation instance.
---@param path? string
---@return Animation
function Animation.new(path) end

--- Copies states and settings from the passed animation. Progress is reset.
---
--- Internally calls `animation:apply()` unless the animation was created through `Animation.new()`
---
--- This function will call and clear interrupt callbacks.
---@param animation Animation
function Animation:copy_from(animation) end

--- Applies the current animation state to the sprite, updating the origin and bounds of the sprite.
---@param sprite Sprite
function Animation:apply(sprite) end

--- Loads new states, clears the old states.
---
--- Will attempt to retain settings and progress if the new animation has the same state as the active state.
---
--- If the animation has not completed and retaining state fails, this function will call and clear interrupt callbacks.
---@param path string
function Animation:load(path) end

--- Advances animation progress by 1f or ~0.1666s. Ignored if the animation is paused.
---
--- Internally calls `animation:apply()` unless the animation was created through `Animation.new()`
---
--- Automatically called unless the animation was created through `Animation.new()`
function Animation:update() end

--- - `time`: number, represents game frames
---
--- Updates the animation as if it has only played for `time`. Using the same time will freeze the animation, decreasing time will reverse the animation.
---@param time number
function Animation:sync_time(time) end

--- Causes `animation:update()` calls (including automatic calls) to be ignored.
function Animation:pause() end

--- Unpauses the animation.
function Animation:resume() end

--- Returns true if the animation is complete.
---@return boolean
function Animation:completed() end

--- Returns true if the state exists.
---@param state string
---@return boolean
function Animation:has_state(state) end

--- Returns the name of the active state.
---@return string
function Animation:state() end

--- Returns a list of available state names.
---@return string[]
function Animation:states() end

--- - `frame_data` a list of frame index and duration pairs.
---   - When provided, the animation will remap frames and durations to match until the next `set_state` call.
---   - Frame index starts at 1
---   - Duration is in game frames (60 per second).
---
--- Changes the active state, resets animation progress and settings.
---
--- This function will call and clear interrupt callbacks.
---
--- Internally calls `animation:apply()` unless the animation was created through `Animation.new()`
---
--- ```lua
--- -- modified example from the built-in buster.lua file
---
--- local frame_data = { { 1, 1 }, { 2, 2 }, { 3, 2 }, { 1, 1 } }
---
--- action:override_animation_frames(frame_data)
---
--- -- setup buster attachment
--- local buster_attachment = action:add_attachment("BUSTER")
---
--- local buster_sprite = buster_attachment:sprite()
--- buster_sprite:set_texture(user:texture())
--- buster_sprite:set_layer(-2)
--- buster_sprite:use_root_shader()
---
--- local buster_animation = buster_attachment:animation()
--- buster_animation:copy_from(user:animation())
---
--- -- relevant
--- buster_animation:set_state("BUSTER", frame_data)
--- ```
---@param state string
---@param frame_data? [number, number][]
function Animation:set_state(state, frame_data) end

--- Returns true if the current animation frame has a point with this name.
---@param name string
---@return boolean
function Animation:has_point(name) end

--- Returns `{ x: number, y: number }`.
---@param name string
---@return { x: number, y: number }
function Animation:get_point(name) end

--- Calculates where a point is relative to the origin.
---
--- Returns `{ x: number, y: number }`.
---@param name string
---@param origin_name? string
---@return { x: number, y: number }
function Animation:relative_point(name, origin_name) end

--- - `playback`:
---   - `Playback.Once` stops when the animation is completed.
---   - `Playback.Loop` restarts the animation when completed.
---   - `Playback.Bounce` when the animation completes playing forward it will play again reversed and cycle.
---   - `Playback.Reverse` same as `Playback.Once` but reversed.
---     - Currently does not start the animation on the last frame.
---
--- ```lua
--- animation:set_state("example")
--- animation:set_playback(Playback.Loop)
--- ```
---@param playback Playback
function Animation:set_playback(playback) end

--- Adds a function to be called when the animation "completes". The callback will no longer be called when the state is changed.
---
--- Completion condition differs depending on playback:
---
--- - `Playback.Once` when the last frame completes.
--- - `Playback.Loop` when the last frame completes.
--- - `Playback.Bounce` when the first frame completes when reversed.
--- - `Playback.Reverse` when the first frame completes.
---@param callback fun()
function Animation:on_complete(callback) end

--- Adds a function to be called when the state changes. The callback will no longer be called after this occurs.
---@param callback fun()
function Animation:on_interrupt(callback) end

--- - `frame_index` starts at 1
--- - `do_once` when true, the callback is deleted.
---
--- Calls the callback when the frame changes during an update. If the `frame_index` is 1 and the state was just set, it will be called next update.
---
--- The callback will no longer be called when the state is changed.
---@param frame_index number
---@param callback fun()
---@param do_once? boolean
function Animation:on_frame(frame_index, callback, do_once) end

--- Returns a new child Sprite instance that renders relative to the parent sprite's origin.
---@return Sprite
function Sprite:create_node() end

--- - `text_style`: [TextStyle](https://docs.hubos.dev/client/lua-api/resource-api/sprite#textstyle)
--- - `text`: The text to render.
---
--- Returns a Sprite, similar to `sprite:create_node()`. The returned sprite node has a child for each character in `text`, all with [sprite:use_parent_shader(true)](https://docs.hubos.dev/client/lua-api/resource-api/sprite#spriteuse_parent_shaderenable) set.
---@param text_style TextStyle
---@param text string
---@return Sprite
function Sprite:create_text_node(text_style, text) end

--- Copies all data from the other sprite, other than children.
---@param sprite Sprite
function Sprite:copy_from(sprite) end

--- Deletes the passed sprite if it's a child of the parent.
---@param sprite Sprite
function Sprite:remove_node(sprite) end

--- Returns a list of Sprites.
---@return Sprite[]
function Sprite:children() end

--- Returns the path to the sprite's texture.
---@return string
function Sprite:texture() end

--- Use values returned from [Resources.load_texture()](https://docs.hubos.dev/client/lua-api/resource-api/resources#resourcesload_texturepath) for better performance.
---@param path string
function Sprite:set_texture(path) end

--- Returns the path to the sprite's palette or `nil`.
---@return string
function Sprite:palette() end

--- Sets the palette for the texture to reference.
---
--- Palettes are 256x1 images. Colors on the sprite's texture will be remapped by taking the red value of the texture to grab a color from the palette.
---
--- Use values returned from [Resources.load_texture()](https://docs.hubos.dev/client/lua-api/resource-api/resources#resourcesload_texturepath) for better performance.
---@param path? string
function Sprite:set_palette(path) end

--- Returns true if the sprite is visible.
---@return boolean
function Sprite:visible() end

---
---@param visible boolean
function Sprite:set_visible(visible) end

--- Same as `sprite:set_visible(true)`
function Sprite:reveal() end

--- Same as `sprite:set_visible(false)`
function Sprite:hide() end

--- Returns an integer used for sorting during render.
---@return number
function Sprite:layer() end

--- - `layer`: integer, negative values render in front of the parent sprite.
---
--- Used for sorting during render.
---@param layer number
function Sprite:set_layer(layer) end

--- Returns `{ x: number, y: number }`, represents the parent relative offset.
---@return { x: number, y: number }
function Sprite:offset() end

--- Sets the parent relative offset.
---@param x number
---@param y number
function Sprite:set_offset(x, y) end

--- Returns `{ x: number, y: number }`.
---@return { x: number, y: number }
function Sprite:origin() end

--- Sets the origin, [Animations](https://docs.hubos.dev/client/lua-api/resource-api/animation) will overwrite this value.
---@param x number
---@param y number
function Sprite:set_origin(x, y) end

--- Returns `{ x: number, y: number }`.
---@return { x: number, y: number }
function Sprite:scale() end

--- Sets the scale of the sprite.
---@param x number
---@param y number
function Sprite:set_scale(x, y) end

--- Returns `{ x: number, y: number }`. Represents the size of the sprite. Scale is accounted.
---@return { x: number, y: number }
function Sprite:size() end

--- Sets the size of the sprite, updates the scale.
---@param x number
---@param y number
function Sprite:set_size(x, y) end

--- Returns the width of the sprite, scale is acounted.
---@return number
function Sprite:width() end

--- Sets the width of the sprite, updates the scale.
---@param width number
function Sprite:set_width(width) end

--- Returns the height of the sprite, scale is acounted.
---@return number
function Sprite:height() end

--- Sets the height of the sprite, updates the scale.
---@param height number
function Sprite:set_height(height) end

--- Returns the rotation of the sprite, in radians.
---
--- You can convert to degrees with `radians / math.pi * 180`
---@return number
function Sprite:rotation() end

--- Sets the rotation of the sprite.
---
--- You can convert degrees to radians with `degrees / 180 * math.pi`
---@param radians number
function Sprite:set_rotation(radians) end

--- Returns a [Color](https://docs.hubos.dev/client/lua-api/resource-api/sprite#color)
---@return Color
function Sprite:color() end

--- - `color`: [Color](https://docs.hubos.dev/client/lua-api/resource-api/sprite#color)
---
--- The color will be reset to black at the start of the next frame for root sprites.
---@param color Color
function Sprite:set_color(color) end

--- Returns the ColorMode.
---@return ColorMode
function Sprite:color_mode() end

--- - `color_mode`
---   - `ColorMode.Add` each pixel will be added by the sprite's color, alpha will be multiplied.
---   - `ColorMode.Multiply` each pixel will be multiplied by the sprite's color.
---   - `ColorMode.Adopt` the RGB components of the sprite's color will be directly used, alpha will be multiplied.
---
--- The color mode will be reset to `ColorMode.Add` at the start of the next frame for root sprites.
---@param color_mode ColorMode
function Sprite:set_color_mode(color_mode) end

--- Returns true if perspective does not affect the sprite.
---@return boolean
function Sprite:never_flip() end

--- Prevents player perspective from flipping the sprite.
---@param never_flip? boolean
function Sprite:set_never_flip(never_flip) end

--- Returns a SpriteShaderEffect.
---@return SpriteShaderEffect
function Sprite:shader_effect() end

--- - `sprite_shader_effect`
---   - `SpriteShaderEffect.None`
---   - ``SpriteShaderEffect.Grayscale`
---   - `SpriteShaderEffect.Pixelate`
---     - Scales with alpha.
---@param sprite_shader_effect SpriteShaderEffect
function Sprite:set_shader_effect(sprite_shader_effect) end

--- Temporarily adopts the color, color mode, and shader effect of the root sprite during render.
---@param enable? boolean
function Sprite:use_root_shader(enable) end

--- Adopts the color, color mode, and shader effect of the parent sprite during render.
---@param enable? boolean
function Sprite:use_parent_shader(enable) end

--- Each component is a 0-255 value, `a` defaults to 255.
---
--- Returns a color.
---@param r number
---@param g number
---@param b number
---@param a? number
---@return Color
function Color.new(r, g, b, a) end

--- A `progress` of 0.0 will return a table with the same values as `color_a`.
---
--- A `progress` of 1.0 will return a table with the same values as `color_b`.
---
--- Other values of `progress` will linearly interpolate each component between `color_a` and `color_b`.
---
--- Returns a color.
---@param color_a Color
---@param color_b Color
---@param progress number
---@return Color
function Color.mix(color_a, color_b, progress) end

--- - `font_name`: The name of the font to use.
---   - Built in fonts:
---     - `"THICK"`
---     - `"THIN"`
---     - `"THIN_SMALL"`
---     - `"MENU_TITLE"`
---     - `"NAVIGATION"`
---     - `"MICRO"`
---     - `"CONTEXT"`
---     - `"CODE"`
---     - `"PLAYER_HP"`
---     - `"PLAYER_HP_ORANGE"`
---     - `"PLAYER_HP_GREEN"`
---     - `"DAMAGE"`
---     - `"RESULT"`
---     - `"BATTLE"`
---     - `"ENTITY_HP"`
---     - `"ENTITY_HP_RED"`
---     - `"ENTITY_HP_GREEN"`
---   - `texture_path`: Required for custom fonts.
---   - `animation_path`: Required for custom fonts.
---
--- For custom fonts, the format `[FONT_NAME]_U+[CHAR_HEX]` is used for mapping characters. Only the first frame in the animation is used to render the character.
---
--- Example: An animation file containing the character `A` for the font `COOL_FONT`
---
--- ```
--- animation state="COOL_FONT_U+0041"
--- frame x="0" y="0" w="7" h="12
--- ```
---
--- Returns TextStyle.
---@param font_name string
---@param texture_path? string
---@param animation_path? string
---@return TextStyle
function TextStyle.new(font_name, texture_path, animation_path) end

--- Returns TextStyle, see [TextStyle.new()](https://docs.hubos.dev/client/lua-api/resource-api/sprite#textstylenewfont_name-texture_path-animation_path)
---@param font_name string
---@param texture_path? string
---@param animation_path? string
---@return TextStyle
function TextStyle.new_monospace(font_name, texture_path, animation_path) end

--- Returns TextMetrics
---@param text_style TextStyle
---@param text string
---@return TextMetrics
function TextStyle.measure(text_style, text) end

--- Returns a reference to the sync node's sprite.
---@return Sprite
function SyncNode:sprite() end

--- Returns a reference to the sync node's [Animation](https://docs.hubos.dev/client/lua-api/resource-api/animation)
---@return Animation
function SyncNode:animation() end

--- There's hidden padding around the field, the first visible tile is at (1, 1).
---
--- Returns a [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile) or `nil`
---@param col number
---@param row number
---@return Tile|nil
function Field.tile_at(col, row) end

--- Returns the total columns in the field.
---@return number
function Field.width() end

--- Returns the total rows in the field.
---@return number
function Field.height() end

--- Spawns the entity at the start of the next frame if the entity hasn't already been spawned, and places the entity at the tile.
---@param entity Entity
---@param tile Tile
---@diagnostic disable-next-line: duplicate-set-field
function Field.spawn(entity, tile) end

--- Spawns the entity at the start of the next frame if the entity hasn't already been spawned, and places the entity at the tile at (col, row).
---@param entity Entity
---@param col number
---@param row number
---@diagnostic disable-next-line: duplicate-set-field
function Field.spawn(entity, col, row) end

--- Returns an [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) or `nil`.
---@param id EntityId
---@return Entity|nil
function Field.get_entity(id) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- All spawned [Entities](https://docs.hubos.dev/client/lua-api/entity-api/entity) that haven't been deleted will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Field.find_entities(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Characters](https://docs.hubos.dev/client/lua-api/entity-api/character) that haven't been deleted will be passed to the callback, includes [Players](https://docs.hubos.dev/client/lua-api/entity-api/player).
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Field.find_characters(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Obstacles](https://docs.hubos.dev/client/lua-api/entity-api/obstacle) that haven't been deleted will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Field.find_obstacles(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Players](https://docs.hubos.dev/client/lua-api/entity-api/player) that haven't been deleted will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Field.find_players(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Spells](https://docs.hubos.dev/client/lua-api/entity-api/spell) that haven't been deleted will be passed to the callback, excludes [Obstacles](https://docs.hubos.dev/client/lua-api/entity-api/obstacle).
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Field.find_spells(callback) end

--- Returns a list of entities sorted by distance, for any entity the callback returned true for.
---
--- Only spawned [Characters](https://docs.hubos.dev/client/lua-api/entity-api/character) that haven't been deleted will be passed to the callback, includes [Players](https://docs.hubos.dev/client/lua-api/entity-api/player).
---@param entity Entity
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Field.find_nearest_characters(entity, callback) end

--- Returns a list of entities sorted by distance, for any entity the callback returned true for.
---
--- Only spawned [Players](https://docs.hubos.dev/client/lua-api/entity-api/player) that haven't been deleted will be passed to the callback.
---@param entity Entity
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Field.find_nearest_players(entity, callback) end

--- Returns a list of [Tiles](https://docs.hubos.dev/client/lua-api/field-api/tile) for any tile the callback returned true for.
---@param callback fun(tile: Tile): boolean
---@return Tile[]
function Field.find_tiles(callback) end

--- - `strength` number, affects how aggressively the field shakes
--- - `duration` number, how many game frames the effect should last
---@param strength number
---@param duration number
function Field.shake(strength, duration) end

--- Causes tiles in the column to return to the matching team as soon as possible, starting at the next frame. The transfer will be delayed by tile reservations in the column.
---@param x number
---@param team Team
function Field.reclaim_column(x, team) end

--- Returns the column of the tile.
---@return number
function Tile:x() end

--- Returns the row of the tile.
---@return number
function Tile:y() end

--- Returns the width of the tile in pixels.
---@return number
function Tile:width() end

--- Returns the height of the tile in pixels.
---@return number
function Tile:height() end

--- Returns the TileState.
---@return TileState
function Tile:state() end

--- - `tile_state`
---   - `TileState.Void`
---   - `TileState.Normal`
---   - `TileState.PermaHole`
---   - `TileState.Cracked`
---   - `TileState.Broken`
---   - [TileState.[state_name]](https://docs.hubos.dev/client/packages#tile-states)
---@param tile_state TileState
function Tile:set_state(tile_state) end

--- Returns true if the currently applied tile state can be replaced with `tile_state`
---@param tile_state TileState
---@return boolean
function Tile:can_set_state(tile_state) end

--- Returns a TileState, usually the same as [tile:state()](https://docs.hubos.dev/client/lua-api/field-api/tile#tilestate), unless [tile:set_visible_state()](https://docs.hubos.dev/client/lua-api/field-api/tile#tileset_visible_statetile_state) was called.
---@return TileState
function Tile:visible_state() end

--- Overrides the visual for the tile to match a tile state, or set to nil to sync with [tile:state()](https://docs.hubos.dev/client/lua-api/field-api/tile#tilestate)
---@param tile_state? TileState
function Tile:set_visible_state(tile_state) end

--- Returns true if the tile is one of the hidden padding tiles around the edge of the field.
---@return boolean
function Tile:is_edge() end

--- Returns true if the tile is not a hole.
---
--- Examples: `TileState.Broken`, `TileState.Void`, `TileState.Empty`
---@return boolean
function Tile:is_walkable() end

--- Returns true as long as there are no reservations by entities where [entity:sharing_tile()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entitysharing_tile) is false, excluding [entities with ids](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityid) matching the `exclude_list`.
---@param exclude_list? EntityId[]
---@return boolean
function Tile:is_shareable(exclude_list) end

--- Returns true if there's any reservations for this tile, excluding [entities with ids](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityid) matching the `exclude_list`.
---@param exclude_list? EntityId[]
---@return boolean
function Tile:is_reserved(exclude_list) end

--- Returns a number, representing the total reservation count for this [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity).
---@param entity Entity
---@return number
function Tile:reserve_count_for(entity) end

--- Adds a reservation of this tile for this [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity).
---@param entity Entity
function Tile:reserve_for(entity) end

--- Removes a reservation for this tile for this [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity).
---@param entity Entity
function Tile:remove_reservation_for(entity) end

--- Adds a reservation of this tile for this [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) using an entity id.
---@param entity_id EntityId
function Tile:reserve_for_id(entity_id) end

--- Removes a reservation of this tile for this [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) using an entity id.
---@param entity_id EntityId
function Tile:remove_reservation_for_id(entity_id) end

--- Returns [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---@return Team
function Tile:team() end

--- - `team`: [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
--- - `direction`: [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction) override for the duration of the team change.
---@param team Team
---@param direction Direction
function Tile:set_team(team, direction) end

--- Returns [Team](https://docs.hubos.dev/client/lua-api/entity-api/entity#entityset_teamteam)
---@return Team
function Tile:original_team() end

--- Returns a [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction)
---@return Direction
function Tile:facing() end

--- - `direction`: [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction)
---
--- Sets the facing direction used to set the initial direction of spawned entities, as well as for resolving reverting team.
---@param direction Direction
function Tile:set_facing(direction) end

--- Returns a [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction)
---@return Direction
function Tile:original_facing() end

--- - `highlight`
---   - `Highlight.None`
---   - `Highlight.Flash`
---     - Used to warn players about an attack that will happen.
---   - `Highlight.Solid`
---     - Used to let players know they will get hit if they are on this tile.
---@param highlight Highlight
function Tile:set_highlight(highlight) end

--- - `direction`: [Direction](https://docs.hubos.dev/client/lua-api/field-api/direction)
--- - `count`: integer
---
--- Returns a Tile `count` many tiles in `direction`'s direction, or `nil`.
---@param direction Direction
---@param distance number
---@return Tile|nil
function Tile:get_tile(direction, distance) end

--- Same as [spell:attack_tile(tile)](https://docs.hubos.dev/client/lua-api/entity-api/spell#spellattack_tiletile)
---@param spell Entity
function Tile:attack_entities(spell) end

--- Returns true if the [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) is at the same position as the tile.
---@param entity Entity
---@return boolean
function Tile:contains_entity(entity) end

--- Moves the [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) to this tile if the entity is spawned.
---@param entity Entity
function Tile:add_entity(entity) end

--- Removes the [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) from the field.
---@param entity Entity
function Tile:remove_entity(entity) end

--- Removes the [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) from the field.
---@param entity_id EntityId
function Tile:remove_entity_by_id(entity_id) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Entities](https://docs.hubos.dev/client/lua-api/entity-api/entity) not marked for deletion will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Tile:find_entities(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Characters](https://docs.hubos.dev/client/lua-api/entity-api/character) not marked for deletion will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Tile:find_characters(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Obstacles](https://docs.hubos.dev/client/lua-api/entity-api/obstacle) not marked for deletion will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Tile:find_obstacles(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only spawned [Players](https://docs.hubos.dev/client/lua-api/entity-api/player) not marked for deletion will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Tile:find_players(callback) end

--- Returns a list of entities for any entity the callback returned true for.
---
--- Only [Spells](https://docs.hubos.dev/client/lua-api/entity-api/spell) will be passed to the callback.
---@param callback fun(entity: Entity): boolean
---@return Entity[]
function Tile:find_spells(callback) end

--- Returns a direction flipped along the x axis.
---
--- ```lua
--- assert(Direction.flip_x(Direction.Left) == Direction.Right)
--- assert(Direction.flip_x(Direction.UpLeft) == Direction.UpRight)
--- ```
---@param direction Direction
---@return Direction
function Direction.flip_x(direction) end

--- Returns a direction flipped along the y axis.
---
--- ```lua
--- assert(Direction.flip_y(Direction.Up) == Direction.Down)
--- assert(Direction.flip_y(Direction.UpLeft) == Direction.DownLeft)
--- ```
---@param direction Direction
---@return Direction
function Direction.flip_y(direction) end

--- Returns a direction flipped along the y axis.
---
--- ```lua
--- assert(Direction.reverse(Direction.Left) == Direction.Right)
--- assert(Direction.reverse(Direction.UpLeft) == Direction.DownRight)
--- ```
---@param direction Direction
---@return Direction
function Direction.reverse(direction) end

--- Returns two directions, a horizontal direction and vertical direction.
---
--- ```lua
--- local x_dir, y_dir = Direction.split(Direction.UpLeft)
---
--- assert(x_dir == Direction.Left)
--- assert(y_dir == Direction.Up)
--- ```
---@param direction Direction
---@return Direction, Direction
function Direction.split(direction) end

--- Joins two directions into a single direction.
---
--- Returns a direction.
---
--- ```lua
--- assert(Direction.join(Direction.Up, Direction.Left) == Direction.UpLeft)
--- assert(Direction.join(Direction.UpLeft, Direction.Right) == Direction.Up)
--- assert(Direction.join(Direction.Left, Direction.Right) == Direction.None)
--- ```
---@param direction_a Direction
---@param direction_b Direction
---@return Direction
function Direction.join(direction_a, direction_b) end

--- Returns `{ x: number, y: number }`.
---
--- ```lua
--- local vector = Direction.vector(Direction.UpLeft)
--- assert(vector.x == -1 and vector.y == -1)
--- ```
---@param direction Direction
---@return { x: number, y: number }
function Direction.vector(direction) end

--- Returns `{ x: number, y: number }`.
---
--- ```lua
--- local vector = Direction.unit_vector(Direction.UpLeft)
--- print(vector.x) -- -0.707...
--- print(vector.y) -- -0.707...
--- ```
---@param direction Direction
---@return { x: number, y: number }
function Direction.unit_vector(direction) end

--- - `tile`: [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile)
---
--- Returns a new Movement instance.
---@param tile Tile
---@return Movement
function Movement.new_teleport(tile) end

--- - `tile`: [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile)
--- - `delta`: number
---
--- Returns a new Movement instance.
---@param tile Tile
---@param delta number
---@return Movement
function Movement.new_slide(tile, delta) end

--- - `tile`: [Tile](https://docs.hubos.dev/client/lua-api/field-api/tile)
--- - `height`: number
--- - `delta`: number
---
--- Returns a new Movement instance.
---@param tile Tile
---@param height number
---@param delta number
---@return Movement
function Movement.new_jump(tile, height, delta) end

--- Returns the movement's animation progress as a value between 0 and 1.
---@return number
function Movement:animation_progress() end

--- Returns true if the movement is processed as a slide.
---@return boolean
function Movement:is_sliding() end

--- Returns true if the movement is processed as a jump.
---@return boolean
function Movement:is_jumping() end

--- Returns true if the movement is processed as a teleport.
---@return boolean
function Movement:is_teleporting() end

--- - `package_id`: string, the package id for a character package
--- - `rank`: [Rank](https://docs.hubos.dev/client/lua-api/entity-api/character#characterfrom_packagepackage_id-team-rank)
---
--- Returns a [Spawner](https://docs.hubos.dev/client/lua-api/field-api/encounter#spawner)
---@param package_id string
---@param rank Rank
---@return Spawner
function Encounter:create_spawner(package_id, rank) end

--- Returns a number, the amount of players that will join the battle.
---@return number
function Encounter:player_count() end

--- - `player_index`: number, starts at 0
---
--- Sets the spawn position for this player.
---@param player_index number
---@param col number
---@param row number
function Encounter:spawn_player(player_index, col, row) end

--- - `player_index`: number, starts at 0
---
--- Marks the player as a spectator. Avoids creating an entity for this player (Mods from this player will still be loaded).
---@param player_index number
function Encounter:mark_spectator(player_index) end

--- Converts players to spectators when deleted.
---@param bool? boolean
function Encounter:set_spectate_on_delete(bool) end

--- - `vel_x`: if unset, uses the "VELOCITY" point on the first frame of the animation.
--- - `vel_y`: if unset, uses the "VELOCITY" point on the first frame of the animation.
---@param texture_path string
---@param animation_path string
---@param vel_x? number
---@param vel_y? number
function Encounter:set_background(texture_path, animation_path, vel_x, vel_y) end

--- Sets the initial battle music. Use [Resources.play_music()](https://docs.hubos.dev/client/lua-api/resource-api/resources#resourcesplay_musicpath-loops) to change the music in the middle of the battle
---@param path string
function Encounter:set_music(path) end

--- Resizes the field, remember to add two to each dimension to account for the invisible edge tiles (The default field size is 8x5). If the field is larger than the screen allows, the camera will adjust placement and zoom to fit all [Characters](https://docs.hubos.dev/client/lua-api/entity-api/character).
---
--- Resets tile teams and states on the field.
---@param width number
---@param height number
function Encounter:set_field_size(width, height) end

--- Deprecated. Use [Field](https://docs.hubos.dev/client/lua-api/field-api/field) directly.
function Encounter:field() end

--- Overrides visuals used to render tile states.
---
--- `TileState.Normal` and `TileState.PermalHole` are special base states, overriding visuals for these states may affect what is drawn for other states.
---@param tile_state TileState
---@param texture_path string
---@param animation_path string
function Encounter:set_tile_state_resources(tile_state, texture_path, animation_path) end

--- Sets the size of tiles for resolving placement.
---@param width number
---@param height number
function Encounter:set_tile_size(width, height) end

--- - `enabled`: defaults to true.
---
--- Causes turns to end without needing the player to press the EndTurn button.
---@param enabled? boolean
function Encounter:enable_automatic_turn_end(enabled) end

--- - `limit`: max number of turns players can take.
---
--- If the `limit` is hit, the battle will end as a failure.
---@param limit number
function Encounter:set_turn_limit(limit) end

--- - `chain_limit`
---   - `TimeFreezeChainLimit.PerTeam(n)` only up to `n` time freeze actions from each team will be used.
---     - The default is `TimeFreezeChainLimit.PerTeam(1)`
---   - `TimeFreezeChainLimit.PerEntity(n)` only up to `n` time freeze actions from each entity will be used.
---   - `TimeFreezeChainLimit.Unlimited` every time freeze action in the chain will be used.
---@param chain_limit TimeFreezeChainLimit
function Encounter:set_time_freeze_chain_limit(chain_limit) end

--- How many entities can be owned by the team before old entities start deleting, 2 by default.
---@param limit number
function Encounter:set_team_owner_limit(limit) end

--- How many entities can be owned by an entity before old entities start deleting, 1 by default.
---@param limit number
function Encounter:set_entity_owner_limit(limit) end

--- Decides whether the entity owner limit is shared between the team or is tied directly to the owner, true by default.
---
--- If the entity owner limit is 1, there can only be one entity owned by any member of the team when this is true, otherwise there can be one for each unique owner.
---@param share? boolean
function Encounter:set_entities_share_ownership(share) end

--- - `enable`: defaults to true.
--- - `player_index`: starts at 0, if unset applies to all players.
---
--- When enabled, players can flip using the FaceLeft and FaceRight buttons.
---
--- If this function is never called, it is automatically decided by checking for non team panels on the end row behind the player.
---@param enable? boolean
---@param player_index? number
function Encounter:enable_flipping(enable, player_index) end

--- Affects the score in [battle_results](https://docs.hubos.dev/server/lua-api/events#battle_results).
---@param enabled? boolean
function Encounter:enable_boss_battle(enabled) end

--- Disables the built-in battle result banner and prevents the scene from automatically ending.
function Encounter:enable_scripted_scene_end() end

--- Disables the built-in win / loss detection.
function Encounter:enable_scripted_result() end

--- Marks the battle as a win for [battle_results](https://docs.hubos.dev/server/lua-api/events#battle_results).
---
--- Additionally [ends the battle](https://docs.hubos.dev/client/lua-api/field-api/encounter#encounteron_battle_endfunctionwon), does not end the scene.
function Encounter:win() end

--- Marks the battle as a loss for [battle_results](https://docs.hubos.dev/server/lua-api/events#battle_results).
---
--- Additionally [ends the battle](https://docs.hubos.dev/client/lua-api/field-api/encounter#encounteron_battle_endfunctionwon), does not end the scene.
function Encounter:lose() end

--- Signals the end of the scene, allowing the player to return to a server or previous menu.
---
--- Additionally [ends the battle](https://docs.hubos.dev/client/lua-api/field-api/encounter#encounteron_battle_endfunctionwon)
function Encounter:end_scene() end

--- Adds a listener for the battle end to handle results.
---@param callback fun(won: boolean)
function Encounter:on_battle_end(callback) end

--- Sends a message to the server that initiated this battle, which can be accessed on the server in the [battle_message](https://docs.hubos.dev/server/lua-api/events#battle_message) event.
---@param data any
function Encounter:send_to_server(data) end

--- Receives a message sent from the server by [Net.send_battle_message()](https://docs.hubos.dev/server/lua-api/players#netsend_battle_messagebattle_id-encounter_data).
---@param callback fun(data: any)
function Encounter:on_server_message(callback) end

--- Spawns the character at this position.
---
--- The tile at this position decides facing direction and team.
---
--- Returns a [Mutator](https://docs.hubos.dev/client/lua-api/field-api/encounter#mutator)
---@param col number
---@param row number
---@return Mutator
function Spawner:spawn_at(col, row) end

--- - `entity`: [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity)
---@param callback fun(entity: Entity)
function Mutator:mutate(callback) end

--- Deprecated. Use [Field](https://docs.hubos.dev/client/lua-api/field-api/field) directly.
function CustomTileState:field() end

--- - `entity`: the [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) to tie the action to.
--- - `state`: string, the animation state to play when the action executes.
---
--- Returns a new Action.
---@param entity Entity
---@param state? string
---@return Action
function Action.new(entity, state) end

--- - `entity`: the [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) to tie the action to.
--- - `card_properties`: [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties)
---
--- Returns Action or `nil`
---@param entity Entity
---@param card_properties CardProperties
---@return Action|nil
function Action.from_card(entity, card_properties) end

--- Returns the [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity) tied to this action
---@return Entity
function Action:owner() end

--- - `lockout`: [ActionLockout](https://docs.hubos.dev/client/lua-api/attack-api/action#actionlockout)
---@param lockout ActionLockout
function Action:set_lockout(lockout) end

--- By default, actions prevent entities from creating tile reservations on movement.
---
--- Calling this function with `true` or `nil` will allow the action's owner to reserve entered tiles and unreserve left tiles.
--- This only matters for entities that automatically reserve tiles by default, such as Characters and Obstacles.
---@param bool? boolean
function Action:allow_auto_tile_reservation(bool) end

--- Returns a new [ActionStep](https://docs.hubos.dev/client/lua-api/attack-api/action#actionstep)
---@return ActionStep
function Action:create_step() end

--- - `point_name`: string, name of a point in the animation to anchor the attachment to
---
--- Returns [Attachment](https://docs.hubos.dev/client/lua-api/attack-api/action#attachment)
---@param point_name string
---@return Attachment
function Action:create_attachment(point_name) end

--- See [animation:set_state()](https://docs.hubos.dev/client/lua-api/resource-api/animation#animationset_statestate-frame_data)
---@param frame_data [number, number][]
function Action:override_animation_frames(frame_data) end

--- Same as calling `action:owner():animation():on_frame(frame_index, callback)` within [action.on_execute_func](https://docs.hubos.dev/client/lua-api/attack-api/action#actionon_execute_func--functionself-owner)
---@param frame_index number
---@param callback fun()
function Action:on_anim_frame(frame_index, callback) end

--- Adds a callback to run before [action.on_action_end_func](https://docs.hubos.dev/client/lua-api/attack-api/action#actionon_action_end_func--functionself)
---@param callback fun()
function Action:on_end(callback) end

--- Calls [action.on_action_end_func](https://docs.hubos.dev/client/lua-api/attack-api/action#actionon_action_end_func--functionself)
---
--- Stops execution and deletes the action.
function Action:end_action() end

--- Returns a copy of the action's card properties.
---
--- Experimental. Replacement / removal is under consideration.
---@return CardProperties
function Action:copy_card_properties() end

--- - `card_properties`: [CardProperties](https://docs.hubos.dev/client/lua-api/attack-api/cards#cardproperties)
---
--- Sets the the action's card properties, will be overwritten when queued if the action is tied to a card.
---
--- Experimental. Replacement / removal is under consideration.
---@param card_properties CardProperties
function Action:set_card_properties(card_properties) end

--- - `point_name`: string, name of a point in this attachment's animation to anchor the new attachment to
---
--- Returns an Attachment
---@param point_name string
---@return Attachment
function Attachment:create_attachment(point_name) end

--- Returns a reference to the attachment's [Sprite](https://docs.hubos.dev/client/lua-api/resource-api/sprite)
---@return Sprite
function Attachment:sprite() end

--- Returns a reference to the attachment's [Animation](https://docs.hubos.dev/client/lua-api/resource-api/animation)
---@return Animation
function Attachment:animation() end

--- Returns ActionLockout.
---
--- Action completes when the animation ends.
---@return ActionLockout
function ActionLockout.new_animation() end

--- Returns ActionLockout.
---
--- Action completes when the action runs out of [ActionSteps](https://docs.hubos.dev/client/lua-api/attack-api/action#actionstep) to execute
---@return ActionLockout
function ActionLockout.new_sequence() end

--- Returns ActionLockout.
---
--- When the animation ends, entities regain movement control. Attacks must wait for the duration to end.
---@param duration number
---@return ActionLockout
function ActionLockout.new_async(duration) end

--- Marks the step as complete.
function ActionStep:complete_step() end

--- - `player`: [Player](https://docs.hubos.dev/client/lua-api/entity-api/player)
--- - `charged`: bool, affects hit artifact
--- - `damage`: number
---
--- Returns a new Action
---@param player Entity
---@param charged boolean
---@param damage number
---@return Action
function Buster.new(player, charged, damage) end

--- - `damage`: integer
--- - `flags`: See [flags](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
--- - `secondary_element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
--- - `context`: An [AttackContext](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#attackcontext) (obtained by [entity:context()](https://docs.hubos.dev/client/lua-api/entity-api/entity#entitycontext))
--- - `drag`: [Drag](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#drag) defaults to Drag.None
---
--- Returns a new HitProps instance.
---@param damage number
---@param flags Hit | number
---@param element Element
---@param secondary_element Element
---@param context? AttackContext
---@param drag? Drag
---@return HitProps
---@diagnostic disable-next-line: duplicate-set-field
function HitProps.new(damage, flags, element, secondary_element, context, drag) end

--- Returns a new HitProps instance.
---@param damage number
---@param flags Hit | number
---@param element Element
---@param context? AttackContext
---@param drag? Drag
---@return HitProps
---@diagnostic disable-next-line: duplicate-set-field
function HitProps.new(damage, flags, element, context, drag) end

--- Returns a new HitProps instance.
---@param card_properties CardProperties
---@param context? AttackContext
---@param drag? Drag
---@return HitProps
function HitProps.from_card(card_properties, context, drag) end

--- -`level`: Starts at level 1, clamps to valid (defined) duration levels.
--- Durations are specified in [Status Packages](https://docs.hubos.dev/client/packages#statuses)
---
--- Returns the duration in frames for a status effect at a specific level, or `1` if no durations are specified.
---@param hit_flag Hit
---@param level number
---@return number
function Hit.duration_for(hit_flag, level) end

--- Returns a number, representing all of the mutually exclusive hit flags for bit manipulation.
---@param hit_flag Hit
---@return number
function Hit.mutual_exclusions_for(hit_flag) end

--- Returns a number, representing all of the hit flags of statuses that have `blocks_actions` set to true.
---@return number
function Hit.action_blockers() end

--- Returns a number, representing all of the hit flags of statuses that have `blocks_mobility` set to true.
---@return number
function Hit.mobility_blockers() end

--- Returns true if `element_a` is weak to `element_b`.
---@param element_a Element
---@param element_b Element
---@return boolean
function Element.is_weak_to(element_a, element_b) end

--- Returns a new Drag instance.
---@param direction? Direction
---@param distance? number
---@return Drag
function Drag.new(direction, distance) end

--- Returns a new CardProperties table with default values.
---@return CardProperties
function CardProperties.new() end

--- Returns a new CardProperties table using package information.
---@param package_id string
---@param code? string
---@return CardProperties
function CardProperties.from_package(package_id, code) end

--- Returns a string, usable anywhere a texture is needed.
---@param card_properties CardProperties
---@return string
function CardProperties.icon_texture(card_properties) end

--- Returns a number, representing the resolved damage.
---@param card_properties CardProperties
---@param entity Entity
---@return number
function CardProperties.resolve_damage(card_properties, entity) end

--- Returns an [Entity](https://docs.hubos.dev/client/lua-api/entity-api/entity), represents the entity affected by the status.
---@return Entity
function Status:owner() end

--- Returns true if the status is being reapplied from a time freeze action ending.
---@return boolean
function Status:reapplied() end

--- Returns a number representing the amount of battle frames until the status wears off.
---@return number
function Status:remaining_time() end

--- - `duration` number, how many battle frames the effect should last.
---@param duration number
function Status:set_remaining_time(duration) end

--- Returns true if the turn gauge is visible, automatically progressing, and allows the turn to end.
---@return boolean
function TurnGauge.enabled() end

--- Hides the turn gauge, disables automatic progression, and prevents the turn from ending when disabled.
---@param enabled boolean
function TurnGauge.set_enabled(enabled) end

--- Returns true if time is frozen from [time freeze](https://docs.hubos.dev/client/lua-api/attack-api/cards#card_propertiestime_freeze) [Actions](https://docs.hubos.dev/client/lua-api/attack-api/action).
---@return boolean
function TurnGauge.frozen() end

--- Returns a number representing the turn gauge's progress as a value between 0 and 1.
---
--- Same as `TurnGauge.time() / TurnGauge.max_time()`
---@return number
function TurnGauge.progress() end

--- Returns a number representing the turn gauge's progress in elapsed frames.
---@return number
function TurnGauge.time() end

--- Returns a number representing the total elapsed frames required to end a turn.
---@return number
function TurnGauge.max_time() end

--- Sets the turn gauge's progress in elapsed frames.
---@param time number
function TurnGauge.set_time(time) end

--- Sets the total elapsed frames required to end a turn.
---@param time number
function TurnGauge.set_max_time(time) end

--- Sets the total elapsed frames required to end a turn to the default (512).
function TurnGauge.reset_max_time() end

--- Returns a number, represents the current turn number. Starts at 0 during the intro, increments when Card Select opens.
---@return number
function TurnGauge.current_turn() end

--- Ends the turn, causing Card Select to appear.
function TurnGauge.complete_turn() end

--- Returns a number or nil, modified through [encounter:set_turn_limit()](https://docs.hubos.dev/client/lua-api/field-api/encounter#encounterset_turn_limitlimit).
---@return number
function TurnGauge.turn_limit() end

--- - `priority`
---   - `DefensePriority.Barrier`
---   - `DefensePriority.Action`
---   - `DefensePriority.Body`
---   - `DefensePriority.Trap`
---     - Additionally causes all players to see `????` in the UI
---   - `DefensePriority.Last`
--- - `defense_order`
---   - `DefenseOrder.Always`
---   - `DefenseOrder.CollisionOnly`
---
--- Adding a DefenseRule to an entity when a DefenseRule already exists with the same priorty will replace the existing rule.
---
--- Returns a new DefenseRule.
---@param defense_priority DefensePriority
---@param defense_order DefenseOrder
---@return DefenseRule
function DefenseRule.new(defense_priority, defense_order) end

--- Returns true if a DefenseRule with the same priority replaced this rule.
---@return boolean
function DefenseRule:replaced() end

--- Prevents damage and statuses from applying to the defending entity.
function Defense:block_damage() end

--- Returns true if `defense:block_damage()` was called.
---@return boolean
function Defense:damage_blocked() end

--- Used to track if the defense retaliated against a hit, such spawning an attack in Reflect / Shields.
function Defense:set_responded() end

--- Returns true if `defense:set_responded()` was called for this hit.
---
--- Used to track if the defense retaliated against a hit, such spawning an attack in Reflect / Shields.
---@return boolean
function Defense:responded() end

--- Returns a new IntangibleRule.
---@return IntangibleRule
function IntangibleRule.new() end

--- Returns a new AuxProp. Attach to an entity with [living:add_aux_prop()](https://docs.hubos.dev/client/lua-api/entity-api/living#livingadd_aux_propaux_prop) and remove with [living:remove_aux_prop()](https://docs.hubos.dev/client/lua-api/entity-api/living#livingremove_aux_propaux_prop)
---
--- All AuxProp methods return the AuxProp for chaining.
---@return AuxProp
function AuxProp.new() end

--- Allows the AuxProp to auto remove after it's effects are first applied.
---@return AuxProp
function AuxProp:once() end

--- Allows the AuxProp to auto remove after a single test run, approximately a single battle frame.
---@return AuxProp
function AuxProp:immediate() end

--- Allows the AuxProp to auto remove after it's effects are have been applied `limit` times.
---@param limit number
---@return AuxProp
function AuxProp:limit(limit) end

--- Allows the AuxProp to auto remove after `limit` test runs, approximately `limit` battle frames.
---@param limit number
---@return AuxProp
function AuxProp:limit_frames(limit) end

--- The callback will be called shortly after the AuxProp's effect is applied. Multiple callbacks can be added to a single AuxProp.
---@param callback fun()
---@return AuxProp
function AuxProp:with_callback(callback) end

--- - Interval priority
--- - `chance`: number, 1 is 100%, 0 is 0%.
---
--- The AuxProp will be given a random chance to pass.
---
--- ```lua
--- -- one in five chance on hit to paralyze:
--- player:add_aux_prop(
---   AuxProp.new()
---   :require_chance(1 / 5) -- 1 in 5 chance
---   :require_hit_damage(Compare.GT, 0) -- on hit
---   :apply_status(Hit.Paralyze, 20)
--- )
---
--- -- 20% chance on hit to freeze:
--- player:add_aux_prop(
---   AuxProp.new()
---   :require_chance(0.2)
---   :require_hit_damage(Compare.GT, 0)
---   :apply_status(Hit.Freeze, 20)
--- )
--- ```
---@param chance number
---@return AuxProp
function AuxProp:require_chance(chance) end

--- - Interval priority
--- - `frames`: number
---
--- The AuxProp can pass if `battle_frame_time % frames == 0`
---
--- In the future the AuxProp will store an internal timer that starts as soon as it is attached, increments every battle frame, passing the test on the first frame and at each interval.
---@param frames number
---@return AuxProp
function AuxProp:require_interval(frames) end

--- - Hit priority
--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- The AuxProp will check the incoming hit's element and secondary element of incoming hits for a match.
---@param element Element
---@return AuxProp
function AuxProp:require_hit_element(element) end

--- - Hit priority
---
--- The AuxProp will check the incoming hit's element and secondary element to see if the attached entity's element is weak to either element.
---@return AuxProp
function AuxProp:require_hit_element_is_weakness() end

--- - Hit priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- The AuxProp will check the incoming hit's [flags](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags) to see if all matching flags apply.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:require_hit_flags(hit_flags) end

--- - Hit priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- The AuxProp will check the incoming hit's [flags](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags) to verify no flags match.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:require_hit_flags_absent(hit_flags) end

--- - Hit priority
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `damage`: number
---
--- The AuxProp will check the incoming hit's [damage](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsdamage).
---@param compare Compare
---@param damage number
---@return AuxProp
function AuxProp:require_hit_damage(compare, damage) end

--- - Hit priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the damage value for the current hit.
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `damage`: number
---
--- The AuxProp will check the incoming hit's [damage](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsdamage).
---@param expr string
---@param compare Compare
---@param damage number
---@return AuxProp
function AuxProp:require_projected_hit_damage(expr, compare, damage) end

--- - Hit priority
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `damage`: number
---
--- The AuxProp will check the total incoming damage from all hits in the current frame.
---@param compare Compare
---@param damage number
---@return AuxProp
function AuxProp:require_total_damage(compare, damage) end

--- - Body priority
--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- The AuxProp will check the attached entity for matching element.
---@param element Element
---@return AuxProp
function AuxProp:require_element(element) end

--- - Body priority
---
--- The AuxProp will check `entity:ignoring_negative_tile_effects() == false`.
---@return AuxProp
function AuxProp:require_negative_tile_interaction() end

--- - Body priority
---
--- The AuxProp will check the tile state of the tile under the entity.
---@param tile_state TileState
---@return AuxProp
function AuxProp:require_tile_state(tile_state) end

--- - Body priority
---
--- The AuxProp will check the tile state of the tile under the entity.
---@param tile_state TileState
---@return AuxProp
function AuxProp:require_tile_state_absent(tile_state) end

--- - Body Priority
---
--- Applies when a new `entity:context()` has started.
---@return AuxProp
function AuxProp:require_context_start() end

--- - Body Priority
--- - `action_types`
---   - `ActionType.All`: All attack types.
---   - `ActionType.Normal`: A player's normal attack.
---   - `ActionType.Charged`: A player's charged attack.
---   - `ActionType.Special`: A player's special attack.
---   - `ActionType.Card`: An attack generated by a card.
---   - `ActionType.Scripted`: A scripted attack.
---
--- If the effect is Modify Context, the `action_types` filter will be tested against the generated action.
--- Otherwise the filter will be tested against any active action on the associated entity.
---@param action_types? number
---@return AuxProp
function AuxProp:require_action(action_types) end

--- - Body priority
--- - `emotion`: string
---
--- The AuxProp will check the attached entity for matching emotion.
---@param emotion string
---@return AuxProp
function AuxProp:require_emotion(emotion) end

--- - Body priority
---
--- The AuxProp will check the attached entity for a defense rule with a matching priority.
---@param defense_priority DefensePriority
---@return AuxProp
function AuxProp:require_defense(defense_priority) end

--- - Body priority
---
--- The AuxProp will check the attached entity for a defense rule with a matching priority.
---@param defense_priority DefensePriority
---@return AuxProp
function AuxProp:require_defense_absent(defense_priority) end

--- - Body priority
---
--- The AuxProp will check a [Player](https://docs.hubos.dev/client/lua-api/entity-api/player)'s held attack charge time against the provided time, the player's charge time will be capped at their max charge time.
---@param compare Compare
---@param time number
---@return AuxProp
function AuxProp:require_charge_time(compare, time) end

--- - Body priority
---
--- The AuxProp will check a [Player](https://docs.hubos.dev/client/lua-api/entity-api/player)'s held card charge time against the provided time, the player's charge time will be capped at their max charge time.
---@param compare Compare
---@param time number
---@return AuxProp
function AuxProp:require_card_charge_time(compare, time) end

--- - Body priority
---
--- The AuxProp will require a [Player](https://docs.hubos.dev/client/lua-api/entity-api/player) to be holding a fully [charged](https://docs.hubos.dev/client/lua-api/entity-api/player#playercalculate_card_charge_time_func--functionself-card_properties-numbernil) card.
---@return AuxProp
function AuxProp:require_charged_card() end

--- - Body priority
--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- The AuxProp will check the primary element on the next card for the attached entity.
---@param element Element
---@return AuxProp
function AuxProp:require_card_primary_element(element) end

--- - Body priority
--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- The AuxProp will check the next card on the attached entity for a failed match with the primary element.
---@param element Element
---@return AuxProp
function AuxProp:require_card_not_primary_element(element) end

--- - Body priority
--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- The AuxProp will check the next card on the attached entity for either matching element or secondary element.
---@param element Element
---@return AuxProp
function AuxProp:require_card_element(element) end

--- - Body priority
--- - `element`: [Element](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#element)
---
--- The AuxProp will check the next card on the attached entity for a failed match with both element and secondary element.
---@param element Element
---@return AuxProp
function AuxProp:require_card_not_element(element) end

--- - Body priority
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `damage`: number
---
--- The AuxProp will compare the damage on the next card on the attached entity against the `damage` value.
---@param compare Compare
---@param damage number
---@return AuxProp
function AuxProp:require_card_damage(compare, damage) end

--- - Body priority
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `recover`: number
---
--- The AuxProp will compare the recover amount on the next card on the attached entity against the `recover` value.
---@param compare Compare
---@param recover number
---@return AuxProp
function AuxProp:require_card_recover(compare, recover) end

--- - Body priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- The AuxProp will check the next card on the attached entity for matching hit flags.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:require_card_hit_flags(hit_flags) end

--- - Hit priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- The AuxProp will check the next card on the attached entity to verify no flags match.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:require_card_hit_flags_absent(hit_flags) end

--- - Body priority
--- - `code`: string
---
--- The AuxProp will check the next card on the attached entity for matching code.
---@param code string
---@return AuxProp
function AuxProp:require_card_code(code) end

--- - Body priority
--- - `card_class`: [CardClass](https://docs.hubos.dev/client/lua-api/attack-api/cards#card_propertiescard_class)
---
--- The AuxProp will check the next card on the attached entity for matching class.
---@param card_class CardClass
---@return AuxProp
function AuxProp:require_card_class(card_class) end

--- - Body priority
--- - `card_class`: [CardClass](https://docs.hubos.dev/client/lua-api/attack-api/cards#card_propertiescard_class)
---
--- The AuxProp will check the next card on the attached entity for a non-matching class.
---@param card_class CardClass
---@return AuxProp
function AuxProp:require_card_not_class(card_class) end

--- - Body priority
--- - `time_freeze`: bool
---
--- The AuxProp will check the time freeze value on the next card on the attached entity.
---@param time_freeze boolean
---@return AuxProp
function AuxProp:require_card_time_freeze(time_freeze) end

--- - Body priority
--- - `tag`: string
---
--- The AuxProp will check the next card on the attached entity for matching tag.
---@param tag string
---@return AuxProp
function AuxProp:require_card_tag(tag) end

--- - Body priority
--- - `tag`: string
---
--- The AuxProp will check the next card on the attached entity for matching tag.
---@param tag string
---@return AuxProp
function AuxProp:require_card_not_tag(tag) end

--- - Body priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- The AuxProp will check active status [flags](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags) to see if all matching flags apply.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:require_statuses(hit_flags) end

--- - Body priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- The AuxProp will check active status [flags](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags) to verify no flags match.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:require_statuses_absent(hit_flags) end

--- - HP Expression priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the total damage value for all incoming hits.
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `percentage`: a number in range [0, 1]
---
--- The AuxProp will compare the result of the expression divided by the entity's max_health against `percentage`.
---@param expr string
---@param compare Compare
---@param percentage number
---@return AuxProp
function AuxProp:require_projected_health_threshold(expr, compare, percentage) end

--- - HP Expression priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the total damage value for all incoming hits.
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `health`: a number
---
--- The AuxProp will compare the result of the expression against `health`.
---@param expr string
---@param compare Compare
---@param health number
---@return AuxProp
function AuxProp:require_projected_health(expr, compare, health) end

--- - HP GE or HP LE priority depending on `compare`
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `percentage`: a number in range [0, 1]
---
--- The AuxProp will compare the entity's health divided by it's max health against `percentage`.
---@param compare Compare
---@param percentage number
---@return AuxProp
function AuxProp:require_health_threshold(compare, percentage) end

--- - HP GE or HP LE priority depending on `compare`
--- - `compare`: [Compare](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#compare)
--- - `health`: a number
---
--- The AuxProp will compare the entity's health against `health`.
---@param compare Compare
---@param health number
---@return AuxProp
function AuxProp:require_health(compare, health) end

--- - Intercept Card priority
---
--- Intercepts a field card before it turns into an action. Field cards can be queued with [character:use_card()](https://docs.hubos.dev/client/lua-api/entity-api/character#characteruse_card).
---@param callback fun(card_properties: CardProperties): CardProperties|nil
---@return AuxProp
function AuxProp:intercept_card(callback) end

--- - Increase Card Damage priority
--- - `increase`: number, the amount to increase the card damage before multiplying.
---@param increase number
---@return AuxProp
function AuxProp:increase_card_damage(increase) end

--- - Increase Card Multiplier priority
--- - `increase`: number, the amount to increase the multiplier by.
---@param increase number
---@return AuxProp
function AuxProp:increase_card_multiplier(increase) end

--- - Update Context priority
---
--- Allows for modification to the context on the associated entity, executes before actions are generated for cards and attacks.
---@param callback fun(context: AttackContext): AttackContext
---@return AuxProp
function AuxProp:update_context(callback) end

--- - Intercept Action priority
---
--- Intercepts an Action moving off the action queue for execution. Returning a different Action or nil in the callback will cancel and delete the Action. `aux_prop:require_card_*` will refer to properties on the Action.
---@param callback fun(action: Action): Action|nil
---@return AuxProp
function AuxProp:intercept_action(callback) end

--- - Interrupt Action priority
---
--- Interrupts an Action that is about to execute or has executed. The Action will be deleted after the callback finishes.
--- `aux_prop:require_card_*` will refer to properties on the Action.
---@param callback fun(action: Action)
---@return AuxProp
function AuxProp:interrupt_action(callback) end

--- - Increase Pre Hit Damage priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the damage value for the current hit before any modifications.
---
--- The result of `expr` will be added to the total incoming damage.
---
--- If the result is negative, it will be clamped to 0.
---@param expr string
---@return AuxProp
function AuxProp:increase_pre_hit_damage(expr) end

--- - Decrease Pre Hit Damage priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the damage value for the current hit before any modifications.
---
--- The result of `expr` will be added to the total incoming damage.
---
--- If the result is negative, it will be clamped to 0.
---@param expr string
---@return AuxProp
function AuxProp:decrease_pre_hit_damage(expr) end

--- - Status Immunity priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- Declares immunity for incoming hits this frame, will not remove existing statuses.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:declare_immunity(hit_flags) end

--- - Apply Status priority
--- - `hit_flag`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
--- - `duration`: number, how many game frames the effect should last
---
--- Applies a status to the entity.
---@param hit_flag Hit
---@param duration number
---@return AuxProp
function AuxProp:apply_status(hit_flag, duration) end

--- - Remove Status priority
--- - `hit_flags`: [Hit](https://docs.hubos.dev/client/lua-api/attack-api/hit-props#hit_propsflags)
---
--- Removes one or more statuses from the entity, won't affect incoming hits.
---@param hit_flags Hit | number
---@return AuxProp
function AuxProp:remove_status(hit_flags) end

--- - Increase Hit Damage priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the damage value for the current hit before any modifications.
---
--- The result of `expr` will be added to the total incoming damage.
---
--- If the result is negative, it will be clamped to 0.
---@param expr string
---@return AuxProp
function AuxProp:increase_hit_damage(expr) end

--- - Decrease Hit Damage priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the damage value for the current hit before any modifications.
---
--- The result of `expr` will be subtracted from the total incoming damage.
---
--- If the result is negative, it will be clamped to 0.
---
--- Note: To entirely negate damage a defense rule must be used.
---@param expr string
---@return AuxProp
function AuxProp:decrease_hit_damage(expr) end

--- - Decrease Damage Total priority
--- - `expr`: [Math Expression String](https://docs.hubos.dev/client/lua-api/defense-api/aux-prop#math-expression-strings), `"DAMAGE"` will represent the total damage value for all incoming hits.
---
--- The result of `expr` will be subtracted from the total incoming damage.
---
--- If the total damage was previously not zero the final total damage will have a minimum value of 1.
---@param expr string
---@return AuxProp
function AuxProp:decrease_total_damage(expr) end

--- - Drain Health priority
--- - `health`: the amount of health to take away
---@param health number
---@return AuxProp
function AuxProp:drain_health(health) end

--- - Recover Health priority
--- - `health`: the amount of health to restore
---@param health number
---@return AuxProp
function AuxProp:recover_health(health) end

--- Returns an AuxProp that provides `Hit.Flash` immunity.
---@return AuxProp
function StandardEnemyAux.new() end
