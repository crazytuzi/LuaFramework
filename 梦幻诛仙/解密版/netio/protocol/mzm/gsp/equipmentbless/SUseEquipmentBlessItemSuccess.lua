local SUseEquipmentBlessItemSuccess = class("SUseEquipmentBlessItemSuccess")
SUseEquipmentBlessItemSuccess.TYPEID = 12626436
function SUseEquipmentBlessItemSuccess:ctor(equipment_uuid, used_count, success_count, added_exp)
  self.id = 12626436
  self.equipment_uuid = equipment_uuid or nil
  self.used_count = used_count or nil
  self.success_count = success_count or nil
  self.added_exp = added_exp or nil
end
function SUseEquipmentBlessItemSuccess:marshal(os)
  os:marshalInt64(self.equipment_uuid)
  os:marshalInt32(self.used_count)
  os:marshalInt32(self.success_count)
  os:marshalInt32(self.added_exp)
end
function SUseEquipmentBlessItemSuccess:unmarshal(os)
  self.equipment_uuid = os:unmarshalInt64()
  self.used_count = os:unmarshalInt32()
  self.success_count = os:unmarshalInt32()
  self.added_exp = os:unmarshalInt32()
end
function SUseEquipmentBlessItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseEquipmentBlessItemSuccess
