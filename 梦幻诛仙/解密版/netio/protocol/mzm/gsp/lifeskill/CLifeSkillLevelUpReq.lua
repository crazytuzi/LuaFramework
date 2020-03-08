local CLifeSkillLevelUpReq = class("CLifeSkillLevelUpReq")
CLifeSkillLevelUpReq.TYPEID = 12589059
function CLifeSkillLevelUpReq:ctor(skillBagId)
  self.id = 12589059
  self.skillBagId = skillBagId or nil
end
function CLifeSkillLevelUpReq:marshal(os)
  os:marshalInt32(self.skillBagId)
end
function CLifeSkillLevelUpReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
end
function CLifeSkillLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CLifeSkillLevelUpReq
