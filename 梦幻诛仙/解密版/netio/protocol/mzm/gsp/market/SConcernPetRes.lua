local MarketPet = require("netio.protocol.mzm.gsp.market.MarketPet")
local SConcernPetRes = class("SConcernPetRes")
SConcernPetRes.TYPEID = 12601377
function SConcernPetRes:ctor(concernMarketPet)
  self.id = 12601377
  self.concernMarketPet = concernMarketPet or MarketPet.new()
end
function SConcernPetRes:marshal(os)
  self.concernMarketPet:marshal(os)
end
function SConcernPetRes:unmarshal(os)
  self.concernMarketPet = MarketPet.new()
  self.concernMarketPet:unmarshal(os)
end
function SConcernPetRes:sizepolicy(size)
  return size <= 65535
end
return SConcernPetRes
