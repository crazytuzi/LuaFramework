local PageInfo = require("netio.protocol.mzm.gsp.baitan.PageInfo")
local SRefreshShopingListRes = class("SRefreshShopingListRes")
SRefreshShopingListRes.TYPEID = 12584995
function SRefreshShopingListRes:ctor(lastFreshTime, costGold, pageresult)
  self.id = 12584995
  self.lastFreshTime = lastFreshTime or nil
  self.costGold = costGold or nil
  self.pageresult = pageresult or PageInfo.new()
end
function SRefreshShopingListRes:marshal(os)
  os:marshalInt64(self.lastFreshTime)
  os:marshalInt32(self.costGold)
  self.pageresult:marshal(os)
end
function SRefreshShopingListRes:unmarshal(os)
  self.lastFreshTime = os:unmarshalInt64()
  self.costGold = os:unmarshalInt32()
  self.pageresult = PageInfo.new()
  self.pageresult:unmarshal(os)
end
function SRefreshShopingListRes:sizepolicy(size)
  return size <= 65535
end
return SRefreshShopingListRes
