local SChildrenWearPetEquipErrorRes = class("SChildrenWearPetEquipErrorRes")
SChildrenWearPetEquipErrorRes.TYPEID = 12609419
SChildrenWearPetEquipErrorRes.ERROR_DO_NOT_HAS_ITEM = 1
SChildrenWearPetEquipErrorRes.ERROR_ITEM_NOT_SUIT = 2
function SChildrenWearPetEquipErrorRes:ctor(ret)
  self.id = 12609419
  self.ret = ret or nil
end
function SChildrenWearPetEquipErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SChildrenWearPetEquipErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SChildrenWearPetEquipErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenWearPetEquipErrorRes
