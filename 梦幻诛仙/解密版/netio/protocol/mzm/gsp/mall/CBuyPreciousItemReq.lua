local CBuyPreciousItemReq = class("CBuyPreciousItemReq")
CBuyPreciousItemReq.TYPEID = 12585480
function CBuyPreciousItemReq:ctor(itemid, count, clientyuanbao)
  self.id = 12585480
  self.itemid = itemid or nil
  self.count = count or nil
  self.clientyuanbao = clientyuanbao or nil
end
function CBuyPreciousItemReq:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
  os:marshalInt64(self.clientyuanbao)
end
function CBuyPreciousItemReq:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.clientyuanbao = os:unmarshalInt64()
end
function CBuyPreciousItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyPreciousItemReq
