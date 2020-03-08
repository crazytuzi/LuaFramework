local OctetsStream = require("netio.OctetsStream")
local GroupMemberInfo = class("GroupMemberInfo")
GroupMemberInfo.ONLINE_STATE_ONLINE = 1
GroupMemberInfo.ONLINE_STATE_OFFLINE = 2
GroupMemberInfo.MSG_STATE_ACCEPT = 1
GroupMemberInfo.MSG_STATE_REFUSE = 2
function GroupMemberInfo:ctor(roleid, name, level, menpai, gender, avatarid, avatar_frame_id, online_state, join_time)
  self.roleid = roleid or nil
  self.name = name or nil
  self.level = level or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.avatarid = avatarid or nil
  self.avatar_frame_id = avatar_frame_id or nil
  self.online_state = online_state or nil
  self.join_time = join_time or nil
end
function GroupMemberInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menpai)
  os:marshalUInt8(self.gender)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frame_id)
  os:marshalUInt8(self.online_state)
  os:marshalInt32(self.join_time)
end
function GroupMemberInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.level = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalUInt8()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frame_id = os:unmarshalInt32()
  self.online_state = os:unmarshalUInt8()
  self.join_time = os:unmarshalInt32()
end
return GroupMemberInfo
