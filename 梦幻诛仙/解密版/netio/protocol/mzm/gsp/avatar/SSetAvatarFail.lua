local SSetAvatarFail = class("SSetAvatarFail")
SSetAvatarFail.TYPEID = 12615175
SSetAvatarFail.LOCKED = 0
SSetAvatarFail.EXPIRED = 1
function SSetAvatarFail:ctor(retcode)
  self.id = 12615175
  self.retcode = retcode or nil
end
function SSetAvatarFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SSetAvatarFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SSetAvatarFail:sizepolicy(size)
  return size <= 65535
end
return SSetAvatarFail
