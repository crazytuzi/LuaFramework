local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangDungeonUtils = Lplus.Class(MODULE_NAME)
local def = GangDungeonUtils.define
def.const("number").DAY_OF_WEEK_BEGIN = 1
def.const("number").DAY_OF_WEEK_END = 7
local _constants
local function initConstants(...)
  _constants = {}
  if constant.CFactionPVEConsts then
    _constants.ACTIVITY_ID = constant.CFactionPVEConsts.Activityid
    _constants.ENTRY_NPC_ID = constant.CFactionPVEConsts.EnterNpc
    _constants.ENTER_DUNGEON_SERVICE_ID = constant.CFactionPVEConsts.EnterService
    _constants.PREPARE_MAP_ID = constant.CFactionPVEConsts.PrepareMap
    _constants.ACTIVITY_MAP_ID = constant.CFactionPVEConsts.FightMap
    if constant.CFactionPVEConsts.PrepareMinutes then
      _constants.PREPARE_SECONDS = constant.CFactionPVEConsts.PrepareMinutes * 60
    end
    for k, v in pairs(constant.CFactionPVEConsts) do
      _constants[k] = v
    end
  end
  local debug = false
  if debug then
    _constants.PREPARE_MAP_ID = 330000000
    _constants.ACTIVITY_MAP_ID = 330000013
  end
end
def.static("string", "=>", "dynamic").GetConstant = function(name)
  if _constants == nil then
    initConstants()
  end
  return _constants[name]
end
def.static("number", "=>", "table").GetMonsterGoalCfg = function(monsterId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_DUNGEON_MONSTER_GOAL_CFG, monsterId)
  if record == nil then
    warn("GetMonsterGoalCfg return nil for id: ", monsterId)
    return nil
  end
  return GangDungeonUtils._GetMonsterGoalCfg(record)
end
def.static("=>", "table").GetAllMonsterGoalCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_DUNGEON_MONSTER_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = GangDungeonUtils._GetMonsterGoalCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("userdata", "=>", "table")._GetMonsterGoalCfg = function(record)
  local cfg = {}
  cfg.monsterId = record:GetIntValue("monsterid")
  cfg.personGoal = record:GetIntValue("personGoal")
  cfg.factionGoal = record:GetIntValue("factionGoal")
  return cfg
end
def.static("number", "=>", "string").GetWDayName = function(wday)
  if wday > GangDungeonUtils.DAY_OF_WEEK_END or wday < GangDungeonUtils.DAY_OF_WEEK_BEGIN then
    return string.format("error wday(%d)", wday)
  end
  return textRes.activity[wday]
end
def.static("table", "=>", "string").ConvertOpenTime2Text = function(openTime)
  if openTime == nil then
    return textRes.GangDungeon[13]
  end
  local wdayName = GangDungeonUtils.GetWDayName(openTime.wday)
  local hourSinceWDay = openTime.hour
  local minuteSinceWDay = openTime.min
  local timeText = textRes.GangDungeon[8]:format(wdayName, hourSinceWDay, minuteSinceWDay)
  return timeText
end
def.static("number", "=>", "table").GetBossGoalCfg = function(bossId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_DUNGEON_BOSS_GOAL_CFG, bossId)
  if record == nil then
    warn("GetBossGoalCfg return nil for id: ", bossId)
    return nil
  end
  return GangDungeonUtils._GetBossGoalCfg(record)
end
def.static("=>", "table").GetAllBossGoalCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_DUNGEON_BOSS_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = GangDungeonUtils._GetBossGoalCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("userdata", "=>", "table")._GetBossGoalCfg = function(record)
  local cfg = {}
  cfg.bossId = record:GetIntValue("bossid")
  cfg.bossNumber = record:GetIntValue("bossNumber")
  cfg.awardid = record:GetIntValue("awardid")
  return cfg
end
def.static("number", "=>", "string").GetBossName = function(bossId)
  local PetInterface = require("Main.Pet.Interface")
  local monsterCfg = PetInterface.GetExplicitMonsterCfg(bossId)
  local bossName
  if monsterCfg then
    bossName = monsterCfg.name
  else
    bossName = "$" .. bossId
  end
  return bossName
end
return GangDungeonUtils.Commit()
