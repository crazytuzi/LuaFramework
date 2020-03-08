local SCardUpgradeWithItemFail = class("SCardUpgradeWithItemFail")
SCardUpgradeWithItemFail.TYPEID = 12624411
SCardUpgradeWithItemFail.ROLE_LEVEL_NOT_ENOUGH = -1
SCardUpgradeWithItemFail.MAIN_CARD_NOT_EXIST = -2
SCardUpgradeWithItemFail.MAIN_CARD_LEVEL_MAX = -3
SCardUpgradeWithItemFail.COST_ITEM_NOT_EXIST = -4
SCardUpgradeWithItemFail.COST_ITEM_IS_NOT_CARD_ITEM = -5
SCardUpgradeWithItemFail.COST_ITEM_NOT_MATCH = -6
SCardUpgradeWithItemFail.COST_ITEM_CAN_NOT_BE_COST = -7
SCardUpgradeWithItemFail.COST_ITEM_LEVEL_HIGHER = -8
function SCardUpgradeWithItemFail:ctor(error_code)
  self.id = 12624411
  self.error_code = error_code or nil
end
function SCardUpgradeWithItemFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SCardUpgradeWithItemFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SCardUpgradeWithItemFail:sizepolicy(size)
  return size <= 65535
end
return SCardUpgradeWithItemFail
