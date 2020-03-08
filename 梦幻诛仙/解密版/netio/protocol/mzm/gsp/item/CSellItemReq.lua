local CSellItemReq = class("CSellItemReq")
CSellItemReq.TYPEID = 12584758
function CSellItemReq:ctor(bagid, uuid, num)
  self.id = 12584758
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.num = num or nil
end
function CSellItemReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
end
function CSellItemReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
function CSellItemReq:sizepolicy(size)
  return size <= 65535
end
return CSellItemReq
