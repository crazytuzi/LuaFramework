local PageItemInfo = require("netio.protocol.mzm.gsp.market.PageItemInfo")
local SQueryMarketItemWithLevelRes = class("SQueryMarketItemWithLevelRes")
SQueryMarketItemWithLevelRes.TYPEID = 12601397
function SQueryMarketItemWithLevelRes:ctor(pricesort, level, pubOrsell, pageResult)
  self.id = 12601397
  self.pricesort = pricesort or nil
  self.level = level or nil
  self.pubOrsell = pubOrsell or nil
  self.pageResult = pageResult or PageItemInfo.new()
end
function SQueryMarketItemWithLevelRes:marshal(os)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.level)
  os:marshalInt32(self.pubOrsell)
  self.pageResult:marshal(os)
end
function SQueryMarketItemWithLevelRes:unmarshal(os)
  self.pricesort = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.pubOrsell = os:unmarshalInt32()
  self.pageResult = PageItemInfo.new()
  self.pageResult:unmarshal(os)
end
function SQueryMarketItemWithLevelRes:sizepolicy(size)
  return size <= 65535
end
return SQueryMarketItemWithLevelRes
