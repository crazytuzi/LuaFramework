local SPetAuctionSuccessRes = class("SPetAuctionSuccessRes")
SPetAuctionSuccessRes.TYPEID = 12601447
function SPetAuctionSuccessRes:ctor(marketId, petCfgId)
  self.id = 12601447
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
end
function SPetAuctionSuccessRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
end
function SPetAuctionSuccessRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
end
function SPetAuctionSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SPetAuctionSuccessRes
