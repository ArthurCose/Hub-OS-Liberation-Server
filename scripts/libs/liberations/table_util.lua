local Lib = {}

---@param t table?
function Lib.get(t, ...)
  local len = select("#", ...)

  for i = 1, len do
    if t == nil then
      return nil
    end

    local key = select(i, ...)
    t = t[key]
  end

  return t
end

---@param t table
function Lib.set(t, ...)
  local len = select("#", ...)

  for i = 1, len - 2 do
    local key = select(i, ...)
    local base = t

    t = base[key]

    if t == nil then
      t = {}
      base[key] = t
    end
  end

  local key = select(len - 1, ...)
  t[key] = select(len, ...)
end

return Lib
