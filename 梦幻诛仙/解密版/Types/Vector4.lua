local EC = EC and EC or {}
local paramcheck = function(_x)
  if _x and type(_x) ~= "number" then
    error(debug.traceback("EC.Vector4Check", 2))
  end
end
EC.Vector4 = {
  new = function(_x, _y, _z, _w)
    local ret = {
      x = _x and _x or 0,
      y = _y and _y or 0,
      z = _z and _z or 0,
      w = _w and _w or 0
    }
    setmetatable(ret, EC.Vector4)
    return ret
  end,
  __add = function(lhs, rhs)
    local ret = {
      x = lhs.x + rhs.x,
      y = lhs.y + rhs.y,
      z = lhs.z + rhs.z,
      w = lhs.w + rhs.w
    }
    setmetatable(ret, EC.Vector4)
    return ret
  end,
  __sub = function(lhs, rhs)
    local ret = {
      x = lhs.x - rhs.x,
      y = lhs.y - rhs.y,
      z = lhs.z - rhs.z,
      w = lhs.w - rhs.w
    }
    setmetatable(ret, EC.Vector4)
    return ret
  end,
  __mul = function(self, factor)
    local ret = {
      x = self.x * factor,
      y = self.y * factor,
      z = self.z * factor,
      w = self.w * factor
    }
    setmetatable(ret, EC.Vector4)
    return ret
  end,
  __div = function(self, factor)
    return EC.Vector4.__mul(self, 1 / factor)
  end,
  __unm = function(self)
    local ret = {
      x = -self.x,
      y = -self.y,
      z = -self.z,
      w = -self.w
    }
    setmetatable(ret, EC.Vector4)
    return ret
  end,
  __eq = function(lhs, rhs)
    if math.abs(lhs.x - rhs.x) > 1.0E-6 then
      return false
    end
    if 1.0E-6 < math.abs(lhs.y - rhs.y) then
      return false
    end
    if 1.0E-6 < math.abs(lhs.z - rhs.z) then
      return false
    end
    if 1.0E-6 < math.abs(lhs.w - rhs.w) then
      return false
    end
    return true
  end,
  __tostring = function(self)
    local s = string.format("EC.Vector4: %.6f, %.6f, %.6f, %.6f", self.x, self.y, self.z, self.w)
    return s
  end,
  get_Length = function(self)
    local len = math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z, self.w * self.w)
    return len
  end,
  Normalize = function(self)
    local len = EC.Vector4.get_Length(self)
    if len < 1.0E-6 then
      self.x = 0
      self.y = 0
      self.z = 1
      self.w = 0
    else
      self.x = self.x / len
      self.y = self.y / len
      self.z = self.z / len
      self.w = self.w / len
    end
  end,
  Dot = function(lhs, rhs)
    local ret = lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z + lhs.w * rhs.w
    return ret
  end,
  ToVector2 = function(self)
    return EC.Vector2.new(self.x, self.y)
  end,
  ToVector3 = function(self)
    return EC.Vector3.new(self.x, self.y, self.z)
  end
}
function EC.Vector4.__index(t, k)
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
EC.Vector4.zero = EC.Vector4.new(0, 0, 0, 0)
EC.Vector4.one = EC.Vector4.new(1, 1, 1, 1)
_G._Vector4Ctor_ = EC.Vector4.new
return EC
