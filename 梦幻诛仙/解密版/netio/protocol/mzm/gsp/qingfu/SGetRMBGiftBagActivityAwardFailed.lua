local SGetRMBGiftBagActivityAwardFailed = class("SGetRMBGiftBagActivityAwardFailed")
SGetRMBGiftBagActivityAwardFailed.TYPEID = 12588832
SGetRMBGiftBagActivityAwardFailed.ERROR_NOT_PURCHASE_RMB_GIFT_BAG = -1
SGetRMBGiftBagActivityAwardFailed.ERROR_LEVEL_NOT_MEET = -2
SGetRMBGiftBagActivityAwardFailed.ERROR_ALREADY_GET_AWARD = -3
function SGetRMBGiftBagActivityAwardFailed:ctor(activity_cfgid, tier, retcode)
  self.id = 12588832
  self.activity_cfgid = activity_cfgid or nil
  self.tier = tier or nil
  self.retcode = retcode or nil
end
function SGetRMBGiftBagActivityAwardFailed:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.tier)
  os:marshalInt32(self.retcode)
end
function SGetRMBGiftBagActivityAwardFailed:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.tier = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetRMBGiftBagActivityAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetRMBGiftBagActivityAwardFailed
