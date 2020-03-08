local SGetPetItemLimitRes = class("SGetPetItemLimitRes")
SGetPetItemLimitRes.TYPEID = 12590654
function SGetPetItemLimitRes:ctor(lianguItemLeft, growItemLeft, petId)
  self.id = 12590654
  self.lianguItemLeft = lianguItemLeft or nil
  self.growItemLeft = growItemLeft or nil
  self.petId = petId or nil
end
function SGetPetItemLimitRes:marshal(os)
  os:marshalInt32(self.lianguItemLeft)
  os:marshalInt32(self.growItemLeft)
  os:marshalInt64(self.petId)
end
function SGetPetItemLimitRes:unmarshal(os)
  self.lianguItemLeft = os:unmarshalInt32()
  self.growItemLeft = os:unmarshalInt32()
  self.petId = os:unmarshalInt64()
end
function SGetPetItemLimitRes:sizepolicy(size)
  return size <= 65535
end
return SGetPetItemLimitRes
