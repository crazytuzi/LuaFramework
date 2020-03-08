local SSynRemCommandRes = class("SSynRemCommandRes")
SSynRemCommandRes.TYPEID = 12594206
function SSynRemCommandRes:ctor(fighterid)
  self.id = 12594206
  self.fighterid = fighterid or nil
end
function SSynRemCommandRes:marshal(os)
  os:marshalInt32(self.fighterid)
end
function SSynRemCommandRes:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
end
function SSynRemCommandRes:sizepolicy(size)
  return size <= 65535
end
return SSynRemCommandRes
