local SUseAvatarFrameUnlockItemFail = class("SUseAvatarFrameUnlockItemFail")
SUseAvatarFrameUnlockItemFail.TYPEID = 12615182
SUseAvatarFrameUnlockItemFail.OCCUPATION_NOT_MATCHED = 1
SUseAvatarFrameUnlockItemFail.GENDER_NOT_MATCHED = 2
SUseAvatarFrameUnlockItemFail.ALREADY_UNLOCKED_FOREVER = 3
function SUseAvatarFrameUnlockItemFail:ctor(retcode)
  self.id = 12615182
  self.retcode = retcode or nil
end
function SUseAvatarFrameUnlockItemFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SUseAvatarFrameUnlockItemFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SUseAvatarFrameUnlockItemFail:sizepolicy(size)
  return size <= 65535
end
return SUseAvatarFrameUnlockItemFail
