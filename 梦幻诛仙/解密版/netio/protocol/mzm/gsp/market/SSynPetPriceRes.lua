local MarketPet = require("netio.protocol.mzm.gsp.market.MarketPet")
local SSynPetPriceRes = class("SSynPetPriceRes")
SSynPetPriceRes.TYPEID = 12601453
function SSynPetPriceRes:ctor(marketpet)
  self.id = 12601453
  self.marketpet = marketpet or MarketPet.new()
end
function SSynPetPriceRes:marshal(os)
  self.marketpet:marshal(os)
end
function SSynPetPriceRes:unmarshal(os)
  self.marketpet = MarketPet.new()
  self.marketpet:unmarshal(os)
end
function SSynPetPriceRes:sizepolicy(size)
  return size <= 65535
end
return SSynPetPriceRes
