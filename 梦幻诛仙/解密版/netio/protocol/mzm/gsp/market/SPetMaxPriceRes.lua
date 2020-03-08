local SPetMaxPriceRes = class("SPetMaxPriceRes")
SPetMaxPriceRes.TYPEID = 12601452
function SPetMaxPriceRes:ctor(marketId, petCfgId, maxprice)
  self.id = 12601452
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.maxprice = maxprice or nil
end
function SPetMaxPriceRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.maxprice)
end
function SPetMaxPriceRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.maxprice = os:unmarshalInt32()
end
function SPetMaxPriceRes:sizepolicy(size)
  return size <= 65535
end
return SPetMaxPriceRes
