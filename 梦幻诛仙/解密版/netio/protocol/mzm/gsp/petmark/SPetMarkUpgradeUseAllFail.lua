local SPetMarkUpgradeUseAllFail = class("SPetMarkUpgradeUseAllFail")
SPetMarkUpgradeUseAllFail.TYPEID = 12628501
SPetMarkUpgradeUseAllFail.ROLE_LEVEL_NOT_ENOUGH = -1
SPetMarkUpgradeUseAllFail.MAIN_PET_MARK_NOT_EXIST = -2
SPetMarkUpgradeUseAllFail.MAIN_PET_MARK_LEVEL_MAX = -3
SPetMarkUpgradeUseAllFail.NOTING_TO_COST = -4
SPetMarkUpgradeUseAllFail.CUT_ITEM_FAIL = -5
SPetMarkUpgradeUseAllFail.NEXT_LEVEL_NEED_HIGHER_ROLE_LEVEL = -6
function SPetMarkUpgradeUseAllFail:ctor(error_code)
  self.id = 12628501
  self.error_code = error_code or nil
end
function SPetMarkUpgradeUseAllFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SPetMarkUpgradeUseAllFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SPetMarkUpgradeUseAllFail:sizepolicy(size)
  return size <= 65535
end
return SPetMarkUpgradeUseAllFail
