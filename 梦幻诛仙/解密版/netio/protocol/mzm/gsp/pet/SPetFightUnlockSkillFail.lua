local SPetFightUnlockSkillFail = class("SPetFightUnlockSkillFail")
SPetFightUnlockSkillFail.TYPEID = 12590688
SPetFightUnlockSkillFail.INSUFFICIENT_SCORE = 1
function SPetFightUnlockSkillFail:ctor(reason, skill_id)
  self.id = 12590688
  self.reason = reason or nil
  self.skill_id = skill_id or nil
end
function SPetFightUnlockSkillFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.skill_id)
end
function SPetFightUnlockSkillFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.skill_id = os:unmarshalInt32()
end
function SPetFightUnlockSkillFail:sizepolicy(size)
  return size <= 65535
end
return SPetFightUnlockSkillFail
