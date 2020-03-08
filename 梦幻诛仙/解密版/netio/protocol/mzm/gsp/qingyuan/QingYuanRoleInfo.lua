local OctetsStream = require("netio.OctetsStream")
local QingYuanRoleInfo = class("QingYuanRoleInfo")
function QingYuanRoleInfo:ctor(role_id, role_name, gender, occupation_id, offline_time, role_level)
  self.role_id = role_id or nil
  self.role_name = role_name or nil
  self.gender = gender or nil
  self.occupation_id = occupation_id or nil
  self.offline_time = offline_time or nil
  self.role_level = role_level or nil
end
function QingYuanRoleInfo:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalString(self.role_name)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation_id)
  os:marshalInt64(self.offline_time)
  os:marshalInt32(self.role_level)
end
function QingYuanRoleInfo:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.role_name = os:unmarshalString()
  self.gender = os:unmarshalInt32()
  self.occupation_id = os:unmarshalInt32()
  self.offline_time = os:unmarshalInt64()
  self.role_level = os:unmarshalInt32()
end
return QingYuanRoleInfo
