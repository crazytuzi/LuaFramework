local Lplus = require("Lplus")
local TreasureHuntUtils = Lplus.Class("TreasureHuntUtils")
local def = TreasureHuntUtils.define
def.static("number", "=>", "table").GetTreasureHuntByActivityId = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TREASURE_HUNT_CFG, activityId)
  if nil == record then
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activity_cfg_id")
  cfg.featureId = record:GetIntValue("switch_type")
  cfg.npcId = record:GetIntValue("npc_id")
  cfg.npcServiceId = record:GetIntValue("npc_service_id")
  return cfg
end
def.static("number", "=>", "string").GetChapterTextById = function(chapterId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TREASURE_HUNT_CHAPTER_CFG, chapterId)
  if nil == record then
    warn("no chapter text by id: ", chapterId)
    return ""
  end
  return record:GetStringValue("chapter_name")
end
def.static("=>", "number").GetActivityId = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TREASURE_HUNT_CONSTS)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TREASURE_HUNT_CONSTS, "christmas_treasure_hunt_activity_cfg_id")
  if not record then
    warn("GetActivityId return nil")
    return 0
  end
  local activityId = DynamicRecord.GetIntValue(record, "value")
  return activityId
end
def.static("number", "number", "=>", "number").GetActivityIdByNpcIdAndServiceId = function(npcId, npcServiceId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_TREASURE_HUNT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityNpcId = record:GetIntValue("npc_id")
    local activityNpcServiceId = record:GetIntValue("npc_service_id")
    if activityNpcId == npcId and activityNpcServiceId == npcServiceId then
      local activityId = record:GetIntValue("activity_cfg_id")
      DynamicDataTable.FastGetRecordEnd(entrys)
      return activityId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("=>", "table").GetAllActivity = function()
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_TREASURE_HUNT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local data = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local cfg = {}
    cfg.activityId = record:GetIntValue("activity_cfg_id")
    cfg.featureId = record:GetIntValue("switch_type")
    cfg.npcId = record:GetIntValue("npc_id")
    cfg.npcServiceId = record:GetIntValue("npc_service_id")
    table.insert(data, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return data
end
def.static("=>", "table").GetTreasureHuntActivityIdAndIDIP = function()
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_TREASURE_HUNT_IDIP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local data = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local cfg = {}
    cfg.activityId = record:GetIntValue("activity_cfg_id")
    cfg.featureId = record:GetIntValue("switch_type")
    table.insert(data, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return data
end
def.static("number", "=>", "number").GetIDIPByNpcServiceId = function(npcServiceId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_TREASURE_HUNT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityNpcServiceId = record:GetIntValue("npc_service_id")
    if activityNpcServiceId == npcServiceId then
      local featureId = record:GetIntValue("switch_type")
      DynamicDataTable.FastGetRecordEnd(entrys)
      return featureId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("number", "=>", "boolean").IsTreasureHuntIDIP = function(feature)
  local activityIDIPCfg = TreasureHuntUtils.GetTreasureHuntActivityIdAndIDIP()
  for idx, cfg in pairs(activityIDIPCfg) do
    if cfg.featureId == feature then
      return true
    end
  end
  return false
end
TreasureHuntUtils.Commit()
return TreasureHuntUtils
