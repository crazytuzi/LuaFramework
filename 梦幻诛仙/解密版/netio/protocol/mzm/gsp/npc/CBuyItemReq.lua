local CBuyItemReq = class("CBuyItemReq")
CBuyItemReq.TYPEID = 12586757
function CBuyItemReq:ctor(npcId, serviceId, itemId, itemCount, clientGold, clientSilver)
  self.id = 12586757
  self.npcId = npcId or nil
  self.serviceId = serviceId or nil
  self.itemId = itemId or nil
  self.itemCount = itemCount or nil
  self.clientGold = clientGold or nil
  self.clientSilver = clientSilver or nil
end
function CBuyItemReq:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalInt32(self.serviceId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemCount)
  os:marshalInt64(self.clientGold)
  os:marshalInt64(self.clientSilver)
end
function CBuyItemReq:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.serviceId = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.itemCount = os:unmarshalInt32()
  self.clientGold = os:unmarshalInt64()
  self.clientSilver = os:unmarshalInt64()
end
function CBuyItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyItemReq
