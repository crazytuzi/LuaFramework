local SIdipBanRank = class("SIdipBanRank")
SIdipBanRank.TYPEID = 12601090
function SIdipBanRank:ctor(unbanTime, reason, rankType)
  self.id = 12601090
  self.unbanTime = unbanTime or nil
  self.reason = reason or nil
  self.rankType = rankType or nil
end
function SIdipBanRank:marshal(os)
  os:marshalInt64(self.unbanTime)
  os:marshalOctets(self.reason)
  os:marshalInt32(self.rankType)
end
function SIdipBanRank:unmarshal(os)
  self.unbanTime = os:unmarshalInt64()
  self.reason = os:unmarshalOctets()
  self.rankType = os:unmarshalInt32()
end
function SIdipBanRank:sizepolicy(size)
  return size <= 65535
end
return SIdipBanRank
