local SBuyMiBaoFail = class("SBuyMiBaoFail")
SBuyMiBaoFail.TYPEID = 12603400
SBuyMiBaoFail.NO_BUY_TIMES_LEFT = 1
SBuyMiBaoFail.LAST_AWARD_NOT_FINISH = 2
SBuyMiBaoFail.BUY_TIME_NOT_ENOUGH = 3
SBuyMiBaoFail.CURRENCY_NOT_EQUAL = 4
SBuyMiBaoFail.BUY_INDEX_ERROR = 5
SBuyMiBaoFail.BAG_FULL = 6
SBuyMiBaoFail.BUY_TIMES_ERROR = 7
SBuyMiBaoFail.CURRENCY_NOT_ENOUGH = 8
SBuyMiBaoFail.COST_CURRENCY_ERROR = 9
SBuyMiBaoFail.ACTIVITY_CAN_NOT_JOIN = 10
SBuyMiBaoFail.BAO_KU_INFO_NULL = 11
SBuyMiBaoFail.ACTIVITY_END_TIME_OUT = 12
SBuyMiBaoFail.TEN_TIMES_DRAW_TYPE_CFG_WRONG = 13
SBuyMiBaoFail.GRID_NUM_NOT_ENOUGH = 14
SBuyMiBaoFail.ITEM_PRICE_LESS_THEN_ZERO = 15
SBuyMiBaoFail.CLIENT_YUAN_BAO_NOT_SAME_WITH_SERVER = 16
SBuyMiBaoFail.CUT_YUAN_BAO_ERROR = 17
function SBuyMiBaoFail:ctor(result)
  self.id = 12603400
  self.result = result or nil
end
function SBuyMiBaoFail:marshal(os)
  os:marshalInt32(self.result)
end
function SBuyMiBaoFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SBuyMiBaoFail:sizepolicy(size)
  return size <= 65535
end
return SBuyMiBaoFail
