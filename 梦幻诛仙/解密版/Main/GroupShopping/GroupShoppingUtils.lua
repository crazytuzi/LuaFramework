local Lplus = require("Lplus")
local GroupShoppingUtils = Lplus.Class("GroupShoppingUtils")
local def = GroupShoppingUtils.define
def.static("=>", "table").GetAllActivityId = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GROUP_SHOPPING_ACTIVITY_CFG)
  if entries == nil then
    warn("GetAllActivityId nil")
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = entry:GetIntValue("activityId")
    table.insert(list, activityId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "boolean").IsGroupShoppingActivity = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_SHOPPING_ACTIVITY_CFG, activityId)
  if record then
    return true
  else
    return false
  end
end
def.static("number", "=>", "table").GetActivityShoppingCatelog = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_SHOPPING_ACTIVITY_CFG, activityId)
  if record == nil then
    warn("GetActivityShoppingCatelog nil", activityId)
    return nil
  end
  local smalls = {}
  local smallStruct = record:GetStructValue("smallStruct")
  local smallSize = DynamicRecord.GetVectorSize(smallStruct, "smallList")
  for i = 0, smallSize - 1 do
    local entry = DynamicRecord.GetVectorValueByIdx(smallStruct, "smallList", i)
    local smallGroupCfgId = entry:GetIntValue("smallGroupCfgId")
    table.insert(smalls, smallGroupCfgId)
  end
  local bigs = {}
  local bigStruct = record:GetStructValue("bigStruct")
  local bigSize = DynamicRecord.GetVectorSize(bigStruct, "bigList")
  for i = 0, bigSize - 1 do
    local entry = DynamicRecord.GetVectorValueByIdx(bigStruct, "bigList", i)
    local bigGroupCfgId = entry:GetIntValue("bigGroupCfgId")
    table.insert(bigs, bigGroupCfgId)
  end
  return {small = smalls, big = bigs}
end
def.static("number", "=>", "table").GetGroupCfg = function(cfgId)
  local type = GroupShoppingUtils.GetGroupType(cfgId)
  if type == 0 then
    return GroupShoppingUtils.GetSmallGroupCfg(cfgId)
  elseif type == 1 then
    return GroupShoppingUtils.GetBigGroupCfg(cfgId)
  else
    return nil
  end
end
def.static("number", "=>", "table").GetSmallGroupCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_SHOPPING_SMALL_CFG, cfgId)
  if record == nil then
    warn("GetSmallGroupCfg nil", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.itemId = record:GetIntValue("itemId")
  cfg.originalPrice = record:GetIntValue("originalPrice")
  cfg.singlePrice = record:GetIntValue("singlePrice")
  cfg.groupPrice = record:GetIntValue("groupPrice")
  cfg.groupSize = record:GetIntValue("groupSize")
  cfg.itemNum = record:GetIntValue("itemNum")
  cfg.maxBuyNum = record:GetIntValue("maxBuyNum")
  cfg.duration = record:GetIntValue("duration")
  return cfg
end
def.static("number", "=>", "table").GetBigGroupCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_SHOPPING_BIG_CFG, cfgId)
  if record == nil then
    warn("GetBigGroupCfg nil", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.itemId = record:GetIntValue("itemId")
  cfg.originalPrice = record:GetIntValue("originalPrice")
  cfg.singlePrice = record:GetIntValue("singlePrice")
  cfg.groupPrice = record:GetIntValue("groupPrice")
  cfg.groupSize = record:GetIntValue("groupSize")
  cfg.itemNum = record:GetIntValue("itemNum")
  cfg.maxBuyNum = record:GetIntValue("maxBuyNum")
  cfg.timeLimitCfgId = record:GetIntValue("timeLimitCfgId")
  return cfg
end
def.static("number", "=>", "number").GetGroupType = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_SHOPPING_SMALL_CFG, cfgId)
  if record ~= nil then
    return 0
  end
  record = DynamicData.GetRecord(CFG_PATH.DATA_GROUP_SHOPPING_BIG_CFG, cfgId)
  if record ~= nil then
    return 1
  end
  return -1
end
def.static("=>", "number").GetCurActivityId = function()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityIds = GroupShoppingUtils.GetAllActivityId()
  for k, v in ipairs(activityIds) do
    if ActivityInterface.Instance():isActivityOpend2(v) then
      return v
    end
  end
  return 0
end
GroupShoppingUtils.Commit()
return GroupShoppingUtils
