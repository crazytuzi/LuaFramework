
local protobuf = require "protobuf"
local common_pb = require("common_pb")
local item_pb = require("item_pb")
module('amuletHandler_pb')


GETALLAMULETDETAILREQ = protobuf.Descriptor();
GETALLAMULETDETAILRES = protobuf.Descriptor();
local GETALLAMULETDETAILRES_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local GETALLAMULETDETAILRES_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD = protobuf.FieldDescriptor();
local GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD = protobuf.FieldDescriptor();
local GETALLAMULETDETAILRES_S2C_DATA_FIELD = protobuf.FieldDescriptor();
EQUIPAMULETREQ = protobuf.Descriptor();
local EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD = protobuf.FieldDescriptor();
UNEQUIPAMULETREQ = protobuf.Descriptor();
local UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD = protobuf.FieldDescriptor();
UNALLEQUIPAMULETREQ = protobuf.Descriptor();
EQUIPAMULETRES = protobuf.Descriptor();
local EQUIPAMULETRES_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local EQUIPAMULETRES_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD = protobuf.FieldDescriptor();
local EQUIPAMULETRES_S2C_MAXCOUNT_FIELD = protobuf.FieldDescriptor();
UNEQUIPAMULETRES = protobuf.Descriptor();
local UNEQUIPAMULETRES_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local UNEQUIPAMULETRES_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD = protobuf.FieldDescriptor();
local UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD = protobuf.FieldDescriptor();
UNALLEQUIPAMULETRES = protobuf.Descriptor();
local UNALLEQUIPAMULETRES_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local UNALLEQUIPAMULETRES_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD = protobuf.FieldDescriptor();
local UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD = protobuf.FieldDescriptor();
AMULETEQUIPNEWPUSH = protobuf.Descriptor();
local AMULETEQUIPNEWPUSH_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local AMULETEQUIPNEWPUSH_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD = protobuf.FieldDescriptor();
local AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD = protobuf.FieldDescriptor();
local AMULETEQUIPNEWPUSH_S2C_DATA_FIELD = protobuf.FieldDescriptor();

GETALLAMULETDETAILREQ.name = "GetAllAmuletDetailReq"
GETALLAMULETDETAILREQ.full_name = ".pomelo.area.GetAllAmuletDetailReq"
GETALLAMULETDETAILREQ.nested_types = {}
GETALLAMULETDETAILREQ.enum_types = {}
GETALLAMULETDETAILREQ.fields = {}
GETALLAMULETDETAILREQ.is_extendable = false
GETALLAMULETDETAILREQ.extensions = {}
GETALLAMULETDETAILRES_S2C_CODE_FIELD.name = "s2c_code"
GETALLAMULETDETAILRES_S2C_CODE_FIELD.full_name = ".pomelo.area.GetAllAmuletDetailRes.s2c_code"
GETALLAMULETDETAILRES_S2C_CODE_FIELD.number = 1
GETALLAMULETDETAILRES_S2C_CODE_FIELD.index = 0
GETALLAMULETDETAILRES_S2C_CODE_FIELD.label = 2
GETALLAMULETDETAILRES_S2C_CODE_FIELD.has_default_value = false
GETALLAMULETDETAILRES_S2C_CODE_FIELD.default_value = 0
GETALLAMULETDETAILRES_S2C_CODE_FIELD.type = 5
GETALLAMULETDETAILRES_S2C_CODE_FIELD.cpp_type = 1

GETALLAMULETDETAILRES_S2C_MSG_FIELD.name = "s2c_msg"
GETALLAMULETDETAILRES_S2C_MSG_FIELD.full_name = ".pomelo.area.GetAllAmuletDetailRes.s2c_msg"
GETALLAMULETDETAILRES_S2C_MSG_FIELD.number = 2
GETALLAMULETDETAILRES_S2C_MSG_FIELD.index = 1
GETALLAMULETDETAILRES_S2C_MSG_FIELD.label = 1
GETALLAMULETDETAILRES_S2C_MSG_FIELD.has_default_value = false
GETALLAMULETDETAILRES_S2C_MSG_FIELD.default_value = ""
GETALLAMULETDETAILRES_S2C_MSG_FIELD.type = 9
GETALLAMULETDETAILRES_S2C_MSG_FIELD.cpp_type = 9

GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.name = "s2c_totalCount"
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.full_name = ".pomelo.area.GetAllAmuletDetailRes.s2c_totalCount"
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.number = 3
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.index = 2
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.label = 1
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.has_default_value = false
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.default_value = 0
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.type = 5
GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD.cpp_type = 1

GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.name = "s2c_maxCount"
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.full_name = ".pomelo.area.GetAllAmuletDetailRes.s2c_maxCount"
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.number = 4
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.index = 3
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.label = 1
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.has_default_value = false
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.default_value = 0
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.type = 5
GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD.cpp_type = 1

GETALLAMULETDETAILRES_S2C_DATA_FIELD.name = "s2c_data"
GETALLAMULETDETAILRES_S2C_DATA_FIELD.full_name = ".pomelo.area.GetAllAmuletDetailRes.s2c_data"
GETALLAMULETDETAILRES_S2C_DATA_FIELD.number = 5
GETALLAMULETDETAILRES_S2C_DATA_FIELD.index = 4
GETALLAMULETDETAILRES_S2C_DATA_FIELD.label = 3
GETALLAMULETDETAILRES_S2C_DATA_FIELD.has_default_value = false
GETALLAMULETDETAILRES_S2C_DATA_FIELD.default_value = {}
GETALLAMULETDETAILRES_S2C_DATA_FIELD.message_type = item_pb.ITEMDETAIL
GETALLAMULETDETAILRES_S2C_DATA_FIELD.type = 11
GETALLAMULETDETAILRES_S2C_DATA_FIELD.cpp_type = 10

GETALLAMULETDETAILRES.name = "GetAllAmuletDetailRes"
GETALLAMULETDETAILRES.full_name = ".pomelo.area.GetAllAmuletDetailRes"
GETALLAMULETDETAILRES.nested_types = {}
GETALLAMULETDETAILRES.enum_types = {}
GETALLAMULETDETAILRES.fields = {GETALLAMULETDETAILRES_S2C_CODE_FIELD, GETALLAMULETDETAILRES_S2C_MSG_FIELD, GETALLAMULETDETAILRES_S2C_TOTALCOUNT_FIELD, GETALLAMULETDETAILRES_S2C_MAXCOUNT_FIELD, GETALLAMULETDETAILRES_S2C_DATA_FIELD}
GETALLAMULETDETAILRES.is_extendable = false
GETALLAMULETDETAILRES.extensions = {}
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.name = "c2s_gridIndex"
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.full_name = ".pomelo.area.EquipAmuletReq.c2s_gridIndex"
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.number = 1
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.index = 0
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.label = 2
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.has_default_value = false
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.default_value = 0
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.type = 5
EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.cpp_type = 1

EQUIPAMULETREQ.name = "EquipAmuletReq"
EQUIPAMULETREQ.full_name = ".pomelo.area.EquipAmuletReq"
EQUIPAMULETREQ.nested_types = {}
EQUIPAMULETREQ.enum_types = {}
EQUIPAMULETREQ.fields = {EQUIPAMULETREQ_C2S_GRIDINDEX_FIELD}
EQUIPAMULETREQ.is_extendable = false
EQUIPAMULETREQ.extensions = {}
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.name = "c2s_gridIndex"
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.full_name = ".pomelo.area.UnEquipAmuletReq.c2s_gridIndex"
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.number = 1
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.index = 0
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.label = 2
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.has_default_value = false
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.default_value = ""
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.type = 9
UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD.cpp_type = 9

UNEQUIPAMULETREQ.name = "UnEquipAmuletReq"
UNEQUIPAMULETREQ.full_name = ".pomelo.area.UnEquipAmuletReq"
UNEQUIPAMULETREQ.nested_types = {}
UNEQUIPAMULETREQ.enum_types = {}
UNEQUIPAMULETREQ.fields = {UNEQUIPAMULETREQ_C2S_GRIDINDEX_FIELD}
UNEQUIPAMULETREQ.is_extendable = false
UNEQUIPAMULETREQ.extensions = {}
UNALLEQUIPAMULETREQ.name = "UnAllEquipAmuletReq"
UNALLEQUIPAMULETREQ.full_name = ".pomelo.area.UnAllEquipAmuletReq"
UNALLEQUIPAMULETREQ.nested_types = {}
UNALLEQUIPAMULETREQ.enum_types = {}
UNALLEQUIPAMULETREQ.fields = {}
UNALLEQUIPAMULETREQ.is_extendable = false
UNALLEQUIPAMULETREQ.extensions = {}
EQUIPAMULETRES_S2C_CODE_FIELD.name = "s2c_code"
EQUIPAMULETRES_S2C_CODE_FIELD.full_name = ".pomelo.area.EquipAmuletRes.s2c_code"
EQUIPAMULETRES_S2C_CODE_FIELD.number = 1
EQUIPAMULETRES_S2C_CODE_FIELD.index = 0
EQUIPAMULETRES_S2C_CODE_FIELD.label = 2
EQUIPAMULETRES_S2C_CODE_FIELD.has_default_value = false
EQUIPAMULETRES_S2C_CODE_FIELD.default_value = 0
EQUIPAMULETRES_S2C_CODE_FIELD.type = 5
EQUIPAMULETRES_S2C_CODE_FIELD.cpp_type = 1

EQUIPAMULETRES_S2C_MSG_FIELD.name = "s2c_msg"
EQUIPAMULETRES_S2C_MSG_FIELD.full_name = ".pomelo.area.EquipAmuletRes.s2c_msg"
EQUIPAMULETRES_S2C_MSG_FIELD.number = 2
EQUIPAMULETRES_S2C_MSG_FIELD.index = 1
EQUIPAMULETRES_S2C_MSG_FIELD.label = 1
EQUIPAMULETRES_S2C_MSG_FIELD.has_default_value = false
EQUIPAMULETRES_S2C_MSG_FIELD.default_value = ""
EQUIPAMULETRES_S2C_MSG_FIELD.type = 9
EQUIPAMULETRES_S2C_MSG_FIELD.cpp_type = 9

EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.name = "s2c_totalCount"
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.full_name = ".pomelo.area.EquipAmuletRes.s2c_totalCount"
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.number = 3
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.index = 2
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.label = 1
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.has_default_value = false
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.default_value = 0
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.type = 5
EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.cpp_type = 1

EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.name = "s2c_maxCount"
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.full_name = ".pomelo.area.EquipAmuletRes.s2c_maxCount"
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.number = 4
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.index = 3
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.label = 1
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.has_default_value = false
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.default_value = 0
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.type = 5
EQUIPAMULETRES_S2C_MAXCOUNT_FIELD.cpp_type = 1

EQUIPAMULETRES.name = "EquipAmuletRes"
EQUIPAMULETRES.full_name = ".pomelo.area.EquipAmuletRes"
EQUIPAMULETRES.nested_types = {}
EQUIPAMULETRES.enum_types = {}
EQUIPAMULETRES.fields = {EQUIPAMULETRES_S2C_CODE_FIELD, EQUIPAMULETRES_S2C_MSG_FIELD, EQUIPAMULETRES_S2C_TOTALCOUNT_FIELD, EQUIPAMULETRES_S2C_MAXCOUNT_FIELD}
EQUIPAMULETRES.is_extendable = false
EQUIPAMULETRES.extensions = {}
UNEQUIPAMULETRES_S2C_CODE_FIELD.name = "s2c_code"
UNEQUIPAMULETRES_S2C_CODE_FIELD.full_name = ".pomelo.area.UnEquipAmuletRes.s2c_code"
UNEQUIPAMULETRES_S2C_CODE_FIELD.number = 1
UNEQUIPAMULETRES_S2C_CODE_FIELD.index = 0
UNEQUIPAMULETRES_S2C_CODE_FIELD.label = 2
UNEQUIPAMULETRES_S2C_CODE_FIELD.has_default_value = false
UNEQUIPAMULETRES_S2C_CODE_FIELD.default_value = 0
UNEQUIPAMULETRES_S2C_CODE_FIELD.type = 5
UNEQUIPAMULETRES_S2C_CODE_FIELD.cpp_type = 1

UNEQUIPAMULETRES_S2C_MSG_FIELD.name = "s2c_msg"
UNEQUIPAMULETRES_S2C_MSG_FIELD.full_name = ".pomelo.area.UnEquipAmuletRes.s2c_msg"
UNEQUIPAMULETRES_S2C_MSG_FIELD.number = 2
UNEQUIPAMULETRES_S2C_MSG_FIELD.index = 1
UNEQUIPAMULETRES_S2C_MSG_FIELD.label = 1
UNEQUIPAMULETRES_S2C_MSG_FIELD.has_default_value = false
UNEQUIPAMULETRES_S2C_MSG_FIELD.default_value = ""
UNEQUIPAMULETRES_S2C_MSG_FIELD.type = 9
UNEQUIPAMULETRES_S2C_MSG_FIELD.cpp_type = 9

UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.name = "s2c_totalCount"
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.full_name = ".pomelo.area.UnEquipAmuletRes.s2c_totalCount"
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.number = 3
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.index = 2
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.label = 1
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.has_default_value = false
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.default_value = 0
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.type = 5
UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.cpp_type = 1

UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.name = "s2c_maxCount"
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.full_name = ".pomelo.area.UnEquipAmuletRes.s2c_maxCount"
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.number = 4
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.index = 3
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.label = 1
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.has_default_value = false
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.default_value = 0
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.type = 5
UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.cpp_type = 1

UNEQUIPAMULETRES.name = "UnEquipAmuletRes"
UNEQUIPAMULETRES.full_name = ".pomelo.area.UnEquipAmuletRes"
UNEQUIPAMULETRES.nested_types = {}
UNEQUIPAMULETRES.enum_types = {}
UNEQUIPAMULETRES.fields = {UNEQUIPAMULETRES_S2C_CODE_FIELD, UNEQUIPAMULETRES_S2C_MSG_FIELD, UNEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD, UNEQUIPAMULETRES_S2C_MAXCOUNT_FIELD}
UNEQUIPAMULETRES.is_extendable = false
UNEQUIPAMULETRES.extensions = {}
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.name = "s2c_code"
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.full_name = ".pomelo.area.UnAllEquipAmuletRes.s2c_code"
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.number = 1
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.index = 0
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.label = 2
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.has_default_value = false
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.default_value = 0
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.type = 5
UNALLEQUIPAMULETRES_S2C_CODE_FIELD.cpp_type = 1

UNALLEQUIPAMULETRES_S2C_MSG_FIELD.name = "s2c_msg"
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.full_name = ".pomelo.area.UnAllEquipAmuletRes.s2c_msg"
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.number = 2
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.index = 1
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.label = 1
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.has_default_value = false
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.default_value = ""
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.type = 9
UNALLEQUIPAMULETRES_S2C_MSG_FIELD.cpp_type = 9

UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.name = "s2c_totalCount"
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.full_name = ".pomelo.area.UnAllEquipAmuletRes.s2c_totalCount"
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.number = 3
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.index = 2
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.label = 1
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.has_default_value = false
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.default_value = 0
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.type = 5
UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD.cpp_type = 1

UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.name = "s2c_maxCount"
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.full_name = ".pomelo.area.UnAllEquipAmuletRes.s2c_maxCount"
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.number = 4
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.index = 3
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.label = 1
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.has_default_value = false
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.default_value = 0
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.type = 5
UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD.cpp_type = 1

UNALLEQUIPAMULETRES.name = "UnAllEquipAmuletRes"
UNALLEQUIPAMULETRES.full_name = ".pomelo.area.UnAllEquipAmuletRes"
UNALLEQUIPAMULETRES.nested_types = {}
UNALLEQUIPAMULETRES.enum_types = {}
UNALLEQUIPAMULETRES.fields = {UNALLEQUIPAMULETRES_S2C_CODE_FIELD, UNALLEQUIPAMULETRES_S2C_MSG_FIELD, UNALLEQUIPAMULETRES_S2C_TOTALCOUNT_FIELD, UNALLEQUIPAMULETRES_S2C_MAXCOUNT_FIELD}
UNALLEQUIPAMULETRES.is_extendable = false
UNALLEQUIPAMULETRES.extensions = {}
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.name = "s2c_code"
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.full_name = ".pomelo.area.AmuletEquipNewPush.s2c_code"
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.number = 1
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.index = 0
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.label = 2
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.has_default_value = false
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.default_value = 0
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.type = 5
AMULETEQUIPNEWPUSH_S2C_CODE_FIELD.cpp_type = 1

AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.name = "s2c_msg"
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.full_name = ".pomelo.area.AmuletEquipNewPush.s2c_msg"
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.number = 2
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.index = 1
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.label = 1
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.has_default_value = false
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.default_value = ""
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.type = 9
AMULETEQUIPNEWPUSH_S2C_MSG_FIELD.cpp_type = 9

AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.name = "s2c_totalCount"
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.full_name = ".pomelo.area.AmuletEquipNewPush.s2c_totalCount"
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.number = 3
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.index = 2
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.label = 1
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.has_default_value = false
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.default_value = 0
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.type = 5
AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD.cpp_type = 1

AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.name = "s2c_maxCount"
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.full_name = ".pomelo.area.AmuletEquipNewPush.s2c_maxCount"
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.number = 4
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.index = 3
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.label = 1
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.has_default_value = false
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.default_value = 0
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.type = 5
AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD.cpp_type = 1

AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.name = "s2c_data"
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.full_name = ".pomelo.area.AmuletEquipNewPush.s2c_data"
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.number = 5
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.index = 4
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.label = 3
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.has_default_value = false
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.default_value = {}
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.message_type = item_pb.ITEMDETAIL
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.type = 11
AMULETEQUIPNEWPUSH_S2C_DATA_FIELD.cpp_type = 10

AMULETEQUIPNEWPUSH.name = "AmuletEquipNewPush"
AMULETEQUIPNEWPUSH.full_name = ".pomelo.area.AmuletEquipNewPush"
AMULETEQUIPNEWPUSH.nested_types = {}
AMULETEQUIPNEWPUSH.enum_types = {}
AMULETEQUIPNEWPUSH.fields = {AMULETEQUIPNEWPUSH_S2C_CODE_FIELD, AMULETEQUIPNEWPUSH_S2C_MSG_FIELD, AMULETEQUIPNEWPUSH_S2C_TOTALCOUNT_FIELD, AMULETEQUIPNEWPUSH_S2C_MAXCOUNT_FIELD, AMULETEQUIPNEWPUSH_S2C_DATA_FIELD}
AMULETEQUIPNEWPUSH.is_extendable = false
AMULETEQUIPNEWPUSH.extensions = {}

AmuletEquipNewPush = protobuf.Message(AMULETEQUIPNEWPUSH)
EquipAmuletReq = protobuf.Message(EQUIPAMULETREQ)
EquipAmuletRes = protobuf.Message(EQUIPAMULETRES)
GetAllAmuletDetailReq = protobuf.Message(GETALLAMULETDETAILREQ)
GetAllAmuletDetailRes = protobuf.Message(GETALLAMULETDETAILRES)
UnAllEquipAmuletReq = protobuf.Message(UNALLEQUIPAMULETREQ)
UnAllEquipAmuletRes = protobuf.Message(UNALLEQUIPAMULETRES)
UnEquipAmuletReq = protobuf.Message(UNEQUIPAMULETREQ)
UnEquipAmuletRes = protobuf.Message(UNEQUIPAMULETRES)
