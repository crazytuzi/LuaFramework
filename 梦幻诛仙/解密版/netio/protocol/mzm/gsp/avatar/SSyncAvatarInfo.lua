local SSyncAvatarInfo = class("SSyncAvatarInfo")
SSyncAvatarInfo.TYPEID = 12615170
function SSyncAvatarInfo:ctor(current_avatar, active_avatar, unlocked_avatars)
  self.id = 12615170
  self.current_avatar = current_avatar or nil
  self.active_avatar = active_avatar or nil
  self.unlocked_avatars = unlocked_avatars or {}
end
function SSyncAvatarInfo:marshal(os)
  os:marshalInt32(self.current_avatar)
  os:marshalInt32(self.active_avatar)
  os:marshalCompactUInt32(table.getn(self.unlocked_avatars))
  for _, v in ipairs(self.unlocked_avatars) do
    v:marshal(os)
  end
end
function SSyncAvatarInfo:unmarshal(os)
  self.current_avatar = os:unmarshalInt32()
  self.active_avatar = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.avatar.AvatarInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.unlocked_avatars, v)
  end
end
function SSyncAvatarInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncAvatarInfo
