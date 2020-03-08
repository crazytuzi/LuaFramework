local SNotifyAvatarFrameExpired = class("SNotifyAvatarFrameExpired")
SNotifyAvatarFrameExpired.TYPEID = 12615188
function SNotifyAvatarFrameExpired:ctor(current_avatar_frame_id, expired_avatar_frame_ids)
  self.id = 12615188
  self.current_avatar_frame_id = current_avatar_frame_id or nil
  self.expired_avatar_frame_ids = expired_avatar_frame_ids or {}
end
function SNotifyAvatarFrameExpired:marshal(os)
  os:marshalInt32(self.current_avatar_frame_id)
  os:marshalCompactUInt32(table.getn(self.expired_avatar_frame_ids))
  for _, v in ipairs(self.expired_avatar_frame_ids) do
    os:marshalInt32(v)
  end
end
function SNotifyAvatarFrameExpired:unmarshal(os)
  self.current_avatar_frame_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.expired_avatar_frame_ids, v)
  end
end
function SNotifyAvatarFrameExpired:sizepolicy(size)
  return size <= 65535
end
return SNotifyAvatarFrameExpired
