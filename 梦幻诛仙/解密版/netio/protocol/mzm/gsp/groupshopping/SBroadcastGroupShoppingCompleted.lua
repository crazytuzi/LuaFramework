local SBroadcastGroupShoppingCompleted = class("SBroadcastGroupShoppingCompleted")
SBroadcastGroupShoppingCompleted.TYPEID = 12623635
function SBroadcastGroupShoppingCompleted:ctor(group_shopping_item_cfgid, creator_role_id, creator_name)
  self.id = 12623635
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.creator_role_id = creator_role_id or nil
  self.creator_name = creator_name or nil
end
function SBroadcastGroupShoppingCompleted:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt64(self.creator_role_id)
  os:marshalOctets(self.creator_name)
end
function SBroadcastGroupShoppingCompleted:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.creator_role_id = os:unmarshalInt64()
  self.creator_name = os:unmarshalOctets()
end
function SBroadcastGroupShoppingCompleted:sizepolicy(size)
  return size <= 65535
end
return SBroadcastGroupShoppingCompleted
