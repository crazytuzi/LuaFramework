local OctetsStream = require("netio.OctetsStream")
local CommonRideRoleInfo = class("CommonRideRoleInfo")
function CommonRideRoleInfo:ctor(roleid, name, level, menpai, gender)
  self.roleid = roleid or nil
  self.name = name or nil
  self.level = level or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
end
function CommonRideRoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.gender)
end
function CommonRideRoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
end
return CommonRideRoleInfo
