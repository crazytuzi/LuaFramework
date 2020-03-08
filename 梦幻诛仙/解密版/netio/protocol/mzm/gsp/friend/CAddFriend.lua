local CAddFriend = class("CAddFriend")
CAddFriend.TYPEID = 12587033
function CAddFriend:ctor(roleId)
  self.id = 12587033
  self.roleId = roleId or nil
end
function CAddFriend:marshal(os)
  os:marshalInt64(self.roleId)
end
function CAddFriend:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CAddFriend:sizepolicy(size)
  return size <= 65535
end
return CAddFriend
