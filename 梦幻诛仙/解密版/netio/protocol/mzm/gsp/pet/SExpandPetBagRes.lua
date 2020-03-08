local SExpandPetBagRes = class("SExpandPetBagRes")
SExpandPetBagRes.TYPEID = 12590628
function SExpandPetBagRes:ctor(bagSize)
  self.id = 12590628
  self.bagSize = bagSize or nil
end
function SExpandPetBagRes:marshal(os)
  os:marshalInt32(self.bagSize)
end
function SExpandPetBagRes:unmarshal(os)
  self.bagSize = os:unmarshalInt32()
end
function SExpandPetBagRes:sizepolicy(size)
  return size <= 65535
end
return SExpandPetBagRes
