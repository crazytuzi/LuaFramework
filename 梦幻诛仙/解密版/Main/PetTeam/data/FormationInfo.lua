local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local FormationInfo = Lplus.Class(CUR_CLASS_NAME)
local def = FormationInfo.define
def.field("number").id = 0
def.field("number").level = 0
def.field("number").exp = 0
def.final("number", "number", "number", "=>", FormationInfo).New = function(id, level, exp)
  local petTeamInfo = FormationInfo()
  petTeamInfo.id = id
  petTeamInfo.level = level
  petTeamInfo.exp = exp
  return petTeamInfo
end
def.method("number").SetLevel = function(self, level)
  self.level = level
end
def.method("number").SetExp = function(self, exp)
  self.exp = exp
end
return FormationInfo.Commit()
