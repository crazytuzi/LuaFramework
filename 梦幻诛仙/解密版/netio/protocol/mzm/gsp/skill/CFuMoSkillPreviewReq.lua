local CFuMoSkillPreviewReq = class("CFuMoSkillPreviewReq")
CFuMoSkillPreviewReq.TYPEID = 12591622
function CFuMoSkillPreviewReq:ctor(skillId, skillBagId)
  self.id = 12591622
  self.skillId = skillId or nil
  self.skillBagId = skillBagId or nil
end
function CFuMoSkillPreviewReq:marshal(os)
  os:marshalInt32(self.skillId)
  os:marshalInt32(self.skillBagId)
end
function CFuMoSkillPreviewReq:unmarshal(os)
  self.skillId = os:unmarshalInt32()
  self.skillBagId = os:unmarshalInt32()
end
function CFuMoSkillPreviewReq:sizepolicy(size)
  return size <= 65535
end
return CFuMoSkillPreviewReq
