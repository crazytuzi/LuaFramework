local Lplus = require("Lplus")
local TradingArcadeUtils = Lplus.Class("TradingArcadeUtils")
local def = TradingArcadeUtils.define
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local GUIUtils = require("GUI.GUIUtils")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local HeroInterface = require("Main.Hero.Interface")
def.static("=>", "table").GetMarketCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MARKET_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = TradingArcadeUtils._GetMarketBigTypeCfg(entry)
    list[#list + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(list, function(l, r)
    return l.sort < r.sort
  end)
  return list
end
def.static("number", "=>", "table").GetMarketBigTypeCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARKET_CFG, id)
  if record == nil then
    warn("GetMarketBigTypeCfg(" .. id .. ") return nil")
    return nil
  end
  return TradingArcadeUtils._GetMarketBigTypeCfg(record)
end
def.static("userdata", "=>", "table")._GetMarketBigTypeCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.sort = record:GetIntValue("sort") or 0
  cfg.subIds = {}
  local idListStruct = record:GetStructValue("subidlistStruct")
  local size = idListStruct:GetVectorSize("subidlistVector")
  for i = 0, size - 1 do
    local vectorRow = idListStruct:GetVectorValueByIdx("subidlistVector", i)
    local subId = vectorRow:GetIntValue("subId")
    table.insert(cfg.subIds, subId)
  end
  return cfg
end
def.static("number", "=>", "table").GetMarketSubTypeCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARKET_SUB_CFG, id)
  if record == nil then
    warn("GetMarketSubTypeCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.iconId = record:GetIntValue("iconId")
  cfg.name = record:GetStringValue("name")
  cfg.needlevel = record:GetIntValue("needlevel")
  cfg.ispricesort = record:GetCharValue("ispricesort") == 1
  cfg.islevelsift = record:GetCharValue("islevelsift") == 1
  cfg.maxsellnum = record:GetIntValue("maxsellnum")
  cfg.initLevel = record:GetIntValue("initLevel")
  cfg.levelDelta = record:GetIntValue("levelDelta")
  cfg.maxLevel = record:GetIntValue("maxLevel")
  cfg.marketCfgId = record:GetIntValue("marketCfgId")
  cfg.sort = record:GetIntValue("sort") or 0
  cfg.isAsc = record:GetCharValue("isAsc") == 1
  return cfg
end
def.static("number", "=>", "boolean").IsItemSubType = function(subid)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARKET_ITEM_SUB_IDS_CFG, subid)
  if record == nil then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").IsPetSubType = function(subid)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARKET_PET_SUB_IDS_CFG, subid)
  if record == nil then
    return false
  end
  return true
end
def.static("number", "=>", "table").GetMarketItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARKET_ITEM_CFG, itemId)
  if record == nil then
    return nil
  end
  local cfg = TradingArcadeUtils._GetMarketItemCfg(record)
  return cfg
end
def.static("=>", "table").GetAllMarketItemCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MARKET_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = TradingArcadeUtils._GetMarketItemCfg(entry)
    list[#list + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("userdata", "=>", "table")._GetMarketItemCfg = function(record)
  local cfg = {}
  cfg.itemid = record:GetIntValue("itemid")
  cfg.subid = record:GetIntValue("subid")
  cfg.minprice = record:GetIntValue("minprice")
  cfg.maxprice = record:GetIntValue("maxprice")
  cfg.frozenTime = record:GetIntValue("forzentime") or 0
  return cfg
end
def.static("number", "=>", "table").GetMarketPetCfg = function(petId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARKET_PET_CFG, petId)
  if record == nil then
    return nil
  end
  local cfg = TradingArcadeUtils._GetMarketPetCfg(record)
  return cfg
end
def.static("=>", "table").GetAllMarketPetCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MARKET_PET_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = TradingArcadeUtils._GetMarketPetCfg(entry)
    list[#list + 1] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("userdata", "=>", "table")._GetMarketPetCfg = function(record)
  local cfg = {}
  cfg.petid = record:GetIntValue("petid")
  cfg.subid = record:GetIntValue("subid")
  cfg.minprice = record:GetIntValue("minprice")
  cfg.maxprice = record:GetIntValue("maxprice")
  cfg.frozenTime = record:GetIntValue("forzentime") or 0
  cfg.minPoint = record:GetIntValue("minPoint") or 0
  return cfg
end
def.static("number", "=>", "table").GetMultiMarketPetPriceCfg = function(xml_data_type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARKET_MULTI_PET_PRICE_CFG, xml_data_type)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.pet_price_skill_num_param = record:GetIntValue("pet_price_skill_num_param")
  cfg.pet_price_skill_num_power_param = record:GetIntValue("pet_price_skill_num_power_param")
  cfg.pet_price_skill_num_ratio_param = record:GetIntValue("pet_price_skill_num_ratio_param")
  cfg.pet_max_price_param = record:GetFloatValue("pet_max_price_param")
  return cfg
end
local needQueryTypes = {
  [ItemType.EQUIP] = true,
  [ItemType.PET_EQUIP] = true,
  [ItemType.FABAO_ITEM] = true
}
def.static("number", "=>", "boolean").NeedQueryItemDetail = function(itemId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase and needQueryTypes[itemBase.itemType] then
    return true
  else
    return false
  end
end
def.static("table", "=>", "number").GetItemUnfreezeTime = function(item)
  if item.extraInfoMap == nil then
    return 0
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local buyTime = item.extraInfoMap[ItemXStoreType.MARKET_BUY_TIME]
  if buyTime == nil then
    return 0
  end
  buyTime = Int64.ToNumber(buyTime)
  local frozenDuration = 0
  local marketItemCfg = TradingArcadeUtils.GetMarketItemCfg(item.id)
  if marketItemCfg then
    frozenDuration = marketItemCfg.frozenTime
  end
  local unfreezeTime = buyTime + frozenDuration
  return unfreezeTime
end
def.static("table", "=>", "boolean").IsItemFrozen = function(item)
  return _G.GetServerTime() < TradingArcadeUtils.GetItemUnfreezeTime(item)
end
def.static("table", "=>", "number").GetPetUnfreezeTime = function(pet)
  local buyTime = Int64.ToNumber(pet.marketbuytime)
  local frozenDuration = 0
  local marketPetCfg = TradingArcadeUtils.GetMarketPetCfg(pet.typeId)
  if marketPetCfg then
    frozenDuration = marketPetCfg.frozenTime
  end
  local unfreezeTime = buyTime + frozenDuration
  return unfreezeTime
end
def.static("table", "=>", "boolean").IsPetFrozen = function(pet)
  return _G.GetServerTime() < TradingArcadeUtils.GetPetUnfreezeTime(pet)
end
def.static("userdata", "number").SetPriceLabel = function(label, price)
  local GUIUtils = require("GUI.GUIUtils")
  local text = CommercePitchUtils.GetPitchColoredPriceText(price)
  GUIUtils.SetText(label, text)
end
def.static("=>", "number").GetOpenLevel = function()
  return _G.constant.MarketConsts.ROLE_LEVEL_FOR_OPEN_MARKET
end
def.static("=>", "boolean").CheckOpen = function()
  return TradingArcadeUtils.CheckOpenEx(false)
end
def.static("boolean", "=>", "boolean").CheckOpenEx = function(isSilent)
  local _Toast = Toast
  local function Toast(...)
    if not isSilent then
      _Toast(...)
    end
  end
  if isSilent and _G.IsCrossingServer() then
    return false
  end
  if _G.CheckCrossServerAndToast() then
    return false
  end
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_MARKET) then
    Toast(textRes.TradingArcade[40])
    return false
  end
  local openLevel = TradingArcadeUtils.GetOpenLevel()
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  if openLevel > heroLevel then
    Toast(string.format(textRes.TradingArcade[38], openLevel))
    return false
  end
  return true
end
def.static("=>", "boolean").IsUnshelveBidGoodsChargeFeatureOpen = function()
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_MARKET_AUCTION_GOODS_CUT_GOLD)
  return isOpen
end
def.static("=>", "number").GetCurrentPublicTime = function()
  local MarketConsts = _G.constant.MarketConsts
  local serverTime = _G.GetServerTime()
  local publicEndTime = serverTime + MarketConsts.PUBLIC_TIME * 60
  local endHour = tonumber(os.date("%H", publicEndTime))
  local endMinute = tonumber(os.date("%M", publicEndTime))
  endHour = endHour + endMinute / 60
  local additionalHour = 0
  if endHour >= MarketConsts.FORBIDDEN_ON_SHELF_START_HOUR and endHour < MarketConsts.FORBIDDEN_ON_SHELF_END_HOUR then
    additionalHour = MarketConsts.FORBIDDEN_ON_SHELF_END_HOUR - endHour
  end
  local publicTime = MarketConsts.PUBLIC_TIME + require("Common.MathHelper").Ceil(additionalHour * 60)
  return publicTime
end
def.static("number", "=>", "table").GetLevelSiftConditions = function(subId)
  local subTypeCfg = TradingArcadeUtils.GetMarketSubTypeCfg(subId)
  if subTypeCfg == nil then
    return {}
  end
  local MIN_LEVEL = subTypeCfg.initLevel
  local LEVEL_STEP = subTypeCfg.levelDelta
  local MAX_LEVEL = subTypeCfg.maxLevel
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
def.static("number", "=>", "string").GetTradingPriceColor = function(price)
  return CommercePitchUtils.GetPitchPriceColor(price)
end
def.static("table", "=>", "number").GetPetOnSellMinPrice = function(pet)
  local params = TradingArcadeUtils.GetPetPriceParams({
    "pet_price_skill_num_param",
    "pet_price_skill_num_power_param",
    "pet_price_skill_num_ratio_param"
  })
  local NUM_PARAM = params.pet_price_skill_num_param
  local NUM_POWER_PARAM = params.pet_price_skill_num_power_param
  local NUM_RATIO_PARAM = params.pet_price_skill_num_ratio_param
  local yaoliCfg = pet:GetPetYaoLiCfg()
  local scorePrice = yaoliCfg and yaoliCfg.marketPriceLimit or 0
  local petSkillNum = #pet:GetSkillIdList()
  local price = scorePrice + math.max(0, petSkillNum - NUM_PARAM) ^ NUM_POWER_PARAM * NUM_RATIO_PARAM
  return require("Common.MathHelper").Floor(price)
end
def.static("table", "=>", "number").GetPetOnSellMaxPrice = function(pet)
  local minPrice = TradingArcadeUtils.GetPetOnSellMinPrice(pet)
  local SCALE_FACTOR = TradingArcadeUtils.GetPetPriceParams({
    "pet_max_price_param"
  }).pet_max_price_param
  local maxPrice = require("Common.MathHelper").Floor(minPrice * SCALE_FACTOR)
  return maxPrice
end
def.static("table", "=>", "number").GetItemOnSellMaxPrice = function(item)
  local itemId = item.id
  local HUGE_PRICE = _G.constant.MarketConsts.MARKET_ITEM_MAX_PRICE or 100000000
  local marketItemCfg = TradingArcadeUtils.GetMarketItemCfg(itemId)
  local maxprice = marketItemCfg and marketItemCfg.maxprice or HUGE_PRICE
  HUGE_PRICE = math.max(HUGE_PRICE, maxprice)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  if item.extraMap and item.extraMap[ItemXStoreType.EQUIP_SKILL] then
    return HUGE_PRICE
  else
    return maxprice
  end
end
def.static("table", "=>", "table").GetPetPriceParams = function(attrs)
  local params = {}
  local attrNameMapConstName = {
    pet_price_skill_num_param = "PET_PRICE_SKILL_NUM_PARAM",
    pet_price_skill_num_power_param = "PET_PRICE_SKILL_NUM_POWER_PARAM",
    pet_price_skill_num_ratio_param = "PET_PRICE_SKILL_NUM_RATIO_PARAM",
    pet_max_price_param = "PET_MAX_PRICE_PARAM"
  }
  local MultiXmlHelper = require("Main.Common.MultiXmlHelper")
  local xml_data_type = MultiXmlHelper.GetXmlDataType()
  local multiPetPriceCfg
  if xml_data_type >= 0 then
    multiPetPriceCfg = TradingArcadeUtils.GetMultiMarketPetPriceCfg(xml_data_type)
  end
  for i, attrName in ipairs(attrs) do
    if multiPetPriceCfg then
      params[attrName] = multiPetPriceCfg[attrName]
    else
      local constName = attrNameMapConstName[attrName]
      if constName then
        params[attrName] = _G.constant.MarketConsts[constName]
      end
    end
  end
  return params
end
def.static("table").ShowGoodsStateRoleNum = function(goods)
  local textTable = {}
  local text
  if goods.bidRoleNum > 0 then
    text = string.format(textRes.TradingArcade[74], goods.bidRoleNum)
    table.insert(textTable, text)
  end
  if 0 < goods.concernRoleNum then
    text = string.format(textRes.TradingArcade[45], goods.concernRoleNum)
    table.insert(textTable, text)
  end
  local text = table.concat(textTable, "<br/>")
  Toast(text)
end
def.static("table", "table").ShowShareOptionsPanel = function(context, pos)
  local operations = {
    require("Main.Item.Operations.OperationMarketShareWorld")(),
    require("Main.Item.Operations.OperationMarketShareTeam")(),
    require("Main.Item.Operations.OperationMarketShareGang")()
  }
  local featureType = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MARKET_SHARE_GROUP_CHAT
  if _G.IsFeatureOpen(featureType) then
    table.insert(operations, 2, require("Main.Item.Operations.OperationMarketShareGroup")())
  end
  local btns = {}
  for i, v in ipairs(operations) do
    local btn = {
      name = v:GetOperationName()
    }
    btns[#btns + 1] = btn
  end
  require("GUI.ButtonGroupPanel").ShowPanel(btns, pos, function(index)
    local operation = operations[index]
    return operation:Operate(0, 0, nil, context)
  end)
end
return TradingArcadeUtils.Commit()
