local CReSellExpireItemReq = class("CReSellExpireItemReq")
CReSellExpireItemReq.TYPEID = 12584990
function CReSellExpireItemReq:ctor(shoppingid, itemid, price)
  self.id = 12584990
  self.shoppingid = shoppingid or nil
  self.itemid = itemid or nil
  self.price = price or nil
end
function CReSellExpireItemReq:marshal(os)
  os:marshalInt64(self.shoppingid)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.price)
end
function CReSellExpireItemReq:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
end
function CReSellExpireItemReq:sizepolicy(size)
  return size <= 65535
end
return CReSellExpireItemReq
