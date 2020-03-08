local WingSkill = require("netio.protocol.mzm.gsp.wing.WingSkill")
local SReplaceSkillRes = class("SReplaceSkillRes")
SReplaceSkillRes.TYPEID = 12596523
function SReplaceSkillRes:ctor(index, skillIndex, skillresult)
  self.id = 12596523
  self.index = index or nil
  self.skillIndex = skillIndex or nil
  self.skillresult = skillresult or WingSkill.new()
end
function SReplaceSkillRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.skillIndex)
  self.skillresult:marshal(os)
end
function SReplaceSkillRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.skillIndex = os:unmarshalInt32()
  self.skillresult = WingSkill.new()
  self.skillresult:unmarshal(os)
end
function SReplaceSkillRes:sizepolicy(size)
  return size <= 65535
end
return SReplaceSkillRes
