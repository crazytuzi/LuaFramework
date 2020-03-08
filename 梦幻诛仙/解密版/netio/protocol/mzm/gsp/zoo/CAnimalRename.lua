local CAnimalRename = class("CAnimalRename")
CAnimalRename.TYPEID = 12615439
function CAnimalRename:ctor(animalid, name)
  self.id = 12615439
  self.animalid = animalid or nil
  self.name = name or nil
end
function CAnimalRename:marshal(os)
  os:marshalInt64(self.animalid)
  os:marshalOctets(self.name)
end
function CAnimalRename:unmarshal(os)
  self.animalid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
end
function CAnimalRename:sizepolicy(size)
  return size <= 65535
end
return CAnimalRename
