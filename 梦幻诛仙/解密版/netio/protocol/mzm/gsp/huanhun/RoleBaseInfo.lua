local OctetsStream = require("netio.OctetsStream")
local RoleBaseInfo = class("RoleBaseInfo")
function RoleBaseInfo:ctor(roleId, name, occupationid, level, gender)
  self.roleId = roleId or nil
  self.name = name or nil
  self.occupationid = occupationid or nil
  self.level = level or nil
  self.gender = gender or nil
end
function RoleBaseInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationid)
  os:marshalInt32(self.level)
  os:marshalInt32(self.gender)
end
function RoleBaseInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupationid = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
end
return RoleBaseInfo
