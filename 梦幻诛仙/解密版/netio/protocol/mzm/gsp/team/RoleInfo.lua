local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleId, name, level, menpai, gender, avatarId, avatarFrameid)
  self.roleId = roleId or nil
  self.name = name or nil
  self.level = level or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.avatarId = avatarId or nil
  self.avatarFrameid = avatarFrameid or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameid)
end
function RoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameid = os:unmarshalInt32()
end
return RoleInfo
