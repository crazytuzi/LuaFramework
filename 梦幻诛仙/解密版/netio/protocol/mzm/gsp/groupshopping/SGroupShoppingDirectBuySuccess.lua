local SGroupShoppingDirectBuySuccess = class("SGroupShoppingDirectBuySuccess")
SGroupShoppingDirectBuySuccess.TYPEID = 12623620
function SGroupShoppingDirectBuySuccess:ctor(group_shopping_item_cfgid)
  self.id = 12623620
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
end
function SGroupShoppingDirectBuySuccess:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
end
function SGroupShoppingDirectBuySuccess:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
end
function SGroupShoppingDirectBuySuccess:sizepolicy(size)
  return size <= 65535
end
return SGroupShoppingDirectBuySuccess
