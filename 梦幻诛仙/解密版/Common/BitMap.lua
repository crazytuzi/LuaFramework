local BitMap = {}
local INTBITS = 5
local MASk = bit.lshift(1, INTBITS) - 1
local _set = function(data, k, v)
  local old = data[k] or 0
  local value = bit.lshift(1, v)
  data[k] = bit.bor(old, value)
end
local _unset = function(data, k, v)
  local old = data[k] or 0
  local value = bit.lshift(1, v)
  data[k] = bit.band(old, bit.bnot(value))
end
local _check = function(data, k, v)
  local old = data[k] or 0
  local value = bit.lshift(1, v)
  return 0 < bit.band(old, value)
end
local function _kv(index)
  if index < 1 then
    error("BitMap index must be greater than 0")
  end
  local indexOffset = index - 1
  local key = bit.rshift(indexOffset, INTBITS) + 1
  local value = bit.band(indexOffset, MASk)
  return key, value
end
function BitMap.new()
  local bitMap = {}
  bitMap.data = {}
  function bitMap.Set(index)
    local k, v = _kv(index)
    _set(bitMap.data, k, v)
  end
  function bitMap.Unset(index)
    local k, v = _kv(index)
    _unset(bitMap.data, k, v)
  end
  function bitMap.Check(index)
    local k, v = _kv(index)
    return _check(bitMap.data, k, v)
  end
  return bitMap
end
function BitMap.ToString(bitMap)
  for k, v in pairs(bitMap.data) do
    local bitStr = {}
    for i = 31, 0, -1 do
      local a = bit.lshift(1, i)
      if bit.band(v, a) ~= 0 then
        table.insert(bitStr, "1")
      else
        table.insert(bitStr, "0")
      end
    end
    warn(k, v, table.concat(bitStr))
  end
end
function BitMap.Contains(lhsBitMap, rhsBitMap)
  for k, v in pairs(rhsBitMap.data) do
    local l = lhsBitMap.data[k]
    if l then
      local ret = bit.band(l, v)
      if ret > 0 then
        return true
      end
    end
  end
  return false
end
return BitMap
