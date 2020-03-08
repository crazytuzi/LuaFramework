local CUnderstandSkill = class("CUnderstandSkill")
CUnderstandSkill.TYPEID = 12596501
function CUnderstandSkill:ctor(index, skillid)
  self.id = 12596501
  self.index = index or nil
  self.skillid = skillid or nil
end
function CUnderstandSkill:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.skillid)
end
function CUnderstandSkill:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.skillid = os:unmarshalInt32()
end
function CUnderstandSkill:sizepolicy(size)
  return size <= 65535
end
return CUnderstandSkill
