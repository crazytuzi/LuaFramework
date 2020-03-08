local SAnimalRenameSuccess = class("SAnimalRenameSuccess")
SAnimalRenameSuccess.TYPEID = 12615440
function SAnimalRenameSuccess:ctor(animalid, name)
  self.id = 12615440
  self.animalid = animalid or nil
  self.name = name or nil
end
function SAnimalRenameSuccess:marshal(os)
  os:marshalInt64(self.animalid)
  os:marshalOctets(self.name)
end
function SAnimalRenameSuccess:unmarshal(os)
  self.animalid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
end
function SAnimalRenameSuccess:sizepolicy(size)
  return size <= 65535
end
return SAnimalRenameSuccess
