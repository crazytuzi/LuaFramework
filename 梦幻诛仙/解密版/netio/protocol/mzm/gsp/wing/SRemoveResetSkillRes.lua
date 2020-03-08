local SRemoveResetSkillRes = class("SRemoveResetSkillRes")
SRemoveResetSkillRes.TYPEID = 12596520
function SRemoveResetSkillRes:ctor(index)
  self.id = 12596520
  self.index = index or nil
end
function SRemoveResetSkillRes:marshal(os)
  os:marshalInt32(self.index)
end
function SRemoveResetSkillRes:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function SRemoveResetSkillRes:sizepolicy(size)
  return size <= 65535
end
return SRemoveResetSkillRes
