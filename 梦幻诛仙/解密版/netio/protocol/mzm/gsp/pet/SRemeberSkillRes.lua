local SRemeberSkillRes = class("SRemeberSkillRes")
SRemeberSkillRes.TYPEID = 12590635
function SRemeberSkillRes:ctor(petId, skillId)
  self.id = 12590635
  self.petId = petId or nil
  self.skillId = skillId or nil
end
function SRemeberSkillRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.skillId)
end
function SRemeberSkillRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.skillId = os:unmarshalInt32()
end
function SRemeberSkillRes:sizepolicy(size)
  return size <= 65535
end
return SRemeberSkillRes
