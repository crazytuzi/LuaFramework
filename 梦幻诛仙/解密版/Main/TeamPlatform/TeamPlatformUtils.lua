local Lplus = require("Lplus")
local TeamPlatformUtils = Lplus.Class("TeamPlatformUtils")
local def = TeamPlatformUtils.define
def.static("string", "=>", "number").GetTeamPlatformConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TEAM_PLATFORM_CONSTS_CFG, key)
  if record == nil then
    warn("GetTeamPlatformConsts(" .. key .. ") return nil")
    return 0
  end
  return record:GetIntValue("value")
end
def.static("=>", "table").GetTeamPlatformMatchOptions = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TEAM_PLATFORM_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = TeamPlatformUtils._GetTeamPlatformMatchOptionCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetTeamPlatformMatchOptionCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TEAM_PLATFORM_ACTIVITY_CFG, id)
  if record == nil then
    warn("GetTeamPlatformMatchOptionCfg(" .. id .. ") return nil")
    return nil
  end
  return TeamPlatformUtils._GetTeamPlatformMatchOptionCfg(record)
end
def.static("userdata", "=>", "table")._GetTeamPlatformMatchOptionCfg = function(record)
  local matchType = record:GetIntValue("matchType")
  local cfg = require("Main.TeamPlatform.data.TeamPlatformDataFactory").Create(matchType)
  cfg.id = record:GetIntValue("id")
  cfg.refId = record:GetIntValue("activityId")
  cfg.cfgId = record:GetIntValue("activityCfgId")
  cfg.matchType = matchType
  cfg.classId = record:GetIntValue("matchTypeCfgId")
  cfg.aidNewbieCapacity = record:GetIntValue("newGuyNum")
  cfg.name = record:GetStringValue("name") or ""
  cfg.instruction = record:GetStringValue("instruction") or ""
  cfg.canAIMatch = record:GetCharValue("canAIMatch") == 1
  return cfg
end
def.static("number", "=>", "table").GetTeamPlatformMatchOptionSubCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TEAM_PLATFORM_ACTIVITY_SUB_CFG, cfgId)
  if record == nil then
    warn("GetTeamPlatformMatchOptionSubCfg(" .. cfgId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = cfgId
  cfg.optionList = {}
  local optionStruct = DynamicRecord.GetStructValue(record, "optionStruct")
  local optionAmount = DynamicRecord.GetVectorSize(optionStruct, "optionVector")
  for i = 0, optionAmount - 1 do
    local optionRecord = DynamicRecord.GetVectorValueByIdx(optionStruct, "optionVector", i)
    local option = {}
    option.index = i + 1
    option.minLevel = optionRecord:GetIntValue("optionLvFloor")
    option.maxLevel = optionRecord:GetIntValue("optionLvTop")
    option.name = optionRecord:GetStringValue("optionName")
    table.insert(cfg.optionList, option)
  end
  return cfg
end
def.static("number", "=>", "table").GetTeamPlatformMatchClassCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TEAM_PLATFORM_MATCH_CLASS_CFG, id)
  if record == nil then
    warn("GetTeamPlatformMatchClassCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.name = record:GetStringValue("typeName")
  cfg.rank = record:GetIntValue("rank")
  return cfg
end
def.static("table", "=>", "string").GetMatchName = function(matchCfg)
  local matchCfgId = matchCfg.matchCfgId or 0
  local index = matchCfg.index
  local name = ""
  local matchData = TeamPlatformUtils.GetTeamPlatformMatchOptionCfg(matchCfgId)
  if matchData == nil then
    return "no data"
  end
  if index == 0 then
    name = matchData:GetName()
  else
    local subCfg = TeamPlatformUtils.GetTeamPlatformMatchOptionSubCfg(matchData.cfgId)
    local option = subCfg.optionList[index]
    name = option and option.name or "ERROR:" .. matchCfgId .. "_" .. index
  end
  return name
end
def.static("=>", "table").GetTeamPlatformServiceCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TEAM_PLATFORM_SERVICE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local teamMatchId = entry:GetIntValue("teamMatchId") or 0
    local serviceId = entry:GetIntValue("serverId")
    cfgs[serviceId] = teamMatchId
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
return TeamPlatformUtils.Commit()
