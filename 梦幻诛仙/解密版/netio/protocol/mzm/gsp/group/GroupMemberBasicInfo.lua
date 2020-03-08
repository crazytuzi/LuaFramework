local OctetsStream = require("netio.OctetsStream")
local GroupMemberBasicInfo = class("GroupMemberBasicInfo")
function GroupMemberBasicInfo:ctor(menpai, gender, avatarid, avatar_frame_id)
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.avatarid = avatarid or nil
  self.avatar_frame_id = avatar_frame_id or nil
end
function GroupMemberBasicInfo:marshal(os)
  os:marshalInt32(self.menpai)
  os:marshalUInt8(self.gender)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frame_id)
end
function GroupMemberBasicInfo:unmarshal(os)
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalUInt8()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frame_id = os:unmarshalInt32()
end
return GroupMemberBasicInfo
