local CGetSellItemReq = class("CGetSellItemReq")
CGetSellItemReq.TYPEID = 12584971
function CGetSellItemReq:ctor(shoppingid, itemid)
  self.id = 12584971
  self.shoppingid = shoppingid or nil
  self.itemid = itemid or nil
end
function CGetSellItemReq:marshal(os)
  os:marshalInt64(self.shoppingid)
  os:marshalInt32(self.itemid)
end
function CGetSellItemReq:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
end
function CGetSellItemReq:sizepolicy(size)
  return size <= 65535
end
return CGetSellItemReq
