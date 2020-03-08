local SCardUpgradeWithCardFail = class("SCardUpgradeWithCardFail")
SCardUpgradeWithCardFail.TYPEID = 12624399
SCardUpgradeWithCardFail.ROLE_LEVEL_NOT_ENOUGH = -1
SCardUpgradeWithCardFail.MAIN_CARD_NOT_EXIST = -2
SCardUpgradeWithCardFail.MAIN_CARD_LEVEL_MAX = -3
SCardUpgradeWithCardFail.COST_CARD_NOT_EXIST = -4
SCardUpgradeWithCardFail.COST_CARD_LEVEL_HIGHER = -5
SCardUpgradeWithCardFail.COST_CARD_NOT_MATCH = -6
SCardUpgradeWithCardFail.COST_CARD_CAN_NOT_BE_COST = -7
function SCardUpgradeWithCardFail:ctor(error_code)
  self.id = 12624399
  self.error_code = error_code or nil
end
function SCardUpgradeWithCardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SCardUpgradeWithCardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SCardUpgradeWithCardFail:sizepolicy(size)
  return size <= 65535
end
return SCardUpgradeWithCardFail
