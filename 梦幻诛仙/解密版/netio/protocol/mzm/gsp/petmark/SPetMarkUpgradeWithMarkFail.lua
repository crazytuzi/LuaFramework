local SPetMarkUpgradeWithMarkFail = class("SPetMarkUpgradeWithMarkFail")
SPetMarkUpgradeWithMarkFail.TYPEID = 12628510
SPetMarkUpgradeWithMarkFail.ROLE_LEVEL_NOT_ENOUGH = -1
SPetMarkUpgradeWithMarkFail.MAIN_PET_MARK_NOT_EXIST = -2
SPetMarkUpgradeWithMarkFail.MAIN_PET_MARK_LEVEL_MAX = -3
SPetMarkUpgradeWithMarkFail.COST_PET_MARK_NOT_EXIST = -4
SPetMarkUpgradeWithMarkFail.COST_PET_MARK_QUALITY_DIFFRENT = -5
SPetMarkUpgradeWithMarkFail.COST_PET_MARK_ALREADY_EQUIPED = -6
SPetMarkUpgradeWithMarkFail.NEXT_LEVEL_NEED_HIGHER_ROLE_LEVEL = -7
SPetMarkUpgradeWithMarkFail.MAIN_AND_COST_PET_MARK_IS_THE_SAME = -8
function SPetMarkUpgradeWithMarkFail:ctor(error_code)
  self.id = 12628510
  self.error_code = error_code or nil
end
function SPetMarkUpgradeWithMarkFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SPetMarkUpgradeWithMarkFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SPetMarkUpgradeWithMarkFail:sizepolicy(size)
  return size <= 65535
end
return SPetMarkUpgradeWithMarkFail
