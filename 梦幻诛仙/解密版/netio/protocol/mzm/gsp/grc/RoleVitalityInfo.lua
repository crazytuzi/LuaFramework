local OctetsStream = require("netio.OctetsStream")
local RecallUserInfo = require("netio.protocol.mzm.gsp.grc.RecallUserInfo")
local RecallRoleInfo = require("netio.protocol.mzm.gsp.grc.RecallRoleInfo")
local RoleVitalityInfo = class("RoleVitalityInfo")
function RoleVitalityInfo:ctor(user_info, role_info, update_time, vitality)
  self.user_info = user_info or RecallUserInfo.new()
  self.role_info = role_info or RecallRoleInfo.new()
  self.update_time = update_time or nil
  self.vitality = vitality or nil
end
function RoleVitalityInfo:marshal(os)
  self.user_info:marshal(os)
  self.role_info:marshal(os)
  os:marshalInt32(self.update_time)
  os:marshalInt32(self.vitality)
end
function RoleVitalityInfo:unmarshal(os)
  self.user_info = RecallUserInfo.new()
  self.user_info:unmarshal(os)
  self.role_info = RecallRoleInfo.new()
  self.role_info:unmarshal(os)
  self.update_time = os:unmarshalInt32()
  self.vitality = os:unmarshalInt32()
end
return RoleVitalityInfo
