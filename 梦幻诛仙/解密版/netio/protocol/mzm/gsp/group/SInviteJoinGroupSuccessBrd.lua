local GroupMemberInfo = require("netio.protocol.mzm.gsp.group.GroupMemberInfo")
local SInviteJoinGroupSuccessBrd = class("SInviteJoinGroupSuccessBrd")
SInviteJoinGroupSuccessBrd.TYPEID = 12605218
function SInviteJoinGroupSuccessBrd:ctor(groupid, inviter, newmember, info_version)
  self.id = 12605218
  self.groupid = groupid or nil
  self.inviter = inviter or nil
  self.newmember = newmember or GroupMemberInfo.new()
  self.info_version = info_version or nil
end
function SInviteJoinGroupSuccessBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt64(self.inviter)
  self.newmember:marshal(os)
  os:marshalInt64(self.info_version)
end
function SInviteJoinGroupSuccessBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.inviter = os:unmarshalInt64()
  self.newmember = GroupMemberInfo.new()
  self.newmember:unmarshal(os)
  self.info_version = os:unmarshalInt64()
end
function SInviteJoinGroupSuccessBrd:sizepolicy(size)
  return size <= 65535
end
return SInviteJoinGroupSuccessBrd
