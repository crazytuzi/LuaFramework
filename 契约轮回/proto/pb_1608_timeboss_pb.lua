-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "tolua.protobuf/protobuf"
module('pb_1608_timeboss_pb')


M_TIMEBOSS_LIST_TOS = protobuf.Descriptor();
M_TIMEBOSS_LIST_TOC = protobuf.Descriptor();
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_RANKING_TOS = protobuf.Descriptor();
M_TIMEBOSS_RANKING_TOC = protobuf.Descriptor();
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_DICE_TOC = protobuf.Descriptor();
M_TIMEBOSS_DICE_TOC_ETIME_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_DICING_TOS = protobuf.Descriptor();
M_TIMEBOSS_DICING_TOC = protobuf.Descriptor();
M_TIMEBOSS_DICING_TOC_SCORE_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_DICING_TOC_OWNER_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXINFO_TOS = protobuf.Descriptor();
M_TIMEBOSS_BOXINFO_TOC = protobuf.Descriptor();
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXOPEN_TOS = protobuf.Descriptor();
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXOPEN_TOC = protobuf.Descriptor();
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY = protobuf.Descriptor();
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_CARE_TOS = protobuf.Descriptor();
M_TIMEBOSS_CARE_TOS_ID_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_CARE_TOS_OP_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_CARE_TOS_TYPE_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_CARE_TOC = protobuf.Descriptor();
M_TIMEBOSS_CARE_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_CARE_TOC_OP_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_CARE_TOC_TYPE_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_REMIND_TOC = protobuf.Descriptor();
M_TIMEBOSS_REMIND_TOC_ID_FIELD = protobuf.FieldDescriptor();
M_TIMEBOSS_DROPPED_TOS = protobuf.Descriptor();
M_TIMEBOSS_DROPPED_TOC = protobuf.Descriptor();
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS = protobuf.Descriptor();
P_TIMEBOSS_ID_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_BORN_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_FLOOR_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_ROLE_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_BOX_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_CARE_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_RANKING = protobuf.Descriptor();
P_TIMEBOSS_RANKING_RANK_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_RANKING_IS_TEAM_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_RANKING_CAPTAIN_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_RANKING_NAME_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_RANKING_DAMAGE_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_RANKING_TEAM_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_DROPPED = protobuf.Descriptor();
P_TIMEBOSS_DROPPED_TIME_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_DROPPED_SCENE_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_DROPPED_BOSS_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD = protobuf.FieldDescriptor();
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD = protobuf.FieldDescriptor();

M_TIMEBOSS_LIST_TOS.name = "m_timeboss_list_tos"
M_TIMEBOSS_LIST_TOS.full_name = ".m_timeboss_list_tos"
M_TIMEBOSS_LIST_TOS.nested_types = {}
M_TIMEBOSS_LIST_TOS.enum_types = {}
M_TIMEBOSS_LIST_TOS.fields = {}
M_TIMEBOSS_LIST_TOS.is_extendable = false
M_TIMEBOSS_LIST_TOS.extensions = {}
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.name = "bosses"
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.full_name = ".m_timeboss_list_toc.bosses"
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.number = 1
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.index = 0
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.label = 3
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.has_default_value = false
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.default_value = {}
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.message_type = P_TIMEBOSS
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.type = 11
M_TIMEBOSS_LIST_TOC_BOSSES_FIELD.cpp_type = 10

M_TIMEBOSS_LIST_TOC.name = "m_timeboss_list_toc"
M_TIMEBOSS_LIST_TOC.full_name = ".m_timeboss_list_toc"
M_TIMEBOSS_LIST_TOC.nested_types = {}
M_TIMEBOSS_LIST_TOC.enum_types = {}
M_TIMEBOSS_LIST_TOC.fields = {M_TIMEBOSS_LIST_TOC_BOSSES_FIELD}
M_TIMEBOSS_LIST_TOC.is_extendable = false
M_TIMEBOSS_LIST_TOC.extensions = {}
M_TIMEBOSS_RANKING_TOS.name = "m_timeboss_ranking_tos"
M_TIMEBOSS_RANKING_TOS.full_name = ".m_timeboss_ranking_tos"
M_TIMEBOSS_RANKING_TOS.nested_types = {}
M_TIMEBOSS_RANKING_TOS.enum_types = {}
M_TIMEBOSS_RANKING_TOS.fields = {}
M_TIMEBOSS_RANKING_TOS.is_extendable = false
M_TIMEBOSS_RANKING_TOS.extensions = {}
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.name = "ranking"
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.full_name = ".m_timeboss_ranking_toc.ranking"
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.number = 1
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.index = 0
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.label = 3
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.has_default_value = false
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.default_value = {}
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.message_type = P_TIMEBOSS_RANKING
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.type = 11
M_TIMEBOSS_RANKING_TOC_RANKING_FIELD.cpp_type = 10

M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.name = "my_rank"
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.full_name = ".m_timeboss_ranking_toc.my_rank"
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.number = 2
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.index = 1
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.label = 2
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.has_default_value = false
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.default_value = 0
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.type = 5
M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD.cpp_type = 1

M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.name = "my_dmg"
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.full_name = ".m_timeboss_ranking_toc.my_dmg"
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.number = 3
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.index = 2
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.label = 2
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.has_default_value = false
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.default_value = 0
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.type = 5
M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD.cpp_type = 1

M_TIMEBOSS_RANKING_TOC.name = "m_timeboss_ranking_toc"
M_TIMEBOSS_RANKING_TOC.full_name = ".m_timeboss_ranking_toc"
M_TIMEBOSS_RANKING_TOC.nested_types = {}
M_TIMEBOSS_RANKING_TOC.enum_types = {}
M_TIMEBOSS_RANKING_TOC.fields = {M_TIMEBOSS_RANKING_TOC_RANKING_FIELD, M_TIMEBOSS_RANKING_TOC_MY_RANK_FIELD, M_TIMEBOSS_RANKING_TOC_MY_DMG_FIELD}
M_TIMEBOSS_RANKING_TOC.is_extendable = false
M_TIMEBOSS_RANKING_TOC.extensions = {}
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.name = "etime"
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.full_name = ".m_timeboss_dice_toc.etime"
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.number = 1
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.index = 0
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.label = 2
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.has_default_value = false
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.default_value = 0
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.type = 5
M_TIMEBOSS_DICE_TOC_ETIME_FIELD.cpp_type = 1

M_TIMEBOSS_DICE_TOC.name = "m_timeboss_dice_toc"
M_TIMEBOSS_DICE_TOC.full_name = ".m_timeboss_dice_toc"
M_TIMEBOSS_DICE_TOC.nested_types = {}
M_TIMEBOSS_DICE_TOC.enum_types = {}
M_TIMEBOSS_DICE_TOC.fields = {M_TIMEBOSS_DICE_TOC_ETIME_FIELD}
M_TIMEBOSS_DICE_TOC.is_extendable = false
M_TIMEBOSS_DICE_TOC.extensions = {}
M_TIMEBOSS_DICING_TOS.name = "m_timeboss_dicing_tos"
M_TIMEBOSS_DICING_TOS.full_name = ".m_timeboss_dicing_tos"
M_TIMEBOSS_DICING_TOS.nested_types = {}
M_TIMEBOSS_DICING_TOS.enum_types = {}
M_TIMEBOSS_DICING_TOS.fields = {}
M_TIMEBOSS_DICING_TOS.is_extendable = false
M_TIMEBOSS_DICING_TOS.extensions = {}
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.name = "score"
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.full_name = ".m_timeboss_dicing_toc.score"
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.number = 1
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.index = 0
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.label = 2
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.has_default_value = false
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.default_value = 0
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.type = 5
M_TIMEBOSS_DICING_TOC_SCORE_FIELD.cpp_type = 1

M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.name = "highest"
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.full_name = ".m_timeboss_dicing_toc.highest"
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.number = 2
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.index = 1
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.label = 2
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.has_default_value = false
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.default_value = 0
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.type = 5
M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD.cpp_type = 1

M_TIMEBOSS_DICING_TOC_OWNER_FIELD.name = "owner"
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.full_name = ".m_timeboss_dicing_toc.owner"
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.number = 3
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.index = 2
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.label = 2
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.has_default_value = false
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.default_value = ""
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.type = 9
M_TIMEBOSS_DICING_TOC_OWNER_FIELD.cpp_type = 9

M_TIMEBOSS_DICING_TOC.name = "m_timeboss_dicing_toc"
M_TIMEBOSS_DICING_TOC.full_name = ".m_timeboss_dicing_toc"
M_TIMEBOSS_DICING_TOC.nested_types = {}
M_TIMEBOSS_DICING_TOC.enum_types = {}
M_TIMEBOSS_DICING_TOC.fields = {M_TIMEBOSS_DICING_TOC_SCORE_FIELD, M_TIMEBOSS_DICING_TOC_HIGHEST_FIELD, M_TIMEBOSS_DICING_TOC_OWNER_FIELD}
M_TIMEBOSS_DICING_TOC.is_extendable = false
M_TIMEBOSS_DICING_TOC.extensions = {}
M_TIMEBOSS_BOXINFO_TOS.name = "m_timeboss_boxinfo_tos"
M_TIMEBOSS_BOXINFO_TOS.full_name = ".m_timeboss_boxinfo_tos"
M_TIMEBOSS_BOXINFO_TOS.nested_types = {}
M_TIMEBOSS_BOXINFO_TOS.enum_types = {}
M_TIMEBOSS_BOXINFO_TOS.fields = {}
M_TIMEBOSS_BOXINFO_TOS.is_extendable = false
M_TIMEBOSS_BOXINFO_TOS.extensions = {}
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.name = "summoner"
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.full_name = ".m_timeboss_boxinfo_toc.summoner"
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.number = 1
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.index = 0
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.label = 3
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.has_default_value = false
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.default_value = {}
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.type = 9
M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD.cpp_type = 9

M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.name = "suids"
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.full_name = ".m_timeboss_boxinfo_toc.suids"
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.number = 2
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.index = 1
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.label = 3
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.has_default_value = false
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.default_value = {}
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.type = 5
M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD.cpp_type = 1

M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.name = "can_open"
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.full_name = ".m_timeboss_boxinfo_toc.can_open"
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.number = 3
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.index = 2
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.label = 2
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.has_default_value = false
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.default_value = false
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.type = 8
M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD.cpp_type = 7

M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.name = "remain"
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.full_name = ".m_timeboss_boxinfo_toc.remain"
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.number = 4
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.index = 3
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.label = 2
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.has_default_value = false
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.default_value = 0
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.type = 5
M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD.cpp_type = 1

M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.name = "boss_id"
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.full_name = ".m_timeboss_boxinfo_toc.boss_id"
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.number = 5
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.index = 4
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.label = 2
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.has_default_value = false
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.default_value = 0
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.type = 5
M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD.cpp_type = 1

M_TIMEBOSS_BOXINFO_TOC.name = "m_timeboss_boxinfo_toc"
M_TIMEBOSS_BOXINFO_TOC.full_name = ".m_timeboss_boxinfo_toc"
M_TIMEBOSS_BOXINFO_TOC.nested_types = {}
M_TIMEBOSS_BOXINFO_TOC.enum_types = {}
M_TIMEBOSS_BOXINFO_TOC.fields = {M_TIMEBOSS_BOXINFO_TOC_SUMMONER_FIELD, M_TIMEBOSS_BOXINFO_TOC_SUIDS_FIELD, M_TIMEBOSS_BOXINFO_TOC_CAN_OPEN_FIELD, M_TIMEBOSS_BOXINFO_TOC_REMAIN_FIELD, M_TIMEBOSS_BOXINFO_TOC_BOSS_ID_FIELD}
M_TIMEBOSS_BOXINFO_TOC.is_extendable = false
M_TIMEBOSS_BOXINFO_TOC.extensions = {}
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.name = "type"
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.full_name = ".m_timeboss_boxopen_tos.type"
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.number = 1
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.index = 0
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.label = 2
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.has_default_value = false
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.default_value = 0
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.type = 5
M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD.cpp_type = 1

M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.name = "boss"
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.full_name = ".m_timeboss_boxopen_tos.boss"
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.number = 2
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.index = 1
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.label = 2
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.has_default_value = false
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.default_value = 0
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.type = 5
M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD.cpp_type = 1

M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.name = "times"
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.full_name = ".m_timeboss_boxopen_tos.times"
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.number = 3
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.index = 2
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.label = 2
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.has_default_value = false
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.default_value = 0
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.type = 5
M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD.cpp_type = 1

M_TIMEBOSS_BOXOPEN_TOS.name = "m_timeboss_boxopen_tos"
M_TIMEBOSS_BOXOPEN_TOS.full_name = ".m_timeboss_boxopen_tos"
M_TIMEBOSS_BOXOPEN_TOS.nested_types = {}
M_TIMEBOSS_BOXOPEN_TOS.enum_types = {}
M_TIMEBOSS_BOXOPEN_TOS.fields = {M_TIMEBOSS_BOXOPEN_TOS_TYPE_FIELD, M_TIMEBOSS_BOXOPEN_TOS_BOSS_FIELD, M_TIMEBOSS_BOXOPEN_TOS_TIMES_FIELD}
M_TIMEBOSS_BOXOPEN_TOS.is_extendable = false
M_TIMEBOSS_BOXOPEN_TOS.extensions = {}
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.name = "key"
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.full_name = ".m_timeboss_boxopen_toc.RewardEntry.key"
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.number = 1
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.index = 0
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.label = 1
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.has_default_value = false
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.default_value = 0
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.type = 5
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD.cpp_type = 1

M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.name = "value"
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.full_name = ".m_timeboss_boxopen_toc.RewardEntry.value"
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.number = 2
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.index = 1
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.label = 1
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.has_default_value = false
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.default_value = 0
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.type = 5
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD.cpp_type = 1

M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.name = "RewardEntry"
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.full_name = ".m_timeboss_boxopen_toc.RewardEntry"
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.nested_types = {}
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.enum_types = {}
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.fields = {M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_KEY_FIELD, M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY_VALUE_FIELD}
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.is_extendable = false
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.extensions = {}
M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY.containing_type = M_TIMEBOSS_BOXOPEN_TOC
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.name = "type"
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.full_name = ".m_timeboss_boxopen_toc.type"
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.number = 1
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.index = 0
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.label = 2
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.has_default_value = false
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.default_value = 0
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.type = 5
M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD.cpp_type = 1

M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.name = "reward"
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.full_name = ".m_timeboss_boxopen_toc.reward"
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.number = 2
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.index = 1
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.label = 3
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.has_default_value = false
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.default_value = {}
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.message_type = M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.type = 11
M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD.cpp_type = 10

M_TIMEBOSS_BOXOPEN_TOC.name = "m_timeboss_boxopen_toc"
M_TIMEBOSS_BOXOPEN_TOC.full_name = ".m_timeboss_boxopen_toc"
M_TIMEBOSS_BOXOPEN_TOC.nested_types = {M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY}
M_TIMEBOSS_BOXOPEN_TOC.enum_types = {}
M_TIMEBOSS_BOXOPEN_TOC.fields = {M_TIMEBOSS_BOXOPEN_TOC_TYPE_FIELD, M_TIMEBOSS_BOXOPEN_TOC_REWARD_FIELD}
M_TIMEBOSS_BOXOPEN_TOC.is_extendable = false
M_TIMEBOSS_BOXOPEN_TOC.extensions = {}
M_TIMEBOSS_CARE_TOS_ID_FIELD.name = "id"
M_TIMEBOSS_CARE_TOS_ID_FIELD.full_name = ".m_timeboss_care_tos.id"
M_TIMEBOSS_CARE_TOS_ID_FIELD.number = 1
M_TIMEBOSS_CARE_TOS_ID_FIELD.index = 0
M_TIMEBOSS_CARE_TOS_ID_FIELD.label = 2
M_TIMEBOSS_CARE_TOS_ID_FIELD.has_default_value = false
M_TIMEBOSS_CARE_TOS_ID_FIELD.default_value = 0
M_TIMEBOSS_CARE_TOS_ID_FIELD.type = 5
M_TIMEBOSS_CARE_TOS_ID_FIELD.cpp_type = 1

M_TIMEBOSS_CARE_TOS_OP_FIELD.name = "op"
M_TIMEBOSS_CARE_TOS_OP_FIELD.full_name = ".m_timeboss_care_tos.op"
M_TIMEBOSS_CARE_TOS_OP_FIELD.number = 2
M_TIMEBOSS_CARE_TOS_OP_FIELD.index = 1
M_TIMEBOSS_CARE_TOS_OP_FIELD.label = 2
M_TIMEBOSS_CARE_TOS_OP_FIELD.has_default_value = false
M_TIMEBOSS_CARE_TOS_OP_FIELD.default_value = 0
M_TIMEBOSS_CARE_TOS_OP_FIELD.type = 5
M_TIMEBOSS_CARE_TOS_OP_FIELD.cpp_type = 1

M_TIMEBOSS_CARE_TOS_TYPE_FIELD.name = "type"
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.full_name = ".m_timeboss_care_tos.type"
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.number = 3
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.index = 2
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.label = 2
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.has_default_value = false
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.default_value = 0
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.type = 5
M_TIMEBOSS_CARE_TOS_TYPE_FIELD.cpp_type = 1

M_TIMEBOSS_CARE_TOS.name = "m_timeboss_care_tos"
M_TIMEBOSS_CARE_TOS.full_name = ".m_timeboss_care_tos"
M_TIMEBOSS_CARE_TOS.nested_types = {}
M_TIMEBOSS_CARE_TOS.enum_types = {}
M_TIMEBOSS_CARE_TOS.fields = {M_TIMEBOSS_CARE_TOS_ID_FIELD, M_TIMEBOSS_CARE_TOS_OP_FIELD, M_TIMEBOSS_CARE_TOS_TYPE_FIELD}
M_TIMEBOSS_CARE_TOS.is_extendable = false
M_TIMEBOSS_CARE_TOS.extensions = {}
M_TIMEBOSS_CARE_TOC_ID_FIELD.name = "id"
M_TIMEBOSS_CARE_TOC_ID_FIELD.full_name = ".m_timeboss_care_toc.id"
M_TIMEBOSS_CARE_TOC_ID_FIELD.number = 1
M_TIMEBOSS_CARE_TOC_ID_FIELD.index = 0
M_TIMEBOSS_CARE_TOC_ID_FIELD.label = 2
M_TIMEBOSS_CARE_TOC_ID_FIELD.has_default_value = false
M_TIMEBOSS_CARE_TOC_ID_FIELD.default_value = 0
M_TIMEBOSS_CARE_TOC_ID_FIELD.type = 5
M_TIMEBOSS_CARE_TOC_ID_FIELD.cpp_type = 1

M_TIMEBOSS_CARE_TOC_OP_FIELD.name = "op"
M_TIMEBOSS_CARE_TOC_OP_FIELD.full_name = ".m_timeboss_care_toc.op"
M_TIMEBOSS_CARE_TOC_OP_FIELD.number = 2
M_TIMEBOSS_CARE_TOC_OP_FIELD.index = 1
M_TIMEBOSS_CARE_TOC_OP_FIELD.label = 2
M_TIMEBOSS_CARE_TOC_OP_FIELD.has_default_value = false
M_TIMEBOSS_CARE_TOC_OP_FIELD.default_value = 0
M_TIMEBOSS_CARE_TOC_OP_FIELD.type = 5
M_TIMEBOSS_CARE_TOC_OP_FIELD.cpp_type = 1

M_TIMEBOSS_CARE_TOC_TYPE_FIELD.name = "type"
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.full_name = ".m_timeboss_care_toc.type"
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.number = 3
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.index = 2
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.label = 2
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.has_default_value = false
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.default_value = 0
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.type = 5
M_TIMEBOSS_CARE_TOC_TYPE_FIELD.cpp_type = 1

M_TIMEBOSS_CARE_TOC.name = "m_timeboss_care_toc"
M_TIMEBOSS_CARE_TOC.full_name = ".m_timeboss_care_toc"
M_TIMEBOSS_CARE_TOC.nested_types = {}
M_TIMEBOSS_CARE_TOC.enum_types = {}
M_TIMEBOSS_CARE_TOC.fields = {M_TIMEBOSS_CARE_TOC_ID_FIELD, M_TIMEBOSS_CARE_TOC_OP_FIELD, M_TIMEBOSS_CARE_TOC_TYPE_FIELD}
M_TIMEBOSS_CARE_TOC.is_extendable = false
M_TIMEBOSS_CARE_TOC.extensions = {}
M_TIMEBOSS_REMIND_TOC_ID_FIELD.name = "id"
M_TIMEBOSS_REMIND_TOC_ID_FIELD.full_name = ".m_timeboss_remind_toc.id"
M_TIMEBOSS_REMIND_TOC_ID_FIELD.number = 1
M_TIMEBOSS_REMIND_TOC_ID_FIELD.index = 0
M_TIMEBOSS_REMIND_TOC_ID_FIELD.label = 2
M_TIMEBOSS_REMIND_TOC_ID_FIELD.has_default_value = false
M_TIMEBOSS_REMIND_TOC_ID_FIELD.default_value = 0
M_TIMEBOSS_REMIND_TOC_ID_FIELD.type = 5
M_TIMEBOSS_REMIND_TOC_ID_FIELD.cpp_type = 1

M_TIMEBOSS_REMIND_TOC.name = "m_timeboss_remind_toc"
M_TIMEBOSS_REMIND_TOC.full_name = ".m_timeboss_remind_toc"
M_TIMEBOSS_REMIND_TOC.nested_types = {}
M_TIMEBOSS_REMIND_TOC.enum_types = {}
M_TIMEBOSS_REMIND_TOC.fields = {M_TIMEBOSS_REMIND_TOC_ID_FIELD}
M_TIMEBOSS_REMIND_TOC.is_extendable = false
M_TIMEBOSS_REMIND_TOC.extensions = {}
M_TIMEBOSS_DROPPED_TOS.name = "m_timeboss_dropped_tos"
M_TIMEBOSS_DROPPED_TOS.full_name = ".m_timeboss_dropped_tos"
M_TIMEBOSS_DROPPED_TOS.nested_types = {}
M_TIMEBOSS_DROPPED_TOS.enum_types = {}
M_TIMEBOSS_DROPPED_TOS.fields = {}
M_TIMEBOSS_DROPPED_TOS.is_extendable = false
M_TIMEBOSS_DROPPED_TOS.extensions = {}
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.name = "logs"
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.full_name = ".m_timeboss_dropped_toc.logs"
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.number = 1
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.index = 0
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.label = 3
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.has_default_value = false
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.default_value = {}
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.message_type = P_TIMEBOSS_DROPPED
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.type = 11
M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD.cpp_type = 10

M_TIMEBOSS_DROPPED_TOC.name = "m_timeboss_dropped_toc"
M_TIMEBOSS_DROPPED_TOC.full_name = ".m_timeboss_dropped_toc"
M_TIMEBOSS_DROPPED_TOC.nested_types = {}
M_TIMEBOSS_DROPPED_TOC.enum_types = {}
M_TIMEBOSS_DROPPED_TOC.fields = {M_TIMEBOSS_DROPPED_TOC_LOGS_FIELD}
M_TIMEBOSS_DROPPED_TOC.is_extendable = false
M_TIMEBOSS_DROPPED_TOC.extensions = {}
P_TIMEBOSS_ID_FIELD.name = "id"
P_TIMEBOSS_ID_FIELD.full_name = ".p_timeboss.id"
P_TIMEBOSS_ID_FIELD.number = 1
P_TIMEBOSS_ID_FIELD.index = 0
P_TIMEBOSS_ID_FIELD.label = 2
P_TIMEBOSS_ID_FIELD.has_default_value = false
P_TIMEBOSS_ID_FIELD.default_value = 0
P_TIMEBOSS_ID_FIELD.type = 5
P_TIMEBOSS_ID_FIELD.cpp_type = 1

P_TIMEBOSS_BORN_FIELD.name = "born"
P_TIMEBOSS_BORN_FIELD.full_name = ".p_timeboss.born"
P_TIMEBOSS_BORN_FIELD.number = 2
P_TIMEBOSS_BORN_FIELD.index = 1
P_TIMEBOSS_BORN_FIELD.label = 2
P_TIMEBOSS_BORN_FIELD.has_default_value = false
P_TIMEBOSS_BORN_FIELD.default_value = 0
P_TIMEBOSS_BORN_FIELD.type = 5
P_TIMEBOSS_BORN_FIELD.cpp_type = 1

P_TIMEBOSS_FLOOR_FIELD.name = "floor"
P_TIMEBOSS_FLOOR_FIELD.full_name = ".p_timeboss.floor"
P_TIMEBOSS_FLOOR_FIELD.number = 3
P_TIMEBOSS_FLOOR_FIELD.index = 2
P_TIMEBOSS_FLOOR_FIELD.label = 2
P_TIMEBOSS_FLOOR_FIELD.has_default_value = false
P_TIMEBOSS_FLOOR_FIELD.default_value = 0
P_TIMEBOSS_FLOOR_FIELD.type = 5
P_TIMEBOSS_FLOOR_FIELD.cpp_type = 1

P_TIMEBOSS_ROLE_FIELD.name = "role"
P_TIMEBOSS_ROLE_FIELD.full_name = ".p_timeboss.role"
P_TIMEBOSS_ROLE_FIELD.number = 4
P_TIMEBOSS_ROLE_FIELD.index = 3
P_TIMEBOSS_ROLE_FIELD.label = 2
P_TIMEBOSS_ROLE_FIELD.has_default_value = false
P_TIMEBOSS_ROLE_FIELD.default_value = 0
P_TIMEBOSS_ROLE_FIELD.type = 5
P_TIMEBOSS_ROLE_FIELD.cpp_type = 1

P_TIMEBOSS_BOX_FIELD.name = "box"
P_TIMEBOSS_BOX_FIELD.full_name = ".p_timeboss.box"
P_TIMEBOSS_BOX_FIELD.number = 5
P_TIMEBOSS_BOX_FIELD.index = 4
P_TIMEBOSS_BOX_FIELD.label = 2
P_TIMEBOSS_BOX_FIELD.has_default_value = false
P_TIMEBOSS_BOX_FIELD.default_value = false
P_TIMEBOSS_BOX_FIELD.type = 8
P_TIMEBOSS_BOX_FIELD.cpp_type = 7

P_TIMEBOSS_CARE_FIELD.name = "care"
P_TIMEBOSS_CARE_FIELD.full_name = ".p_timeboss.care"
P_TIMEBOSS_CARE_FIELD.number = 6
P_TIMEBOSS_CARE_FIELD.index = 5
P_TIMEBOSS_CARE_FIELD.label = 2
P_TIMEBOSS_CARE_FIELD.has_default_value = false
P_TIMEBOSS_CARE_FIELD.default_value = false
P_TIMEBOSS_CARE_FIELD.type = 8
P_TIMEBOSS_CARE_FIELD.cpp_type = 7

P_TIMEBOSS.name = "p_timeboss"
P_TIMEBOSS.full_name = ".p_timeboss"
P_TIMEBOSS.nested_types = {}
P_TIMEBOSS.enum_types = {}
P_TIMEBOSS.fields = {P_TIMEBOSS_ID_FIELD, P_TIMEBOSS_BORN_FIELD, P_TIMEBOSS_FLOOR_FIELD, P_TIMEBOSS_ROLE_FIELD, P_TIMEBOSS_BOX_FIELD, P_TIMEBOSS_CARE_FIELD}
P_TIMEBOSS.is_extendable = false
P_TIMEBOSS.extensions = {}
P_TIMEBOSS_RANKING_RANK_FIELD.name = "rank"
P_TIMEBOSS_RANKING_RANK_FIELD.full_name = ".p_timeboss_ranking.rank"
P_TIMEBOSS_RANKING_RANK_FIELD.number = 1
P_TIMEBOSS_RANKING_RANK_FIELD.index = 0
P_TIMEBOSS_RANKING_RANK_FIELD.label = 2
P_TIMEBOSS_RANKING_RANK_FIELD.has_default_value = false
P_TIMEBOSS_RANKING_RANK_FIELD.default_value = 0
P_TIMEBOSS_RANKING_RANK_FIELD.type = 5
P_TIMEBOSS_RANKING_RANK_FIELD.cpp_type = 1

P_TIMEBOSS_RANKING_IS_TEAM_FIELD.name = "is_team"
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.full_name = ".p_timeboss_ranking.is_team"
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.number = 2
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.index = 1
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.label = 2
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.has_default_value = false
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.default_value = false
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.type = 8
P_TIMEBOSS_RANKING_IS_TEAM_FIELD.cpp_type = 7

P_TIMEBOSS_RANKING_CAPTAIN_FIELD.name = "captain"
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.full_name = ".p_timeboss_ranking.captain"
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.number = 3
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.index = 2
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.label = 2
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.has_default_value = false
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.default_value = 0
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.type = 6
P_TIMEBOSS_RANKING_CAPTAIN_FIELD.cpp_type = 4

P_TIMEBOSS_RANKING_NAME_FIELD.name = "name"
P_TIMEBOSS_RANKING_NAME_FIELD.full_name = ".p_timeboss_ranking.name"
P_TIMEBOSS_RANKING_NAME_FIELD.number = 4
P_TIMEBOSS_RANKING_NAME_FIELD.index = 3
P_TIMEBOSS_RANKING_NAME_FIELD.label = 2
P_TIMEBOSS_RANKING_NAME_FIELD.has_default_value = false
P_TIMEBOSS_RANKING_NAME_FIELD.default_value = ""
P_TIMEBOSS_RANKING_NAME_FIELD.type = 9
P_TIMEBOSS_RANKING_NAME_FIELD.cpp_type = 9

P_TIMEBOSS_RANKING_DAMAGE_FIELD.name = "damage"
P_TIMEBOSS_RANKING_DAMAGE_FIELD.full_name = ".p_timeboss_ranking.damage"
P_TIMEBOSS_RANKING_DAMAGE_FIELD.number = 5
P_TIMEBOSS_RANKING_DAMAGE_FIELD.index = 4
P_TIMEBOSS_RANKING_DAMAGE_FIELD.label = 2
P_TIMEBOSS_RANKING_DAMAGE_FIELD.has_default_value = false
P_TIMEBOSS_RANKING_DAMAGE_FIELD.default_value = 0
P_TIMEBOSS_RANKING_DAMAGE_FIELD.type = 5
P_TIMEBOSS_RANKING_DAMAGE_FIELD.cpp_type = 1

P_TIMEBOSS_RANKING_TEAM_FIELD.name = "team"
P_TIMEBOSS_RANKING_TEAM_FIELD.full_name = ".p_timeboss_ranking.team"
P_TIMEBOSS_RANKING_TEAM_FIELD.number = 6
P_TIMEBOSS_RANKING_TEAM_FIELD.index = 5
P_TIMEBOSS_RANKING_TEAM_FIELD.label = 1
P_TIMEBOSS_RANKING_TEAM_FIELD.has_default_value = false
P_TIMEBOSS_RANKING_TEAM_FIELD.default_value = 0
P_TIMEBOSS_RANKING_TEAM_FIELD.type = 5
P_TIMEBOSS_RANKING_TEAM_FIELD.cpp_type = 1

P_TIMEBOSS_RANKING.name = "p_timeboss_ranking"
P_TIMEBOSS_RANKING.full_name = ".p_timeboss_ranking"
P_TIMEBOSS_RANKING.nested_types = {}
P_TIMEBOSS_RANKING.enum_types = {}
P_TIMEBOSS_RANKING.fields = {P_TIMEBOSS_RANKING_RANK_FIELD, P_TIMEBOSS_RANKING_IS_TEAM_FIELD, P_TIMEBOSS_RANKING_CAPTAIN_FIELD, P_TIMEBOSS_RANKING_NAME_FIELD, P_TIMEBOSS_RANKING_DAMAGE_FIELD, P_TIMEBOSS_RANKING_TEAM_FIELD}
P_TIMEBOSS_RANKING.is_extendable = false
P_TIMEBOSS_RANKING.extensions = {}
P_TIMEBOSS_DROPPED_TIME_FIELD.name = "time"
P_TIMEBOSS_DROPPED_TIME_FIELD.full_name = ".p_timeboss_dropped.time"
P_TIMEBOSS_DROPPED_TIME_FIELD.number = 1
P_TIMEBOSS_DROPPED_TIME_FIELD.index = 0
P_TIMEBOSS_DROPPED_TIME_FIELD.label = 2
P_TIMEBOSS_DROPPED_TIME_FIELD.has_default_value = false
P_TIMEBOSS_DROPPED_TIME_FIELD.default_value = 0
P_TIMEBOSS_DROPPED_TIME_FIELD.type = 5
P_TIMEBOSS_DROPPED_TIME_FIELD.cpp_type = 1

P_TIMEBOSS_DROPPED_SCENE_FIELD.name = "scene"
P_TIMEBOSS_DROPPED_SCENE_FIELD.full_name = ".p_timeboss_dropped.scene"
P_TIMEBOSS_DROPPED_SCENE_FIELD.number = 2
P_TIMEBOSS_DROPPED_SCENE_FIELD.index = 1
P_TIMEBOSS_DROPPED_SCENE_FIELD.label = 2
P_TIMEBOSS_DROPPED_SCENE_FIELD.has_default_value = false
P_TIMEBOSS_DROPPED_SCENE_FIELD.default_value = 0
P_TIMEBOSS_DROPPED_SCENE_FIELD.type = 5
P_TIMEBOSS_DROPPED_SCENE_FIELD.cpp_type = 1

P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.name = "picker_id"
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.full_name = ".p_timeboss_dropped.picker_id"
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.number = 3
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.index = 2
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.label = 2
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.has_default_value = false
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.default_value = 0
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.type = 6
P_TIMEBOSS_DROPPED_PICKER_ID_FIELD.cpp_type = 4

P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.name = "picker_name"
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.full_name = ".p_timeboss_dropped.picker_name"
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.number = 4
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.index = 3
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.label = 2
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.has_default_value = false
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.default_value = ""
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.type = 9
P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD.cpp_type = 9

P_TIMEBOSS_DROPPED_BOSS_FIELD.name = "boss"
P_TIMEBOSS_DROPPED_BOSS_FIELD.full_name = ".p_timeboss_dropped.boss"
P_TIMEBOSS_DROPPED_BOSS_FIELD.number = 5
P_TIMEBOSS_DROPPED_BOSS_FIELD.index = 4
P_TIMEBOSS_DROPPED_BOSS_FIELD.label = 2
P_TIMEBOSS_DROPPED_BOSS_FIELD.has_default_value = false
P_TIMEBOSS_DROPPED_BOSS_FIELD.default_value = ""
P_TIMEBOSS_DROPPED_BOSS_FIELD.type = 9
P_TIMEBOSS_DROPPED_BOSS_FIELD.cpp_type = 9

P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.name = "item_id"
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.full_name = ".p_timeboss_dropped.item_id"
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.number = 6
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.index = 5
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.label = 2
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.has_default_value = false
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.default_value = 0
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.type = 5
P_TIMEBOSS_DROPPED_ITEM_ID_FIELD.cpp_type = 1

P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.name = "cache_id"
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.full_name = ".p_timeboss_dropped.cache_id"
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.number = 7
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.index = 6
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.label = 2
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.has_default_value = false
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.default_value = 0
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.type = 5
P_TIMEBOSS_DROPPED_CACHE_ID_FIELD.cpp_type = 1

P_TIMEBOSS_DROPPED.name = "p_timeboss_dropped"
P_TIMEBOSS_DROPPED.full_name = ".p_timeboss_dropped"
P_TIMEBOSS_DROPPED.nested_types = {}
P_TIMEBOSS_DROPPED.enum_types = {}
P_TIMEBOSS_DROPPED.fields = {P_TIMEBOSS_DROPPED_TIME_FIELD, P_TIMEBOSS_DROPPED_SCENE_FIELD, P_TIMEBOSS_DROPPED_PICKER_ID_FIELD, P_TIMEBOSS_DROPPED_PICKER_NAME_FIELD, P_TIMEBOSS_DROPPED_BOSS_FIELD, P_TIMEBOSS_DROPPED_ITEM_ID_FIELD, P_TIMEBOSS_DROPPED_CACHE_ID_FIELD}
P_TIMEBOSS_DROPPED.is_extendable = false
P_TIMEBOSS_DROPPED.extensions = {}

m_timeboss_boxinfo_toc = protobuf.Message(M_TIMEBOSS_BOXINFO_TOC)
m_timeboss_boxinfo_tos = protobuf.Message(M_TIMEBOSS_BOXINFO_TOS)
m_timeboss_boxopen_toc = protobuf.Message(M_TIMEBOSS_BOXOPEN_TOC)
m_timeboss_boxopen_toc.RewardEntry = protobuf.Message(M_TIMEBOSS_BOXOPEN_TOC_REWARDENTRY)
m_timeboss_boxopen_tos = protobuf.Message(M_TIMEBOSS_BOXOPEN_TOS)
m_timeboss_care_toc = protobuf.Message(M_TIMEBOSS_CARE_TOC)
m_timeboss_care_tos = protobuf.Message(M_TIMEBOSS_CARE_TOS)
m_timeboss_dice_toc = protobuf.Message(M_TIMEBOSS_DICE_TOC)
m_timeboss_dicing_toc = protobuf.Message(M_TIMEBOSS_DICING_TOC)
m_timeboss_dicing_tos = protobuf.Message(M_TIMEBOSS_DICING_TOS)
m_timeboss_dropped_toc = protobuf.Message(M_TIMEBOSS_DROPPED_TOC)
m_timeboss_dropped_tos = protobuf.Message(M_TIMEBOSS_DROPPED_TOS)
m_timeboss_list_toc = protobuf.Message(M_TIMEBOSS_LIST_TOC)
m_timeboss_list_tos = protobuf.Message(M_TIMEBOSS_LIST_TOS)
m_timeboss_ranking_toc = protobuf.Message(M_TIMEBOSS_RANKING_TOC)
m_timeboss_ranking_tos = protobuf.Message(M_TIMEBOSS_RANKING_TOS)
m_timeboss_remind_toc = protobuf.Message(M_TIMEBOSS_REMIND_TOC)
p_timeboss = protobuf.Message(P_TIMEBOSS)
p_timeboss_dropped = protobuf.Message(P_TIMEBOSS_DROPPED)
p_timeboss_ranking = protobuf.Message(P_TIMEBOSS_RANKING)

