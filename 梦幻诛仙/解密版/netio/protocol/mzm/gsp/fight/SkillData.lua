local OctetsStream = require("netio.OctetsStream")
local SkillData = class("SkillData")
function SkillData:ctor(skillUseCount, skillUseRound)
  self.skillUseCount = skillUseCount or nil
  self.skillUseRound = skillUseRound or nil
end
function SkillData:marshal(os)
  os:marshalInt32(self.skillUseCount)
  os:marshalInt32(self.skillUseRound)
end
function SkillData:unmarshal(os)
  self.skillUseCount = os:unmarshalInt32()
  self.skillUseRound = os:unmarshalInt32()
end
return SkillData
