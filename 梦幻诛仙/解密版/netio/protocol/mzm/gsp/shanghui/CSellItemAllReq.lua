local CSellItemAllReq = class("CSellItemAllReq")
CSellItemAllReq.TYPEID = 12592651
function CSellItemAllReq:ctor(bagid, itemKey, itemId, itemNum)
  self.id = 12592651
  self.bagid = bagid or nil
  self.itemKey = itemKey or nil
  self.itemId = itemId or nil
  self.itemNum = itemNum or nil
end
function CSellItemAllReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemNum)
end
function CSellItemAllReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.itemKey = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
function CSellItemAllReq:sizepolicy(size)
  return size <= 65535
end
return CSellItemAllReq
