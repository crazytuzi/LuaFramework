local GroupShoppingBanInfo = require("netio.protocol.mzm.gsp.groupshopping.GroupShoppingBanInfo")
local SBroadcastGroupShoppingBanChanged = class("SBroadcastGroupShoppingBanChanged")
SBroadcastGroupShoppingBanChanged.TYPEID = 12623622
function SBroadcastGroupShoppingBanChanged:ctor(info)
  self.id = 12623622
  self.info = info or GroupShoppingBanInfo.new()
end
function SBroadcastGroupShoppingBanChanged:marshal(os)
  self.info:marshal(os)
end
function SBroadcastGroupShoppingBanChanged:unmarshal(os)
  self.info = GroupShoppingBanInfo.new()
  self.info:unmarshal(os)
end
function SBroadcastGroupShoppingBanChanged:sizepolicy(size)
  return size <= 65535
end
return SBroadcastGroupShoppingBanChanged
