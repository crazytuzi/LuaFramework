local OctetsStream = require("netio.OctetsStream")
local RecallUserInfo = require("netio.protocol.mzm.gsp.grc.RecallUserInfo")
local RecallRoleInfo = require("netio.protocol.mzm.gsp.grc.RecallRoleInfo")
local BindVitalityInfo = class("BindVitalityInfo")
function BindVitalityInfo:ctor(user_info, role_info, vitality, update_time, bind_time, state)
  self.user_info = user_info or RecallUserInfo.new()
  self.role_info = role_info or RecallRoleInfo.new()
  self.vitality = vitality or nil
  self.update_time = update_time or nil
  self.bind_time = bind_time or nil
  self.state = state or nil
end
function BindVitalityInfo:marshal(os)
  self.user_info:marshal(os)
  self.role_info:marshal(os)
  os:marshalInt32(self.vitality)
  os:marshalInt32(self.update_time)
  os:marshalInt32(self.bind_time)
  os:marshalUInt8(self.state)
end
function BindVitalityInfo:unmarshal(os)
  self.user_info = RecallUserInfo.new()
  self.user_info:unmarshal(os)
  self.role_info = RecallRoleInfo.new()
  self.role_info:unmarshal(os)
  self.vitality = os:unmarshalInt32()
  self.update_time = os:unmarshalInt32()
  self.bind_time = os:unmarshalInt32()
  self.state = os:unmarshalUInt8()
end
return BindVitalityInfo
