local SSyncPlayerCount = class("SSyncPlayerCount")
SSyncPlayerCount.TYPEID = 12613643
function SSyncPlayerCount:ctor(count)
  self.id = 12613643
  self.count = count or nil
end
function SSyncPlayerCount:marshal(os)
  os:marshalInt32(self.count)
end
function SSyncPlayerCount:unmarshal(os)
  self.count = os:unmarshalInt32()
end
function SSyncPlayerCount:sizepolicy(size)
  return size <= 65535
end
return SSyncPlayerCount
