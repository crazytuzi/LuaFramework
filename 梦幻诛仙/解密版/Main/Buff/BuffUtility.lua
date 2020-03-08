local Lplus = require("Lplus")
local BuffUtility = Lplus.Class("BuffUtility")
local def = BuffUtility.define
local instance
def.static("=>", BuffUtility).Instance = function()
  if instance == nil then
    instance = BuffUtility()
  end
  return instance
end
def.static("number", "=>", "table").GetBuffCfg = function(buffId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BUFF_CFG, buffId)
  if record == nil then
    warn("GetBuffCfg(" .. buffId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.name = DynamicRecord.GetStringValue(record, "name")
  cfg.icon = DynamicRecord.GetIntValue(record, "icon")
  cfg.effectType = DynamicRecord.GetIntValue(record, "effectType")
  cfg.buffStateType = DynamicRecord.GetIntValue(record, "bufStateType")
  cfg.desc = DynamicRecord.GetStringValue(record, "desc")
  cfg.vanishTip = DynamicRecord.GetIntValue(record, "vanishTip")
  cfg.isShowInFight = DynamicRecord.GetCharValue(record, "isShowInFight") == 1
  cfg.stateBuffStr = DynamicRecord.GetStringValue(record, "stateBuffStr")
  cfg.canDelete = DynamicRecord.GetCharValue(record, "canDelete") == 1 or false
  cfg.showAppearAnimation = DynamicRecord.GetCharValue(record, "showDynamicEffect") == 1 or false
  cfg.effects = {}
  local effectsStruct = record:GetStructValue("effects")
  local size = effectsStruct:GetVectorSize("effectList")
  for i = 0, size - 1 do
    local vectorRow = effectsStruct:GetVectorValueByIdx("effectList", i)
    local effect = {}
    effect.id = vectorRow:GetIntValue("effectId")
    effect.value = vectorRow:GetIntValue("effectValue")
    table.insert(cfg.effects, effect)
  end
  return cfg
end
def.static("number", "=>", "table").GetSupplementNutritionCfg = function(level)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SUPPLEMENT_NUTRITION_CFG, level)
  if record == nil then
    warn("GetSupplementNutritionCfg(" .. level .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.level = level
  cfg.neededSilverPerNutrition = DynamicRecord.GetIntValue(record, "add1BaoshiduNeedSilver")
  return cfg
end
def.static("number", "=>", "table").GetBuffChartletCfg = function(buffId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BUFF_CHARTLET_CFG, buffId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.buffId = buffId
  cfg.icon = DynamicRecord.GetIntValue(record, "icon")
  return cfg
end
return BuffUtility.Commit()
