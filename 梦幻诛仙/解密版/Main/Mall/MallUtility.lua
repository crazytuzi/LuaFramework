local Lplus = require("Lplus")
local MallUtility = Lplus.Class("MallUtility")
local Vector = require("Types.Vector")
local def = MallUtility.define
def.static("table", "userdata", "=>", "table").FillTreasureNodeUI = function(uiTbl, node)
  uiTbl = {}
  local Img_BgItems = node:FindDirect("Img_BgItems")
  local ScrollView_Items = Img_BgItems:FindDirect("Scroll View_Items")
  local Grid_Items = ScrollView_Items:FindDirect("Grid_Items")
  uiTbl["Scroll View_Items"] = ScrollView_Items
  uiTbl.Grid_Items = Grid_Items
  local Img_BgDetail = node:FindDirect("Img_BgDetail")
  local Group_NoChoice = Img_BgDetail:FindDirect("Group_NoChoice")
  local Group_ItemInfo = Img_BgDetail:FindDirect("Group_ItemInfo")
  Img_BgDetail:SetActive(true)
  local Group_Detail = Group_ItemInfo:FindDirect("Group_Detail")
  local Group_Buy = Group_ItemInfo:FindDirect("Group_Buy")
  uiTbl.Group_NoChoice = Group_NoChoice
  uiTbl.Group_ItemInfo = Group_ItemInfo
  uiTbl.Group_Detail = Group_Detail
  uiTbl.Group_Buy = Group_Buy
  local List_Class = node:FindDirect("Group_List/ScrollList_Class/List_Class")
  uiTbl.List_Class = List_Class
  local Group_Fashion = node:FindDirect("Group_Fashion")
  uiTbl.Group_Fashion = Group_Fashion
  return uiTbl
end
def.static("number", "=>", "table").GetMallInfo = function(type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MALL_TYPE_CFG, type)
  local tbl
  if record then
    tbl = {}
    tbl.mallName = record:GetStringValue("mallName")
    tbl.sort = record:GetIntValue("sort")
    tbl.refreshtime = record:GetIntValue("refreshtime")
    tbl.mallType = record:GetIntValue("mallType")
    tbl.pagetype = record:GetIntValue("pagetype")
  end
  return tbl
end
def.static("number", "=>", "number").GetPageTypeByMallType = function(malltype)
  local tbl = MallUtility.GetMallInfo(malltype)
  if tbl then
    return tbl.pagetype
  else
    return 0
  end
end
def.static("=>", "table").GetAllMallInfo = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MALL_TYPE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local data = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    data.mallName = record:GetStringValue("mallName")
    data.sort = record:GetIntValue("sort")
    data.refreshtime = record:GetIntValue("refreshtime")
    data.mallType = record:GetIntValue("mallType")
    data.pagetype = record:GetIntValue("pagetype")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetMallListByPageType = function(page)
  local allMallInfos = MallUtility.GetAllMallInfo()
  local retData = {}
  for i = 1, #allMallInfos do
    local mallInfo = allMallInfos[i]
    if mallInfo.pagetype == page then
      table.insert(retData, mallInfo)
    end
  end
  return retData
end
def.static("=>", "number").GetTypeOneBtnNumByCfg = function()
  local btnList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MALL_TYPE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local PageEnum = require("consts.mzm.gsp.mall.confbean.PageEnum")
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local type = DynamicRecord.GetIntValue(entry, "mallType")
    local pagetype = DynamicRecord.GetIntValue(entry, "pagetype")
    if pagetype == PageEnum.PAGE_1 then
      table.insert(btnList, type)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return #btnList
end
def.static("string", "=>", "number").GetItemSort = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MALL_ITEM_PRICE_CFG, key)
  local sort = 0
  if record then
    sort = record:GetIntValue("sort")
  end
  return sort
end
def.static("string", "=>", "number").GetItemPrice = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MALL_ITEM_PRICE_CFG, key)
  local price = 0
  if record then
    price = record:GetIntValue("price")
  end
  return price
end
def.static("string", "=>", "number").GetItemOldPrice = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MALL_ITEM_PRICE_CFG, key)
  local price = 0
  if record then
    price = record:GetIntValue("primeprice")
  end
  return price
end
def.static("string", "=>", "number").GetItemMaxBuyNum = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MALL_ITEM_PRICE_CFG, key)
  local num = 0
  if record then
    num = record:GetIntValue("maxbuynum")
  end
  return num
end
def.static("number", "=>", "number").GetPriceByItemId = function(itemId)
  local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local key_1 = string.format("%d_%d", itemId, MallType.PRECIOUS_MALL)
  local price = MallUtility.GetItemPrice(key_1)
  if price == 0 then
    local key_2 = string.format("%d_%d", itemId, MallType.FUNCTION_MALL)
    price = MallUtility.GetItemPrice(key_2)
  end
  if price == 0 then
    local key_3 = string.format("%d_%d", itemId, MallType.LIMIT_MALL)
    price = MallUtility.GetItemPrice(key_3)
  end
  if price == 0 then
    local key_4 = string.format("%d_%d", itemId, MallType.FASHION_DRESS)
    price = MallUtility.GetItemPrice(key_4)
  end
  return price
end
def.static("userdata", "userdata", "number", "string").CreateNewGroup = function(groupNew, gridTemplate, count, name)
  groupNew:set_name(string.format(name, count))
  groupNew.parent = gridTemplate
  groupNew:set_localScale(Vector.Vector3.one)
  groupNew:SetActive(true)
end
def.static("number", "string", "userdata").DeleteLastGroup = function(listNum, groupName, gridTemplate)
  local template = gridTemplate:FindDirect(string.format(groupName, listNum))
  Object.Destroy(template)
  template = nil
end
def.static("number", "string", "userdata", "userdata").AddLastGroup = function(listNum, groupName, gridTemplate, groupTemplate)
  local groupNew = Object.Instantiate(groupTemplate)
  MallUtility.CreateNewGroup(groupNew, gridTemplate, listNum, groupName)
end
def.static("number", "=>", "string").GetRefeshTimeStr = function(timeId)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local tbl = TimeCfgUtils.GetTimeCommonCfg(timeId)
  local str = ""
  if tbl then
    local activeHour = tbl.activeHour
    local activeMinute = tbl.activeMinute
    local activeWeekDay = textRes.Mall.WeekDay[tbl.activeWeekDay]
    str = string.format(textRes.Mall[1], activeWeekDay, activeHour, activeMinute)
  end
  return str
end
return MallUtility.Commit()
