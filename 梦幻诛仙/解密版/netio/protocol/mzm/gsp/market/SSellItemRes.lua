local MarketItem = require("netio.protocol.mzm.gsp.market.MarketItem")
local SSellItemRes = class("SSellItemRes")
SSellItemRes.TYPEID = 12601367
function SSellItemRes:ctor(oldMarketId, marketItem)
  self.id = 12601367
  self.oldMarketId = oldMarketId or nil
  self.marketItem = marketItem or MarketItem.new()
end
function SSellItemRes:marshal(os)
  os:marshalInt64(self.oldMarketId)
  self.marketItem:marshal(os)
end
function SSellItemRes:unmarshal(os)
  self.oldMarketId = os:unmarshalInt64()
  self.marketItem = MarketItem.new()
  self.marketItem:unmarshal(os)
end
function SSellItemRes:sizepolicy(size)
  return size <= 65535
end
return SSellItemRes
