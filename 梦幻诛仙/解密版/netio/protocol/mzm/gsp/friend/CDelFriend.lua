local CDelFriend = class("CDelFriend")
CDelFriend.TYPEID = 12587011
function CDelFriend:ctor(friendId)
  self.id = 12587011
  self.friendId = friendId or nil
end
function CDelFriend:marshal(os)
  os:marshalInt64(self.friendId)
end
function CDelFriend:unmarshal(os)
  self.friendId = os:unmarshalInt64()
end
function CDelFriend:sizepolicy(size)
  return size <= 65535
end
return CDelFriend
