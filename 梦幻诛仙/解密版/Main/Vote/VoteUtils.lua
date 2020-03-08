local Lplus = require("Lplus")
local VoteUtils = Lplus.Class("VoteUtils")
local def = VoteUtils.define
def.static("number", "=>", "table").GetCommonVoteCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_VOTE_CFG, activityId)
  if record == nil then
    warn("GetCommonVoteCfg(" .. activityId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.idipSwitchId = record:GetIntValue("idipSwitchId")
  cfg.awardType = record:GetIntValue("awardType")
  cfg.awardId = record:GetIntValue("awardId")
  cfg.voteCountMax = record:GetIntValue("voteCountMax")
  cfg.voteType = record:GetIntValue("voteType")
  cfg.voteNumMaxPerCount = record:GetIntValue("voteNumMaxPerCount")
  return cfg
end
def.static("=>", "table").GetAllActivityIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_COMMON_VOTE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local activityIds = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = record:GetIntValue("activityCfgId")
    local idipSwitchId = record:GetIntValue("idipSwitchId")
    activityIds[activityId] = idipSwitchId
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return activityIds
end
local _featureTypeMapActivityId
def.static("number", "=>", "number").GetActivityIdByFeatureType = function(featureType)
  if _featureTypeMapActivityId == nil then
    local entries = DynamicData.GetTable(CFG_PATH.DATA_COMMON_VOTE_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    _featureTypeMapActivityId = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local activityId = record:GetIntValue("activityCfgId")
      local idipSwitchId = record:GetIntValue("idipSwitchId")
      _featureTypeMapActivityId[idipSwitchId] = activityId
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  return _featureTypeMapActivityId[featureType] or 0
end
def.static("=>", "table").GetAllFeatureVoteCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FEATURE_VOTE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfgs[#cfgs + 1] = VoteUtils._GetFeatureVoteCfg(record)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetFeatureVoteCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FEATURE_VOTE_CFG, id)
  if record == nil then
    warn("GetFeatureVoteCfg(" .. id .. ") return nil")
    return nil
  end
  return VoteUtils._GetFeatureVoteCfg(record)
end
def.static("userdata", "=>", "table")._GetFeatureVoteCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.describeTitle = record:GetStringValue("describeTitle")
  cfg.functionDescribe = record:GetStringValue("functionDescribe")
  cfg.iconResourceId = record:GetIntValue("iconResourceId")
  cfg.functionType = record:GetIntValue("functionType")
  cfg.joinVote = record:GetCharValue("joinVote") == 1
  cfg.rank = record:GetIntValue("rank")
  return cfg
end
return VoteUtils.Commit()
