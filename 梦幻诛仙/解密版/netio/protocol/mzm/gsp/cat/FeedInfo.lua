local OctetsStream = require("netio.OctetsStream")
local FeedInfo = class("FeedInfo")
function FeedInfo:ctor(roleid, role_name, feed_timestamp)
  self.roleid = roleid or nil
  self.role_name = role_name or nil
  self.feed_timestamp = feed_timestamp or nil
end
function FeedInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.feed_timestamp)
end
function FeedInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.feed_timestamp = os:unmarshalInt32()
end
return FeedInfo
