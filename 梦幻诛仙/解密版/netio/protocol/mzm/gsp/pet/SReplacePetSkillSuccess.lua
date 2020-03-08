local SReplacePetSkillSuccess = class("SReplacePetSkillSuccess")
SReplacePetSkillSuccess.TYPEID = 12590659
function SReplacePetSkillSuccess:ctor(petId)
  self.id = 12590659
  self.petId = petId or nil
end
function SReplacePetSkillSuccess:marshal(os)
  os:marshalInt64(self.petId)
end
function SReplacePetSkillSuccess:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function SReplacePetSkillSuccess:sizepolicy(size)
  return size <= 65535
end
return SReplacePetSkillSuccess
