local OctetsStream = require("netio.OctetsStream")
local ShoppingItem = class("ShoppingItem")
function ShoppingItem:ctor(index, itemid, num, price, isneed)
  self.index = index or nil
  self.itemid = itemid or nil
  self.num = num or nil
  self.price = price or nil
  self.isneed = isneed or nil
end
function ShoppingItem:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.num)
  os:marshalInt32(self.price)
  os:marshalInt32(self.isneed)
end
function ShoppingItem:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.isneed = os:unmarshalInt32()
end
return ShoppingItem
