local SSyncPetExpChange = class("SSyncPetExpChange")
SSyncPetExpChange.TYPEID = 12590641
function SSyncPetExpChange:ctor(petId, addExp)
  self.id = 12590641
  self.petId = petId or nil
  self.addExp = addExp or nil
end
function SSyncPetExpChange:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.addExp)
end
function SSyncPetExpChange:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.addExp = os:unmarshalInt32()
end
function SSyncPetExpChange:sizepolicy(size)
  return size <= 65535
end
return SSyncPetExpChange
