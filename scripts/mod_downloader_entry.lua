local ModDownloader = require("scripts/libs/mod_downloader")

local package_ids = {
  -- bosses
  "BattleNetwork5.BlizzardMan",
  "BattleNetwork5.ShadeMan",
  "BattleNetwork5.Virus.BigBrute",
  "BattleNetwork5.TinHawk",
  -- viruses
  "BattleNetwork6.Swordy",
  "BattleNetwork6.Mettaur",
  "BattleNetwork5.Cactikil",
  "BattleNetwork3.Virus.Boomer",
  "BattleNetwork5.Batty",
  "BattleNetwork5.Bugtank",
  "BattleNetwork5.Drixol",
  "BattleNetwork5.Draggin",
  "BattleNetwork5.Whirly",
  "BattleNetwork3.Virus.KillerEye",
  -- "BattleNetwork5.Powie",
  -- libraries
  "BattleNetwork.Assets",
  "BattleNetwork.FallingRock",
  "dev.konstinople.library.ai",
  "dev.konstinople.library.iterator",
  "dev.konstinople.library.turn_based",
  "BattleNetwork6.TileStates.Ice",
  "BattleNetwork6.TileStates.Poison",
  "BattleNetwork3.TileStates.Sand",
  "BattleNetwork6.Statuses.Uninstall",
  "BattleNetwork6.Libraries.CubesAndBoulders",
  "dev.konstinople.library.sliding_obstacle",
  -- Grab Revenge
  "BattleNetwork6.Class01.Standard.167",
  "BattleNetwork6.Libraries.PanelGrab",
  -- minimal libraries necessary for liberations:
  "dev.konstinople.library.liberation",
  "BattleNetwork6.Statuses.Invincible",
}

ModDownloader.maintain(package_ids)

Net:on("player_connect", function(event)
  -- apply restrictions
  Net.set_player_restrictions(event.player_id, "/server/assets/restrictions.toml")

  -- preload mods on join
  for _, package_id in ipairs(package_ids) do
    Net.provide_package_for_player(event.player_id, ModDownloader.resolve_asset_path(package_id))
  end
end)
