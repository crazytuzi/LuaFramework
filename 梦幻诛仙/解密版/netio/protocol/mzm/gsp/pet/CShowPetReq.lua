local CShowPetReq = class("CShowPetReq")
CShowPetReq.TYPEID = 12590631
function CShowPetReq:ctor(petId)
  self.id = 12590631
  self.petId = petId or nil
end
function CShowPetReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CShowPetReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CShowPetReq:sizepolicy(size)
  return size <= 65535
end
return CShowPetReq
