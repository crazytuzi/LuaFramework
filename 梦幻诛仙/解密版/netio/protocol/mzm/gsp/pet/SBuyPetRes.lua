local SBuyPetRes = class("SBuyPetRes")
SBuyPetRes.TYPEID = 12590632
function SBuyPetRes:ctor(petCfgId)
  self.id = 12590632
  self.petCfgId = petCfgId or nil
end
function SBuyPetRes:marshal(os)
  os:marshalInt32(self.petCfgId)
end
function SBuyPetRes:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
end
function SBuyPetRes:sizepolicy(size)
  return size <= 65535
end
return SBuyPetRes
