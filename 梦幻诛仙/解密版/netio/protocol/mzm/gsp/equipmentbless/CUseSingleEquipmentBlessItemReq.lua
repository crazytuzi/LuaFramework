local CUseSingleEquipmentBlessItemReq = class("CUseSingleEquipmentBlessItemReq")
CUseSingleEquipmentBlessItemReq.TYPEID = 12626434
function CUseSingleEquipmentBlessItemReq:ctor(equipment_uuid, bless_item_cfgid)
  self.id = 12626434
  self.equipment_uuid = equipment_uuid or nil
  self.bless_item_cfgid = bless_item_cfgid or nil
end
function CUseSingleEquipmentBlessItemReq:marshal(os)
  os:marshalInt64(self.equipment_uuid)
  os:marshalInt32(self.bless_item_cfgid)
end
function CUseSingleEquipmentBlessItemReq:unmarshal(os)
  self.equipment_uuid = os:unmarshalInt64()
  self.bless_item_cfgid = os:unmarshalInt32()
end
function CUseSingleEquipmentBlessItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseSingleEquipmentBlessItemReq
