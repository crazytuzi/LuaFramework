local CStudySkillBookReq = class("CStudySkillBookReq")
CStudySkillBookReq.TYPEID = 12590615
function CStudySkillBookReq:ctor(petId, itemKey)
  self.id = 12590615
  self.petId = petId or nil
  self.itemKey = itemKey or nil
end
function CStudySkillBookReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.itemKey)
end
function CStudySkillBookReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CStudySkillBookReq:sizepolicy(size)
  return size <= 65535
end
return CStudySkillBookReq
