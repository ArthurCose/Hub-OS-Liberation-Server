local Preloader = {}

local path_list = {}
local preloaded = {}

function Preloader.add_asset(asset_path)
  if preloaded[asset_path] then
    return asset_path
  end

  preloaded[asset_path] = true
  path_list[#path_list + 1] = asset_path

  return asset_path
end

function Preloader.update(area_id)
  for _, asset_path in ipairs(path_list) do
    Net.provide_asset(area_id, asset_path)
  end
end

return Preloader
