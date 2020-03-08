local OctetsStream = require("netio.OctetsStream")
local NormalResultRet = class("NormalResultRet")
NormalResultRet.PREPARE_ENTER_TIME_EXPIRED = 1
NormalResultRet.PREPARE_ENTER_MAP_NOT_JOIN_TEAM = 2
NormalResultRet.MATCH_FAIL = 3
NormalResultRet.KNOCK_OUT_ACTIVITY_DATA_NOT_FOUND = 4
NormalResultRet.KNOCK_OUT_FIGHT_ZONE_DATA_NOT_FOUND = 5
NormalResultRet.KNOCK_OUT_FIGHT_STAGE_DATA_NOT_FOUND = 6
NormalResultRet.KNOCK_OUT_FIGHT_CORPS_INFO_GET_ERROR = 7
NormalResultRet.KNOCK_OUT_FIGHT_GEN_TOKEN_ERROR = 8
NormalResultRet.KNOCK_OUT_FIGHT_ROAM_ROLE_DATA_ERROR = 9
NormalResultRet.KNOCK_OUT_FIGHT_INFO_GET_ERROR = 10
NormalResultRet.USER_ID_NOT_FOUND = 11
NormalResultRet.ACTIVITY_CFG_NOT_FOUND = 12
NormalResultRet.TEAM_NUMBER_NOT_VALID = 13
NormalResultRet.TEAM_NEED = 14
NormalResultRet.TEAM_MEMBER_NOT_SAME_WITH_SIGN_UP = 15
NormalResultRet.WORLD_NOT_EXIST = 16
NormalResultRet.INTO_WORLD_END_TIME_NOT_EXIST = 17
NormalResultRet.NOT_IN_CORPS = 18
NormalResultRet.NOT_IN_FIGHT_ZONE = 19
NormalResultRet.ROAMED_USER_ID_NOT_FOUND = 20
NormalResultRet.ROAMED_CONTEXT_NOT_FOUND = 21
NormalResultRet.OWN_SERVER_LOGIN_NOT_FOUND_OPPONENT = 22
NormalResultRet.CAL_KNOCK_OUT_STAGE_FAIL = 23
NormalResultRet.QUERY_SIGN_UP_ROLE_LIST_FAIL = 24
NormalResultRet.KNOCK_OUT_FUNCTION_NOT_OPEN = 25
NormalResultRet.FIGHT_ZONE_ID_NOT_VALID = 26
NormalResultRet.KNOCK_OUT_CFG_NOT_FOUND = 27
NormalResultRet.KNOCK_OUT_HANDLER_NOT_FOUND = 28
NormalResultRet.CAL_FIGHT_TIMES_ERROR = 29
NormalResultRet.ALEARDY_RANK_UP = 30
NormalResultRet.ALEARDY_KNOCK_OUT = 31
NormalResultRet.ROLE_STATUS_ERROR = 32
NormalResultRet.TEAM_MEMBER_CAN_NOT_CLICK = 34
NormalResultRet.TEAM_CAN_NOT_INTO_GAME = 35
NormalResultRet.KNOCK_OUT_DATA_NOT_FOUND = 36
function NormalResultRet:ctor()
end
function NormalResultRet:marshal(os)
end
function NormalResultRet:unmarshal(os)
end
return NormalResultRet
