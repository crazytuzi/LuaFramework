local PageItemInfo = require("netio.protocol.mzm.gsp.market.PageItemInfo")
local SQueryMarketPublicItemRes = class("SQueryMarketPublicItemRes")
SQueryMarketPublicItemRes.TYPEID = 12601392
function SQueryMarketPublicItemRes:ctor(pricesort, pageResult)
  self.id = 12601392
  self.pricesort = pricesort or nil
  self.pageResult = pageResult or PageItemInfo.new()
end
function SQueryMarketPublicItemRes:marshal(os)
  os:marshalInt32(self.pricesort)
  self.pageResult:marshal(os)
end
function SQueryMarketPublicItemRes:unmarshal(os)
  self.pricesort = os:unmarshalInt32()
  self.pageResult = PageItemInfo.new()
  self.pageResult:unmarshal(os)
end
function SQueryMarketPublicItemRes:sizepolicy(size)
  return size <= 65535
end
return SQueryMarketPublicItemRes
