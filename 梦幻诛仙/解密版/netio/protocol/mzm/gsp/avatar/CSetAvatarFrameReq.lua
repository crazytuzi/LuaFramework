local CSetAvatarFrameReq = class("CSetAvatarFrameReq")
CSetAvatarFrameReq.TYPEID = 12615186
function CSetAvatarFrameReq:ctor(avatar_frame_id)
  self.id = 12615186
  self.avatar_frame_id = avatar_frame_id or nil
end
function CSetAvatarFrameReq:marshal(os)
  os:marshalInt32(self.avatar_frame_id)
end
function CSetAvatarFrameReq:unmarshal(os)
  self.avatar_frame_id = os:unmarshalInt32()
end
function CSetAvatarFrameReq:sizepolicy(size)
  return size <= 65535
end
return CSetAvatarFrameReq
