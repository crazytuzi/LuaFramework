local SUsePetChangeModelItemSuccess = class("SUsePetChangeModelItemSuccess")
SUsePetChangeModelItemSuccess.TYPEID = 12590711
function SUsePetChangeModelItemSuccess:ctor(pet_id)
  self.id = 12590711
  self.pet_id = pet_id or nil
end
function SUsePetChangeModelItemSuccess:marshal(os)
  os:marshalInt64(self.pet_id)
end
function SUsePetChangeModelItemSuccess:unmarshal(os)
  self.pet_id = os:unmarshalInt64()
end
function SUsePetChangeModelItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUsePetChangeModelItemSuccess
