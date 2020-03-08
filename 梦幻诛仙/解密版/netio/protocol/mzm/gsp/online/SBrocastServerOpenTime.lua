local SBrocastServerOpenTime = class("SBrocastServerOpenTime")
SBrocastServerOpenTime.TYPEID = 12582915
function SBrocastServerOpenTime:ctor(serverOpenTime)
  self.id = 12582915
  self.serverOpenTime = serverOpenTime or nil
end
function SBrocastServerOpenTime:marshal(os)
  os:marshalInt64(self.serverOpenTime)
end
function SBrocastServerOpenTime:unmarshal(os)
  self.serverOpenTime = os:unmarshalInt64()
end
function SBrocastServerOpenTime:sizepolicy(size)
  return size <= 65535
end
return SBrocastServerOpenTime
