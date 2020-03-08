local Lplus = require("Lplus")
local TokenMallUtils = Lplus.Class("TokenMallUtils")
local def = TokenMallUtils.define
def.static("number", "=>", "table").GetActivityTokenMallCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_TOKEN_MALL_CFG, activityId)
  if record == nil then
    warn("GetActivityTokenMallCfg(" .. activityId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.activitySwitchId = DynamicRecord.GetIntValue(record, "activitySwitchId")
  cfg.mallCfgIds = {}
  local malltruct = record:GetStructValue("malltruct")
  local count = malltruct:GetVectorSize("mallList")
  for i = 1, count do
    local mallCfg = malltruct:GetVectorValueByIdx("mallList", i - 1)
    local mallCfgId = mallCfg:GetIntValue("mallCfgId")
    table.insert(cfg.mallCfgIds, mallCfgId)
  end
  return cfg
end
def.static("number", "=>", "table").GetTokenMallCfg = function(mallCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TOKEN_MALL_CFG, mallCfgId)
  if record == nil then
    warn("GetTokenMallCfg(" .. mallCfgId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = mallCfgId
  cfg.mallName = record:GetStringValue("mallName")
  cfg.mallTheme = record:GetIntValue("mallTheme")
  cfg.exchangeTipId = record:GetIntValue("exchangeTipId")
  cfg.mallLimitTimeId = record:GetIntValue("mallLimitTimeId")
  cfg.tokenType = record:GetIntValue("tokenType")
  cfg.exchangeCountManualRefreshMaxCount = record:GetIntValue("exchangeCountManualRefreshMaxCount")
  cfg.goodsCfgTypeId = record:GetIntValue("goodsCfgTypeId")
  cfg.manualRefreshCostTypeId = record:GetIntValue("manualRefreshCostTypeId")
  cfg.mallHelpTipId = record:GetIntValue("mallHelpTipId")
  cfg.isShowMallTime = record:GetIntValue("isShowMallTime")
  return cfg
end
def.static("number", "=>", "table").GetTokenMallItems = function(mallType)
  local items = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TOKEN_MALL_ITEM_CFG, mallType)
  if record == nil then
    warn("GetTokenMallItems(" .. mallType .. ") return empty")
  else
    local goodsStruct = record:GetStructValue("goodsStruct")
    local count = goodsStruct:GetVectorSize("goodsList")
    for i = 1, count do
      local itemCfg = goodsStruct:GetVectorValueByIdx("goodsList", i - 1)
      local item = {}
      item.id = itemCfg:GetIntValue("id")
      item.index = itemCfg:GetIntValue("index")
      item.fixAwardId = itemCfg:GetIntValue("fixAwardId")
      item.exchangeType = itemCfg:GetIntValue("exchangeType")
      item.exchangeMaxCount = itemCfg:GetIntValue("exchangeMaxCount")
      item.tokenCount = itemCfg:GetIntValue("tokenCount")
      table.insert(items, item)
    end
  end
  table.sort(items, function(a, b)
    return a.index < b.index
  end)
  return items
end
def.static("number", "number", "=>", "table").GetTokenMallRefreshCost = function(refreshType, refreshCount)
  local costList = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TOKEN_MALL_REFRESH_CFG, refreshType)
  if record == nil then
    warn("GetTokenMallRefreshCost(" .. refreshType .. ") return empty")
    return nil
  end
  local costStruct = record:GetStructValue("costStruct")
  local count = costStruct:GetVectorSize("costList")
  for i = 1, count do
    local costCfg = costStruct:GetVectorValueByIdx("costList", i - 1)
    local cost = {}
    cost.index = costCfg:GetIntValue("index")
    cost.moneyType = costCfg:GetIntValue("moneyType")
    cost.moneyCount = costCfg:GetIntValue("moneyCount")
    table.insert(costList, cost)
  end
  table.sort(costList, function(a, b)
    return a.index < b.index
  end)
  for i = #costList, 1, -1 do
    if refreshCount >= costList[i].index then
      return costList[i]
    end
  end
  return nil
end
def.static("number", "=>", "number").GetTokenMallTheme = function(cfgId)
  local cfg = TokenMallUtils.GetTokenMallCfg(cfgId)
  if cfg then
    return cfg.mallTheme
  else
    return 0
  end
end
return TokenMallUtils.Commit()
