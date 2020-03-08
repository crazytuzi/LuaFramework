local SPetAuctionBePassedRes = class("SPetAuctionBePassedRes")
SPetAuctionBePassedRes.TYPEID = 12601446
function SPetAuctionBePassedRes:ctor(marketId, petCfgId, myprice, newprice)
  self.id = 12601446
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.myprice = myprice or nil
  self.newprice = newprice or nil
end
function SPetAuctionBePassedRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.myprice)
  os:marshalInt32(self.newprice)
end
function SPetAuctionBePassedRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.myprice = os:unmarshalInt32()
  self.newprice = os:unmarshalInt32()
end
function SPetAuctionBePassedRes:sizepolicy(size)
  return size <= 65535
end
return SPetAuctionBePassedRes
