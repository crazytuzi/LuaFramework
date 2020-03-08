local SGetDailyGiftFailed = class("SGetDailyGiftFailed")
SGetDailyGiftFailed.TYPEID = 12588835
SGetDailyGiftFailed.ERROR_RECEIVED = -1
SGetDailyGiftFailed.ERROR_BAG_FULL = -2
function SGetDailyGiftFailed:ctor(retcode)
  self.id = 12588835
  self.retcode = retcode or nil
end
function SGetDailyGiftFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SGetDailyGiftFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SGetDailyGiftFailed:sizepolicy(size)
  return size <= 65535
end
return SGetDailyGiftFailed
