local Lplus = require("Lplus")
local AllLottoUtils = Lplus.Class("AllLottoUtils")
local def = AllLottoUtils.define
def.static("number", "=>", "table").GetAllLottoCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ALL_LOTTO_CFG, activityId)
  if record == nil then
    warn("GetAllLottoCfg nil", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activity_cfg_id")
  cfg.tipId = record:GetIntValue("tips_id")
  local items = {}
  local itemStruct = record:GetStructValue("itemStruct")
  local itemSize = DynamicRecord.GetVectorSize(itemStruct, "itemList")
  for i = 0, itemSize - 1 do
    local entry = DynamicRecord.GetVectorValueByIdx(itemStruct, "itemList", i)
    local itemId = entry:GetIntValue("itemId")
    table.insert(items, itemId)
  end
  cfg.items = items
  local warmUps = {}
  local warmUpStruct = record:GetStructValue("warmUpStruct")
  local warmUpSize = DynamicRecord.GetVectorSize(warmUpStruct, "warmUpList")
  for i = 0, warmUpSize - 1 do
    local entry = DynamicRecord.GetVectorValueByIdx(warmUpStruct, "warmUpList", i)
    local info = {}
    info.turn = entry:GetIntValue("warm_up_turn")
    info.time = entry:GetIntValue("timestamp")
    info.awardId = entry:GetIntValue("fix_award_id")
    table.insert(warmUps, info)
  end
  cfg.warmUps = warmUps
  local turns = {}
  local turnStruct = record:GetStructValue("turnStruct")
  local turnSize = DynamicRecord.GetVectorSize(turnStruct, "turnList")
  for i = 0, turnSize - 1 do
    local entry = DynamicRecord.GetVectorValueByIdx(turnStruct, "turnList", i)
    local info = {}
    info.turn = entry:GetIntValue("turn")
    info.time = entry:GetIntValue("timestamp")
    info.awardId = entry:GetIntValue("fix_award_id")
    info.modelId = entry:GetIntValue("model_id")
    table.insert(turns, info)
  end
  cfg.turns = turns
  return cfg
end
def.static("number", "=>", "boolean").IsAllLottoActivity = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ALL_LOTTO_CFG, activityId)
  if record then
    return true
  else
    return false
  end
end
def.static("number", "number", "=>", "table").GetAllLottoTurnCfg = function(activityId, turn)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ALL_LOTTO_CFG, activityId)
  if record == nil then
    warn("GetAllLottoTurnCfg activity nil", activityId)
    return nil
  end
  local turnStruct = record:GetStructValue("turnStruct")
  local entry = DynamicRecord.GetVectorValueByIdx(turnStruct, "turnList", turn - 1)
  if entry == nil then
    warn("GetAllLottoTurnCfg turn nil", turn)
    return nil
  end
  local info = {}
  info.turn = entry:GetIntValue("turn")
  info.time = entry:GetIntValue("timestamp")
  info.awardId = entry:GetIntValue("fix_award_id")
  info.modelId = entry:GetIntValue("model_id")
  return info
end
def.static("number", "number", "=>", "table").GetAllLottoWarmUpCfg = function(activityId, turn)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ALL_LOTTO_CFG, activityId)
  if record == nil then
    warn("GetAllLottoWarmUpCfg activity nil", activityId)
    return nil
  end
  local warmUpStruct = record:GetStructValue("warmUpStruct")
  local entry = DynamicRecord.GetVectorValueByIdx(warmUpStruct, "warmUpList", turn - 1)
  if entry == nil then
    warn("GetAllLottoWarmUpCfg warmUp nil", activityId)
    return nil
  end
  local info = {}
  info.turn = entry:GetIntValue("warm_up_turn")
  info.time = entry:GetIntValue("timestamp")
  info.awardId = entry:GetIntValue("fix_award_id")
  return info
end
def.static("=>", "number").GetCurAllLottoId = function()
  local list = AllLottoUtils.GetAllAllLottoActivityIds()
  if list then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    for k, v in ipairs(list) do
      if ActivityInterface.Instance():IsInTime(v) then
        return v
      end
    end
    return 0
  else
    return 0
  end
end
def.static("=>", "table").GetAllAllLottoActivityIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ALL_LOTTO_CFG)
  if entries == nil then
    warn("GetAllAllLottoActivityIds nil")
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = entry:GetIntValue("activity_cfg_id")
    table.insert(list, activityId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
AllLottoUtils.Commit()
return AllLottoUtils
