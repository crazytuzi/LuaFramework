local OctetsStream = require("netio.OctetsStream")
local SkillBagInfo = class("SkillBagInfo")
function SkillBagInfo:ctor(skillBagId, skillLevel, exp)
  self.skillBagId = skillBagId or nil
  self.skillLevel = skillLevel or nil
  self.exp = exp or nil
end
function SkillBagInfo:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.skillLevel)
  os:marshalInt32(self.exp)
end
function SkillBagInfo:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  self.skillLevel = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
end
return SkillBagInfo
