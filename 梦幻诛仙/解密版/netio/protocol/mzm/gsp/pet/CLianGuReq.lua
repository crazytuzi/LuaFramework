local CLianGuReq = class("CLianGuReq")
CLianGuReq.TYPEID = 12590594
function CLianGuReq:ctor(petId, aptType)
  self.id = 12590594
  self.petId = petId or nil
  self.aptType = aptType or nil
end
function CLianGuReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.aptType)
end
function CLianGuReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.aptType = os:unmarshalInt32()
end
function CLianGuReq:sizepolicy(size)
  return size <= 65535
end
return CLianGuReq
