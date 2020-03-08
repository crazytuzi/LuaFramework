local ShoppingItem = require("netio.protocol.mzm.gsp.shanghui.ShoppingItem")
local SBuyItemRes = class("SBuyItemRes")
SBuyItemRes.TYPEID = 12592645
function SBuyItemRes:ctor(buyNum, costGold, canBuyNum, itemInfo)
  self.id = 12592645
  self.buyNum = buyNum or nil
  self.costGold = costGold or nil
  self.canBuyNum = canBuyNum or nil
  self.itemInfo = itemInfo or ShoppingItem.new()
end
function SBuyItemRes:marshal(os)
  os:marshalInt32(self.buyNum)
  os:marshalInt64(self.costGold)
  os:marshalInt32(self.canBuyNum)
  self.itemInfo:marshal(os)
end
function SBuyItemRes:unmarshal(os)
  self.buyNum = os:unmarshalInt32()
  self.costGold = os:unmarshalInt64()
  self.canBuyNum = os:unmarshalInt32()
  self.itemInfo = ShoppingItem.new()
  self.itemInfo:unmarshal(os)
end
function SBuyItemRes:sizepolicy(size)
  return size <= 65535
end
return SBuyItemRes
