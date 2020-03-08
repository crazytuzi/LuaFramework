local SUnLockMagicMarkRes = class("SUnLockMagicMarkRes")
SUnLockMagicMarkRes.TYPEID = 12609540
SUnLockMagicMarkRes.SUCCESS = 1
SUnLockMagicMarkRes.ERROR_ITEM_NOT_ENOUGH = 2
SUnLockMagicMarkRes.ERROR_ITEM_MAGIC_MARK_TYPE_NOT_SAME = 3
SUnLockMagicMarkRes.ERROR_DO_NOT_NEED_UNLOCK = 4
SUnLockMagicMarkRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 5
function SUnLockMagicMarkRes:ctor(ret, magicMarkType, expiredTime)
  self.id = 12609540
  self.ret = ret or nil
  self.magicMarkType = magicMarkType or nil
  self.expiredTime = expiredTime or nil
end
function SUnLockMagicMarkRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.magicMarkType)
  os:marshalInt64(self.expiredTime)
end
function SUnLockMagicMarkRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.magicMarkType = os:unmarshalInt32()
  self.expiredTime = os:unmarshalInt64()
end
function SUnLockMagicMarkRes:sizepolicy(size)
  return size <= 65535
end
return SUnLockMagicMarkRes
