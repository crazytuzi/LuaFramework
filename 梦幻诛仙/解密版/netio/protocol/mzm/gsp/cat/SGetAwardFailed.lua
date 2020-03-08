local SGetAwardFailed = class("SGetAwardFailed")
SGetAwardFailed.TYPEID = 12605702
SGetAwardFailed.ERROR_AWARD_NOT_EXIST = -1
SGetAwardFailed.ERROR_BAG_FULL = -2
function SGetAwardFailed:ctor(retcode)
  self.id = 12605702
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
