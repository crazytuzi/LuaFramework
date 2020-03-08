local CStudyCommonSkillReq = class("CStudyCommonSkillReq")
CStudyCommonSkillReq.TYPEID = 12609389
function CStudyCommonSkillReq:ctor(childrenid, itemKey, pos)
  self.id = 12609389
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
  self.pos = pos or nil
end
function CStudyCommonSkillReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.pos)
end
function CStudyCommonSkillReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
  self.pos = os:unmarshalInt32()
end
function CStudyCommonSkillReq:sizepolicy(size)
  return size <= 65535
end
return CStudyCommonSkillReq
