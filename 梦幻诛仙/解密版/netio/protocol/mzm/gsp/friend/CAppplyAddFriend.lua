local CAppplyAddFriend = class("CAppplyAddFriend")
CAppplyAddFriend.TYPEID = 12587015
function CAppplyAddFriend:ctor(roleId, content)
  self.id = 12587015
  self.roleId = roleId or nil
  self.content = content or nil
end
function CAppplyAddFriend:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.content)
end
function CAppplyAddFriend:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.content = os:unmarshalString()
end
function CAppplyAddFriend:sizepolicy(size)
  return size <= 65535
end
return CAppplyAddFriend
