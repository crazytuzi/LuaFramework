local SChildrenEquipRandomErrorRes = class("SChildrenEquipRandomErrorRes")
SChildrenEquipRandomErrorRes.TYPEID = 12609426
SChildrenEquipRandomErrorRes.ERROR_ITEM_NOT_ENOUGH = 1
SChildrenEquipRandomErrorRes.ERROR_ITEM_NOT_SUIT = 2
SChildrenEquipRandomErrorRes.ERROR_MONEY_NOT_ENOUGH = 3
SChildrenEquipRandomErrorRes.ERROR_DO_DO_NOT_HAS_OTHER_PROP = 4
SChildrenEquipRandomErrorRes.ERROR_POS_DO_NOT_HAS_EQUIP = 5
SChildrenEquipRandomErrorRes.ERROR_ITEM_PRICE_CHANGED = 6
function SChildrenEquipRandomErrorRes:ctor(ret)
  self.id = 12609426
  self.ret = ret or nil
end
function SChildrenEquipRandomErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SChildrenEquipRandomErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SChildrenEquipRandomErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenEquipRandomErrorRes
