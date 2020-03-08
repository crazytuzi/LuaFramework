local Lplus = require("Lplus")
local DungeonUtils = Lplus.Class("DungeonUtils")
local def = DungeonUtils.define
def.static("=>", "table").GetSingleDungeons = function()
  local DungenType = require("consts.mzm.gsp.instance.confbean.InstanceType")
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DUNGEON_CFG)
  if entries == nil then
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  print("GetSingleDungeons", count)
  local cfg = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local type = DynamicRecord.GetIntValue(entry, "type")
    print("type", type)
    if type == DungenType.SINGLE then
      local dungeon = {}
      dungeon.name = DynamicRecord.GetStringValue(entry, "name")
      dungeon.level = DynamicRecord.GetIntValue(entry, "level")
      dungeon.closeLevel = DynamicRecord.GetIntValue(entry, "closeLevel")
      dungeon.id = DynamicRecord.GetIntValue(entry, "id")
      table.insert(cfg, dungeon)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetDungeonCfg = function(dungeonId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CFG, dungeonId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.type = record:GetIntValue("type")
  cfg.image = record:GetIntValue("image")
  cfg.item = record:GetIntValue("item")
  cfg.level = record:GetIntValue("level")
  cfg.closeLevel = record:GetIntValue("closeLevel")
  cfg.memberCount = record:GetIntValue("memberCount")
  cfg.timeLimit = record:GetIntValue("timeLimit")
  cfg.finishLimit = record:GetIntValue("finishLimit")
  return cfg
end
def.static("number", "number", "=>", "table").GetOneSoloDungeonCfg = function(dungeonId, processId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOLOMISSON_CFG)
  if entries == nil then
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  local find = false
  DynamicDataTable.FastGetRecordBegin(entries)
  local lastMapId = 0
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfgDungeonId = DynamicRecord.GetIntValue(entry, "dungeonId")
    local cfgProcessId = DynamicRecord.GetIntValue(entry, "processid")
    local mapId = DynamicRecord.GetIntValue(entry, "mapId")
    if mapId and mapId ~= 0 then
      lastMapId = mapId
    end
    if cfgDungeonId == dungeonId and processId == cfgProcessId then
      cfg.id = DynamicRecord.GetIntValue(entry, "id")
      cfg.name = DynamicRecord.GetStringValue(entry, "name")
      cfg.desc = DynamicRecord.GetStringValue(entry, "desc")
      cfg.monsterId = DynamicRecord.GetIntValue(entry, "monsterId")
      cfg.type = DynamicRecord.GetIntValue(entry, "type")
      cfg.posX = DynamicRecord.GetIntValue(entry, "posX")
      cfg.posY = DynamicRecord.GetIntValue(entry, "posY")
      cfg.sao_dang_item_num = DynamicRecord.GetIntValue(entry, "sao_dang_item_num")
      cfg.dungeonId = dungeonId
      cfg.processid = processId
      cfg.mapId = lastMapId
      find = true
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if find then
    return cfg
  end
  return nil
end
def.static("number", "=>", "table").GetSoloDungeonCfg = function(dungeonId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOLOMISSON_CFG)
  if entries == nil then
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfgDungeonId = DynamicRecord.GetIntValue(entry, "dungeonId")
    if cfgDungeonId == dungeonId then
      local mission = {}
      mission.id = DynamicRecord.GetIntValue(entry, "id")
      mission.name = DynamicRecord.GetStringValue(entry, "name")
      mission.desc = DynamicRecord.GetStringValue(entry, "desc")
      mission.dungeonId = cfgDungeonId
      mission.monsterId = DynamicRecord.GetIntValue(entry, "monsterId")
      mission.processId = DynamicRecord.GetIntValue(entry, "processid")
      mission.type = DynamicRecord.GetIntValue(entry, "type")
      mission.posX = DynamicRecord.GetIntValue(entry, "posX")
      mission.posY = DynamicRecord.GetIntValue(entry, "posY")
      mission.sao_dang_item_num = DynamicRecord.GetIntValue(entry, "sao_dang_item_num")
      cfg[mission.processId] = mission
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
local DungeonConst
def.static("=>", "table").GetDungeonConst = function()
  if DungeonConst then
    return DungeonConst
  end
  DungeonConst = {}
  DungeonConst.FailTimeAll = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "SINGLE_INSTANCE_FAIL_TIMES"):GetIntValue("value")
  DungeonConst.SaoDangQuanId = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "SAO_DAO_ITEM_ID"):GetIntValue("value")
  DungeonConst.SaoDangLimit = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "FINISH_TIME_CAN_SAO_DANG"):GetIntValue("value")
  DungeonConst.SoloServiceNpc = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "SINGLG_NPCid"):GetIntValue("value")
  DungeonConst.TeamServiceNpc = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "MULTI_NPCid"):GetIntValue("value")
  DungeonConst.RollTime = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "ROLL_ITEM_SECOND"):GetIntValue("value")
  DungeonConst.ConfirmTime = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "WAIT_TEAM_MEMBER_TIME"):GetIntValue("value")
  DungeonConst.SoloDungeonActivityId = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "SINGLE_INSTANCE_ACTIVITY_TYPE_ID"):GetIntValue("value")
  DungeonConst.TipsId = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "SINGLE_INSTANCE_TIPS_ID"):GetIntValue("value")
  DungeonConst.EffectId = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_CONST, "SINGLE_INSTANCE_SAO_DANG_EFFECT_ID"):GetIntValue("value")
  return DungeonConst
end
def.static("number", "=>", "table").GetDungeonMonsterCfg = function(monsterId)
  local soloMonsterCfg = DynamicData.GetRecord(CFG_PATH.DATA_DUNGEON_MONSTER_CFG, monsterId)
  if soloMonsterCfg == nil then
    return nil
  end
  local cfg = {}
  cfg.id = soloMonsterCfg:GetIntValue("id")
  cfg.name = soloMonsterCfg:GetStringValue("name")
  cfg.title = soloMonsterCfg:GetStringValue("title")
  cfg.talk = soloMonsterCfg:GetStringValue("talk")
  cfg.attackOptionTalk = soloMonsterCfg:GetStringValue("attackOptionTalk")
  cfg.notAttackOptionTalk = soloMonsterCfg:GetStringValue("notAttackOptionTalk")
  cfg.modelId = soloMonsterCfg:GetIntValue("monsterId")
  cfg.modelColorId = soloMonsterCfg:GetIntValue("modelColorId")
  cfg.modelFigureId = soloMonsterCfg:GetIntValue("modelFigureId")
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, cfg.modelId)
  if modelRecord then
    cfg.headIcon = modelRecord:GetIntValue("headerIconId")
    cfg.halfIcon = modelRecord:GetIntValue("halfBodyIconId")
  else
    warn("modelRecord not found for monster: ", monsterId)
  end
  return cfg
end
def.static("number", "=>", "table").GetTeamDungeonCfg = function(dungeonId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TEAM_DUNGEON_CFG, dungeonId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.type = record:GetIntValue("type")
  cfg.desc = record:GetStringValue("desc")
  cfg.activityid = record:GetIntValue("activityid")
  cfg.teamPlatformid = record:GetIntValue("teamPlatformid")
  cfg.items = {}
  local awards = record:GetStructValue("AwardStruct")
  local size = awards:GetVectorSize("ItemVector")
  for i = 0, size - 1 do
    local item = awards:GetVectorValueByIdx("ItemVector", i)
    local itemId = item:GetIntValue("itemId")
    table.insert(cfg.items, itemId)
  end
  return cfg
end
local activityIdToTeamDungeonId
def.static("=>", "table").ActivityIdToTeamDungeonId = function()
  if activityIdToTeamDungeonId == nil then
    local entries = DynamicData.GetTable(CFG_PATH.DATA_TEAM_DUNGEON_CFG)
    if entries == nil then
      return {}
    end
    local count = DynamicDataTable.GetRecordsCount(entries)
    local cfg = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local dungeonType = DynamicRecord.GetIntValue(entry, "type")
      local dungeonId = DynamicRecord.GetIntValue(entry, "id")
      local activityId = DynamicRecord.GetIntValue(entry, "activityid")
      cfg[activityId] = {dungeonType, dungeonId}
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    activityIdToTeamDungeonId = cfg
  end
  return activityIdToTeamDungeonId
end
def.static("number", "=>", "table").GetDungeonByType = function(type)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TEAM_DUNGEON_CFG)
  if entries == nil then
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfgType = DynamicRecord.GetIntValue(entry, "type")
    if cfgType == type then
      local mission = {}
      mission.id = DynamicRecord.GetIntValue(entry, "id")
      mission.type = cfgType
      mission.activityid = DynamicRecord.GetIntValue(entry, "activityid")
      table.insert(cfg, mission)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "=>", "number").CountTeamDungeonProcess = function(dungeonId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TEAM_DUNGEON_PROCESS_CFG)
  if entries == nil then
    return 0
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local size = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfgDungeonId = DynamicRecord.GetIntValue(entry, "dungeonId")
    if cfgDungeonId == dungeonId then
      size = size + 1
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return size
end
def.static("number", "number", "=>", "table").GetTeamDungeonProcessCfg = function(dungeonId, processId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TEAM_DUNGEON_PROCESS_CFG)
  if entries == nil then
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  local find = false
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfgDungeonId = DynamicRecord.GetIntValue(entry, "dungeonId")
    local cfgProcessId = DynamicRecord.GetIntValue(entry, "processId")
    if cfgDungeonId == dungeonId and processId == cfgProcessId then
      cfg.id = DynamicRecord.GetIntValue(entry, "id")
      cfg.title = DynamicRecord.GetStringValue(entry, "title")
      cfg.desc = DynamicRecord.GetStringValue(entry, "desc")
      cfg.dungeonId = dungeonId
      cfg.processid = processId
      find = true
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if find then
    return cfg
  end
  return nil
end
def.static("number", "=>", "table").GetSoloDungeonSaoDangCfg = function(soloDungeonId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOLOMISSON_SAODANG_CFG, soloDungeonId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.instanceid = soloDungeonId
  cfg.sao_dang_open_process_id = record:GetIntValue("sao_dang_open_process_id")
  cfg.sao_dang_reserve_process_num = record:GetIntValue("sao_dang_reserve_process_num")
  cfg.cost_item_id = record:GetIntValue("cost_item_id")
  return cfg
end
DungeonUtils.Commit()
return DungeonUtils
