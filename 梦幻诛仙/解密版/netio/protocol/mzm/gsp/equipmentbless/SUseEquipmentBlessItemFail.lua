local SUseEquipmentBlessItemFail = class("SUseEquipmentBlessItemFail")
SUseEquipmentBlessItemFail.TYPEID = 12626435
SUseEquipmentBlessItemFail.UNKNOWN = -1
SUseEquipmentBlessItemFail.REACH_MAX_LEVEL = 1
SUseEquipmentBlessItemFail.REACH_MAX_LEVEL_OF_CURRENT_STAGE = 2
SUseEquipmentBlessItemFail.INVALID_EQUIPMENT = 3
SUseEquipmentBlessItemFail.NOT_OWN_BLESS_ITEM = 4
SUseEquipmentBlessItemFail.BLESS_ITEM_NOT_MATCH_EQUIPMENT = 5
function SUseEquipmentBlessItemFail:ctor(reason)
  self.id = 12626435
  self.reason = reason or nil
end
function SUseEquipmentBlessItemFail:marshal(os)
  os:marshalInt32(self.reason)
end
function SUseEquipmentBlessItemFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SUseEquipmentBlessItemFail:sizepolicy(size)
  return size <= 65535
end
return SUseEquipmentBlessItemFail
