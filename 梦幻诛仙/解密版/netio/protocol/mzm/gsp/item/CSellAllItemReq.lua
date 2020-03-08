local CSellAllItemReq = class("CSellAllItemReq")
CSellAllItemReq.TYPEID = 12584776
function CSellAllItemReq:ctor(bagid, uuid)
  self.id = 12584776
  self.bagid = bagid or nil
  self.uuid = uuid or nil
end
function CSellAllItemReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
end
function CSellAllItemReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
end
function CSellAllItemReq:sizepolicy(size)
  return size <= 65535
end
return CSellAllItemReq
