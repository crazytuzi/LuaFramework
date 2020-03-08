local STransfomPetPlaceRes = class("STransfomPetPlaceRes")
STransfomPetPlaceRes.TYPEID = 12590646
STransfomPetPlaceRes.TARGET_BAG = 0
STransfomPetPlaceRes.TARGET_DEPOT = 1
function STransfomPetPlaceRes:ctor(petId, target)
  self.id = 12590646
  self.petId = petId or nil
  self.target = target or nil
end
function STransfomPetPlaceRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.target)
end
function STransfomPetPlaceRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.target = os:unmarshalInt32()
end
function STransfomPetPlaceRes:sizepolicy(size)
  return size <= 65535
end
return STransfomPetPlaceRes
