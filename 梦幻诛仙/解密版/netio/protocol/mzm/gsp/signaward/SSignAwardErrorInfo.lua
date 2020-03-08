local SSignAwardErrorInfo = class("SSignAwardErrorInfo")
SSignAwardErrorInfo.TYPEID = 12593411
SSignAwardErrorInfo.SIGN_DAY_FORMAT_ERROR = 1
SSignAwardErrorInfo.SIGN_DAY_ERROR = 2
SSignAwardErrorInfo.LOGIN_DAY_ERROR = 3
SSignAwardErrorInfo.LEVEL_ERROR = 4
SSignAwardErrorInfo.TODAY_SIGNED_ERROR = 5
SSignAwardErrorInfo.ALREADY_GET_LEVEL_BAG = 6
SSignAwardErrorInfo.ALREADY_GET_ONLINE_AWARD = 7
SSignAwardErrorInfo.ONLINE_TIME_NOT_ENOUGH = 8
SSignAwardErrorInfo.AWARD_BEFORE_SIGN_DAY_ERROR = 9
SSignAwardErrorInfo.CELL_NO_ANY_AWARD = 10
SSignAwardErrorInfo.YUAN_BAO_NOT_SAME_WITH_CLIENT = 11
SSignAwardErrorInfo.BOX_BUFF_AWARD_NOT_FOUND = 12
SSignAwardErrorInfo.BOX_BUFF_RANDOM_ERROR = 13
SSignAwardErrorInfo.ROLE_SIGN_INFO_NULL = 14
SSignAwardErrorInfo.CURRENT_CELL_NOT_BOX_AWARD = 15
SSignAwardErrorInfo.NO_RANDOM_LUCKY_BOX = 16
SSignAwardErrorInfo.LUCKY_BOX_NOT_EXIST = 17
SSignAwardErrorInfo.YUAN_BAO_NOT_ENOUGH = 18
SSignAwardErrorInfo.CUT_YUAN_BAO_FAIL = 19
SSignAwardErrorInfo.NO_RANDOM_BUFF = 20
SSignAwardErrorInfo.NEXT_BOX_CELL_TOO_FAR = 21
SSignAwardErrorInfo.NOT_FOUND_NEXT_BOX_CELL = 22
SSignAwardErrorInfo.HAS_BOX_AWARD_NOT_FINISH_DRAW = 23
SSignAwardErrorInfo.HAS_AWARD_NOT_FINISH = 24
SSignAwardErrorInfo.RANDOM_LUCKY_BOX_ERROR = 25
SSignAwardErrorInfo.RANDOM_RESULT_NULL = 26
SSignAwardErrorInfo.RANDOM_RESULT_ITEM_EMPTY = 27
SSignAwardErrorInfo.DELAY_AWARD_ADD_FAIL = 28
SSignAwardErrorInfo.NOW_CAN_NOT_DRAW_LOTTERY = 29
SSignAwardErrorInfo.FIRST_BOX_CAN_NOT_USE_YUAN_BAO = 30
SSignAwardErrorInfo.BUFF_CFG_NOT_EXIST = 31
SSignAwardErrorInfo.LUCKY_BOX_ALEARDY_BUY = 32
function SSignAwardErrorInfo:ctor(resCode)
  self.id = 12593411
  self.resCode = resCode or nil
end
function SSignAwardErrorInfo:marshal(os)
  os:marshalInt32(self.resCode)
end
function SSignAwardErrorInfo:unmarshal(os)
  self.resCode = os:unmarshalInt32()
end
function SSignAwardErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SSignAwardErrorInfo
