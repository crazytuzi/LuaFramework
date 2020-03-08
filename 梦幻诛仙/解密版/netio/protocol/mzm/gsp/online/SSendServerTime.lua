local SSendServerTime = class("SSendServerTime")
SSendServerTime.TYPEID = 12582913
function SSendServerTime:ctor(serverTime, raw_offset, serverOpenTime)
  self.id = 12582913
  self.serverTime = serverTime or nil
  self.raw_offset = raw_offset or nil
  self.serverOpenTime = serverOpenTime or nil
end
function SSendServerTime:marshal(os)
  os:marshalInt64(self.serverTime)
  os:marshalInt32(self.raw_offset)
  os:marshalInt64(self.serverOpenTime)
end
function SSendServerTime:unmarshal(os)
  self.serverTime = os:unmarshalInt64()
  self.raw_offset = os:unmarshalInt32()
  self.serverOpenTime = os:unmarshalInt64()
end
function SSendServerTime:sizepolicy(size)
  return size <= 65535
end
return SSendServerTime
