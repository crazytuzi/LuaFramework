local SGetBigGroupShoppingItemInfoRes = class("SGetBigGroupShoppingItemInfoRes")
SGetBigGroupShoppingItemInfoRes.TYPEID = 12623637
function SGetBigGroupShoppingItemInfoRes:ctor(group_shopping_item_cfgid, remaining_num, bought_num, group_id, member_num)
  self.id = 12623637
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.remaining_num = remaining_num or nil
  self.bought_num = bought_num or nil
  self.group_id = group_id or nil
  self.member_num = member_num or nil
end
function SGetBigGroupShoppingItemInfoRes:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt32(self.remaining_num)
  os:marshalInt32(self.bought_num)
  os:marshalInt64(self.group_id)
  os:marshalInt32(self.member_num)
end
function SGetBigGroupShoppingItemInfoRes:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.remaining_num = os:unmarshalInt32()
  self.bought_num = os:unmarshalInt32()
  self.group_id = os:unmarshalInt64()
  self.member_num = os:unmarshalInt32()
end
function SGetBigGroupShoppingItemInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetBigGroupShoppingItemInfoRes
