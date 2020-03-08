local EC = EC and EC or {}
local paramcheck = function(_x)
  if _x and type(_x) ~= "number" then
    error(debug.traceback("Vector2Check", 2))
  end
end
EC.Vector2 = {
  new = function(_x, _y)
    local ret = {
      x = _x and _x or 0,
      y = _y and _y or 0
    }
    setmetatable(ret, EC.Vector2)
    return ret
  end,
  __add = function(lhs, rhs)
    local ret = {
      x = lhs.x + rhs.x,
      y = lhs.y + rhs.y
    }
    setmetatable(ret, EC.Vector2)
    return ret
  end,
  __sub = function(lhs, rhs)
    local ret = {
      x = lhs.x - rhs.x,
      y = lhs.y - rhs.y
    }
    setmetatable(ret, EC.Vector2)
    return ret
  end,
  __mul = function(self, factor)
    local ret = {
      x = self.x * factor,
      y = self.y * factor
    }
    setmetatable(ret, EC.Vector2)
    return ret
  end,
  __div = function(self, factor)
    return EC.Vector2.__mul(self, 1 / factor)
  end,
  __unm = function(self)
    local ret = {
      x = -self.x,
      y = -self.y
    }
    setmetatable(ret, EC.Vector2)
    return ret
  end,
  __eq = function(lhs, rhs)
    if math.abs(lhs.x - rhs.x) > 1.0E-6 then
      return false
    end
    if 1.0E-6 < math.abs(lhs.y - rhs.y) then
      return false
    end
    return true
  end,
  __tostring = function(self)
    local s = string.format("Vector2: %.6f, %.6f", self.x, self.y)
    return s
  end,
  get_Length = function(self)
    local len = math.sqrt(self.x * self.x + self.y * self.y)
    return len
  end,
  Normalize = function(self)
    local len = EC.Vector2.get_Length(self)
    if len < 1.0E-6 then
      self.x = 1
      self.y = 0
    else
      self.x = self.x / len
      self.y = self.y / len
    end
  end,
  Dot = function(lhs, rhs)
    local ret = lhs.x * rhs.x + lhs.y * rhs.y
    return ret
  end
}
function EC.Vector2.__index(t, k)
  local mt = getmetatable(t)
  local v = mt[k]
  if v then
    return v
  end
  v = mt["get_" .. k]
  if v then
    return v(t)
  end
  return nil
end
EC.Vector2.zero = EC.Vector2.new(0, 0)
EC.Vector2.one = EC.Vector2.new(1, 1)
EC.Vector2.right = EC.Vector2.new(1, 0)
EC.Vector2.up = EC.Vector2.new(0, 1)
_G._Vector2Ctor_ = EC.Vector2.new
return EC
