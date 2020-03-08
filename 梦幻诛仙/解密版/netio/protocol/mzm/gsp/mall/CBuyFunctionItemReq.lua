local CBuyFunctionItemReq = class("CBuyFunctionItemReq")
CBuyFunctionItemReq.TYPEID = 12585484
function CBuyFunctionItemReq:ctor(itemid, count, clientyuanbao)
  self.id = 12585484
  self.itemid = itemid or nil
  self.count = count or nil
  self.clientyuanbao = clientyuanbao or nil
end
function CBuyFunctionItemReq:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
  os:marshalInt64(self.clientyuanbao)
end
function CBuyFunctionItemReq:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.clientyuanbao = os:unmarshalInt64()
end
function CBuyFunctionItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyFunctionItemReq
