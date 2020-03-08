local SEquipFabaoErrorRes = class("SEquipFabaoErrorRes")
SEquipFabaoErrorRes.TYPEID = 12596019
SEquipFabaoErrorRes.ERROR_FA_BAO_NON_EXSIT = 0
SEquipFabaoErrorRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 1
SEquipFabaoErrorRes.ERROR_ITEM_IS_NOT_FA_BAO = 2
SEquipFabaoErrorRes.ERROR_IN_CROSS = 3
function SEquipFabaoErrorRes:ctor(errorCode)
  self.id = 12596019
  self.errorCode = errorCode or nil
end
function SEquipFabaoErrorRes:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SEquipFabaoErrorRes:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SEquipFabaoErrorRes:sizepolicy(size)
  return size <= 65535
end
return SEquipFabaoErrorRes
