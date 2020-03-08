local Lplus = require("Lplus")
local CommercePitchUtils = Lplus.Class("CommercePitchUtils")
local Vector = require("Types.Vector")
local ItemUtils = require("Main.Item.ItemUtils")
local CommerceData, instance
local def = CommercePitchUtils.define
def.field("table").constTbl = nil
def.static("=>", CommercePitchUtils).Instance = function()
  if nil == instance then
    instance = CommercePitchUtils()
    instance.constTbl = {}
    instance:InitConstTbl()
  end
  return instance
end
def.static("string", "userdata", "number").FillIcon = function(iconId, uiSprite, i)
  local atlas = CommercePitchUtils.GetAtlasName(i)
  GameUtil.AsyncLoad(atlas, function(obj)
    if obj ~= nil and obj.isnil == false then
      local atlas = obj:GetComponent("UIAtlas")
      if atlas ~= nil then
        uiSprite:set_atlas(atlas)
        uiSprite:set_spriteName(iconId)
      end
    end
  end)
end
def.static("number", "=>", "string").GetAtlasName = function(i)
  if 0 == i then
    return RESPATH.COMMONATLAS
  elseif 1 == i then
    return RESPATH.BAGATLAS
  end
end
def.static("userdata", "userdata", "number", "string").CreateNewGroup = function(groupNew, gridTemplate, count, name)
  groupNew:set_name(string.format(name, count))
  groupNew.parent = gridTemplate
  groupNew:set_localScale(Vector.Vector3.one)
  groupNew:SetActive(true)
end
def.static("number", "string", "userdata").DeleteLastGroup = function(listNum, groupName, gridTemplate)
  if 1 == listNum then
    gridTemplate:FindDirect(groupName):SetActive(false)
  elseif listNum > 1 then
    local template = gridTemplate:GetChild(listNum - 1)
    Object.Destroy(template)
  end
end
def.static("number", "string", "userdata", "userdata").AddLastGroup = function(listNum, groupName, gridTemplate, groupTemplate)
  if 1 == listNum then
    groupTemplate:SetActive(true)
    return
  end
  local groupNew = Object.Instantiate(groupTemplate)
  CommercePitchUtils.CreateNewGroup(groupNew, gridTemplate, listNum, groupName)
  groupNew:SetActive(true)
end
def.static("number", "=>", "string", "number").GetGroupInfo = function(group)
  local name = ""
  local iconId = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_GROUP_INFO_CFG, group)
  if nil ~= record then
    name = record:GetStringValue("name")
    iconId = record:GetIntValue("iconId")
  end
  return name, iconId
end
def.static("number", "=>", "string", "number").GetItemInfo = function(itemId)
  local name = ""
  local iconId = 0
  local record = require("Main.Item.ItemUtils").GetItemBase(itemId)
  if nil ~= record then
    name = record.name
    iconId = record.icon
  end
  return name, iconId
end
def.method().InitConstTbl = function(self)
  local record
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "SERVICE_OPEN_LEVEL")
  self.constTbl.pitchOpenLv = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "RECOMMAND_PRICE_UPDATE_INTERVAL")
  self.constTbl.recommendPriceUpdateInterval = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "FREE_REFRESH_TIME_COUNTER")
  self.constTbl.refeshTimeCounter = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "DEFAULT_REFRESH_INTERVAL")
  self.constTbl.refreshInterval = DynamicRecord.GetIntValue(record, "value") * 60
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "SELF_REFRESH_NEED_GOLD")
  self.constTbl.refreshNeedGold = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "DEFAULT_POS_NUM")
  self.constTbl.defaultPosNum = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "EXPEND_TANWEI_NEED_YUANBAO")
  self.constTbl.extendTanweiNeedYuanbao = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "BAITAN_FEE_RATE")
  self.constTbl.baitanFreeRate = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "SINGLE_ADD_PRICE_RATE")
  self.constTbl.singleAddPriceRate = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "HIGH_PRICE_RATE_LIMIT")
  self.constTbl.highPriceRateLimit = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "LOW_PRICE_RATE_LIMIT")
  self.constTbl.lowPriceRateLimit = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "MAX_BAITAN_GRID_LIMIT")
  self.constTbl.maxBaitanGridLimit = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "TAX_TIPS")
  self.constTbl.taxTipsId = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "BATAN_COST_TIPS")
  self.constTbl.serviceTipsId = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, "ITEM_STOCK_NUM")
  self.constTbl.onSellMaxNumPerGrid = DynamicRecord.GetIntValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_CONSTS_CFG, "OPEN_LEVEL")
  self.constTbl.commerceOpenLv = DynamicRecord.GetFloatValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_CONSTS_CFG, "MoneyType")
  self.constTbl.moneyType = DynamicRecord.GetFloatValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_CONSTS_CFG, "CLIENT_REQUIRE_REFRESH_TIME")
  self.constTbl.clientRequireRefreshTime = DynamicRecord.GetFloatValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_CONSTS_CFG, "STOP_RISE_BUY_RATE")
  self.constTbl.stopRiseBuyRate = DynamicRecord.GetFloatValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_CONSTS_CFG, "STOP_FALL_SELL_RATE")
  self.constTbl.stopFallSellRate = DynamicRecord.GetFloatValue(record, "value")
  record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_CONSTS_CFG, "PRICE_DAY_MAX_FLOW_LIMIT")
  self.constTbl.priceDayMaxFlowLimit = DynamicRecord.GetFloatValue(record, "value")
end
def.static("string", "=>", "dynamic").GetPitchConstant = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_CONST_CFG, key)
  if record == nil then
    Debug.LogError(string.format("CommercePitchUtils.GetPitchConstant(%s) return nil", key))
    return nil
  end
  return record:GetIntValue("value")
end
def.static("=>", "number").GetOnSellMaxNumPerGrid = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.onSellMaxNumPerGrid
end
def.static("=>", "number").GetPitchTaxTipsId = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.taxTipsId
end
def.static("=>", "number").GetPitchServiceTipsId = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.serviceTipsId
end
def.static("=>", "number").GetPitchOpenLevel = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.pitchOpenLv
end
def.static("=>", "number").GetRecommandPriceUpdateInterval = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.recommendPriceUpdateInterval
end
def.static("=>", "number").GetPitchFreeRefeshTime = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.refeshTimeCounter
end
def.static("=>", "number").GetPitchAutoRefeshTime = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.refreshInterval
end
def.static("=>", "number").GetPitchRefeshNeedGold = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.refreshNeedGold
end
def.static("=>", "number").GetDefaultStallNum = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.defaultPosNum
end
def.static("=>", "number").GetExpendStallCostYuanBao = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.extendTanweiNeedYuanbao
end
def.static("=>", "number").GetStallServiceMoneyRate = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.baitanFreeRate
end
def.static("=>", "number").GetOnceAdjustPriceRate = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.singleAddPriceRate
end
def.static("=>", "number").GetAdjustPriceRateMax = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.highPriceRateLimit
end
def.static("=>", "number").GetAdjustPriceRateMin = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.lowPriceRateLimit
end
def.static("=>", "number").GetStallMax = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.maxBaitanGridLimit
end
def.static("=>", "number").GetCommerceOpenLevel = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.commerceOpenLv
end
def.static("=>", "number").GetCommerceMoneyType = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.moneyType
end
def.static("=>", "number").GetCommerceRequireRefeshTime = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.clientRequireRefreshTime
end
def.static("=>", "number").GetCommerceUpStopBuyRate = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.stopRiseBuyRate
end
def.static("=>", "number").GetCommerceDownStopSellRate = function()
  local self = CommercePitchUtils.Instance()
  return self.constTbl.stopFallSellRate
end
def.static("number", "=>", "number").ItemIdToConditionId = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_ITEMID_TO_CONDITIONID_CFG, itemId)
  if nil ~= record then
    return DynamicRecord.GetIntValue(record, "conditionId")
  else
    return 0
  end
end
def.static("number", "=>", "number", "number").ItemConditionIdToGroup = function(id)
  local data = require("Main.CommerceAndPitch.data.PitchData").Instance()
  local big, small = data:GetGroupInfoByItemConditionId(id)
  return big, small
end
def.static("number", "=>", "table").GetPitchEquipConditionInfo = function(id)
  local info
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_EQUIPMENT_CONDITION_CFG, id)
  if record ~= nil then
    info = {}
    info.itemSiftId = DynamicRecord.GetIntValue(record, "itemSiftId")
    info.needHunMinNum = DynamicRecord.GetIntValue(record, "needHunMinNum")
    info.needHunMaxNum = DynamicRecord.GetIntValue(record, "needHunMaxNum")
    info.needHunMinQlt = DynamicRecord.GetIntValue(record, "needHunMinQlt")
    info.needHunMaxQlt = DynamicRecord.GetIntValue(record, "needHunMaxQlt")
    info.isShowNeedSign = DynamicRecord.GetCharValue(record, "isShowNeedSign") ~= 0
  end
  return info
end
def.static("number", "table", "number", "=>", "boolean").CanPitchEquipConditonPass = function(itemId, item, idValue)
  local bPass = false
  local itemBase = ItemUtils.GetItemBase(itemId)
  local info = CommercePitchUtils.GetPitchEquipConditionInfo(idValue)
  local bExproCountPass = true
  local bExproColorPass = false
  local exproCount = #item.exproList
  if exproCount < info.needHunMinNum or exproCount > info.needHunMaxNum then
    bExproCountPass = false
  elseif exproCount > 0 then
    local equipModule = require("Main.Equip.EquipModule")
    local EquipUtils = require("Main.Equip.EquipUtils")
    local equipBase = ItemUtils.GetEquipBase(itemId)
    for i = 1, exproCount do
      local exproValue, realVal = equipModule.GetProRealValue(item.exproList[i].proType, item.exproList[i].proValue)
      local pro = equipModule.GetProTypeID(item.exproList[i].proType)
      local colorId = EquipUtils.GetColor(item.exproList[i].proValue)
      if bExproColorPass == false and colorId >= info.needHunMinQlt and colorId <= info.needHunMaxQlt then
        bExproColorPass = true
      end
    end
  else
    bExproColorPass = true
  end
  if bExproCountPass and bExproColorPass then
    bPass = true
  else
    bPass = false
  end
  return bPass
end
def.static("number", "table", "=>", "boolean").CanItemPitchToSell = function(itemId, item)
  local IdType = require("consts.mzm.gsp.baitan.confbean.IdType")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local isBind = ItemUtils.IsItemBind(item)
  local big, small = CommercePitchUtils.ItemConditionIdToGroup(itemId)
  local bCanSell = false
  if 0 ~= big and 0 ~= small then
    if itemBase.isProprietary or isBind then
      bCanSell = false
    else
      bCanSell = true
      local tbl = require("Main.CommerceAndPitch.data.PitchData").Instance():GetEquipPitchIdByItemConditionId(itemId)
      for k, v in pairs(tbl) do
        if v.type == IdType.EQUIPITEMSHIFTID then
          bCanSell = CommercePitchUtils.CanPitchEquipConditonPass(itemId, item, v.idVal)
          if bCanSell then
            break
          end
        end
      end
    end
  else
    local conditionId = CommercePitchUtils.ItemIdToConditionId(itemId)
    if 0 ~= conditionId then
      if itemBase.isProprietary or isBind then
        bCanSell = false
      else
        bCanSell = true
        local tbl = require("Main.CommerceAndPitch.data.PitchData").Instance():GetEquipPitchIdByItemConditionId(conditionId)
        for k, v in pairs(tbl) do
          if v.type == IdType.EQUIPITEMSHIFTID then
            bCanSell = CommercePitchUtils.CanPitchEquipConditonPass(itemId, item, v.idVal)
            if bCanSell then
              break
            end
          end
        end
      end
    else
      bCanSell = false
    end
  end
  return bCanSell
end
def.static("=>", "table").GetItemsCanSellToCommerce = function()
  local itemIds = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_COMMERCE_ITEM_TO_GROUP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local itemid = record:GetIntValue("itemId")
    itemIds[itemid] = true
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return itemIds
end
def.static("number", "=>", "number").ItemIdToGroupId = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_ITEM_TO_GROUP_CFG, itemId)
  if nil ~= record then
    return DynamicRecord.GetIntValue(record, "bigTypeId")
  else
    return 0
  end
end
def.static("number", "=>", "number", "number").ItemIdToCommerceGroupId = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_ITEM_TO_GROUP_CFG, itemId)
  if nil ~= record then
    return DynamicRecord.GetIntValue(record, "bigTypeId"), DynamicRecord.GetIntValue(record, "SubTypeId")
  else
    return 0, 0
  end
end
def.static("number", "table", "=>", "boolean").CanItemCommerceToSell = function(itemId, item)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local isBind = ItemUtils.IsItemBind(item)
  if 0 ~= CommercePitchUtils.ItemIdToGroupId(itemId) then
    if itemBase.isProprietary or isBind then
      return false
    else
      return true
    end
  else
    return false
  end
end
def.static("number", "=>", "boolean").IsItemId = function(itemId)
  local record = require("Main.Item.ItemUtils").GetItemBase(itemId)
  if nil ~= record then
    return true
  else
    return false
  end
end
def.static("table", "userdata", "=>", "table").FillPitchBuyNodeUI = function(uiTbl, node)
  uiTbl = {}
  local Group_BuyList01 = node:FindDirect("Group_BuyList01")
  local ScrollView_BugList = Group_BuyList01:FindDirect("Scroll View_BugList")
  local Table_BugList = ScrollView_BugList:FindDirect("Table_BugList")
  local Tab_1 = Table_BugList:FindDirect("Tab_1")
  uiTbl.ScrollView_BugList = ScrollView_BugList
  uiTbl.Table_BugList = Table_BugList
  uiTbl.Tab_1 = Tab_1
  local Btn_Select = node:FindDirect("Btn_Select")
  uiTbl.Btn_Select = Btn_Select
  local Img_BgBuyItem = node:FindDirect("Img_BgBuyItem")
  local Group_Empty = Img_BgBuyItem:FindDirect("Group_Empty")
  local Group_Empty1 = Img_BgBuyItem:FindDirect("Group_Empty1")
  local ScrollView_BuyItem = Img_BgBuyItem:FindDirect("Scroll View_BuyItem")
  local Grid_Page = ScrollView_BuyItem:FindDirect("Grid_Page")
  local Page01 = Grid_Page:FindDirect("Page01")
  local Grid_BuyItem = Page01:FindDirect("Grid_BuyItem")
  local Group_BuyItem = Grid_BuyItem:FindDirect("Group_BuyItem")
  if Grid_Page then
    local cochild = Grid_Page:GetComponent("UICenterOnChild")
    if cochild then
      cochild.enabled = false
    end
  end
  uiTbl.Grid_Page = Grid_Page
  uiTbl.Page01 = Page01
  uiTbl.Grid_BuyItem = Grid_BuyItem
  uiTbl.Group_BuyItem = Group_BuyItem
  uiTbl.Group_Empty = Group_Empty
  uiTbl.Group_Empty1 = Group_Empty1
  uiTbl.ScrollView_BuyItem = ScrollView_BuyItem
  local Img_BgMoney = node:FindDirect("Img_BgMoney")
  local Label_MoneyNum
  if Img_BgMoney then
    Label_MoneyNum = Img_BgMoney:FindDirect("Label_MoneyNum")
  end
  local Group_BtnBuy = node:FindDirect("Group_BtnBuy")
  local Img_BgMoney = Group_BtnBuy:FindDirect("Img_BgMoney")
  local Group_Time = Group_BtnBuy:FindDirect("Group_Time")
  local Label_Time = Group_Time:FindDirect("Label_Time")
  local Btn_Refresh = Group_BtnBuy:FindDirect("Btn_Refresh")
  local Label_Refresh = Btn_Refresh:FindDirect("Label_Refresh")
  local Group_MoneyRefresh = Btn_Refresh:FindDirect("Group_MoneyRefresh")
  local Img_BgPage = Group_BtnBuy:FindDirect("Img_BgPage")
  local Label_Page = Img_BgPage:FindDirect("Label_Page")
  local Btn_Lv_Menu = Group_BtnBuy:FindDirect("Scroll_View/Btn_Lv_Menu")
  uiTbl.Group_BtnBuy = Group_BtnBuy
  uiTbl.Label_MoneyNum = Label_MoneyNum
  uiTbl.Label_Time = Label_Time
  uiTbl.Label_Refresh = Label_Refresh
  uiTbl.Group_MoneyRefresh = Group_MoneyRefresh
  uiTbl.Label_Page = Label_Page
  uiTbl.Btn_Lv_Menu = Btn_Lv_Menu
  return uiTbl
end
def.static("table", "userdata", "=>", "table").FillPitchSellNodeUI = function(uiTbl, node)
  uiTbl = {}
  local Img_BgSellItem = node:FindDirect("Img_BgSellItem")
  local ScrollView_SellItem = Img_BgSellItem:FindDirect("Scroll View_SellItem")
  local Grid_SellItem = ScrollView_SellItem:FindDirect("Grid_SellItem")
  local Img_BgSellItem01 = Grid_SellItem:FindDirect("Img_BgSellItem01")
  uiTbl.Grid_SellItem = Grid_SellItem
  uiTbl.Img_BgSellItem01 = Img_BgSellItem01
  local Group_BtnSell = node:FindDirect("Group_BtnSell")
  local Img_BgMoney = Group_BtnSell:FindDirect("Img_BgMoney")
  local Label_MoneyNum = Img_BgMoney:FindDirect("Label_MoneyNum")
  uiTbl.Label_MoneyNum = Label_MoneyNum
  local Btn_Sell = Group_BtnSell:FindDirect("Btn_Sell")
  local Label_Sell = Btn_Sell:FindDirect("Label_Sell")
  uiTbl.Label_Sell = Label_Sell
  return uiTbl
end
def.static("number", "=>", "number", "number", "number").GetItemPitchInfo = function(itemId)
  local recommendPrice = 0
  local minPrice = 0
  local maxPrice = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_PRICE_CFG, itemId)
  if nil ~= record then
    recommendPrice = record:GetIntValue("baiTanSilverNum")
    minPrice = record:GetIntValue("baiTanMinSilver")
    maxPrice = record:GetIntValue("baiTanMaxSilver")
  end
  return recommendPrice, minPrice, maxPrice
end
def.static("table", "userdata", "=>", "table").FillPitchItemOnShelfUI = function(uiTbl, node)
  uiTbl = {}
  local Group_Item0 = node:FindDirect("Group_Item0")
  local Group_Empty = node:FindDirect("Group_Empty")
  uiTbl.Group_Item0 = Group_Item0
  uiTbl.Group_Empty = Group_Empty
  local Group_Bag = Group_Item0:FindDirect("Group_Bag")
  local Img_BgBag = Group_Bag:FindDirect("Img_BgBag")
  local ScrollView_Bag = Img_BgBag:FindDirect("Scroll View_Bag")
  local Grid_Bag = ScrollView_Bag:FindDirect("Grid_Bag")
  local Img_BgBagItem01 = Grid_Bag:FindDirect("Img_BgBagItem01")
  uiTbl.Grid_Bag = Grid_Bag
  uiTbl.Img_BgBagItem01 = Img_BgBagItem01
  local Img_BgItemMoney = node:FindDirect("Img_BgItemMoney")
  local Label_MoneyNum = Img_BgItemMoney:FindDirect("Label_MoneyNum")
  uiTbl.Label_MoneyNum = Label_MoneyNum
  local Img_BgItemNum = node:FindDirect("Img_BgItemNum")
  local Label_ItemNum = Img_BgItemNum:FindDirect("Label_ItemNum")
  uiTbl.Label_ItemNum = Label_ItemNum
  local Group_None = Group_Item0:FindDirect("Group_None")
  uiTbl.Group_None = Group_None
  local Group_Right = Group_Item0:FindDirect("Group_Right")
  uiTbl.Group_Right = Group_Right
  return uiTbl
end
def.static("table", "userdata", "=>", "table").FillCommerceUI = function(uiTbl, node)
  uiTbl = {}
  local Group_CommerceList = node:FindDirect("Group_CommerceList")
  local ScrollView_Commerce = Group_CommerceList:FindDirect("Scroll View_Commerce")
  local Table_List = ScrollView_Commerce:FindDirect("Table_List")
  local Tab_1 = Table_List:FindDirect("Tab_1")
  uiTbl.ScrollView_Commerce = ScrollView_Commerce
  uiTbl.Table_List = Table_List
  uiTbl.Tab_1 = Tab_1
  local Group_ComItem = node:FindDirect("Group_ComItem")
  local ScrollView_BgComItem = Group_ComItem:FindDirect("Img_BgComItem/Scroll View_BgComItem")
  local Grid_BgComItem = ScrollView_BgComItem:FindDirect("Grid_BgComItem")
  local Group_ComItem01 = Grid_BgComItem:FindDirect("Group_ComItem01")
  uiTbl.Grid_BgComItem = Grid_BgComItem
  uiTbl.Group_ComItem01 = Group_ComItem01
  uiTbl.ScrollView_BgComItem = ScrollView_BgComItem
  local Group_Page = Group_ComItem:FindDirect("Group_Page")
  local Label_Page = Group_Page:FindDirect("Img_BgPage/Label_Page")
  uiTbl.Label_Page = Label_Page
  local Group_Bag = node:FindDirect("Group_Bag")
  local ScrollView_Bag = Group_Bag:FindDirect("Img_BgBag/Scroll View_Bag")
  local Group_NoItem = Group_Bag:FindDirect("Img_BgBag/Group_NoItem")
  local Grid_Bag = ScrollView_Bag:FindDirect("Grid_Bag")
  local Img_BgBagItem01 = Grid_Bag:FindDirect("Img_BgBagItem01")
  uiTbl.Grid_Bag = Grid_Bag
  uiTbl.Img_BgBagItem01 = Img_BgBagItem01
  uiTbl.Group_NoItem = Group_NoItem
  uiTbl.ScrollView_Bag = ScrollView_Bag
  local Btn_Buy = Group_Bag:FindDirect("Group_BtnBagBug/Btn_Buy")
  local Group_Btn = Group_Bag:FindDirect("Group_BtnBagBug/Group_Btn")
  Btn_Buy:SetActive(true)
  Group_Btn:SetActive(false)
  uiTbl.Btn_Buy = Btn_Buy
  uiTbl.Group_Btn = Group_Btn
  local Group_BtnBagBug = Group_Bag:FindDirect("Group_BtnBagBug")
  local Img_BgBagMoney = Group_BtnBagBug:FindDirect("Img_BgBagMoney")
  local Label_BagMoneyNum = Img_BgBagMoney:FindDirect("Label_BagMoneyNum")
  uiTbl.Label_BagMoneyNum = Label_BagMoneyNum
  return uiTbl
end
def.static("number", "=>", "table").GetCommerceItemInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_ITEM_CFG, itemId)
  local itemInfo
  if nil ~= record then
    itemInfo = {}
    itemInfo.daySellMaxNum = DynamicRecord.GetIntValue(record, "daySellMaxNum")
    itemInfo.dayBuyMaxNum = DynamicRecord.GetIntValue(record, "dayBuyMaxNum")
    itemInfo.openServerLevel = DynamicRecord.GetIntValue(record, "openServerLevel")
    itemInfo.isPriceFlow = DynamicRecord.GetCharValue(record, "isPriceFlow") ~= 0
  end
  return itemInfo
end
def.static("number", "=>", "number").GetCommerceItemOrginialPrice = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_ITEM_CFG, itemId)
  if nil ~= record then
    local orginialPrice = DynamicRecord.GetIntValue(record, "orginialPrice")
    if orginialPrice then
      return orginialPrice
    end
  end
  return 0
end
def.static("number", "=>", "number").GetPriceFlowFormulaId = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_ITEM_CFG, itemId)
  if nil ~= record then
    local priceFlowFormulaId = DynamicRecord.GetIntValue(record, "priceFlowFormulaId")
    if priceFlowFormulaId then
      return priceFlowFormulaId
    end
  end
  return 0
end
def.static("number", "=>", "number", "number").GetItemMinAndMaxPrice = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_ITEM_CFG, itemId)
  local minPrice = 0
  local maxPrice = 0
  if nil ~= record then
    local minPrice = record.GetIntValue("minPrice")
    local maxPrice = record.GetIntValue("maxPrice")
  end
  return minPrice, maxPrice
end
def.static("table", "userdata", "=>", "table").FillPitchVigorOnShelfUI = function(uiTbl, node)
  uiTbl = {}
  local Group_Active0 = node:FindDirect("Group_Active0")
  uiTbl.Group_Active0 = Group_Active0
  local Label_ActiveNum = node:FindDirect("Img_BgActive/Label_ActiveNum")
  uiTbl.Label_ActiveNum = Label_ActiveNum
  local Label_ActiveAddNum = node:FindDirect("Img_BgActiveNum/Label_ActiveAddNum")
  uiTbl.Label_ActiveAddNum = Label_ActiveAddNum
  local Grid_Skill = Group_Active0:FindDirect("Group_Skill/Scroll View_Skill/Grid_Skill")
  uiTbl.Grid_Skill = Grid_Skill
  local Group_Skill01 = Grid_Skill:FindDirect("Group_Skill01")
  uiTbl.Group_Skill01 = Group_Skill01
  local Group_None = Group_Active0:FindDirect("Group_None")
  uiTbl.Group_None = Group_None
  local Group_Right = Group_Active0:FindDirect("Group_Right")
  uiTbl.Group_Right = Group_Right
  return uiTbl
end
local _cfg_cache = {}
def.static("number", "=>", "table").GetPitchSubTypeCfg = function(id)
  if _cfg_cache[id] then
    return _cfg_cache[id]
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PITCH_SUB_TYPE_CFG, id)
  if nil == record then
    warn("GetPitchSubTypeCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.name = DynamicRecord.GetStringValue(record, "name")
  cfg.size = DynamicRecord.GetIntValue(record, "size")
  cfg.iconid = DynamicRecord.GetIntValue(record, "iconid")
  _cfg_cache[id] = cfg
  return cfg
end
local _query_cache
def.static("number", "=>", "string").GetPitchPriceColor = function(price)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  if _query_cache == nil then
    _query_cache = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_PITCH_PRICE_COLOR_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local cfg = {}
      cfg.color = record:GetIntValue("color")
      cfg.minPrice = record:GetIntValue("minPrice")
      cfg.maxPrice = record:GetIntValue("maxPrice")
      table.insert(_query_cache, cfg)
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  local colorEnum = 0
  if price <= 0 then
    return HtmlHelper.NameColor[1]
  end
  for i, v in ipairs(_query_cache) do
    if price <= v.maxPrice and price >= v.minPrice then
      colorEnum = v.color
      break
    end
  end
  local maxColorEnum = #HtmlHelper.NameColor
  if colorEnum == 0 then
    colorEnum = maxColorEnum
  end
  colorEnum = math.min(colorEnum, maxColorEnum)
  return HtmlHelper.NameColor[colorEnum]
end
def.static("number", "=>", "string").GetPitchColoredPriceText = function(price)
  local color = CommercePitchUtils.GetPitchPriceColor(price)
  return string.format("[%s]%s[-]", color, price)
end
def.static("number", "=>", "table").GetPriceFlowFormulaCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMERCE_FLOW_FORMULA_CFG, id)
  if nil == record then
    warn("!!!!!GetPriceFlowFormulaCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.riseParamX = record:GetFloatValue("riseParamX")
  cfg.offsetMaxLimitN = record:GetFloatValue("offsetMaxLimitN")
  cfg.sqrtTime1 = record:GetFloatValue("sqrtTime1")
  cfg.riseFormulaScaleParamZ = record:GetFloatValue("riseFormulaScaleParamZ")
  cfg.riseFormulaAjustParam = record:GetFloatValue("riseFormulaAjustParam")
  cfg.fallParamY = record:GetFloatValue("fallParamY")
  cfg.offsetMinM = record:GetFloatValue("offsetMinM")
  cfg.sqrtTime2 = record:GetFloatValue("sqrtTime2")
  cfg.fallFormulaScallParamZ = record:GetFloatValue("fallFormulaScallParamZ")
  cfg.fallFormulaAjustParam = record:GetFloatValue("fallFormulaAjustParam")
  return cfg
end
def.static("number", "number", "number", "=>", "number", "number").CalcCommerceItemPrice = function(itemId, price, rise)
  local flowId = CommercePitchUtils.GetPriceFlowFormulaId(itemId)
  local flowCfg = CommercePitchUtils.GetPriceFlowFormulaCfg(flowId)
  if CommerceData == nil then
    CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
  end
  local calcInfo = CommerceData.Instance():GetCalcItemPriceInfo(itemId)
  if flowCfg == nil or calcInfo == nil then
    return price, rise
  end
  local recommendPrice = calcInfo.recommandPrice
  local p = (price - recommendPrice) / recommendPrice
  local adjustParam = 1
  if p < 0 then
    adjustParam = flowCfg.riseFormulaAjustParam
  end
  local riseFluctuate = flowCfg.riseParamX * flowCfg.fallFormulaScallParamZ * math.pow(flowCfg.offsetMaxLimitN - p * adjustParam, flowCfg.sqrtTime1)
  local newRise = rise + riseFluctuate * 10000
  local buyRate = 1
  if newRise >= instance.constTbl.priceDayMaxFlowLimit then
    buyRate = instance.constTbl.stopRiseBuyRate
  end
  local nowPrice = calcInfo.orgDayPrice * (rise + 10000) / 10000 * buyRate
  local minPrice, maxPrice = CommercePitchUtils.GetItemMinAndMaxPrice(itemId)
  if minPrice ~= 0 and nowPrice < minPrice then
    nowPrice = minPrice
  end
  if maxPrice ~= 0 and maxPrice < nowPrice then
    nowPrice = maxPrice
  end
  return math.floor(nowPrice), math.floor(newRise)
end
CommercePitchUtils.Commit()
return CommercePitchUtils
