local Lplus = require("Lplus")
local MemoryCompetitionUtils = Lplus.Class("MemoryCompetitionUtils")
local def = MemoryCompetitionUtils.define
def.static("number", "=>", "table").GetMemoryCompetionByActivityId = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MEMORY_ACTIVITY_CFG, activityId)
  if nil == record then
    warn("not memorycompetition activity", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activity_cfg_id")
  cfg.featureId = record:GetIntValue("idip_switch_id")
  cfg.npcId = record:GetIntValue("npc_id")
  cfg.npcServiceId = record:GetIntValue("npc_service_id")
  cfg.memoryCompetitionList = {}
  local memoryStruct = record:GetStructValue("memoryStruct")
  local vectorCount = DynamicRecord.GetVectorSize(memoryStruct, "memoryList")
  for i = 0, vectorCount - 1 do
    local memoryRecord = DynamicRecord.GetVectorValueByIdx(memoryStruct, "memoryList", i)
    local cfgId = memoryRecord:GetIntValue("memory_competition_cfg_id")
    table.insert(cfg.memoryCompetitionList, cfgId)
  end
  return cfg
end
def.static("number", "number", "=>", "number").GetActivityIdByNpcIdAndServiceId = function(npcId, npcServiceId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_MEMORY_ACTIVITY_CFG)
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
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_MEMORY_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local data = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local cfg = {}
    cfg.activityId = record:GetIntValue("activity_cfg_id")
    cfg.featureId = record:GetIntValue("idip_switch_id")
    cfg.npcId = record:GetIntValue("npc_id")
    cfg.npcServiceId = record:GetIntValue("npc_service_id")
    table.insert(data, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return data
end
def.static("number", "=>", "number").GetIDIPByNpcServiceId = function(npcServiceId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_MEMORY_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityNpcServiceId = record:GetIntValue("npc_service_id")
    if activityNpcServiceId == npcServiceId then
      local featureId = record:GetIntValue("idip_switch_id")
      DynamicDataTable.FastGetRecordEnd(entrys)
      return featureId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("=>", "table").GetMemoryCompetitionActivityIdAndIDIP = function()
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_MEMORY_COMPETITION_IDIP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local data = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local cfg = {}
    cfg.activityId = record:GetIntValue("activity_cfg_id")
    cfg.featureId = record:GetIntValue("idip_switch_id")
    table.insert(data, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return data
end
def.static("number", "=>", "boolean").IsMemoryCompetitionIDIP = function(feature)
  local activityIDIPCfg = MemoryCompetitionUtils.GetMemoryCompetitionActivityIdAndIDIP()
  for idx, cfg in pairs(activityIDIPCfg) do
    if cfg.featureId == feature then
      return true
    end
  end
  return false
end
MemoryCompetitionUtils.Commit()
return MemoryCompetitionUtils
