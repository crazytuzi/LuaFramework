local SLuckyStarNormalFail = class("SLuckyStarNormalFail")
SLuckyStarNormalFail.TYPEID = 12608514
SLuckyStarNormalFail.ACTIVITY_CAN_NOT_JOIN = 1
SLuckyStarNormalFail.ACTIVITY_CFG_NOT_EXIST = 2
SLuckyStarNormalFail.ROLE_ACTIVITY_INFO_NULL = 3
SLuckyStarNormalFail.ROLE_ACTIVITY_INFO_NOT_EXIST = 4
SLuckyStarNormalFail.ROLE_GIFT_INFO_NOT_EXIST = 5
SLuckyStarNormalFail.GIFT_CFG_NOT_EXIST = 6
SLuckyStarNormalFail.BUY_TIMES_NOT_ENOUGH = 7
SLuckyStarNormalFail.CURRENCY_NOT_ENOUGH = 8
SLuckyStarNormalFail.CUT_CURRENCY_ERROR = 9
SLuckyStarNormalFail.AWARDED_FAIL = 10
SLuckyStarNormalFail.ACTIVE_NOT_ENOUGH = 11
SLuckyStarNormalFail.LUCKY_STAR_FUNCTION_NOT_OPEN = 12
SLuckyStarNormalFail.BUY_TIMES_NOT_VALID = 13
function SLuckyStarNormalFail:ctor(result)
  self.id = 12608514
  self.result = result or nil
end
function SLuckyStarNormalFail:marshal(os)
  os:marshalInt32(self.result)
end
function SLuckyStarNormalFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SLuckyStarNormalFail:sizepolicy(size)
  return size <= 65535
end
return SLuckyStarNormalFail
