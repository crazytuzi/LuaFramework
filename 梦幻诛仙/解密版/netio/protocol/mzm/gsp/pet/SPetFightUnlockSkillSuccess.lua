local SPetFightUnlockSkillSuccess = class("SPetFightUnlockSkillSuccess")
SPetFightUnlockSkillSuccess.TYPEID = 12590693
function SPetFightUnlockSkillSuccess:ctor(skill_id)
  self.id = 12590693
  self.skill_id = skill_id or nil
end
function SPetFightUnlockSkillSuccess:marshal(os)
  os:marshalInt32(self.skill_id)
end
function SPetFightUnlockSkillSuccess:unmarshal(os)
  self.skill_id = os:unmarshalInt32()
end
function SPetFightUnlockSkillSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetFightUnlockSkillSuccess
