local SPetEquipItemRes = class("SPetEquipItemRes")
SPetEquipItemRes.TYPEID = 12590649
function SPetEquipItemRes:ctor(petId, wearPos)
  self.id = 12590649
  self.petId = petId or nil
  self.wearPos = wearPos or nil
end
function SPetEquipItemRes:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.wearPos)
end
function SPetEquipItemRes:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.wearPos = os:unmarshalInt32()
end
function SPetEquipItemRes:sizepolicy(size)
  return size <= 65535
end
return SPetEquipItemRes
