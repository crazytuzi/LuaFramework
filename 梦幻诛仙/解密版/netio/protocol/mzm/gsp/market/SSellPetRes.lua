local MarketPet = require("netio.protocol.mzm.gsp.market.MarketPet")
local SSellPetRes = class("SSellPetRes")
SSellPetRes.TYPEID = 12601374
function SSellPetRes:ctor(oldMarketId, marketPet)
  self.id = 12601374
  self.oldMarketId = oldMarketId or nil
  self.marketPet = marketPet or MarketPet.new()
end
function SSellPetRes:marshal(os)
  os:marshalInt64(self.oldMarketId)
  self.marketPet:marshal(os)
end
function SSellPetRes:unmarshal(os)
  self.oldMarketId = os:unmarshalInt64()
  self.marketPet = MarketPet.new()
  self.marketPet:unmarshal(os)
end
function SSellPetRes:sizepolicy(size)
  return size <= 65535
end
return SSellPetRes
