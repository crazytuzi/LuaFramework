local PageItemInfo = require("netio.protocol.mzm.gsp.market.PageItemInfo")
local SQueryMarketItemRes = class("SQueryMarketItemRes")
SQueryMarketItemRes.TYPEID = 12601362
function SQueryMarketItemRes:ctor(pricesort, pageResult)
  self.id = 12601362
  self.pricesort = pricesort or nil
  self.pageResult = pageResult or PageItemInfo.new()
end
function SQueryMarketItemRes:marshal(os)
  os:marshalInt32(self.pricesort)
  self.pageResult:marshal(os)
end
function SQueryMarketItemRes:unmarshal(os)
  self.pricesort = os:unmarshalInt32()
  self.pageResult = PageItemInfo.new()
  self.pageResult:unmarshal(os)
end
function SQueryMarketItemRes:sizepolicy(size)
  return size <= 65535
end
return SQueryMarketItemRes
