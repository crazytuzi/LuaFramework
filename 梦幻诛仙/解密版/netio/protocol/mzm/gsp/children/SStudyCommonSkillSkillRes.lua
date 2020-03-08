local SStudyCommonSkillSkillRes = class("SStudyCommonSkillSkillRes")
SStudyCommonSkillSkillRes.TYPEID = 12609385
function SStudyCommonSkillSkillRes:ctor(childrenid, itemKey, skilid, replaceSkillid, pos)
  self.id = 12609385
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
  self.skilid = skilid or nil
  self.replaceSkillid = replaceSkillid or nil
  self.pos = pos or nil
end
function SStudyCommonSkillSkillRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.skilid)
  os:marshalInt32(self.replaceSkillid)
  os:marshalInt32(self.pos)
end
function SStudyCommonSkillSkillRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
  self.skilid = os:unmarshalInt32()
  self.replaceSkillid = os:unmarshalInt32()
  self.pos = os:unmarshalInt32()
end
function SStudyCommonSkillSkillRes:sizepolicy(size)
  return size <= 65535
end
return SStudyCommonSkillSkillRes
