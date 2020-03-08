local SSyncSkillExpChange = class("SSyncSkillExpChange")
SSyncSkillExpChange.TYPEID = 12589571
function SSyncSkillExpChange:ctor(skillBagId, exp, useSilver)
  self.id = 12589571
  self.skillBagId = skillBagId or nil
  self.exp = exp or nil
  self.useSilver = useSilver or nil
end
function SSyncSkillExpChange:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.exp)
  os:marshalInt32(self.useSilver)
end
function SSyncSkillExpChange:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
  self.useSilver = os:unmarshalInt32()
end
function SSyncSkillExpChange:sizepolicy(size)
  return size <= 65535
end
return SSyncSkillExpChange
