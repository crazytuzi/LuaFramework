local CSellItemReq = class("CSellItemReq")
CSellItemReq.TYPEID = 12592643
function CSellItemReq:ctor(bagid, itemKey, itemId)
  self.id = 12592643
  self.bagid = bagid or nil
  self.itemKey = itemKey or nil
  self.itemId = itemId or nil
end
function CSellItemReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemId)
end
function CSellItemReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.itemKey = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
end
function CSellItemReq:sizepolicy(size)
  return size <= 65535
end
return CSellItemReq
