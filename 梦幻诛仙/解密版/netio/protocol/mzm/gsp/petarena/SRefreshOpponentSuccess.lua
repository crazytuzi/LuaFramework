local SRefreshOpponentSuccess = class("SRefreshOpponentSuccess")
SRefreshOpponentSuccess.TYPEID = 12628234
function SRefreshOpponentSuccess:ctor(rank, refresh_time)
  self.id = 12628234
  self.rank = rank or nil
  self.refresh_time = refresh_time or nil
end
function SRefreshOpponentSuccess:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.refresh_time)
end
function SRefreshOpponentSuccess:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.refresh_time = os:unmarshalInt32()
end
function SRefreshOpponentSuccess:sizepolicy(size)
  return size <= 65535
end
return SRefreshOpponentSuccess
