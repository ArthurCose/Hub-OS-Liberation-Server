local Preloader = {}

local asset_paths = {
  "/server/assets/liberations/bots/blur.png",
  "/server/assets/liberations/bots/blur.animation",
  "/server/assets/liberations/bots/explosion.png",
  "/server/assets/liberations/bots/explosion.animation",
  "/server/assets/liberations/bots/paralyze.png",
  "/server/assets/liberations/bots/paralyze.animation",
  "/server/assets/liberations/bots/recover.png",
  "/server/assets/liberations/bots/recover.animation",
  "/server/assets/liberations/bots/item.png",
  "/server/assets/liberations/bots/item.animation",
  "/server/assets/liberations/sound effects/hurt.ogg",
  "/server/assets/liberations/sound effects/explode.ogg",
  "/server/assets/liberations/sound effects/paralyze.ogg",
  "/server/assets/liberations/sound effects/recover.ogg",
  "/server/assets/liberations/ui/order_points.png",
  "/server/assets/liberations/ui/order_points.animation",
}

function Preloader.add_asset(asset_path)
  asset_paths[#asset_paths + 1] = asset_path
end

function Preloader.update(area_id)
  for _, asset_path in ipairs(asset_paths) do
    Net.provide_asset(area_id, asset_path)
  end
end

return Preloader
