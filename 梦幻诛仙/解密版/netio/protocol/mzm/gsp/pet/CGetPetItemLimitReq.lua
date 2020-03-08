local CGetPetItemLimitReq = class("CGetPetItemLimitReq")
CGetPetItemLimitReq.TYPEID = 12590655
function CGetPetItemLimitReq:ctor(petId)
  self.id = 12590655
  self.petId = petId or nil
end
function CGetPetItemLimitReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CGetPetItemLimitReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CGetPetItemLimitReq:sizepolicy(size)
  return size <= 65535
end
return CGetPetItemLimitReq
