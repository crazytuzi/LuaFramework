local Lplus = require("Lplus")
local TurnedCardUtils = Lplus.Class("TurnedCardUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = TurnedCardUtils.define
def.const("number").PurpleLevel = 4
def.const("table").TurnedCardLevelFrame = {
  [0] = "Cell_00",
  [1] = "Cell_01",
  [2] = "Cell_02",
  [3] = "Cell_03",
  [4] = "Cell_04",
  [5] = "Cell_05",
  [6] = "Cell_08"
}
def.const("table").TurnedCardModelFrame = {
  [0] = "Img_Card01",
  [1] = "Img_Card01",
  [2] = "Img_Card02",
  [3] = "Img_Card03",
  [4] = "Img_Card04",
  [5] = "Img_Card05",
  [6] = "Img_Card06"
}
def.const("table").TurnedCardLevelTitle = {
  [0] = "Img_Card01Title",
  [1] = "Img_Card01Title",
  [2] = "Img_Card02Title",
  [3] = "Img_Card03Title",
  [4] = "Img_Card04Title",
  [5] = "Img_Card05Title",
  [6] = "Img_Card06Title"
}
def.static("number", "=>", "table").GetChangeModelCardCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANGE_MODEL_CARD_CFG, id)
  if record == nil then
    warn("!!!!!GetChangeModelCardCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.cardName = record:GetStringValue("cardName")
  cfg.quality = record:GetIntValue("quality")
  cfg.classType = record:GetIntValue("classType")
  cfg.useLevel = record:GetIntValue("useLevel")
  cfg.changeModelId = record:GetIntValue("changeModelId")
  cfg.iconId = record:GetIntValue("iconId")
  return cfg
end
def.static("number", "=>", "table").GetCardLevelCfg = function(cardId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CARD_LEVEL_CFG, cardId)
  if record == nil then
    warn("!!!!!GetCardLevelCfg(" .. cardId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.cardCfgId = cardId
  cfg.cardLevels = {}
  local carLevelStruct = record:GetStructValue("cardLevelStruct")
  local size = carLevelStruct:GetVectorSize("cardLeveList")
  for i = 0, size - 1 do
    local rec = carLevelStruct:GetVectorValueByIdx("cardLeveList", i)
    local t = {}
    t.level = rec:GetIntValue("level")
    t.useLevel = rec:GetIntValue("useLevel")
    t.useCostEssence = rec:GetIntValue("useCostEssence")
    t.effectPersistMinute = rec:GetIntValue("effectPersistMinute")
    t.effectPersistPVPFight = rec:GetIntValue("effectPersistPVPFight")
    t.useCount = rec:GetIntValue("useCount")
    t.upgradeExp = rec:GetIntValue("upgradeExp")
    t.provideExp = rec:GetIntValue("provideExp")
    t.sellScore = rec:GetIntValue("sellScore")
    t.unlockItemId = rec:GetIntValue("unlockItemId")
    t.dyeId = rec:GetIntValue("dyeId")
    t.propertys = {}
    local propertyStruct = rec:GetStructValue("propertyStruct")
    local num = propertyStruct:GetVectorSize("propertys")
    for n = 0, num - 1 do
      local rec2 = propertyStruct:GetVectorValueByIdx("propertys", n)
      local p = {}
      p.propType = rec2:GetIntValue("propType")
      if 0 < p.propType then
        p.value = rec2:GetIntValue("propValue")
        table.insert(t.propertys, p)
      end
    end
    cfg.cardLevels[t.level] = t
  end
  return cfg
end
def.static("number", "=>", "table").GetCardClassCfg = function(classType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CLASS_CFG, classType)
  if record == nil then
    warn("!!!!!GetCardClassCfg(" .. classType .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.classType = classType
  cfg.className = record:GetStringValue("className")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.smallIconId = record:GetIntValue("smallIconId")
  return cfg
end
def.static("=>", "table").LoadAllTypeCardsCfg = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHANGE_MODEL_CARD_CFG)
  if entries == nil then
    warn("[ERROR: Can't find file DATA_CHANGE_MODEL_CARD_CFG]")
    return retData
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.cardName = record:GetStringValue("cardName")
    cfg.quality = record:GetIntValue("quality")
    cfg.classType = record:GetIntValue("classType")
    cfg.useLevel = record:GetIntValue("useLevel")
    cfg.changeModelId = record:GetIntValue("changeModelId")
    cfg.iconId = record:GetIntValue("iconId")
    table.insert(retData, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
local class_level_cache = {}
def.static("number", "=>", "table").GetClassLevelCfg = function(classType)
  if class_level_cache[classType] then
    return class_level_cache[classType]
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CLASS_LEVEL_CFG, classType)
  if record == nil then
    warn("!!!!!GetClassLevelCfg(" .. classType .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.classType = classType
  cfg.classLevels = {}
  local classLevelStruct = record:GetStructValue("classLevelStruct")
  local size = classLevelStruct:GetVectorSize("classLevels")
  for i = 0, size - 1 do
    local rec = classLevelStruct:GetVectorValueByIdx("classLevels", i)
    local t = {}
    t.classType = rec:GetIntValue("classType")
    t.level = rec:GetIntValue("level")
    t.damageAddRates = {}
    t.damageReduceRates = {}
    t.beRestrictedClasses = {}
    local damageAddRatesStruct = rec:GetStructValue("damageAddRatesStruct")
    local num = damageAddRatesStruct:GetVectorSize("damageAddRates")
    for m = 0, num - 1 do
      local rec2 = damageAddRatesStruct:GetVectorValueByIdx("damageAddRates", m)
      local damageAddRates = {}
      damageAddRates.classType = rec2:GetIntValue("classType")
      damageAddRates.value = rec2:GetIntValue("value")
      table.insert(t.damageAddRates, damageAddRates)
    end
    local damageReduceRatesStruct = rec:GetStructValue("damageReduceRatesStruct")
    local num = damageReduceRatesStruct:GetVectorSize("damageReduceRates")
    for m = 0, num - 1 do
      local rec3 = damageReduceRatesStruct:GetVectorValueByIdx("damageReduceRates", m)
      local damageReduceRates = {}
      damageReduceRates.classType = rec3:GetIntValue("classType")
      damageReduceRates.value = rec3:GetIntValue("value")
      table.insert(t.damageReduceRates, damageReduceRates)
    end
    local beRestrictedClassesStruct = rec:GetStructValue("beRestrictedClassesStruct")
    local num = beRestrictedClassesStruct:GetVectorSize("beRestrictedClasses")
    for m = 0, num - 1 do
      local rec3 = beRestrictedClassesStruct:GetVectorValueByIdx("beRestrictedClasses", m)
      local classType = rec3:GetIntValue("classType")
      table.insert(t.beRestrictedClasses, classType)
    end
    t.sealAddRates = {}
    local sealAddRatesStruct = rec:GetStructValue("sealAddRatesStruct")
    local num = sealAddRatesStruct:GetVectorSize("sealAddRates")
    for i = 0, num - 1 do
      local rec3 = sealAddRatesStruct:GetVectorValueByIdx("sealAddRates", i)
      local classType = rec3:GetIntValue("classType")
      t.sealAddRates[classType] = rec3:GetIntValue("value")
    end
    t.sealReduceRates = {}
    local sealReduceRatesStruct = rec:GetStructValue("sealReduceRatesStruct")
    local num = sealReduceRatesStruct:GetVectorSize("sealReduceRates")
    for i = 0, num - 1 do
      local rec3 = sealReduceRatesStruct:GetVectorValueByIdx("sealReduceRates", i)
      local classType = rec3:GetIntValue("classType")
      t.sealReduceRates[classType] = rec3:GetIntValue("value")
    end
    cfg.classLevels[t.level] = t
  end
  class_level_cache[classType] = cfg
  return cfg
end
def.static("number", "=>", "table").GetChangeModelCardItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANGE_MODEL_CARD_ITEM_CFG, itemId)
  if record == nil then
    warn("!!!!!GetChangeModelCardItemCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.itemId = itemId
  cfg.cardCfgId = record:GetIntValue("cardCfgId")
  cfg.provideExp = record:GetIntValue("provideExp")
  cfg.cardLevel = record:GetIntValue("cardLevel")
  cfg.sellScore = record:GetIntValue("sellScore")
  return cfg
end
def.static("=>", "table").GetChangeModelCardItemCfgList = function()
  local cfgList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHANGE_MODEL_CARD_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local itemId = record:GetIntValue("itemId")
    local cfg = TurnedCardUtils.GetChangeModelCardItemCfg(itemId)
    if cfg then
      table.insert(cfgList, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgList
end
def.static("number", "=>", "table").GetChangeModelCardFragmentCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANGE_MODEL_CARD_FRAGMENT_CFG, itemId)
  if record == nil then
    warn("!!!!!GetChangeModelCardFragmentCfg(" .. itemId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.itemId = itemId
  cfg.cardCfgId = record:GetIntValue("cardCfgId")
  cfg.provideExp = record:GetIntValue("provideExp")
  cfg.cardLevel = record:GetIntValue("cardLevel")
  cfg.sellScore = record:GetIntValue("sellScore")
  return cfg
end
def.static("=>", "table").GetChangeModelCardFragmentCfgList = function()
  local cfgList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHANGE_MODEL_CARD_FRAGMENT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local itemId = record:GetIntValue("itemId")
    local cfg = TurnedCardUtils.GetChangeModelCardFragmentCfg(itemId)
    if cfg then
      table.insert(cfgList, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgList
end
def.static("number", "=>", "table").GetChangeModelCardItemFilterCfg = function(type)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHANGE_MODEL_CARD_ITEM_FILTER_CFG, type)
  if record == nil then
    warn("!!!!!GetChangeModelCardItemFilterCfg(" .. type .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.type = record:GetIntValue("type")
  cfg.itemCfgIds = {}
  local itemCfgIdStruct = record:GetStructValue("itemCfgIdsStruct")
  local size = itemCfgIdStruct:GetVectorSize("itemCfgIds")
  for i = 0, size - 1 do
    local rec = itemCfgIdStruct:GetVectorValueByIdx("itemCfgIds", i)
    local itemId = rec:GetIntValue("itemId")
    table.insert(cfg.itemCfgIds, itemId)
  end
  return cfg
end
def.static("number", "=>", "boolean").IsPurpleCardItem = function(itemId)
  local PurpleLv = TurnedCardUtils.PurpleLevel
  local cardItemCfg = TurnedCardUtils.GetChangeModelCardItemCfg(itemId)
  local isPurple = false
  if cardItemCfg then
    if PurpleLv <= cardItemCfg.cardLevel then
      isPurple = true
    end
  else
    local cardFragmentCfg = TurnedCardUtils.GetChangeModelCardFragmentCfg(itemId)
    if cardFragmentCfg and PurpleLv <= cardFragmentCfg.cardLevel then
      isPurple = true
    end
  end
  return isPurple
end
def.static("number", "number", "=>", "string").GetTurnedCardDisPlayName = function(cardId, level)
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardId)
  if cardCfg then
    local levelStr = textRes.TurnedCard.CardLevelStr[level]
    if levelStr then
      return levelStr .. "\194\183" .. cardCfg.cardName
    end
    return cardCfg.cardName
  end
  return ""
end
def.static("number", "number", "=>", "number").GetUnlockItemId = function(cfgId, level)
  local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(cfgId)
  if cardLevelCfg then
    local curLevelCfg = cardLevelCfg.cardLevels[level]
    if curLevelCfg then
      return curLevelCfg.unlockItemId
    end
  end
  return 0
end
def.static("number", "number").ShowTurnedCardTips = function(cfgId, level)
  local itemBase = ItemUtils.GetItemBase(cfgId)
  local itemId = 0
  if itemBase then
    itemId = cfgId
  else
    itemId = TurnedCardUtils.GetUnlockItemId(cfgId, level)
  end
  if itemId > 0 then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, ItemTipsMgr.Position.Right.x + 100, ItemTipsMgr.Position.Right.y, 0, 0, 0, false)
  end
end
return TurnedCardUtils.Commit()
