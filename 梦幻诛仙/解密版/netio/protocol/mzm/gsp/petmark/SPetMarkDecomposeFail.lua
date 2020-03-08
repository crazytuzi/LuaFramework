local SPetMarkDecomposeFail = class("SPetMarkDecomposeFail")
SPetMarkDecomposeFail.TYPEID = 12628504
SPetMarkDecomposeFail.ROLE_LEVEL_NOT_ENOUGH = -1
SPetMarkDecomposeFail.PET_MARK_NOT_EXIST = -2
SPetMarkDecomposeFail.PET_MARK_ALREADY_EQUIPED = -3
SPetMarkDecomposeFail.ADD_SCORE_FAIL = -4
function SPetMarkDecomposeFail:ctor(error_code)
  self.id = 12628504
  self.error_code = error_code or nil
end
function SPetMarkDecomposeFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SPetMarkDecomposeFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SPetMarkDecomposeFail:sizepolicy(size)
  return size <= 65535
end
return SPetMarkDecomposeFail
