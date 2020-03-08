local SSyncShoppingGroupSize = class("SSyncShoppingGroupSize")
SSyncShoppingGroupSize.TYPEID = 12623630
function SSyncShoppingGroupSize:ctor(group_id, member_num)
  self.id = 12623630
  self.group_id = group_id or nil
  self.member_num = member_num or nil
end
function SSyncShoppingGroupSize:marshal(os)
  os:marshalInt64(self.group_id)
  os:marshalInt32(self.member_num)
end
function SSyncShoppingGroupSize:unmarshal(os)
  self.group_id = os:unmarshalInt64()
  self.member_num = os:unmarshalInt32()
end
function SSyncShoppingGroupSize:sizepolicy(size)
  return size <= 65535
end
return SSyncShoppingGroupSize
