local CBuyCurrentLimitItemReq = class("CBuyCurrentLimitItemReq")
CBuyCurrentLimitItemReq.TYPEID = 12585486
function CBuyCurrentLimitItemReq:ctor(malltype, itemid, count, clientyuanbao)
  self.id = 12585486
  self.malltype = malltype or nil
  self.itemid = itemid or nil
  self.count = count or nil
  self.clientyuanbao = clientyuanbao or nil
end
function CBuyCurrentLimitItemReq:marshal(os)
  os:marshalInt32(self.malltype)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
  os:marshalInt64(self.clientyuanbao)
end
function CBuyCurrentLimitItemReq:unmarshal(os)
  self.malltype = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.clientyuanbao = os:unmarshalInt64()
end
function CBuyCurrentLimitItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyCurrentLimitItemReq
