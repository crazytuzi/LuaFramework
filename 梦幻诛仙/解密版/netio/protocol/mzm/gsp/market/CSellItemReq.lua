local CSellItemReq = class("CSellItemReq")
CSellItemReq.TYPEID = 12601353
function CSellItemReq:ctor(itemKey, itemId, price, num)
  self.id = 12601353
  self.itemKey = itemKey or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.num = num or nil
end
function CSellItemReq:marshal(os)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.num)
end
function CSellItemReq:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CSellItemReq:sizepolicy(size)
  return size <= 65535
end
return CSellItemReq
