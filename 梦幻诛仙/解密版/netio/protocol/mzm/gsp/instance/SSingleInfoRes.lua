local SSingleInfoRes = class("SSingleInfoRes")
SSingleInfoRes.TYPEID = 12591376
function SSingleInfoRes:ctor(second, sucTimes)
  self.id = 12591376
  self.second = second or nil
  self.sucTimes = sucTimes or nil
end
function SSingleInfoRes:marshal(os)
  os:marshalInt32(self.second)
  os:marshalInt32(self.sucTimes)
end
function SSingleInfoRes:unmarshal(os)
  self.second = os:unmarshalInt32()
  self.sucTimes = os:unmarshalInt32()
end
function SSingleInfoRes:sizepolicy(size)
  return size <= 65535
end
return SSingleInfoRes
