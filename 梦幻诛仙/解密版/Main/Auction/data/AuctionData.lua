local Lplus = require("Lplus")
local AuctionUtils = require("Main.Auction.AuctionUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local AuctionItemInfo = require("Main.Auction.data.AuctionItemInfo")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local AuctionData = Lplus.Class("AuctionData")
local def = AuctionData.define
local _instance
def.static("=>", AuctionData).Instance = function()
  if _instance == nil then
    _instance = AuctionData()
  end
  return _instance
end
def.field("table")._auctionInfoMap = nil
def.field("number")._curAuctionId = 0
def.field("number")._curAuctionPeriodIdx = 0
def.field("number")._curAuctionRoundIdx = 0
def.field("table")._activityCfg = nil
def.field("table")._roundCfg = nil
def.field("table")._itemCfg = nil
def.field("table")._currencyCfg = nil
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._auctionInfoMap = nil
  self._curAuctionId = 0
  self._curAuctionPeriodIdx = 0
  self._curAuctionRoundIdx = 0
  self._activityCfg = nil
  self._roundCfg = nil
  self._itemCfg = nil
  self._currencyCfg = nil
  self:_ClearTimer()
end
def.method()._Update = function(self)
  if self._curAuctionId > 0 and 0 < self._curAuctionPeriodIdx then
    local roundIdx = self:_GetCurrentAuctionRoundIdx()
    self:SetCurrentAuctionRoundIdx(roundIdx)
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method()._LoadAuctionActivityCfg = function(self)
  warn("[AuctionData:_LoadAuctionActivityCfg] start Load AuctionActivityCfg!")
  self._activityCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AUCTION_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local auctionActivityCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    auctionActivityCfg.activityId = DynamicRecord.GetIntValue(entry, "activityId")
    auctionActivityCfg.periods = {}
    local activityInfoStruct = entry:GetStructValue("activityInfoStruct")
    local periodCount = activityInfoStruct:GetVectorSize("activityInfoList")
    for j = 1, periodCount do
      local record = activityInfoStruct:GetVectorValueByIdx("activityInfoList", j - 1)
      local periodCfg = {}
      periodCfg.activityTimeIndex = record:GetIntValue("activityTimeIndex")
      periodCfg.turnTypeId = record:GetIntValue("turnTypeId")
      auctionActivityCfg.periods[periodCfg.activityTimeIndex] = periodCfg
    end
    self._activityCfg[auctionActivityCfg.activityId] = auctionActivityCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table").GetAuctionActivityCfgs = function(self)
  if nil == self._activityCfg then
    self:_LoadAuctionActivityCfg()
  end
  return self._activityCfg
end
def.method("number", "=>", "table").GetAuctionCfg = function(self, id)
  return self:GetAuctionActivityCfgs()[id]
end
def.method("number", "number", "=>", "table").GetAuctionPeriodCfg = function(self, activityId, periodIdx)
  local auctionCfg = self:GetAuctionCfg(activityId)
  local periodCfg = auctionCfg and auctionCfg.periods[periodIdx]
  return periodCfg
end
def.method()._LoadAuctionRoundCfg = function(self)
  warn("[AuctionData:_LoadAuctionRoundCfg] start Load AuctionRoundCfg!")
  self._roundCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AUCTION_ROUND_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local roundCfg = {}
    roundCfg.turnTypeId = DynamicRecord.GetIntValue(entry, "turnTypeId")
    roundCfg.rounds = {}
    local turnInfoStruct = entry:GetStructValue("turnInfoStruct")
    local roundCount = turnInfoStruct:GetVectorSize("turnInfoList")
    for j = 1, roundCount do
      local record = turnInfoStruct:GetVectorValueByIdx("turnInfoList", j - 1)
      local roundInfo = {}
      roundInfo.turnIndex = record:GetIntValue("turnIndex")
      roundInfo.turnTimeId = record:GetIntValue("turnTimeId")
      roundInfo.durationCfg = TimeCfgUtils.GetTimeDurationCommonCfg(roundInfo.turnTimeId)
      roundInfo.bidStartCountDownTime = record:GetIntValue("bidStartCountDownTime")
      table.insert(roundCfg.rounds, roundInfo)
    end
    table.sort(roundCfg.rounds, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        return a.turnIndex < b.turnIndex
      end
    end)
    self._roundCfg[roundCfg.turnTypeId] = roundCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetAuctionRoundCfgs = function(self)
  if nil == self._roundCfg then
    self:_LoadAuctionRoundCfg()
  end
  return self._roundCfg
end
def.method("number", "=>", "table").GetAuctionRoundCfg = function(self, id)
  local cfgs = self:_GetAuctionRoundCfgs()
  return cfgs and cfgs[id] or nil
end
def.method("number", "number", "=>", "table").GetAuctionRounds = function(self, activityId, periodIdx)
  local periodCfg = periodIdx > 0 and self:GetAuctionPeriodCfg(activityId, periodIdx)
  local roundCfg = periodCfg and self:GetAuctionRoundCfg(periodCfg.turnTypeId)
  local rounds = roundCfg and roundCfg.rounds or nil
  return rounds
end
def.method()._LoadAuctionItemCfg = function(self)
  warn("[AuctionData:_LoadAuctionItemCfg] start Load AuctionItemCfg!")
  self._itemCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AUCTION_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local itemCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    itemCfg.id = DynamicRecord.GetIntValue(entry, "id")
    itemCfg.itemTypeId = DynamicRecord.GetIntValue(entry, "itemTypeId")
    itemCfg.itemCfgId = DynamicRecord.GetIntValue(entry, "itemCfgId")
    itemCfg.moneyType = DynamicRecord.GetIntValue(entry, "moneyType")
    itemCfg.yuanBaoType = DynamicRecord.GetIntValue(entry, "yuanBaoType")
    itemCfg.basePrice = DynamicRecord.GetIntValue(entry, "basePrice")
    itemCfg.costItemType = DynamicRecord.GetIntValue(entry, "cost_item_type")
    itemCfg.premiumRate = DynamicRecord.GetIntValue(entry, "premiumRate")
    self._itemCfg[itemCfg.id] = itemCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetAuctionItemCfgs = function(self)
  if nil == self._itemCfg then
    self:_LoadAuctionItemCfg()
  end
  return self._itemCfg
end
def.method("number", "=>", "table").GetAuctionItemCfg = function(self, cfgId)
  return self:_GetAuctionItemCfgs()[cfgId]
end
def.method()._LoadAuctionCurrencyCfg = function(self)
  warn("[AuctionData:_LoadAuctionCurrencyCfg] start Load CurrencyCfg!")
  self._currencyCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AUCTION_CURRENCY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local currencyCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    currencyCfg.moneyType = DynamicRecord.GetIntValue(entry, "moneyType")
    currencyCfg.moneyIcon = DynamicRecord.GetStringValue(entry, "moneyIcon")
    self._currencyCfg[currencyCfg.moneyType] = currencyCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetAuctionCurrencyCfgs = function(self)
  if nil == self._currencyCfg then
    self:_LoadAuctionCurrencyCfg()
  end
  return self._currencyCfg
end
def.method("number", "=>", "table").GetAuctionCurrencyCfg = function(self, cfgId)
  return self:_GetAuctionCurrencyCfgs()[cfgId]
end
def.method("number", "=>", "string").GetCurrencySpriteName = function(self, currencyType)
  local currencyCfg = self:GetAuctionCurrencyCfg(currencyType)
  if currencyCfg then
    return currencyCfg.moneyIcon
  else
    warn("[ERROR][AuctionData:GetCurrencySpriteName] currencyCfg nil for currencyType:", currencyType)
    return ""
  end
end
def.method("=>", "number").GetCurrentAuctionId = function(self)
  return self._curAuctionId
end
def.method("=>", "number")._GetCurrentAuctionId = function(self)
  local result = 0
  local auctionActivities = self:GetAuctionActivityCfgs()
  if auctionActivities then
    for activityId, auctionActivity in pairs(auctionActivities) do
      if AuctionUtils.IsActivityOpen(activityId) then
        result = activityId
        break
      end
    end
  end
  return result
end
def.method("=>", "number").GetCurrentAuctionPeriodIdx = function(self)
  return self._curAuctionPeriodIdx
end
def.method("number").SetCurrentAuctionRoundIdx = function(self, roundIdx)
  if roundIdx ~= self._curAuctionRoundIdx then
    warn("[AuctionData:SetCurrentAuctionRoundIdx] set roundIdx:", roundIdx)
    self._curAuctionRoundIdx = roundIdx
    Event.DispatchEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ROUND_CHANGE, {
      activityId = self._curAuctionId,
      roundIdx = roundIdx
    })
  end
end
def.method("=>", "number").GetCurrentAuctionRoundIdx = function(self)
  return self._curAuctionRoundIdx
end
def.method("=>", "number")._GetCurrentAuctionRoundIdx = function(self)
  local roundIdx = 0
  local rounds = self:GetAuctionRounds(self._curAuctionId, self._curAuctionPeriodIdx)
  if rounds and #rounds > 0 then
    local curTime = _G.GetServerTime()
    for idx, roundInfo in ipairs(rounds) do
      local startTime, endTime = AuctionUtils.GetDurationStartEndTime(roundInfo.durationCfg)
      if curTime < startTime then
        roundIdx = idx - 1
        break
      elseif idx == #rounds then
        roundIdx = idx
      end
    end
  else
  end
  return roundIdx
end
def.method("=>", "boolean").IsInCurRoundCfgInterval = function(self)
  local result = false
  local rounds = self:GetAuctionRounds(self._curAuctionId, self._curAuctionPeriodIdx)
  local roundInfo = rounds and rounds[self._curAuctionRoundIdx]
  if roundInfo then
    local curTime = _G.GetServerTime()
    local startTime, endTime = AuctionUtils.GetDurationStartEndTime(roundInfo.durationCfg)
    result = curTime >= startTime and curTime < endTime
  end
  return result
end
def.method("=>", "number").GetMinOpenLevel = function(self)
  local result = 0
  local auctionActivities = self:GetAuctionActivityCfgs()
  if auctionActivities then
    for activityId, auctionActivity in pairs(auctionActivities) do
      local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
      result = not activityCfg or result > 0 and math.min(result, activityCfg.levelMin) or activityCfg.levelMin
    end
  end
  return result
end
def.method("number", "number", "table", "boolean").SyncItemInfo = function(self, activityId, round, itemInfo, bEvent)
  if nil == itemInfo then
    warn("[ERROR][AuctionData:SyncItemInfo] sync fail, itemInfo nil.")
    return
  end
  local auctionItemInfo = self:GetItemInfo(activityId, round, itemInfo.itemCfgId)
  if auctionItemInfo then
    auctionItemInfo:SyncItemInfo(itemInfo)
  else
    if nil == self._auctionInfoMap then
      self._auctionInfoMap = {}
    end
    local activityRoundMap = self._auctionInfoMap[activityId]
    if nil == activityRoundMap then
      activityRoundMap = {}
      self._auctionInfoMap[activityId] = activityRoundMap
    end
    local itemInfoMap = activityRoundMap[round]
    if nil == itemInfoMap then
      itemInfoMap = {}
      activityRoundMap[round] = itemInfoMap
    end
    local auctionItemInfo = AuctionItemInfo.New(activityId, round, itemInfo)
    itemInfoMap[auctionItemInfo.auctionItemId] = auctionItemInfo
  end
  if bEvent then
    Event.DispatchEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ITEM_INFO_CHANGE, {
      activityId = activityId,
      roundIdx = round,
      auctionItemId = itemInfo.itemCfgId
    })
  end
end
def.method("number", "number", "=>", "table").GetRoundItems = function(self, activityId, round)
  local activityRoundMap = self._auctionInfoMap and self._auctionInfoMap[activityId]
  local itemInfoMap = activityRoundMap and activityRoundMap[round]
  return itemInfoMap
end
def.method("number", "number", "number", "=>", "table").GetItemInfo = function(self, activityId, round, auctionItemId)
  local itemInfoMap = self:GetRoundItems(activityId, round)
  local auctionItemInfo = itemInfoMap and itemInfoMap[auctionItemId]
  return auctionItemInfo
end
def.method().OnEnterWorld = function(self)
  self:UpdateCurrentAuction()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("table", "table").OnNewDay = function(self, param, context)
  self:ClearAuctionItemInfo()
  self:UpdateCurrentAuction()
end
def.method().ClearAuctionItemInfo = function(self)
  self._auctionInfoMap = nil
end
def.method().UpdateCurrentAuction = function(self)
  local oldAuctionId = self._curAuctionId
  local oldAuctionPeriodIdx = self._curAuctionPeriodIdx
  self._curAuctionId = self:_GetCurrentAuctionId()
  self._curAuctionPeriodIdx = AuctionUtils.GetActivityPeroidIdx(self._curAuctionId)
  if oldAuctionId ~= self._curAuctionId or oldAuctionPeriodIdx ~= self._curAuctionPeriodIdx then
    warn("[AuctionData:UpdateCurrentAuction] self._curAuctionId, self._curAuctionPeriodIdx:", self._curAuctionId, self._curAuctionPeriodIdx)
    self:SetCurrentAuctionRoundIdx(0)
    Event.DispatchEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_PERIOD_CHANGE, {
      auctionId = self._curAuctionId,
      periodIdx = self._curAuctionPeriodIdx
    })
    if 0 == self._curAuctionId then
      ActivityInterface.Instance()._activityInPeriod[oldAuctionId] = nil
      warn("[AuctionData:UpdateCurrentAuction] activityInterface._activityInPeriod[oldAuctionId] = nil.")
    end
  end
end
AuctionData.Commit()
return AuctionData
