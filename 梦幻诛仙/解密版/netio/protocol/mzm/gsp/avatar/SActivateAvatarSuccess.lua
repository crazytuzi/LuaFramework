local SActivateAvatarSuccess = class("SActivateAvatarSuccess")
SActivateAvatarSuccess.TYPEID = 12615176
function SActivateAvatarSuccess:ctor(avatar)
  self.id = 12615176
  self.avatar = avatar or nil
end
function SActivateAvatarSuccess:marshal(os)
  os:marshalInt32(self.avatar)
end
function SActivateAvatarSuccess:unmarshal(os)
  self.avatar = os:unmarshalInt32()
end
function SActivateAvatarSuccess:sizepolicy(size)
  return size <= 65535
end
return SActivateAvatarSuccess
