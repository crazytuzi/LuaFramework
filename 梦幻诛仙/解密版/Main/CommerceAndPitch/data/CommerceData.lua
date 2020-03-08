local Lplus = require("Lplus")
local CommerceData = Lplus.Class("CommerceData")
local def = CommerceData.define
local instance
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local PAGE_ITEM_COUNT = 4
def.field("table").groupList = nil
def.field("table").curGroupList = nil
def.field("table").subTypeList = nil
def.field("table").itemInfoList = nil
def.field("table").bagItemIdList = nil
def.field("table").banShopList = nil
def.field("number").lastRefeshTime = 0
def.field("boolean").bISOnceFinished = true
def.field("table").calcItemPriceInfo = nil
def.static("=>", CommerceData).Instance = function()
  if nil == instance then
    instance = CommerceData()
    instance.itemInfoList = {}
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.groupList = nil
  self.curGroupList = nil
  self.subTypeList = nil
  self.itemInfoList = {}
  self.bagItemIdList = nil
  self.banShopList = nil
  self.lastRefeshTime = 0
  self.bISOnceFinished = true
end
def.method().InitData = function(self)
  self.groupList = {}
  self.curGroupList = {}
  self.subTypeList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_COMMERCE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local group = {}
    group.id = DynamicRecord.GetIntValue(entry, "id")
    group.BigTypeName = DynamicRecord.GetStringValue(entry, "BigTypeName")
    group.BigTypeIcon = DynamicRecord.GetIntValue(entry, "BigTypeIcon")
    group.BigTypeSort = DynamicRecord.GetIntValue(entry, "BigTypeSort") or 1000
    group.subTypeIdList = {}
    local SubTypeIdStruct = DynamicRecord.GetStructValue(entry, "SubTypeIdStruct")
    local SubTypeIdAmount = DynamicRecord.GetVectorSize(SubTypeIdStruct, "SubTypeIdList")
    for i = 0, SubTypeIdAmount - 1 do
      local SubTypeRecord = DynamicRecord.GetVectorValueByIdx(SubTypeIdStruct, "SubTypeIdList", i)
      local SubTypeId = SubTypeRecord:GetIntValue("SubTypeId")
      table.insert(group.subTypeIdList, SubTypeId)
      self.subTypeList[SubTypeId] = {}
      local subRecord = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_SUBTYPE_CFG, SubTypeId)
      self.subTypeList[SubTypeId].id = subRecord:GetIntValue("id")
      self.subTypeList[SubTypeId].SubTypeName = subRecord:GetStringValue("SubTypeName")
      self.subTypeList[SubTypeId].openServerLevel = subRecord:GetIntValue("openServerLevel")
      self.subTypeList[SubTypeId].openId = subRecord:GetIntValue("openId") or 0
      self.subTypeList[SubTypeId].itemList = {}
      local itemIdStruct = subRecord:GetStructValue("itemIdStruct")
      local itemIdListAmount = DynamicRecord.GetVectorSize(itemIdStruct, "itemIdList")
      for i = 0, itemIdListAmount - 1 do
        local itemRecord = DynamicRecord.GetVectorValueByIdx(itemIdStruct, "itemIdList", i)
        local itemId = itemRecord:GetIntValue("itemId")
        table.insert(self.subTypeList[SubTypeId].itemList, itemId)
      end
    end
    table.insert(self.groupList, group)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "=>", "number", "number").GetGroupIndexBySmallGroupId = function(self, smallGroupId)
  if nil == self.groupList then
    self:InitData()
  end
  local tmpGroupList = self:GetGroupList()
  local bigIndex = 0
  local smallIndex = 0
  for k, v in pairs(tmpGroupList) do
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
def.method("number", "=>", "number").GetBigGroupIndexByBigGroupId = function(self, bigGroupId)
  if nil == self.groupList then
    self:InitData()
  end
  local tmpGroupList = self:GetGroupList()
  local bigIndex = 0
  for k, v in pairs(tmpGroupList) do
    if v.id == bigGroupId then
      bigIndex = k
      break
    end
  end
  return bigIndex
end
def.method("number", "=>", "number", "number").GetGroupInfoByItemId = function(self, itemId)
  if nil == self.groupList then
    self:InitData()
  end
  local bigGroup, smallGroup = CommercePitchUtils.ItemIdToCommerceGroupId(itemId)
  local bigIndex = 0
  local smallIndex = 0
  local tmpGroupList = self:GetGroupList()
  for k, v in pairs(tmpGroupList) do
    if v.id == bigGroup then
      bigIndex = k
      for m, n in pairs(v.subTypeIdList) do
        if n == smallGroup then
          smallIndex = m
        end
      end
      break
    end
  end
  return bigIndex, smallIndex
end
def.method("boolean").SetOnceFinished = function(self, b)
  self.bISOnceFinished = b
end
def.method("table").setBanItemList = function(self, list)
  self.banShopList = list
end
def.method("number", "=>", "boolean").isBanItem = function(self, itemid)
  if self.banShopList == nil then
    return false
  end
  local count = #self.banShopList
  for k, v in pairs(self.banShopList) do
    warn("-------- ", v)
    if v == itemid then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").GetOnceFinished = function(self)
  return self.bISOnceFinished
end
def.method("=>", "table").GetGroupList = function(self)
  local tmpList = {}
  local curServerLv = require("Main.Server.Interface").GetServerLevelInfo().level
  for k, v in pairs(self.groupList) do
    local tmp = {}
    tmp.id = v.id
    tmp.BigTypeName = v.BigTypeName
    tmp.BigTypeIcon = v.BigTypeIcon
    tmp.BigTypeSort = v.BigTypeSort
    tmp.subTypeIdList = {}
    local subList = v.subTypeIdList
    for m, n in pairs(subList) do
      local subInfo = self.subTypeList[n]
      if curServerLv >= subInfo.openServerLevel and (subInfo.openId == 0 or IsFeatureOpen(subInfo.openId)) then
        table.insert(tmp.subTypeIdList, n)
      end
    end
    if #tmp.subTypeIdList > 0 then
      table.insert(tmpList, tmp)
    end
  end
  table.sort(tmpList, function(a, b)
    return a.BigTypeSort < b.BigTypeSort
  end)
  self.curGroupList = tmpList
  return tmpList
end
def.method("number", "number", "number", "=>", "table", "number", "number", "number").GetItemList = function(self, big, small, page)
  local selectGroup = self.curGroupList[big]
  local subList = {}
  local subTypeId = 0
  if nil ~= selectGroup and 0 ~= small and small <= #selectGroup.subTypeIdList then
    subTypeId = selectGroup.subTypeIdList[small]
    if subTypeId then
      subList = self:GetSubItemList(subTypeId)
    end
  end
  local itemCount = #subList
  local maxPage = math.ceil(itemCount / PAGE_ITEM_COUNT)
  if maxPage < 1 then
    return subList, 0, 0, 0
  end
  local itemList = {}
  local curPage = page or 1
  local curPage = math.max(curPage, 1)
  curPage = math.min(curPage, maxPage)
  local beginIndex = (curPage - 1) * PAGE_ITEM_COUNT + 1
  local endIndex = math.min(curPage * PAGE_ITEM_COUNT, itemCount)
  for i = beginIndex, endIndex do
    table.insert(itemList, subList[i])
  end
  return itemList, curPage, maxPage, subTypeId
end
def.method("number", "number", "number", "=>", "number").GetItemPage = function(self, big, small, itemid)
  local selectGroup = self.curGroupList[big]
  local subList = {}
  local subTypeId = 0
  if nil ~= selectGroup and 0 ~= small and small <= #selectGroup.subTypeIdList then
    subTypeId = selectGroup.subTypeIdList[small]
    if subTypeId then
      subList = self:GetSubItemList(subTypeId)
      for k, v in ipairs(subList) do
        if v == itemid then
          return math.ceil(k / PAGE_ITEM_COUNT)
        end
      end
    end
  end
  return 1
end
def.method("number", "=>", "table").GetSubItemList = function(self, subTyeId)
  local tmpList = {}
  if self.subTypeList[subTyeId] == nil then
    return tmpList
  end
  local curServerLv = require("Main.Server.Interface").GetServerLevelInfo().level
  for k, v in pairs(self.subTypeList[subTyeId].itemList) do
    local info = CommercePitchUtils.GetCommerceItemInfo(v)
    if info and curServerLv >= info.openServerLevel and self:isBanItem(v) == false then
      table.insert(tmpList, v)
    end
  end
  return tmpList
end
def.method("number", "=>", "string").GetSubTypeName = function(self, subTyeId)
  return self.subTypeList[subTyeId].SubTypeName
end
def.method().InitCommerceBagItems = function(self)
  local bags = ItemModule.Instance():GetAllItems()
  self.bagItemIdList = {}
  for bagId, items in pairs(bags) do
    for k, v in pairs(items) do
      local itemBase = ItemUtils.GetItemBase(v.id)
      local bCanSell = CommercePitchUtils.CanItemCommerceToSell(v.id, v)
      if bCanSell then
        local index = #self.bagItemIdList + 1
        local info = {}
        info.key = k
        info.bagId = bagId
        info.itemBase = itemBase
        info.count = v.number
        self.bagItemIdList[index] = info
      end
    end
  end
  table.sort(self.bagItemIdList, function(a, b)
    if a.bagId < b.bagId then
      return true
    elseif a.bagId > b.bagId then
      return false
    else
      return a.key < b.key
    end
  end)
end
def.method("=>", "table").GetCommerceItems = function(self)
  return self.bagItemIdList
end
def.method("table").UpdateItemInfo = function(self, itemInfo)
  if nil == self.itemInfoList[itemInfo.itemId] then
    self.itemInfoList[itemInfo.itemId] = {}
  end
  self.itemInfoList[itemInfo.itemId].price = itemInfo.price
  self.itemInfoList[itemInfo.itemId].rise = itemInfo.rise
end
def.method("number", "=>", "table").GetItemInfo = function(self, itemId)
  return self.itemInfoList[itemId]
end
def.method("number").SetRefeshTime = function(self, time)
  self.lastRefeshTime = time
end
def.method("=>", "number").GetRefeshTime = function(self)
  return self.lastRefeshTime
end
def.method().ShowTest = function(self)
  print("ShowTest")
  for k, v in pairs(self.itemInfoList) do
    print("itemId", k)
  end
end
def.method("number", "number", "number", "number").SetCalcItemPriceInfo = function(self, itemId, canBuyNum, orgDayPrice, recommandPrice)
  self.calcItemPriceInfo = self.calcItemPriceInfo or {}
  local t = {}
  t.itemId = itemId
  t.canBuyNum = canBuyNum
  t.orgDayPrice = orgDayPrice
  t.recommandPrice = recommandPrice
  self.calcItemPriceInfo[itemId] = t
end
def.method("number", "=>", "table").GetCalcItemPriceInfo = function(self, itemId)
  if self.calcItemPriceInfo then
    return self.calcItemPriceInfo[itemId]
  end
  return nil
end
def.method("number", "number").UpdateItemCanBuyNum = function(self, itemId, num)
  if self.calcItemPriceInfo then
    local t = self.calcItemPriceInfo[itemId]
    if t then
      t.canBuyNum = num
    end
  end
end
def.method().clearCalcItemCalcItemPriceInfo = function(self)
  self.calcItemPriceInfo = nil
end
CommerceData.Commit()
return CommerceData
