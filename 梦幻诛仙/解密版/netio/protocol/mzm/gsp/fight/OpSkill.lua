local OctetsStream = require("netio.OctetsStream")
local OpSkill = class("OpSkill")
function OpSkill:ctor(skill, main_target)
  self.skill = skill or nil
  self.main_target = main_target or nil
end
function OpSkill:marshal(os)
  os:marshalInt32(self.skill)
  os:marshalInt32(self.main_target)
end
function OpSkill:unmarshal(os)
  self.skill = os:unmarshalInt32()
  self.main_target = os:unmarshalInt32()
end
return OpSkill
