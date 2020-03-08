local CBuyFashionDressItemReq = class("CBuyFashionDressItemReq")
CBuyFashionDressItemReq.TYPEID = 12585485
function CBuyFashionDressItemReq:ctor(itemid, count, clientyuanbao)
  self.id = 12585485
  self.itemid = itemid or nil
  self.count = count or nil
  self.clientyuanbao = clientyuanbao or nil
end
function CBuyFashionDressItemReq:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
  os:marshalInt64(self.clientyuanbao)
end
function CBuyFashionDressItemReq:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.clientyuanbao = os:unmarshalInt64()
end
function CBuyFashionDressItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyFashionDressItemReq
