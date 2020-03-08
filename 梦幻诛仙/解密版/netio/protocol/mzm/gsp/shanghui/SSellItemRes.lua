local ShoppingItem = require("netio.protocol.mzm.gsp.shanghui.ShoppingItem")
local SSellItemRes = class("SSellItemRes")
SSellItemRes.TYPEID = 12592641
function SSellItemRes:ctor(earnGold, canSellNum, itemInfo)
  self.id = 12592641
  self.earnGold = earnGold or nil
  self.canSellNum = canSellNum or nil
  self.itemInfo = itemInfo or ShoppingItem.new()
end
function SSellItemRes:marshal(os)
  os:marshalInt64(self.earnGold)
  os:marshalInt32(self.canSellNum)
  self.itemInfo:marshal(os)
end
function SSellItemRes:unmarshal(os)
  self.earnGold = os:unmarshalInt64()
  self.canSellNum = os:unmarshalInt32()
  self.itemInfo = ShoppingItem.new()
  self.itemInfo:unmarshal(os)
end
function SSellItemRes:sizepolicy(size)
  return size <= 65535
end
return SSellItemRes
