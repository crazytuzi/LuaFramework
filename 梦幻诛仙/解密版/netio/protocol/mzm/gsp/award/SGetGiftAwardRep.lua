local SGetGiftAwardRep = class("SGetGiftAwardRep")
SGetGiftAwardRep.TYPEID = 12583444
function SGetGiftAwardRep:ctor(giftAwardCfgId, result)
  self.id = 12583444
  self.giftAwardCfgId = giftAwardCfgId or nil
  self.result = result or nil
end
function SGetGiftAwardRep:marshal(os)
  os:marshalInt32(self.giftAwardCfgId)
  os:marshalUInt8(self.result)
end
function SGetGiftAwardRep:unmarshal(os)
  self.giftAwardCfgId = os:unmarshalInt32()
  self.result = os:unmarshalUInt8()
end
function SGetGiftAwardRep:sizepolicy(size)
  return size <= 65535
end
return SGetGiftAwardRep
