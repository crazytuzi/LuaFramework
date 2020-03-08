local SGroupShoppingDirectBuyFail = class("SGroupShoppingDirectBuyFail")
SGroupShoppingDirectBuyFail.TYPEID = 12623626
SGroupShoppingDirectBuyFail.INSUFFICIENT_YUANBAO = 1
SGroupShoppingDirectBuyFail.REACH_BUY_LIMIT = 2
SGroupShoppingDirectBuyFail.NOT_STARTED = 3
SGroupShoppingDirectBuyFail.FULL_BAG = 4
function SGroupShoppingDirectBuyFail:ctor(reason, group_shopping_item_cfgid)
  self.id = 12623626
  self.reason = reason or nil
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
end
function SGroupShoppingDirectBuyFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.group_shopping_item_cfgid)
end
function SGroupShoppingDirectBuyFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.group_shopping_item_cfgid = os:unmarshalInt32()
end
function SGroupShoppingDirectBuyFail:sizepolicy(size)
  return size <= 65535
end
return SGroupShoppingDirectBuyFail
