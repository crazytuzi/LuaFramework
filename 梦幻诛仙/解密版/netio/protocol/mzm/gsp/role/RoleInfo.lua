local OctetsStream = require("netio.OctetsStream")
local AppellationInfo = require("netio.protocol.mzm.gsp.title.AppellationInfo")
local RoleInfo = class("RoleInfo")
RoleInfo.MAIL = 1
RoleInfo.FEMAIL = 2
function RoleInfo:ctor(roleId, openId, occupationId, level, name, teamId, onlineStatus, gender, teamMemberNum, gangId, gangName, friendSetting, deleteState, appellationInfo, hasHomeland, holdBanquest, avatarId, avatarFrameId)
  self.roleId = roleId or nil
  self.openId = openId or nil
  self.occupationId = occupationId or nil
  self.level = level or nil
  self.name = name or nil
  self.teamId = teamId or nil
  self.onlineStatus = onlineStatus or nil
  self.gender = gender or nil
  self.teamMemberNum = teamMemberNum or nil
  self.gangId = gangId or nil
  self.gangName = gangName or nil
  self.friendSetting = friendSetting or nil
  self.deleteState = deleteState or nil
  self.appellationInfo = appellationInfo or AppellationInfo.new()
  self.hasHomeland = hasHomeland or nil
  self.holdBanquest = holdBanquest or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.openId)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.level)
  os:marshalString(self.name)
  os:marshalInt64(self.teamId)
  os:marshalInt32(self.onlineStatus)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.teamMemberNum)
  os:marshalInt64(self.gangId)
  os:marshalString(self.gangName)
  os:marshalInt32(self.friendSetting)
  os:marshalInt32(self.deleteState)
  self.appellationInfo:marshal(os)
  os:marshalInt32(self.hasHomeland)
  os:marshalInt32(self.holdBanquest)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
end
function RoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.openId = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.teamId = os:unmarshalInt64()
  self.onlineStatus = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.teamMemberNum = os:unmarshalInt32()
  self.gangId = os:unmarshalInt64()
  self.gangName = os:unmarshalString()
  self.friendSetting = os:unmarshalInt32()
  self.deleteState = os:unmarshalInt32()
  self.appellationInfo = AppellationInfo.new()
  self.appellationInfo:unmarshal(os)
  self.hasHomeland = os:unmarshalInt32()
  self.holdBanquest = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
end
return RoleInfo
