
local protobuf = require "protobuf"
local item_pb = require("item_pb")
module('dailyActivity_pb')


DAILYINFO = protobuf.Descriptor();
local DAILYINFO_ID_FIELD = protobuf.FieldDescriptor();
local DAILYINFO_CUR_NUM_FIELD = protobuf.FieldDescriptor();
local DAILYINFO_MAX_NUM_FIELD = protobuf.FieldDescriptor();
local DAILYINFO_PERDEGREE_FIELD = protobuf.FieldDescriptor();
local DAILYINFO_LVLIMIT_FIELD = protobuf.FieldDescriptor();
local DAILYINFO_OPENPERIOD_FIELD = protobuf.FieldDescriptor();
local DAILYINFO_ISOVER_FIELD = protobuf.FieldDescriptor();
local DAILYINFO_AWARDITEM_FIELD = protobuf.FieldDescriptor();
DEGREEINFO = protobuf.Descriptor();
local DEGREEINFO_ID_FIELD = protobuf.FieldDescriptor();
local DEGREEINFO_NEEDDEGREE_FIELD = protobuf.FieldDescriptor();
local DEGREEINFO_STATE_FIELD = protobuf.FieldDescriptor();
local DEGREEINFO_AWARDITEM_FIELD = protobuf.FieldDescriptor();

DAILYINFO_ID_FIELD.name = "id"
DAILYINFO_ID_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.id"
DAILYINFO_ID_FIELD.number = 1
DAILYINFO_ID_FIELD.index = 0
DAILYINFO_ID_FIELD.label = 2
DAILYINFO_ID_FIELD.has_default_value = false
DAILYINFO_ID_FIELD.default_value = 0
DAILYINFO_ID_FIELD.type = 5
DAILYINFO_ID_FIELD.cpp_type = 1

DAILYINFO_CUR_NUM_FIELD.name = "cur_num"
DAILYINFO_CUR_NUM_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.cur_num"
DAILYINFO_CUR_NUM_FIELD.number = 2
DAILYINFO_CUR_NUM_FIELD.index = 1
DAILYINFO_CUR_NUM_FIELD.label = 1
DAILYINFO_CUR_NUM_FIELD.has_default_value = false
DAILYINFO_CUR_NUM_FIELD.default_value = 0
DAILYINFO_CUR_NUM_FIELD.type = 5
DAILYINFO_CUR_NUM_FIELD.cpp_type = 1

DAILYINFO_MAX_NUM_FIELD.name = "max_num"
DAILYINFO_MAX_NUM_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.max_num"
DAILYINFO_MAX_NUM_FIELD.number = 3
DAILYINFO_MAX_NUM_FIELD.index = 2
DAILYINFO_MAX_NUM_FIELD.label = 1
DAILYINFO_MAX_NUM_FIELD.has_default_value = false
DAILYINFO_MAX_NUM_FIELD.default_value = 0
DAILYINFO_MAX_NUM_FIELD.type = 5
DAILYINFO_MAX_NUM_FIELD.cpp_type = 1

DAILYINFO_PERDEGREE_FIELD.name = "perDegree"
DAILYINFO_PERDEGREE_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.perDegree"
DAILYINFO_PERDEGREE_FIELD.number = 4
DAILYINFO_PERDEGREE_FIELD.index = 3
DAILYINFO_PERDEGREE_FIELD.label = 1
DAILYINFO_PERDEGREE_FIELD.has_default_value = false
DAILYINFO_PERDEGREE_FIELD.default_value = 0
DAILYINFO_PERDEGREE_FIELD.type = 5
DAILYINFO_PERDEGREE_FIELD.cpp_type = 1

DAILYINFO_LVLIMIT_FIELD.name = "lvLimit"
DAILYINFO_LVLIMIT_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.lvLimit"
DAILYINFO_LVLIMIT_FIELD.number = 5
DAILYINFO_LVLIMIT_FIELD.index = 4
DAILYINFO_LVLIMIT_FIELD.label = 1
DAILYINFO_LVLIMIT_FIELD.has_default_value = false
DAILYINFO_LVLIMIT_FIELD.default_value = 0
DAILYINFO_LVLIMIT_FIELD.type = 5
DAILYINFO_LVLIMIT_FIELD.cpp_type = 1

DAILYINFO_OPENPERIOD_FIELD.name = "openPeriod"
DAILYINFO_OPENPERIOD_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.openPeriod"
DAILYINFO_OPENPERIOD_FIELD.number = 6
DAILYINFO_OPENPERIOD_FIELD.index = 5
DAILYINFO_OPENPERIOD_FIELD.label = 1
DAILYINFO_OPENPERIOD_FIELD.has_default_value = false
DAILYINFO_OPENPERIOD_FIELD.default_value = ""
DAILYINFO_OPENPERIOD_FIELD.type = 9
DAILYINFO_OPENPERIOD_FIELD.cpp_type = 9

DAILYINFO_ISOVER_FIELD.name = "isOver"
DAILYINFO_ISOVER_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.isOver"
DAILYINFO_ISOVER_FIELD.number = 7
DAILYINFO_ISOVER_FIELD.index = 6
DAILYINFO_ISOVER_FIELD.label = 1
DAILYINFO_ISOVER_FIELD.has_default_value = false
DAILYINFO_ISOVER_FIELD.default_value = 0
DAILYINFO_ISOVER_FIELD.type = 5
DAILYINFO_ISOVER_FIELD.cpp_type = 1

DAILYINFO_AWARDITEM_FIELD.name = "awardItem"
DAILYINFO_AWARDITEM_FIELD.full_name = ".pomelo.dailyActivity.DailyInfo.awardItem"
DAILYINFO_AWARDITEM_FIELD.number = 8
DAILYINFO_AWARDITEM_FIELD.index = 7
DAILYINFO_AWARDITEM_FIELD.label = 3
DAILYINFO_AWARDITEM_FIELD.has_default_value = false
DAILYINFO_AWARDITEM_FIELD.default_value = {}
DAILYINFO_AWARDITEM_FIELD.message_type = item_pb.ITEMDETAIL
DAILYINFO_AWARDITEM_FIELD.type = 11
DAILYINFO_AWARDITEM_FIELD.cpp_type = 10

DAILYINFO.name = "DailyInfo"
DAILYINFO.full_name = ".pomelo.dailyActivity.DailyInfo"
DAILYINFO.nested_types = {}
DAILYINFO.enum_types = {}
DAILYINFO.fields = {DAILYINFO_ID_FIELD, DAILYINFO_CUR_NUM_FIELD, DAILYINFO_MAX_NUM_FIELD, DAILYINFO_PERDEGREE_FIELD, DAILYINFO_LVLIMIT_FIELD, DAILYINFO_OPENPERIOD_FIELD, DAILYINFO_ISOVER_FIELD, DAILYINFO_AWARDITEM_FIELD}
DAILYINFO.is_extendable = false
DAILYINFO.extensions = {}
DEGREEINFO_ID_FIELD.name = "id"
DEGREEINFO_ID_FIELD.full_name = ".pomelo.dailyActivity.DegreeInfo.id"
DEGREEINFO_ID_FIELD.number = 1
DEGREEINFO_ID_FIELD.index = 0
DEGREEINFO_ID_FIELD.label = 2
DEGREEINFO_ID_FIELD.has_default_value = false
DEGREEINFO_ID_FIELD.default_value = 0
DEGREEINFO_ID_FIELD.type = 5
DEGREEINFO_ID_FIELD.cpp_type = 1

DEGREEINFO_NEEDDEGREE_FIELD.name = "needDegree"
DEGREEINFO_NEEDDEGREE_FIELD.full_name = ".pomelo.dailyActivity.DegreeInfo.needDegree"
DEGREEINFO_NEEDDEGREE_FIELD.number = 2
DEGREEINFO_NEEDDEGREE_FIELD.index = 1
DEGREEINFO_NEEDDEGREE_FIELD.label = 1
DEGREEINFO_NEEDDEGREE_FIELD.has_default_value = false
DEGREEINFO_NEEDDEGREE_FIELD.default_value = 0
DEGREEINFO_NEEDDEGREE_FIELD.type = 5
DEGREEINFO_NEEDDEGREE_FIELD.cpp_type = 1

DEGREEINFO_STATE_FIELD.name = "state"
DEGREEINFO_STATE_FIELD.full_name = ".pomelo.dailyActivity.DegreeInfo.state"
DEGREEINFO_STATE_FIELD.number = 3
DEGREEINFO_STATE_FIELD.index = 2
DEGREEINFO_STATE_FIELD.label = 1
DEGREEINFO_STATE_FIELD.has_default_value = false
DEGREEINFO_STATE_FIELD.default_value = 0
DEGREEINFO_STATE_FIELD.type = 5
DEGREEINFO_STATE_FIELD.cpp_type = 1

DEGREEINFO_AWARDITEM_FIELD.name = "awardItem"
DEGREEINFO_AWARDITEM_FIELD.full_name = ".pomelo.dailyActivity.DegreeInfo.awardItem"
DEGREEINFO_AWARDITEM_FIELD.number = 4
DEGREEINFO_AWARDITEM_FIELD.index = 3
DEGREEINFO_AWARDITEM_FIELD.label = 3
DEGREEINFO_AWARDITEM_FIELD.has_default_value = false
DEGREEINFO_AWARDITEM_FIELD.default_value = {}
DEGREEINFO_AWARDITEM_FIELD.message_type = item_pb.ITEMDETAIL
DEGREEINFO_AWARDITEM_FIELD.type = 11
DEGREEINFO_AWARDITEM_FIELD.cpp_type = 10

DEGREEINFO.name = "DegreeInfo"
DEGREEINFO.full_name = ".pomelo.dailyActivity.DegreeInfo"
DEGREEINFO.nested_types = {}
DEGREEINFO.enum_types = {}
DEGREEINFO.fields = {DEGREEINFO_ID_FIELD, DEGREEINFO_NEEDDEGREE_FIELD, DEGREEINFO_STATE_FIELD, DEGREEINFO_AWARDITEM_FIELD}
DEGREEINFO.is_extendable = false
DEGREEINFO.extensions = {}

DailyInfo = protobuf.Message(DAILYINFO)
DegreeInfo = protobuf.Message(DEGREEINFO)
