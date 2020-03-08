local SCrossBattleHistoryNormalRes = class("SCrossBattleHistoryNormalRes")
SCrossBattleHistoryNormalRes.TYPEID = 12617089
SCrossBattleHistoryNormalRes.TIME_LIMIT = 1
SCrossBattleHistoryNormalRes.FUNCTION_NOT_OPEN = 2
SCrossBattleHistoryNormalRes.ACTIVITY_DB_DATA_NOT_EXIST = 3
SCrossBattleHistoryNormalRes.FINAL_DB_DATA_NOT_EXIST = 4
SCrossBattleHistoryNormalRes.FIGHT_ZONE_DB_DATA_NOT_EXIST = 5
SCrossBattleHistoryNormalRes.ACTIVITY_CFG_DATA_NOT_EXIST = 6
SCrossBattleHistoryNormalRes.FINAL_CFG_DATA_NOT_EXIST = 7
SCrossBattleHistoryNormalRes.PARAM_SESSION_ERROR = 8
SCrossBattleHistoryNormalRes.HISTORY_CFG_NOT_EXIST = 9
SCrossBattleHistoryNormalRes.GET_FINAL_STAGE_ERROR = 10
SCrossBattleHistoryNormalRes.GRC_SEND_ERROR = 11
SCrossBattleHistoryNormalRes.GRC_GET_DATA_ERROR = 12
SCrossBattleHistoryNormalRes.GET_KNOCK_OUT_HANDLER_ERROR = 13
SCrossBattleHistoryNormalRes.CAN_NOT_QUERY_FINAL_ERROR = 15
SCrossBattleHistoryNormalRes.NOT_FINAL_LAST_ROUND_ERROR = 16
SCrossBattleHistoryNormalRes.CHAMPION_NOT_OUT_ERROR = 17
SCrossBattleHistoryNormalRes.CHAMPION_STAGE_DATA_NOT_FOUND_ERROR = 18
SCrossBattleHistoryNormalRes.CHAMPION_FIGHT_AGAINST_DATA_NOT_FOUND_ERROR = 19
SCrossBattleHistoryNormalRes.THIRD_PLACE_STAGE_DATA_NOT_FOUND_ERROR = 20
SCrossBattleHistoryNormalRes.THRID_PLACE_FIGHT_AGAINST_DATA_NOT_FOUND_ERROR = 21
SCrossBattleHistoryNormalRes.RANK_DATA_ERROR = 22
SCrossBattleHistoryNormalRes.NO_CHAMPION_ERROR = 23
SCrossBattleHistoryNormalRes.CORPS_ID_NO_CHAMPION_ERROR = 24
SCrossBattleHistoryNormalRes.CORPS_ID_NO_SECOND_PLACE_ERROR = 25
SCrossBattleHistoryNormalRes.CORPS_ID_NO_THIRD_PLACE_ERROR = 26
SCrossBattleHistoryNormalRes.LAST_SESSION_CFG_NOT_FOUND_ERROR = 27
function SCrossBattleHistoryNormalRes:ctor(ret)
  self.id = 12617089
  self.ret = ret or nil
end
function SCrossBattleHistoryNormalRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SCrossBattleHistoryNormalRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SCrossBattleHistoryNormalRes:sizepolicy(size)
  return size <= 65535
end
return SCrossBattleHistoryNormalRes
