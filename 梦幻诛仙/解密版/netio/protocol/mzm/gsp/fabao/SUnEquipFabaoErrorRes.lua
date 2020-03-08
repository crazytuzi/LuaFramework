local SUnEquipFabaoErrorRes = class("SUnEquipFabaoErrorRes")
SUnEquipFabaoErrorRes.TYPEID = 12596018
SUnEquipFabaoErrorRes.ERROR_FA_BAO_NON_EXSIT = 0
SUnEquipFabaoErrorRes.ERROR_BAG_FULL = 1
SUnEquipFabaoErrorRes.ERROR_IN_CROSS = 2
function SUnEquipFabaoErrorRes:ctor(errorCode)
  self.id = 12596018
  self.errorCode = errorCode or nil
end
function SUnEquipFabaoErrorRes:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SUnEquipFabaoErrorRes:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SUnEquipFabaoErrorRes:sizepolicy(size)
  return size <= 65535
end
return SUnEquipFabaoErrorRes
