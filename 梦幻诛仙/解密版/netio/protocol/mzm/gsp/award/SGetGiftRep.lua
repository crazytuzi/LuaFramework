local SGetGiftRep = class("SGetGiftRep")
SGetGiftRep.TYPEID = 12583447
function SGetGiftRep:ctor(useType, alCount)
  self.id = 12583447
  self.useType = useType or nil
  self.alCount = alCount or nil
end
function SGetGiftRep:marshal(os)
  os:marshalInt32(self.useType)
  os:marshalInt32(self.alCount)
end
function SGetGiftRep:unmarshal(os)
  self.useType = os:unmarshalInt32()
  self.alCount = os:unmarshalInt32()
end
function SGetGiftRep:sizepolicy(size)
  return size <= 65535
end
return SGetGiftRep
