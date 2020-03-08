local SCrossBattleFinalNormalRes = class("SCrossBattleFinalNormalRes")
SCrossBattleFinalNormalRes.TYPEID = 12617058
SCrossBattleFinalNormalRes.PREPARE_ENTER_TIME_EXPIRED = 1
SCrossBattleFinalNormalRes.PREPARE_ENTER_MAP_NOT_JOIN_TEAM = 2
SCrossBattleFinalNormalRes.MATCH_FAIL = 3
SCrossBattleFinalNormalRes.Final_ACTIVITY_DATA_NOT_FOUND = 4
SCrossBattleFinalNormalRes.Final_FIGHT_ZONE_DATA_NOT_FOUND = 5
SCrossBattleFinalNormalRes.Final_FIGHT_STAGE_DATA_NOT_FOUND = 6
SCrossBattleFinalNormalRes.Final_FIGHT_CORPS_INFO_GET_ERROR = 7
SCrossBattleFinalNormalRes.Final_FIGHT_GEN_TOKEN_ERROR = 8
SCrossBattleFinalNormalRes.Final_FIGHT_ROAM_ROLE_DATA_ERROR = 9
SCrossBattleFinalNormalRes.Final_FIGHT_INFO_GET_ERROR = 10
SCrossBattleFinalNormalRes.USER_ID_NOT_FOUND = 11
SCrossBattleFinalNormalRes.ACTIVITY_CFG_NOT_FOUND = 12
SCrossBattleFinalNormalRes.TEAM_NUMBER_NOT_VALID = 13
SCrossBattleFinalNormalRes.TEAM_NEED = 14
SCrossBattleFinalNormalRes.TEAM_MEMBER_NOT_SAME_WITH_SIGN_UP = 15
SCrossBattleFinalNormalRes.WORLD_NOT_EXIST = 16
SCrossBattleFinalNormalRes.INTO_WORLD_END_TIME_NOT_EXIST = 17
SCrossBattleFinalNormalRes.NOT_IN_CORPS = 18
SCrossBattleFinalNormalRes.NOT_IN_FIGHT_ZONE = 19
SCrossBattleFinalNormalRes.ROAMED_USER_ID_NOT_FOUND = 20
SCrossBattleFinalNormalRes.ROAMED_CONTEXT_NOT_FOUND = 21
SCrossBattleFinalNormalRes.OWN_SERVER_LOGIN_NOT_FOUND_OPPONENT = 22
SCrossBattleFinalNormalRes.CAL_Final_STAGE_FAIL = 23
SCrossBattleFinalNormalRes.QUERY_SIGN_UP_ROLE_LIST_FAIL = 24
SCrossBattleFinalNormalRes.Final_FUNCTION_NOT_OPEN = 25
SCrossBattleFinalNormalRes.FIGHT_ZONE_ID_NOT_VALID = 26
SCrossBattleFinalNormalRes.ALEARDY_RANK_UP = 30
SCrossBattleFinalNormalRes.ALEARDY_KNOCK_OUT = 31
SCrossBattleFinalNormalRes.TEAM_MEMBER_CAN_NOT_CLICK = 34
SCrossBattleFinalNormalRes.TEAM_CAN_NOT_INTO_GAME = 35
SCrossBattleFinalNormalRes.KNOCK_OUT_DATA_NOT_FOUND = 36
function SCrossBattleFinalNormalRes:ctor(ret)
  self.id = 12617058
  self.ret = ret or nil
end
function SCrossBattleFinalNormalRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SCrossBattleFinalNormalRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SCrossBattleFinalNormalRes:sizepolicy(size)
  return size <= 65535
end
return SCrossBattleFinalNormalRes
