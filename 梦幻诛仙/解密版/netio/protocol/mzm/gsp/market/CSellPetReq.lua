local CSellPetReq = class("CSellPetReq")
CSellPetReq.TYPEID = 12601365
function CSellPetReq:ctor(petId, price)
  self.id = 12601365
  self.petId = petId or nil
  self.price = price or nil
end
function CSellPetReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.price)
end
function CSellPetReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.price = os:unmarshalInt32()
end
function CSellPetReq:sizepolicy(size)
  return size <= 65535
end
return CSellPetReq
