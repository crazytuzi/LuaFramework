local MarketItem = require("netio.protocol.mzm.gsp.market.MarketItem")
local SConcernItemRes = class("SConcernItemRes")
SConcernItemRes.TYPEID = 12601378
function SConcernItemRes:ctor(concernMarketItem)
  self.id = 12601378
  self.concernMarketItem = concernMarketItem or MarketItem.new()
end
function SConcernItemRes:marshal(os)
  self.concernMarketItem:marshal(os)
end
function SConcernItemRes:unmarshal(os)
  self.concernMarketItem = MarketItem.new()
  self.concernMarketItem:unmarshal(os)
end
function SConcernItemRes:sizepolicy(size)
  return size <= 65535
end
return SConcernItemRes
