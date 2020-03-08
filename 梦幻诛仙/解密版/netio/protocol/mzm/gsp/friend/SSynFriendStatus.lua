local SSynFriendStatus = class("SSynFriendStatus")
SSynFriendStatus.TYPEID = 12587025
SSynFriendStatus.NORMAL = 1
SSynFriendStatus.CROSS_SERVER = 2
function SSynFriendStatus:ctor(friendId, status, reason)
  self.id = 12587025
  self.friendId = friendId or nil
  self.status = status or nil
  self.reason = reason or nil
end
function SSynFriendStatus:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.status)
  os:marshalInt32(self.reason)
end
function SSynFriendStatus:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.status = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SSynFriendStatus:sizepolicy(size)
  return size <= 65535
end
return SSynFriendStatus
