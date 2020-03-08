local SCreateShoppingGroupFail = class("SCreateShoppingGroupFail")
SCreateShoppingGroupFail.TYPEID = 12623628
SCreateShoppingGroupFail.INSUFFICIENT_YUANBAO = 1
SCreateShoppingGroupFail.SOLD_OUT = 2
SCreateShoppingGroupFail.CREATED = 3
SCreateShoppingGroupFail.REACH_BUY_LIMIT = 4
SCreateShoppingGroupFail.SYSTEM_BUSY = 5
function SCreateShoppingGroupFail:ctor(reason, group_shopping_item_cfgid)
  self.id = 12623628
  self.reason = reason or nil
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
end
function SCreateShoppingGroupFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.group_shopping_item_cfgid)
end
function SCreateShoppingGroupFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.group_shopping_item_cfgid = os:unmarshalInt32()
end
function SCreateShoppingGroupFail:sizepolicy(size)
  return size <= 65535
end
return SCreateShoppingGroupFail
