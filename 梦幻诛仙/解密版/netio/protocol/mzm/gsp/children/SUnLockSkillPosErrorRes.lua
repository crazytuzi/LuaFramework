local SUnLockSkillPosErrorRes = class("SUnLockSkillPosErrorRes")
SUnLockSkillPosErrorRes.TYPEID = 12609387
SUnLockSkillPosErrorRes.ERROR_DO_NOT_HAS_ENOUGH_YUAN_BAO = 1
SUnLockSkillPosErrorRes.ERROR_DO_NOT_HAS_ENOUGH_ITEM = 2
SUnLockSkillPosErrorRes.ERROR_UNLOCK_TO_MAX = 3
SUnLockSkillPosErrorRes.ERROR_ITEM_PRICE_CHANGED = 4
function SUnLockSkillPosErrorRes:ctor(ret)
  self.id = 12609387
  self.ret = ret or nil
end
function SUnLockSkillPosErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SUnLockSkillPosErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SUnLockSkillPosErrorRes:sizepolicy(size)
  return size <= 65535
end
return SUnLockSkillPosErrorRes
