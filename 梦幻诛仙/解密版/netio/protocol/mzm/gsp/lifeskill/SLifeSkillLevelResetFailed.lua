local SLifeSkillLevelResetFailed = class("SLifeSkillLevelResetFailed")
SLifeSkillLevelResetFailed.TYPEID = 12589069
SLifeSkillLevelResetFailed.ERROR_SYSTEM = -1
SLifeSkillLevelResetFailed.ERROR_USERID = -2
SLifeSkillLevelResetFailed.ERROR_CFG = -3
SLifeSkillLevelResetFailed.ERROR_PARAM = -4
SLifeSkillLevelResetFailed.ERROR_ROLE_LEVEL_LESS = -5
SLifeSkillLevelResetFailed.ERROR_SILVER_TO_MAX = -6
SLifeSkillLevelResetFailed.ERROR_BANGGONG_TO_MAX = -7
SLifeSkillLevelResetFailed.ERROR_NOT_IN_GANG = -8
function SLifeSkillLevelResetFailed:ctor(skill_bag_id, ret_code)
  self.id = 12589069
  self.skill_bag_id = skill_bag_id or nil
  self.ret_code = ret_code or nil
end
function SLifeSkillLevelResetFailed:marshal(os)
  os:marshalInt32(self.skill_bag_id)
  os:marshalInt32(self.ret_code)
end
function SLifeSkillLevelResetFailed:unmarshal(os)
  self.skill_bag_id = os:unmarshalInt32()
  self.ret_code = os:unmarshalInt32()
end
function SLifeSkillLevelResetFailed:sizepolicy(size)
  return size <= 65535
end
return SLifeSkillLevelResetFailed
