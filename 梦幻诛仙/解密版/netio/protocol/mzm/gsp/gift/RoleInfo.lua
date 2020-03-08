local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleId, roleName, gender, occupationId, avatarid, avatar_frame_id, level)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.gender = gender or nil
  self.occupationId = occupationId or nil
  self.avatarid = avatarid or nil
  self.avatar_frame_id = avatar_frame_id or nil
  self.level = level or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frame_id)
  os:marshalInt32(self.level)
end
function RoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.gender = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frame_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
end
return RoleInfo
