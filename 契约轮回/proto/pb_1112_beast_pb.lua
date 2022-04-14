-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
require("proto/pb_comm_pb")
local pb_comm_pb = pb_comm_pb
module('pb_1112_beast_pb')


M_BEAST_LIST_TOS = protobuf.Descriptor();
M_BEAST_LIST_TOC = protobuf.Descriptor();
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD = protobuf.FieldDescriptor();
M_BEAST_LIST_TOC_LIST_FIELD = protobuf.FieldDescriptor();
M_BEAST_ADDSUMMON_TOS = protobuf.Descriptor();
M_BEAST_ADDSUMMON_TOC = protobuf.Descriptor();
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_LOAD_TOS = protobuf.Descriptor();
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_LOAD_TOC = protobuf.Descriptor();
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_UNLOAD_TOS = protobuf.Descriptor();
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_UNLOAD_TOC = protobuf.Descriptor();
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD = protobuf.FieldDescriptor();
M_BEAST_SUMMON_TOS = protobuf.Descriptor();
M_BEAST_SUMMON_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_SUMMON_TOC = protobuf.Descriptor();
M_BEAST_SUMMON_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_UNSUMMON_TOS = protobuf.Descriptor();
M_BEAST_UNSUMMON_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_UNSUMMON_TOC = protobuf.Descriptor();
M_BEAST_UNSUMMON_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_REINFORCE_TOS = protobuf.Descriptor();
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_REINFORCE_TOC = protobuf.Descriptor();
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD = protobuf.FieldDescriptor();
P_BEAST = protobuf.Descriptor();
P_BEAST_ID_FIELD = protobuf.FieldDescriptor();
P_BEAST_EQUIPS_FIELD = protobuf.FieldDescriptor();
P_BEAST_SUMMON_FIELD = protobuf.FieldDescriptor();

M_BEAST_LIST_TOS.name = "m_beast_list_tos"
M_BEAST_LIST_TOS.full_name = ".m_beast_list_tos"
M_BEAST_LIST_TOS.nested_types = {}
M_BEAST_LIST_TOS.enum_types = {}
M_BEAST_LIST_TOS.fields = {}
M_BEAST_LIST_TOS.is_extendable = false
M_BEAST_LIST_TOS.extensions = {}
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.name = "max_summon"
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.full_name = ".m_beast_list_toc.max_summon"
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.number = 1
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.index = 0
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.label = 2
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.has_default_value = false
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.default_value = 0
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.type = 5
M_BEAST_LIST_TOC_MAX_SUMMON_FIELD.cpp_type = 1

M_BEAST_LIST_TOC_LIST_FIELD.name = "list"
M_BEAST_LIST_TOC_LIST_FIELD.full_name = ".m_beast_list_toc.list"
M_BEAST_LIST_TOC_LIST_FIELD.number = 2
M_BEAST_LIST_TOC_LIST_FIELD.index = 1
M_BEAST_LIST_TOC_LIST_FIELD.label = 3
M_BEAST_LIST_TOC_LIST_FIELD.has_default_value = false
M_BEAST_LIST_TOC_LIST_FIELD.default_value = {}
M_BEAST_LIST_TOC_LIST_FIELD.message_type = P_BEAST
M_BEAST_LIST_TOC_LIST_FIELD.type = 11
M_BEAST_LIST_TOC_LIST_FIELD.cpp_type = 10

M_BEAST_LIST_TOC.name = "m_beast_list_toc"
M_BEAST_LIST_TOC.full_name = ".m_beast_list_toc"
M_BEAST_LIST_TOC.nested_types = {}
M_BEAST_LIST_TOC.enum_types = {}
M_BEAST_LIST_TOC.fields = {M_BEAST_LIST_TOC_MAX_SUMMON_FIELD, M_BEAST_LIST_TOC_LIST_FIELD}
M_BEAST_LIST_TOC.is_extendable = false
M_BEAST_LIST_TOC.extensions = {}
M_BEAST_ADDSUMMON_TOS.name = "m_beast_addsummon_tos"
M_BEAST_ADDSUMMON_TOS.full_name = ".m_beast_addsummon_tos"
M_BEAST_ADDSUMMON_TOS.nested_types = {}
M_BEAST_ADDSUMMON_TOS.enum_types = {}
M_BEAST_ADDSUMMON_TOS.fields = {}
M_BEAST_ADDSUMMON_TOS.is_extendable = false
M_BEAST_ADDSUMMON_TOS.extensions = {}
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.name = "max_summon"
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.full_name = ".m_beast_addsummon_toc.max_summon"
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.number = 1
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.index = 0
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.label = 2
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.has_default_value = false
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.default_value = 0
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.type = 5
M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD.cpp_type = 1

M_BEAST_ADDSUMMON_TOC.name = "m_beast_addsummon_toc"
M_BEAST_ADDSUMMON_TOC.full_name = ".m_beast_addsummon_toc"
M_BEAST_ADDSUMMON_TOC.nested_types = {}
M_BEAST_ADDSUMMON_TOC.enum_types = {}
M_BEAST_ADDSUMMON_TOC.fields = {M_BEAST_ADDSUMMON_TOC_MAX_SUMMON_FIELD}
M_BEAST_ADDSUMMON_TOC.is_extendable = false
M_BEAST_ADDSUMMON_TOC.extensions = {}
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.name = "id"
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.full_name = ".m_beast_equip_load_tos.id"
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.number = 1
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.index = 0
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.label = 2
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.has_default_value = false
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.default_value = 0
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.type = 5
M_BEAST_EQUIP_LOAD_TOS_ID_FIELD.cpp_type = 1

M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.name = "uid"
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.full_name = ".m_beast_equip_load_tos.uid"
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.number = 2
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.index = 1
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.label = 2
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.has_default_value = false
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.default_value = 0
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.type = 5
M_BEAST_EQUIP_LOAD_TOS_UID_FIELD.cpp_type = 1

M_BEAST_EQUIP_LOAD_TOS.name = "m_beast_equip_load_tos"
M_BEAST_EQUIP_LOAD_TOS.full_name = ".m_beast_equip_load_tos"
M_BEAST_EQUIP_LOAD_TOS.nested_types = {}
M_BEAST_EQUIP_LOAD_TOS.enum_types = {}
M_BEAST_EQUIP_LOAD_TOS.fields = {M_BEAST_EQUIP_LOAD_TOS_ID_FIELD, M_BEAST_EQUIP_LOAD_TOS_UID_FIELD}
M_BEAST_EQUIP_LOAD_TOS.is_extendable = false
M_BEAST_EQUIP_LOAD_TOS.extensions = {}
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.name = "id"
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.full_name = ".m_beast_equip_load_toc.id"
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.number = 1
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.index = 0
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.label = 2
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.has_default_value = false
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.default_value = 0
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.type = 5
M_BEAST_EQUIP_LOAD_TOC_ID_FIELD.cpp_type = 1

M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.name = "equip"
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.full_name = ".m_beast_equip_load_toc.equip"
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.number = 2
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.index = 1
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.label = 2
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.has_default_value = false
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.default_value = nil
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.message_type = pb_comm_pb.P_ITEM
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.type = 11
M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD.cpp_type = 10

M_BEAST_EQUIP_LOAD_TOC.name = "m_beast_equip_load_toc"
M_BEAST_EQUIP_LOAD_TOC.full_name = ".m_beast_equip_load_toc"
M_BEAST_EQUIP_LOAD_TOC.nested_types = {}
M_BEAST_EQUIP_LOAD_TOC.enum_types = {}
M_BEAST_EQUIP_LOAD_TOC.fields = {M_BEAST_EQUIP_LOAD_TOC_ID_FIELD, M_BEAST_EQUIP_LOAD_TOC_EQUIP_FIELD}
M_BEAST_EQUIP_LOAD_TOC.is_extendable = false
M_BEAST_EQUIP_LOAD_TOC.extensions = {}
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.name = "id"
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.full_name = ".m_beast_equip_unload_tos.id"
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.number = 1
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.index = 0
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.label = 2
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.has_default_value = false
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.default_value = 0
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.type = 5
M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD.cpp_type = 1

M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.name = "slot"
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.full_name = ".m_beast_equip_unload_tos.slot"
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.number = 2
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.index = 1
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.label = 2
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.has_default_value = false
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.default_value = 0
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.type = 5
M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD.cpp_type = 1

M_BEAST_EQUIP_UNLOAD_TOS.name = "m_beast_equip_unload_tos"
M_BEAST_EQUIP_UNLOAD_TOS.full_name = ".m_beast_equip_unload_tos"
M_BEAST_EQUIP_UNLOAD_TOS.nested_types = {}
M_BEAST_EQUIP_UNLOAD_TOS.enum_types = {}
M_BEAST_EQUIP_UNLOAD_TOS.fields = {M_BEAST_EQUIP_UNLOAD_TOS_ID_FIELD, M_BEAST_EQUIP_UNLOAD_TOS_SLOT_FIELD}
M_BEAST_EQUIP_UNLOAD_TOS.is_extendable = false
M_BEAST_EQUIP_UNLOAD_TOS.extensions = {}
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.name = "id"
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.full_name = ".m_beast_equip_unload_toc.id"
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.number = 1
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.index = 0
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.label = 2
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.has_default_value = false
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.default_value = 0
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.type = 5
M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD.cpp_type = 1

M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.name = "slot"
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.full_name = ".m_beast_equip_unload_toc.slot"
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.number = 2
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.index = 1
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.label = 2
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.has_default_value = false
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.default_value = 0
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.type = 5
M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD.cpp_type = 1

M_BEAST_EQUIP_UNLOAD_TOC.name = "m_beast_equip_unload_toc"
M_BEAST_EQUIP_UNLOAD_TOC.full_name = ".m_beast_equip_unload_toc"
M_BEAST_EQUIP_UNLOAD_TOC.nested_types = {}
M_BEAST_EQUIP_UNLOAD_TOC.enum_types = {}
M_BEAST_EQUIP_UNLOAD_TOC.fields = {M_BEAST_EQUIP_UNLOAD_TOC_ID_FIELD, M_BEAST_EQUIP_UNLOAD_TOC_SLOT_FIELD}
M_BEAST_EQUIP_UNLOAD_TOC.is_extendable = false
M_BEAST_EQUIP_UNLOAD_TOC.extensions = {}
M_BEAST_SUMMON_TOS_ID_FIELD.name = "id"
M_BEAST_SUMMON_TOS_ID_FIELD.full_name = ".m_beast_summon_tos.id"
M_BEAST_SUMMON_TOS_ID_FIELD.number = 1
M_BEAST_SUMMON_TOS_ID_FIELD.index = 0
M_BEAST_SUMMON_TOS_ID_FIELD.label = 2
M_BEAST_SUMMON_TOS_ID_FIELD.has_default_value = false
M_BEAST_SUMMON_TOS_ID_FIELD.default_value = 0
M_BEAST_SUMMON_TOS_ID_FIELD.type = 5
M_BEAST_SUMMON_TOS_ID_FIELD.cpp_type = 1

M_BEAST_SUMMON_TOS.name = "m_beast_summon_tos"
M_BEAST_SUMMON_TOS.full_name = ".m_beast_summon_tos"
M_BEAST_SUMMON_TOS.nested_types = {}
M_BEAST_SUMMON_TOS.enum_types = {}
M_BEAST_SUMMON_TOS.fields = {M_BEAST_SUMMON_TOS_ID_FIELD}
M_BEAST_SUMMON_TOS.is_extendable = false
M_BEAST_SUMMON_TOS.extensions = {}
M_BEAST_SUMMON_TOC_ID_FIELD.name = "id"
M_BEAST_SUMMON_TOC_ID_FIELD.full_name = ".m_beast_summon_toc.id"
M_BEAST_SUMMON_TOC_ID_FIELD.number = 1
M_BEAST_SUMMON_TOC_ID_FIELD.index = 0
M_BEAST_SUMMON_TOC_ID_FIELD.label = 2
M_BEAST_SUMMON_TOC_ID_FIELD.has_default_value = false
M_BEAST_SUMMON_TOC_ID_FIELD.default_value = 0
M_BEAST_SUMMON_TOC_ID_FIELD.type = 5
M_BEAST_SUMMON_TOC_ID_FIELD.cpp_type = 1

M_BEAST_SUMMON_TOC.name = "m_beast_summon_toc"
M_BEAST_SUMMON_TOC.full_name = ".m_beast_summon_toc"
M_BEAST_SUMMON_TOC.nested_types = {}
M_BEAST_SUMMON_TOC.enum_types = {}
M_BEAST_SUMMON_TOC.fields = {M_BEAST_SUMMON_TOC_ID_FIELD}
M_BEAST_SUMMON_TOC.is_extendable = false
M_BEAST_SUMMON_TOC.extensions = {}
M_BEAST_UNSUMMON_TOS_ID_FIELD.name = "id"
M_BEAST_UNSUMMON_TOS_ID_FIELD.full_name = ".m_beast_unsummon_tos.id"
M_BEAST_UNSUMMON_TOS_ID_FIELD.number = 1
M_BEAST_UNSUMMON_TOS_ID_FIELD.index = 0
M_BEAST_UNSUMMON_TOS_ID_FIELD.label = 2
M_BEAST_UNSUMMON_TOS_ID_FIELD.has_default_value = false
M_BEAST_UNSUMMON_TOS_ID_FIELD.default_value = 0
M_BEAST_UNSUMMON_TOS_ID_FIELD.type = 5
M_BEAST_UNSUMMON_TOS_ID_FIELD.cpp_type = 1

M_BEAST_UNSUMMON_TOS.name = "m_beast_unsummon_tos"
M_BEAST_UNSUMMON_TOS.full_name = ".m_beast_unsummon_tos"
M_BEAST_UNSUMMON_TOS.nested_types = {}
M_BEAST_UNSUMMON_TOS.enum_types = {}
M_BEAST_UNSUMMON_TOS.fields = {M_BEAST_UNSUMMON_TOS_ID_FIELD}
M_BEAST_UNSUMMON_TOS.is_extendable = false
M_BEAST_UNSUMMON_TOS.extensions = {}
M_BEAST_UNSUMMON_TOC_ID_FIELD.name = "id"
M_BEAST_UNSUMMON_TOC_ID_FIELD.full_name = ".m_beast_unsummon_toc.id"
M_BEAST_UNSUMMON_TOC_ID_FIELD.number = 1
M_BEAST_UNSUMMON_TOC_ID_FIELD.index = 0
M_BEAST_UNSUMMON_TOC_ID_FIELD.label = 2
M_BEAST_UNSUMMON_TOC_ID_FIELD.has_default_value = false
M_BEAST_UNSUMMON_TOC_ID_FIELD.default_value = 0
M_BEAST_UNSUMMON_TOC_ID_FIELD.type = 5
M_BEAST_UNSUMMON_TOC_ID_FIELD.cpp_type = 1

M_BEAST_UNSUMMON_TOC.name = "m_beast_unsummon_toc"
M_BEAST_UNSUMMON_TOC.full_name = ".m_beast_unsummon_toc"
M_BEAST_UNSUMMON_TOC.nested_types = {}
M_BEAST_UNSUMMON_TOC.enum_types = {}
M_BEAST_UNSUMMON_TOC.fields = {M_BEAST_UNSUMMON_TOC_ID_FIELD}
M_BEAST_UNSUMMON_TOC.is_extendable = false
M_BEAST_UNSUMMON_TOC.extensions = {}
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.name = "id"
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.full_name = ".m_beast_equip_reinforce_tos.id"
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.number = 1
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.index = 0
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.label = 2
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.has_default_value = false
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.default_value = 0
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.type = 5
M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD.cpp_type = 1

M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.name = "uid"
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.full_name = ".m_beast_equip_reinforce_tos.uid"
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.number = 2
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.index = 1
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.label = 2
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.has_default_value = false
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.default_value = 0
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.type = 5
M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD.cpp_type = 1

M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.name = "cellids"
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.full_name = ".m_beast_equip_reinforce_tos.cellids"
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.number = 3
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.index = 2
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.label = 3
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.has_default_value = false
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.default_value = {}
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.type = 5
M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD.cpp_type = 1

M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.name = "use_gold"
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.full_name = ".m_beast_equip_reinforce_tos.use_gold"
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.number = 4
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.index = 3
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.label = 2
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.has_default_value = false
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.default_value = false
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.type = 8
M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD.cpp_type = 7

M_BEAST_EQUIP_REINFORCE_TOS.name = "m_beast_equip_reinforce_tos"
M_BEAST_EQUIP_REINFORCE_TOS.full_name = ".m_beast_equip_reinforce_tos"
M_BEAST_EQUIP_REINFORCE_TOS.nested_types = {}
M_BEAST_EQUIP_REINFORCE_TOS.enum_types = {}
M_BEAST_EQUIP_REINFORCE_TOS.fields = {M_BEAST_EQUIP_REINFORCE_TOS_ID_FIELD, M_BEAST_EQUIP_REINFORCE_TOS_UID_FIELD, M_BEAST_EQUIP_REINFORCE_TOS_CELLIDS_FIELD, M_BEAST_EQUIP_REINFORCE_TOS_USE_GOLD_FIELD}
M_BEAST_EQUIP_REINFORCE_TOS.is_extendable = false
M_BEAST_EQUIP_REINFORCE_TOS.extensions = {}
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.name = "id"
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.full_name = ".m_beast_equip_reinforce_toc.id"
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.number = 1
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.index = 0
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.label = 2
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.has_default_value = false
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.default_value = 0
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.type = 5
M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD.cpp_type = 1

M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.name = "equip"
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.full_name = ".m_beast_equip_reinforce_toc.equip"
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.number = 2
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.index = 1
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.label = 2
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.has_default_value = false
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.default_value = nil
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.message_type = pb_comm_pb.P_ITEM
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.type = 11
M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD.cpp_type = 10

M_BEAST_EQUIP_REINFORCE_TOC.name = "m_beast_equip_reinforce_toc"
M_BEAST_EQUIP_REINFORCE_TOC.full_name = ".m_beast_equip_reinforce_toc"
M_BEAST_EQUIP_REINFORCE_TOC.nested_types = {}
M_BEAST_EQUIP_REINFORCE_TOC.enum_types = {}
M_BEAST_EQUIP_REINFORCE_TOC.fields = {M_BEAST_EQUIP_REINFORCE_TOC_ID_FIELD, M_BEAST_EQUIP_REINFORCE_TOC_EQUIP_FIELD}
M_BEAST_EQUIP_REINFORCE_TOC.is_extendable = false
M_BEAST_EQUIP_REINFORCE_TOC.extensions = {}
P_BEAST_ID_FIELD.name = "id"
P_BEAST_ID_FIELD.full_name = ".p_beast.id"
P_BEAST_ID_FIELD.number = 1
P_BEAST_ID_FIELD.index = 0
P_BEAST_ID_FIELD.label = 2
P_BEAST_ID_FIELD.has_default_value = false
P_BEAST_ID_FIELD.default_value = 0
P_BEAST_ID_FIELD.type = 5
P_BEAST_ID_FIELD.cpp_type = 1

P_BEAST_EQUIPS_FIELD.name = "equips"
P_BEAST_EQUIPS_FIELD.full_name = ".p_beast.equips"
P_BEAST_EQUIPS_FIELD.number = 2
P_BEAST_EQUIPS_FIELD.index = 1
P_BEAST_EQUIPS_FIELD.label = 3
P_BEAST_EQUIPS_FIELD.has_default_value = false
P_BEAST_EQUIPS_FIELD.default_value = {}
P_BEAST_EQUIPS_FIELD.message_type = pb_comm_pb.P_ITEM
P_BEAST_EQUIPS_FIELD.type = 11
P_BEAST_EQUIPS_FIELD.cpp_type = 10

P_BEAST_SUMMON_FIELD.name = "summon"
P_BEAST_SUMMON_FIELD.full_name = ".p_beast.summon"
P_BEAST_SUMMON_FIELD.number = 3
P_BEAST_SUMMON_FIELD.index = 2
P_BEAST_SUMMON_FIELD.label = 2
P_BEAST_SUMMON_FIELD.has_default_value = false
P_BEAST_SUMMON_FIELD.default_value = false
P_BEAST_SUMMON_FIELD.type = 8
P_BEAST_SUMMON_FIELD.cpp_type = 7

P_BEAST.name = "p_beast"
P_BEAST.full_name = ".p_beast"
P_BEAST.nested_types = {}
P_BEAST.enum_types = {}
P_BEAST.fields = {P_BEAST_ID_FIELD, P_BEAST_EQUIPS_FIELD, P_BEAST_SUMMON_FIELD}
P_BEAST.is_extendable = false
P_BEAST.extensions = {}

m_beast_addsummon_toc = protobuf.Message(M_BEAST_ADDSUMMON_TOC)
m_beast_addsummon_tos = protobuf.Message(M_BEAST_ADDSUMMON_TOS)
m_beast_equip_load_toc = protobuf.Message(M_BEAST_EQUIP_LOAD_TOC)
m_beast_equip_load_tos = protobuf.Message(M_BEAST_EQUIP_LOAD_TOS)
m_beast_equip_reinforce_toc = protobuf.Message(M_BEAST_EQUIP_REINFORCE_TOC)
m_beast_equip_reinforce_tos = protobuf.Message(M_BEAST_EQUIP_REINFORCE_TOS)
m_beast_equip_unload_toc = protobuf.Message(M_BEAST_EQUIP_UNLOAD_TOC)
m_beast_equip_unload_tos = protobuf.Message(M_BEAST_EQUIP_UNLOAD_TOS)
m_beast_list_toc = protobuf.Message(M_BEAST_LIST_TOC)
m_beast_list_tos = protobuf.Message(M_BEAST_LIST_TOS)
m_beast_summon_toc = protobuf.Message(M_BEAST_SUMMON_TOC)
m_beast_summon_tos = protobuf.Message(M_BEAST_SUMMON_TOS)
m_beast_unsummon_toc = protobuf.Message(M_BEAST_UNSUMMON_TOC)
m_beast_unsummon_tos = protobuf.Message(M_BEAST_UNSUMMON_TOS)
p_beast = protobuf.Message(P_BEAST)

