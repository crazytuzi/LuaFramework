local CEquipDecorateItemReq = class("CEquipDecorateItemReq")
CEquipDecorateItemReq.TYPEID = 12590643
function CEquipDecorateItemReq:ctor(petId, itemKey)
  self.id = 12590643
  self.petId = petId or nil
  self.itemKey = itemKey or nil
end
function CEquipDecorateItemReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.itemKey)
end
function CEquipDecorateItemReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CEquipDecorateItemReq:sizepolicy(size)
  return size <= 65535
end
return CEquipDecorateItemReq
