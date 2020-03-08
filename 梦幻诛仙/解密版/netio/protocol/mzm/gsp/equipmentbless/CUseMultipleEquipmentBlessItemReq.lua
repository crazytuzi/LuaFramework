local CUseMultipleEquipmentBlessItemReq = class("CUseMultipleEquipmentBlessItemReq")
CUseMultipleEquipmentBlessItemReq.TYPEID = 12626433
function CUseMultipleEquipmentBlessItemReq:ctor(equipment_uuid, bless_item_cfgid)
  self.id = 12626433
  self.equipment_uuid = equipment_uuid or nil
  self.bless_item_cfgid = bless_item_cfgid or nil
end
function CUseMultipleEquipmentBlessItemReq:marshal(os)
  os:marshalInt64(self.equipment_uuid)
  os:marshalInt32(self.bless_item_cfgid)
end
function CUseMultipleEquipmentBlessItemReq:unmarshal(os)
  self.equipment_uuid = os:unmarshalInt64()
  self.bless_item_cfgid = os:unmarshalInt32()
end
function CUseMultipleEquipmentBlessItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseMultipleEquipmentBlessItemReq
