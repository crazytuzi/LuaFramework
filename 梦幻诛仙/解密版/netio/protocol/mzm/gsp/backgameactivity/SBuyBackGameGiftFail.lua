local SBuyBackGameGiftFail = class("SBuyBackGameGiftFail")
SBuyBackGameGiftFail.TYPEID = 12620559
SBuyBackGameGiftFail.NOT_IN_BACK_GAME_ACTIVITY = -1
SBuyBackGameGiftFail.BACK_GAME_GIFT_NOT_EXIST = -2
SBuyBackGameGiftFail.BUY_COUNT_NOT_ENOUGH = -3
SBuyBackGameGiftFail.CURRENCY_NOT_ENOUGH = -4
SBuyBackGameGiftFail.RECHARGE_NOT_ENOUGH = -5
SBuyBackGameGiftFail.OFFER_ITEM_FAIL = -6
function SBuyBackGameGiftFail:ctor(error_code)
  self.id = 12620559
  self.error_code = error_code or nil
end
function SBuyBackGameGiftFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SBuyBackGameGiftFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SBuyBackGameGiftFail:sizepolicy(size)
  return size <= 65535
end
return SBuyBackGameGiftFail
