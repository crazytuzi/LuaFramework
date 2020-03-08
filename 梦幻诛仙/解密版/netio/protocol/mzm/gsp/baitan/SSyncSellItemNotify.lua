local SSyncSellItemNotify = class("SSyncSellItemNotify")
SSyncSellItemNotify.TYPEID = 12584976
function SSyncSellItemNotify:ctor(shoppingid, num, sellNum)
  self.id = 12584976
  self.shoppingid = shoppingid or nil
  self.num = num or nil
  self.sellNum = sellNum or nil
end
function SSyncSellItemNotify:marshal(os)
  os:marshalInt64(self.shoppingid)
  os:marshalInt32(self.num)
  os:marshalInt32(self.sellNum)
end
function SSyncSellItemNotify:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
  self.sellNum = os:unmarshalInt32()
end
function SSyncSellItemNotify:sizepolicy(size)
  return size <= 65535
end
return SSyncSellItemNotify
