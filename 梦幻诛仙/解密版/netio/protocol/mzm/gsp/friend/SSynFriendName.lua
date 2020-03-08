local SSynFriendName = class("SSynFriendName")
SSynFriendName.TYPEID = 12587028
function SSynFriendName:ctor(friendId, name)
  self.id = 12587028
  self.friendId = friendId or nil
  self.name = name or nil
end
function SSynFriendName:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalString(self.name)
end
function SSynFriendName:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.name = os:unmarshalString()
end
function SSynFriendName:sizepolicy(size)
  return size <= 65535
end
return SSynFriendName
