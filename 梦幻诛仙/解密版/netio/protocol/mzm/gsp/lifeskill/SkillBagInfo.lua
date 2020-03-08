local OctetsStream = require("netio.OctetsStream")
local SkillBagInfo = class("SkillBagInfo")
function SkillBagInfo:ctor(skillBagId, skillLevel)
  self.skillBagId = skillBagId or nil
  self.skillLevel = skillLevel or nil
end
function SkillBagInfo:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.skillLevel)
end
function SkillBagInfo:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  self.skillLevel = os:unmarshalInt32()
end
return SkillBagInfo
