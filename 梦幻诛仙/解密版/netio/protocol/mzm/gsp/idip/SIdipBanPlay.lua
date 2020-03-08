local SIdipBanPlay = class("SIdipBanPlay")
SIdipBanPlay.TYPEID = 12601094
function SIdipBanPlay:ctor(unbanTime, reason, playType)
  self.id = 12601094
  self.unbanTime = unbanTime or nil
  self.reason = reason or nil
  self.playType = playType or nil
end
function SIdipBanPlay:marshal(os)
  os:marshalInt64(self.unbanTime)
  os:marshalOctets(self.reason)
  os:marshalInt32(self.playType)
end
function SIdipBanPlay:unmarshal(os)
  self.unbanTime = os:unmarshalInt64()
  self.reason = os:unmarshalOctets()
  self.playType = os:unmarshalInt32()
end
function SIdipBanPlay:sizepolicy(size)
  return size <= 65535
end
return SIdipBanPlay
