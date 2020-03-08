local SAnimalFreeFailed = class("SAnimalFreeFailed")
SAnimalFreeFailed.TYPEID = 12615436
SAnimalFreeFailed.ERROR_STAGE = -1
function SAnimalFreeFailed:ctor(retcode, animalid)
  self.id = 12615436
  self.retcode = retcode or nil
  self.animalid = animalid or nil
end
function SAnimalFreeFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.animalid)
end
function SAnimalFreeFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.animalid = os:unmarshalInt64()
end
function SAnimalFreeFailed:sizepolicy(size)
  return size <= 65535
end
return SAnimalFreeFailed
