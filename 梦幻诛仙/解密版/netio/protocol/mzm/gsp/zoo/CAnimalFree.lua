local CAnimalFree = class("CAnimalFree")
CAnimalFree.TYPEID = 12615438
function CAnimalFree:ctor(animalid)
  self.id = 12615438
  self.animalid = animalid or nil
end
function CAnimalFree:marshal(os)
  os:marshalInt64(self.animalid)
end
function CAnimalFree:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function CAnimalFree:sizepolicy(size)
  return size <= 65535
end
return CAnimalFree
