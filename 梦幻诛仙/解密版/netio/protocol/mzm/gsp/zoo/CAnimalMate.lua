local CAnimalMate = class("CAnimalMate")
CAnimalMate.TYPEID = 12615432
function CAnimalMate:ctor(animalid, target_animalid)
  self.id = 12615432
  self.animalid = animalid or nil
  self.target_animalid = target_animalid or nil
end
function CAnimalMate:marshal(os)
  os:marshalInt64(self.animalid)
  os:marshalInt64(self.target_animalid)
end
function CAnimalMate:unmarshal(os)
  self.animalid = os:unmarshalInt64()
  self.target_animalid = os:unmarshalInt64()
end
function CAnimalMate:sizepolicy(size)
  return size <= 65535
end
return CAnimalMate
