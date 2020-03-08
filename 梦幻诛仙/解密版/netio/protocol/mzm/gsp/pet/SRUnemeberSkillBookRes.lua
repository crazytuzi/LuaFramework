local SRUnemeberSkillBookRes = class("SRUnemeberSkillBookRes")
SRUnemeberSkillBookRes.TYPEID = 12590638
function SRUnemeberSkillBookRes:ctor(petId, skillId)
  self.id = 12590638
  self.petId = petId or nil
  self.skillId = skillId or nil
end
function SRUnemeberSkillBookRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.skillId)
end
function SRUnemeberSkillBookRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.skillId = os:unmarshalInt32()
end
function SRUnemeberSkillBookRes:sizepolicy(size)
  return size <= 65535
end
return SRUnemeberSkillBookRes
