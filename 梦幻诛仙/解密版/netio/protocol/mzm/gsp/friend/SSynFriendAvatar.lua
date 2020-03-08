local SSynFriendAvatar = class("SSynFriendAvatar")
SSynFriendAvatar.TYPEID = 12587038
function SSynFriendAvatar:ctor(friendId, avatarId)
  self.id = 12587038
  self.friendId = friendId or nil
  self.avatarId = avatarId or nil
end
function SSynFriendAvatar:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.avatarId)
end
function SSynFriendAvatar:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.avatarId = os:unmarshalInt32()
end
function SSynFriendAvatar:sizepolicy(size)
  return size <= 65535
end
return SSynFriendAvatar
