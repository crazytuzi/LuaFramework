local SUseGiftCardFailed = class("SUseGiftCardFailed")
SUseGiftCardFailed.TYPEID = 12589316
SUseGiftCardFailed.ERROR_CARD_NOT_ACTIVATE = 1
SUseGiftCardFailed.ERROR_CARD_NOT_IN_EFFECT_TIME = 2
SUseGiftCardFailed.ERROR_CARD_EXPIRED = 3
SUseGiftCardFailed.ERROR_CARD_IS_INVALID = 4
SUseGiftCardFailed.ERROR_CARD_IS_ALREADY_USED_IN_THIS_SERVER = 5
SUseGiftCardFailed.ERROR_CARD_IS_ALREADY_USED_BY_OHTERS = 6
SUseGiftCardFailed.ERROR_CARD_NOT_EXIST = 7
SUseGiftCardFailed.ERROR_UNKOWN = 8
SUseGiftCardFailed.ERROR_NETWORK = 9
SUseGiftCardFailed.BAG_FULL = 10
function SUseGiftCardFailed:ctor(reason)
  self.id = 12589316
  self.reason = reason or nil
end
function SUseGiftCardFailed:marshal(os)
  os:marshalInt32(self.reason)
end
function SUseGiftCardFailed:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SUseGiftCardFailed:sizepolicy(size)
  return size <= 65535
end
return SUseGiftCardFailed
