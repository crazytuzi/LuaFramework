local SChatGiftResult = class("SChatGiftResult")
SChatGiftResult.TYPEID = 12585263
SChatGiftResult.CHAT_GIFT_HAVE_LIMIT_WORDS = 0
SChatGiftResult.CHAT_GIFT_SEND_MAX = 1
SChatGiftResult.CHAT_GIFT_MONEY_NOT_ENOUGH = 2
SChatGiftResult.CHAT_GIFT_NOT_FIND_CFG = 3
SChatGiftResult.CHAT_GIFT_NUM_NOT_MATCH_CFG = 4
SChatGiftResult.CHAT_GIFT_MONEY_NOT_MATCH = 5
SChatGiftResult.CHAT_GIFT_ACTIVE_NOT_ENOUGH = 6
SChatGiftResult.CHAT_GIFT_SERVER_CHANNEL_ERROR = 7
SChatGiftResult.CHAT_GIFT_CHANNEL_DATA_ERROR = 8
SChatGiftResult.CHAT_GIFT_NOT_IN_CHANNEL_CAN_NOT_SEND = 9
SChatGiftResult.CHAT_GIFT_OVER_WORDS_LIMIT = 10
SChatGiftResult.CHAT_GIFT_OVER_NUM_LIMIT = 11
SChatGiftResult.CHAT_GIFT_MAKE_ERROR = 12
SChatGiftResult.CHAT_GIFT_CHANNEL_SEND_ERROR = 13
SChatGiftResult.CHAT_GIFT_NOT_IN_CHANNEL_CAN_NOT_GET = 14
SChatGiftResult.CHAT_GIFT_NOT_IN_CHANNEL_CAN_NOT_LOOK = 15
SChatGiftResult.CHAT_GIFT_CHANNEL_TYPE_ERROR = 16
SChatGiftResult.CHAT_GIFT_DATA_ERROR = 17
SChatGiftResult.CHAT_GIFT_CHANNEL_NOT_MACTH = 18
SChatGiftResult.CHAT_GIFT_ALREADY_GET = 19
SChatGiftResult.CHAT_GIFT_GET_MAX_NUM = 20
SChatGiftResult.CHAT_GIFT_GET_MONEY_NUM_ERROR = 21
SChatGiftResult.CHAT_GIFT_GET_MONEY_ERROR = 22
SChatGiftResult.CHAT_GIFT_ADD_BANGGONG_ERROR = 23
SChatGiftResult.CHAT_GIFT_GET_NUM_DAY_LIMIT = 24
function SChatGiftResult:ctor(result)
  self.id = 12585263
  self.result = result or nil
end
function SChatGiftResult:marshal(os)
  os:marshalInt32(self.result)
end
function SChatGiftResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SChatGiftResult:sizepolicy(size)
  return size <= 65535
end
return SChatGiftResult
