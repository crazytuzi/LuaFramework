local SGetSmallGroupShoppingItemInfoRes = class("SGetSmallGroupShoppingItemInfoRes")
SGetSmallGroupShoppingItemInfoRes.TYPEID = 12623625
function SGetSmallGroupShoppingItemInfoRes:ctor(group_shopping_item_cfgid, remaining_num, bought_num, shopping_group_num)
  self.id = 12623625
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.remaining_num = remaining_num or nil
  self.bought_num = bought_num or nil
  self.shopping_group_num = shopping_group_num or nil
end
function SGetSmallGroupShoppingItemInfoRes:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt32(self.remaining_num)
  os:marshalInt32(self.bought_num)
  os:marshalInt32(self.shopping_group_num)
end
function SGetSmallGroupShoppingItemInfoRes:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.remaining_num = os:unmarshalInt32()
  self.bought_num = os:unmarshalInt32()
  self.shopping_group_num = os:unmarshalInt32()
end
function SGetSmallGroupShoppingItemInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetSmallGroupShoppingItemInfoRes
