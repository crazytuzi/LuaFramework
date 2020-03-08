local CTransfomPetPlaceReq = class("CTransfomPetPlaceReq")
CTransfomPetPlaceReq.TYPEID = 12590618
CTransfomPetPlaceReq.TARGET_BAG = 0
CTransfomPetPlaceReq.TARGET_DEPOT = 1
function CTransfomPetPlaceReq:ctor(petId, target)
  self.id = 12590618
  self.petId = petId or nil
  self.target = target or nil
end
function CTransfomPetPlaceReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.target)
end
function CTransfomPetPlaceReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.target = os:unmarshalInt32()
end
function CTransfomPetPlaceReq:sizepolicy(size)
  return size <= 65535
end
return CTransfomPetPlaceReq
