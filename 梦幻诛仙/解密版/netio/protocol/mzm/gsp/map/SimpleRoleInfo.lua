local OctetsStream = require("netio.OctetsStream")
local SimpleRoleInfo = class("SimpleRoleInfo")
SimpleRoleInfo.MAIL = 1
SimpleRoleInfo.FEMAIL = 2
function SimpleRoleInfo:ctor(roleid, name, occupationId, level, gender, avatarId, avatarFrameid)
  self.roleid = roleid or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.level = level or nil
  self.gender = gender or nil
  self.avatarId = avatarId or nil
  self.avatarFrameid = avatarFrameid or nil
end
function SimpleRoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.level)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameid)
end
function SimpleRoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameid = os:unmarshalInt32()
end
return SimpleRoleInfo
