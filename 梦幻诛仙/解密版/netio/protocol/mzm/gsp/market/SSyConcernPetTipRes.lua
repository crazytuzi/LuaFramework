local MarketPet = require("netio.protocol.mzm.gsp.market.MarketPet")
local SSyConcernPetTipRes = class("SSyConcernPetTipRes")
SSyConcernPetTipRes.TYPEID = 12601388
function SSyConcernPetTipRes:ctor(marketPet)
  self.id = 12601388
  self.marketPet = marketPet or MarketPet.new()
end
function SSyConcernPetTipRes:marshal(os)
  self.marketPet:marshal(os)
end
function SSyConcernPetTipRes:unmarshal(os)
  self.marketPet = MarketPet.new()
  self.marketPet:unmarshal(os)
end
function SSyConcernPetTipRes:sizepolicy(size)
  return size <= 65535
end
return SSyConcernPetTipRes
