local Lplus = require("Lplus")
local MonkeyRunUtils = Lplus.Class("MonkeyRunUtils")
local def = MonkeyRunUtils.define
def.static("=>", "table").GetAllActivityIds = function()
  local activityIds = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONKEYRUN_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local activityId = DynamicRecord.GetIntValue(entry, "activityId")
    table.insert(activityIds, activityId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return activityIds
end
def.static("number", "=>", "table").GetActivityOuterAwardGridCfg = function(activityId)
  local grids = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONKEYRUN_GRID_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    if activityId == DynamicRecord.GetIntValue(entry, "activityId") then
      local grid = {}
      grid.id = DynamicRecord.GetIntValue(entry, "id")
      grid.activityId = DynamicRecord.GetIntValue(entry, "activityId")
      grid.index = DynamicRecord.GetIntValue(entry, "index")
      grid.itemId = DynamicRecord.GetIntValue(entry, "itemId")
      grid.lightEffectId = DynamicRecord.GetIntValue(entry, "lightEffectId")
      grid.gridColor = DynamicRecord.GetIntValue(entry, "gridColor")
      grid.hitRate = DynamicRecord.GetIntValue(entry, "hitRate")
      grid.poolTypeId = DynamicRecord.GetIntValue(entry, "poolTypeId")
      table.insert(grids, grid)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(grids, function(a, b)
    return a.index < b.index
  end)
  if #grids == 0 then
    warn("GetActivityOuterAwardGridCfg is empty for activity:" .. activityId)
  end
  return grids
end
def.static("number", "=>", "number").GetActivityOuterAwardGridCount = function(activityId)
  local grids = MonkeyRunUtils.GetActivityOuterAwardGridCfg(activityId)
  return #grids
end
def.static("number", "=>", "table").GetMonkeyRunActivityCfgById = function(activityId)
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_MONKEYRUN_ACTIVITY_CFG, activityId)
  if entry == nil then
    warn("GetMonkeyRunActivityCfgById is nil:" .. activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = DynamicRecord.GetIntValue(entry, "activityId")
  cfg.modelId = DynamicRecord.GetIntValue(entry, "modelId")
  cfg.mainItemId = DynamicRecord.GetIntValue(entry, "mainItemId")
  cfg.subItemId = DynamicRecord.GetIntValue(entry, "subItemId")
  cfg.itemCount = DynamicRecord.GetIntValue(entry, "itemCount")
  cfg.lotteryViewCfgId = DynamicRecord.GetIntValue(entry, "lotteryViewCfgId")
  cfg.ticketCount = DynamicRecord.GetIntValue(entry, "ticketCount")
  cfg.duration = DynamicRecord.GetIntValue(entry, "duration")
  cfg.isClearPointExchangeInfo = DynamicRecord.GetIntValue(entry, "isClearPointExchangeInfo")
  cfg.initFlagCount = DynamicRecord.GetIntValue(entry, "initFlagCount")
  cfg.systemDrawMailId = DynamicRecord.GetIntValue(entry, "systemDrawMailId")
  cfg.outerDrawTipId = DynamicRecord.GetIntValue(entry, "outerDrawTipId")
  cfg.innerDrawTipId = DynamicRecord.GetIntValue(entry, "innerDrawTipId")
  cfg.pointExchangeTipId = DynamicRecord.GetIntValue(entry, "pointExchangeTipId")
  cfg.nengLiangQiIconId = DynamicRecord.GetIntValue(entry, "nengLiangQiIconId")
  cfg.nengLiangQiItemId = DynamicRecord.GetIntValue(entry, "nengLiangQiItemId")
  cfg.fireEffectSourceCfgId = DynamicRecord.GetIntValue(entry, "fireEffectSourceCfgId")
  return cfg
end
def.static("number", "=>", "number").GetMonkeyRunItemRelatedActivityId = function(itemId)
  local result = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONKEYRUN_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local activityId = DynamicRecord.GetIntValue(entry, "activityId")
    local mainItemId = DynamicRecord.GetIntValue(entry, "mainItemId")
    local subItemId = DynamicRecord.GetIntValue(entry, "subItemId")
    if mainItemId == itemId or subItemId == itemId then
      result = activityId
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return result
end
def.static("number", "=>", "table").GetActivityTicketAwardCfg = function(activityId)
  local awards = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONKEYRUN_TICKET_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    if activityId == DynamicRecord.GetIntValue(entry, "activityId") then
      local award = {}
      award.id = DynamicRecord.GetIntValue(entry, "id")
      award.activityId = DynamicRecord.GetIntValue(entry, "activityId")
      award.accumulateTurnCount = DynamicRecord.GetIntValue(entry, "accumulateTurnCount")
      award.ticketCount = DynamicRecord.GetIntValue(entry, "ticketCount")
      table.insert(awards, award)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(awards, function(a, b)
    return a.accumulateTurnCount < b.accumulateTurnCount
  end)
  if #awards == 0 then
    warn("GetActivityTicketAwardCfg is empty for activity:" .. activityId)
  end
  return awards
end
def.static("=>", "table").GetMonkeyRunShopCfg = function()
  local shopMap = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONKEYRUN_SHOP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local exchangeType = DynamicRecord.GetIntValue(entry, "exchangeType")
    if shopMap[exchangeType] == nil then
      shopMap[exchangeType] = {}
    end
    local item = {}
    item.id = DynamicRecord.GetIntValue(entry, "id")
    item.index = DynamicRecord.GetIntValue(entry, "index")
    item.fixAwardId = DynamicRecord.GetIntValue(entry, "fixAwardId")
    item.pointCount = DynamicRecord.GetIntValue(entry, "pointCount")
    item.exchangeMaxCount = DynamicRecord.GetIntValue(entry, "exchangeMaxCount")
    table.insert(shopMap[exchangeType], item)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local shopList = {}
  for exchangeType, tbl in pairs(shopMap) do
    table.sort(tbl, function(a, b)
      return a.index < b.index
    end)
    local shop = {}
    shop.shopType = exchangeType
    shop.items = tbl
    table.insert(shopList, shop)
  end
  return shopList
end
def.static("number", "number", "=>", "number", "number", "number").GetMonkeyRunAwardModelCfgId = function(activityId, itemId)
  local modelId = 0
  local scale = 0
  local angle = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONKEYRUN_AWARD_MODEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    if activityId == DynamicRecord.GetIntValue(entry, "activityId") and itemId == DynamicRecord.GetIntValue(entry, "itemId") then
      modelId = DynamicRecord.GetIntValue(entry, "modelId")
      scale = DynamicRecord.GetIntValue(entry, "scale")
      angle = DynamicRecord.GetIntValue(entry, "modelAngle")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return modelId, scale, angle
end
def.static("=>", "table").GetAllMonkeyRunEggAwardActivityIds = function()
  local activityIds = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONKEYRUN_EGG_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local activityId = DynamicRecord.GetIntValue(entry, "compensateActivityId")
    table.insert(activityIds, activityId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return activityIds
end
def.static("number", "=>", "table").GetMonkeyRunEggAwardActivityCfg = function(activityId)
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_MONKEYRUN_EGG_AWARD_CFG, activityId)
  if entry == nil then
    warn("GetMonkeyRunEggAwardActivityCfg is nil:" .. activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = DynamicRecord.GetIntValue(entry, "compensateActivityId")
  cfg.pointPerTurn = DynamicRecord.GetIntValue(entry, "pointPerTurn")
  return cfg
end
return MonkeyRunUtils.Commit()
