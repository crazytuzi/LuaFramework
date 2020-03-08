local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RaceEvent = Lplus.Class(MODULE_NAME)
local def = RaceEvent.define
def.field("number").m_eventId = 0
def.field("number").m_actualChangeSpeed = 0
def.final("number", "=>", RaceEvent).new = function(eventId)
  local obj = RaceEvent()
  obj:SetEventId(eventId)
  return obj
end
def.method("=>", "number").GetEventId = function(self)
  return self.m_eventId
end
def.method("=>", "number").GetActualChangeSpeed = function(self)
  return self.m_actualChangeSpeed
end
def.method("number").SetEventId = function(self, value)
  self.m_eventId = value
end
def.method("number").SetActualChangeSpeed = function(self, value)
  self.m_actualChangeSpeed = value
end
return RaceEvent.Commit()
