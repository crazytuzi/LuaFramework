local OctetsStream = require("netio.OctetsStream")
local FriendInfo = class("FriendInfo")
function FriendInfo:ctor(roleId, roleName, roleLevel, occupationId, sex, onlineStatus, relationValue, teamMemCount, delStatus, avatarId, avatarFrameId, remarkName)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.roleLevel = roleLevel or nil
  self.occupationId = occupationId or nil
  self.sex = sex or nil
  self.onlineStatus = onlineStatus or nil
  self.relationValue = relationValue or nil
  self.teamMemCount = teamMemCount or nil
  self.delStatus = delStatus or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
  self.remarkName = remarkName or nil
end
function FriendInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.roleLevel)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.sex)
  os:marshalInt32(self.onlineStatus)
  os:marshalInt32(self.relationValue)
  os:marshalInt32(self.teamMemCount)
  os:marshalInt32(self.delStatus)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
  os:marshalString(self.remarkName)
end
function FriendInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.roleLevel = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.sex = os:unmarshalInt32()
  self.onlineStatus = os:unmarshalInt32()
  self.relationValue = os:unmarshalInt32()
  self.teamMemCount = os:unmarshalInt32()
  self.delStatus = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
  self.remarkName = os:unmarshalString()
end
return FriendInfo
