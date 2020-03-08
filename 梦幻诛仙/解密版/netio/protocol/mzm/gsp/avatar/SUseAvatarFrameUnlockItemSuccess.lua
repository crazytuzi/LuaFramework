local SUseAvatarFrameUnlockItemSuccess = class("SUseAvatarFrameUnlockItemSuccess")
SUseAvatarFrameUnlockItemSuccess.TYPEID = 12615187
function SUseAvatarFrameUnlockItemSuccess:ctor(avatar_frame_id, is_new, expire_time)
  self.id = 12615187
  self.avatar_frame_id = avatar_frame_id or nil
  self.is_new = is_new or nil
  self.expire_time = expire_time or nil
end
function SUseAvatarFrameUnlockItemSuccess:marshal(os)
  os:marshalInt32(self.avatar_frame_id)
  os:marshalInt32(self.is_new)
  os:marshalInt32(self.expire_time)
end
function SUseAvatarFrameUnlockItemSuccess:unmarshal(os)
  self.avatar_frame_id = os:unmarshalInt32()
  self.is_new = os:unmarshalInt32()
  self.expire_time = os:unmarshalInt32()
end
function SUseAvatarFrameUnlockItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseAvatarFrameUnlockItemSuccess
