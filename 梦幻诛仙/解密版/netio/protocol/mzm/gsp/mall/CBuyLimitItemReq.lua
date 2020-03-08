local CBuyLimitItemReq = class("CBuyLimitItemReq")
CBuyLimitItemReq.TYPEID = 12585478
function CBuyLimitItemReq:ctor(itemid, count, clientyuanbao)
  self.id = 12585478
  self.itemid = itemid or nil
  self.count = count or nil
  self.clientyuanbao = clientyuanbao or nil
end
function CBuyLimitItemReq:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
  os:marshalInt64(self.clientyuanbao)
end
function CBuyLimitItemReq:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.clientyuanbao = os:unmarshalInt64()
end
function CBuyLimitItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyLimitItemReq
