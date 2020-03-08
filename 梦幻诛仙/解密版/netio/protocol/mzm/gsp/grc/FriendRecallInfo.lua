local OctetsStream = require("netio.OctetsStream")
local RecallUserInfo = require("netio.protocol.mzm.gsp.grc.RecallUserInfo")
local RecallRoleInfo = require("netio.protocol.mzm.gsp.grc.RecallRoleInfo")
local FriendRecallInfo = class("FriendRecallInfo")
function FriendRecallInfo:ctor(user_info, role_info, callback, state)
  self.user_info = user_info or RecallUserInfo.new()
  self.role_info = role_info or RecallRoleInfo.new()
  self.callback = callback or nil
  self.state = state or nil
end
function FriendRecallInfo:marshal(os)
  self.user_info:marshal(os)
  self.role_info:marshal(os)
  os:marshalInt32(self.callback)
  os:marshalInt32(self.state)
end
function FriendRecallInfo:unmarshal(os)
  self.user_info = RecallUserInfo.new()
  self.user_info:unmarshal(os)
  self.role_info = RecallRoleInfo.new()
  self.role_info:unmarshal(os)
  self.callback = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
end
return FriendRecallInfo
