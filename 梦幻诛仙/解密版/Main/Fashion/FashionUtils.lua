local Lplus = require("Lplus")
local FashionUtils = Lplus.Class("FashionUtils")
local FashionData = Lplus.ForwardDeclare("FashionData")
local DyeData = Lplus.ForwardDeclare("DyeData")
local DyeingMgr = Lplus.ForwardDeclare("DyeingMgr")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local def = FashionUtils.define
def.static("=>", "table").GetAllFashionItemData = function()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local items = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FASHION_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local item = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local gender = DynamicRecord.GetIntValue(entry, "gender")
    local occupation = DynamicRecord.GetIntValue(entry, "menpai")
    if heroProp.gender == gender and heroProp.occupation == occupation or GenderEnum.ALL == gender and heroProp.occupation == occupation or heroProp.gender == gender and OccupationEnum.ALL == occupation or GenderEnum.ALL == gender and OccupationEnum.ALL == occupation then
      item.id = DynamicRecord.GetIntValue(entry, "id")
      item.fashionDressName = DynamicRecord.GetStringValue(entry, "fashionDressName")
      item.fashionDressDesc = DynamicRecord.GetStringValue(entry, "fashionDressDesc")
      item.fashionShowType = DynamicRecord.GetIntValue(entry, "fashionShowType")
      item.menpai = DynamicRecord.GetIntValue(entry, "menpai")
      item.gender = DynamicRecord.GetIntValue(entry, "gender")
      item.modelId = DynamicRecord.GetIntValue(entry, "modelId")
      item.headModelId = DynamicRecord.GetIntValue(entry, "headModelId")
      item.shengWuNvPandaModelId = DynamicRecord.GetIntValue(entry, "shengWuNvPandaModelId")
      item.effectTime = DynamicRecord.GetIntValue(entry, "effectTime")
      item.iconId = DynamicRecord.GetIntValue(entry, "iconId")
      item.fashionDressType = DynamicRecord.GetIntValue(entry, "fashionDressType")
      item.fashionDressDyeType = DynamicRecord.GetIntValue(entry, "fashionDressDyeType")
      item.clothesPressType = DynamicRecord.GetIntValue(entry, "clothesPressType")
      item.defaultHairDyeId = DynamicRecord.GetIntValue(entry, "defaultHairDyeId")
      item.defaultClothDyeId = DynamicRecord.GetIntValue(entry, "defaultClothDyeId")
      item.costItemId = DynamicRecord.GetIntValue(entry, "costItemId")
      item.costItemId = DynamicRecord.GetIntValue(entry, "costItemId")
      item.costItemNum = DynamicRecord.GetIntValue(entry, "costItemNum")
      item.unlockConditionId = DynamicRecord.GetIntValue(entry, "unlockConditionId")
      item.effects = {}
      local effectsStruct = entry:GetStructValue("effectSkillListStruct")
      local size = effectsStruct:GetVectorSize("effectSkillList")
      for i = 0, size - 1 do
        local effect = effectsStruct:GetVectorValueByIdx("effectSkillList", i)
        local effectId = effect:GetIntValue("effectSkillId")
        table.insert(item.effects, effectId)
      end
      item.properties = {}
      local propertyStruct = entry:GetStructValue("propertySkillListStruct")
      local size = propertyStruct:GetVectorSize("propertySkillList")
      for i = 0, size - 1 do
        local property = propertyStruct:GetVectorValueByIdx("propertySkillList", i)
        local propertyId = property:GetIntValue("propertySkillId")
        table.insert(item.properties, propertyId)
      end
      table.insert(items, item)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return items
end
def.static("number", "=>", "table").GetFashionItemDataById = function(id)
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_FASHION_CFG, id)
  if entry == nil then
    warn("no fashion item:" .. id)
    return nil
  end
  local item = {}
  item.id = DynamicRecord.GetIntValue(entry, "id")
  item.fashionDressName = DynamicRecord.GetStringValue(entry, "fashionDressName")
  item.fashionDressDesc = DynamicRecord.GetStringValue(entry, "fashionDressDesc")
  item.menpai = DynamicRecord.GetIntValue(entry, "menpai")
  item.gender = DynamicRecord.GetIntValue(entry, "gender")
  item.modelId = DynamicRecord.GetIntValue(entry, "modelId")
  item.headModelId = DynamicRecord.GetIntValue(entry, "headModelId")
  item.shengWuNvPandaModelId = DynamicRecord.GetIntValue(entry, "shengWuNvPandaModelId")
  item.effectTime = DynamicRecord.GetIntValue(entry, "effectTime")
  item.iconId = DynamicRecord.GetIntValue(entry, "iconId")
  item.fashionDressType = DynamicRecord.GetIntValue(entry, "fashionDressType")
  item.fashionDressDyeType = DynamicRecord.GetIntValue(entry, "fashionDressDyeType")
  item.clothesPressType = DynamicRecord.GetIntValue(entry, "clothesPressType")
  item.defaultHairDyeId = DynamicRecord.GetIntValue(entry, "defaultHairDyeId")
  item.defaultClothDyeId = DynamicRecord.GetIntValue(entry, "defaultClothDyeId")
  item.costItemId = DynamicRecord.GetIntValue(entry, "costItemId")
  item.costItemNum = DynamicRecord.GetIntValue(entry, "costItemNum")
  item.unlockConditionId = DynamicRecord.GetIntValue(entry, "unlockConditionId")
  item.effects = {}
  local effectsStruct = entry:GetStructValue("effectSkillListStruct")
  local size = effectsStruct:GetVectorSize("effectSkillList")
  for i = 0, size - 1 do
    local effect = effectsStruct:GetVectorValueByIdx("effectSkillList", i)
    local effectId = effect:GetIntValue("effectSkillId")
    table.insert(item.effects, effectId)
  end
  item.properties = {}
  local propertyStruct = entry:GetStructValue("propertySkillListStruct")
  local size = propertyStruct:GetVectorSize("propertySkillList")
  for i = 0, size - 1 do
    local property = propertyStruct:GetVectorValueByIdx("propertySkillList", i)
    local propertyId = property:GetIntValue("propertySkillId")
    table.insert(item.properties, propertyId)
  end
  return item
end
def.static("number", "=>", "table").GetFashionUnlockConditionById = function(id)
  local condition = {}
  local conditionRecord = DynamicData.GetRecord(CFG_PATH.DATA_FASHION_UNLOCK_CONDITION_CFG, id)
  condition.id = DynamicRecord.GetIntValue(conditionRecord, "id")
  condition.templatename = DynamicRecord.GetStringValue(conditionRecord, "templatename")
  condition.conditionDesc = DynamicRecord.GetStringValue(conditionRecord, "conditionDesc")
  condition.conditionType = DynamicRecord.GetIntValue(conditionRecord, "conditionType")
  condition.conditionValue = DynamicRecord.GetIntValue(conditionRecord, "conditionValue")
  return condition
end
def.static("number", "=>", "table").GetFashionItemByUnlockItemId = function(itemId)
  local allData = FashionUtils.GetAllFashionItemData()
  for idx, item in ipairs(allData) do
    if item.costItemId == itemId then
      return item
    end
  end
  warn("no fashion can unlock by item:" .. itemId)
  return nil
end
def.static("number", "=>", "table").GetFashionItemByFashionType = function(fashionType)
  local allData = FashionUtils.GetAllFashionItemData()
  for idx, item in ipairs(allData) do
    if item.fashionDressType == fashionType then
      return item
    end
  end
  warn("no fashion is type:" .. fashionType)
  return nil
end
def.static("number", "=>", "boolean").IsFashionHavePropertyEffect = function(fashionCfgId)
  local fashionItem = FashionUtils.GetFashionItemDataById(fashionCfgId)
  if fashionItem ~= nil then
    return #fashionItem.properties > 0
  else
    return false
  end
end
def.static("=>", "table").GetAllFashionSkills = function()
  local skills = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FASHION_DRESS_EFFECT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    table.insert(skills, DynamicRecord.GetIntValue(entry, "passiveSkillId"))
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return skills
end
def.static("=>", "table").GetAllThemeFashionCfgData = function()
  local themeFashions = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_THEME_FASHION_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.fashionDressName = DynamicRecord.GetStringValue(entry, "fashionDressName")
    cfg.desc = DynamicRecord.GetIntValue(entry, "desc")
    cfg.iconId = DynamicRecord.GetIntValue(entry, "iconId")
    cfg.awardIconId = DynamicRecord.GetIntValue(entry, "awardIconId")
    cfg.fullEffectId = DynamicRecord.GetIntValue(entry, "fullEffectId")
    cfg.progressBarName = DynamicRecord.GetStringValue(entry, "progressBarName")
    cfg.relatedFashionType = {}
    local unlockFashionStruct = entry:GetStructValue("unlockFashionStruct")
    local size = unlockFashionStruct:GetVectorSize("unlockFashionList")
    for i = 0, size - 1 do
      local fashionRecord = unlockFashionStruct:GetVectorValueByIdx("unlockFashionList", i)
      local unlockFashionType = fashionRecord:GetIntValue("unlockFashionType")
      table.insert(cfg.relatedFashionType, unlockFashionType)
    end
    table.insert(themeFashions, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return themeFashions
end
def.static("number", "=>", "table").GetThemeFashionCfgById = function(cfgId)
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_THEME_FASHION_CFG, cfgId)
  if entry == nil then
    warn("theme fashion not exist:" .. cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = DynamicRecord.GetIntValue(entry, "id")
  cfg.fashionDressName = DynamicRecord.GetStringValue(entry, "fashionDressName")
  cfg.desc = DynamicRecord.GetIntValue(entry, "desc")
  cfg.iconId = DynamicRecord.GetIntValue(entry, "iconId")
  cfg.awardIconId = DynamicRecord.GetIntValue(entry, "awardIconId")
  cfg.fullEffectId = DynamicRecord.GetIntValue(entry, "fullEffectId")
  cfg.relatedFashionType = {}
  local unlockFashionStruct = entry:GetStructValue("unlockFashionStruct")
  local size = unlockFashionStruct:GetVectorSize("unlockFashionList")
  for i = 0, size - 1 do
    local fashionRecord = unlockFashionStruct:GetVectorValueByIdx("unlockFashionList", i)
    local unlockFashionType = fashionRecord:GetIntValue("unlockFashionType")
    table.insert(cfg.relatedFashionType, unlockFashionType)
  end
  return cfg
end
def.static("number", "=>", "table").GetThemeFashionUnlockCfgByTypeId = function(typeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_THEME_FASHION_UNLOCK_CFG, typeId)
  if record == nil then
    warn("theme fashion type not exist:" .. typeId)
    return nil
  end
  local cfg = {}
  cfg.typeId = DynamicRecord.GetIntValue(record, "typeId")
  cfg.name = DynamicRecord.GetStringValue(record, "name")
  cfg.description = DynamicRecord.GetStringValue(record, "description")
  cfg.source = DynamicRecord.GetStringValue(record, "source")
  cfg.fashionType = {}
  local fashionTypeStruct = record:GetStructValue("fashionTypeStruct")
  local size = fashionTypeStruct:GetVectorSize("fashionTypeList")
  for i = 0, size - 1 do
    local fashionTypeRecord = fashionTypeStruct:GetVectorValueByIdx("fashionTypeList", i)
    local fashionType = fashionTypeRecord:GetIntValue("fashionType")
    table.insert(cfg.fashionType, fashionType)
  end
  return cfg
end
def.static("=>", "table").GetThemeFashionAwards = function()
  local awards = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_THEME_FASHION_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local award = {}
    award.id = DynamicRecord.GetIntValue(entry, "id")
    award.themeFashionCfgId = DynamicRecord.GetIntValue(entry, "themeFashionCfgId")
    award.unlockFashionNum = DynamicRecord.GetIntValue(entry, "unlockFashionNum")
    award.awardId = DynamicRecord.GetIntValue(entry, "awardId")
    award.desc = DynamicRecord.GetStringValue(entry, "desc")
    award.propertyList = {}
    local propertyStruct = entry:GetStructValue("propertyStruct")
    local size = propertyStruct:GetVectorSize("propertyList")
    for i = 0, size - 1 do
      local propertyRecord = propertyStruct:GetVectorValueByIdx("propertyList", i)
      local propertyType = propertyRecord:GetIntValue("propertyType")
      local propertyValue = propertyRecord:GetIntValue("propertyValue")
      table.insert(award.propertyList, {propType = propertyType, propValue = propertyValue})
    end
    table.insert(awards, award)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return awards
end
def.static("number", "=>", "table").GetTheFashionAwardById = function(themeFashionCfgId)
  local allAwards = FashionUtils.GetThemeFashionAwards()
  local awards = {}
  for i = 1, #allAwards do
    if allAwards[i].themeFashionCfgId == themeFashionCfgId then
      table.insert(awards, allAwards[i])
    end
  end
  table.sort(awards, function(a, b)
    return a.unlockFashionNum < b.unlockFashionNum
  end)
  return awards
end
def.static("=>", "table", "number").GetNowLimitedThemeFashionCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LIMITED_THEME_FASHION_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local curTime = _G.GetServerTime()
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local cfg
  local period = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local time_limit_cfg_id = DynamicRecord.GetIntValue(entry, "time_limit_cfg_id")
    local timeLimitCommonCfg = TimeCfgUtils.GetTimeLimitCommonCfg(time_limit_cfg_id)
    if timeLimitCommonCfg ~= nil then
      local beginTime = TimeCfgUtils.GetTimeSec(timeLimitCommonCfg.startYear, timeLimitCommonCfg.startMonth, timeLimitCommonCfg.startDay, timeLimitCommonCfg.startHour, timeLimitCommonCfg.startMinute, 0)
      local endTime = TimeCfgUtils.GetTimeSec(timeLimitCommonCfg.endYear, timeLimitCommonCfg.endMonth, timeLimitCommonCfg.endDay, timeLimitCommonCfg.endHour, timeLimitCommonCfg.endMinute, 0)
      if curTime >= beginTime and curTime <= endTime then
        period = i
        cfg = {}
        cfg.id = DynamicRecord.GetIntValue(entry, "id")
        cfg.icon_id = DynamicRecord.GetIntValue(entry, "icon_id")
        cfg.time_limit_cfg_id = DynamicRecord.GetIntValue(entry, "time_limit_cfg_id")
        cfg.theme_fashion_dress_cfg_id = DynamicRecord.GetIntValue(entry, "theme_fashion_dress_cfg_id")
        cfg.buff_cfg_id = DynamicRecord.GetIntValue(entry, "buff_cfg_id")
        break
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg, period
end
def.static("number", "=>", "table", "number").GetNextPeriodLimitedThemeFashionCfg = function(curPeriod)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LIMITED_THEME_FASHION_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  if curPeriod >= count then
    return nil, 0
  end
  local cfg = {}
  local period = curPeriod + 1
  DynamicDataTable.FastGetRecordBegin(entries)
  local entry = DynamicDataTable.GetRecordByIdx(entries, period - 1)
  cfg.id = DynamicRecord.GetIntValue(entry, "id")
  cfg.icon_id = DynamicRecord.GetIntValue(entry, "icon_id")
  cfg.time_limit_cfg_id = DynamicRecord.GetIntValue(entry, "time_limit_cfg_id")
  cfg.theme_fashion_dress_cfg_id = DynamicRecord.GetIntValue(entry, "theme_fashion_dress_cfg_id")
  cfg.buff_cfg_id = DynamicRecord.GetIntValue(entry, "buff_cfg_id")
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg, period
end
def.static("number", "=>", "string").ConvertHourToSentence = function(hour)
  if hour == -1 then
    return textRes.Fashion[3]
  end
  local d = math.floor(hour / 24)
  local h = math.floor(hour % 24)
  if d > 0 and h > 0 then
    return string.format(textRes.Fashion[2], d, h)
  elseif d > 0 and h == 0 then
    return string.format(textRes.Fashion[21], d)
  elseif d == 0 and h > 0 then
    return string.format(textRes.Fashion[20], h)
  elseif d == 0 and h == 0 then
    return textRes.Fashion[19]
  end
  return textRes.Fashion[33]
end
def.static("userdata", "=>", "string").ConvertSecondToSentence = function(second)
  local h = second / 3600
  return FashionUtils.ConvertHourToSentence(Int64.ToNumber(h))
end
def.static("table", "number").SetFashion = function(model, fashionCfgId)
  local dyeColor = FashionUtils.GetFashionDyeColor(fashionCfgId)
  FashionUtils.SetFashionWithDyeColor(model, dyeColor)
end
def.static("number", "=>", "table").GetFashionDyeColor = function(fashionCfgId)
  local currentFashionId = FashionData.Instance().currentFashionId
  local dyeColor = {}
  if FashionUtils.IsFashionUseSameClothPres(fashionCfgId, currentFashionId) then
    local dyeData = DyeData.Instance():GetCurClothData()
    dyeColor.fashionDressCfgId = fashionCfgId
    dyeColor.hairId = dyeData.hairid
    dyeColor.clothId = dyeData.clothid
  else
    local fashionItem = FashionUtils.GetFashionItemDataById(fashionCfgId)
    if fashionItem ~= nil then
      dyeColor.fashionDressCfgId = fashionCfgId
      dyeColor.hairId = fashionItem.defaultHairDyeId
      dyeColor.clothId = fashionItem.defaultClothDyeId
    else
      warn("fashionItem not exist:" .. fashionCfgId)
    end
  end
  return dyeColor
end
def.static("number", "number", "=>", "boolean").IsFashionUseSameClothPres = function(fashionCfgId1, fashionCfgId2)
  if fashionCfgId1 == fashionCfgId2 then
    return true
  elseif fashionCfgId1 < 0 or fashionCfgId2 < 0 then
    return false
  else
    local fashionItem1 = FashionUtils.GetFashionItemDataById(fashionCfgId1)
    local fashionItem2 = FashionUtils.GetFashionItemDataById(fashionCfgId2)
    if fashionItem1 ~= nil and fashionItem2 ~= nil then
      return fashionItem1.clothesPressType == fashionItem2.clothesPressType
    end
  end
  return false
end
def.static("table", "table").SetFashionWithDyeColor = function(model, dyeColor)
  if model == nil or dyeColor == nil or dyeColor.fashionDressCfgId == nil or dyeColor.hairId == nil or dyeColor.clothId == nil then
    warn("fashion color cfg is wrong")
    return
  end
  SetCostume(model, dyeColor.fashionDressCfgId, dyeColor.hairId, dyeColor.clothId, nil)
end
FashionUtils.Commit()
return FashionUtils
