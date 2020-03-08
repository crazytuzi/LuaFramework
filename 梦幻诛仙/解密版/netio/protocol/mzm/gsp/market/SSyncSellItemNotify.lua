local SSyncSellItemNotify = class("SSyncSellItemNotify")
SSyncSellItemNotify.TYPEID = 12601356
function SSyncSellItemNotify:ctor(marketId, itemId, restNum, sellNum)
  self.id = 12601356
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.restNum = restNum or nil
  self.sellNum = sellNum or nil
end
function SSyncSellItemNotify:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.restNum)
  os:marshalInt32(self.sellNum)
end
function SSyncSellItemNotify:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.restNum = os:unmarshalInt32()
  self.sellNum = os:unmarshalInt32()
end
function SSyncSellItemNotify:sizepolicy(size)
  return size <= 65535
end
return SSyncSellItemNotify
