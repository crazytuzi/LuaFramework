
local protobuf = require "protobuf"
local common_pb = require("common_pb")
module('arenaHandler_pb')


ARENAINFOREQUEST = protobuf.Descriptor();
ARENAINFORESPONSE = protobuf.Descriptor();
local ARENAINFORESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_SINGLERANK_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_TOTALRANK_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD = protobuf.FieldDescriptor();
local ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD = protobuf.FieldDescriptor();
ENTERARENAAREAREQUEST = protobuf.Descriptor();
ENTERARENAAREARESPONSE = protobuf.Descriptor();
local ENTERARENAAREARESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ENTERARENAAREARESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
LEAVEARENAAREAREQUEST = protobuf.Descriptor();
LEAVEARENAAREARESPONSE = protobuf.Descriptor();
local LEAVEARENAAREARESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local LEAVEARENAAREARESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
ARENAREWARDREQUEST = protobuf.Descriptor();
local ARENAREWARDREQUEST_C2S_TYPE_FIELD = protobuf.FieldDescriptor();
ARENAREWARDRESPONSE = protobuf.Descriptor();
local ARENAREWARDRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ARENAREWARDRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
ARENABATTLESCORE = protobuf.Descriptor();
local ARENABATTLESCORE_NAME_FIELD = protobuf.FieldDescriptor();
local ARENABATTLESCORE_SCORE_FIELD = protobuf.FieldDescriptor();
local ARENABATTLESCORE_PRO_FIELD = protobuf.FieldDescriptor();
local ARENABATTLESCORE_ID_FIELD = protobuf.FieldDescriptor();
ONARENABATTLEINFOPUSH = protobuf.Descriptor();
local ONARENABATTLEINFOPUSH_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD = protobuf.FieldDescriptor();
local ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD = protobuf.FieldDescriptor();
local ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD = protobuf.FieldDescriptor();
local ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD = protobuf.FieldDescriptor();
local ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD = protobuf.FieldDescriptor();
local ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD = protobuf.FieldDescriptor();
ONARENABATTLEENDPUSH = protobuf.Descriptor();
local ONARENABATTLEENDPUSH_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ONARENABATTLEENDPUSH_OUTTIME_FIELD = protobuf.FieldDescriptor();

ARENAINFOREQUEST.name = "ArenaInfoRequest"
ARENAINFOREQUEST.full_name = ".pomelo.area.ArenaInfoRequest"
ARENAINFOREQUEST.nested_types = {}
ARENAINFOREQUEST.enum_types = {}
ARENAINFOREQUEST.fields = {}
ARENAINFOREQUEST.is_extendable = false
ARENAINFOREQUEST.extensions = {}
ARENAINFORESPONSE_S2C_CODE_FIELD.name = "s2c_code"
ARENAINFORESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_code"
ARENAINFORESPONSE_S2C_CODE_FIELD.number = 1
ARENAINFORESPONSE_S2C_CODE_FIELD.index = 0
ARENAINFORESPONSE_S2C_CODE_FIELD.label = 2
ARENAINFORESPONSE_S2C_CODE_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_CODE_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_CODE_FIELD.type = 5
ARENAINFORESPONSE_S2C_CODE_FIELD.cpp_type = 1

ARENAINFORESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
ARENAINFORESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_msg"
ARENAINFORESPONSE_S2C_MSG_FIELD.number = 2
ARENAINFORESPONSE_S2C_MSG_FIELD.index = 1
ARENAINFORESPONSE_S2C_MSG_FIELD.label = 1
ARENAINFORESPONSE_S2C_MSG_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_MSG_FIELD.default_value = ""
ARENAINFORESPONSE_S2C_MSG_FIELD.type = 9
ARENAINFORESPONSE_S2C_MSG_FIELD.cpp_type = 9

ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.name = "s2c_singleRank"
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_singleRank"
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.number = 3
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.index = 2
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.label = 1
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.type = 5
ARENAINFORESPONSE_S2C_SINGLERANK_FIELD.cpp_type = 1

ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.name = "s2c_totalRank"
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_totalRank"
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.number = 4
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.index = 3
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.label = 1
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.type = 5
ARENAINFORESPONSE_S2C_TOTALRANK_FIELD.cpp_type = 1

ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.name = "s2c_singleReward"
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_singleReward"
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.number = 5
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.index = 4
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.label = 1
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.type = 5
ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD.cpp_type = 1

ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.name = "s2c_totalReward"
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_totalReward"
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.number = 6
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.index = 5
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.label = 1
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.type = 5
ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD.cpp_type = 1

ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.name = "s2c_currentTotalRank"
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_currentTotalRank"
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.number = 7
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.index = 6
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.label = 1
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.type = 5
ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD.cpp_type = 1

ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.name = "s2c_currentTotalScore"
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_currentTotalScore"
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.number = 8
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.index = 7
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.label = 1
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.type = 5
ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD.cpp_type = 1

ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.name = "s2c_seasonEndTime"
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.full_name = ".pomelo.area.ArenaInfoResponse.s2c_seasonEndTime"
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.number = 9
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.index = 8
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.label = 1
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.has_default_value = false
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.default_value = 0
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.type = 3
ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD.cpp_type = 2

ARENAINFORESPONSE.name = "ArenaInfoResponse"
ARENAINFORESPONSE.full_name = ".pomelo.area.ArenaInfoResponse"
ARENAINFORESPONSE.nested_types = {}
ARENAINFORESPONSE.enum_types = {}
ARENAINFORESPONSE.fields = {ARENAINFORESPONSE_S2C_CODE_FIELD, ARENAINFORESPONSE_S2C_MSG_FIELD, ARENAINFORESPONSE_S2C_SINGLERANK_FIELD, ARENAINFORESPONSE_S2C_TOTALRANK_FIELD, ARENAINFORESPONSE_S2C_SINGLEREWARD_FIELD, ARENAINFORESPONSE_S2C_TOTALREWARD_FIELD, ARENAINFORESPONSE_S2C_CURRENTTOTALRANK_FIELD, ARENAINFORESPONSE_S2C_CURRENTTOTALSCORE_FIELD, ARENAINFORESPONSE_S2C_SEASONENDTIME_FIELD}
ARENAINFORESPONSE.is_extendable = false
ARENAINFORESPONSE.extensions = {}
ENTERARENAAREAREQUEST.name = "EnterArenaAreaRequest"
ENTERARENAAREAREQUEST.full_name = ".pomelo.area.EnterArenaAreaRequest"
ENTERARENAAREAREQUEST.nested_types = {}
ENTERARENAAREAREQUEST.enum_types = {}
ENTERARENAAREAREQUEST.fields = {}
ENTERARENAAREAREQUEST.is_extendable = false
ENTERARENAAREAREQUEST.extensions = {}
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.name = "s2c_code"
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.EnterArenaAreaResponse.s2c_code"
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.number = 1
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.index = 0
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.label = 2
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.has_default_value = false
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.default_value = 0
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.type = 5
ENTERARENAAREARESPONSE_S2C_CODE_FIELD.cpp_type = 1

ENTERARENAAREARESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.EnterArenaAreaResponse.s2c_msg"
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.number = 2
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.index = 1
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.label = 1
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.has_default_value = false
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.default_value = ""
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.type = 9
ENTERARENAAREARESPONSE_S2C_MSG_FIELD.cpp_type = 9

ENTERARENAAREARESPONSE.name = "EnterArenaAreaResponse"
ENTERARENAAREARESPONSE.full_name = ".pomelo.area.EnterArenaAreaResponse"
ENTERARENAAREARESPONSE.nested_types = {}
ENTERARENAAREARESPONSE.enum_types = {}
ENTERARENAAREARESPONSE.fields = {ENTERARENAAREARESPONSE_S2C_CODE_FIELD, ENTERARENAAREARESPONSE_S2C_MSG_FIELD}
ENTERARENAAREARESPONSE.is_extendable = false
ENTERARENAAREARESPONSE.extensions = {}
LEAVEARENAAREAREQUEST.name = "LeaveArenaAreaRequest"
LEAVEARENAAREAREQUEST.full_name = ".pomelo.area.LeaveArenaAreaRequest"
LEAVEARENAAREAREQUEST.nested_types = {}
LEAVEARENAAREAREQUEST.enum_types = {}
LEAVEARENAAREAREQUEST.fields = {}
LEAVEARENAAREAREQUEST.is_extendable = false
LEAVEARENAAREAREQUEST.extensions = {}
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.name = "s2c_code"
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.LeaveArenaAreaResponse.s2c_code"
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.number = 1
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.index = 0
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.label = 2
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.has_default_value = false
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.default_value = 0
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.type = 5
LEAVEARENAAREARESPONSE_S2C_CODE_FIELD.cpp_type = 1

LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.LeaveArenaAreaResponse.s2c_msg"
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.number = 2
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.index = 1
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.label = 1
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.has_default_value = false
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.default_value = ""
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.type = 9
LEAVEARENAAREARESPONSE_S2C_MSG_FIELD.cpp_type = 9

LEAVEARENAAREARESPONSE.name = "LeaveArenaAreaResponse"
LEAVEARENAAREARESPONSE.full_name = ".pomelo.area.LeaveArenaAreaResponse"
LEAVEARENAAREARESPONSE.nested_types = {}
LEAVEARENAAREARESPONSE.enum_types = {}
LEAVEARENAAREARESPONSE.fields = {LEAVEARENAAREARESPONSE_S2C_CODE_FIELD, LEAVEARENAAREARESPONSE_S2C_MSG_FIELD}
LEAVEARENAAREARESPONSE.is_extendable = false
LEAVEARENAAREARESPONSE.extensions = {}
ARENAREWARDREQUEST_C2S_TYPE_FIELD.name = "c2s_type"
ARENAREWARDREQUEST_C2S_TYPE_FIELD.full_name = ".pomelo.area.ArenaRewardRequest.c2s_type"
ARENAREWARDREQUEST_C2S_TYPE_FIELD.number = 1
ARENAREWARDREQUEST_C2S_TYPE_FIELD.index = 0
ARENAREWARDREQUEST_C2S_TYPE_FIELD.label = 2
ARENAREWARDREQUEST_C2S_TYPE_FIELD.has_default_value = false
ARENAREWARDREQUEST_C2S_TYPE_FIELD.default_value = 0
ARENAREWARDREQUEST_C2S_TYPE_FIELD.type = 5
ARENAREWARDREQUEST_C2S_TYPE_FIELD.cpp_type = 1

ARENAREWARDREQUEST.name = "ArenaRewardRequest"
ARENAREWARDREQUEST.full_name = ".pomelo.area.ArenaRewardRequest"
ARENAREWARDREQUEST.nested_types = {}
ARENAREWARDREQUEST.enum_types = {}
ARENAREWARDREQUEST.fields = {ARENAREWARDREQUEST_C2S_TYPE_FIELD}
ARENAREWARDREQUEST.is_extendable = false
ARENAREWARDREQUEST.extensions = {}
ARENAREWARDRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
ARENAREWARDRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.ArenaRewardResponse.s2c_code"
ARENAREWARDRESPONSE_S2C_CODE_FIELD.number = 1
ARENAREWARDRESPONSE_S2C_CODE_FIELD.index = 0
ARENAREWARDRESPONSE_S2C_CODE_FIELD.label = 2
ARENAREWARDRESPONSE_S2C_CODE_FIELD.has_default_value = false
ARENAREWARDRESPONSE_S2C_CODE_FIELD.default_value = 0
ARENAREWARDRESPONSE_S2C_CODE_FIELD.type = 5
ARENAREWARDRESPONSE_S2C_CODE_FIELD.cpp_type = 1

ARENAREWARDRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
ARENAREWARDRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.ArenaRewardResponse.s2c_msg"
ARENAREWARDRESPONSE_S2C_MSG_FIELD.number = 2
ARENAREWARDRESPONSE_S2C_MSG_FIELD.index = 1
ARENAREWARDRESPONSE_S2C_MSG_FIELD.label = 1
ARENAREWARDRESPONSE_S2C_MSG_FIELD.has_default_value = false
ARENAREWARDRESPONSE_S2C_MSG_FIELD.default_value = ""
ARENAREWARDRESPONSE_S2C_MSG_FIELD.type = 9
ARENAREWARDRESPONSE_S2C_MSG_FIELD.cpp_type = 9

ARENAREWARDRESPONSE.name = "ArenaRewardResponse"
ARENAREWARDRESPONSE.full_name = ".pomelo.area.ArenaRewardResponse"
ARENAREWARDRESPONSE.nested_types = {}
ARENAREWARDRESPONSE.enum_types = {}
ARENAREWARDRESPONSE.fields = {ARENAREWARDRESPONSE_S2C_CODE_FIELD, ARENAREWARDRESPONSE_S2C_MSG_FIELD}
ARENAREWARDRESPONSE.is_extendable = false
ARENAREWARDRESPONSE.extensions = {}
ARENABATTLESCORE_NAME_FIELD.name = "name"
ARENABATTLESCORE_NAME_FIELD.full_name = ".pomelo.area.ArenaBattleScore.name"
ARENABATTLESCORE_NAME_FIELD.number = 1
ARENABATTLESCORE_NAME_FIELD.index = 0
ARENABATTLESCORE_NAME_FIELD.label = 2
ARENABATTLESCORE_NAME_FIELD.has_default_value = false
ARENABATTLESCORE_NAME_FIELD.default_value = ""
ARENABATTLESCORE_NAME_FIELD.type = 9
ARENABATTLESCORE_NAME_FIELD.cpp_type = 9

ARENABATTLESCORE_SCORE_FIELD.name = "score"
ARENABATTLESCORE_SCORE_FIELD.full_name = ".pomelo.area.ArenaBattleScore.score"
ARENABATTLESCORE_SCORE_FIELD.number = 2
ARENABATTLESCORE_SCORE_FIELD.index = 1
ARENABATTLESCORE_SCORE_FIELD.label = 2
ARENABATTLESCORE_SCORE_FIELD.has_default_value = false
ARENABATTLESCORE_SCORE_FIELD.default_value = 0
ARENABATTLESCORE_SCORE_FIELD.type = 5
ARENABATTLESCORE_SCORE_FIELD.cpp_type = 1

ARENABATTLESCORE_PRO_FIELD.name = "pro"
ARENABATTLESCORE_PRO_FIELD.full_name = ".pomelo.area.ArenaBattleScore.pro"
ARENABATTLESCORE_PRO_FIELD.number = 3
ARENABATTLESCORE_PRO_FIELD.index = 2
ARENABATTLESCORE_PRO_FIELD.label = 2
ARENABATTLESCORE_PRO_FIELD.has_default_value = false
ARENABATTLESCORE_PRO_FIELD.default_value = 0
ARENABATTLESCORE_PRO_FIELD.type = 5
ARENABATTLESCORE_PRO_FIELD.cpp_type = 1

ARENABATTLESCORE_ID_FIELD.name = "id"
ARENABATTLESCORE_ID_FIELD.full_name = ".pomelo.area.ArenaBattleScore.id"
ARENABATTLESCORE_ID_FIELD.number = 4
ARENABATTLESCORE_ID_FIELD.index = 3
ARENABATTLESCORE_ID_FIELD.label = 1
ARENABATTLESCORE_ID_FIELD.has_default_value = false
ARENABATTLESCORE_ID_FIELD.default_value = ""
ARENABATTLESCORE_ID_FIELD.type = 9
ARENABATTLESCORE_ID_FIELD.cpp_type = 9

ARENABATTLESCORE.name = "ArenaBattleScore"
ARENABATTLESCORE.full_name = ".pomelo.area.ArenaBattleScore"
ARENABATTLESCORE.nested_types = {}
ARENABATTLESCORE.enum_types = {}
ARENABATTLESCORE.fields = {ARENABATTLESCORE_NAME_FIELD, ARENABATTLESCORE_SCORE_FIELD, ARENABATTLESCORE_PRO_FIELD, ARENABATTLESCORE_ID_FIELD}
ARENABATTLESCORE.is_extendable = false
ARENABATTLESCORE.extensions = {}
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.name = "s2c_code"
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.full_name = ".pomelo.area.OnArenaBattleInfoPush.s2c_code"
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.number = 1
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.index = 0
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.label = 2
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.has_default_value = false
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.default_value = 0
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.type = 5
ONARENABATTLEINFOPUSH_S2C_CODE_FIELD.cpp_type = 1

ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.name = "s2c_killCount"
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.full_name = ".pomelo.area.OnArenaBattleInfoPush.s2c_killCount"
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.number = 2
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.index = 1
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.label = 2
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.has_default_value = false
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.default_value = 0
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.type = 5
ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD.cpp_type = 1

ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.name = "s2c_index"
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.full_name = ".pomelo.area.OnArenaBattleInfoPush.s2c_index"
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.number = 3
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.index = 2
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.label = 2
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.has_default_value = false
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.default_value = 0
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.type = 5
ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD.cpp_type = 1

ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.name = "s2c_score"
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.full_name = ".pomelo.area.OnArenaBattleInfoPush.s2c_score"
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.number = 4
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.index = 3
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.label = 2
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.has_default_value = false
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.default_value = 0
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.type = 5
ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD.cpp_type = 1

ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.name = "s2c_scores"
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.full_name = ".pomelo.area.OnArenaBattleInfoPush.s2c_scores"
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.number = 5
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.index = 4
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.label = 3
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.has_default_value = false
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.default_value = {}
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.message_type = ARENABATTLESCORE
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.type = 11
ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD.cpp_type = 10

ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.name = "s2c_playerCount"
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.full_name = ".pomelo.area.OnArenaBattleInfoPush.s2c_playerCount"
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.number = 6
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.index = 5
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.label = 2
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.has_default_value = false
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.default_value = 0
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.type = 5
ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD.cpp_type = 1

ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.name = "s2c_killCountList"
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.full_name = ".pomelo.area.OnArenaBattleInfoPush.s2c_killCountList"
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.number = 7
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.index = 6
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.label = 3
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.has_default_value = false
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.default_value = {}
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.message_type = ARENABATTLESCORE
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.type = 11
ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD.cpp_type = 10

ONARENABATTLEINFOPUSH.name = "OnArenaBattleInfoPush"
ONARENABATTLEINFOPUSH.full_name = ".pomelo.area.OnArenaBattleInfoPush"
ONARENABATTLEINFOPUSH.nested_types = {}
ONARENABATTLEINFOPUSH.enum_types = {}
ONARENABATTLEINFOPUSH.fields = {ONARENABATTLEINFOPUSH_S2C_CODE_FIELD, ONARENABATTLEINFOPUSH_S2C_KILLCOUNT_FIELD, ONARENABATTLEINFOPUSH_S2C_INDEX_FIELD, ONARENABATTLEINFOPUSH_S2C_SCORE_FIELD, ONARENABATTLEINFOPUSH_S2C_SCORES_FIELD, ONARENABATTLEINFOPUSH_S2C_PLAYERCOUNT_FIELD, ONARENABATTLEINFOPUSH_S2C_KILLCOUNTLIST_FIELD}
ONARENABATTLEINFOPUSH.is_extendable = false
ONARENABATTLEINFOPUSH.extensions = {}
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.name = "s2c_code"
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.full_name = ".pomelo.area.OnArenaBattleEndPush.s2c_code"
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.number = 1
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.index = 0
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.label = 2
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.has_default_value = false
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.default_value = 0
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.type = 5
ONARENABATTLEENDPUSH_S2C_CODE_FIELD.cpp_type = 1

ONARENABATTLEENDPUSH_OUTTIME_FIELD.name = "outtime"
ONARENABATTLEENDPUSH_OUTTIME_FIELD.full_name = ".pomelo.area.OnArenaBattleEndPush.outtime"
ONARENABATTLEENDPUSH_OUTTIME_FIELD.number = 2
ONARENABATTLEENDPUSH_OUTTIME_FIELD.index = 1
ONARENABATTLEENDPUSH_OUTTIME_FIELD.label = 2
ONARENABATTLEENDPUSH_OUTTIME_FIELD.has_default_value = false
ONARENABATTLEENDPUSH_OUTTIME_FIELD.default_value = 0
ONARENABATTLEENDPUSH_OUTTIME_FIELD.type = 5
ONARENABATTLEENDPUSH_OUTTIME_FIELD.cpp_type = 1

ONARENABATTLEENDPUSH.name = "OnArenaBattleEndPush"
ONARENABATTLEENDPUSH.full_name = ".pomelo.area.OnArenaBattleEndPush"
ONARENABATTLEENDPUSH.nested_types = {}
ONARENABATTLEENDPUSH.enum_types = {}
ONARENABATTLEENDPUSH.fields = {ONARENABATTLEENDPUSH_S2C_CODE_FIELD, ONARENABATTLEENDPUSH_OUTTIME_FIELD}
ONARENABATTLEENDPUSH.is_extendable = false
ONARENABATTLEENDPUSH.extensions = {}

ArenaBattleScore = protobuf.Message(ARENABATTLESCORE)
ArenaInfoRequest = protobuf.Message(ARENAINFOREQUEST)
ArenaInfoResponse = protobuf.Message(ARENAINFORESPONSE)
ArenaRewardRequest = protobuf.Message(ARENAREWARDREQUEST)
ArenaRewardResponse = protobuf.Message(ARENAREWARDRESPONSE)
EnterArenaAreaRequest = protobuf.Message(ENTERARENAAREAREQUEST)
EnterArenaAreaResponse = protobuf.Message(ENTERARENAAREARESPONSE)
LeaveArenaAreaRequest = protobuf.Message(LEAVEARENAAREAREQUEST)
LeaveArenaAreaResponse = protobuf.Message(LEAVEARENAAREARESPONSE)
OnArenaBattleEndPush = protobuf.Message(ONARENABATTLEENDPUSH)
OnArenaBattleInfoPush = protobuf.Message(ONARENABATTLEINFOPUSH)
