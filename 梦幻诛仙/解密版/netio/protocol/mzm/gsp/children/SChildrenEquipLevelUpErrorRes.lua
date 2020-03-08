local SChildrenEquipLevelUpErrorRes = class("SChildrenEquipLevelUpErrorRes")
SChildrenEquipLevelUpErrorRes.TYPEID = 12609421
SChildrenEquipLevelUpErrorRes.ERROR_ITEM_NOT_ENOUGH = 1
SChildrenEquipLevelUpErrorRes.ERROR_ITEM_NOT_SUIT = 2
SChildrenEquipLevelUpErrorRes.ERROR_POS_DO_NOT_HAS_EQUIP = 3
SChildrenEquipLevelUpErrorRes.ERROR_TO_MAX_LEVEL = 4
SChildrenEquipLevelUpErrorRes.ERROR_STAGE_NOT_ENOUGH = 5
SChildrenEquipLevelUpErrorRes.ERROR_NOT_OVER_CHILDREN_LEVEL = 6
function SChildrenEquipLevelUpErrorRes:ctor(ret)
  self.id = 12609421
  self.ret = ret or nil
end
function SChildrenEquipLevelUpErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SChildrenEquipLevelUpErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SChildrenEquipLevelUpErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenEquipLevelUpErrorRes
