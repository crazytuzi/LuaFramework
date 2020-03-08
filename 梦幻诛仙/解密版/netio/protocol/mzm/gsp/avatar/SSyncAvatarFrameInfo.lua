local SSyncAvatarFrameInfo = class("SSyncAvatarFrameInfo")
SSyncAvatarFrameInfo.TYPEID = 12615181
function SSyncAvatarFrameInfo:ctor(current_avatar_frame_id, unlocked_avatar_frame)
  self.id = 12615181
  self.current_avatar_frame_id = current_avatar_frame_id or nil
  self.unlocked_avatar_frame = unlocked_avatar_frame or {}
end
function SSyncAvatarFrameInfo:marshal(os)
  os:marshalInt32(self.current_avatar_frame_id)
  os:marshalCompactUInt32(table.getn(self.unlocked_avatar_frame))
  for _, v in ipairs(self.unlocked_avatar_frame) do
    v:marshal(os)
  end
end
function SSyncAvatarFrameInfo:unmarshal(os)
  self.current_avatar_frame_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.avatar.AvatarFrameInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.unlocked_avatar_frame, v)
  end
end
function SSyncAvatarFrameInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncAvatarFrameInfo
