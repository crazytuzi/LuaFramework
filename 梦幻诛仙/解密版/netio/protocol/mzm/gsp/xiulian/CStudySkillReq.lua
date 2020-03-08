local CStudySkillReq = class("CStudySkillReq")
CStudySkillReq.TYPEID = 12589578
function CStudySkillReq:ctor(skillBagId, studyCount)
  self.id = 12589578
  self.skillBagId = skillBagId or nil
  self.studyCount = studyCount or nil
end
function CStudySkillReq:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.studyCount)
end
function CStudySkillReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  self.studyCount = os:unmarshalInt32()
end
function CStudySkillReq:sizepolicy(size)
  return size <= 65535
end
return CStudySkillReq
