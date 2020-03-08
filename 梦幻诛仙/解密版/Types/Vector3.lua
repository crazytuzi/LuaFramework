local EC = EC and EC or {}
local paramcheck = function(_x)
  if _x and type(_x) ~= "number" then
    error(debug.traceback("Vector3Check", 2))
  end
end
EC.Vector3 = {
  new = function(_x, _y, _z)
    local ret = {
      x = _x and _x or 0,
      y = _y and _y or 0,
      z = _z and _z or 0
    }
    setmetatable(ret, EC.Vector3)
    return ret
  end,
  __add = function(lhs, rhs)
    local ret = {
      x = lhs.x + rhs.x,
      y = lhs.y + rhs.y,
      z = lhs.z + rhs.z
    }
    setmetatable(ret, EC.Vector3)
    return ret
  end,
  __sub = function(lhs, rhs)
    local ret = {
      x = lhs.x - rhs.x,
      y = lhs.y - rhs.y,
      z = lhs.z - rhs.z
    }
    setmetatable(ret, EC.Vector3)
    return ret
  end,
  __mul = function(lhs, factor)
    local ret = {
      x = lhs.x * factor,
      y = lhs.y * factor,
      z = lhs.z * factor
    }
    setmetatable(ret, EC.Vector3)
    return ret
  end,
  __div = function(lhs, div)
    return EC.Vector3.__mul(lhs, 1 / div)
  end,
  __unm = function(lhs)
    local ret = {
      x = -lhs.x,
      y = -lhs.y,
      z = -lhs.z
    }
    setmetatable(ret, EC.Vector3)
    return ret
  end,
  __len = function(lhs)
    local len = lhs.x * lhs.x + lhs.y * lhs.y + lhs.z * lhs.z
    return math.sqrt(len)
  end,
  __eq = function(lhs, rhs)
    if math.abs(lhs.x - rhs.x) > 0.001 then
      return false
    end
    if 0.001 < math.abs(lhs.y - rhs.y) then
      return false
    end
    if 0.001 < math.abs(lhs.z - rhs.z) then
      return false
    end
    return true
  end,
  __tostring = function(self)
    local s = string.format("EC.Vector3: %.6f,%.6f,%.6f", self.x, self.y, self.z)
    return s
  end,
  Dot = function(self, rhs)
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
  end,
  Set = function(self, _x, _y, _z)
    self.x = _x
    self.y = _y
    self.z = _z
  end,
  Assign = function(self, _x, _y, _z)
    self.x = _x
    self.y = _y
    self.z = _z
    return self
  end,
  Cross = function(self, rhs)
    return EC.Vector3.new(self.y * rhs.z - self.z * rhs.y, self.z * rhs.x - self.x * rhs.z, self.x * rhs.y - self.y * rhs.x)
  end,
  Normalize = function(self)
    local len = self.Length
    if len < 1.0E-6 then
      self.x = 0
      self.y = 0
      self.z = 1
    else
      f = 1 / len
      self.x = self.x * f
      self.y = self.y * f
      self.z = self.z * f
    end
  end,
  get_Length = function(self)
    local len = math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    return len
  end,
  Angle = function(self, rhs)
    local v = self:Dot(rhs)
    if v < -1 then
      v = -1
    end
    if v > 1 then
      v = 1
    end
    return math.acos(v) * 57.29578
  end,
  Lerp = function(v1, v2, t)
    if t <= 0 then
      return v1
    elseif t >= 1 then
      return v2
    else
      return v1 * t + v2 * (1 - t)
    end
  end,
  MulUnpack = function(self, factor)
    return self.x * factor, self.y * factor, self.z * factor
  end,
  AddUnpack = function(self, x, y, z)
    return self.x + x, self.y + y, self.z + z
  end,
  SubUnpack = function(self, x, y, z)
    return self.x - x, self.y - y, self.z - z
  end
}
function EC.Vector3.__index(t, k)
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
_G._Vector3Ctor_ = EC.Vector3.new
EC.Vector3.back = EC.Vector3.new(0, 0, -1)
EC.Vector3.down = EC.Vector3.new(0, -1, 0)
EC.Vector3.forward = EC.Vector3.new(0, 0, 1)
EC.Vector3.left = EC.Vector3.new(-1, 0, 0)
EC.Vector3.one = EC.Vector3.new(1, 1, 1)
EC.Vector3.right = EC.Vector3.new(1, 0, 0)
EC.Vector3.up = EC.Vector3.new(0, 1, 0)
EC.Vector3.zero = EC.Vector3.new(0, 0, 0)
return EC
