local SGetDailyGiftSuccess = class("SGetDailyGiftSuccess")
SGetDailyGiftSuccess.TYPEID = 12588836
function SGetDailyGiftSuccess:ctor()
  self.id = 12588836
end
function SGetDailyGiftSuccess:marshal(os)
end
function SGetDailyGiftSuccess:unmarshal(os)
end
function SGetDailyGiftSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetDailyGiftSuccess
