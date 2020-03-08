local OctetsStream = require("netio.OctetsStream")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local MyShoppingItem = class("MyShoppingItem")
MyShoppingItem.STATE_SELL = 0
MyShoppingItem.STATE_SELLED = 1
MyShoppingItem.STATE_EXPIRE = 2
function MyShoppingItem:ctor(shoppingid, item, price, sellNum, state)
  self.shoppingid = shoppingid or nil
  self.item = item or ItemInfo.new()
  self.price = price or nil
  self.sellNum = sellNum or nil
  self.state = state or nil
end
function MyShoppingItem:marshal(os)
  os:marshalInt64(self.shoppingid)
  self.item:marshal(os)
  os:marshalInt32(self.price)
  os:marshalInt32(self.sellNum)
  os:marshalInt32(self.state)
end
function MyShoppingItem:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
  self.item = ItemInfo.new()
  self.item:unmarshal(os)
  self.price = os:unmarshalInt32()
  self.sellNum = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
end
return MyShoppingItem
