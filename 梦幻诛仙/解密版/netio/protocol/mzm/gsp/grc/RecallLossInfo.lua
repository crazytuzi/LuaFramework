local OctetsStream = require("netio.OctetsStream")
local RecallUserInfo = require("netio.protocol.mzm.gsp.grc.RecallUserInfo")
local RecallRoleInfo = require("netio.protocol.mzm.gsp.grc.RecallRoleInfo")
local RecallLossInfo = class("RecallLossInfo")
function RecallLossInfo:ctor(user_info, role_info, start_time, be_recall_num, invite_time)
  self.user_info = user_info or RecallUserInfo.new()
  self.role_info = role_info or RecallRoleInfo.new()
  self.start_time = start_time or nil
  self.be_recall_num = be_recall_num or nil
  self.invite_time = invite_time or nil
end
function RecallLossInfo:marshal(os)
  self.user_info:marshal(os)
  self.role_info:marshal(os)
  os:marshalInt32(self.start_time)
  os:marshalInt32(self.be_recall_num)
  os:marshalInt32(self.invite_time)
end
function RecallLossInfo:unmarshal(os)
  self.user_info = RecallUserInfo.new()
  self.user_info:unmarshal(os)
  self.role_info = RecallRoleInfo.new()
  self.role_info:unmarshal(os)
  self.start_time = os:unmarshalInt32()
  self.be_recall_num = os:unmarshalInt32()
  self.invite_time = os:unmarshalInt32()
end
return RecallLossInfo
