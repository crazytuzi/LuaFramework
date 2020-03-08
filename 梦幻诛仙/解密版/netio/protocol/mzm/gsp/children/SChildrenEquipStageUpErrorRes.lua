local SChildrenEquipStageUpErrorRes = class("SChildrenEquipStageUpErrorRes")
SChildrenEquipStageUpErrorRes.TYPEID = 12609423
SChildrenEquipStageUpErrorRes.ERROR_ITEM_NOT_ENOUGH = 1
SChildrenEquipStageUpErrorRes.ERROR_ITEM_NOT_SUIT = 2
SChildrenEquipStageUpErrorRes.ERROR_POS_DO_NOT_HAS_EQUIP = 3
SChildrenEquipStageUpErrorRes.ERROR_TO_MAX_LEVEL = 4
SChildrenEquipStageUpErrorRes.ERROR_LEVEL_NOT_ENOUGH = 5
SChildrenEquipStageUpErrorRes.ERROR_MONEY_NOT_ENOUGH = 6
function SChildrenEquipStageUpErrorRes:ctor(ret)
  self.id = 12609423
  self.ret = ret or nil
end
function SChildrenEquipStageUpErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SChildrenEquipStageUpErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SChildrenEquipStageUpErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenEquipStageUpErrorRes
