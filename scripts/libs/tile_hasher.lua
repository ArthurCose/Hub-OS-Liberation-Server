---@class TileHasher
---@field w number
---@field h number
local TileHasher = {}
TileHasher.__index = TileHasher

function TileHasher:from_area(area_id)
  local w = Net.get_layer_width(area_id)
  local h = Net.get_layer_height(area_id)

  return self:new(w, h)
end

---@return TileHasher
function TileHasher:new(w, h)
  local hasher = {
    w = w,
    h = h,
  }

  setmetatable(hasher, TileHasher)

  return hasher
end

function TileHasher:hash(x, y, z)
  local w = self.w
  local h = self.h

  return (z * w * h) + (y * w) + x
end

function TileHasher:decode(hash)
  local w = self.w
  local h = self.h

  local z = hash // (w * h)
  hash = hash - z * w * h
  local y = hash // w
  hash = hash - y * w
  return hash, y, z
end

return TileHasher
