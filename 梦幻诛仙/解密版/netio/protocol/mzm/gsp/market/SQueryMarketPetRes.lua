local PagePetInfo = require("netio.protocol.mzm.gsp.market.PagePetInfo")
local SQueryMarketPetRes = class("SQueryMarketPetRes")
SQueryMarketPetRes.TYPEID = 12601349
function SQueryMarketPetRes:ctor(pricesort, pageResult)
  self.id = 12601349
  self.pricesort = pricesort or nil
  self.pageResult = pageResult or PagePetInfo.new()
end
function SQueryMarketPetRes:marshal(os)
  os:marshalInt32(self.pricesort)
  self.pageResult:marshal(os)
end
function SQueryMarketPetRes:unmarshal(os)
  self.pricesort = os:unmarshalInt32()
  self.pageResult = PagePetInfo.new()
  self.pageResult:unmarshal(os)
end
function SQueryMarketPetRes:sizepolicy(size)
  return size <= 65535
end
return SQueryMarketPetRes
