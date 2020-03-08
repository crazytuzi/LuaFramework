local SAnimalFreeSuccess = class("SAnimalFreeSuccess")
SAnimalFreeSuccess.TYPEID = 12615437
function SAnimalFreeSuccess:ctor(animalid)
  self.id = 12615437
  self.animalid = animalid or nil
end
function SAnimalFreeSuccess:marshal(os)
  os:marshalInt64(self.animalid)
end
function SAnimalFreeSuccess:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function SAnimalFreeSuccess:sizepolicy(size)
  return size <= 65535
end
return SAnimalFreeSuccess
