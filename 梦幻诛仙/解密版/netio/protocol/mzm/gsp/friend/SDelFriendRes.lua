local SDelFriendRes = class("SDelFriendRes")
SDelFriendRes.TYPEID = 12587026
function SDelFriendRes:ctor(friendId)
  self.id = 12587026
  self.friendId = friendId or nil
end
function SDelFriendRes:marshal(os)
  os:marshalInt64(self.friendId)
end
function SDelFriendRes:unmarshal(os)
  self.friendId = os:unmarshalInt64()
end
function SDelFriendRes:sizepolicy(size)
  return size <= 65535
end
return SDelFriendRes
