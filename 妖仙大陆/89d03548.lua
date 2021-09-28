
local protobuf = require "protobuf"
local common_pb = require("common_pb")
local item_pb = require("item_pb")
module('achievementHandler_pb')


ACHIEVEMENTGETTYPEELEMENTREQUEST = protobuf.Descriptor();
local ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD = protobuf.FieldDescriptor();
ACHIEVEMENTGETAWARDREQUEST = protobuf.Descriptor();
local ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD = protobuf.FieldDescriptor();
ACHIEVEMENT = protobuf.Descriptor();
local ACHIEVEMENT_ID_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENT_SCHEDULECURR_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENT_STATUS_FIELD = protobuf.FieldDescriptor();
ACHIEVEMENTGETTYPEELEMENTRESPONSE = protobuf.Descriptor();
local ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD = protobuf.FieldDescriptor();
ACHIEVEMENTGETAWARDRESPONSE = protobuf.Descriptor();
local ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
ONACHIEVEMENTPUSH = protobuf.Descriptor();
local ONACHIEVEMENTPUSH_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ONACHIEVEMENTPUSH_S2C_ID_FIELD = protobuf.FieldDescriptor();
local ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD = protobuf.FieldDescriptor();
HOLYARMOR = protobuf.Descriptor();
local HOLYARMOR_ID_FIELD = protobuf.FieldDescriptor();
local HOLYARMOR_STATES_FIELD = protobuf.FieldDescriptor();
GETHOLYARMORSREQUEST = protobuf.Descriptor();
GETHOLYARMORSRESPONSE = protobuf.Descriptor();
local GETHOLYARMORSRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local GETHOLYARMORSRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD = protobuf.FieldDescriptor();
ACTIVATEHOLYARMORREQUEST = protobuf.Descriptor();
local ACTIVATEHOLYARMORREQUEST_ID_FIELD = protobuf.FieldDescriptor();
ACTIVATEHOLYARMORRESPONSE = protobuf.Descriptor();
local ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();

ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.name = "c2s_id"
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementRequest.c2s_id"
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.number = 1
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.index = 0
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.label = 2
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.default_value = 0
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.type = 5
ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD.cpp_type = 1

ACHIEVEMENTGETTYPEELEMENTREQUEST.name = "AchievementGetTypeElementRequest"
ACHIEVEMENTGETTYPEELEMENTREQUEST.full_name = ".pomelo.area.AchievementGetTypeElementRequest"
ACHIEVEMENTGETTYPEELEMENTREQUEST.nested_types = {}
ACHIEVEMENTGETTYPEELEMENTREQUEST.enum_types = {}
ACHIEVEMENTGETTYPEELEMENTREQUEST.fields = {ACHIEVEMENTGETTYPEELEMENTREQUEST_C2S_ID_FIELD}
ACHIEVEMENTGETTYPEELEMENTREQUEST.is_extendable = false
ACHIEVEMENTGETTYPEELEMENTREQUEST.extensions = {}
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.name = "c2s_id"
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.full_name = ".pomelo.area.AchievementGetAwardRequest.c2s_id"
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.number = 1
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.index = 0
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.label = 2
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.has_default_value = false
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.default_value = 0
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.type = 5
ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD.cpp_type = 1

ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.name = "c2s_type"
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.full_name = ".pomelo.area.AchievementGetAwardRequest.c2s_type"
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.number = 2
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.index = 1
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.label = 2
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.has_default_value = false
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.default_value = 0
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.type = 5
ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD.cpp_type = 1

ACHIEVEMENTGETAWARDREQUEST.name = "AchievementGetAwardRequest"
ACHIEVEMENTGETAWARDREQUEST.full_name = ".pomelo.area.AchievementGetAwardRequest"
ACHIEVEMENTGETAWARDREQUEST.nested_types = {}
ACHIEVEMENTGETAWARDREQUEST.enum_types = {}
ACHIEVEMENTGETAWARDREQUEST.fields = {ACHIEVEMENTGETAWARDREQUEST_C2S_ID_FIELD, ACHIEVEMENTGETAWARDREQUEST_C2S_TYPE_FIELD}
ACHIEVEMENTGETAWARDREQUEST.is_extendable = false
ACHIEVEMENTGETAWARDREQUEST.extensions = {}
ACHIEVEMENT_ID_FIELD.name = "id"
ACHIEVEMENT_ID_FIELD.full_name = ".pomelo.area.Achievement.id"
ACHIEVEMENT_ID_FIELD.number = 1
ACHIEVEMENT_ID_FIELD.index = 0
ACHIEVEMENT_ID_FIELD.label = 2
ACHIEVEMENT_ID_FIELD.has_default_value = false
ACHIEVEMENT_ID_FIELD.default_value = 0
ACHIEVEMENT_ID_FIELD.type = 5
ACHIEVEMENT_ID_FIELD.cpp_type = 1

ACHIEVEMENT_SCHEDULECURR_FIELD.name = "scheduleCurr"
ACHIEVEMENT_SCHEDULECURR_FIELD.full_name = ".pomelo.area.Achievement.scheduleCurr"
ACHIEVEMENT_SCHEDULECURR_FIELD.number = 2
ACHIEVEMENT_SCHEDULECURR_FIELD.index = 1
ACHIEVEMENT_SCHEDULECURR_FIELD.label = 2
ACHIEVEMENT_SCHEDULECURR_FIELD.has_default_value = false
ACHIEVEMENT_SCHEDULECURR_FIELD.default_value = 0
ACHIEVEMENT_SCHEDULECURR_FIELD.type = 5
ACHIEVEMENT_SCHEDULECURR_FIELD.cpp_type = 1

ACHIEVEMENT_STATUS_FIELD.name = "status"
ACHIEVEMENT_STATUS_FIELD.full_name = ".pomelo.area.Achievement.status"
ACHIEVEMENT_STATUS_FIELD.number = 3
ACHIEVEMENT_STATUS_FIELD.index = 2
ACHIEVEMENT_STATUS_FIELD.label = 2
ACHIEVEMENT_STATUS_FIELD.has_default_value = false
ACHIEVEMENT_STATUS_FIELD.default_value = 0
ACHIEVEMENT_STATUS_FIELD.type = 5
ACHIEVEMENT_STATUS_FIELD.cpp_type = 1

ACHIEVEMENT.name = "Achievement"
ACHIEVEMENT.full_name = ".pomelo.area.Achievement"
ACHIEVEMENT.nested_types = {}
ACHIEVEMENT.enum_types = {}
ACHIEVEMENT.fields = {ACHIEVEMENT_ID_FIELD, ACHIEVEMENT_SCHEDULECURR_FIELD, ACHIEVEMENT_STATUS_FIELD}
ACHIEVEMENT.is_extendable = false
ACHIEVEMENT.extensions = {}
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementResponse.s2c_code"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.number = 1
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.index = 0
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.label = 2
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.default_value = 0
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.type = 5
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD.cpp_type = 1

ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementResponse.s2c_msg"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.number = 2
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.index = 1
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.label = 1
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.default_value = ""
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.type = 9
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD.cpp_type = 9

ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.name = "s2c_achievements"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementResponse.s2c_achievements"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.number = 3
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.index = 2
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.label = 3
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.default_value = {}
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.message_type = ACHIEVEMENT
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.type = 11
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD.cpp_type = 10

ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.name = "s2c_rewardCount"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementResponse.s2c_rewardCount"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.number = 4
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.index = 3
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.label = 1
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.default_value = 0
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.type = 5
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD.cpp_type = 1

ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.name = "s2c_reward_status"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementResponse.s2c_reward_status"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.number = 5
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.index = 4
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.label = 1
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.default_value = 0
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.type = 5
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD.cpp_type = 1

ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.name = "s2c_opened_chapter"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementResponse.s2c_opened_chapter"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.number = 6
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.index = 5
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.label = 3
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.default_value = {}
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.type = 5
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD.cpp_type = 1

ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.name = "s2c_chest_view"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.full_name = ".pomelo.area.AchievementGetTypeElementResponse.s2c_chest_view"
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.number = 7
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.index = 6
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.label = 3
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.has_default_value = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.default_value = {}
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.message_type = item_pb.MINIITEM
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.type = 11
ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD.cpp_type = 10

ACHIEVEMENTGETTYPEELEMENTRESPONSE.name = "AchievementGetTypeElementResponse"
ACHIEVEMENTGETTYPEELEMENTRESPONSE.full_name = ".pomelo.area.AchievementGetTypeElementResponse"
ACHIEVEMENTGETTYPEELEMENTRESPONSE.nested_types = {}
ACHIEVEMENTGETTYPEELEMENTRESPONSE.enum_types = {}
ACHIEVEMENTGETTYPEELEMENTRESPONSE.fields = {ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CODE_FIELD, ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_MSG_FIELD, ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_ACHIEVEMENTS_FIELD, ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARDCOUNT_FIELD, ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_REWARD_STATUS_FIELD, ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_OPENED_CHAPTER_FIELD, ACHIEVEMENTGETTYPEELEMENTRESPONSE_S2C_CHEST_VIEW_FIELD}
ACHIEVEMENTGETTYPEELEMENTRESPONSE.is_extendable = false
ACHIEVEMENTGETTYPEELEMENTRESPONSE.extensions = {}
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.AchievementGetAwardResponse.s2c_code"
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.number = 1
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.index = 0
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.label = 2
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.has_default_value = false
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.default_value = 0
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.type = 5
ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD.cpp_type = 1

ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.AchievementGetAwardResponse.s2c_msg"
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.number = 2
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.index = 1
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.label = 1
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.has_default_value = false
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.default_value = ""
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.type = 9
ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD.cpp_type = 9

ACHIEVEMENTGETAWARDRESPONSE.name = "AchievementGetAwardResponse"
ACHIEVEMENTGETAWARDRESPONSE.full_name = ".pomelo.area.AchievementGetAwardResponse"
ACHIEVEMENTGETAWARDRESPONSE.nested_types = {}
ACHIEVEMENTGETAWARDRESPONSE.enum_types = {}
ACHIEVEMENTGETAWARDRESPONSE.fields = {ACHIEVEMENTGETAWARDRESPONSE_S2C_CODE_FIELD, ACHIEVEMENTGETAWARDRESPONSE_S2C_MSG_FIELD}
ACHIEVEMENTGETAWARDRESPONSE.is_extendable = false
ACHIEVEMENTGETAWARDRESPONSE.extensions = {}
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.name = "s2c_code"
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.full_name = ".pomelo.area.OnAchievementPush.s2c_code"
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.number = 1
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.index = 0
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.label = 2
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.has_default_value = false
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.default_value = 0
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.type = 5
ONACHIEVEMENTPUSH_S2C_CODE_FIELD.cpp_type = 1

ONACHIEVEMENTPUSH_S2C_ID_FIELD.name = "s2c_id"
ONACHIEVEMENTPUSH_S2C_ID_FIELD.full_name = ".pomelo.area.OnAchievementPush.s2c_id"
ONACHIEVEMENTPUSH_S2C_ID_FIELD.number = 2
ONACHIEVEMENTPUSH_S2C_ID_FIELD.index = 1
ONACHIEVEMENTPUSH_S2C_ID_FIELD.label = 1
ONACHIEVEMENTPUSH_S2C_ID_FIELD.has_default_value = false
ONACHIEVEMENTPUSH_S2C_ID_FIELD.default_value = 0
ONACHIEVEMENTPUSH_S2C_ID_FIELD.type = 5
ONACHIEVEMENTPUSH_S2C_ID_FIELD.cpp_type = 1

ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.name = "s2c_achievements"
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.full_name = ".pomelo.area.OnAchievementPush.s2c_achievements"
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.number = 3
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.index = 2
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.label = 3
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.has_default_value = false
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.default_value = {}
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.message_type = ACHIEVEMENT
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.type = 11
ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD.cpp_type = 10

ONACHIEVEMENTPUSH.name = "OnAchievementPush"
ONACHIEVEMENTPUSH.full_name = ".pomelo.area.OnAchievementPush"
ONACHIEVEMENTPUSH.nested_types = {}
ONACHIEVEMENTPUSH.enum_types = {}
ONACHIEVEMENTPUSH.fields = {ONACHIEVEMENTPUSH_S2C_CODE_FIELD, ONACHIEVEMENTPUSH_S2C_ID_FIELD, ONACHIEVEMENTPUSH_S2C_ACHIEVEMENTS_FIELD}
ONACHIEVEMENTPUSH.is_extendable = false
ONACHIEVEMENTPUSH.extensions = {}
HOLYARMOR_ID_FIELD.name = "id"
HOLYARMOR_ID_FIELD.full_name = ".pomelo.area.HolyArmor.id"
HOLYARMOR_ID_FIELD.number = 1
HOLYARMOR_ID_FIELD.index = 0
HOLYARMOR_ID_FIELD.label = 2
HOLYARMOR_ID_FIELD.has_default_value = false
HOLYARMOR_ID_FIELD.default_value = 0
HOLYARMOR_ID_FIELD.type = 5
HOLYARMOR_ID_FIELD.cpp_type = 1

HOLYARMOR_STATES_FIELD.name = "states"
HOLYARMOR_STATES_FIELD.full_name = ".pomelo.area.HolyArmor.states"
HOLYARMOR_STATES_FIELD.number = 2
HOLYARMOR_STATES_FIELD.index = 1
HOLYARMOR_STATES_FIELD.label = 2
HOLYARMOR_STATES_FIELD.has_default_value = false
HOLYARMOR_STATES_FIELD.default_value = 0
HOLYARMOR_STATES_FIELD.type = 5
HOLYARMOR_STATES_FIELD.cpp_type = 1

HOLYARMOR.name = "HolyArmor"
HOLYARMOR.full_name = ".pomelo.area.HolyArmor"
HOLYARMOR.nested_types = {}
HOLYARMOR.enum_types = {}
HOLYARMOR.fields = {HOLYARMOR_ID_FIELD, HOLYARMOR_STATES_FIELD}
HOLYARMOR.is_extendable = false
HOLYARMOR.extensions = {}
GETHOLYARMORSREQUEST.name = "GetHolyArmorsRequest"
GETHOLYARMORSREQUEST.full_name = ".pomelo.area.GetHolyArmorsRequest"
GETHOLYARMORSREQUEST.nested_types = {}
GETHOLYARMORSREQUEST.enum_types = {}
GETHOLYARMORSREQUEST.fields = {}
GETHOLYARMORSREQUEST.is_extendable = false
GETHOLYARMORSREQUEST.extensions = {}
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.GetHolyArmorsResponse.s2c_code"
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.number = 1
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.index = 0
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.label = 2
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.has_default_value = false
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.default_value = 0
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.type = 5
GETHOLYARMORSRESPONSE_S2C_CODE_FIELD.cpp_type = 1

GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.GetHolyArmorsResponse.s2c_msg"
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.number = 2
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.index = 1
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.label = 1
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.has_default_value = false
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.default_value = ""
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.type = 9
GETHOLYARMORSRESPONSE_S2C_MSG_FIELD.cpp_type = 9

GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.name = "holyArmors"
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.full_name = ".pomelo.area.GetHolyArmorsResponse.holyArmors"
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.number = 3
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.index = 2
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.label = 3
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.has_default_value = false
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.default_value = {}
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.message_type = HOLYARMOR
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.type = 11
GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD.cpp_type = 10

GETHOLYARMORSRESPONSE.name = "GetHolyArmorsResponse"
GETHOLYARMORSRESPONSE.full_name = ".pomelo.area.GetHolyArmorsResponse"
GETHOLYARMORSRESPONSE.nested_types = {}
GETHOLYARMORSRESPONSE.enum_types = {}
GETHOLYARMORSRESPONSE.fields = {GETHOLYARMORSRESPONSE_S2C_CODE_FIELD, GETHOLYARMORSRESPONSE_S2C_MSG_FIELD, GETHOLYARMORSRESPONSE_HOLYARMORS_FIELD}
GETHOLYARMORSRESPONSE.is_extendable = false
GETHOLYARMORSRESPONSE.extensions = {}
ACTIVATEHOLYARMORREQUEST_ID_FIELD.name = "id"
ACTIVATEHOLYARMORREQUEST_ID_FIELD.full_name = ".pomelo.area.ActivateHolyArmorRequest.id"
ACTIVATEHOLYARMORREQUEST_ID_FIELD.number = 1
ACTIVATEHOLYARMORREQUEST_ID_FIELD.index = 0
ACTIVATEHOLYARMORREQUEST_ID_FIELD.label = 2
ACTIVATEHOLYARMORREQUEST_ID_FIELD.has_default_value = false
ACTIVATEHOLYARMORREQUEST_ID_FIELD.default_value = 0
ACTIVATEHOLYARMORREQUEST_ID_FIELD.type = 5
ACTIVATEHOLYARMORREQUEST_ID_FIELD.cpp_type = 1

ACTIVATEHOLYARMORREQUEST.name = "ActivateHolyArmorRequest"
ACTIVATEHOLYARMORREQUEST.full_name = ".pomelo.area.ActivateHolyArmorRequest"
ACTIVATEHOLYARMORREQUEST.nested_types = {}
ACTIVATEHOLYARMORREQUEST.enum_types = {}
ACTIVATEHOLYARMORREQUEST.fields = {ACTIVATEHOLYARMORREQUEST_ID_FIELD}
ACTIVATEHOLYARMORREQUEST.is_extendable = false
ACTIVATEHOLYARMORREQUEST.extensions = {}
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.ActivateHolyArmorResponse.s2c_code"
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.number = 1
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.index = 0
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.label = 2
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.has_default_value = false
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.default_value = 0
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.type = 5
ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD.cpp_type = 1

ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.ActivateHolyArmorResponse.s2c_msg"
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.number = 2
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.index = 1
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.label = 1
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.has_default_value = false
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.default_value = ""
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.type = 9
ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD.cpp_type = 9

ACTIVATEHOLYARMORRESPONSE.name = "ActivateHolyArmorResponse"
ACTIVATEHOLYARMORRESPONSE.full_name = ".pomelo.area.ActivateHolyArmorResponse"
ACTIVATEHOLYARMORRESPONSE.nested_types = {}
ACTIVATEHOLYARMORRESPONSE.enum_types = {}
ACTIVATEHOLYARMORRESPONSE.fields = {ACTIVATEHOLYARMORRESPONSE_S2C_CODE_FIELD, ACTIVATEHOLYARMORRESPONSE_S2C_MSG_FIELD}
ACTIVATEHOLYARMORRESPONSE.is_extendable = false
ACTIVATEHOLYARMORRESPONSE.extensions = {}

Achievement = protobuf.Message(ACHIEVEMENT)
AchievementGetAwardRequest = protobuf.Message(ACHIEVEMENTGETAWARDREQUEST)
AchievementGetAwardResponse = protobuf.Message(ACHIEVEMENTGETAWARDRESPONSE)
AchievementGetTypeElementRequest = protobuf.Message(ACHIEVEMENTGETTYPEELEMENTREQUEST)
AchievementGetTypeElementResponse = protobuf.Message(ACHIEVEMENTGETTYPEELEMENTRESPONSE)
ActivateHolyArmorRequest = protobuf.Message(ACTIVATEHOLYARMORREQUEST)
ActivateHolyArmorResponse = protobuf.Message(ACTIVATEHOLYARMORRESPONSE)
GetHolyArmorsRequest = protobuf.Message(GETHOLYARMORSREQUEST)
GetHolyArmorsResponse = protobuf.Message(GETHOLYARMORSRESPONSE)
HolyArmor = protobuf.Message(HOLYARMOR)
OnAchievementPush = protobuf.Message(ONACHIEVEMENTPUSH)
