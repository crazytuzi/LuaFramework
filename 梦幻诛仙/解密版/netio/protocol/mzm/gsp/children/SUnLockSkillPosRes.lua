local SUnLockSkillPosRes = class("SUnLockSkillPosRes")
SUnLockSkillPosRes.TYPEID = 12609381
function SUnLockSkillPosRes:ctor(childrenid, nowNum)
  self.id = 12609381
  self.childrenid = childrenid or nil
  self.nowNum = nowNum or nil
end
function SUnLockSkillPosRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.nowNum)
end
function SUnLockSkillPosRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.nowNum = os:unmarshalInt32()
end
function SUnLockSkillPosRes:sizepolicy(size)
  return size <= 65535
end
return SUnLockSkillPosRes
