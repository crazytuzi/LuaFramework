local SMemberAvatarFrameChangedBrd = class("SMemberAvatarFrameChangedBrd")
SMemberAvatarFrameChangedBrd.TYPEID = 12588348
function SMemberAvatarFrameChangedBrd:ctor(roleid, avatarFrameId)
  self.id = 12588348
  self.roleid = roleid or nil
  self.avatarFrameId = avatarFrameId or nil
end
function SMemberAvatarFrameChangedBrd:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.avatarFrameId)
end
function SMemberAvatarFrameChangedBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.avatarFrameId = os:unmarshalInt32()
end
function SMemberAvatarFrameChangedBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberAvatarFrameChangedBrd
