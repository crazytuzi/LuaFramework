local CActivateAvatarReq = class("CActivateAvatarReq")
CActivateAvatarReq.TYPEID = 12615169
function CActivateAvatarReq:ctor(avatar)
  self.id = 12615169
  self.avatar = avatar or nil
end
function CActivateAvatarReq:marshal(os)
  os:marshalInt32(self.avatar)
end
function CActivateAvatarReq:unmarshal(os)
  self.avatar = os:unmarshalInt32()
end
function CActivateAvatarReq:sizepolicy(size)
  return size <= 65535
end
return CActivateAvatarReq
