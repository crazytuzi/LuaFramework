local SPetFightSetSkillSuccess = class("SPetFightSetSkillSuccess")
SPetFightSetSkillSuccess.TYPEID = 12590702
function SPetFightSetSkillSuccess:ctor(pet_id, skill_id)
  self.id = 12590702
  self.pet_id = pet_id or nil
  self.skill_id = skill_id or nil
end
function SPetFightSetSkillSuccess:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.skill_id)
end
function SPetFightSetSkillSuccess:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.skill_id = os:unmarshalInt32()
end
function SPetFightSetSkillSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetSkillSuccess
