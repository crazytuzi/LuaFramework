local CUnRemeberSkillReq = class("CUnRemeberSkillReq")
CUnRemeberSkillReq.TYPEID = 12590611
function CUnRemeberSkillReq:ctor(petId, skillId)
  self.id = 12590611
  self.petId = petId or nil
  self.skillId = skillId or nil
end
function CUnRemeberSkillReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.skillId)
end
function CUnRemeberSkillReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.skillId = os:unmarshalInt32()
end
function CUnRemeberSkillReq:sizepolicy(size)
  return size <= 65535
end
return CUnRemeberSkillReq
