local GroupInfo = require("netio.protocol.mzm.gsp.group.GroupInfo")
local SJoinGroupNotify = class("SJoinGroupNotify")
SJoinGroupNotify.TYPEID = 12605202
function SJoinGroupNotify:ctor(inviterid, inviter_name, group_basic_info)
  self.id = 12605202
  self.inviterid = inviterid or nil
  self.inviter_name = inviter_name or nil
  self.group_basic_info = group_basic_info or GroupInfo.new()
end
function SJoinGroupNotify:marshal(os)
  os:marshalInt64(self.inviterid)
  os:marshalOctets(self.inviter_name)
  self.group_basic_info:marshal(os)
end
function SJoinGroupNotify:unmarshal(os)
  self.inviterid = os:unmarshalInt64()
  self.inviter_name = os:unmarshalOctets()
  self.group_basic_info = GroupInfo.new()
  self.group_basic_info:unmarshal(os)
end
function SJoinGroupNotify:sizepolicy(size)
  return size <= 65535
end
return SJoinGroupNotify
