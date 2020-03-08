local SPetAuctionRes = class("SPetAuctionRes")
SPetAuctionRes.TYPEID = 12601430
function SPetAuctionRes:ctor(marketId, petCfgId, price, endTime)
  self.id = 12601430
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.price = price or nil
  self.endTime = endTime or nil
end
function SPetAuctionRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.price)
  os:marshalInt64(self.endTime)
end
function SPetAuctionRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.endTime = os:unmarshalInt64()
end
function SPetAuctionRes:sizepolicy(size)
  return size <= 65535
end
return SPetAuctionRes
