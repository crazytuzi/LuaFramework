local CAbandonItemReq = class("CAbandonItemReq")
CAbandonItemReq.TYPEID = 12584761
function CAbandonItemReq:ctor(bagid, uuid, num)
  self.id = 12584761
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.num = num or nil
end
function CAbandonItemReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
end
function CAbandonItemReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
function CAbandonItemReq:sizepolicy(size)
  return size <= 65535
end
return CAbandonItemReq
