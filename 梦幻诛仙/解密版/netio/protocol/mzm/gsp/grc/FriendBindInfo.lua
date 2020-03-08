local OctetsStream = require("netio.OctetsStream")
local RecallUserInfo = require("netio.protocol.mzm.gsp.grc.RecallUserInfo")
local FriendBindInfo = class("FriendBindInfo")
function FriendBindInfo:ctor(user_info, bind_time)
  self.user_info = user_info or RecallUserInfo.new()
  self.bind_time = bind_time or nil
end
function FriendBindInfo:marshal(os)
  self.user_info:marshal(os)
  os:marshalInt32(self.bind_time)
end
function FriendBindInfo:unmarshal(os)
  self.user_info = RecallUserInfo.new()
  self.user_info:unmarshal(os)
  self.bind_time = os:unmarshalInt32()
end
return FriendBindInfo
