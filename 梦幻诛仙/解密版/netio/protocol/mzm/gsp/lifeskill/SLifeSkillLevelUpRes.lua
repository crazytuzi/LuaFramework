local SLifeSkillLevelUpRes = class("SLifeSkillLevelUpRes")
SLifeSkillLevelUpRes.TYPEID = 12589063
function SLifeSkillLevelUpRes:ctor(skillBagId, level)
  self.id = 12589063
  self.skillBagId = skillBagId or nil
  self.level = level or nil
end
function SLifeSkillLevelUpRes:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.level)
end
function SLifeSkillLevelUpRes:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
end
function SLifeSkillLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SLifeSkillLevelUpRes
