local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ActivityRetrieveUtils = Lplus.Class(MODULE_NAME)
local Cls = ActivityRetrieveUtils
local def = Cls.define
def.static("userdata", "=>", "table").readLineData = function(record)
  if record == nil then
    return nil
  end
  local data = {}
  data.actId = record:GetIntValue("activityid")
  data.id = record:GetIntValue("id")
  data.gold = record:GetIntValue("gold")
  data.yuanbao = record:GetIntValue("yuanbao")
  data.freeItemid = record:GetIntValue("freeItemid")
  data.goldItemid = record:GetIntValue("goldItemid")
  data.yuanbaoItemid = record:GetIntValue("yuanbaoItemid")
  return data
end
def.static("=>", "table").LoadAllRetrieveActivity = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACT_RETRIEVE)
  if entries == nil then
    warn("[ERROR: Could not find file DATA_ACT_RETRIEVE cfg]")
    return retData
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = Cls.readLineData(record)
    table.insert(retData, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetRetrieveActivityById = function(actId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACT_RETRIEVE, actId)
  if record == nil then
    warn("[ERROR: Counld not find record in cfg DATA_ACT_RETRIEVE, activity ID:]" .. actId)
    return nil
  end
  local data = Cls.readLineData(record)
  return data
end
return Cls.Commit()
