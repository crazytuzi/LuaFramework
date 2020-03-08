local SMemberAvatarChangedBrd = class("SMemberAvatarChangedBrd")
SMemberAvatarChangedBrd.TYPEID = 12588347
function SMemberAvatarChangedBrd:ctor(roleid, avatarId)
  self.id = 12588347
  self.roleid = roleid or nil
  self.avatarId = avatarId or nil
end
function SMemberAvatarChangedBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.avatarId)
end
function SMemberAvatarChangedBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.avatarId = os:unmarshalInt32()
end
function SMemberAvatarChangedBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberAvatarChangedBrd
