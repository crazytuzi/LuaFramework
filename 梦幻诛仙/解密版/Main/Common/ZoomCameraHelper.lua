local Lplus = require("Lplus")
local ZoomCameraHelper = Lplus.Class("ZoomCameraHelper")
local def = ZoomCameraHelper.define
def.field("userdata").camera = nil
def.field("number").speed = 0
def.field("number").value = 0
def.field("number").min = 0
def.field("number").max = 0
def.field("boolean")._start = false
def.field("number")._dir = 0
def.static("number", "number", "number", "=>", ZoomCameraHelper).New = function(min, max, value)
  local instance = ZoomCameraHelper()
  instance.min = min
  instance.max = max
  instance.value = value
  return instance
end
def.virtual().Update = function(self)
  if not self._start then
    return
  end
  if self._dir == 0 then
    return
  end
  if self._dir > 0 and self.value >= self.max then
    self._start = false
    self._dir = -1
  elseif self._dir < 0 and self.value <= self.min then
    self._start = false
    self._dir = 1
  else
    self:Zoom()
  end
end
def.virtual().ZoomIn = function(self)
  self._start = true
  self._dir = -1
end
def.virtual().ZoomOut = function(self)
  self._start = true
  self._dir = 1
end
def.method().Zoom = function(self)
  local v = Time.deltaTime * self.speed * self._dir
  self.value = self.value + v
  if self.value > self.max then
    self.value = self.max
  end
  if self.value < self.min then
    self.value = self.min
  end
  if self.camera then
    if self.camera.orthographic == true then
      self.camera.orthographicSize = self.value
    else
      self.camera.fieldOfView = self.value
    end
  end
end
return ZoomCameraHelper.Commit()
