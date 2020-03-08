local SMergePetEquipRes = class("SMergePetEquipRes")
SMergePetEquipRes.TYPEID = 12590607
function SMergePetEquipRes:ctor(itemKey)
  self.id = 12590607
  self.itemKey = itemKey or nil
end
function SMergePetEquipRes:marshal(os)
  os:marshalInt32(self.itemKey)
end
function SMergePetEquipRes:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
end
function SMergePetEquipRes:sizepolicy(size)
  return size <= 65535
end
return SMergePetEquipRes
