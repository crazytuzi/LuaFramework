local SNotifyNewAvatar = class("SNotifyNewAvatar")
SNotifyNewAvatar.TYPEID = 12615174
function SNotifyNewAvatar:ctor(new_avatars)
  self.id = 12615174
  self.new_avatars = new_avatars or {}
end
function SNotifyNewAvatar:marshal(os)
  os:marshalCompactUInt32(table.getn(self.new_avatars))
  for _, v in ipairs(self.new_avatars) do
    v:marshal(os)
  end
end
function SNotifyNewAvatar:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.avatar.AvatarInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.new_avatars, v)
  end
end
function SNotifyNewAvatar:sizepolicy(size)
  return size <= 65535
end
return SNotifyNewAvatar
