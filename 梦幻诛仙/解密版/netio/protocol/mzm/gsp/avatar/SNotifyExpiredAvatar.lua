local SNotifyExpiredAvatar = class("SNotifyExpiredAvatar")
SNotifyExpiredAvatar.TYPEID = 12615180
function SNotifyExpiredAvatar:ctor(current_avatar, active_avatar, expired_avatars)
  self.id = 12615180
  self.current_avatar = current_avatar or nil
  self.active_avatar = active_avatar or nil
  self.expired_avatars = expired_avatars or {}
end
function SNotifyExpiredAvatar:marshal(os)
  os:marshalInt32(self.current_avatar)
  os:marshalInt32(self.active_avatar)
  os:marshalCompactUInt32(table.getn(self.expired_avatars))
  for _, v in ipairs(self.expired_avatars) do
    v:marshal(os)
  end
end
function SNotifyExpiredAvatar:unmarshal(os)
  self.current_avatar = os:unmarshalInt32()
  self.active_avatar = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.avatar.AvatarInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.expired_avatars, v)
  end
end
function SNotifyExpiredAvatar:sizepolicy(size)
  return size <= 65535
end
return SNotifyExpiredAvatar
