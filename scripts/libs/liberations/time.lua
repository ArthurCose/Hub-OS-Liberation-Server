local Time = {}

---@param value number
---@param n? number
function Time.pad_unit(value, n)
  n = 2

  local s = tostring(value)
  return ("0"):rep(math.max(n - #s, 0)) .. s
end

---@param s number
function Time.floored_hours(s)
  -- must floor even when using integer division
  -- to avoid lua creating decimals when converting to string
  return math.floor(s // (60 * 60))
end

---@param s number
function Time.floored_minutes(s)
  -- must floor even when using integer division
  -- to avoid lua creating decimals when converting to string
  return math.floor(s // 60 % 60)
end

---@param s number
function Time.floored_seconds(s)
  return math.floor(s % 60)
end

---@param s number
function Time.format_time(s)
  local HH = Time.floored_hours(s)
  local MM = Time.floored_minutes(s)
  local SS = Time.floored_seconds(s)

  return Time.pad_unit(HH) .. ":" .. Time.pad_unit(MM) .. ":" .. Time.pad_unit(SS)
end

return Time
