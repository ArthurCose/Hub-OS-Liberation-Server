local ModDownloader = require("scripts/libs/mod_downloader")

local package_ids = {
  -- bosses
  "BattleNetwork5.BlizzardMan",
  "BattleNetwork5.Virus.BigBrute",
  -- viruses
  -- libraries
  "BattleNetwork.Assets",
  "BattleNetwork.FallingRock",
  "dev.konstinople.library.ai",
  "dev.konstinople.library.iterator",
  "BattleNetwork6.TileStates.Ice",
  -- minimal libraries necessary for liberations:
  "dev.konstinople.library.liberation",
  "BattleNetwork6.Statuses.Invincible",
}

ModDownloader.maintain(package_ids)

Net:on("player_connect", function(event)
  -- preload mods on join
  for _, package_id in ipairs(package_ids) do
    Net.provide_package_for_player(event.player_id, ModDownloader.resolve_asset_path(package_id))
  end
end)
