local OctetsStream = require("netio.OctetsStream")
local ShoppingItem = class("ShoppingItem")
function ShoppingItem:ctor(itemId, price, rise)
  self.itemId = itemId or nil
  self.price = price or nil
  self.rise = rise or nil
end
function ShoppingItem:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.rise)
end
function ShoppingItem:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.rise = os:unmarshalInt32()
end
return ShoppingItem
