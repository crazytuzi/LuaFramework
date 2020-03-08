local SAnimalMateFailed = class("SAnimalMateFailed")
SAnimalMateFailed.TYPEID = 12615433
SAnimalMateFailed.ERROR_MATE_CD = -1
SAnimalMateFailed.ERROR_ANIMAL_MYSELF = -2
SAnimalMateFailed.ERROR_ANIMAL_MARRIAGE = -3
function SAnimalMateFailed:ctor(retcode, animalid, target_animalid)
  self.id = 12615433
  self.retcode = retcode or nil
  self.animalid = animalid or nil
  self.target_animalid = target_animalid or nil
end
function SAnimalMateFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.animalid)
  os:marshalInt64(self.target_animalid)
end
function SAnimalMateFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.animalid = os:unmarshalInt64()
  self.target_animalid = os:unmarshalInt64()
end
function SAnimalMateFailed:sizepolicy(size)
  return size <= 65535
end
return SAnimalMateFailed
