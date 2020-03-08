local CPetFightSetSkillReq = class("CPetFightSetSkillReq")
CPetFightSetSkillReq.TYPEID = 12590700
function CPetFightSetSkillReq:ctor(pet_id, skill_id)
  self.id = 12590700
  self.pet_id = pet_id or nil
  self.skill_id = skill_id or nil
end
function CPetFightSetSkillReq:marshal(os)
  os:marshalInt64(self.pet_id)
  os:marshalInt32(self.skill_id)
end
function CPetFightSetSkillReq:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
  self.skill_id = os:unmarshalInt32()
end
function CPetFightSetSkillReq:sizepolicy(size)
  return size <= 65535
end
return CPetFightSetSkillReq
