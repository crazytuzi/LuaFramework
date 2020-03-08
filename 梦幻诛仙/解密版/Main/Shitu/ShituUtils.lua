local Lplus = require("Lplus")
local ShituUtils = Lplus.Class("ShituUtils")
local TitleInterface = require("Main.title.TitleInterface")
local ItemUtils = require("Main.Item.ItemUtils")
local def = ShituUtils.define
def.static("number", "=>", "string").GetShoutuConditionById = function(id)
  local conditionRecord = DynamicData.GetRecord(CFG_PATH.DATA_SHOUTU_CONDITION_CFG, id)
  if conditionRecord == nil then
    return nil
  end
  local desc = DynamicRecord.GetStringValue(conditionRecord, "conditionDesc")
  return desc
end
def.static("number", "=>", "string").GetChushiConditionById = function(id)
  local conditionRecord = DynamicData.GetRecord(CFG_PATH.DATA_CHUSHI_CONDITION_CFG, id)
  if conditionRecord == nil then
    return nil
  end
  local desc = DynamicRecord.GetStringValue(conditionRecord, "conditionDesc")
  return desc
end
def.static("=>", "table").GetChushiAwardCfg = function()
  local awards = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHUSHI_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local award = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    award.cfgId = DynamicRecord.GetIntValue(entry, "cfgId")
    award.chuShiApprenticeNum = DynamicRecord.GetIntValue(entry, "chuShiApprenticeNum")
    local awardId = DynamicRecord.GetIntValue(entry, "awardId")
    local key = string.format("%d_%d_%d", awardId, 0, 0)
    local awardRecord = ItemUtils.GetGiftAwardCfg(key)
    if awardRecord ~= nil then
      local appellationCfg = TitleInterface.GetAppellationCfg(awardRecord.appellationId)
      if appellationCfg ~= nil then
        award.appellationName = appellationCfg.appellationName
        table.insert(awards, award)
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return awards
end
ShituUtils.Commit()
return ShituUtils
