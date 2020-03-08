local SPetFightSetSkillFail = class("SPetFightSetSkillFail")
SPetFightSetSkillFail.TYPEID = 12590698
SPetFightSetSkillFail.PET_NOT_EXISTS = 1
SPetFightSetSkillFail.PET_NOT_BOUND = 2
SPetFightSetSkillFail.SKILL_NOT_AVAILABLE = 3
function SPetFightSetSkillFail:ctor(reason, pet_id, skill_id)
  self.id = 12590698
  self.reason = reason or nil
  self.pet_id = pet_id or nil
  self.skill_id = skill_id or nil
end
function SPetFightSetSkillFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.skill_id)
end
function SPetFightSetSkillFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.pet_id = os:unmarshalInt64()
  self.skill_id = os:unmarshalInt32()
end
function SPetFightSetSkillFail:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetSkillFail
