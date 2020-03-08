local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local SJoinShoppingGroupSuccess = class("SJoinShoppingGroupSuccess")
SJoinShoppingGroupSuccess.TYPEID = 12623629
function SJoinShoppingGroupSuccess:ctor(group_info)
  self.id = 12623629
  self.group_info = group_info or ShoppingGroupInfo.new()
end
function SJoinShoppingGroupSuccess:marshal(os)
  self.group_info:marshal(os)
end
function SJoinShoppingGroupSuccess:unmarshal(os)
  self.group_info = ShoppingGroupInfo.new()
  self.group_info:unmarshal(os)
end
function SJoinShoppingGroupSuccess:sizepolicy(size)
  return size <= 65535
end
return SJoinShoppingGroupSuccess
