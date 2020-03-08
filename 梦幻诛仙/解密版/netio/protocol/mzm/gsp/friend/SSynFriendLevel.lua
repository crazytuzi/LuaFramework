local SSynFriendLevel = class("SSynFriendLevel")
SSynFriendLevel.TYPEID = 12587023
function SSynFriendLevel:ctor(friendId, level)
  self.id = 12587023
  self.friendId = friendId or nil
  self.level = level or nil
end
function SSynFriendLevel:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.level)
end
function SSynFriendLevel:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
end
function SSynFriendLevel:sizepolicy(size)
  return size <= 65535
end
return SSynFriendLevel
