local SMemberFriendSetChangedBrd = class("SMemberFriendSetChangedBrd")
SMemberFriendSetChangedBrd.TYPEID = 12588334
function SMemberFriendSetChangedBrd:ctor(roleid, friendSetting)
  self.id = 12588334
  self.roleid = roleid or nil
  self.friendSetting = friendSetting or nil
end
function SMemberFriendSetChangedBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.friendSetting)
end
function SMemberFriendSetChangedBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.friendSetting = os:unmarshalInt32()
end
function SMemberFriendSetChangedBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberFriendSetChangedBrd
