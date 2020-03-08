local OctetsStream = require("netio.OctetsStream")
local GangSkillBagInfo = class("GangSkillBagInfo")
function GangSkillBagInfo:ctor(skillid, level)
  self.skillid = skillid or nil
  self.level = level or nil
end
function GangSkillBagInfo:marshal(os)
  os:marshalInt32(self.skillid)
  os:marshalInt32(self.level)
end
function GangSkillBagInfo:unmarshal(os)
  self.skillid = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
end
return GangSkillBagInfo
