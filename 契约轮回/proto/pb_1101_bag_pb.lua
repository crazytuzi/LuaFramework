-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
require("proto/pb_comm_pb")
local pb_comm_pb = pb_comm_pb
module('pb_1101_bag_pb')


M_BAG_INFO_TOS = protobuf.Descriptor();
M_BAG_INFO_TOS_BAG_ID_FIELD = protobuf.FieldDescriptor();
M_BAG_INFO_TOC = protobuf.Descriptor();
M_BAG_INFO_TOC_BAG_ID_FIELD = protobuf.FieldDescriptor();
M_BAG_INFO_TOC_OPENED_FIELD = protobuf.FieldDescriptor();
M_BAG_INFO_TOC_ITEMS_FIELD = protobuf.FieldDescriptor();
M_BAG_OPEN_TOS = protobuf.Descriptor();
M_BAG_OPEN_TOS_BAG_ID_FIELD = protobuf.FieldDescriptor();
M_BAG_OPEN_TOS_NUM_FIELD = protobuf.FieldDescriptor();
M_BAG_OPEN_TOC = protobuf.Descriptor();
M_BAG_OPEN_TOC_BAG_ID_FIELD = protobuf.FieldDescriptor();
M_BAG_OPEN_TOC_NUM_FIELD = protobuf.FieldDescriptor();
M_BAG_UPDATE_TOC = protobuf.Descriptor();
M_BAG_UPDATE_TOC_CHGENTRY = protobuf.Descriptor();
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD = protobuf.FieldDescriptor();
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD = protobuf.FieldDescriptor();
M_BAG_UPDATE_TOC_ADD_FIELD = protobuf.FieldDescriptor();
M_BAG_UPDATE_TOC_DEL_FIELD = protobuf.FieldDescriptor();
M_BAG_UPDATE_TOC_CHG_FIELD = protobuf.FieldDescriptor();
M_BAG_UPDATE_TOC_WAY_FIELD = protobuf.FieldDescriptor();

M_BAG_INFO_TOS_BAG_ID_FIELD.name = "bag_id"
M_BAG_INFO_TOS_BAG_ID_FIELD.full_name = ".m_bag_info_tos.bag_id"
M_BAG_INFO_TOS_BAG_ID_FIELD.number = 1
M_BAG_INFO_TOS_BAG_ID_FIELD.index = 0
M_BAG_INFO_TOS_BAG_ID_FIELD.label = 2
M_BAG_INFO_TOS_BAG_ID_FIELD.has_default_value = false
M_BAG_INFO_TOS_BAG_ID_FIELD.default_value = 0
M_BAG_INFO_TOS_BAG_ID_FIELD.type = 5
M_BAG_INFO_TOS_BAG_ID_FIELD.cpp_type = 1

M_BAG_INFO_TOS.name = "m_bag_info_tos"
M_BAG_INFO_TOS.full_name = ".m_bag_info_tos"
M_BAG_INFO_TOS.nested_types = {}
M_BAG_INFO_TOS.enum_types = {}
M_BAG_INFO_TOS.fields = {M_BAG_INFO_TOS_BAG_ID_FIELD}
M_BAG_INFO_TOS.is_extendable = false
M_BAG_INFO_TOS.extensions = {}
M_BAG_INFO_TOC_BAG_ID_FIELD.name = "bag_id"
M_BAG_INFO_TOC_BAG_ID_FIELD.full_name = ".m_bag_info_toc.bag_id"
M_BAG_INFO_TOC_BAG_ID_FIELD.number = 1
M_BAG_INFO_TOC_BAG_ID_FIELD.index = 0
M_BAG_INFO_TOC_BAG_ID_FIELD.label = 2
M_BAG_INFO_TOC_BAG_ID_FIELD.has_default_value = false
M_BAG_INFO_TOC_BAG_ID_FIELD.default_value = 0
M_BAG_INFO_TOC_BAG_ID_FIELD.type = 5
M_BAG_INFO_TOC_BAG_ID_FIELD.cpp_type = 1

M_BAG_INFO_TOC_OPENED_FIELD.name = "opened"
M_BAG_INFO_TOC_OPENED_FIELD.full_name = ".m_bag_info_toc.opened"
M_BAG_INFO_TOC_OPENED_FIELD.number = 2
M_BAG_INFO_TOC_OPENED_FIELD.index = 1
M_BAG_INFO_TOC_OPENED_FIELD.label = 2
M_BAG_INFO_TOC_OPENED_FIELD.has_default_value = false
M_BAG_INFO_TOC_OPENED_FIELD.default_value = 0
M_BAG_INFO_TOC_OPENED_FIELD.type = 5
M_BAG_INFO_TOC_OPENED_FIELD.cpp_type = 1

M_BAG_INFO_TOC_ITEMS_FIELD.name = "items"
M_BAG_INFO_TOC_ITEMS_FIELD.full_name = ".m_bag_info_toc.items"
M_BAG_INFO_TOC_ITEMS_FIELD.number = 3
M_BAG_INFO_TOC_ITEMS_FIELD.index = 2
M_BAG_INFO_TOC_ITEMS_FIELD.label = 3
M_BAG_INFO_TOC_ITEMS_FIELD.has_default_value = false
M_BAG_INFO_TOC_ITEMS_FIELD.default_value = {}
M_BAG_INFO_TOC_ITEMS_FIELD.message_type = pb_comm_pb.P_ITEM_BASE
M_BAG_INFO_TOC_ITEMS_FIELD.type = 11
M_BAG_INFO_TOC_ITEMS_FIELD.cpp_type = 10

M_BAG_INFO_TOC.name = "m_bag_info_toc"
M_BAG_INFO_TOC.full_name = ".m_bag_info_toc"
M_BAG_INFO_TOC.nested_types = {}
M_BAG_INFO_TOC.enum_types = {}
M_BAG_INFO_TOC.fields = {M_BAG_INFO_TOC_BAG_ID_FIELD, M_BAG_INFO_TOC_OPENED_FIELD, M_BAG_INFO_TOC_ITEMS_FIELD}
M_BAG_INFO_TOC.is_extendable = false
M_BAG_INFO_TOC.extensions = {}
M_BAG_OPEN_TOS_BAG_ID_FIELD.name = "bag_id"
M_BAG_OPEN_TOS_BAG_ID_FIELD.full_name = ".m_bag_open_tos.bag_id"
M_BAG_OPEN_TOS_BAG_ID_FIELD.number = 1
M_BAG_OPEN_TOS_BAG_ID_FIELD.index = 0
M_BAG_OPEN_TOS_BAG_ID_FIELD.label = 2
M_BAG_OPEN_TOS_BAG_ID_FIELD.has_default_value = false
M_BAG_OPEN_TOS_BAG_ID_FIELD.default_value = 0
M_BAG_OPEN_TOS_BAG_ID_FIELD.type = 5
M_BAG_OPEN_TOS_BAG_ID_FIELD.cpp_type = 1

M_BAG_OPEN_TOS_NUM_FIELD.name = "num"
M_BAG_OPEN_TOS_NUM_FIELD.full_name = ".m_bag_open_tos.num"
M_BAG_OPEN_TOS_NUM_FIELD.number = 2
M_BAG_OPEN_TOS_NUM_FIELD.index = 1
M_BAG_OPEN_TOS_NUM_FIELD.label = 2
M_BAG_OPEN_TOS_NUM_FIELD.has_default_value = false
M_BAG_OPEN_TOS_NUM_FIELD.default_value = 0
M_BAG_OPEN_TOS_NUM_FIELD.type = 5
M_BAG_OPEN_TOS_NUM_FIELD.cpp_type = 1

M_BAG_OPEN_TOS.name = "m_bag_open_tos"
M_BAG_OPEN_TOS.full_name = ".m_bag_open_tos"
M_BAG_OPEN_TOS.nested_types = {}
M_BAG_OPEN_TOS.enum_types = {}
M_BAG_OPEN_TOS.fields = {M_BAG_OPEN_TOS_BAG_ID_FIELD, M_BAG_OPEN_TOS_NUM_FIELD}
M_BAG_OPEN_TOS.is_extendable = false
M_BAG_OPEN_TOS.extensions = {}
M_BAG_OPEN_TOC_BAG_ID_FIELD.name = "bag_id"
M_BAG_OPEN_TOC_BAG_ID_FIELD.full_name = ".m_bag_open_toc.bag_id"
M_BAG_OPEN_TOC_BAG_ID_FIELD.number = 1
M_BAG_OPEN_TOC_BAG_ID_FIELD.index = 0
M_BAG_OPEN_TOC_BAG_ID_FIELD.label = 2
M_BAG_OPEN_TOC_BAG_ID_FIELD.has_default_value = false
M_BAG_OPEN_TOC_BAG_ID_FIELD.default_value = 0
M_BAG_OPEN_TOC_BAG_ID_FIELD.type = 5
M_BAG_OPEN_TOC_BAG_ID_FIELD.cpp_type = 1

M_BAG_OPEN_TOC_NUM_FIELD.name = "num"
M_BAG_OPEN_TOC_NUM_FIELD.full_name = ".m_bag_open_toc.num"
M_BAG_OPEN_TOC_NUM_FIELD.number = 2
M_BAG_OPEN_TOC_NUM_FIELD.index = 1
M_BAG_OPEN_TOC_NUM_FIELD.label = 2
M_BAG_OPEN_TOC_NUM_FIELD.has_default_value = false
M_BAG_OPEN_TOC_NUM_FIELD.default_value = 0
M_BAG_OPEN_TOC_NUM_FIELD.type = 5
M_BAG_OPEN_TOC_NUM_FIELD.cpp_type = 1

M_BAG_OPEN_TOC.name = "m_bag_open_toc"
M_BAG_OPEN_TOC.full_name = ".m_bag_open_toc"
M_BAG_OPEN_TOC.nested_types = {}
M_BAG_OPEN_TOC.enum_types = {}
M_BAG_OPEN_TOC.fields = {M_BAG_OPEN_TOC_BAG_ID_FIELD, M_BAG_OPEN_TOC_NUM_FIELD}
M_BAG_OPEN_TOC.is_extendable = false
M_BAG_OPEN_TOC.extensions = {}
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.name = "key"
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.full_name = ".m_bag_update_toc.ChgEntry.key"
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.number = 1
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.index = 0
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.label = 1
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.has_default_value = false
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.default_value = 0
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.type = 5
M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD.cpp_type = 1

M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.name = "value"
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.full_name = ".m_bag_update_toc.ChgEntry.value"
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.number = 2
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.index = 1
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.label = 1
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.has_default_value = false
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.default_value = 0
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.type = 5
M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD.cpp_type = 1

M_BAG_UPDATE_TOC_CHGENTRY.name = "ChgEntry"
M_BAG_UPDATE_TOC_CHGENTRY.full_name = ".m_bag_update_toc.ChgEntry"
M_BAG_UPDATE_TOC_CHGENTRY.nested_types = {}
M_BAG_UPDATE_TOC_CHGENTRY.enum_types = {}
M_BAG_UPDATE_TOC_CHGENTRY.fields = {M_BAG_UPDATE_TOC_CHGENTRY_KEY_FIELD, M_BAG_UPDATE_TOC_CHGENTRY_VALUE_FIELD}
M_BAG_UPDATE_TOC_CHGENTRY.is_extendable = false
M_BAG_UPDATE_TOC_CHGENTRY.extensions = {}
M_BAG_UPDATE_TOC_CHGENTRY.containing_type = M_BAG_UPDATE_TOC
M_BAG_UPDATE_TOC_ADD_FIELD.name = "add"
M_BAG_UPDATE_TOC_ADD_FIELD.full_name = ".m_bag_update_toc.add"
M_BAG_UPDATE_TOC_ADD_FIELD.number = 1
M_BAG_UPDATE_TOC_ADD_FIELD.index = 0
M_BAG_UPDATE_TOC_ADD_FIELD.label = 3
M_BAG_UPDATE_TOC_ADD_FIELD.has_default_value = false
M_BAG_UPDATE_TOC_ADD_FIELD.default_value = {}
M_BAG_UPDATE_TOC_ADD_FIELD.message_type = pb_comm_pb.P_ITEM_BASE
M_BAG_UPDATE_TOC_ADD_FIELD.type = 11
M_BAG_UPDATE_TOC_ADD_FIELD.cpp_type = 10

M_BAG_UPDATE_TOC_DEL_FIELD.name = "del"
M_BAG_UPDATE_TOC_DEL_FIELD.full_name = ".m_bag_update_toc.del"
M_BAG_UPDATE_TOC_DEL_FIELD.number = 2
M_BAG_UPDATE_TOC_DEL_FIELD.index = 1
M_BAG_UPDATE_TOC_DEL_FIELD.label = 3
M_BAG_UPDATE_TOC_DEL_FIELD.has_default_value = false
M_BAG_UPDATE_TOC_DEL_FIELD.default_value = {}
M_BAG_UPDATE_TOC_DEL_FIELD.type = 5
M_BAG_UPDATE_TOC_DEL_FIELD.cpp_type = 1

M_BAG_UPDATE_TOC_CHG_FIELD.name = "chg"
M_BAG_UPDATE_TOC_CHG_FIELD.full_name = ".m_bag_update_toc.chg"
M_BAG_UPDATE_TOC_CHG_FIELD.number = 3
M_BAG_UPDATE_TOC_CHG_FIELD.index = 2
M_BAG_UPDATE_TOC_CHG_FIELD.label = 3
M_BAG_UPDATE_TOC_CHG_FIELD.has_default_value = false
M_BAG_UPDATE_TOC_CHG_FIELD.default_value = {}
M_BAG_UPDATE_TOC_CHG_FIELD.message_type = M_BAG_UPDATE_TOC_CHGENTRY
M_BAG_UPDATE_TOC_CHG_FIELD.type = 11
M_BAG_UPDATE_TOC_CHG_FIELD.cpp_type = 10

M_BAG_UPDATE_TOC_WAY_FIELD.name = "way"
M_BAG_UPDATE_TOC_WAY_FIELD.full_name = ".m_bag_update_toc.way"
M_BAG_UPDATE_TOC_WAY_FIELD.number = 4
M_BAG_UPDATE_TOC_WAY_FIELD.index = 3
M_BAG_UPDATE_TOC_WAY_FIELD.label = 2
M_BAG_UPDATE_TOC_WAY_FIELD.has_default_value = false
M_BAG_UPDATE_TOC_WAY_FIELD.default_value = 0
M_BAG_UPDATE_TOC_WAY_FIELD.type = 5
M_BAG_UPDATE_TOC_WAY_FIELD.cpp_type = 1

M_BAG_UPDATE_TOC.name = "m_bag_update_toc"
M_BAG_UPDATE_TOC.full_name = ".m_bag_update_toc"
M_BAG_UPDATE_TOC.nested_types = {M_BAG_UPDATE_TOC_CHGENTRY}
M_BAG_UPDATE_TOC.enum_types = {}
M_BAG_UPDATE_TOC.fields = {M_BAG_UPDATE_TOC_ADD_FIELD, M_BAG_UPDATE_TOC_DEL_FIELD, M_BAG_UPDATE_TOC_CHG_FIELD, M_BAG_UPDATE_TOC_WAY_FIELD}
M_BAG_UPDATE_TOC.is_extendable = false
M_BAG_UPDATE_TOC.extensions = {}

m_bag_info_toc = protobuf.Message(M_BAG_INFO_TOC)
m_bag_info_tos = protobuf.Message(M_BAG_INFO_TOS)
m_bag_open_toc = protobuf.Message(M_BAG_OPEN_TOC)
m_bag_open_tos = protobuf.Message(M_BAG_OPEN_TOS)
m_bag_update_toc = protobuf.Message(M_BAG_UPDATE_TOC)
m_bag_update_toc.ChgEntry = protobuf.Message(M_BAG_UPDATE_TOC_CHGENTRY)

