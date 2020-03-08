local CPetFightUnlockSkillReq = class("CPetFightUnlockSkillReq")
CPetFightUnlockSkillReq.TYPEID = 12590696
function CPetFightUnlockSkillReq:ctor(skill_id)
  self.id = 12590696
  self.skill_id = skill_id or nil
end
function CPetFightUnlockSkillReq:marshal(os)
  os:marshalInt32(self.skill_id)
end
function CPetFightUnlockSkillReq:unmarshal(os)
  self.skill_id = os:unmarshalInt32()
end
function CPetFightUnlockSkillReq:sizepolicy(size)
  return size <= 65535
end
return CPetFightUnlockSkillReq
