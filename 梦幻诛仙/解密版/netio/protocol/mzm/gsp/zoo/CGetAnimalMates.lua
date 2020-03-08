local CGetAnimalMates = class("CGetAnimalMates")
CGetAnimalMates.TYPEID = 12615445
function CGetAnimalMates:ctor(animalid)
  self.id = 12615445
  self.animalid = animalid or nil
end
function CGetAnimalMates:marshal(os)
  os:marshalInt64(self.animalid)
end
function CGetAnimalMates:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function CGetAnimalMates:sizepolicy(size)
  return size <= 65535
end
return CGetAnimalMates
