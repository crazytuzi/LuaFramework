local CLifeSkillLevelResetReq = class("CLifeSkillLevelResetReq")
CLifeSkillLevelResetReq.TYPEID = 12589068
function CLifeSkillLevelResetReq:ctor(skill_bag_id, return_silver, return_banggong)
  self.id = 12589068
  self.skill_bag_id = skill_bag_id or nil
  self.return_silver = return_silver or nil
  self.return_banggong = return_banggong or nil
end
function CLifeSkillLevelResetReq:marshal(os)
  os:marshalInt32(self.skill_bag_id)
  os:marshalInt64(self.return_silver)
  os:marshalInt64(self.return_banggong)
end
function CLifeSkillLevelResetReq:unmarshal(os)
  self.skill_bag_id = os:unmarshalInt32()
  self.return_silver = os:unmarshalInt64()
  self.return_banggong = os:unmarshalInt64()
end
function CLifeSkillLevelResetReq:sizepolicy(size)
  return size <= 65535
end
return CLifeSkillLevelResetReq
