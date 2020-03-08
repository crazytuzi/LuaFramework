local PagePetInfo = require("netio.protocol.mzm.gsp.market.PagePetInfo")
local SQueryMarketPublicPetRes = class("SQueryMarketPublicPetRes")
SQueryMarketPublicPetRes.TYPEID = 12601390
function SQueryMarketPublicPetRes:ctor(pricesort, pageResult)
  self.id = 12601390
  self.pricesort = pricesort or nil
  self.pageResult = pageResult or PagePetInfo.new()
end
function SQueryMarketPublicPetRes:marshal(os)
  os:marshalInt32(self.pricesort)
  self.pageResult:marshal(os)
end
function SQueryMarketPublicPetRes:unmarshal(os)
  self.pricesort = os:unmarshalInt32()
  self.pageResult = PagePetInfo.new()
  self.pageResult:unmarshal(os)
end
function SQueryMarketPublicPetRes:sizepolicy(size)
  return size <= 65535
end
return SQueryMarketPublicPetRes
