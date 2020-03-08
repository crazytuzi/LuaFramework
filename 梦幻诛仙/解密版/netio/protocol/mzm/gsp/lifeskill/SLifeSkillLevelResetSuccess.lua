local SLifeSkillLevelResetSuccess = class("SLifeSkillLevelResetSuccess")
SLifeSkillLevelResetSuccess.TYPEID = 12589067
function SLifeSkillLevelResetSuccess:ctor(skill_bag_id, after_level, return_silver, return_banggong)
  self.id = 12589067
  self.skill_bag_id = skill_bag_id or nil
  self.after_level = after_level or nil
  self.return_silver = return_silver or nil
  self.return_banggong = return_banggong or nil
end
function SLifeSkillLevelResetSuccess:marshal(os)
  os:marshalInt32(self.skill_bag_id)
  os:marshalInt32(self.after_level)
  os:marshalInt64(self.return_silver)
  os:marshalInt64(self.return_banggong)
end
function SLifeSkillLevelResetSuccess:unmarshal(os)
  self.skill_bag_id = os:unmarshalInt32()
  self.after_level = os:unmarshalInt32()
  self.return_silver = os:unmarshalInt64()
  self.return_banggong = os:unmarshalInt64()
end
function SLifeSkillLevelResetSuccess:sizepolicy(size)
  return size <= 65535
end
return SLifeSkillLevelResetSuccess
