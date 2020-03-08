local SyncRemoveAnimal = class("SyncRemoveAnimal")
SyncRemoveAnimal.TYPEID = 12615444
function SyncRemoveAnimal:ctor(animalid)
  self.id = 12615444
  self.animalid = animalid or nil
end
function SyncRemoveAnimal:marshal(os)
  os:marshalInt64(self.animalid)
end
function SyncRemoveAnimal:unmarshal(os)
  self.animalid = os:unmarshalInt64()
end
function SyncRemoveAnimal:sizepolicy(size)
  return size <= 65535
end
return SyncRemoveAnimal
