local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local SCreateShoppingGroupSuccess = class("SCreateShoppingGroupSuccess")
SCreateShoppingGroupSuccess.TYPEID = 12623617
function SCreateShoppingGroupSuccess:ctor(group_info)
  self.id = 12623617
  self.group_info = group_info or ShoppingGroupInfo.new()
end
function SCreateShoppingGroupSuccess:marshal(os)
  self.group_info:marshal(os)
end
function SCreateShoppingGroupSuccess:unmarshal(os)
  self.group_info = ShoppingGroupInfo.new()
  self.group_info:unmarshal(os)
end
function SCreateShoppingGroupSuccess:sizepolicy(size)
  return size <= 65535
end
return SCreateShoppingGroupSuccess
