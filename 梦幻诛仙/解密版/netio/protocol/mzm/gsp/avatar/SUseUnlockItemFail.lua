local SUseUnlockItemFail = class("SUseUnlockItemFail")
SUseUnlockItemFail.TYPEID = 12615177
SUseUnlockItemFail.INVALID_ITEM = 0
SUseUnlockItemFail.ALREADY_UNLOCKED = 1
SUseUnlockItemFail.NO_ITEM = 2
SUseUnlockItemFail.CANNOT_UNLOCK = 3
SUseUnlockItemFail.ITEMS_RELATED_TO_DIFFERENT_AVATAR = 4
SUseUnlockItemFail.MULTIPLE_ITEMS_WITH_UNLOCK_FOREVER = 5
function SUseUnlockItemFail:ctor(retcode)
  self.id = 12615177
  self.retcode = retcode or nil
end
function SUseUnlockItemFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SUseUnlockItemFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SUseUnlockItemFail:sizepolicy(size)
  return size <= 65535
end
return SUseUnlockItemFail
