local Lplus = require("Lplus")
local InteractiveTaskUtils = Lplus.Class("InteractiveTaskUtils")
local def = InteractiveTaskUtils.define
def.static("number", "=>", "table").GetInteractiveTaskCfg = function(typeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_INTERACTIVE_TASK_CFG, typeId)
  if record == nil then
    warn(string.format("GetInteractiveTaskCfg(%d) return nil", typeId))
    return nil
  end
  local cfg = {}
  cfg.isSeq = record:GetCharValue("hasSeq") == 1
  cfg.graphs = {}
  local graphsStruct = record:GetStructValue("graphsStruct")
  local count = graphsStruct:GetVectorSize("graphs")
  for i = 1, count do
    local record = graphsStruct:GetVectorValueByIdx("graphs", i - 1)
    local graph = {}
    graph.graphId = record:GetIntValue("graphid")
    graph.name = record:GetStringValue("name")
    graph.iconId = record:GetIntValue("iconid") or 0
    table.insert(cfg.graphs, graph)
  end
  return cfg
end
def.static("number", "number", "=>", "table").GetInteractiveGraphCfg = function(typeId, graphId)
  local itaskCfg = InteractiveTaskUtils.GetInteractiveTaskCfg(typeId)
  if itaskCfg == nil then
    return nil
  end
  local cfg
  for i, v in ipairs(itaskCfg.graphs) do
    if v.graphId == graphId then
      cfg = v
      break
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetInteractiveTaskTypeCfg = function(typeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_INTERACTIVE_TYPE_TASK_CFG, typeId)
  if record == nil then
    warn(string.format("GetInteractiveTaskTypeCfg(%d) return nil", typeId))
    return nil
  end
  local cfg = {}
  cfg.mapId = record:GetIntValue("mapid")
  cfg.typeName = record:GetStringValue("typeName")
  cfg.commanderAppellation = record:GetStringValue("commanderName")
  cfg.executorAppellation = record:GetStringValue("executorName")
  cfg.costCurrencyType = record:GetIntValue("moneyType") or 0
  cfg.costCurrencyNum = record:GetIntValue("moneyNum") or 0
  cfg.effectId = record:GetIntValue("effectId")
  cfg.delaySeonds = record:GetIntValue("delaySeonds")
  return cfg
end
def.static("=>", "table").GetAllInteractiveTaskMaps = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_INTERACTIVE_TYPE_TASK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local maps = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = entry:GetIntValue("id")
    local mapid = entry:GetIntValue("mapid")
    maps[mapid] = id
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return maps
end
return InteractiveTaskUtils.Commit()
