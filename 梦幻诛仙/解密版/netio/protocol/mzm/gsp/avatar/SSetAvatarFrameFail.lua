local SSetAvatarFrameFail = class("SSetAvatarFrameFail")
SSetAvatarFrameFail.TYPEID = 12615183
SSetAvatarFrameFail.LOCKED_OR_EXPIRED = 1
function SSetAvatarFrameFail:ctor(retcode)
  self.id = 12615183
  self.retcode = retcode or nil
end
function SSetAvatarFrameFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SSetAvatarFrameFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SSetAvatarFrameFail:sizepolicy(size)
  return size <= 65535
end
return SSetAvatarFrameFail
