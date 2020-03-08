local SBroadcastShoppingGroupSize = class("SBroadcastShoppingGroupSize")
SBroadcastShoppingGroupSize.TYPEID = 12623634
function SBroadcastShoppingGroupSize:ctor(group_id, group_shopping_item_cfgid, member_num, member_role_id, member_name)
  self.id = 12623634
  self.group_id = group_id or nil
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.member_num = member_num or nil
  self.member_role_id = member_role_id or nil
  self.member_name = member_name or nil
end
function SBroadcastShoppingGroupSize:marshal(os)
  os:marshalInt64(self.group_id)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt32(self.member_num)
  os:marshalInt64(self.member_role_id)
  os:marshalOctets(self.member_name)
end
function SBroadcastShoppingGroupSize:unmarshal(os)
  self.group_id = os:unmarshalInt64()
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.member_num = os:unmarshalInt32()
  self.member_role_id = os:unmarshalInt64()
  self.member_name = os:unmarshalOctets()
end
function SBroadcastShoppingGroupSize:sizepolicy(size)
  return size <= 65535
end
return SBroadcastShoppingGroupSize
