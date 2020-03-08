local Lplus = require("Lplus")
local PitchData = Lplus.Class("PitchData")
local def = PitchData.define
local instance
local MyShoppingItem = require("netio.protocol.mzm.gsp.baitan.MyShoppingItem")
local IdType = require("consts.mzm.gsp.baitan.confbean.IdType")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
def.const("number").PerPageItemNum = 8
def.field("number").lastFreeRefeshTime = 0
def.field("number").lastAutoFreshTime = 0
def.field("boolean").bFreeRefesh = false
def.field("boolean").bAutoRefesh = false
def.field("boolean").bAutoFreeRefresh = true
def.field("table").shoppingList = nil
def.field("table").exchangeList = nil
def.field("table").groupList = nil
def.field("number").lastGroup = 0
def.field("boolean").bISOnceFinished = true
def.field("number").sellGridNum = 0
def.field("table").sellList = nil
def.field("table").itemSoldOutTbl = nil
def.field("table").subTypeList = nil
def.field("boolean").bSyncShoppingList = false
def.field("table").itemPriceRecord = nil
def.static("=>", PitchData).Instance = function()
  if nil == instance then
    instance = PitchData()
    instance.itemSoldOutTbl = {}
    instance.shoppingList = {}
    instance.exchangeList = {}
    instance.sellList = {}
    instance.itemPriceRecord = {}
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.lastFreeRefeshTime = 0
  self.lastAutoFreshTime = 0
  self.bFreeRefesh = false
  self.bAutoRefesh = false
  self.bAutoFreeRefresh = true
  self.shoppingList = {}
  self.groupList = nil
  self.lastGroup = 0
  self.bISOnceFinished = true
  self.sellGridNum = 0
  self.sellList = {}
  self.itemSoldOutTbl = {}
  self.subTypeList = nil
  self.bSyncShoppingList = false
end
def.method().InitGroupList = function(self)
  self:InitSubList()
  self.groupList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PITCH_ITEMCONDITIONID_TO_GROUP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local group = {}
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    group.id = DynamicRecord.GetIntValue(entry, "id")
    group.ItemGroupSeq = DynamicRecord.GetIntValue(entry, "ItemGroupSeq")
    group.iconId = DynamicRecord.GetIntValue(entry, "iconId")
    group.subTypeIdList = {}
    local SubTypeIdStruct = DynamicRecord.GetStructValue(entry, "subTypeIdStruct")
    local SubTypeIdAmount = DynamicRecord.GetVectorSize(SubTypeIdStruct, "subTypeIdList")
    for i = 0, SubTypeIdAmount - 1 do
      local SubTypeRecord = DynamicRecord.GetVectorValueByIdx(SubTypeIdStruct, "subTypeIdList", i)
      local SubTypeId = SubTypeRecord:GetIntValue("subTypeId")
      table.insert(group.subTypeIdList, SubTypeId)
    end
    table.insert(self.groupList, group)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(self.groupList, function(a, b)
    return a.ItemGroupSeq < b.ItemGroupSeq
  end)
end
def.method().InitSubList = function(self)
  self.subTypeList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PITCH_ITEM_INFO_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    local subTypeId = DynamicRecord.GetIntValue(entry, "subTypeId")
    if self.subTypeList[subTypeId] == nil then
      self.subTypeList[subTypeId] = {}
    end
    local subInfo = {}
    subInfo.id = id
    subInfo.subTypeId = subTypeId
    local subtypeCfg = CommercePitchUtils.GetPitchSubTypeCfg(subTypeId)
    subInfo.name = subtypeCfg.name
    subInfo.icon = subtypeCfg.iconid
    subInfo.size = subtypeCfg.size
    subInfo.idType = DynamicRecord.GetIntValue(entry, "idType")
    if subInfo.idType == IdType.EQUIPITEMSHIFTID then
      local idVal = DynamicRecord.GetIntValue(entry, "idValue")
      local info = CommercePitchUtils.GetPitchEquipConditionInfo(idVal)
      subInfo.idValue = info.itemSiftId
    else
      subInfo.idValue = DynamicRecord.GetIntValue(entry, "idValue")
    end
    table.insert(self.subTypeList[subTypeId], subInfo)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "=>", "string").GetSubTypeName = function(self, subTypeId)
  if self.subTypeList[subTypeId] ~= nil and #self.subTypeList[subTypeId] >= 1 then
    return self.subTypeList[subTypeId][1].name
  else
    return ""
  end
end
def.method("number", "=>", "number").GetSubTypeIcon = function(self, subTypeId)
  if self.subTypeList[subTypeId] ~= nil and #self.subTypeList[subTypeId] >= 1 then
    return self.subTypeList[subTypeId][1].icon
  else
    return 0
  end
end
def.method("number", "=>", "table").GetEquipPitchIdByItemConditionId = function(self, id)
  if nil == self.groupList then
    self:InitGroupList()
  end
  local tbl = {}
  for k, v in pairs(self.subTypeList) do
    for m, n in pairs(v) do
      if id == n.idValue and n.idType == IdType.EQUIPITEMSHIFTID then
        local record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_ITEM_INFO_CFG, n.id)
        local idVal = DynamicRecord.GetIntValue(record, "idValue")
        local info = CommercePitchUtils.GetPitchEquipConditionInfo(idVal)
        table.insert(tbl, {
          type = n.idType,
          idVal = idVal
        })
      end
    end
  end
  return tbl
end
def.method("number", "=>", "number", "number").GetGroupInfoByItemConditionId = function(self, id)
  if nil == self.groupList then
    self:InitGroupList()
  end
  local subId = 0
  for k, v in pairs(self.subTypeList) do
    for m, n in pairs(v) do
      if id == n.idValue then
        if n.idType == IdType.EQUIPITEMSHIFTID then
          local record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_ITEM_INFO_CFG, n.id)
          local idVal = DynamicRecord.GetIntValue(record, "idValue")
          local info = CommercePitchUtils.GetPitchEquipConditionInfo(idVal)
          if info.isShowNeedSign then
            subId = n.subTypeId
            break
          end
        else
          subId = n.subTypeId
          break
        end
      end
    end
  end
  local bigIndex = 0
  local smallIndex = 0
  if subId ~= 0 then
    for k, v in pairs(self.groupList) do
      for m, n in pairs(v.subTypeIdList) do
        if n == subId then
          smallIndex = m
          bigIndex = k
          break
        end
      end
    end
  end
  return bigIndex, smallIndex
end
def.method("=>", "boolean").IfHaveMoneyToGetMoney = function(self)
  local b = false
  for k, v in pairs(self.sellList) do
    if v.state == MyShoppingItem.STATE_SELLED and v.sellNum > 0 then
      b = true
      break
    end
  end
  return b
end
def.method("=>", "table").GetSoldOutList = function(self)
  return self.itemSoldOutTbl
end
def.method("userdata").AddSoldOutItem = function(self, shoppingid)
end
def.method("number").SetLastAutoRefeshTime = function(self, lastAutoFreshTime)
  self.lastAutoFreshTime = lastAutoFreshTime
end
def.method("=>", "number").GetLastAutoRefeshTime = function(self)
  return self.lastAutoFreshTime
end
def.method("boolean").SetIsAutoRefesh = function(self, bAutoRefesh)
  self.bAutoRefesh = bAutoRefesh
end
def.method("=>", "boolean").GetIsAutoRefesh = function(self)
  return self.bAutoRefesh
end
def.method("number").SetLastFreeRefeshTime = function(self, lastTime)
  self.lastFreeRefeshTime = lastTime
end
def.method("table").SetShoppingList = function(self, shopList)
  require("Common.MathHelper").ShuffleTable(shopList)
  self.shoppingList = {}
  for k, v in pairs(shopList) do
    if nil == self.shoppingList[v.group] then
      self.shoppingList[v.group] = {}
    end
    v.item = nil
    table.insert(self.shoppingList[v.group], v)
  end
end
def.method("userdata", "table").SetShoppingItem = function(self, shoppingid, item)
  for k, v in pairs(self.shoppingList) do
    for m, n in pairs(v) do
      if n.shoppingid == shoppingid then
        n.item = item
      end
    end
  end
end
def.method().ClearShoppingList = function(self)
  self.shoppingList = {}
end
def.method("table", "=>", "boolean").SetPageInfoToShoppingList = function(self, pageInfo)
  pageInfo.param = pageInfo.param or 0
  self.shoppingList[pageInfo.subtype] = self.shoppingList[pageInfo.subtype] or {}
  local lastParam = not self.shoppingList[pageInfo.subtype].activeParam and 0
  local isReset = false
  if lastParam ~= pageInfo.param then
    isReset = true
  end
  self.shoppingList[pageInfo.subtype] = self.shoppingList[pageInfo.subtype] or {}
  self.shoppingList[pageInfo.subtype][pageInfo.param] = self.shoppingList[pageInfo.subtype][pageInfo.param] or {}
  local speParamList = self.shoppingList[pageInfo.subtype][pageInfo.param]
  table.sort(pageInfo.shoppingItemList, function(left, right)
    return left.price < right.price
  end)
  speParamList[pageInfo.pageindex] = pageInfo.shoppingItemList
  speParamList.param = pageInfo.param
  speParamList.totalPage = pageInfo.totalpagenum
  self.shoppingList[pageInfo.subtype].itemList = self.shoppingList[pageInfo.subtype].itemList or {}
  for i, v in ipairs(pageInfo.shoppingItemList) do
    self.shoppingList[pageInfo.subtype].itemList[v.index + 1] = v
  end
  self.shoppingList[pageInfo.subtype].activeParam = pageInfo.param
  return isReset
end
def.method("number", "number", "=>", "string").GetShoppingItemKey = function(index, itemId)
  return string.format("%d%d", index, itemId)
end
def.method("number", "table").SetShoppingItemInfo = function(self, index, itemInfo)
  local pos = self:GetItemPosByIndexAndId(index, itemInfo.id)
  if pos == nil then
    return
  end
  if self.shoppingList == nil then
    return
  end
  self.shoppingList[pos.subType][pos.param][pos.pageIndex][pos.offIndex].item = itemInfo
end
def.method("number", "number", "number").UpdateShoppingItemNum = function(self, index, itemId, itemNum)
  local pos = self:GetItemPosByIndexAndId(index, itemId)
  if pos == nil then
    return
  end
  if self.shoppingList == nil then
    return
  end
  self.shoppingList[pos.subType][pos.param][pos.pageIndex][pos.offIndex].num = itemNum
end
def.method("=>", "number").GetChangedSelledItemNum = function(self)
  local count = 0
  for k, v in pairs(self.sellList) do
    if v.state == MyShoppingItem.STATE_SELLED or v.state == MyShoppingItem.STATE_EXPIRE then
      count = count + 1
    end
  end
  return count
end
def.method("=>", "number").GetLastFreeRefeshTime = function(self)
  return self.lastFreeRefeshTime
end
def.method("=>", "table").GetGroupList = function(self)
  return self.groupList
end
def.method("number").SetLastGroup = function(self, group)
  self.lastGroup = group
end
def.method("boolean").SetIsFreeRefesh = function(self, b)
  self.bFreeRefesh = b
end
def.method("=>", "boolean").GetIsFreeRefesh = function(self)
  return self.bFreeRefesh
end
def.method("boolean").SetAutoFreeRefresh = function(self, b)
  self.bAutoFreeRefresh = b
end
def.method("=>", "boolean").CanAutoFreeRefresh = function(self)
  return self.bAutoFreeRefresh
end
def.method("=>", "boolean").IsAutoFreeRefresh = function(self)
  return self.bAutoFreeRefresh
end
def.method("boolean").SetOnceFinished = function(self, b)
  self.bISOnceFinished = b
end
def.method("=>", "boolean").GetOnceFinished = function(self)
  return self.bISOnceFinished
end
def.method("boolean").SetIsSyncShoppingList = function(self, b)
  self.bSyncShoppingList = b
end
def.method("=>", "boolean").GetIsSyncShoppingList = function(self)
  return self.bSyncShoppingList
end
def.method("number", "=>", "table").GetShoppingListByGroup = function(self, smallGroup)
  local tmpTbl = {}
  if nil ~= self.shoppingList[smallGroup] then
    return self.shoppingList[smallGroup]
  end
  return tmpTbl
end
def.method("number", "number", "=>", "table").GetShoppingListByGroupAndParam = function(self, smallGroup, param)
  if self.shoppingList[smallGroup] == nil then
    return {}
  end
  if self.shoppingList[smallGroup][param] == nil then
    return {}
  end
  return self.shoppingList[smallGroup][param]
end
def.method("number", "table").SetShoppingListByGroup = function(self, smallGroup, pages)
  self.shoppingList[smallGroup] = pages
end
def.method("number", "=>", "table").GetSubItemList = function(self, subTyeId)
  return self.subTypeList[subTyeId]
end
def.method("userdata", "=>", "table").GetShoppingInfoByShoppingId = function(self, shoppingid)
  for k, v in pairs(self.shoppingList) do
    for m, n in pairs(v) do
      if n.shoppingid == shoppingid then
        return n
      end
    end
  end
  return nil
end
def.method("number", "number", "=>", "table").GetItemPosByIndexAndId = function(self, index, itemId)
  local function travelPage(subType, param, pageIndex, page)
    for offIndex, v in ipairs(page) do
      if v.index == index and v.itemid == itemId then
        return true, {
          subType = subType,
          param = param,
          pageIndex = pageIndex,
          offIndex = offIndex
        }
      end
    end
    return false
  end
  local function travelPages(subType, param, pages)
    for pageIndex, page in pairs(pages) do
      if type(page) == "table" then
        local stop, result = travelPage(subType, param, pageIndex, page)
        if stop then
          return stop, result
        end
      end
    end
    return false
  end
  local function travelParamDatas(subType, paramDatas)
    for param, pages in pairs(paramDatas) do
      if type(pages) == "table" then
        local stop, result = travelPages(subType, param, pages)
        if stop then
          return stop, result
        end
      end
    end
    return false
  end
  for subType, paramDatas in pairs(self.shoppingList) do
    local stop, result = travelParamDatas(subType, paramDatas)
    if stop then
      return result
    end
  end
  return nil
end
def.method("number", "number", "=>", "table").GetShoppingInfoByIndexAndId = function(self, index, itemId)
  local pos = self:GetItemPosByIndexAndId(index, itemId)
  if pos == nil then
    return nil
  end
  if self.shoppingList == nil then
    return nil
  end
  return self.shoppingList[pos.subType][pos.param][pos.pageIndex][pos.offIndex]
end
def.method("number").SetSellGridNum = function(self, num)
  self.sellGridNum = num
end
def.method().UpdateSellList = function(self)
  if nil == self.sellList then
    return
  end
  for k, v in pairs(self.sellList) do
    if v.bNeedUpdate then
      table.remove(self.sellList, k)
    end
  end
end
def.method().SetSellListEmpty = function(self)
  self.sellList = {}
end
def.method("table").AddSellItem = function(self, item)
  item.bNeedUpdate = false
  table.insert(self.sellList, item)
end
def.method("userdata", "number", "number").SellItemShowOff = function(self, shoppingid, sellNum, remainNum)
  for k, v in pairs(self.sellList) do
    if v.shoppingid == shoppingid then
      v.state = MyShoppingItem.STATE_SELLED
      v.sellNum = sellNum
      v.item.number = remainNum
    end
  end
end
def.method("userdata", "number").SellItemOnShelfAgain = function(self, shoppingid, price)
  for k, v in pairs(self.sellList) do
    if v.shoppingid == shoppingid then
      v.state = MyShoppingItem.STATE_SELL
      v.price = price
    end
  end
end
def.method("userdata", "=>", "table").GetItemByShoppinId = function(self, shoppingid)
  for k, v in pairs(self.sellList) do
    if v.shoppingid == shoppingid then
      return v
    end
  end
  return nil
end
def.method("userdata").RemoveSellItem = function(self, shoppingid)
  for k, v in pairs(self.sellList) do
    if v.shoppingid == shoppingid then
      table.remove(self.sellList, k)
      v.bNeedUpdate = true
    end
  end
end
def.method("userdata").UpdateItemState = function(self, shoppingid)
  local sellItem = self:GetItemByShoppinId(shoppingid)
  if nil ~= sellItem and 0 == sellItem.item.number then
    self:RemoveSellItem(shoppingid)
  elseif nil ~= sellItem and 0 < sellItem.item.number then
    sellItem.state = MyShoppingItem.STATE_SELL
  end
end
def.method("userdata").SellItemOverDate = function(self, shoppingid)
  for k, v in pairs(self.sellList) do
    if v.shoppingid == shoppingid then
      v.state = MyShoppingItem.STATE_EXPIRE
    end
  end
end
def.method("=>", "number").GetSellGridNum = function(self)
  return self.sellGridNum
end
def.method("=>", "table").GetSellList = function(self)
  return self.sellList
end
def.method("=>", "table").GetExpireSellItems = function(self)
  local items = {}
  for i, v in ipairs(self.sellList) do
    if v.state == MyShoppingItem.STATE_EXPIRE then
      table.insert(items, v)
    end
  end
  return items
end
def.method("userdata", "=>", "table").GetOnSellItem = function(self, shoppingid)
  for i, v in ipairs(self.sellList) do
    if v.shoppingid == shoppingid then
      return v
    end
  end
  return nil
end
def.method("number", "=>", "number").GetBigGroupIndexByBigGroupId = function(self, bigGroupId)
  if nil == self.groupList then
    self:InitGroupList()
  end
  local groupIndex = 0
  for k, v in pairs(self.groupList) do
    if bigGroupId == v.id then
      groupIndex = k
      break
    end
  end
  return groupIndex
end
def.method("number", "=>", "number", "number").GetGroupIndexBySmallGroupId = function(self, smallGroupId)
  if nil == self.groupList then
    self:InitGroupList()
  end
  local bigIndex = 0
  local smallIndex = 0
  for k, v in pairs(self.groupList) do
    for m, n in pairs(v.subTypeIdList) do
      if n == smallGroupId then
        smallIndex = m
        bigIndex = k
        break
      end
    end
  end
  return bigIndex, smallIndex
end
def.method("=>", "boolean").CanFreeRefresh = function(self)
  local lastFreeTime = self:GetLastFreeRefeshTime()
  local curTime = GetServerTime()
  local freeTime = curTime - lastFreeTime
  return freeTime >= CommercePitchUtils.GetPitchFreeRefeshTime()
end
def.method("=>", "table").GetEquipFilterConditions = function(self)
  local MIN_LEVEL = CommercePitchUtils.GetPitchConstant("SHOW_EQUIP_START_LEVEL")
  local MAX_LEVEL = CommercePitchUtils.GetPitchConstant("EQUIP_SIFT_MAX_LEVEL")
  local LEVEL_STEP = 10
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local minLevel = math.max(MIN_LEVEL, math.min(MIN_LEVEL, math.floor(heroLevel / LEVEL_STEP) * LEVEL_STEP))
  local maxLevel = math.max(MIN_LEVEL, math.floor((heroLevel + LEVEL_STEP) / LEVEL_STEP) * LEVEL_STEP)
  maxLevel = math.min(maxLevel, MAX_LEVEL)
  local conditions = {}
  local defaultNotSet = true
  local lastCondition
  for i = minLevel, maxLevel, LEVEL_STEP do
    local condition = {
      param = i,
      name = string.format(textRes.Common[3], i)
    }
    if defaultNotSet and math.floor(heroLevel / LEVEL_STEP) * LEVEL_STEP == i or heroLevel < minLevel then
      condition.default = true
      defaultNotSet = false
    end
    lastCondition = condition
    table.insert(conditions, condition)
  end
  if defaultNotSet and lastCondition then
    lastCondition.default = true
  end
  return conditions
end
PitchData.Commit()
return PitchData
