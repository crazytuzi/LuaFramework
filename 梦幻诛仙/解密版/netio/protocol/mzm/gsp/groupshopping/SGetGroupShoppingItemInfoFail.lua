local SGetGroupShoppingItemInfoFail = class("SGetGroupShoppingItemInfoFail")
SGetGroupShoppingItemInfoFail.TYPEID = 12623640
SGetGroupShoppingItemInfoFail.SYSTEM_BUSY = 1
function SGetGroupShoppingItemInfoFail:ctor(reason, group_shopping_item_cfgid)
  self.id = 12623640
  self.reason = reason or nil
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
end
function SGetGroupShoppingItemInfoFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.group_shopping_item_cfgid)
end
function SGetGroupShoppingItemInfoFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.group_shopping_item_cfgid = os:unmarshalInt32()
end
function SGetGroupShoppingItemInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetGroupShoppingItemInfoFail
