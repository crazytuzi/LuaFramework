local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local FirstModule = Lplus.Extend(ModuleBase, "FirstModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local def = FirstModule.define
local instance
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local TaskInterface = require("Main.task.TaskInterface")
def.static("=>", FirstModule).Instance = function()
  if instance == nil then
    instance = FirstModule()
    instance.m_moduleId = ModuleId.FIRST
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  self:LoadBaotuTaskConsts()
  self:LoadBountyHunterConsts()
  self:LoadCircleTaskConsts()
  self:LoadGangMiFangConsts()
  self:LoadHuanhunConsts()
  self:LoadHuSongConst()
  self:LoadImagePvpConsts()
  self:LoadLuanshiYaomoConsts()
  self:LoadLeaderBattleConsts()
  self:LoadPartnerConsts()
  self:LoadShimenTaskConsts()
  self:LoadTaskConst()
  self:LoadZhendyaoTaskConsts()
  self:LoadGangBattleConsts()
  activityInterface:Init()
end
def.method().LoadCircleTaskConsts = function(self)
  local circleConstsTable = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TASK_CIRCLE_CONST)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    circleConstsTable[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.Circle_TASK_GRAPHIC_ID = circleConstsTable.TASK_GRAPHIC_ID
  ActivityInterface.Circle_TASK_ACTIVITY_ID = circleConstsTable.TASK_ACTIVITY_ID
  ActivityInterface.Circle_START_TASK_NEED_SILVER = circleConstsTable.START_TASK_NEED_SILVER
  ActivityInterface.Circle_CALL_GANG_HELP_COOLDOWN_SECOND = circleConstsTable.CALL_GANG_HELP_COOLDOWN_SECOND
  ActivityInterface.Circle_LEGEND_TASK_MINUTE = circleConstsTable.LEGEND_TASK_MINUTE
  ActivityInterface.Circle_AWARD_TYPE_ID = circleConstsTable.AWARD_TYPE_ID
  ActivityInterface.Circle_ACCEPT_NPC_ID = circleConstsTable.ACCEPT_NPC_ID
  ActivityInterface.Circle_AWARD_VIGOR_ID = circleConstsTable.AWARD_VIGOR_ID
  ActivityInterface.Circle_AWARD_VIGOR_WEEK_COUNT = circleConstsTable.AWARD_VIGOR_WEEK_COUNT
end
def.method().LoadShimenTaskConsts = function(self)
  local shimenConstsTable = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SHIMEN_CONST)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    shimenConstsTable[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.SHIMEN_ACTIVITY_ID = shimenConstsTable.ACTIVITYID
  ActivityInterface.SHIMEN_GUIWANG_NPC_ID = shimenConstsTable.GUIWANG_NPC_ID
  ActivityInterface.SHIMEN_GUIWANG_GRAPH_ID = shimenConstsTable.GUIWANG_GRAPH_ID
  ActivityInterface.SHIMEN_QINGYUN_NPC_ID = shimenConstsTable.QINGYUN_NPC_ID
  ActivityInterface.SHIMEN_QINGYUN_GRAPH_ID = shimenConstsTable.QINGYUN_GRAPH_ID
  ActivityInterface.SHIMEN_TIANYIN_NPC_ID = shimenConstsTable.TIANYIN_NPC_ID
  ActivityInterface.SHIMEN_TIANYIN_GRAPH_ID = shimenConstsTable.TIANYIN_GRAPH_ID
  ActivityInterface.SHIMEN_FENXIANG_NPC_ID = shimenConstsTable.FENXIANG_NPC_ID
  ActivityInterface.SHIMEN_FENXIANG_GRAPH_ID = shimenConstsTable.FENXIANG_GRAPH_ID
  ActivityInterface.SHIMEN_HEHUAN_NPC_ID = shimenConstsTable.HEHUAN_NPC_ID
  ActivityInterface.SHIMEN_HEHUAN_GRAPH_ID = shimenConstsTable.HEHUAN_GRAPH_ID
  ActivityInterface.SHIMEN_SHENGWU_NPC_ID = shimenConstsTable.SHENGWU_NPC_ID
  ActivityInterface.SHIMEN_SHENGWU_GRAPH_ID = shimenConstsTable.SHENGWU_GRAPH_ID
  ActivityInterface.SHIMEN_REWARD_ID = shimenConstsTable.REWARD_ID
  ActivityInterface.SHIMEN_IS_AUTO_ACCEPT = shimenConstsTable.IS_AUTO_ACCEPT
  ActivityInterface.SHIMEN_DAY_TOTAL_COUNT = shimenConstsTable.DAY_TOTAL_COUNT
  ActivityInterface.SHIMEN_WEEK_PERFECT_CIRCLE_COUNT = shimenConstsTable.WEEK_PERFECT_CIRCLE_COUNT
  ActivityInterface.SHIMEN_DAY_PERFECT_CIRCLE_COUNT = shimenConstsTable.DAY_PERFECT_CIRCLE_COUNT
  ActivityInterface.SHIMEN_DAY_PERFECT_CIRCLE_REWARD_ID = shimenConstsTable.DAY_PERFECT_CIRCLE_REWARD_ID
  ActivityInterface.SHIMEN_WEEK_PERFECT_CIRCLE_REWARD_ID = shimenConstsTable.WEEK_PERFECT_CIRCLE_REWARD_ID
end
def.method().LoadBaotuTaskConsts = function(self)
  local baotuConstsTable = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BAOTU_ACTIVITY_CONST)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    baotuConstsTable[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.BAOTU_ACTIVITY_ID = baotuConstsTable.ACTIVITYID
  ActivityInterface.BAOTU_GRAPH_ID = baotuConstsTable.GRAPH_ID
  ActivityInterface.BAOTU_NPC_ID = baotuConstsTable.NPC_ID
  ActivityInterface.BAOTU_REWARDID1 = baotuConstsTable.REWARDID1
  ActivityInterface.BAOTU_AWARDRATE1 = baotuConstsTable.AWARDRATE1
  ActivityInterface.BAOTU_REWARDID2 = baotuConstsTable.REWARDID2
  ActivityInterface.BAOTU_AWARDRATE2 = baotuConstsTable.AWARDRATE2
  ActivityInterface.BAOTU_MAX_AWARD_COUNT = baotuConstsTable.MAX_AWARD_COUNT
end
def.method().LoadZhendyaoTaskConsts = function(self)
  local zhenyaoConstsTable = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ZHENYAO_ACTIVITY_CONST)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    zhenyaoConstsTable[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.ZhenYao_ACTIVITY_ID = zhenyaoConstsTable.ACTIVITYID
  ActivityInterface.ZhenYao_GRAPH_ID = zhenyaoConstsTable.GRAPH_ID
  ActivityInterface.ZhenYao_NPC_ID = zhenyaoConstsTable.NPC_ID
  ActivityInterface.ZhenYao_REWARDID = zhenyaoConstsTable.REWARDID
  ActivityInterface.ZhenYao_MAX_AWARD_COUNT = zhenyaoConstsTable.MAX_AWARD_COUNT
  ActivityInterface.ZhenYao_FIGHT_DEC_DOUBLE_POINT = zhenyaoConstsTable.FIGHT_DEC_DOUBLE_POINT
  ActivityInterface.ZhenYao_MAX_LEVEL_DELTA = zhenyaoConstsTable.MAX_LEVEL_DELTA
  ActivityInterface.ZhenYao_MUSIC_TIP_FOR_LEADER = zhenyaoConstsTable.MUSIC_TIP_FOR_LEADER
  ActivityInterface.ZhenYao_MIN_DOUBLE_POINT_TIP = zhenyaoConstsTable.MIN_DOUBLE_POINT_TIP
end
def.method().LoadPartnerConsts = function(self)
  local partnerConsts = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PARTNER_CONST)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    partnerConsts[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local PartnerInterface = require("Main.partner.PartnerInterface")
  PartnerInterface.Partner_OPEN_LEVEL = partnerConsts.OPEN_LEVEL
  PartnerInterface.Partner_ITEM_ID = partnerConsts.ITEM_ID
  PartnerInterface.Partner_ITEM_TYPE_ID = partnerConsts.ITEM_TYPE_ID
  PartnerInterface.Partner_FIGHT_NUM = partnerConsts.FIGHT_NUM
  PartnerInterface.Partner_WASHGOLD_NUM = partnerConsts.WASHGOLD_NUM
end
def.method().LoadHuanhunConsts = function(self)
  local huanhunConsts = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HUANHUN_CONST)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    huanhunConsts[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.HUANHUN_ACTIVITYID = huanhunConsts.ACTIVITYID
  ActivityInterface.HUANHUN_NPC_ID = huanhunConsts.NPC_ID
  ActivityInterface.HUANHUN_TASK_TIME_LIMIT = huanhunConsts.TASK_TIME_LIMIT
  ActivityInterface.HUANHUN_TASK_GRAPH_ID = huanhunConsts.TASK_GRAPH_ID
  ActivityInterface.HUANHUN_AWARD_ITEM_ID = huanhunConsts.AWARD_ITEM_ID
  ActivityInterface.HUANHUN_AWARD_ITEM_NUM = huanhunConsts.AWARD_ITEM_NUM
  ActivityInterface.HUANHUN_FLUSH_TIME = huanhunConsts.FLUSH_TIME
  ActivityInterface.HUANHUN_HUOLI_AWARD_ID = huanhunConsts.HUOLI_AWARD_ID
  ActivityInterface.HUANHUN_HUOLI_AWARD_COUNT = huanhunConsts.HUOLI_AWARD_COUNT
  ActivityInterface.HUANHUN_XIULIAN_RATE_LOW = huanhunConsts.XIULIAN_RATE_LOW
  ActivityInterface.HUANHUN_XIULIAN_RATE_HIGH = huanhunConsts.XIULIAN_RATE_HIGH
  ActivityInterface.HUANHUN_NEED_SILVER_PER_XIULIAN = huanhunConsts.NEED_SILVER_PER_XIULIAN
  ActivityInterface.HUANHUN_XIULIAN_PER_ITEM_LOW = huanhunConsts.XIULIAN_PER_ITEM_LOW
  ActivityInterface.HUANHUN_SEEK_HELP_NUM = huanhunConsts.SEEK_HELP_NUM
  ActivityInterface.HUANHUN_HELP_OTHER_NUM = huanhunConsts.HELP_OTHER_NUM
  ActivityInterface.HUANHUN_FULL_BOX_NUM_BEFORE_SEEK_HRLP = huanhunConsts.FULL_BOX_NUM_BEFORE_SEEK_HRLP
end
def.method().LoadLuanshiYaomoConsts = function(self)
  local consts = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DEAMON_FIGHT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    consts[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.LUANSHI_ACTIVITYID = consts.ACTIVITYID
  ActivityInterface.LUANSHI_VISIBLE_MONSTER_ID1 = consts.VISIBLE_MONSTER_ID1
  ActivityInterface.LUANSHI_VISIBLE_MONSTER_ID2 = consts.VISIBLE_MONSTER_ID2
  ActivityInterface.LUANSHI_REWARD_LIMIT = consts.REWARD_LIMIT
end
def.method().LoadBountyHunterConsts = function(self)
  local consts = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BOUNTY_CONSTS)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    consts[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.BOUNTYHUNTER_ACTIVITYID = consts.ACTIVITYID
  ActivityInterface.BOUNTYHUNTER_NPC_ID = consts.NPC_ID
  ActivityInterface.BOUNTYHUNTER_TASK_GRAPH_ID_1 = consts.TASK_GRAPH_ID_1
  ActivityInterface.BOUNTYHUNTER_TASK_GRAPH_ID_2 = consts.TASK_GRAPH_ID_2
  ActivityInterface.BOUNTYHUNTER_TASK_GRAPH_ID_3 = consts.TASK_GRAPH_ID_3
  ActivityInterface.BOUNTYHUNTER_TASK_GRAPH_ID_4 = consts.TASK_GRAPH_ID_4
  ActivityInterface.BOUNTYHUNTER_DAY_UPPER_LIMIT = consts.DAY_UPPER_LIMIT
  ActivityInterface.BOUNTYHUNTER_FLUSH_ITEM_ID = consts.FLUSH_ITEM_ID
end
def.method().LoadGangMiFangConsts = function(self)
  local consts = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_MIFANG_CONST_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    consts[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.GANGMIFANG_NEED_YAODIAN_LEVEL = consts.NEED_YAODIAN_LEVEL
  ActivityInterface.GANGMIFANG_NEED_LIVELY_LOW_RATE = consts.NEED_LIVELY_LOW_RATE
  ActivityInterface.GANGMIFANG_OPEN_DURATION = consts.OPEN_DURATION
  ActivityInterface.GANGMIFANG_NEED_MATERIAL_NUM = consts.NEED_MATERIAL_NUM
  ActivityInterface.GANGMIFANG_LIAYO_SKILL_BAG_ID = consts.LIAYO_SKILL_BAG_ID
  ActivityInterface.GANGMIFANG_NPC_ID = consts.NPC_ID
  ActivityInterface.GANGMIFANG_TASK_GRAPH_ID = consts.TASK_GRAPH_ID
  ActivityInterface.GANGMIFANG_TASK_ID = consts.TASK_ID
end
def.method().LoadImagePvpConsts = function(self)
  local record = DynamicData.GetRecord("data/cfg/mzm.gsp.activity.confbean.JingjiActivityCfgConsts.bny", "ACTIVITYID")
  if record == nil then
    return
  end
  ActivityInterface.IMAGE_PVP = record:GetIntValue("value")
end
def.method().LoadLeaderBattleConsts = function(self)
  local record = DynamicData.GetRecord("data/cfg/mzm.gsp.menpaipvp.confbean.CMenpaiPVPConsts.bny", "Activityid")
  if record == nil then
    return
  end
  ActivityInterface.LEADER_BATTLE = record:GetIntValue("value")
end
def.method().LoadGangBattleConsts = function(self)
  local record = DynamicData.GetRecord("data/cfg/mzm.gsp.competition.confbean.CCompetitionConsts.bny", "Activityid")
  if record == nil then
    return
  end
  ActivityInterface.GANG_BATTLE_ACTIVITYID = record:GetIntValue("value")
end
def.method().LoadHuSongConst = function(self)
  local consts = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_CHuSongConst)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    consts[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  ActivityInterface.CONVOY_ACTIVITY_ID = consts.activity
  ActivityInterface.CONVOY_NPCID = consts.npcid
  ActivityInterface.CONVOY_SPECIALNUM = consts.specialNum
end
def.method().LoadTaskConst = function(self)
  local consts = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TASK_CONST)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local key = DynamicRecord.GetStringValue(entry, "name")
    local value = DynamicRecord.GetIntValue(entry, "value")
    consts[key] = value
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  TaskInterface.TaskFightWaitTime = consts.ENTER_FIGHT_WAITING_TIME
end
FirstModule.Commit()
return FirstModule
