local EC = require("Types.Vector2")
local EC = EC and EC or {}
local paramcheck = function(_x)
  if _x and type(_x) ~= "number" then
    error(debug.traceback("Rect", 2))
  end
end
EC.Rect = {
  new = function(_x, _y, _width, _height)
    local ret = {
      x = _x,
      y = _y,
      width = _width,
      height = _height
    }
    setmetatable(ret, EC.Rect)
    return ret
  end,
  get_center = function(self)
    return EC.Vector2.new(self.x + self.width / 2, self.y + self.height / 2)
  end,
  set_center = function(self, center)
    local old_center = self:get_center()
    local delta = center - old_center
    self.x = self.x + delta.x
    self.y = self.y + delta.y
  end,
  get_max = function(self)
    return EC.Vector2.new(self.x + self.width, self.y + self.height)
  end,
  set_max = function(self, max)
    self.width = max.x - self.x
    self.height = max.y - self.y
  end,
  get_min = function(self)
    return EC.Vector2.new(self.x, self.y)
  end,
  set_min = function(self, min)
    local max = self:get_max()
    self.x = min.x
    self.y = min.y
    self.width = max.x - min.x
    self.height = max.y - min.y
  end,
  get_position = function(self)
    return self:get_min()
  end,
  set_position = function(self, pos)
    self:set_min(pos)
  end,
  get_size = function(self)
    return EC.Vector2.new(self.width, self.height)
  end,
  set_size = function(self, size)
    self.width = size.x
    self.height = size.y
  end,
  get_xMax = function(self)
    return self.x + self.width
  end,
  set_xMax = function(self, xMax)
    self.width = xMax - self.x
  end,
  get_xMin = function(self)
    return self.x
  end,
  set_xMin = function(self, xMin)
    local xMax = self:get_xMax()
    self.x = xMin
    self.width = xMax - xMin
  end,
  get_yMax = function(self)
    return self.y + self.height
  end,
  set_yMax = function(self, yMax)
    self.height = yMax - self.y
  end,
  get_yMin = function(self)
    return self.y
  end,
  set_yMin = function(self, yMin)
    local yMax = self:get_yMax()
    self.y = yMin
    self.height = yMax - yMin
  end,
  Set = function(self, x, y, w, h)
    self.x = x
    self.y = y
    self.width = w
    self.height = h
  end,
  __tostring = function(self)
    local s = string.format("Rect:(%.6f,%.6f,%.6f,%.6f)", self.x, self.y, self.width, self.height)
    return s
  end,
  __eq = function(self, rhs)
    if math.abs(self.x - rhs.x) > 1.0E-6 then
      return false
    end
    if 1.0E-6 < math.abs(self.y - rhs.y) then
      return false
    end
    if 1.0E-6 < math.abs(self.width - rhs.width) then
      return false
    end
    if 1.0E-6 < math.abs(self.height - rhs.height) then
      return false
    end
    return true
  end
}
function EC.Rect.__index(t, k)
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
function EC.Rect.__newindex(t, k, v)
  local mt = getmetatable(t)
  local setfunc = rawget(mt, "set_" .. k)
  if setfunc then
    setfunc(t, v)
    return t
  end
  return nil
end
_RectCtor_ = EC.Rect.new
return EC
