local MarketItem = require("netio.protocol.mzm.gsp.market.MarketItem")
local SSyConcernItemTipRes = class("SSyConcernItemTipRes")
SSyConcernItemTipRes.TYPEID = 12601387
function SSyConcernItemTipRes:ctor(marketItem)
  self.id = 12601387
  self.marketItem = marketItem or MarketItem.new()
end
function SSyConcernItemTipRes:marshal(os)
  self.marketItem:marshal(os)
end
function SSyConcernItemTipRes:unmarshal(os)
  self.marketItem = MarketItem.new()
  self.marketItem:unmarshal(os)
end
function SSyConcernItemTipRes:sizepolicy(size)
  return size <= 65535
end
return SSyConcernItemTipRes
