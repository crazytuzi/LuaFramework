local CReplaceMainSkill = class("CReplaceMainSkill")
CReplaceMainSkill.TYPEID = 12596521
function CReplaceMainSkill:ctor(index, skillIndex)
  self.id = 12596521
  self.index = index or nil
  self.skillIndex = skillIndex or nil
end
function CReplaceMainSkill:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.skillIndex)
end
function CReplaceMainSkill:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.skillIndex = os:unmarshalInt32()
end
function CReplaceMainSkill:sizepolicy(size)
  return size <= 65535
end
return CReplaceMainSkill
