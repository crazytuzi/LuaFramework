local SCatRecoveryToItemFailed = class("SCatRecoveryToItemFailed")
SCatRecoveryToItemFailed.TYPEID = 12605711
SCatRecoveryToItemFailed.HOMELAND_CAT_EXPLORE_STATE = -1
SCatRecoveryToItemFailed.HOMELAND_CAT_RESET_STATE = -2
SCatRecoveryToItemFailed.HOMELAND_CAT_AWARD_NOT_RECEIVED = -3
SCatRecoveryToItemFailed.BAG_FULL = -4
function SCatRecoveryToItemFailed:ctor(retcode)
  self.id = 12605711
  self.retcode = retcode or nil
end
function SCatRecoveryToItemFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SCatRecoveryToItemFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SCatRecoveryToItemFailed:sizepolicy(size)
  return size <= 65535
end
return SCatRecoveryToItemFailed
