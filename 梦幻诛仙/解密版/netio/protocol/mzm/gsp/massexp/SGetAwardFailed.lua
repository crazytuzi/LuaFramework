local SGetAwardFailed = class("SGetAwardFailed")
SGetAwardFailed.TYPEID = 12608260
SGetAwardFailed.ERROR_NOT_JOIN_ACTIVITY = -1
SGetAwardFailed.ERROR_EXPIRED = -2
function SGetAwardFailed:ctor(retcode)
  self.id = 12608260
  self.retcode = retcode or nil
end
function SGetAwardFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SGetAwardFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SGetAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetAwardFailed
