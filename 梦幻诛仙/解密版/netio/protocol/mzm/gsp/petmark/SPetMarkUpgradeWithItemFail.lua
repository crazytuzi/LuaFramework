local SPetMarkUpgradeWithItemFail = class("SPetMarkUpgradeWithItemFail")
SPetMarkUpgradeWithItemFail.TYPEID = 12628495
SPetMarkUpgradeWithItemFail.ROLE_LEVEL_NOT_ENOUGH = -1
SPetMarkUpgradeWithItemFail.MAIN_PET_MARK_NOT_EXIST = -2
SPetMarkUpgradeWithItemFail.MAIN_PET_MARK_LEVEL_MAX = -3
SPetMarkUpgradeWithItemFail.COST_ITEM_NOT_EXIST = -4
SPetMarkUpgradeWithItemFail.COST_ITEM_TYPE_WRONG = -5
SPetMarkUpgradeWithItemFail.COST_ITEM_QUALITY_DIFFRENT = -6
SPetMarkUpgradeWithItemFail.NEXT_LEVEL_NEED_HIGHER_ROLE_LEVEL = -7
function SPetMarkUpgradeWithItemFail:ctor(error_code)
  self.id = 12628495
  self.error_code = error_code or nil
end
function SPetMarkUpgradeWithItemFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SPetMarkUpgradeWithItemFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SPetMarkUpgradeWithItemFail:sizepolicy(size)
  return size <= 65535
end
return SPetMarkUpgradeWithItemFail
