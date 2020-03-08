local SIdipBanRole = class("SIdipBanRole")
SIdipBanRole.TYPEID = 12601099
function SIdipBanRole:ctor(unbanTime, reason)
  self.id = 12601099
  self.unbanTime = unbanTime or nil
  self.reason = reason or nil
end
function SIdipBanRole:marshal(os)
  os:marshalInt64(self.unbanTime)
  os:marshalOctets(self.reason)
end
function SIdipBanRole:unmarshal(os)
  self.unbanTime = os:unmarshalInt64()
  self.reason = os:unmarshalOctets()
end
function SIdipBanRole:sizepolicy(size)
  return size <= 65535
end
return SIdipBanRole
