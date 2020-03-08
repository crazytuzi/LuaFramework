local SActivateAvatarFail = class("SActivateAvatarFail")
SActivateAvatarFail.TYPEID = 12615171
SActivateAvatarFail.LOCKED = 0
SActivateAvatarFail.EXPIRED = 1
SActivateAvatarFail.NO_PROPERTY = 2
function SActivateAvatarFail:ctor(retcode)
  self.id = 12615171
  self.retcode = retcode or nil
end
function SActivateAvatarFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SActivateAvatarFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SActivateAvatarFail:sizepolicy(size)
  return size <= 65535
end
return SActivateAvatarFail
