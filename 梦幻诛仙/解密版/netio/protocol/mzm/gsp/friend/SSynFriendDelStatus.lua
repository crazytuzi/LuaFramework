local SSynFriendDelStatus = class("SSynFriendDelStatus")
SSynFriendDelStatus.TYPEID = 12587031
function SSynFriendDelStatus:ctor(friendId, status)
  self.id = 12587031
  self.friendId = friendId or nil
  self.status = status or nil
end
function SSynFriendDelStatus:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.status)
end
function SSynFriendDelStatus:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.status = os:unmarshalInt32()
end
function SSynFriendDelStatus:sizepolicy(size)
  return size <= 65535
end
return SSynFriendDelStatus
