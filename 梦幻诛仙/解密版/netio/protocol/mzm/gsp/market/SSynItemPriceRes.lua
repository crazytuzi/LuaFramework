local MarketItem = require("netio.protocol.mzm.gsp.market.MarketItem")
local SSynItemPriceRes = class("SSynItemPriceRes")
SSynItemPriceRes.TYPEID = 12601454
function SSynItemPriceRes:ctor(marketitem)
  self.id = 12601454
  self.marketitem = marketitem or MarketItem.new()
end
function SSynItemPriceRes:marshal(os)
  self.marketitem:marshal(os)
end
function SSynItemPriceRes:unmarshal(os)
  self.marketitem = MarketItem.new()
  self.marketitem:unmarshal(os)
end
function SSynItemPriceRes:sizepolicy(size)
  return size <= 65535
end
return SSynItemPriceRes
