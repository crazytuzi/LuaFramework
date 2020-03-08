local OctetsStream = require("netio.OctetsStream")
local MarketPet = require("netio.protocol.mzm.gsp.market.MarketPet")
local AuctionPet = class("AuctionPet")
function AuctionPet:ctor(marketPet, isMaxPrice)
  self.marketPet = marketPet or MarketPet.new()
  self.isMaxPrice = isMaxPrice or nil
end
function AuctionPet:marshal(os)
  self.marketPet:marshal(os)
  os:marshalInt32(self.isMaxPrice)
end
function AuctionPet:unmarshal(os)
  self.marketPet = MarketPet.new()
  self.marketPet:unmarshal(os)
  self.isMaxPrice = os:unmarshalInt32()
end
return AuctionPet
