local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local JZJXUtils = Lplus.Class(CUR_CLASS_NAME)
local def = JZJXUtils.define
local instance
def.static("=>", JZJXUtils).Instance = function()
  if instance == nil then
    instance = JZJXUtils()
  end
  return instance
end
def.static("string", "=>", "number").GetConstant = function(key)
  local value = _G.constant.CJueZhanJiuXiaoConsts[key]
  if value == nil then
    warn("JZJXUtils.GetConstant(" .. key .. ") return nil")
    return 0
  end
  return value
end
def.static("=>", "table", "table").LoadActivityCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_JZJX_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  local mapIdToCfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.layer = record:GetIntValue("floor")
    cfg.mapId = record:GetIntValue("mapid")
    cfg.bossNPCId = record:GetIntValue("bossNPC")
    local npcidsStruct = record:GetStructValue("npcidsStruct")
    local count = npcidsStruct:GetVectorSize("npcids")
    cfg.npcIdList = {}
    for i = 1, count do
      local npcidRecord = npcidsStruct:GetVectorValueByIdx("npcids", i - 1)
      local npcid = npcidRecord:GetIntValue("npcid")
      table.insert(cfg.npcIdList, npcid)
    end
    cfgs[cfg.id] = cfg
    mapIdToCfg[cfg.mapId] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs, mapIdToCfg
end
def.static("number", "=>", "table").GetJZJXActivityCfg = function(cfgid)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_JZJX_CFG, cfgid)
  if record == nil then
    return
  end
  local cfg = JZJXUtils._GetJZJXActivityCfg(record)
  return cfg
end
def.static("userdata", "=>", "table")._GetJZJXActivityCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.layer = record:GetIntValue("floor")
  cfg.mapId = record:GetIntValue("mapid")
  cfg.bossNPCId = record:GetIntValue("bossNPC")
  local npcidsStruct = record:GetStructValue("npcidsStruct")
  local count = npcidsStruct:GetVectorSize("npcids")
  cfg.npcIdList = {}
  for i = 1, count do
    local npcidRecord = npcidsStruct:GetVectorValueByIdx("npcids", i - 1)
    local npcid = npcidRecord:GetIntValue("npcid")
    table.insert(cfg.npcIdList, npcid)
  end
  return cfg
end
def.static("=>", "table").GetAllJZJXActivityInfos = function()
  local cfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_JZJX_ACTIVITY_INFO_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = JZJXUtils._GetJZJXActivityInfo(record)
    cfgs[cfg.activityid] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetJZJXActivityInfo = function(activityid)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_JZJX_ACTIVITY_INFO_CFG, activityid)
  if record == nil then
    warn("GetJZJXActivityInfo(" .. activityid .. ") return nil")
    return nil
  end
  return JZJXUtils._GetJZJXActivityInfo(record)
end
def.static("userdata", "=>", "table")._GetJZJXActivityInfo = function(record)
  local cfg = {}
  cfg.activityid = record:GetIntValue("activityid")
  cfg.npcid = record:GetIntValue("npcid")
  cfg.mapServiceid = record:GetIntValue("mapServiceid")
  cfg.waitRoomMapid = record:GetIntValue("waitRoomMapid")
  cfg.npcInWaitRoom = record:GetIntValue("npcInWaitRoom")
  cfg.waitRoomServiceid = record:GetIntValue("waitRoomServiceid")
  return cfg
end
def.static("number", "=>", "string").Seconds2TimeText = function(seconds)
  local t = _G.Seconds2HMSTime(seconds)
  local timeText
  if t.m > 0 then
    timeText = string.format(textRes.JueZhanJiuXiao[2], t.m, t.s)
  else
    timeText = string.format(textRes.JueZhanJiuXiao[3], t.s)
  end
  return timeText
end
return JZJXUtils.Commit()
