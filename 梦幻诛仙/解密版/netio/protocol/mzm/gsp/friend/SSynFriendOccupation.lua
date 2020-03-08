local SSynFriendOccupation = class("SSynFriendOccupation")
SSynFriendOccupation.TYPEID = 12587037
function SSynFriendOccupation:ctor(friendId, occupationId)
  self.id = 12587037
  self.friendId = friendId or nil
  self.occupationId = occupationId or nil
end
function SSynFriendOccupation:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.occupationId)
end
function SSynFriendOccupation:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.occupationId = os:unmarshalInt32()
end
function SSynFriendOccupation:sizepolicy(size)
  return size <= 65535
end
return SSynFriendOccupation
