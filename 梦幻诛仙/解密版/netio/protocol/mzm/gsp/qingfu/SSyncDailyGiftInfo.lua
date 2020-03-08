local SSyncDailyGiftInfo = class("SSyncDailyGiftInfo")
SSyncDailyGiftInfo.TYPEID = 12588837
function SSyncDailyGiftInfo:ctor(is_receive)
  self.id = 12588837
  self.is_receive = is_receive or nil
end
function SSyncDailyGiftInfo:marshal(os)
  os:marshalUInt8(self.is_receive)
end
function SSyncDailyGiftInfo:unmarshal(os)
  self.is_receive = os:unmarshalUInt8()
end
function SSyncDailyGiftInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncDailyGiftInfo
