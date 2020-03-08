local SSynFriendAvatarFrame = class("SSynFriendAvatarFrame")
SSynFriendAvatarFrame.TYPEID = 12587039
function SSynFriendAvatarFrame:ctor(friendId, avatarFrameId)
  self.id = 12587039
  self.friendId = friendId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function SSynFriendAvatarFrame:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.avatarFrameId)
end
function SSynFriendAvatarFrame:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.avatarFrameId = os:unmarshalInt32()
end
function SSynFriendAvatarFrame:sizepolicy(size)
  return size <= 65535
end
return SSynFriendAvatarFrame
