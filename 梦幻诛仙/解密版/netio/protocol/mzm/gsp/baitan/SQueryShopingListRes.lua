local PageInfo = require("netio.protocol.mzm.gsp.baitan.PageInfo")
local SQueryShopingListRes = class("SQueryShopingListRes")
SQueryShopingListRes.TYPEID = 12584992
function SQueryShopingListRes:ctor(lastFreshTime, pageresult)
  self.id = 12584992
  self.lastFreshTime = lastFreshTime or nil
  self.pageresult = pageresult or PageInfo.new()
end
function SQueryShopingListRes:marshal(os)
  os:marshalInt64(self.lastFreshTime)
  self.pageresult:marshal(os)
end
function SQueryShopingListRes:unmarshal(os)
  self.lastFreshTime = os:unmarshalInt64()
  self.pageresult = PageInfo.new()
  self.pageresult:unmarshal(os)
end
function SQueryShopingListRes:sizepolicy(size)
  return size <= 65535
end
return SQueryShopingListRes
