local SDeleteItemAuctionRes = class("SDeleteItemAuctionRes")
SDeleteItemAuctionRes.TYPEID = 12601426
function SDeleteItemAuctionRes:ctor(marketId)
  self.id = 12601426
  self.marketId = marketId or nil
end
function SDeleteItemAuctionRes:marshal(os)
  os:marshalInt64(self.marketId)
end
function SDeleteItemAuctionRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function SDeleteItemAuctionRes:sizepolicy(size)
  return size <= 65535
end
return SDeleteItemAuctionRes
