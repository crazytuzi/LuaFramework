local SReSellExpireItemRes = class("SReSellExpireItemRes")
SReSellExpireItemRes.TYPEID = 12584969
function SReSellExpireItemRes:ctor(shoppingid, price)
  self.id = 12584969
  self.shoppingid = shoppingid or nil
  self.price = price or nil
end
function SReSellExpireItemRes:marshal(os)
  os:marshalInt64(self.shoppingid)
  os:marshalInt32(self.price)
end
function SReSellExpireItemRes:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
  self.price = os:unmarshalInt32()
end
function SReSellExpireItemRes:sizepolicy(size)
  return size <= 65535
end
return SReSellExpireItemRes
