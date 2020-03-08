local Lplus = require("Lplus")
local MysteryStoreUtil = Lplus.Class("MysteryStoreUtil")
local ItemUtils = require("Main.Item.ItemUtils")
local def = MysteryStoreUtil.define
def.static("number", "=>", "table").GetGoodsCfgById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MysteryStore_GoodsCfg, id)
  local retData = {}
  if record == nil then
    return retData
  end
  retData.id = record:GetIntValue("id")
  retData.itemId = record:GetIntValue("itemId")
  retData.num = record:GetIntValue("num")
  retData.price = record:GetIntValue("price")
  retData.money_type = record:GetIntValue("moneyType")
  retData.maxbuynum = record:GetIntValue("maxbuynum")
  retData.is_bind = record:GetIntValue("is_bind")
  return retData
end
def.static("number", "=>", "table").GetRefreshCostCfgById = function(id)
  warn(">>>>refresh id = " .. id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MysteryStore_RefreshCostCfg, id)
  local retData = {}
  if record == nil then
    return retData
  end
  retData.refreshTimes = record:GetIntValue("refreshTimes")
  retData.moneyNum = record:GetIntValue("moneyNum")
  retData.moneyType = record:GetIntValue("moneyType")
  warn(" >>>>moneyType = " .. retData.moneyType)
  return retData
end
def.static("=>", "table").GetAllConstCfg = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MysteryStore_ConstCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local data = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    data.id = record:GetIntValue("id")
    data.shopType = record:GetIntValue("shopType")
    data.minLevel = record:GetIntValue("MIN_ROLE_LEVLE_FOR_MYSTERY_SHOP")
    data.gridNum = record:GetIntValue("GOODS_GRID_NUM")
    data.dailyMaxRefresTimes = record:GetIntValue("DAILY_MAX_REFRESH_TIMES")
    data.addEffectThreshold = record:GetIntValue("SALE_PROMPT_THRESHOLD")
    data.line1 = record:GetIntValue("SALE_RANGE_1")
    data.tag_img1 = record:GetIntValue("SALE_COLOR_1")
    data.line2 = record:GetIntValue("SALE_RANGE_2")
    data.tag_img2 = record:GetIntValue("SALE_COLOR_2")
    data.line3 = record:GetIntValue("SALE_RANGE_3")
    data.tag_img3 = record:GetIntValue("SALE_COLOR_3")
    data.min_discount = record:GetIntValue("SALE_MIN")
    data.hoverTipsId = record:GetIntValue("HOVER_TIPS_ID")
    data.specRefreshMaxTimes = record:GetIntValue("MAX_FREE_REFRESH_TIMES")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetOneGoodsDataById = function(id)
  local retData = MysteryStoreUtil.GetGoodsCfgById(id)
  local itemBaseCfg = ItemUtils.GetItemBase(retData.itemId)
  retData.ItemName = itemBaseCfg.name
  retData.icon = itemBaseCfg.icon
  retData.itemTypeName = itemBaseCfg.itemTypeName
  retData.useLevel = itemBaseCfg.useLevel
  retData.desc = itemBaseCfg.desc
  return retData
end
def.static("number", "=>", "table").GetConstCfgByShopType = function(shopType)
  local allConsts = MysteryStoreUtil.GetAllConstCfg()
  for i = 1, #allConsts do
    if allConsts[i].shopType == shopType then
      return allConsts[i]
    end
  end
  return nil
end
return MysteryStoreUtil.Commit()
