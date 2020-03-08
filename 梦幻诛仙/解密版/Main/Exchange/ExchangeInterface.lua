local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ExchangeInterface = Lplus.Class("ExchangeInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local def = ExchangeInterface.define
local instance
def.field("table").exchangeInfos = nil
def.field("table").allExchangeActivityList = nil
def.field("table").exchangeableItems = nil
def.static("=>", ExchangeInterface).Instance = function()
  if instance == nil then
    instance = ExchangeInterface()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.exchangeInfos = {}
end
def.method().Reset = function(self)
  self.exchangeInfos = {}
  self.allExchangeActivityList = nil
end
def.static("number", "=>", "table").GetExchangeCfgIdList = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_ACTIVITY_CFG, activityId)
  if record == nil then
    error("!!!!!!!error exchange activityId:" .. activityId)
    return nil
  end
  local cfgIds = {}
  local rec2 = record:GetStructValue("exchangeIdStruct")
  local count = rec2:GetVectorSize("cfg_ids")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("cfg_ids", i - 1)
    local id = rec3:GetIntValue("id")
    table.insert(cfgIds, id)
  end
  return cfgIds
end
def.static("number", "=>", "number").GetExchangeOpendId = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_ACTIVITY_CFG, activityId)
  if record == nil then
    warn("!!!!!!!GetExchangeOpendId, error exchange activityId:" .. activityId)
    return 0
  end
  return record:GetIntValue("moduleid")
end
def.static("number", "=>", "number").GetExchangeSortId = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_ACTIVITY_CFG, activityId)
  if record == nil then
    warn("!!!!!!!GetExchangeSortId, error exchange activityId:" .. activityId)
    return 0
  end
  return record:GetIntValue("display_sort_id")
end
def.static("number", "=>", "number").GetExchangePageId = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_ACTIVITY_CFG, activityId)
  if record == nil then
    warn("!!!!!!!GetExchangePageId, error exchange activityId:" .. activityId)
    return 0
  end
  return record:GetIntValue("page_cfg_id")
end
def.static("number", "=>", "table").GetExchangeCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_CFG, id)
  if record == nil then
    error("!!!!!!!error exchange activityId:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.desc = record:GetStringValue("desc")
  cfg.activity_cfg_id = record:GetIntValue("activity_cfg_id")
  cfg.sort_id = record:GetIntValue("sort_id")
  cfg.display_sort_id = record:GetIntValue("display_sort_id")
  cfg.max_exchange_num = record:GetIntValue("max_exchange_num")
  cfg.award_cfg_id = record:GetIntValue("award_cfg_id")
  cfg.exchange_type = record:GetIntValue("exchange_type")
  cfg.is_open = record:GetCharValue("is_open") ~= 0
  cfg.itemList = {}
  local rec2 = record:GetStructValue("itemStruct")
  local count = rec2:GetVectorSize("itemList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("itemList", i - 1)
    local itemId = rec3:GetIntValue("item_id")
    local itemNum = rec3:GetIntValue("item_num")
    table.insert(cfg.itemList, {itemId = itemId, itemNum = itemNum})
  end
  return cfg
end
def.static("number", "=>", "boolean").isOpenExchange = function(exchangeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_CFG, exchangeId)
  if record == nil then
    warn("!!!!!!isOpenExchange exchange:", exchangeId)
    return false
  end
  return record:GetCharValue("is_open") ~= 0
end
def.static("number", "=>", "table").GetExchangePageCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXCHANGE_PAGE_CFG, id)
  if record == nil then
    error("!!!!!!!GetExchangePageCfg error id:", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.desc = record:GetStringValue("desc")
  cfg.activity_desc = record:GetStringValue("activity_desc")
  cfg.time_desc = record:GetStringValue("time_desc")
  cfg.display_sort_id = record:GetIntValue("display_sort_id")
  cfg.activityList = {}
  local rec2 = record:GetStructValue("activity_cfg_id_struct")
  local count = rec2:GetVectorSize("activity_cfg_ids")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("activity_cfg_ids", i - 1)
    local activityId = rec3:GetIntValue("activityId")
    table.insert(cfg.activityList, activityId)
  end
  return cfg
end
def.method("number", "=>", "boolean").isExchangeableItem = function(self, itemId)
  if self.exchangeableItems == nil then
    self.exchangeableItems = {}
    local ItemUtils = require("Main.Item.ItemUtils")
    local ExchangeType = require("consts.mzm.gsp.exchange.confbean.ExchangeType")
    local activityList = self:getAllExchangeActivity()
    for _, activityId in ipairs(activityList) do
      local cfgIds = ExchangeInterface.GetExchangeCfgIdList(activityId)
      for i, cfgId in ipairs(cfgIds) do
        local exchangeCfg = ExchangeInterface.GetExchangeCfg(cfgId)
        if exchangeCfg then
          for i, v in ipairs(exchangeCfg.itemList) do
            if exchangeCfg.exchange_type == ExchangeType.USE_SAME_PRICE_ITEM_ID then
              local filterCfg = ItemUtils.GetItemFilterCfg(v.itemId)
              for index, siftCfg in ipairs(filterCfg.siftCfgs) do
                self.exchangeableItems[siftCfg.idvalue] = activityId
              end
            else
              self.exchangeableItems[v.itemId] = activityId
            end
          end
        end
      end
    end
  end
  return self.exchangeableItems[itemId] ~= nil
end
def.method("=>", "table").getAllExchangeActivity = function(self)
  if self.allExchangeActivityList then
    return self.allExchangeActivityList
  end
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EXCHANGE_ACTIVITY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local idList = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = entry:GetIntValue("id")
    table.insert(idList, id)
  end
  self.allExchangeActivityList = idList
  return idList
end
def.method("number", "table").setExchangeInfos = function(self, activityId, infos)
  self.exchangeInfos[activityId] = infos
end
def.method("number").removeExchangeActivity = function(self, activityId)
  if self.exchangeInfos[activityId] then
    self.exchangeInfos[activityId] = nil
  end
end
def.method("number", "number", "number").setExchangeNum = function(self, activityId, sort_id, times)
  local info = self.exchangeInfos[activityId]
  info[sort_id] = times
end
def.method("number", "number", "=>", "number").getExchangeNum = function(self, activityId, sort_id)
  if self.exchangeInfos[activityId] then
    return self.exchangeInfos[activityId][sort_id] or 0
  end
  return 0
end
def.method("=>", "table").getExchangeActivityList = function(self)
  local list = {}
  for i, v in pairs(self.exchangeInfos) do
    local openId = ExchangeInterface.GetExchangeOpendId(i)
    if openId == 0 or IsFeatureOpen(openId) then
      table.insert(list, i)
    end
  end
  local function comp(activityId1, activityId2)
    local sort1 = ExchangeInterface.GetExchangeSortId(activityId1)
    local sort2 = ExchangeInterface.GetExchangeSortId(activityId2)
    return sort1 < sort2
  end
  table.sort(list, comp)
  return list
end
def.method("=>", "table").getExchangePageIdList = function(self)
  local listMap = {}
  for i, v in pairs(self.exchangeInfos) do
    local pageId = ExchangeInterface.GetExchangePageId(i)
    if listMap[pageId] == nil then
      local openId = ExchangeInterface.GetExchangeOpendId(i)
      if openId == 0 or IsFeatureOpen(openId) then
        listMap[pageId] = pageId
      end
    end
  end
  local list = {}
  for i, v in pairs(listMap) do
    table.insert(list, v)
  end
  local function comp(pageId1, pageId2)
    local pageCfg1 = ExchangeInterface.GetExchangePageCfg(pageId1)
    local pageCfg2 = ExchangeInterface.GetExchangePageCfg(pageId2)
    return pageCfg1.display_sort_id < pageCfg2.display_sort_id
  end
  table.sort(list, comp)
  return list
end
def.method("number", "=>", "table").getOpenActivityListByPageId = function(self, pageId)
  local list = {}
  for i, v in pairs(self.exchangeInfos) do
    local curPageId = ExchangeInterface.GetExchangePageId(i)
    if curPageId == pageId then
      local openId = ExchangeInterface.GetExchangeOpendId(i)
      if openId == 0 or IsFeatureOpen(openId) then
        table.insert(list, i)
      end
    end
  end
  return list
end
def.method("number", "=>", "table").getExchangeListByPageId = function(self, pageId)
  local activityList = self:getOpenActivityListByPageId(pageId)
  local exchangeList = {}
  for i, v in ipairs(activityList) do
    local exchangeCfgs = ExchangeInterface.GetExchangeCfgIdList(v)
    for _, exchangeId in ipairs(exchangeCfgs) do
      local isOpen = ExchangeInterface.isOpenExchange(exchangeId)
      if isOpen then
        table.insert(exchangeList, exchangeId)
      end
    end
  end
  return exchangeList
end
def.method("number", "number", "=>", "boolean").canEchange = function(self, activityId, exchangeId)
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local ItemUtils = require("Main.Item.ItemUtils")
  local ExchangeType = require("consts.mzm.gsp.exchange.confbean.ExchangeType")
  local exchangeCfg = ExchangeInterface.GetExchangeCfg(exchangeId)
  if not exchangeCfg.is_open then
    return false
  end
  local canExchange = true
  local exchangeNum = self:getExchangeNum(activityId, exchangeCfg.sort_id)
  if exchangeCfg.max_exchange_num == 0 or exchangeNum < exchangeCfg.max_exchange_num then
    for _, itemInfo in pairs(exchangeCfg.itemList) do
      local itemId = itemInfo.itemId
      local count = 0
      if exchangeCfg.exchange_type == ExchangeType.USE_SAME_PRICE_ITEM_ID then
        local filterCfg = ItemUtils.GetItemFilterCfg(itemId)
        for index, siftCfg in ipairs(filterCfg.siftCfgs) do
          count = count + itemData:GetNumberByItemId(BagInfo.BAG, siftCfg.idvalue)
        end
      else
        count = itemData:GetNumberByItemId(BagInfo.BAG, itemId)
      end
      if count < itemInfo.itemNum and canExchange then
        canExchange = false
      end
    end
  else
    canExchange = false
  end
  return canExchange
end
def.method("number", "=>", "boolean").calcExchangeRedPoint = function(self, activityId)
  local openId = ExchangeInterface.GetExchangeOpendId(activityId)
  if openId > 0 and not IsFeatureOpen(openId) then
    return false
  end
  local exchangeIdList = ExchangeInterface.GetExchangeCfgIdList(activityId)
  local flag = false
  for i, v in ipairs(exchangeIdList) do
    local canExchange = self:canEchange(activityId, v)
    if canExchange then
      flag = true
    end
  end
  return flag
end
def.method("number", "=>", "boolean").calcExchangePageRedPoint = function(self, pageId)
  local activityList = self:getOpenActivityListByPageId(pageId)
  for i, v in ipairs(activityList) do
    if self:calcExchangeRedPoint(v) then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").isHaveExchangeActivity = function(self)
  for i, v in pairs(self.exchangeInfos) do
    if self:calcExchangeRedPoint(i) then
      return true
    end
  end
  return false
end
return ExchangeInterface.Commit()
