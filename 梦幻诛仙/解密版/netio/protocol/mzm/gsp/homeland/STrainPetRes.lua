local STrainPetRes = class("STrainPetRes")
STrainPetRes.TYPEID = 12605445
function STrainPetRes:ctor(petId, addExpNum, dayTtrainPetCount)
  self.id = 12605445
  self.petId = petId or nil
  self.addExpNum = addExpNum or nil
  self.dayTtrainPetCount = dayTtrainPetCount or nil
end
function STrainPetRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.addExpNum)
  os:marshalInt32(self.dayTtrainPetCount)
end
function STrainPetRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.addExpNum = os:unmarshalInt32()
  self.dayTtrainPetCount = os:unmarshalInt32()
end
function STrainPetRes:sizepolicy(size)
  return size <= 65535
end
return STrainPetRes
