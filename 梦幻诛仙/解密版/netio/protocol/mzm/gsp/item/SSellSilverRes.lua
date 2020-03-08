local SSellSilverRes = class("SSellSilverRes")
SSellSilverRes.TYPEID = 12584768
function SSellSilverRes:ctor(silvernum)
  self.id = 12584768
  self.silvernum = silvernum or nil
end
function SSellSilverRes:marshal(os)
  os:marshalInt32(self.silvernum)
end
function SSellSilverRes:unmarshal(os)
  self.silvernum = os:unmarshalInt32()
end
function SSellSilverRes:sizepolicy(size)
  return size <= 65535
end
return SSellSilverRes
