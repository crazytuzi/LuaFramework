local OctetsStream = require("netio.OctetsStream")
local RecomandFriendInfo = class("RecomandFriendInfo")
function RecomandFriendInfo:ctor(roleId, roleName, roleLevel, isGrcFriend, isOnline, occupationId, sex, friendSet, avatarId, avatarFrameId)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.roleLevel = roleLevel or nil
  self.isGrcFriend = isGrcFriend or nil
  self.isOnline = isOnline or nil
  self.occupationId = occupationId or nil
  self.sex = sex or nil
  self.friendSet = friendSet or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function RecomandFriendInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.roleLevel)
  os:marshalInt32(self.isGrcFriend)
  os:marshalInt32(self.isOnline)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.sex)
  os:marshalInt32(self.friendSet)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
end
function RecomandFriendInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.roleLevel = os:unmarshalInt32()
  self.isGrcFriend = os:unmarshalInt32()
  self.isOnline = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.sex = os:unmarshalInt32()
  self.friendSet = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
end
return RecomandFriendInfo
