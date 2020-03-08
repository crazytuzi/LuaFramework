local PagePetInfo = require("netio.protocol.mzm.gsp.market.PagePetInfo")
local SQueryMarketPetWithLevelRes = class("SQueryMarketPetWithLevelRes")
SQueryMarketPetWithLevelRes.TYPEID = 12601400
function SQueryMarketPetWithLevelRes:ctor(pricesort, level, pubOrsell, pageResult)
  self.id = 12601400
  self.pricesort = pricesort or nil
  self.level = level or nil
  self.pubOrsell = pubOrsell or nil
  self.pageResult = pageResult or PagePetInfo.new()
end
function SQueryMarketPetWithLevelRes:marshal(os)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.level)
  os:marshalInt32(self.pubOrsell)
  self.pageResult:marshal(os)
end
function SQueryMarketPetWithLevelRes:unmarshal(os)
  self.pricesort = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.pubOrsell = os:unmarshalInt32()
  self.pageResult = PagePetInfo.new()
  self.pageResult:unmarshal(os)
end
function SQueryMarketPetWithLevelRes:sizepolicy(size)
  return size <= 65535
end
return SQueryMarketPetWithLevelRes
