local MyShoppingItem = require("netio.protocol.mzm.gsp.baitan.MyShoppingItem")
local SSellItemRes = class("SSellItemRes")
SSellItemRes.TYPEID = 12584982
function SSellItemRes:ctor(myShoppingItem)
  self.id = 12584982
  self.myShoppingItem = myShoppingItem or MyShoppingItem.new()
end
function SSellItemRes:marshal(os)
  self.myShoppingItem:marshal(os)
end
function SSellItemRes:unmarshal(os)
  self.myShoppingItem = MyShoppingItem.new()
  self.myShoppingItem:unmarshal(os)
end
function SSellItemRes:sizepolicy(size)
  return size <= 65535
end
return SSellItemRes
