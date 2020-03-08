local CTrainPetReq = class("CTrainPetReq")
CTrainPetReq.TYPEID = 12605444
function CTrainPetReq:ctor(petId)
  self.id = 12605444
  self.petId = petId or nil
end
function CTrainPetReq:marshal(os)
  os:marshalInt64(self.petId)
end
function CTrainPetReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
end
function CTrainPetReq:sizepolicy(size)
  return size <= 65535
end
return CTrainPetReq
