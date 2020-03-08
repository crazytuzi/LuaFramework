local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RaceCommandResult = Lplus.Class(MODULE_NAME)
local def = RaceCommandResult.define
def.field("boolean").m_isAllRight = false
def.field("number").m_actualChangeSpeed = 0
def.field("table").m_teamMemberStates = nil
def.final("=>", RaceCommandResult).new = function()
  local obj = RaceCommandResult()
  return obj
end
def.method("=>", "boolean").GetIsAllRight = function(self)
  return self.m_isAllRight
end
def.method("=>", "number").GetActualChangeSpeed = function(self)
  return self.m_actualChangeSpeed
end
def.method("=>", "table").GetTeamMemberStates = function(self)
  return self.m_teamMemberStates
end
def.method("boolean").SetIsAllRight = function(self, value)
  self.m_isAllRight = value
end
def.method("number").SetActualChangeSpeed = function(self, value)
  self.m_actualChangeSpeed = value
end
def.method("table").SetTeamMemberStates = function(self, value)
  self.m_teamMemberStates = value
end
return RaceCommandResult.Commit()
