local SSyncAddSkill = class("SSyncAddSkill")
SSyncAddSkill.TYPEID = 12590604
SSyncAddSkill.FROM_BOOK = 0
SSyncAddSkill.FROM_LEVELUP = 1
function SSyncAddSkill:ctor(petId, skillId, reason, removeSkillId)
  self.id = 12590604
  self.petId = petId or nil
  self.skillId = skillId or nil
  self.reason = reason or nil
  self.removeSkillId = removeSkillId or nil
end
function SSyncAddSkill:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.skillId)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.removeSkillId)
end
function SSyncAddSkill:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.skillId = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
  self.removeSkillId = os:unmarshalInt32()
end
function SSyncAddSkill:sizepolicy(size)
  return size <= 65535
end
return SSyncAddSkill
