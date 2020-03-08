local SSetAvatarSuccess = class("SSetAvatarSuccess")
SSetAvatarSuccess.TYPEID = 12615173
function SSetAvatarSuccess:ctor(avatar)
  self.id = 12615173
  self.avatar = avatar or nil
end
function SSetAvatarSuccess:marshal(os)
  os:marshalInt32(self.avatar)
end
function SSetAvatarSuccess:unmarshal(os)
  self.avatar = os:unmarshalInt32()
end
function SSetAvatarSuccess:sizepolicy(size)
  return size <= 65535
end
return SSetAvatarSuccess
