local SFriendNeedValidate = class("SFriendNeedValidate")
SFriendNeedValidate.TYPEID = 12587032
function SFriendNeedValidate:ctor(roleId, name)
  self.id = 12587032
  self.roleId = roleId or nil
  self.name = name or nil
end
function SFriendNeedValidate:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
end
function SFriendNeedValidate:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
end
function SFriendNeedValidate:sizepolicy(size)
  return size <= 65535
end
return SFriendNeedValidate
