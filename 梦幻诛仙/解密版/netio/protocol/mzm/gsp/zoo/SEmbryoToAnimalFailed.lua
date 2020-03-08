local SEmbryoToAnimalFailed = class("SEmbryoToAnimalFailed")
SEmbryoToAnimalFailed.TYPEID = 12615430
SEmbryoToAnimalFailed.ERROR_DAY_NOT_ENOUGH = -1
function SEmbryoToAnimalFailed:ctor(retcode, animalid)
  self.id = 12615430
  self.retcode = retcode or nil
  self.animalid = animalid or nil
end
function SEmbryoToAnimalFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.animalid)
end
function SEmbryoToAnimalFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.animalid = os:unmarshalInt64()
end
function SEmbryoToAnimalFailed:sizepolicy(size)
  return size <= 65535
end
return SEmbryoToAnimalFailed
