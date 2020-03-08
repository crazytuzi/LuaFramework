local CSetAvatarReq = class("CSetAvatarReq")
CSetAvatarReq.TYPEID = 12615172
function CSetAvatarReq:ctor(avatar)
  self.id = 12615172
  self.avatar = avatar or nil
end
function CSetAvatarReq:marshal(os)
  os:marshalInt32(self.avatar)
end
function CSetAvatarReq:unmarshal(os)
  self.avatar = os:unmarshalInt32()
end
function CSetAvatarReq:sizepolicy(size)
  return size <= 65535
end
return CSetAvatarReq
