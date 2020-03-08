local SAnimalRenameFailed = class("SAnimalRenameFailed")
SAnimalRenameFailed.TYPEID = 12615435
SAnimalRenameFailed.ERROR_MIN_LEN = -1
SAnimalRenameFailed.ERROR_MAX_LEN = -2
SAnimalRenameFailed.ERROR_INVALID = -3
function SAnimalRenameFailed:ctor(retcode, animalid, name)
  self.id = 12615435
  self.retcode = retcode or nil
  self.animalid = animalid or nil
  self.name = name or nil
end
function SAnimalRenameFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.animalid)
  os:marshalOctets(self.name)
end
function SAnimalRenameFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.animalid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
end
function SAnimalRenameFailed:sizepolicy(size)
  return size <= 65535
end
return SAnimalRenameFailed
