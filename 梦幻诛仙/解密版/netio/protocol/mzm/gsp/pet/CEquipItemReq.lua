local CEquipItemReq = class("CEquipItemReq")
CEquipItemReq.TYPEID = 12590613
function CEquipItemReq:ctor(petId, itemKey)
  self.id = 12590613
  self.petId = petId or nil
  self.itemKey = itemKey or nil
end
function CEquipItemReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.itemKey)
end
function CEquipItemReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CEquipItemReq:sizepolicy(size)
  return size <= 65535
end
return CEquipItemReq
