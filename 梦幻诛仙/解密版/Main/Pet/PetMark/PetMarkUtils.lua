local Lplus = require("Lplus")
local PetMarkUtils = Lplus.Class("PetMarkUtils")
local PetData = Lplus.ForwardDeclare("PetData")
local PetAptConsts = require("netio.protocol.mzm.gsp.pet.PetAptConsts")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local def = PetMarkUtils.define
def.static("=>", "table").GetAllPetMarkCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PET_MARK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.name = DynamicRecord.GetStringValue(entry, "name")
    cfg.desc = DynamicRecord.GetStringValue(entry, "desc")
    cfg.iconId = DynamicRecord.GetIntValue(entry, "iconId")
    cfg.quality = DynamicRecord.GetIntValue(entry, "quality")
    cfg.category = DynamicRecord.GetIntValue(entry, "category")
    cfg.type = DynamicRecord.GetIntValue(entry, "type")
    cfg.modelId = DynamicRecord.GetIntValue(entry, "modelId")
    cfg.display = DynamicRecord.GetCharValue(entry, "display") ~= 0
    cfg.typeId = DynamicRecord.GetIntValue(entry, "typeId")
    table.insert(list, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "table").GetPetMarkCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_MARK_CFG, cfgId)
  if record == nil then
    warn("GetPetMarkCfg get nil record for id: ", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = DynamicRecord.GetIntValue(record, "id")
  cfg.name = DynamicRecord.GetStringValue(record, "name")
  cfg.desc = DynamicRecord.GetStringValue(record, "desc")
  cfg.iconId = DynamicRecord.GetIntValue(record, "iconId")
  cfg.quality = DynamicRecord.GetIntValue(record, "quality")
  cfg.category = DynamicRecord.GetIntValue(record, "category")
  cfg.type = DynamicRecord.GetIntValue(record, "type")
  cfg.modelId = DynamicRecord.GetIntValue(record, "modelId")
  cfg.display = DynamicRecord.GetCharValue(record, "display") ~= 0
  cfg.typeId = DynamicRecord.GetIntValue(record, "typeId")
  return cfg
end
def.static("number", "=>", "table").GetPetMarkLevelCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_MARK_LEVEL_CFG, cfgId)
  if record == nil then
    warn("GetPetMarkLevelCfg get nil record for id: ", cfgId)
    return nil
  end
  local cfg = {}
  cfg.markCfgId = cfgId
  cfg.levelCfg = {}
  local levelBeanStruct = record:GetStructValue("levelBeanStruct")
  local size = levelBeanStruct:GetVectorSize("levelBeans")
  for i = 0, size - 1 do
    local levelBean = {}
    local beanData = levelBeanStruct:GetVectorValueByIdx("levelBeans", i)
    levelBean.markCfgId = beanData:GetIntValue("markCfgId")
    levelBean.level = beanData:GetIntValue("level")
    levelBean.upgradeExp = beanData:GetIntValue("upgradeExp")
    levelBean.provideExp = beanData:GetIntValue("provideExp")
    levelBean.smeltScoreType = beanData:GetIntValue("smeltScoreType")
    levelBean.smeltScore = beanData:GetIntValue("smeltScore")
    levelBean.unlockItemId = beanData:GetIntValue("unlockItemId")
    levelBean.passiveSkillId = beanData:GetIntValue("passiveSkillId")
    levelBean.addYaoli = beanData:GetIntValue("addYaoli")
    levelBean.needRoleLevel = beanData:GetIntValue("needRoleLevel")
    levelBean.propList = {}
    local propBeanStruct = beanData:GetStructValue("propBeanStruct")
    local propSize = propBeanStruct:GetVectorSize("propBeans")
    for j = 0, propSize - 1 do
      local propBean = propBeanStruct:GetVectorValueByIdx("propBeans", j)
      local propType = propBean:GetIntValue("propType")
      local propValue = propBean:GetIntValue("propValue")
      table.insert(levelBean.propList, {propType = propType, propValue = propValue})
    end
    table.insert(cfg.levelCfg, levelBean)
  end
  table.sort(cfg.levelCfg, function(a, b)
    return a.level < b.level
  end)
  return cfg
end
def.static("number", "number", "=>", "table").GetPetMarkLevelCfgByLevel = function(cfgId, level)
  local markLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(cfgId)
  if markLevelCfg == nil then
    return nil
  elseif markLevelCfg.levelCfg[level] ~= nil then
    return markLevelCfg.levelCfg[level]
  else
    warn("GetPetMarkLevelCfgByLevel return nil:", cfgId, level)
    return nil
  end
end
def.static("number", "number", "=>", "number", "number").GetPetMarkNextLevelSkillId = function(cfgId, level)
  local markLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(cfgId)
  if markLevelCfg == nil then
    warn("GetPetMarkNextLevelSkillId return nil:", cfgId)
    return 0, 0
  else
    for i = level + 1, #markLevelCfg.levelCfg do
      local levelCfg = markLevelCfg.levelCfg[i]
      if 0 < levelCfg.passiveSkillId then
        return i, levelCfg.passiveSkillId
      end
    end
  end
  return 0, 0
end
def.static("number", "=>", "table").GetPetMarkItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_MARK_ITEM_CFG, itemId)
  if record == nil then
    warn("GetPetMarkItemCfg get nil record for id: ", itemId)
    return nil
  end
  local cfg = {}
  cfg.itemId = DynamicRecord.GetIntValue(record, "itemId")
  cfg.petMarkCfgId = DynamicRecord.GetIntValue(record, "petMarkCfgId")
  cfg.level = DynamicRecord.GetIntValue(record, "level")
  cfg.provideExp = DynamicRecord.GetIntValue(record, "provideExp")
  cfg.smeltScoreType = DynamicRecord.GetIntValue(record, "smeltScoreType")
  cfg.smeltScore = DynamicRecord.GetIntValue(record, "catsmeltScoreegory")
  return cfg
end
def.static("number", "=>", "table").GetPetMarkLotteryCfg = function(lotteryType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PET_MARK_Lottery_CFG, lotteryType)
  if record == nil then
    warn("GetPetMarkLotteryCfg get nil record for id: ", lotteryType)
    return nil
  end
  local cfg = {}
  cfg.lotteryType = DynamicRecord.GetIntValue(record, "lotteryType")
  cfg.items = {}
  local itemStruct = record:GetStructValue("itemStruct")
  local size = itemStruct:GetVectorSize("items")
  for i = 0, size - 1 do
    local data = itemStruct:GetVectorValueByIdx("items", i)
    local itemId = data:GetIntValue("itemId")
    table.insert(cfg.items, itemId)
  end
  return cfg
end
def.static(PetData, "table", "=>", "number").GetPetMarkActualPropValue = function(pet, prop)
  local propValue = 0
  if prop and prop.propValue then
    local PetUtility = require("Main.Pet.PetUtility")
    local RATIO_BISIC_PROP = PetUtility.Instance():GetPetConstants("RATIO_BISIC_PROP")
    RATIO_BISIC_PROP = RATIO_BISIC_PROP and RATIO_BISIC_PROP / 10000 or 0
    local CONST_APT = PetUtility.Instance():GetPetConstants("CONST_APT")
    CONST_APT = CONST_APT and CONST_APT / 10000 or 0
    local RATIO_APT = PetUtility.Instance():GetPetConstants("RATIO_APT")
    RATIO_APT = RATIO_APT and RATIO_APT / 10000 or 0
    local CONST_GROW = PetUtility.Instance():GetPetConstants("CONST_GROW")
    CONST_GROW = CONST_GROW and CONST_GROW / 10000 or 0
    local RATIO_GROW = PetUtility.Instance():GetPetConstants("RATIO_GROW")
    RATIO_GROW = RATIO_GROW and RATIO_GROW / 10000 or 0
    local growData = PetUtility.GetPetGrowValueViewData(pet)
    local curGrowApt = growData and growData.value or 0
    local petAptType = PetMarkUtils.GetPropAptType(prop.propType)
    local curPropApt = pet.petQuality:GetQuality(petAptType) or 0
    propValue = math.floor(prop.propValue * RATIO_BISIC_PROP + prop.propValue * math.max(curPropApt / 1000 - CONST_APT, 0) * RATIO_APT + prop.propValue * math.max(curGrowApt - CONST_GROW, 0) * RATIO_GROW)
  end
  return propValue
end
def.static("number", "=>", "number").GetPropAptType = function(propType)
  local result = -1
  if propType == PropertyType.MAX_HP then
    result = PetAptConsts.HP_APT
  elseif propType == PropertyType.PHYATK then
    result = PetAptConsts.PHYATK_APT
  elseif propType == PropertyType.PHYDEF then
    result = PetAptConsts.PHYDEF_APT
  elseif propType == PropertyType.MAGATK then
    result = PetAptConsts.MAGATK_APT
  elseif propType == PropertyType.MAGDEF then
    result = PetAptConsts.MAGDEF_APT
  elseif propType == PropertyType.SPEED then
    result = PetAptConsts.SPEED_APT
  end
  return result
end
def.static(PetData, "table", "=>", "string").GetPetMarkActualPropValueStr = function(pet, prop)
  local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
  local propertyCfg = _G.GetCommonPropNameCfg(prop.propType)
  if propertyCfg.valueType == ProValueType.TEN_THOUSAND_RATE then
    return _G.PropValueToText(prop.propValue, propertyCfg.valueType)
  else
    local actualValue = PetMarkUtils.GetPetMarkActualPropValue(pet, prop)
    local addValue = actualValue - prop.propValue
    return string.format(textRes.Pet.PetMark[31], _G.PropValueToText(prop.propValue, propertyCfg.valueType), _G.PropValueToText(addValue, propertyCfg.valueType))
  end
end
PetMarkUtils.Commit()
return PetMarkUtils
