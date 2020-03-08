local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleId, roleName, gender, occupationId, avatarId, avatarFrameId, roleLevel)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.gender = gender or nil
  self.occupationId = occupationId or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
  self.roleLevel = roleLevel or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
  os:marshalInt32(self.roleLevel)
end
function RoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.gender = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
  self.roleLevel = os:unmarshalInt32()
end
return RoleInfo
