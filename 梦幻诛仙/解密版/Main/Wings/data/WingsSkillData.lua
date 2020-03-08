local Lplus = require("Lplus")
local WingsSkillData = Lplus.Class("WingsSkillData")
local def = WingsSkillData.define
def.field("number").mainSkillId = 0
def.field("table").subSkillIds = nil
def.method("table").RawSet = function(self, data)
  self.mainSkillId = data.mainSkillId
  self.subSkillIds = data.subSkillIds
end
return WingsSkillData.Commit()
