local SNotifyExtendedAvatar = class("SNotifyExtendedAvatar")
SNotifyExtendedAvatar.TYPEID = 12615179
function SNotifyExtendedAvatar:ctor(extended_avatars)
  self.id = 12615179
  self.extended_avatars = extended_avatars or {}
end
function SNotifyExtendedAvatar:marshal(os)
  os:marshalCompactUInt32(table.getn(self.extended_avatars))
  for _, v in ipairs(self.extended_avatars) do
    v:marshal(os)
  end
end
function SNotifyExtendedAvatar:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.avatar.AvatarInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.extended_avatars, v)
  end
end
function SNotifyExtendedAvatar:sizepolicy(size)
  return size <= 65535
end
return SNotifyExtendedAvatar
