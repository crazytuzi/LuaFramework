local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local SGetShoppingGroupInfoRes = class("SGetShoppingGroupInfoRes")
SGetShoppingGroupInfoRes.TYPEID = 12623639
function SGetShoppingGroupInfoRes:ctor(group_info)
  self.id = 12623639
  self.group_info = group_info or ShoppingGroupInfo.new()
end
function SGetShoppingGroupInfoRes:marshal(os)
  self.group_info:marshal(os)
end
function SGetShoppingGroupInfoRes:unmarshal(os)
  self.group_info = ShoppingGroupInfo.new()
  self.group_info:unmarshal(os)
end
function SGetShoppingGroupInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetShoppingGroupInfoRes
