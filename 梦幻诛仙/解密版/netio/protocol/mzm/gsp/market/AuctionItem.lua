local OctetsStream = require("netio.OctetsStream")
local MarketItem = require("netio.protocol.mzm.gsp.market.MarketItem")
local AuctionItem = class("AuctionItem")
function AuctionItem:ctor(marketItem, isMaxPrice)
  self.marketItem = marketItem or MarketItem.new()
  self.isMaxPrice = isMaxPrice or nil
end
function AuctionItem:marshal(os)
  self.marketItem:marshal(os)
  os:marshalInt32(self.isMaxPrice)
end
function AuctionItem:unmarshal(os)
  self.marketItem = MarketItem.new()
  self.marketItem:unmarshal(os)
  self.isMaxPrice = os:unmarshalInt32()
end
return AuctionItem
