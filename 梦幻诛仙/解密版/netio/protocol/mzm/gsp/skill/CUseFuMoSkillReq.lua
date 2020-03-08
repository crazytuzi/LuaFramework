local CUseFuMoSkillReq = class("CUseFuMoSkillReq")
CUseFuMoSkillReq.TYPEID = 12591623
function CUseFuMoSkillReq:ctor(skillId, skillBagId)
  self.id = 12591623
  self.skillId = skillId or nil
  self.skillBagId = skillBagId or nil
end
function CUseFuMoSkillReq:marshal(os)
  os:marshalInt32(self.skillId)
  os:marshalInt32(self.skillBagId)
end
function CUseFuMoSkillReq:unmarshal(os)
  self.skillId = os:unmarshalInt32()
  self.skillBagId = os:unmarshalInt32()
end
function CUseFuMoSkillReq:sizepolicy(size)
  return size <= 65535
end
return CUseFuMoSkillReq
