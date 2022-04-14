-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
require("proto/pb_comm_pb")
local pb_comm_pb = pb_comm_pb
module('pb_1147_mecha_pb')


M_MECHA_LIST_TOS = protobuf.Descriptor();
M_MECHA_LIST_TOC = protobuf.Descriptor();
M_MECHA_LIST_TOC_MECHAS_FIELD = protobuf.FieldDescriptor();
M_MECHA_LIST_TOC_USE_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_UPSTAR_TOS = protobuf.Descriptor();
M_MECHA_UPSTAR_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_UPSTAR_TOC = protobuf.Descriptor();
M_MECHA_UPSTAR_TOC_MECHA_FIELD = protobuf.FieldDescriptor();
M_MECHA_UPGRADE_TOS = protobuf.Descriptor();
M_MECHA_UPGRADE_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_UPGRADE_TOC = protobuf.Descriptor();
M_MECHA_UPGRADE_TOC_MECHA_FIELD = protobuf.FieldDescriptor();
M_MECHA_SELECT_TOS = protobuf.Descriptor();
M_MECHA_SELECT_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_SELECT_TOC = protobuf.Descriptor();
M_MECHA_SELECT_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_TOS = protobuf.Descriptor();
M_MECHA_EQUIP_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_TOC = protobuf.Descriptor();
M_MECHA_EQUIP_TOC_SLOTSENTRY = protobuf.Descriptor();
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_TOC_EQUIPS_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_TOC_SLOTS_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_PUTON_TOS = protobuf.Descriptor();
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_PUTON_TOC = protobuf.Descriptor();
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_UPLEVEL_TOS = protobuf.Descriptor();
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_UPLEVEL_TOC = protobuf.Descriptor();
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_DECOMPOSE_TOS = protobuf.Descriptor();
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD = protobuf.FieldDescriptor();
M_MECHA_EQUIP_DECOMPOSE_TOC = protobuf.Descriptor();
P_MECHA = protobuf.Descriptor();
P_MECHA_ID_FIELD = protobuf.FieldDescriptor();
P_MECHA_STAR_FIELD = protobuf.FieldDescriptor();
P_MECHA_LEVEL_FIELD = protobuf.FieldDescriptor();
P_MECHA_EXP_FIELD = protobuf.FieldDescriptor();

M_MECHA_LIST_TOS.name = "m_mecha_list_tos"
M_MECHA_LIST_TOS.full_name = ".m_mecha_list_tos"
M_MECHA_LIST_TOS.nested_types = {}
M_MECHA_LIST_TOS.enum_types = {}
M_MECHA_LIST_TOS.fields = {}
M_MECHA_LIST_TOS.is_extendable = false
M_MECHA_LIST_TOS.extensions = {}
M_MECHA_LIST_TOC_MECHAS_FIELD.name = "mechas"
M_MECHA_LIST_TOC_MECHAS_FIELD.full_name = ".m_mecha_list_toc.mechas"
M_MECHA_LIST_TOC_MECHAS_FIELD.number = 1
M_MECHA_LIST_TOC_MECHAS_FIELD.index = 0
M_MECHA_LIST_TOC_MECHAS_FIELD.label = 3
M_MECHA_LIST_TOC_MECHAS_FIELD.has_default_value = false
M_MECHA_LIST_TOC_MECHAS_FIELD.default_value = {}
M_MECHA_LIST_TOC_MECHAS_FIELD.message_type = P_MECHA
M_MECHA_LIST_TOC_MECHAS_FIELD.type = 11
M_MECHA_LIST_TOC_MECHAS_FIELD.cpp_type = 10

M_MECHA_LIST_TOC_USE_ID_FIELD.name = "use_id"
M_MECHA_LIST_TOC_USE_ID_FIELD.full_name = ".m_mecha_list_toc.use_id"
M_MECHA_LIST_TOC_USE_ID_FIELD.number = 2
M_MECHA_LIST_TOC_USE_ID_FIELD.index = 1
M_MECHA_LIST_TOC_USE_ID_FIELD.label = 2
M_MECHA_LIST_TOC_USE_ID_FIELD.has_default_value = false
M_MECHA_LIST_TOC_USE_ID_FIELD.default_value = 0
M_MECHA_LIST_TOC_USE_ID_FIELD.type = 5
M_MECHA_LIST_TOC_USE_ID_FIELD.cpp_type = 1

M_MECHA_LIST_TOC.name = "m_mecha_list_toc"
M_MECHA_LIST_TOC.full_name = ".m_mecha_list_toc"
M_MECHA_LIST_TOC.nested_types = {}
M_MECHA_LIST_TOC.enum_types = {}
M_MECHA_LIST_TOC.fields = {M_MECHA_LIST_TOC_MECHAS_FIELD, M_MECHA_LIST_TOC_USE_ID_FIELD}
M_MECHA_LIST_TOC.is_extendable = false
M_MECHA_LIST_TOC.extensions = {}
M_MECHA_UPSTAR_TOS_ID_FIELD.name = "id"
M_MECHA_UPSTAR_TOS_ID_FIELD.full_name = ".m_mecha_upstar_tos.id"
M_MECHA_UPSTAR_TOS_ID_FIELD.number = 1
M_MECHA_UPSTAR_TOS_ID_FIELD.index = 0
M_MECHA_UPSTAR_TOS_ID_FIELD.label = 2
M_MECHA_UPSTAR_TOS_ID_FIELD.has_default_value = false
M_MECHA_UPSTAR_TOS_ID_FIELD.default_value = 0
M_MECHA_UPSTAR_TOS_ID_FIELD.type = 5
M_MECHA_UPSTAR_TOS_ID_FIELD.cpp_type = 1

M_MECHA_UPSTAR_TOS.name = "m_mecha_upstar_tos"
M_MECHA_UPSTAR_TOS.full_name = ".m_mecha_upstar_tos"
M_MECHA_UPSTAR_TOS.nested_types = {}
M_MECHA_UPSTAR_TOS.enum_types = {}
M_MECHA_UPSTAR_TOS.fields = {M_MECHA_UPSTAR_TOS_ID_FIELD}
M_MECHA_UPSTAR_TOS.is_extendable = false
M_MECHA_UPSTAR_TOS.extensions = {}
M_MECHA_UPSTAR_TOC_MECHA_FIELD.name = "mecha"
M_MECHA_UPSTAR_TOC_MECHA_FIELD.full_name = ".m_mecha_upstar_toc.mecha"
M_MECHA_UPSTAR_TOC_MECHA_FIELD.number = 1
M_MECHA_UPSTAR_TOC_MECHA_FIELD.index = 0
M_MECHA_UPSTAR_TOC_MECHA_FIELD.label = 2
M_MECHA_UPSTAR_TOC_MECHA_FIELD.has_default_value = false
M_MECHA_UPSTAR_TOC_MECHA_FIELD.default_value = nil
M_MECHA_UPSTAR_TOC_MECHA_FIELD.message_type = P_MECHA
M_MECHA_UPSTAR_TOC_MECHA_FIELD.type = 11
M_MECHA_UPSTAR_TOC_MECHA_FIELD.cpp_type = 10

M_MECHA_UPSTAR_TOC.name = "m_mecha_upstar_toc"
M_MECHA_UPSTAR_TOC.full_name = ".m_mecha_upstar_toc"
M_MECHA_UPSTAR_TOC.nested_types = {}
M_MECHA_UPSTAR_TOC.enum_types = {}
M_MECHA_UPSTAR_TOC.fields = {M_MECHA_UPSTAR_TOC_MECHA_FIELD}
M_MECHA_UPSTAR_TOC.is_extendable = false
M_MECHA_UPSTAR_TOC.extensions = {}
M_MECHA_UPGRADE_TOS_ID_FIELD.name = "id"
M_MECHA_UPGRADE_TOS_ID_FIELD.full_name = ".m_mecha_upgrade_tos.id"
M_MECHA_UPGRADE_TOS_ID_FIELD.number = 1
M_MECHA_UPGRADE_TOS_ID_FIELD.index = 0
M_MECHA_UPGRADE_TOS_ID_FIELD.label = 2
M_MECHA_UPGRADE_TOS_ID_FIELD.has_default_value = false
M_MECHA_UPGRADE_TOS_ID_FIELD.default_value = 0
M_MECHA_UPGRADE_TOS_ID_FIELD.type = 5
M_MECHA_UPGRADE_TOS_ID_FIELD.cpp_type = 1

M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.name = "item_id"
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.full_name = ".m_mecha_upgrade_tos.item_id"
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.number = 2
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.index = 1
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.label = 2
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.has_default_value = false
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.default_value = 0
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.type = 5
M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD.cpp_type = 1

M_MECHA_UPGRADE_TOS.name = "m_mecha_upgrade_tos"
M_MECHA_UPGRADE_TOS.full_name = ".m_mecha_upgrade_tos"
M_MECHA_UPGRADE_TOS.nested_types = {}
M_MECHA_UPGRADE_TOS.enum_types = {}
M_MECHA_UPGRADE_TOS.fields = {M_MECHA_UPGRADE_TOS_ID_FIELD, M_MECHA_UPGRADE_TOS_ITEM_ID_FIELD}
M_MECHA_UPGRADE_TOS.is_extendable = false
M_MECHA_UPGRADE_TOS.extensions = {}
M_MECHA_UPGRADE_TOC_MECHA_FIELD.name = "mecha"
M_MECHA_UPGRADE_TOC_MECHA_FIELD.full_name = ".m_mecha_upgrade_toc.mecha"
M_MECHA_UPGRADE_TOC_MECHA_FIELD.number = 1
M_MECHA_UPGRADE_TOC_MECHA_FIELD.index = 0
M_MECHA_UPGRADE_TOC_MECHA_FIELD.label = 2
M_MECHA_UPGRADE_TOC_MECHA_FIELD.has_default_value = false
M_MECHA_UPGRADE_TOC_MECHA_FIELD.default_value = nil
M_MECHA_UPGRADE_TOC_MECHA_FIELD.message_type = P_MECHA
M_MECHA_UPGRADE_TOC_MECHA_FIELD.type = 11
M_MECHA_UPGRADE_TOC_MECHA_FIELD.cpp_type = 10

M_MECHA_UPGRADE_TOC.name = "m_mecha_upgrade_toc"
M_MECHA_UPGRADE_TOC.full_name = ".m_mecha_upgrade_toc"
M_MECHA_UPGRADE_TOC.nested_types = {}
M_MECHA_UPGRADE_TOC.enum_types = {}
M_MECHA_UPGRADE_TOC.fields = {M_MECHA_UPGRADE_TOC_MECHA_FIELD}
M_MECHA_UPGRADE_TOC.is_extendable = false
M_MECHA_UPGRADE_TOC.extensions = {}
M_MECHA_SELECT_TOS_ID_FIELD.name = "id"
M_MECHA_SELECT_TOS_ID_FIELD.full_name = ".m_mecha_select_tos.id"
M_MECHA_SELECT_TOS_ID_FIELD.number = 1
M_MECHA_SELECT_TOS_ID_FIELD.index = 0
M_MECHA_SELECT_TOS_ID_FIELD.label = 2
M_MECHA_SELECT_TOS_ID_FIELD.has_default_value = false
M_MECHA_SELECT_TOS_ID_FIELD.default_value = 0
M_MECHA_SELECT_TOS_ID_FIELD.type = 5
M_MECHA_SELECT_TOS_ID_FIELD.cpp_type = 1

M_MECHA_SELECT_TOS.name = "m_mecha_select_tos"
M_MECHA_SELECT_TOS.full_name = ".m_mecha_select_tos"
M_MECHA_SELECT_TOS.nested_types = {}
M_MECHA_SELECT_TOS.enum_types = {}
M_MECHA_SELECT_TOS.fields = {M_MECHA_SELECT_TOS_ID_FIELD}
M_MECHA_SELECT_TOS.is_extendable = false
M_MECHA_SELECT_TOS.extensions = {}
M_MECHA_SELECT_TOC_ID_FIELD.name = "id"
M_MECHA_SELECT_TOC_ID_FIELD.full_name = ".m_mecha_select_toc.id"
M_MECHA_SELECT_TOC_ID_FIELD.number = 1
M_MECHA_SELECT_TOC_ID_FIELD.index = 0
M_MECHA_SELECT_TOC_ID_FIELD.label = 2
M_MECHA_SELECT_TOC_ID_FIELD.has_default_value = false
M_MECHA_SELECT_TOC_ID_FIELD.default_value = 0
M_MECHA_SELECT_TOC_ID_FIELD.type = 5
M_MECHA_SELECT_TOC_ID_FIELD.cpp_type = 1

M_MECHA_SELECT_TOC.name = "m_mecha_select_toc"
M_MECHA_SELECT_TOC.full_name = ".m_mecha_select_toc"
M_MECHA_SELECT_TOC.nested_types = {}
M_MECHA_SELECT_TOC.enum_types = {}
M_MECHA_SELECT_TOC.fields = {M_MECHA_SELECT_TOC_ID_FIELD}
M_MECHA_SELECT_TOC.is_extendable = false
M_MECHA_SELECT_TOC.extensions = {}
M_MECHA_EQUIP_TOS_ID_FIELD.name = "id"
M_MECHA_EQUIP_TOS_ID_FIELD.full_name = ".m_mecha_equip_tos.id"
M_MECHA_EQUIP_TOS_ID_FIELD.number = 1
M_MECHA_EQUIP_TOS_ID_FIELD.index = 0
M_MECHA_EQUIP_TOS_ID_FIELD.label = 2
M_MECHA_EQUIP_TOS_ID_FIELD.has_default_value = false
M_MECHA_EQUIP_TOS_ID_FIELD.default_value = 0
M_MECHA_EQUIP_TOS_ID_FIELD.type = 5
M_MECHA_EQUIP_TOS_ID_FIELD.cpp_type = 1

M_MECHA_EQUIP_TOS.name = "m_mecha_equip_tos"
M_MECHA_EQUIP_TOS.full_name = ".m_mecha_equip_tos"
M_MECHA_EQUIP_TOS.nested_types = {}
M_MECHA_EQUIP_TOS.enum_types = {}
M_MECHA_EQUIP_TOS.fields = {M_MECHA_EQUIP_TOS_ID_FIELD}
M_MECHA_EQUIP_TOS.is_extendable = false
M_MECHA_EQUIP_TOS.extensions = {}
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.name = "key"
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.full_name = ".m_mecha_equip_toc.SlotsEntry.key"
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.number = 1
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.index = 0
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.label = 1
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.has_default_value = false
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.default_value = 0
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.type = 5
M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD.cpp_type = 1

M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.name = "value"
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.full_name = ".m_mecha_equip_toc.SlotsEntry.value"
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.number = 2
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.index = 1
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.label = 1
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.has_default_value = false
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.default_value = 0
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.type = 5
M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD.cpp_type = 1

M_MECHA_EQUIP_TOC_SLOTSENTRY.name = "SlotsEntry"
M_MECHA_EQUIP_TOC_SLOTSENTRY.full_name = ".m_mecha_equip_toc.SlotsEntry"
M_MECHA_EQUIP_TOC_SLOTSENTRY.nested_types = {}
M_MECHA_EQUIP_TOC_SLOTSENTRY.enum_types = {}
M_MECHA_EQUIP_TOC_SLOTSENTRY.fields = {M_MECHA_EQUIP_TOC_SLOTSENTRY_KEY_FIELD, M_MECHA_EQUIP_TOC_SLOTSENTRY_VALUE_FIELD}
M_MECHA_EQUIP_TOC_SLOTSENTRY.is_extendable = false
M_MECHA_EQUIP_TOC_SLOTSENTRY.extensions = {}
M_MECHA_EQUIP_TOC_SLOTSENTRY.containing_type = M_MECHA_EQUIP_TOC
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.name = "equips"
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.full_name = ".m_mecha_equip_toc.equips"
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.number = 1
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.index = 0
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.label = 3
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.has_default_value = false
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.default_value = {}
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.message_type = pb_comm_pb.P_ITEM
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.type = 11
M_MECHA_EQUIP_TOC_EQUIPS_FIELD.cpp_type = 10

M_MECHA_EQUIP_TOC_SLOTS_FIELD.name = "slots"
M_MECHA_EQUIP_TOC_SLOTS_FIELD.full_name = ".m_mecha_equip_toc.slots"
M_MECHA_EQUIP_TOC_SLOTS_FIELD.number = 2
M_MECHA_EQUIP_TOC_SLOTS_FIELD.index = 1
M_MECHA_EQUIP_TOC_SLOTS_FIELD.label = 3
M_MECHA_EQUIP_TOC_SLOTS_FIELD.has_default_value = false
M_MECHA_EQUIP_TOC_SLOTS_FIELD.default_value = {}
M_MECHA_EQUIP_TOC_SLOTS_FIELD.message_type = M_MECHA_EQUIP_TOC_SLOTSENTRY
M_MECHA_EQUIP_TOC_SLOTS_FIELD.type = 11
M_MECHA_EQUIP_TOC_SLOTS_FIELD.cpp_type = 10

M_MECHA_EQUIP_TOC_ID_FIELD.name = "id"
M_MECHA_EQUIP_TOC_ID_FIELD.full_name = ".m_mecha_equip_toc.id"
M_MECHA_EQUIP_TOC_ID_FIELD.number = 3
M_MECHA_EQUIP_TOC_ID_FIELD.index = 2
M_MECHA_EQUIP_TOC_ID_FIELD.label = 2
M_MECHA_EQUIP_TOC_ID_FIELD.has_default_value = false
M_MECHA_EQUIP_TOC_ID_FIELD.default_value = 0
M_MECHA_EQUIP_TOC_ID_FIELD.type = 5
M_MECHA_EQUIP_TOC_ID_FIELD.cpp_type = 1

M_MECHA_EQUIP_TOC.name = "m_mecha_equip_toc"
M_MECHA_EQUIP_TOC.full_name = ".m_mecha_equip_toc"
M_MECHA_EQUIP_TOC.nested_types = {M_MECHA_EQUIP_TOC_SLOTSENTRY}
M_MECHA_EQUIP_TOC.enum_types = {}
M_MECHA_EQUIP_TOC.fields = {M_MECHA_EQUIP_TOC_EQUIPS_FIELD, M_MECHA_EQUIP_TOC_SLOTS_FIELD, M_MECHA_EQUIP_TOC_ID_FIELD}
M_MECHA_EQUIP_TOC.is_extendable = false
M_MECHA_EQUIP_TOC.extensions = {}
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.name = "id"
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.full_name = ".m_mecha_equip_puton_tos.id"
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.number = 1
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.index = 0
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.label = 2
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.has_default_value = false
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.default_value = 0
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.type = 5
M_MECHA_EQUIP_PUTON_TOS_ID_FIELD.cpp_type = 1

M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.name = "uid"
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.full_name = ".m_mecha_equip_puton_tos.uid"
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.number = 2
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.index = 1
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.label = 2
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.has_default_value = false
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.default_value = 0
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.type = 5
M_MECHA_EQUIP_PUTON_TOS_UID_FIELD.cpp_type = 1

M_MECHA_EQUIP_PUTON_TOS.name = "m_mecha_equip_puton_tos"
M_MECHA_EQUIP_PUTON_TOS.full_name = ".m_mecha_equip_puton_tos"
M_MECHA_EQUIP_PUTON_TOS.nested_types = {}
M_MECHA_EQUIP_PUTON_TOS.enum_types = {}
M_MECHA_EQUIP_PUTON_TOS.fields = {M_MECHA_EQUIP_PUTON_TOS_ID_FIELD, M_MECHA_EQUIP_PUTON_TOS_UID_FIELD}
M_MECHA_EQUIP_PUTON_TOS.is_extendable = false
M_MECHA_EQUIP_PUTON_TOS.extensions = {}
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.name = "slot"
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.full_name = ".m_mecha_equip_puton_toc.slot"
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.number = 1
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.index = 0
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.label = 2
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.has_default_value = false
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.default_value = 0
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.type = 5
M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD.cpp_type = 1

M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.name = "id"
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.full_name = ".m_mecha_equip_puton_toc.id"
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.number = 2
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.index = 1
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.label = 2
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.has_default_value = false
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.default_value = 0
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.type = 5
M_MECHA_EQUIP_PUTON_TOC_ID_FIELD.cpp_type = 1

M_MECHA_EQUIP_PUTON_TOC.name = "m_mecha_equip_puton_toc"
M_MECHA_EQUIP_PUTON_TOC.full_name = ".m_mecha_equip_puton_toc"
M_MECHA_EQUIP_PUTON_TOC.nested_types = {}
M_MECHA_EQUIP_PUTON_TOC.enum_types = {}
M_MECHA_EQUIP_PUTON_TOC.fields = {M_MECHA_EQUIP_PUTON_TOC_SLOT_FIELD, M_MECHA_EQUIP_PUTON_TOC_ID_FIELD}
M_MECHA_EQUIP_PUTON_TOC.is_extendable = false
M_MECHA_EQUIP_PUTON_TOC.extensions = {}
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.name = "slot"
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.full_name = ".m_mecha_equip_uplevel_tos.slot"
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.number = 1
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.index = 0
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.label = 2
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.has_default_value = false
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.default_value = 0
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.type = 5
M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD.cpp_type = 1

M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.name = "id"
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.full_name = ".m_mecha_equip_uplevel_tos.id"
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.number = 2
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.index = 1
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.label = 2
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.has_default_value = false
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.default_value = 0
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.type = 5
M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD.cpp_type = 1

M_MECHA_EQUIP_UPLEVEL_TOS.name = "m_mecha_equip_uplevel_tos"
M_MECHA_EQUIP_UPLEVEL_TOS.full_name = ".m_mecha_equip_uplevel_tos"
M_MECHA_EQUIP_UPLEVEL_TOS.nested_types = {}
M_MECHA_EQUIP_UPLEVEL_TOS.enum_types = {}
M_MECHA_EQUIP_UPLEVEL_TOS.fields = {M_MECHA_EQUIP_UPLEVEL_TOS_SLOT_FIELD, M_MECHA_EQUIP_UPLEVEL_TOS_ID_FIELD}
M_MECHA_EQUIP_UPLEVEL_TOS.is_extendable = false
M_MECHA_EQUIP_UPLEVEL_TOS.extensions = {}
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.name = "slot"
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.full_name = ".m_mecha_equip_uplevel_toc.slot"
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.number = 1
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.index = 0
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.label = 2
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.has_default_value = false
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.default_value = 0
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.type = 5
M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD.cpp_type = 1

M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.name = "id"
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.full_name = ".m_mecha_equip_uplevel_toc.id"
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.number = 2
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.index = 1
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.label = 2
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.has_default_value = false
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.default_value = 0
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.type = 5
M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD.cpp_type = 1

M_MECHA_EQUIP_UPLEVEL_TOC.name = "m_mecha_equip_uplevel_toc"
M_MECHA_EQUIP_UPLEVEL_TOC.full_name = ".m_mecha_equip_uplevel_toc"
M_MECHA_EQUIP_UPLEVEL_TOC.nested_types = {}
M_MECHA_EQUIP_UPLEVEL_TOC.enum_types = {}
M_MECHA_EQUIP_UPLEVEL_TOC.fields = {M_MECHA_EQUIP_UPLEVEL_TOC_SLOT_FIELD, M_MECHA_EQUIP_UPLEVEL_TOC_ID_FIELD}
M_MECHA_EQUIP_UPLEVEL_TOC.is_extendable = false
M_MECHA_EQUIP_UPLEVEL_TOC.extensions = {}
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.name = "uid"
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.full_name = ".m_mecha_equip_decompose_tos.uid"
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.number = 1
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.index = 0
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.label = 3
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.has_default_value = false
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.default_value = {}
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.type = 5
M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD.cpp_type = 1

M_MECHA_EQUIP_DECOMPOSE_TOS.name = "m_mecha_equip_decompose_tos"
M_MECHA_EQUIP_DECOMPOSE_TOS.full_name = ".m_mecha_equip_decompose_tos"
M_MECHA_EQUIP_DECOMPOSE_TOS.nested_types = {}
M_MECHA_EQUIP_DECOMPOSE_TOS.enum_types = {}
M_MECHA_EQUIP_DECOMPOSE_TOS.fields = {M_MECHA_EQUIP_DECOMPOSE_TOS_UID_FIELD}
M_MECHA_EQUIP_DECOMPOSE_TOS.is_extendable = false
M_MECHA_EQUIP_DECOMPOSE_TOS.extensions = {}
M_MECHA_EQUIP_DECOMPOSE_TOC.name = "m_mecha_equip_decompose_toc"
M_MECHA_EQUIP_DECOMPOSE_TOC.full_name = ".m_mecha_equip_decompose_toc"
M_MECHA_EQUIP_DECOMPOSE_TOC.nested_types = {}
M_MECHA_EQUIP_DECOMPOSE_TOC.enum_types = {}
M_MECHA_EQUIP_DECOMPOSE_TOC.fields = {}
M_MECHA_EQUIP_DECOMPOSE_TOC.is_extendable = false
M_MECHA_EQUIP_DECOMPOSE_TOC.extensions = {}
P_MECHA_ID_FIELD.name = "id"
P_MECHA_ID_FIELD.full_name = ".p_mecha.id"
P_MECHA_ID_FIELD.number = 1
P_MECHA_ID_FIELD.index = 0
P_MECHA_ID_FIELD.label = 2
P_MECHA_ID_FIELD.has_default_value = false
P_MECHA_ID_FIELD.default_value = 0
P_MECHA_ID_FIELD.type = 5
P_MECHA_ID_FIELD.cpp_type = 1

P_MECHA_STAR_FIELD.name = "star"
P_MECHA_STAR_FIELD.full_name = ".p_mecha.star"
P_MECHA_STAR_FIELD.number = 2
P_MECHA_STAR_FIELD.index = 1
P_MECHA_STAR_FIELD.label = 2
P_MECHA_STAR_FIELD.has_default_value = false
P_MECHA_STAR_FIELD.default_value = 0
P_MECHA_STAR_FIELD.type = 5
P_MECHA_STAR_FIELD.cpp_type = 1

P_MECHA_LEVEL_FIELD.name = "level"
P_MECHA_LEVEL_FIELD.full_name = ".p_mecha.level"
P_MECHA_LEVEL_FIELD.number = 3
P_MECHA_LEVEL_FIELD.index = 2
P_MECHA_LEVEL_FIELD.label = 2
P_MECHA_LEVEL_FIELD.has_default_value = false
P_MECHA_LEVEL_FIELD.default_value = 0
P_MECHA_LEVEL_FIELD.type = 5
P_MECHA_LEVEL_FIELD.cpp_type = 1

P_MECHA_EXP_FIELD.name = "exp"
P_MECHA_EXP_FIELD.full_name = ".p_mecha.exp"
P_MECHA_EXP_FIELD.number = 4
P_MECHA_EXP_FIELD.index = 3
P_MECHA_EXP_FIELD.label = 2
P_MECHA_EXP_FIELD.has_default_value = false
P_MECHA_EXP_FIELD.default_value = 0
P_MECHA_EXP_FIELD.type = 5
P_MECHA_EXP_FIELD.cpp_type = 1

P_MECHA.name = "p_mecha"
P_MECHA.full_name = ".p_mecha"
P_MECHA.nested_types = {}
P_MECHA.enum_types = {}
P_MECHA.fields = {P_MECHA_ID_FIELD, P_MECHA_STAR_FIELD, P_MECHA_LEVEL_FIELD, P_MECHA_EXP_FIELD}
P_MECHA.is_extendable = false
P_MECHA.extensions = {}

m_mecha_equip_decompose_toc = protobuf.Message(M_MECHA_EQUIP_DECOMPOSE_TOC)
m_mecha_equip_decompose_tos = protobuf.Message(M_MECHA_EQUIP_DECOMPOSE_TOS)
m_mecha_equip_puton_toc = protobuf.Message(M_MECHA_EQUIP_PUTON_TOC)
m_mecha_equip_puton_tos = protobuf.Message(M_MECHA_EQUIP_PUTON_TOS)
m_mecha_equip_toc = protobuf.Message(M_MECHA_EQUIP_TOC)
m_mecha_equip_toc.SlotsEntry = protobuf.Message(M_MECHA_EQUIP_TOC_SLOTSENTRY)
m_mecha_equip_tos = protobuf.Message(M_MECHA_EQUIP_TOS)
m_mecha_equip_uplevel_toc = protobuf.Message(M_MECHA_EQUIP_UPLEVEL_TOC)
m_mecha_equip_uplevel_tos = protobuf.Message(M_MECHA_EQUIP_UPLEVEL_TOS)
m_mecha_list_toc = protobuf.Message(M_MECHA_LIST_TOC)
m_mecha_list_tos = protobuf.Message(M_MECHA_LIST_TOS)
m_mecha_select_toc = protobuf.Message(M_MECHA_SELECT_TOC)
m_mecha_select_tos = protobuf.Message(M_MECHA_SELECT_TOS)
m_mecha_upgrade_toc = protobuf.Message(M_MECHA_UPGRADE_TOC)
m_mecha_upgrade_tos = protobuf.Message(M_MECHA_UPGRADE_TOS)
m_mecha_upstar_toc = protobuf.Message(M_MECHA_UPSTAR_TOC)
m_mecha_upstar_tos = protobuf.Message(M_MECHA_UPSTAR_TOS)
p_mecha = protobuf.Message(P_MECHA)

