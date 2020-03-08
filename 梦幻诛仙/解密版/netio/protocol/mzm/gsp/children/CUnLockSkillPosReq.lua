local CUnLockSkillPosReq = class("CUnLockSkillPosReq")
CUnLockSkillPosReq.TYPEID = 12609380
function CUnLockSkillPosReq:ctor(childrenid, nowNum)
  self.id = 12609380
  self.childrenid = childrenid or nil
  self.nowNum = nowNum or nil
end
function CUnLockSkillPosReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.nowNum)
end
function CUnLockSkillPosReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.nowNum = os:unmarshalInt32()
end
function CUnLockSkillPosReq:sizepolicy(size)
  return size <= 65535
end
return CUnLockSkillPosReq
