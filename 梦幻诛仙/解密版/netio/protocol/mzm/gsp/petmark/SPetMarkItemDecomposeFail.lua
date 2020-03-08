local SPetMarkItemDecomposeFail = class("SPetMarkItemDecomposeFail")
SPetMarkItemDecomposeFail.TYPEID = 12628506
SPetMarkItemDecomposeFail.ROLE_LEVEL_NOT_ENOUGH = -1
SPetMarkItemDecomposeFail.COST_ITEM_NOT_EXIST = -2
SPetMarkItemDecomposeFail.COST_ITEM_TYPE_WRONG = -3
SPetMarkItemDecomposeFail.ADD_SCORE_FAIL = -4
SPetMarkItemDecomposeFail.CUT_ITEM_FAIL = -5
function SPetMarkItemDecomposeFail:ctor(error_code)
  self.id = 12628506
  self.error_code = error_code or nil
end
function SPetMarkItemDecomposeFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SPetMarkItemDecomposeFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SPetMarkItemDecomposeFail:sizepolicy(size)
  return size <= 65535
end
return SPetMarkItemDecomposeFail
