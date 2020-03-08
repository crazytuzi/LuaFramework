local SPetMarkDecomposeAllFail = class("SPetMarkDecomposeAllFail")
SPetMarkDecomposeAllFail.TYPEID = 12628497
SPetMarkDecomposeAllFail.ROLE_LEVEL_NOT_ENOUGH = -1
SPetMarkDecomposeAllFail.NOTING_TO_COST = -2
SPetMarkDecomposeAllFail.ADD_SCORE_FAIL = -3
SPetMarkDecomposeAllFail.CUT_ITEM_FAIL = -4
SPetMarkDecomposeAllFail.QUALITY_INVALID = -5
function SPetMarkDecomposeAllFail:ctor(error_code)
  self.id = 12628497
  self.error_code = error_code or nil
end
function SPetMarkDecomposeAllFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SPetMarkDecomposeAllFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SPetMarkDecomposeAllFail:sizepolicy(size)
  return size <= 65535
end
return SPetMarkDecomposeAllFail
