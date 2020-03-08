local SSynZheyaoCount = class("SSynZheyaoCount")
SSynZheyaoCount.TYPEID = 12587564
function SSynZheyaoCount:ctor(singleCount, doubleCount)
  self.id = 12587564
  self.singleCount = singleCount or nil
  self.doubleCount = doubleCount or nil
end
function SSynZheyaoCount:marshal(os)
  os:marshalInt32(self.singleCount)
  os:marshalInt32(self.doubleCount)
end
function SSynZheyaoCount:unmarshal(os)
  self.singleCount = os:unmarshalInt32()
  self.doubleCount = os:unmarshalInt32()
end
function SSynZheyaoCount:sizepolicy(size)
  return size <= 65535
end
return SSynZheyaoCount
