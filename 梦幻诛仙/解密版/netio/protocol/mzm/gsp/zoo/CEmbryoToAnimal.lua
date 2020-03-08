local CEmbryoToAnimal = class("CEmbryoToAnimal")
CEmbryoToAnimal.TYPEID = 12615429
function CEmbryoToAnimal:ctor(animalid)
  self.id = 12615429
  self.animalid = animalid or nil
end
function CEmbryoToAnimal:marshal(os)
  os:marshalInt64(self.animalid)
end
function CEmbryoToAnimal:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function CEmbryoToAnimal:sizepolicy(size)
  return size <= 65535
end
return CEmbryoToAnimal
