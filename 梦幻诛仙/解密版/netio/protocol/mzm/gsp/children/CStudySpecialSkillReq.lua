local CStudySpecialSkillReq = class("CStudySpecialSkillReq")
CStudySpecialSkillReq.TYPEID = 12609383
function CStudySpecialSkillReq:ctor(childrenid, itemKey)
  self.id = 12609383
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
end
function CStudySpecialSkillReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
end
function CStudySpecialSkillReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CStudySpecialSkillReq:sizepolicy(size)
  return size <= 65535
end
return CStudySpecialSkillReq
