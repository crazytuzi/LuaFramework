local SCardItemDecomposeFail = class("SCardItemDecomposeFail")
SCardItemDecomposeFail.TYPEID = 12624410
SCardItemDecomposeFail.ROLE_LEVEL_NOT_ENOUGH = -1
SCardItemDecomposeFail.ITEM_NOT_EXIST = -2
SCardItemDecomposeFail.ITEM_NOT_CARD_ITEM = -3
SCardItemDecomposeFail.ADD_SCORE_FAIL = -4
SCardItemDecomposeFail.CUT_ITEM_FAIL = -5
SCardItemDecomposeFail.CAN_ONLY_DECOMPOSE_ONE = -6
function SCardItemDecomposeFail:ctor(error_code)
  self.id = 12624410
  self.error_code = error_code or nil
end
function SCardItemDecomposeFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SCardItemDecomposeFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SCardItemDecomposeFail:sizepolicy(size)
  return size <= 65535
end
return SCardItemDecomposeFail
