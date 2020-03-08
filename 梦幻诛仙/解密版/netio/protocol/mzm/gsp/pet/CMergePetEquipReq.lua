local CMergePetEquipReq = class("CMergePetEquipReq")
CMergePetEquipReq.TYPEID = 12590633
function CMergePetEquipReq:ctor(itemKey1, itemKey2)
  self.id = 12590633
  self.itemKey1 = itemKey1 or nil
  self.itemKey2 = itemKey2 or nil
end
function CMergePetEquipReq:marshal(os)
  os:marshalInt32(self.itemKey1)
  os:marshalInt32(self.itemKey2)
end
function CMergePetEquipReq:unmarshal(os)
  self.itemKey1 = os:unmarshalInt32()
  self.itemKey2 = os:unmarshalInt32()
end
function CMergePetEquipReq:sizepolicy(size)
  return size <= 65535
end
return CMergePetEquipReq
