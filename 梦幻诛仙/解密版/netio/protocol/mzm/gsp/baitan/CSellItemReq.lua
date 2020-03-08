local CSellItemReq = class("CSellItemReq")
CSellItemReq.TYPEID = 12584975
function CSellItemReq:ctor(bagid, itemKey, itemid, price, num)
  self.id = 12584975
  self.bagid = bagid or nil
  self.itemKey = itemKey or nil
  self.itemid = itemid or nil
  self.price = price or nil
  self.num = num or nil
end
function CSellItemReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.price)
  os:marshalInt32(self.num)
end
function CSellItemReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.itemKey = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CSellItemReq:sizepolicy(size)
  return size <= 65535
end
return CSellItemReq
