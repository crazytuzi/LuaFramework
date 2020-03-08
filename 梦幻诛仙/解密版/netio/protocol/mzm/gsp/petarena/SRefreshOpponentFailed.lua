local SRefreshOpponentFailed = class("SRefreshOpponentFailed")
SRefreshOpponentFailed.TYPEID = 12628233
SRefreshOpponentFailed.ERROR_LEVEL = -1
SRefreshOpponentFailed.ERROR_ACTIVITY_JOIN = -2
SRefreshOpponentFailed.ERROR_CD = -3
function SRefreshOpponentFailed:ctor(retcode)
  self.id = 12628233
  self.retcode = retcode or nil
end
function SRefreshOpponentFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SRefreshOpponentFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SRefreshOpponentFailed:sizepolicy(size)
  return size <= 65535
end
return SRefreshOpponentFailed
