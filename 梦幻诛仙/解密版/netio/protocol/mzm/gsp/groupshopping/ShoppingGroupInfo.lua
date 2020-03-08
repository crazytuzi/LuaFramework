local OctetsStream = require("netio.OctetsStream")
local ShoppingGroupInfo = class("ShoppingGroupInfo")
ShoppingGroupInfo.INCOMPLETED = 0
ShoppingGroupInfo.COMPLETED = 1
ShoppingGroupInfo.FAILED = 2
function ShoppingGroupInfo:ctor(group_id, group_shopping_item_cfgid, member_num, status, creator_role_id, creator_name, price, close_time)
  self.group_id = group_id or nil
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.member_num = member_num or nil
  self.status = status or nil
  self.creator_role_id = creator_role_id or nil
  self.creator_name = creator_name or nil
  self.price = price or nil
  self.close_time = close_time or nil
end
function ShoppingGroupInfo:marshal(os)
  os:marshalInt64(self.group_id)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt32(self.member_num)
  os:marshalInt32(self.status)
  os:marshalInt64(self.creator_role_id)
  os:marshalOctets(self.creator_name)
  os:marshalInt32(self.price)
  os:marshalInt32(self.close_time)
end
function ShoppingGroupInfo:unmarshal(os)
  self.group_id = os:unmarshalInt64()
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.member_num = os:unmarshalInt32()
  self.status = os:unmarshalInt32()
  self.creator_role_id = os:unmarshalInt64()
  self.creator_name = os:unmarshalOctets()
  self.price = os:unmarshalInt32()
  self.close_time = os:unmarshalInt32()
end
return ShoppingGroupInfo
