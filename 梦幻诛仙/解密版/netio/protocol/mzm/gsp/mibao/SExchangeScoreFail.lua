local SExchangeScoreFail = class("SExchangeScoreFail")
SExchangeScoreFail.TYPEID = 12603404
SExchangeScoreFail.ACTIVITY_CAN_NOT_JOIN = 1
SExchangeScoreFail.EXCHANGE_TIMES_NOT_VALID = 2
SExchangeScoreFail.EXCHANGE_CHANGE_NOT_VALID = 3
SExchangeScoreFail.ACTIVITY_END_TIME_OUT = 4
SExchangeScoreFail.CAN_NOT_DO_THIS = 5
SExchangeScoreFail.BAO_KU_INFO_NULL = 6
SExchangeScoreFail.EXCHANGE_CFG_NOT_EXIST = 7
SExchangeScoreFail.EXCHANGE_TOO_FAST = 8
SExchangeScoreFail.EXCHANGE_SCORE_NOT_ENOUGH = 9
SExchangeScoreFail.AWARD_FAIL = 10
function SExchangeScoreFail:ctor(result)
  self.id = 12603404
  self.result = result or nil
end
function SExchangeScoreFail:marshal(os)
  os:marshalInt32(self.result)
end
function SExchangeScoreFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SExchangeScoreFail:sizepolicy(size)
  return size <= 65535
end
return SExchangeScoreFail
