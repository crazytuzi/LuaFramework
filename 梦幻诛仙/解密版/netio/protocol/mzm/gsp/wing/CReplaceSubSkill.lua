local CReplaceSubSkill = class("CReplaceSubSkill")
CReplaceSubSkill.TYPEID = 12596518
function CReplaceSubSkill:ctor(index, skillIndex, subSkillIndex)
  self.id = 12596518
  self.index = index or nil
  self.skillIndex = skillIndex or nil
  self.subSkillIndex = subSkillIndex or nil
end
function CReplaceSubSkill:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.skillIndex)
  os:marshalInt32(self.subSkillIndex)
end
function CReplaceSubSkill:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.skillIndex = os:unmarshalInt32()
  self.subSkillIndex = os:unmarshalInt32()
end
function CReplaceSubSkill:sizepolicy(size)
  return size <= 65535
end
return CReplaceSubSkill
