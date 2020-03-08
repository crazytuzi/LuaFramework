local CBuyItemReq = class("CBuyItemReq")
CBuyItemReq.TYPEID = 12592644
function CBuyItemReq:ctor(curGold, itemId, itemNum)
  self.id = 12592644
  self.curGold = curGold or nil
  self.itemId = itemId or nil
  self.itemNum = itemNum or nil
end
function CBuyItemReq:marshal(os)
  os:marshalInt64(self.curGold)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemNum)
end
function CBuyItemReq:unmarshal(os)
  self.curGold = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
function CBuyItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyItemReq
