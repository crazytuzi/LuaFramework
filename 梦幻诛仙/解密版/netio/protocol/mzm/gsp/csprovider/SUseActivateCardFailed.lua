local SUseActivateCardFailed = class("SUseActivateCardFailed")
SUseActivateCardFailed.TYPEID = 12589315
SUseActivateCardFailed.ERROR_NOT_REQUIRE = 0
SUseActivateCardFailed.ERROR_CARD_NOT_ACTIVATE = 1
SUseActivateCardFailed.ERROR_CARD_NOT_IN_EFFECT_TIME = 2
SUseActivateCardFailed.ERROR_CARD_EXPIRED = 3
SUseActivateCardFailed.ERROR_CARD_IS_ALREADY_USED_IN_THIS_SERVER = 4
SUseActivateCardFailed.ERROR_CARD_IS_INVALID = 5
SUseActivateCardFailed.ERROR_CARD_IS_ALREADY_USED_IN_OHTER_SERVER = 6
SUseActivateCardFailed.ERROR_CARD_IS_ALREADY_USED_BY_OHTERS = 7
SUseActivateCardFailed.ERROR_CARD_NOT_EXIST = 8
SUseActivateCardFailed.ERROR_UNKOWN = 9
SUseActivateCardFailed.ERROR_NETWORK = 10
function SUseActivateCardFailed:ctor(reason)
  self.id = 12589315
  self.reason = reason or nil
end
function SUseActivateCardFailed:marshal(os)
  os:marshalInt32(self.reason)
end
function SUseActivateCardFailed:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SUseActivateCardFailed:sizepolicy(size)
  return size <= 1024
end
return SUseActivateCardFailed
