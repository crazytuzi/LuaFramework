local SSellGoldRes = class("SSellGoldRes")
SSellGoldRes.TYPEID = 12584800
function SSellGoldRes:ctor(goldnum)
  self.id = 12584800
  self.goldnum = goldnum or nil
end
function SSellGoldRes:marshal(os)
  os:marshalInt32(self.goldnum)
end
function SSellGoldRes:unmarshal(os)
  self.goldnum = os:unmarshalInt32()
end
function SSellGoldRes:sizepolicy(size)
  return size <= 65535
end
return SSellGoldRes
