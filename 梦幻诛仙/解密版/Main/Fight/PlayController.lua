local Lplus = require("Lplus")
local PlayController = Lplus.Class("PlayController")
local def = PlayController.define
def.field("number").time = -1
def.field("table").events = nil
def.field("boolean").isInUpdate = false
def.field("table").to_be_add = nil
def.static("=>", PlayController).Create = function()
  return PlayController()
end
def.method().Start = function(self)
  self.events = {}
  self.to_be_add = {}
  self.isInUpdate = false
  self.time = 0
end
def.method("=>", "boolean").IsRunning = function(self)
  return self.time >= 0
end
def.method("number").Update = function(self, tick)
  if self.time < 0 then
    return
  end
  self.time = self.time + tick
  self.isInUpdate = true
  for k, v in pairs(self.events) do
    if self.time >= v.startTime then
      _G.SafeCall(v.callback, v.context)
      self.events[k] = nil
    end
  end
  self.isInUpdate = false
  if self.to_be_add then
    for k, v in pairs(self.to_be_add) do
      self:AddEvent(v)
      self.to_be_add[k] = nil
    end
  end
end
def.method("table").AddEvent = function(self, event)
  if event == nil or self.events == nil then
    return
  end
  if self.isInUpdate then
    self.to_be_add[#self.to_be_add + 1] = event
    return
  end
  event.startTime = self.time + event.startTime
  self.events[#self.events + 1] = event
end
def.method().Reset = function(self)
  self.events = nil
  self.to_be_add = nil
  self.isInUpdate = false
  self.time = -1
end
PlayController.Commit()
return PlayController
