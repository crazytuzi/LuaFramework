local SStudySpecialSkillRes = class("SStudySpecialSkillRes")
SStudySpecialSkillRes.TYPEID = 12609396
function SStudySpecialSkillRes:ctor(childrenid, itemKey, skilid)
  self.id = 12609396
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
  self.skilid = skilid or nil
end
function SStudySpecialSkillRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.skilid)
end
function SStudySpecialSkillRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
  self.skilid = os:unmarshalInt32()
end
function SStudySpecialSkillRes:sizepolicy(size)
  return size <= 65535
end
return SStudySpecialSkillRes
