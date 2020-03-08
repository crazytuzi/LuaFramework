local SBroadcastShoppingGroupCreated = class("SBroadcastShoppingGroupCreated")
SBroadcastShoppingGroupCreated.TYPEID = 12623621
function SBroadcastShoppingGroupCreated:ctor(group_id, group_shopping_item_cfgid, creator_role_id, creator_name)
  self.id = 12623621
  self.group_id = group_id or nil
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.creator_role_id = creator_role_id or nil
  self.creator_name = creator_name or nil
end
function SBroadcastShoppingGroupCreated:marshal(os)
  os:marshalInt64(self.group_id)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt64(self.creator_role_id)
  os:marshalOctets(self.creator_name)
end
function SBroadcastShoppingGroupCreated:unmarshal(os)
  self.group_id = os:unmarshalInt64()
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.creator_role_id = os:unmarshalInt64()
  self.creator_name = os:unmarshalOctets()
end
function SBroadcastShoppingGroupCreated:sizepolicy(size)
  return size <= 65535
end
return SBroadcastShoppingGroupCreated
