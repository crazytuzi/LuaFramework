local SCardDecomposeFail = class("SCardDecomposeFail")
SCardDecomposeFail.TYPEID = 12624403
SCardDecomposeFail.ROLE_LEVEL_NOT_ENOUGH = -1
SCardDecomposeFail.CARD_NOT_EXIST = -2
SCardDecomposeFail.ADD_SCORE_FAIL = -3
function SCardDecomposeFail:ctor(error_code)
  self.id = 12624403
  self.error_code = error_code or nil
end
function SCardDecomposeFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SCardDecomposeFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SCardDecomposeFail:sizepolicy(size)
  return size <= 65535
end
return SCardDecomposeFail
