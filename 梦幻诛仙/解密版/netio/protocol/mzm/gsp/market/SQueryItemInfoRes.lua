local MarketItem = require("netio.protocol.mzm.gsp.market.MarketItem")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SQueryItemInfoRes = class("SQueryItemInfoRes")
SQueryItemInfoRes.TYPEID = 12601355
function SQueryItemInfoRes:ctor(marketId, itemId, price, marketItem, itemInfo, sellerRoleId)
  self.id = 12601355
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.marketItem = marketItem or MarketItem.new()
  self.itemInfo = itemInfo or ItemInfo.new()
  self.sellerRoleId = sellerRoleId or nil
end
function SQueryItemInfoRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  self.marketItem:marshal(os)
  self.itemInfo:marshal(os)
  os:marshalInt64(self.sellerRoleId)
end
function SQueryItemInfoRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.marketItem = MarketItem.new()
  self.marketItem:unmarshal(os)
  self.itemInfo = ItemInfo.new()
  self.itemInfo:unmarshal(os)
  self.sellerRoleId = os:unmarshalInt64()
end
function SQueryItemInfoRes:sizepolicy(size)
  return size <= 65535
end
return SQueryItemInfoRes
