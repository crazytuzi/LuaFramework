local SSetAvatarFrameSuccess = class("SSetAvatarFrameSuccess")
SSetAvatarFrameSuccess.TYPEID = 12615184
function SSetAvatarFrameSuccess:ctor(avatar_frame_id)
  self.id = 12615184
  self.avatar_frame_id = avatar_frame_id or nil
end
function SSetAvatarFrameSuccess:marshal(os)
  os:marshalInt32(self.avatar_frame_id)
end
function SSetAvatarFrameSuccess:unmarshal(os)
  self.avatar_frame_id = os:unmarshalInt32()
end
function SSetAvatarFrameSuccess:sizepolicy(size)
  return size <= 65535
end
return SSetAvatarFrameSuccess
