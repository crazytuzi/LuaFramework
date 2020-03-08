local SFuMoSkillPreviewRes = class("SFuMoSkillPreviewRes")
SFuMoSkillPreviewRes.TYPEID = 12591625
function SFuMoSkillPreviewRes:ctor(skillId, needVigor, itemId)
  self.id = 12591625
  self.skillId = skillId or nil
  self.needVigor = needVigor or nil
  self.itemId = itemId or nil
end
function SFuMoSkillPreviewRes:marshal(os)
  os:marshalInt32(self.skillId)
  os:marshalInt32(self.needVigor)
  os:marshalInt32(self.itemId)
end
function SFuMoSkillPreviewRes:unmarshal(os)
  self.skillId = os:unmarshalInt32()
  self.needVigor = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
end
function SFuMoSkillPreviewRes:sizepolicy(size)
  return size <= 65535
end
return SFuMoSkillPreviewRes
