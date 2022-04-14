-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
module('pb_1110_vip_pb')


M_VIP_INFO_TOS = protobuf.Descriptor();
M_VIP_INFO_TOC = protobuf.Descriptor();
M_VIP_INFO_TOC_DAILY_EXP_FIELD = protobuf.FieldDescriptor();
M_VIP_INFO_TOC_LV_REWARD_FIELD = protobuf.FieldDescriptor();
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD = protobuf.FieldDescriptor();
M_VIP_INFO_TOC_AUTO_FETCH_FIELD = protobuf.FieldDescriptor();
M_VIP_FETCH_TOS = protobuf.Descriptor();
M_VIP_FETCH_TOS_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_FETCH_TOS_LEVEL_FIELD = protobuf.FieldDescriptor();
M_VIP_FETCH_TOC = protobuf.Descriptor();
M_VIP_FETCH_TOC_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_FETCH_TOC_LEVEL_FIELD = protobuf.FieldDescriptor();
M_VIP_ACTIVE_TOS = protobuf.Descriptor();
M_VIP_ACTIVE_TOS_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_ACTIVE_TOC = protobuf.Descriptor();
M_VIP_ACTIVE_TOC_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_AUTO_FETCH_TOS = protobuf.Descriptor();
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD = protobuf.FieldDescriptor();
M_VIP_AUTO_FETCH_TOC = protobuf.Descriptor();
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD = protobuf.FieldDescriptor();
M_VIP_EXP_POOL_TOS = protobuf.Descriptor();
M_VIP_EXP_POOL_TOC = protobuf.Descriptor();
M_VIP_EXP_POOL_TOC_EXP_FIELD = protobuf.FieldDescriptor();
M_VIP_MCARD_TOS = protobuf.Descriptor();
M_VIP_MCARD_TOC = protobuf.Descriptor();
M_VIP_MCARD_TOC_FETCHENTRY = protobuf.Descriptor();
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD = protobuf.FieldDescriptor();
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD = protobuf.FieldDescriptor();
M_VIP_MCARD_TOC_BUY_FIELD = protobuf.FieldDescriptor();
M_VIP_MCARD_TOC_FETCH_FIELD = protobuf.FieldDescriptor();
M_VIP_MCARD_BUY_TOS = protobuf.Descriptor();
M_VIP_MCARD_FETCH_TOS = protobuf.Descriptor();
M_VIP_MCARD_FETCH_TOS_DAY_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_TOS = protobuf.Descriptor();
M_VIP_INVEST_TOC = protobuf.Descriptor();
M_VIP_INVEST_TOC_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_TOC_GRADE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_TOC_LIST_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_BUY_TOS = protobuf.Descriptor();
M_VIP_INVEST_BUY_TOS_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_BUY_TOS_GRADE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_BUY_TOC = protobuf.Descriptor();
M_VIP_INVEST_FETCH_TOS = protobuf.Descriptor();
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_FETCH_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_FETCH_TOC = protobuf.Descriptor();
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST_NEXT_TOC = protobuf.Descriptor();
M_VIP_REBATE_INFO_TOS = protobuf.Descriptor();
M_VIP_REBATE_INFO_TOC = protobuf.Descriptor();
M_VIP_REBATE_INFO_TOC_TIME_FIELD = protobuf.FieldDescriptor();
M_VIP_REBATE_INFO_TOC_FETCH_FIELD = protobuf.FieldDescriptor();
M_VIP_REBATE_FETCH_TOS = protobuf.Descriptor();
M_VIP_REBATE_FETCH_TOC = protobuf.Descriptor();
M_VIP_TASTE_INFO_TOS = protobuf.Descriptor();
M_VIP_TASTE_INFO_TOC = protobuf.Descriptor();
M_VIP_TASTE_INFO_TOC_STIME_FIELD = protobuf.FieldDescriptor();
M_VIP_TASTE_INFO_TOC_ETIME_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST2_TOS = protobuf.Descriptor();
M_VIP_INVEST2_TOS_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST2_TOC = protobuf.Descriptor();
M_VIP_INVEST2_TOC_TYPE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST2_TOC_GRADE_FIELD = protobuf.FieldDescriptor();
M_VIP_INVEST2_TOC_LIST_FIELD = protobuf.FieldDescriptor();
P_INVEST = protobuf.Descriptor();
P_INVEST_ID_FIELD = protobuf.FieldDescriptor();
P_INVEST_STATE_FIELD = protobuf.FieldDescriptor();
P_INVEST_BGOLD_FIELD = protobuf.FieldDescriptor();

M_VIP_INFO_TOS.name = "m_vip_info_tos"
M_VIP_INFO_TOS.full_name = ".m_vip_info_tos"
M_VIP_INFO_TOS.nested_types = {}
M_VIP_INFO_TOS.enum_types = {}
M_VIP_INFO_TOS.fields = {}
M_VIP_INFO_TOS.is_extendable = false
M_VIP_INFO_TOS.extensions = {}
M_VIP_INFO_TOC_DAILY_EXP_FIELD.name = "daily_exp"
M_VIP_INFO_TOC_DAILY_EXP_FIELD.full_name = ".m_vip_info_toc.daily_exp"
M_VIP_INFO_TOC_DAILY_EXP_FIELD.number = 1
M_VIP_INFO_TOC_DAILY_EXP_FIELD.index = 0
M_VIP_INFO_TOC_DAILY_EXP_FIELD.label = 2
M_VIP_INFO_TOC_DAILY_EXP_FIELD.has_default_value = false
M_VIP_INFO_TOC_DAILY_EXP_FIELD.default_value = false
M_VIP_INFO_TOC_DAILY_EXP_FIELD.type = 8
M_VIP_INFO_TOC_DAILY_EXP_FIELD.cpp_type = 7

M_VIP_INFO_TOC_LV_REWARD_FIELD.name = "lv_reward"
M_VIP_INFO_TOC_LV_REWARD_FIELD.full_name = ".m_vip_info_toc.lv_reward"
M_VIP_INFO_TOC_LV_REWARD_FIELD.number = 2
M_VIP_INFO_TOC_LV_REWARD_FIELD.index = 1
M_VIP_INFO_TOC_LV_REWARD_FIELD.label = 3
M_VIP_INFO_TOC_LV_REWARD_FIELD.has_default_value = false
M_VIP_INFO_TOC_LV_REWARD_FIELD.default_value = {}
M_VIP_INFO_TOC_LV_REWARD_FIELD.type = 5
M_VIP_INFO_TOC_LV_REWARD_FIELD.cpp_type = 1

M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.name = "weekly_gift"
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.full_name = ".m_vip_info_toc.weekly_gift"
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.number = 3
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.index = 2
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.label = 2
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.has_default_value = false
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.default_value = false
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.type = 8
M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD.cpp_type = 7

M_VIP_INFO_TOC_AUTO_FETCH_FIELD.name = "auto_fetch"
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.full_name = ".m_vip_info_toc.auto_fetch"
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.number = 4
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.index = 3
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.label = 2
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.has_default_value = false
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.default_value = false
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.type = 8
M_VIP_INFO_TOC_AUTO_FETCH_FIELD.cpp_type = 7

M_VIP_INFO_TOC.name = "m_vip_info_toc"
M_VIP_INFO_TOC.full_name = ".m_vip_info_toc"
M_VIP_INFO_TOC.nested_types = {}
M_VIP_INFO_TOC.enum_types = {}
M_VIP_INFO_TOC.fields = {M_VIP_INFO_TOC_DAILY_EXP_FIELD, M_VIP_INFO_TOC_LV_REWARD_FIELD, M_VIP_INFO_TOC_WEEKLY_GIFT_FIELD, M_VIP_INFO_TOC_AUTO_FETCH_FIELD}
M_VIP_INFO_TOC.is_extendable = false
M_VIP_INFO_TOC.extensions = {}
M_VIP_FETCH_TOS_TYPE_FIELD.name = "type"
M_VIP_FETCH_TOS_TYPE_FIELD.full_name = ".m_vip_fetch_tos.type"
M_VIP_FETCH_TOS_TYPE_FIELD.number = 1
M_VIP_FETCH_TOS_TYPE_FIELD.index = 0
M_VIP_FETCH_TOS_TYPE_FIELD.label = 2
M_VIP_FETCH_TOS_TYPE_FIELD.has_default_value = false
M_VIP_FETCH_TOS_TYPE_FIELD.default_value = 0
M_VIP_FETCH_TOS_TYPE_FIELD.type = 5
M_VIP_FETCH_TOS_TYPE_FIELD.cpp_type = 1

M_VIP_FETCH_TOS_LEVEL_FIELD.name = "level"
M_VIP_FETCH_TOS_LEVEL_FIELD.full_name = ".m_vip_fetch_tos.level"
M_VIP_FETCH_TOS_LEVEL_FIELD.number = 2
M_VIP_FETCH_TOS_LEVEL_FIELD.index = 1
M_VIP_FETCH_TOS_LEVEL_FIELD.label = 1
M_VIP_FETCH_TOS_LEVEL_FIELD.has_default_value = false
M_VIP_FETCH_TOS_LEVEL_FIELD.default_value = 0
M_VIP_FETCH_TOS_LEVEL_FIELD.type = 5
M_VIP_FETCH_TOS_LEVEL_FIELD.cpp_type = 1

M_VIP_FETCH_TOS.name = "m_vip_fetch_tos"
M_VIP_FETCH_TOS.full_name = ".m_vip_fetch_tos"
M_VIP_FETCH_TOS.nested_types = {}
M_VIP_FETCH_TOS.enum_types = {}
M_VIP_FETCH_TOS.fields = {M_VIP_FETCH_TOS_TYPE_FIELD, M_VIP_FETCH_TOS_LEVEL_FIELD}
M_VIP_FETCH_TOS.is_extendable = false
M_VIP_FETCH_TOS.extensions = {}
M_VIP_FETCH_TOC_TYPE_FIELD.name = "type"
M_VIP_FETCH_TOC_TYPE_FIELD.full_name = ".m_vip_fetch_toc.type"
M_VIP_FETCH_TOC_TYPE_FIELD.number = 1
M_VIP_FETCH_TOC_TYPE_FIELD.index = 0
M_VIP_FETCH_TOC_TYPE_FIELD.label = 2
M_VIP_FETCH_TOC_TYPE_FIELD.has_default_value = false
M_VIP_FETCH_TOC_TYPE_FIELD.default_value = 0
M_VIP_FETCH_TOC_TYPE_FIELD.type = 5
M_VIP_FETCH_TOC_TYPE_FIELD.cpp_type = 1

M_VIP_FETCH_TOC_LEVEL_FIELD.name = "level"
M_VIP_FETCH_TOC_LEVEL_FIELD.full_name = ".m_vip_fetch_toc.level"
M_VIP_FETCH_TOC_LEVEL_FIELD.number = 2
M_VIP_FETCH_TOC_LEVEL_FIELD.index = 1
M_VIP_FETCH_TOC_LEVEL_FIELD.label = 1
M_VIP_FETCH_TOC_LEVEL_FIELD.has_default_value = false
M_VIP_FETCH_TOC_LEVEL_FIELD.default_value = 0
M_VIP_FETCH_TOC_LEVEL_FIELD.type = 5
M_VIP_FETCH_TOC_LEVEL_FIELD.cpp_type = 1

M_VIP_FETCH_TOC.name = "m_vip_fetch_toc"
M_VIP_FETCH_TOC.full_name = ".m_vip_fetch_toc"
M_VIP_FETCH_TOC.nested_types = {}
M_VIP_FETCH_TOC.enum_types = {}
M_VIP_FETCH_TOC.fields = {M_VIP_FETCH_TOC_TYPE_FIELD, M_VIP_FETCH_TOC_LEVEL_FIELD}
M_VIP_FETCH_TOC.is_extendable = false
M_VIP_FETCH_TOC.extensions = {}
M_VIP_ACTIVE_TOS_TYPE_FIELD.name = "type"
M_VIP_ACTIVE_TOS_TYPE_FIELD.full_name = ".m_vip_active_tos.type"
M_VIP_ACTIVE_TOS_TYPE_FIELD.number = 1
M_VIP_ACTIVE_TOS_TYPE_FIELD.index = 0
M_VIP_ACTIVE_TOS_TYPE_FIELD.label = 2
M_VIP_ACTIVE_TOS_TYPE_FIELD.has_default_value = false
M_VIP_ACTIVE_TOS_TYPE_FIELD.default_value = 0
M_VIP_ACTIVE_TOS_TYPE_FIELD.type = 5
M_VIP_ACTIVE_TOS_TYPE_FIELD.cpp_type = 1

M_VIP_ACTIVE_TOS.name = "m_vip_active_tos"
M_VIP_ACTIVE_TOS.full_name = ".m_vip_active_tos"
M_VIP_ACTIVE_TOS.nested_types = {}
M_VIP_ACTIVE_TOS.enum_types = {}
M_VIP_ACTIVE_TOS.fields = {M_VIP_ACTIVE_TOS_TYPE_FIELD}
M_VIP_ACTIVE_TOS.is_extendable = false
M_VIP_ACTIVE_TOS.extensions = {}
M_VIP_ACTIVE_TOC_TYPE_FIELD.name = "type"
M_VIP_ACTIVE_TOC_TYPE_FIELD.full_name = ".m_vip_active_toc.type"
M_VIP_ACTIVE_TOC_TYPE_FIELD.number = 1
M_VIP_ACTIVE_TOC_TYPE_FIELD.index = 0
M_VIP_ACTIVE_TOC_TYPE_FIELD.label = 2
M_VIP_ACTIVE_TOC_TYPE_FIELD.has_default_value = false
M_VIP_ACTIVE_TOC_TYPE_FIELD.default_value = 0
M_VIP_ACTIVE_TOC_TYPE_FIELD.type = 5
M_VIP_ACTIVE_TOC_TYPE_FIELD.cpp_type = 1

M_VIP_ACTIVE_TOC.name = "m_vip_active_toc"
M_VIP_ACTIVE_TOC.full_name = ".m_vip_active_toc"
M_VIP_ACTIVE_TOC.nested_types = {}
M_VIP_ACTIVE_TOC.enum_types = {}
M_VIP_ACTIVE_TOC.fields = {M_VIP_ACTIVE_TOC_TYPE_FIELD}
M_VIP_ACTIVE_TOC.is_extendable = false
M_VIP_ACTIVE_TOC.extensions = {}
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.name = "is_auto"
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.full_name = ".m_vip_auto_fetch_tos.is_auto"
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.number = 1
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.index = 0
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.label = 2
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.has_default_value = false
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.default_value = false
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.type = 8
M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD.cpp_type = 7

M_VIP_AUTO_FETCH_TOS.name = "m_vip_auto_fetch_tos"
M_VIP_AUTO_FETCH_TOS.full_name = ".m_vip_auto_fetch_tos"
M_VIP_AUTO_FETCH_TOS.nested_types = {}
M_VIP_AUTO_FETCH_TOS.enum_types = {}
M_VIP_AUTO_FETCH_TOS.fields = {M_VIP_AUTO_FETCH_TOS_IS_AUTO_FIELD}
M_VIP_AUTO_FETCH_TOS.is_extendable = false
M_VIP_AUTO_FETCH_TOS.extensions = {}
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.name = "is_auto"
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.full_name = ".m_vip_auto_fetch_toc.is_auto"
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.number = 1
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.index = 0
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.label = 2
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.has_default_value = false
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.default_value = false
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.type = 8
M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD.cpp_type = 7

M_VIP_AUTO_FETCH_TOC.name = "m_vip_auto_fetch_toc"
M_VIP_AUTO_FETCH_TOC.full_name = ".m_vip_auto_fetch_toc"
M_VIP_AUTO_FETCH_TOC.nested_types = {}
M_VIP_AUTO_FETCH_TOC.enum_types = {}
M_VIP_AUTO_FETCH_TOC.fields = {M_VIP_AUTO_FETCH_TOC_IS_AUTO_FIELD}
M_VIP_AUTO_FETCH_TOC.is_extendable = false
M_VIP_AUTO_FETCH_TOC.extensions = {}
M_VIP_EXP_POOL_TOS.name = "m_vip_exp_pool_tos"
M_VIP_EXP_POOL_TOS.full_name = ".m_vip_exp_pool_tos"
M_VIP_EXP_POOL_TOS.nested_types = {}
M_VIP_EXP_POOL_TOS.enum_types = {}
M_VIP_EXP_POOL_TOS.fields = {}
M_VIP_EXP_POOL_TOS.is_extendable = false
M_VIP_EXP_POOL_TOS.extensions = {}
M_VIP_EXP_POOL_TOC_EXP_FIELD.name = "exp"
M_VIP_EXP_POOL_TOC_EXP_FIELD.full_name = ".m_vip_exp_pool_toc.exp"
M_VIP_EXP_POOL_TOC_EXP_FIELD.number = 1
M_VIP_EXP_POOL_TOC_EXP_FIELD.index = 0
M_VIP_EXP_POOL_TOC_EXP_FIELD.label = 2
M_VIP_EXP_POOL_TOC_EXP_FIELD.has_default_value = false
M_VIP_EXP_POOL_TOC_EXP_FIELD.default_value = 0
M_VIP_EXP_POOL_TOC_EXP_FIELD.type = 5
M_VIP_EXP_POOL_TOC_EXP_FIELD.cpp_type = 1

M_VIP_EXP_POOL_TOC.name = "m_vip_exp_pool_toc"
M_VIP_EXP_POOL_TOC.full_name = ".m_vip_exp_pool_toc"
M_VIP_EXP_POOL_TOC.nested_types = {}
M_VIP_EXP_POOL_TOC.enum_types = {}
M_VIP_EXP_POOL_TOC.fields = {M_VIP_EXP_POOL_TOC_EXP_FIELD}
M_VIP_EXP_POOL_TOC.is_extendable = false
M_VIP_EXP_POOL_TOC.extensions = {}
M_VIP_MCARD_TOS.name = "m_vip_mcard_tos"
M_VIP_MCARD_TOS.full_name = ".m_vip_mcard_tos"
M_VIP_MCARD_TOS.nested_types = {}
M_VIP_MCARD_TOS.enum_types = {}
M_VIP_MCARD_TOS.fields = {}
M_VIP_MCARD_TOS.is_extendable = false
M_VIP_MCARD_TOS.extensions = {}
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.name = "key"
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.full_name = ".m_vip_mcard_toc.FetchEntry.key"
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.number = 1
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.index = 0
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.label = 1
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.has_default_value = false
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.default_value = 0
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.type = 5
M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD.cpp_type = 1

M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.name = "value"
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.full_name = ".m_vip_mcard_toc.FetchEntry.value"
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.number = 2
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.index = 1
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.label = 1
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.has_default_value = false
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.default_value = false
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.type = 8
M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD.cpp_type = 7

M_VIP_MCARD_TOC_FETCHENTRY.name = "FetchEntry"
M_VIP_MCARD_TOC_FETCHENTRY.full_name = ".m_vip_mcard_toc.FetchEntry"
M_VIP_MCARD_TOC_FETCHENTRY.nested_types = {}
M_VIP_MCARD_TOC_FETCHENTRY.enum_types = {}
M_VIP_MCARD_TOC_FETCHENTRY.fields = {M_VIP_MCARD_TOC_FETCHENTRY_KEY_FIELD, M_VIP_MCARD_TOC_FETCHENTRY_VALUE_FIELD}
M_VIP_MCARD_TOC_FETCHENTRY.is_extendable = false
M_VIP_MCARD_TOC_FETCHENTRY.extensions = {}
M_VIP_MCARD_TOC_FETCHENTRY.containing_type = M_VIP_MCARD_TOC
M_VIP_MCARD_TOC_BUY_FIELD.name = "buy"
M_VIP_MCARD_TOC_BUY_FIELD.full_name = ".m_vip_mcard_toc.buy"
M_VIP_MCARD_TOC_BUY_FIELD.number = 1
M_VIP_MCARD_TOC_BUY_FIELD.index = 0
M_VIP_MCARD_TOC_BUY_FIELD.label = 2
M_VIP_MCARD_TOC_BUY_FIELD.has_default_value = false
M_VIP_MCARD_TOC_BUY_FIELD.default_value = false
M_VIP_MCARD_TOC_BUY_FIELD.type = 8
M_VIP_MCARD_TOC_BUY_FIELD.cpp_type = 7

M_VIP_MCARD_TOC_FETCH_FIELD.name = "fetch"
M_VIP_MCARD_TOC_FETCH_FIELD.full_name = ".m_vip_mcard_toc.fetch"
M_VIP_MCARD_TOC_FETCH_FIELD.number = 3
M_VIP_MCARD_TOC_FETCH_FIELD.index = 1
M_VIP_MCARD_TOC_FETCH_FIELD.label = 3
M_VIP_MCARD_TOC_FETCH_FIELD.has_default_value = false
M_VIP_MCARD_TOC_FETCH_FIELD.default_value = {}
M_VIP_MCARD_TOC_FETCH_FIELD.message_type = M_VIP_MCARD_TOC_FETCHENTRY
M_VIP_MCARD_TOC_FETCH_FIELD.type = 11
M_VIP_MCARD_TOC_FETCH_FIELD.cpp_type = 10

M_VIP_MCARD_TOC.name = "m_vip_mcard_toc"
M_VIP_MCARD_TOC.full_name = ".m_vip_mcard_toc"
M_VIP_MCARD_TOC.nested_types = {M_VIP_MCARD_TOC_FETCHENTRY}
M_VIP_MCARD_TOC.enum_types = {}
M_VIP_MCARD_TOC.fields = {M_VIP_MCARD_TOC_BUY_FIELD, M_VIP_MCARD_TOC_FETCH_FIELD}
M_VIP_MCARD_TOC.is_extendable = false
M_VIP_MCARD_TOC.extensions = {}
M_VIP_MCARD_BUY_TOS.name = "m_vip_mcard_buy_tos"
M_VIP_MCARD_BUY_TOS.full_name = ".m_vip_mcard_buy_tos"
M_VIP_MCARD_BUY_TOS.nested_types = {}
M_VIP_MCARD_BUY_TOS.enum_types = {}
M_VIP_MCARD_BUY_TOS.fields = {}
M_VIP_MCARD_BUY_TOS.is_extendable = false
M_VIP_MCARD_BUY_TOS.extensions = {}
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.name = "day"
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.full_name = ".m_vip_mcard_fetch_tos.day"
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.number = 2
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.index = 0
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.label = 2
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.has_default_value = false
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.default_value = 0
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.type = 5
M_VIP_MCARD_FETCH_TOS_DAY_FIELD.cpp_type = 1

M_VIP_MCARD_FETCH_TOS.name = "m_vip_mcard_fetch_tos"
M_VIP_MCARD_FETCH_TOS.full_name = ".m_vip_mcard_fetch_tos"
M_VIP_MCARD_FETCH_TOS.nested_types = {}
M_VIP_MCARD_FETCH_TOS.enum_types = {}
M_VIP_MCARD_FETCH_TOS.fields = {M_VIP_MCARD_FETCH_TOS_DAY_FIELD}
M_VIP_MCARD_FETCH_TOS.is_extendable = false
M_VIP_MCARD_FETCH_TOS.extensions = {}
M_VIP_INVEST_TOS.name = "m_vip_invest_tos"
M_VIP_INVEST_TOS.full_name = ".m_vip_invest_tos"
M_VIP_INVEST_TOS.nested_types = {}
M_VIP_INVEST_TOS.enum_types = {}
M_VIP_INVEST_TOS.fields = {}
M_VIP_INVEST_TOS.is_extendable = false
M_VIP_INVEST_TOS.extensions = {}
M_VIP_INVEST_TOC_TYPE_FIELD.name = "type"
M_VIP_INVEST_TOC_TYPE_FIELD.full_name = ".m_vip_invest_toc.type"
M_VIP_INVEST_TOC_TYPE_FIELD.number = 1
M_VIP_INVEST_TOC_TYPE_FIELD.index = 0
M_VIP_INVEST_TOC_TYPE_FIELD.label = 2
M_VIP_INVEST_TOC_TYPE_FIELD.has_default_value = false
M_VIP_INVEST_TOC_TYPE_FIELD.default_value = 0
M_VIP_INVEST_TOC_TYPE_FIELD.type = 5
M_VIP_INVEST_TOC_TYPE_FIELD.cpp_type = 1

M_VIP_INVEST_TOC_GRADE_FIELD.name = "grade"
M_VIP_INVEST_TOC_GRADE_FIELD.full_name = ".m_vip_invest_toc.grade"
M_VIP_INVEST_TOC_GRADE_FIELD.number = 2
M_VIP_INVEST_TOC_GRADE_FIELD.index = 1
M_VIP_INVEST_TOC_GRADE_FIELD.label = 2
M_VIP_INVEST_TOC_GRADE_FIELD.has_default_value = false
M_VIP_INVEST_TOC_GRADE_FIELD.default_value = 0
M_VIP_INVEST_TOC_GRADE_FIELD.type = 5
M_VIP_INVEST_TOC_GRADE_FIELD.cpp_type = 1

M_VIP_INVEST_TOC_LIST_FIELD.name = "list"
M_VIP_INVEST_TOC_LIST_FIELD.full_name = ".m_vip_invest_toc.list"
M_VIP_INVEST_TOC_LIST_FIELD.number = 3
M_VIP_INVEST_TOC_LIST_FIELD.index = 2
M_VIP_INVEST_TOC_LIST_FIELD.label = 3
M_VIP_INVEST_TOC_LIST_FIELD.has_default_value = false
M_VIP_INVEST_TOC_LIST_FIELD.default_value = {}
M_VIP_INVEST_TOC_LIST_FIELD.message_type = P_INVEST
M_VIP_INVEST_TOC_LIST_FIELD.type = 11
M_VIP_INVEST_TOC_LIST_FIELD.cpp_type = 10

M_VIP_INVEST_TOC.name = "m_vip_invest_toc"
M_VIP_INVEST_TOC.full_name = ".m_vip_invest_toc"
M_VIP_INVEST_TOC.nested_types = {}
M_VIP_INVEST_TOC.enum_types = {}
M_VIP_INVEST_TOC.fields = {M_VIP_INVEST_TOC_TYPE_FIELD, M_VIP_INVEST_TOC_GRADE_FIELD, M_VIP_INVEST_TOC_LIST_FIELD}
M_VIP_INVEST_TOC.is_extendable = false
M_VIP_INVEST_TOC.extensions = {}
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.name = "type"
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.full_name = ".m_vip_invest_buy_tos.type"
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.number = 1
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.index = 0
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.label = 2
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.has_default_value = false
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.default_value = 0
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.type = 5
M_VIP_INVEST_BUY_TOS_TYPE_FIELD.cpp_type = 1

M_VIP_INVEST_BUY_TOS_GRADE_FIELD.name = "grade"
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.full_name = ".m_vip_invest_buy_tos.grade"
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.number = 2
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.index = 1
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.label = 2
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.has_default_value = false
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.default_value = 0
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.type = 5
M_VIP_INVEST_BUY_TOS_GRADE_FIELD.cpp_type = 1

M_VIP_INVEST_BUY_TOS.name = "m_vip_invest_buy_tos"
M_VIP_INVEST_BUY_TOS.full_name = ".m_vip_invest_buy_tos"
M_VIP_INVEST_BUY_TOS.nested_types = {}
M_VIP_INVEST_BUY_TOS.enum_types = {}
M_VIP_INVEST_BUY_TOS.fields = {M_VIP_INVEST_BUY_TOS_TYPE_FIELD, M_VIP_INVEST_BUY_TOS_GRADE_FIELD}
M_VIP_INVEST_BUY_TOS.is_extendable = false
M_VIP_INVEST_BUY_TOS.extensions = {}
M_VIP_INVEST_BUY_TOC.name = "m_vip_invest_buy_toc"
M_VIP_INVEST_BUY_TOC.full_name = ".m_vip_invest_buy_toc"
M_VIP_INVEST_BUY_TOC.nested_types = {}
M_VIP_INVEST_BUY_TOC.enum_types = {}
M_VIP_INVEST_BUY_TOC.fields = {}
M_VIP_INVEST_BUY_TOC.is_extendable = false
M_VIP_INVEST_BUY_TOC.extensions = {}
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.name = "type"
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.full_name = ".m_vip_invest_fetch_tos.type"
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.number = 1
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.index = 0
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.label = 2
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.has_default_value = false
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.default_value = 0
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.type = 5
M_VIP_INVEST_FETCH_TOS_TYPE_FIELD.cpp_type = 1

M_VIP_INVEST_FETCH_TOS_ID_FIELD.name = "id"
M_VIP_INVEST_FETCH_TOS_ID_FIELD.full_name = ".m_vip_invest_fetch_tos.id"
M_VIP_INVEST_FETCH_TOS_ID_FIELD.number = 2
M_VIP_INVEST_FETCH_TOS_ID_FIELD.index = 1
M_VIP_INVEST_FETCH_TOS_ID_FIELD.label = 2
M_VIP_INVEST_FETCH_TOS_ID_FIELD.has_default_value = false
M_VIP_INVEST_FETCH_TOS_ID_FIELD.default_value = 0
M_VIP_INVEST_FETCH_TOS_ID_FIELD.type = 5
M_VIP_INVEST_FETCH_TOS_ID_FIELD.cpp_type = 1

M_VIP_INVEST_FETCH_TOS.name = "m_vip_invest_fetch_tos"
M_VIP_INVEST_FETCH_TOS.full_name = ".m_vip_invest_fetch_tos"
M_VIP_INVEST_FETCH_TOS.nested_types = {}
M_VIP_INVEST_FETCH_TOS.enum_types = {}
M_VIP_INVEST_FETCH_TOS.fields = {M_VIP_INVEST_FETCH_TOS_TYPE_FIELD, M_VIP_INVEST_FETCH_TOS_ID_FIELD}
M_VIP_INVEST_FETCH_TOS.is_extendable = false
M_VIP_INVEST_FETCH_TOS.extensions = {}
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.name = "item"
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.full_name = ".m_vip_invest_fetch_toc.item"
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.number = 1
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.index = 0
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.label = 2
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.has_default_value = false
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.default_value = nil
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.message_type = P_INVEST
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.type = 11
M_VIP_INVEST_FETCH_TOC_ITEM_FIELD.cpp_type = 10

M_VIP_INVEST_FETCH_TOC.name = "m_vip_invest_fetch_toc"
M_VIP_INVEST_FETCH_TOC.full_name = ".m_vip_invest_fetch_toc"
M_VIP_INVEST_FETCH_TOC.nested_types = {}
M_VIP_INVEST_FETCH_TOC.enum_types = {}
M_VIP_INVEST_FETCH_TOC.fields = {M_VIP_INVEST_FETCH_TOC_ITEM_FIELD}
M_VIP_INVEST_FETCH_TOC.is_extendable = false
M_VIP_INVEST_FETCH_TOC.extensions = {}
M_VIP_INVEST_NEXT_TOC.name = "m_vip_invest_next_toc"
M_VIP_INVEST_NEXT_TOC.full_name = ".m_vip_invest_next_toc"
M_VIP_INVEST_NEXT_TOC.nested_types = {}
M_VIP_INVEST_NEXT_TOC.enum_types = {}
M_VIP_INVEST_NEXT_TOC.fields = {}
M_VIP_INVEST_NEXT_TOC.is_extendable = false
M_VIP_INVEST_NEXT_TOC.extensions = {}
M_VIP_REBATE_INFO_TOS.name = "m_vip_rebate_info_tos"
M_VIP_REBATE_INFO_TOS.full_name = ".m_vip_rebate_info_tos"
M_VIP_REBATE_INFO_TOS.nested_types = {}
M_VIP_REBATE_INFO_TOS.enum_types = {}
M_VIP_REBATE_INFO_TOS.fields = {}
M_VIP_REBATE_INFO_TOS.is_extendable = false
M_VIP_REBATE_INFO_TOS.extensions = {}
M_VIP_REBATE_INFO_TOC_TIME_FIELD.name = "time"
M_VIP_REBATE_INFO_TOC_TIME_FIELD.full_name = ".m_vip_rebate_info_toc.time"
M_VIP_REBATE_INFO_TOC_TIME_FIELD.number = 1
M_VIP_REBATE_INFO_TOC_TIME_FIELD.index = 0
M_VIP_REBATE_INFO_TOC_TIME_FIELD.label = 2
M_VIP_REBATE_INFO_TOC_TIME_FIELD.has_default_value = false
M_VIP_REBATE_INFO_TOC_TIME_FIELD.default_value = 0
M_VIP_REBATE_INFO_TOC_TIME_FIELD.type = 5
M_VIP_REBATE_INFO_TOC_TIME_FIELD.cpp_type = 1

M_VIP_REBATE_INFO_TOC_FETCH_FIELD.name = "fetch"
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.full_name = ".m_vip_rebate_info_toc.fetch"
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.number = 2
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.index = 1
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.label = 2
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.has_default_value = false
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.default_value = false
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.type = 8
M_VIP_REBATE_INFO_TOC_FETCH_FIELD.cpp_type = 7

M_VIP_REBATE_INFO_TOC.name = "m_vip_rebate_info_toc"
M_VIP_REBATE_INFO_TOC.full_name = ".m_vip_rebate_info_toc"
M_VIP_REBATE_INFO_TOC.nested_types = {}
M_VIP_REBATE_INFO_TOC.enum_types = {}
M_VIP_REBATE_INFO_TOC.fields = {M_VIP_REBATE_INFO_TOC_TIME_FIELD, M_VIP_REBATE_INFO_TOC_FETCH_FIELD}
M_VIP_REBATE_INFO_TOC.is_extendable = false
M_VIP_REBATE_INFO_TOC.extensions = {}
M_VIP_REBATE_FETCH_TOS.name = "m_vip_rebate_fetch_tos"
M_VIP_REBATE_FETCH_TOS.full_name = ".m_vip_rebate_fetch_tos"
M_VIP_REBATE_FETCH_TOS.nested_types = {}
M_VIP_REBATE_FETCH_TOS.enum_types = {}
M_VIP_REBATE_FETCH_TOS.fields = {}
M_VIP_REBATE_FETCH_TOS.is_extendable = false
M_VIP_REBATE_FETCH_TOS.extensions = {}
M_VIP_REBATE_FETCH_TOC.name = "m_vip_rebate_fetch_toc"
M_VIP_REBATE_FETCH_TOC.full_name = ".m_vip_rebate_fetch_toc"
M_VIP_REBATE_FETCH_TOC.nested_types = {}
M_VIP_REBATE_FETCH_TOC.enum_types = {}
M_VIP_REBATE_FETCH_TOC.fields = {}
M_VIP_REBATE_FETCH_TOC.is_extendable = false
M_VIP_REBATE_FETCH_TOC.extensions = {}
M_VIP_TASTE_INFO_TOS.name = "m_vip_taste_info_tos"
M_VIP_TASTE_INFO_TOS.full_name = ".m_vip_taste_info_tos"
M_VIP_TASTE_INFO_TOS.nested_types = {}
M_VIP_TASTE_INFO_TOS.enum_types = {}
M_VIP_TASTE_INFO_TOS.fields = {}
M_VIP_TASTE_INFO_TOS.is_extendable = false
M_VIP_TASTE_INFO_TOS.extensions = {}
M_VIP_TASTE_INFO_TOC_STIME_FIELD.name = "stime"
M_VIP_TASTE_INFO_TOC_STIME_FIELD.full_name = ".m_vip_taste_info_toc.stime"
M_VIP_TASTE_INFO_TOC_STIME_FIELD.number = 1
M_VIP_TASTE_INFO_TOC_STIME_FIELD.index = 0
M_VIP_TASTE_INFO_TOC_STIME_FIELD.label = 2
M_VIP_TASTE_INFO_TOC_STIME_FIELD.has_default_value = false
M_VIP_TASTE_INFO_TOC_STIME_FIELD.default_value = 0
M_VIP_TASTE_INFO_TOC_STIME_FIELD.type = 5
M_VIP_TASTE_INFO_TOC_STIME_FIELD.cpp_type = 1

M_VIP_TASTE_INFO_TOC_ETIME_FIELD.name = "etime"
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.full_name = ".m_vip_taste_info_toc.etime"
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.number = 2
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.index = 1
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.label = 2
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.has_default_value = false
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.default_value = 0
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.type = 5
M_VIP_TASTE_INFO_TOC_ETIME_FIELD.cpp_type = 1

M_VIP_TASTE_INFO_TOC.name = "m_vip_taste_info_toc"
M_VIP_TASTE_INFO_TOC.full_name = ".m_vip_taste_info_toc"
M_VIP_TASTE_INFO_TOC.nested_types = {}
M_VIP_TASTE_INFO_TOC.enum_types = {}
M_VIP_TASTE_INFO_TOC.fields = {M_VIP_TASTE_INFO_TOC_STIME_FIELD, M_VIP_TASTE_INFO_TOC_ETIME_FIELD}
M_VIP_TASTE_INFO_TOC.is_extendable = false
M_VIP_TASTE_INFO_TOC.extensions = {}
M_VIP_INVEST2_TOS_TYPE_FIELD.name = "type"
M_VIP_INVEST2_TOS_TYPE_FIELD.full_name = ".m_vip_invest2_tos.type"
M_VIP_INVEST2_TOS_TYPE_FIELD.number = 1
M_VIP_INVEST2_TOS_TYPE_FIELD.index = 0
M_VIP_INVEST2_TOS_TYPE_FIELD.label = 2
M_VIP_INVEST2_TOS_TYPE_FIELD.has_default_value = false
M_VIP_INVEST2_TOS_TYPE_FIELD.default_value = 0
M_VIP_INVEST2_TOS_TYPE_FIELD.type = 5
M_VIP_INVEST2_TOS_TYPE_FIELD.cpp_type = 1

M_VIP_INVEST2_TOS.name = "m_vip_invest2_tos"
M_VIP_INVEST2_TOS.full_name = ".m_vip_invest2_tos"
M_VIP_INVEST2_TOS.nested_types = {}
M_VIP_INVEST2_TOS.enum_types = {}
M_VIP_INVEST2_TOS.fields = {M_VIP_INVEST2_TOS_TYPE_FIELD}
M_VIP_INVEST2_TOS.is_extendable = false
M_VIP_INVEST2_TOS.extensions = {}
M_VIP_INVEST2_TOC_TYPE_FIELD.name = "type"
M_VIP_INVEST2_TOC_TYPE_FIELD.full_name = ".m_vip_invest2_toc.type"
M_VIP_INVEST2_TOC_TYPE_FIELD.number = 1
M_VIP_INVEST2_TOC_TYPE_FIELD.index = 0
M_VIP_INVEST2_TOC_TYPE_FIELD.label = 2
M_VIP_INVEST2_TOC_TYPE_FIELD.has_default_value = false
M_VIP_INVEST2_TOC_TYPE_FIELD.default_value = 0
M_VIP_INVEST2_TOC_TYPE_FIELD.type = 5
M_VIP_INVEST2_TOC_TYPE_FIELD.cpp_type = 1

M_VIP_INVEST2_TOC_GRADE_FIELD.name = "grade"
M_VIP_INVEST2_TOC_GRADE_FIELD.full_name = ".m_vip_invest2_toc.grade"
M_VIP_INVEST2_TOC_GRADE_FIELD.number = 2
M_VIP_INVEST2_TOC_GRADE_FIELD.index = 1
M_VIP_INVEST2_TOC_GRADE_FIELD.label = 2
M_VIP_INVEST2_TOC_GRADE_FIELD.has_default_value = false
M_VIP_INVEST2_TOC_GRADE_FIELD.default_value = 0
M_VIP_INVEST2_TOC_GRADE_FIELD.type = 5
M_VIP_INVEST2_TOC_GRADE_FIELD.cpp_type = 1

M_VIP_INVEST2_TOC_LIST_FIELD.name = "list"
M_VIP_INVEST2_TOC_LIST_FIELD.full_name = ".m_vip_invest2_toc.list"
M_VIP_INVEST2_TOC_LIST_FIELD.number = 3
M_VIP_INVEST2_TOC_LIST_FIELD.index = 2
M_VIP_INVEST2_TOC_LIST_FIELD.label = 3
M_VIP_INVEST2_TOC_LIST_FIELD.has_default_value = false
M_VIP_INVEST2_TOC_LIST_FIELD.default_value = {}
M_VIP_INVEST2_TOC_LIST_FIELD.message_type = P_INVEST
M_VIP_INVEST2_TOC_LIST_FIELD.type = 11
M_VIP_INVEST2_TOC_LIST_FIELD.cpp_type = 10

M_VIP_INVEST2_TOC.name = "m_vip_invest2_toc"
M_VIP_INVEST2_TOC.full_name = ".m_vip_invest2_toc"
M_VIP_INVEST2_TOC.nested_types = {}
M_VIP_INVEST2_TOC.enum_types = {}
M_VIP_INVEST2_TOC.fields = {M_VIP_INVEST2_TOC_TYPE_FIELD, M_VIP_INVEST2_TOC_GRADE_FIELD, M_VIP_INVEST2_TOC_LIST_FIELD}
M_VIP_INVEST2_TOC.is_extendable = false
M_VIP_INVEST2_TOC.extensions = {}
P_INVEST_ID_FIELD.name = "id"
P_INVEST_ID_FIELD.full_name = ".p_invest.id"
P_INVEST_ID_FIELD.number = 1
P_INVEST_ID_FIELD.index = 0
P_INVEST_ID_FIELD.label = 2
P_INVEST_ID_FIELD.has_default_value = false
P_INVEST_ID_FIELD.default_value = 0
P_INVEST_ID_FIELD.type = 5
P_INVEST_ID_FIELD.cpp_type = 1

P_INVEST_STATE_FIELD.name = "state"
P_INVEST_STATE_FIELD.full_name = ".p_invest.state"
P_INVEST_STATE_FIELD.number = 3
P_INVEST_STATE_FIELD.index = 1
P_INVEST_STATE_FIELD.label = 2
P_INVEST_STATE_FIELD.has_default_value = false
P_INVEST_STATE_FIELD.default_value = 0
P_INVEST_STATE_FIELD.type = 5
P_INVEST_STATE_FIELD.cpp_type = 1

P_INVEST_BGOLD_FIELD.name = "bgold"
P_INVEST_BGOLD_FIELD.full_name = ".p_invest.bgold"
P_INVEST_BGOLD_FIELD.number = 4
P_INVEST_BGOLD_FIELD.index = 2
P_INVEST_BGOLD_FIELD.label = 2
P_INVEST_BGOLD_FIELD.has_default_value = false
P_INVEST_BGOLD_FIELD.default_value = 0
P_INVEST_BGOLD_FIELD.type = 5
P_INVEST_BGOLD_FIELD.cpp_type = 1

P_INVEST.name = "p_invest"
P_INVEST.full_name = ".p_invest"
P_INVEST.nested_types = {}
P_INVEST.enum_types = {}
P_INVEST.fields = {P_INVEST_ID_FIELD, P_INVEST_STATE_FIELD, P_INVEST_BGOLD_FIELD}
P_INVEST.is_extendable = false
P_INVEST.extensions = {}

m_vip_active_toc = protobuf.Message(M_VIP_ACTIVE_TOC)
m_vip_active_tos = protobuf.Message(M_VIP_ACTIVE_TOS)
m_vip_auto_fetch_toc = protobuf.Message(M_VIP_AUTO_FETCH_TOC)
m_vip_auto_fetch_tos = protobuf.Message(M_VIP_AUTO_FETCH_TOS)
m_vip_exp_pool_toc = protobuf.Message(M_VIP_EXP_POOL_TOC)
m_vip_exp_pool_tos = protobuf.Message(M_VIP_EXP_POOL_TOS)
m_vip_fetch_toc = protobuf.Message(M_VIP_FETCH_TOC)
m_vip_fetch_tos = protobuf.Message(M_VIP_FETCH_TOS)
m_vip_info_toc = protobuf.Message(M_VIP_INFO_TOC)
m_vip_info_tos = protobuf.Message(M_VIP_INFO_TOS)
m_vip_invest2_toc = protobuf.Message(M_VIP_INVEST2_TOC)
m_vip_invest2_tos = protobuf.Message(M_VIP_INVEST2_TOS)
m_vip_invest_buy_toc = protobuf.Message(M_VIP_INVEST_BUY_TOC)
m_vip_invest_buy_tos = protobuf.Message(M_VIP_INVEST_BUY_TOS)
m_vip_invest_fetch_toc = protobuf.Message(M_VIP_INVEST_FETCH_TOC)
m_vip_invest_fetch_tos = protobuf.Message(M_VIP_INVEST_FETCH_TOS)
m_vip_invest_next_toc = protobuf.Message(M_VIP_INVEST_NEXT_TOC)
m_vip_invest_toc = protobuf.Message(M_VIP_INVEST_TOC)
m_vip_invest_tos = protobuf.Message(M_VIP_INVEST_TOS)
m_vip_mcard_buy_tos = protobuf.Message(M_VIP_MCARD_BUY_TOS)
m_vip_mcard_fetch_tos = protobuf.Message(M_VIP_MCARD_FETCH_TOS)
m_vip_mcard_toc = protobuf.Message(M_VIP_MCARD_TOC)
m_vip_mcard_toc.FetchEntry = protobuf.Message(M_VIP_MCARD_TOC_FETCHENTRY)
m_vip_mcard_tos = protobuf.Message(M_VIP_MCARD_TOS)
m_vip_rebate_fetch_toc = protobuf.Message(M_VIP_REBATE_FETCH_TOC)
m_vip_rebate_fetch_tos = protobuf.Message(M_VIP_REBATE_FETCH_TOS)
m_vip_rebate_info_toc = protobuf.Message(M_VIP_REBATE_INFO_TOC)
m_vip_rebate_info_tos = protobuf.Message(M_VIP_REBATE_INFO_TOS)
m_vip_taste_info_toc = protobuf.Message(M_VIP_TASTE_INFO_TOC)
m_vip_taste_info_tos = protobuf.Message(M_VIP_TASTE_INFO_TOS)
p_invest = protobuf.Message(P_INVEST)

