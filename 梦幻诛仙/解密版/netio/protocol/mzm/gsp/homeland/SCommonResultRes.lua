local SCommonResultRes = class("SCommonResultRes")
SCommonResultRes.TYPEID = 12605453
SCommonResultRes.PET_ROOM_LEVEL_TO_MAX = 1
SCommonResultRes.BED_ROOM_LEVEL_TO_MAX = 2
SCommonResultRes.DRUG_ROOM_LEVEL_TO_MAX = 3
SCommonResultRes.KITCHEN_LEVEL_TO_MAX = 4
SCommonResultRes.MAID_ROOM_LEVEL_TO_MAX = 5
SCommonResultRes.BUY_NUM_TO_MAX = 6
SCommonResultRes.BUY_ITEM_TIME_OUT = 7
SCommonResultRes.NOT_HOME_OWNER = 8
SCommonResultRes.DAY_CLEAN_COUNT_TO_MAX = 9
SCommonResultRes.CLEANLINESS_TO_MAX = 10
SCommonResultRes.TRAIN_PET_COUNT_TO_MAX = 11
SCommonResultRes.ADD_VIGOR_COUNT_TO_MAX = 12
SCommonResultRes.ADD_BAOSHIDU_COUNT_TO_MAX = 13
SCommonResultRes.ALREADY_HAS_HOME = 14
SCommonResultRes.HOME_ROLE_NUM_TO_MAX_CAN_NOT_ACCESS = 15
SCommonResultRes.HOME_ROLE_NUM_TO_MAX_CAN_NOT_GO_BACK_WITH_TEAM = 16
SCommonResultRes.NO_HOME_CAN_NOT_USE_DURNITURE_ITEM = 17
SCommonResultRes.VIGOR_TO_MAX = 18
SCommonResultRes.HOME_ROLE_NUM_TO_MAX_CAN_NOT_RETURN_TEAM = 19
SCommonResultRes.BAOSHIDU_TO_MAX = 20
SCommonResultRes.TEAM_IN_HOMELAND_CAN_NOT_TRANSFER = 21
SCommonResultRes.ROLE_IN_HOMELAND_CAN_NOT_TRANSFER = 22
SCommonResultRes.NO_HOME = 23
SCommonResultRes.COURT_LEVEL_UP_NOT_OPEN = 24
SCommonResultRes.USER_ID_NULL = 25
SCommonResultRes.NOT_AT_HOME = 26
SCommonResultRes.HOME_LEVEL_CFG_NOT_FOUND = 27
SCommonResultRes.COURT_LEVEL_CFG_NOT_FOUND = 28
SCommonResultRes.COURT_LEVEL_MAX = 29
SCommonResultRes.COURT_LEVEL_UP_CUT_FAIL = 30
SCommonResultRes.CLEAN_YARD_CUT_FAIL = 31
SCommonResultRes.CLEAN_YARD_MONEY_NUM_LESS_THAN_ZERO = 32
SCommonResultRes.UUID_ITEM_NOT_OWN = 33
SCommonResultRes.ITEM_CFG_ID_NOT_OWN = 34
SCommonResultRes.ITEM_CFG_ID_NOT_FIND = 35
SCommonResultRes.COURT_YARD_FURNITURE_CAN_NOT_REPLACE = 36
SCommonResultRes.COURT_YARD_FURNITURE_REPLACE_NOT_FIND_OLD = 37
SCommonResultRes.HOME_FUNCTION_NOT_OPEN = 38
SCommonResultRes.USER_DATA_IS_NULL = 39
SCommonResultRes.ROLE_HOME_OPERATOR_IS_NULL = 40
SCommonResultRes.FURNITURE_CAN_NOT_RECYCLE = 41
SCommonResultRes.FURNITURE_CFG_CAN_NOT_RECYCLE = 42
SCommonResultRes.FURNITURE_CFG_PROPRIETARY_CAN_NOT_RECYCLE = 43
SCommonResultRes.STATUS_CAN_NOT_DO_THIS = 44
function SCommonResultRes:ctor(res)
  self.id = 12605453
  self.res = res or nil
end
function SCommonResultRes:marshal(os)
  os:marshalInt32(self.res)
end
function SCommonResultRes:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SCommonResultRes:sizepolicy(size)
  return size <= 65535
end
return SCommonResultRes
