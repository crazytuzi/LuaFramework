local SSynOnlineTimeRes = class("SSynOnlineTimeRes")
SSynOnlineTimeRes.TYPEID = 12593420
function SSynOnlineTimeRes:ctor(onlinetime)
  self.id = 12593420
  self.onlinetime = onlinetime or nil
end
function SSynOnlineTimeRes:marshal(os)
  os:marshalInt32(self.onlinetime)
end
function SSynOnlineTimeRes:unmarshal(os)
  self.onlinetime = os:unmarshalInt32()
end
function SSynOnlineTimeRes:sizepolicy(size)
  return size <= 65535
end
return SSynOnlineTimeRes
