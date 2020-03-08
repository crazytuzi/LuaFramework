local CSellPetReq = class("CSellPetReq")
CSellPetReq.TYPEID = 12590629
function CSellPetReq:ctor(petId)
  self.id = 12590629
  self.petId = petId or nil
end
function CSellPetReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CSellPetReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CSellPetReq:sizepolicy(size)
  return size <= 65535
end
return CSellPetReq
