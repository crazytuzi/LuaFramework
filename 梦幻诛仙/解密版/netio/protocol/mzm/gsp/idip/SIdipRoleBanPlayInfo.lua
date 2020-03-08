local SIdipRoleBanPlayInfo = class("SIdipRoleBanPlayInfo")
SIdipRoleBanPlayInfo.TYPEID = 12601098
function SIdipRoleBanPlayInfo:ctor(name, unbanTime, reason, playType)
  self.id = 12601098
  self.name = name or nil
  self.unbanTime = unbanTime or nil
  self.reason = reason or nil
  self.playType = playType or nil
end
function SIdipRoleBanPlayInfo:marshal(os)
  os:marshalOctets(self.name)
  os:marshalInt64(self.unbanTime)
  os:marshalOctets(self.reason)
  os:marshalInt32(self.playType)
end
function SIdipRoleBanPlayInfo:unmarshal(os)
  self.name = os:unmarshalOctets()
  self.unbanTime = os:unmarshalInt64()
  self.reason = os:unmarshalOctets()
  self.playType = os:unmarshalInt32()
end
function SIdipRoleBanPlayInfo:sizepolicy(size)
  return size <= 65535
end
return SIdipRoleBanPlayInfo
