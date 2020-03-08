local SGetTimeLimitGiftFailedRes = class("SGetTimeLimitGiftFailedRes")
SGetTimeLimitGiftFailedRes.TYPEID = 12588829
SGetTimeLimitGiftFailedRes.ERROR_ACTVITY_NOT_OPEN = -1
SGetTimeLimitGiftFailedRes.ERROR_CURRENCY_NOT_ENOUGH = -2
SGetTimeLimitGiftFailedRes.ERROR_REAMIN_BUY_COUNT_NOT_ENOUGH = -3
SGetTimeLimitGiftFailedRes.ERROR_CAN_NOT_BUY_TODAY = -4
SGetTimeLimitGiftFailedRes.ERROR_BUY_NUM_ILLEGAL = -5
function SGetTimeLimitGiftFailedRes:ctor(activity_id, gift_bag_id, retcode)
  self.id = 12588829
  self.activity_id = activity_id or nil
  self.gift_bag_id = gift_bag_id or nil
  self.retcode = retcode or nil
end
function SGetTimeLimitGiftFailedRes:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_id)
  os:marshalInt32(self.retcode)
end
function SGetTimeLimitGiftFailedRes:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_id = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetTimeLimitGiftFailedRes:sizepolicy(size)
  return size <= 65535
end
return SGetTimeLimitGiftFailedRes
