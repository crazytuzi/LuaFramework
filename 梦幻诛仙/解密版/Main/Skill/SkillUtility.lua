local Lplus = require("Lplus")
local SkillUtility = Lplus.Class("SkillUtility")
local def = SkillUtility.define
local SkillBagCfgData = Lplus.ForwardDeclare("SkillBagCfgData")
local SkillCfgData = Lplus.ForwardDeclare("SkillCfgData")
local SkillModule = Lplus.ForwardDeclare("SkillModule")
local instance
def.static("=>", SkillUtility).Instance = function()
  if instance == nil then
    instance = SkillUtility()
  end
  return instance
end
def.static("number", "=>", SkillBagCfgData).GetSkillBagCfg = function(skillBagId)
  local skillBagInfo = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_BAG_CFG, skillBagId)
  if skillBagInfo == nil then
    warn("GetSkillBagCfg(" .. skillBagId .. ") return nil")
    return nil
  end
  local SkillBagCfgData = require("Main.Skill.data.SkillBagCfgData")
  local skillBagCfg = SkillBagCfgData.New()
  skillBagCfg.name = DynamicRecord.GetStringValue(skillBagInfo, "name")
  skillBagCfg.iconId = DynamicRecord.GetIntValue(skillBagInfo, "icon")
  skillBagCfg.levelUpCfgId = DynamicRecord.GetIntValue(skillBagInfo, "levelcfgid")
  skillBagCfg.description = DynamicRecord.GetStringValue(skillBagInfo, "desc")
  skillBagCfg.propText = DynamicRecord.GetStringValue(skillBagInfo, "skillBagPropStr")
  local skillStruct = DynamicRecord.GetStructValue(skillBagInfo, "skillStruct")
  local skillNum = DynamicRecord.GetVectorSize(skillStruct, "skillVector")
  for i = 0, skillNum - 1 do
    local skillData = SkillBagCfgData.SkillData.New()
    local skill = DynamicRecord.GetVectorValueByIdx(skillStruct, "skillVector", i)
    skillData.id = DynamicRecord.GetIntValue(skill, "skillid")
    skillData.unlockLevel = DynamicRecord.GetIntValue(skill, "needlevel")
    table.insert(skillBagCfg.skillList, skillData)
  end
  return skillBagCfg
end
def.static("number", "=>", "table").GetSkillCfg = function(skillId)
  if SkillUtility.IsActiveSkill(skillId) then
    return SkillUtility.GetActiveSkillCfg(skillId)
  elseif SkillUtility.IsPassiveSkill(skillId) then
    return SkillUtility.GetPassiveSkillCfg(skillId)
  elseif SkillUtility.IsEnchantingSkill(skillId) then
    return SkillUtility.GetEnchantingSkillCfg(skillId)
  else
    return nil
  end
end
def.static("number", "=>", SkillCfgData).GetActiveSkillCfg = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_CFG, skillId)
  if record == nil then
    warn("GetSkillCfg(" .. skillId .. ") return nil")
    return nil
  end
  local SkillCfgData = require("Main.Skill.data.SkillCfgData")
  local skillCfg = SkillCfgData()
  skillCfg.id = record:GetIntValue("id")
  skillCfg.iconId = record:GetIntValue("icon")
  skillCfg.name = record:GetStringValue("name")
  skillCfg.description = record:GetStringValue("description")
  skillCfg.type = record:GetIntValue("type")
  skillCfg.conditionId = record:GetIntValue("condition")
  skillCfg.playId = record:GetIntValue("skillPlayid")
  skillCfg.displayInFight = record:GetCharValue("displayInFight") ~= 0
  skillCfg.canAuto = record:GetCharValue("canAuto") ~= 0
  skillCfg.simpleDesc = record:GetStringValue("simpleDesc")
  skillCfg.specialType = record:GetIntValue("specialType") or 0
  return skillCfg
end
local tmpQueryTable
def.static("number", "number", "=>", "table").GetOccupationSkillBagLevelUpNeedCfg = function(curLevel, levelUpCfgId)
  local nextLevel = curLevel + 1
  if tmpQueryTable == nil then
    tmpQueryTable = SkillUtility.GenOccupationSkillBagLevelUpQueryTable()
    GameUtil.AddGlobalLateTimer(0, true, function()
      tmpQueryTable = nil
    end)
  end
  local cfgs = tmpQueryTable[levelUpCfgId]
  if cfgs == nil then
    warn(string.format("GetOccupationSkillBagLevelUpNeedCfg: levelUpCfgId = %d can't find.", levelUpCfgId))
  end
  local cfg = cfgs[nextLevel]
  if cfg == nil then
    cfg = {}
    cfg.needRoleLevel = 0
    cfg.needSilver = 0
  end
  return cfg
end
def.static("=>", "table").GenOccupationSkillBagLevelUpQueryTable = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_OCCUPATION_SKILL_BAG_LEVEL_UP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local qt = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local levelcfgid = DynamicRecord.GetIntValue(entry, "levelcfgid")
    qt[levelcfgid] = qt[levelcfgid] or {}
    local cfgs = qt[levelcfgid]
    local skillbaglevel = DynamicRecord.GetIntValue(entry, "skillbaglevel")
    cfgs[skillbaglevel] = {
      needRoleLevel = DynamicRecord.GetIntValue(entry, "needRoleLevel"),
      needSilver = DynamicRecord.GetIntValue(entry, "needSilver")
    }
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return qt
end
def.static("number", "=>", "table").GetSkillBagOccupationCfg = function(occupationId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_BAG_OCCUPATION_CFG, occupationId)
  if record == nil then
    warn("GetSkillBagOccupationCfg(" .. occupationId .. ") return nil")
    return nil
  end
  local cfg = {}
  local skillBagStruct = DynamicRecord.GetStructValue(record, "bagStruct")
  local skillBagAmount = DynamicRecord.GetVectorSize(skillBagStruct, "bagVector")
  for i = 0, skillBagAmount - 1 do
    local skillBag = DynamicRecord.GetVectorValueByIdx(skillBagStruct, "bagVector", i)
    local skillBagId = DynamicRecord.GetIntValue(skillBag, "skillBagId")
    table.insert(cfg, skillBagId)
  end
  return cfg
end
def.static("number", "=>", "table").GetMonsterSkillCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MONSTER_SKILL_CFG, id)
  if record == nil then
    warn("GetMonsterSkillCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  local skillListStruct = DynamicRecord.GetStructValue(record, "skillStruct")
  local skillAmount = DynamicRecord.GetVectorSize(skillListStruct, "skillVector")
  for i = 0, skillAmount - 1 do
    local skillRecord = DynamicRecord.GetVectorValueByIdx(skillListStruct, "skillVector", i)
    local skillId = skillRecord:GetIntValue("skillid")
    table.insert(cfg, skillId)
  end
  return cfg
end
def.static("string", "=>", "number").GetSkillConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_CONSTS_CFG, key)
  if record == nil then
    warn("GetSkillConsts(" .. key .. ") return nil")
    return 0
  end
  local value = record:GetIntValue("value")
  return value
end
def.static("number", "=>", "table").GetSkillConditionCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_CONDITION_CFG, id)
  if record == nil then
    warn("GetSkillConditionCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  local costListStruct = DynamicRecord.GetStructValue(record, "costStruct")
  local costAmount = DynamicRecord.GetVectorSize(costListStruct, "costVector")
  for i = 0, costAmount - 1 do
    local reqRecord = DynamicRecord.GetVectorValueByIdx(costListStruct, "reqVector", i)
    local costRecord = DynamicRecord.GetVectorValueByIdx(costListStruct, "costVector", i)
    local cost = {}
    cost.costType = costRecord:GetIntValue("costType")
    cost.formulaid = costRecord:GetIntValue("formulaid")
    cost.reqType = reqRecord:GetIntValue("requireType")
    cost.reqFormulaId = reqRecord:GetIntValue("reqFormulaId")
    table.insert(cfg, cost)
  end
  return cfg
end
def.static("number", "=>", "table").GetSkillFormulaCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SKILL_FORMULA_CFG, id)
  if record == nil then
    warn("GetSkillFormulaCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.className = record:GetStringValue("className")
  cfg.params = {}
  local paramsListStruct = DynamicRecord.GetStructValue(record, "paramsStruct")
  local paramsAmount = DynamicRecord.GetVectorSize(paramsListStruct, "paramsVector")
  for i = 0, paramsAmount - 1 do
    local paramsRecord = DynamicRecord.GetVectorValueByIdx(paramsListStruct, "paramsVector", i)
    local param = paramsRecord:GetFloatValue("param")
    table.insert(cfg.params, param)
  end
  return cfg
end
def.static("number", "=>", "table").GetPassiveSkillCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PASSIVE_SKILL_CFG, id)
  if record == nil then
    warn("GetPassiveSkillCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.iconId = record:GetIntValue("icon")
  cfg.name = record:GetStringValue("name")
  cfg.description = record:GetStringValue("description")
  cfg.title = record:GetIntValue("title")
  cfg.type = record:GetIntValue("type")
  cfg.effectIdList = {}
  local skillEffectsStruct = DynamicRecord.GetStructValue(record, "skillEffectsStruct")
  local skillEffectsAmount = DynamicRecord.GetVectorSize(skillEffectsStruct, "skillEffectsVector")
  for i = 0, skillEffectsAmount - 1 do
    local skillEffectRecord = DynamicRecord.GetVectorValueByIdx(skillEffectsStruct, "skillEffectsVector", i)
    local skillEffectId = skillEffectRecord:GetIntValue("skillEffectId")
    table.insert(cfg.effectIdList, skillEffectId)
  end
  return cfg
end
def.static("number", "=>", "number").GetRoleSpecialSkillScore = function(id)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ROLE_SPECIAL_SKILL_SCORE)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local skillId = record:GetIntValue("skillId")
    if skillId == id then
      return record:GetIntValue("score")
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return 0
end
def.static("number", "=>", "table").GetOutFightEffectGroup = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_OUTFIGHT_SKILL_EFFECT_GROUP_CFG, id)
  if record == nil then
    warn("GetOutFightEffectGroup(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.effectId = record:GetIntValue("effectId")
  cfg.formulaIdList = {}
  local formulasStruct = DynamicRecord.GetStructValue(record, "formulasStruct")
  local formulasAmount = DynamicRecord.GetVectorSize(formulasStruct, "formulasVector")
  for i = 0, formulasAmount - 1 do
    local formulaRecord = DynamicRecord.GetVectorValueByIdx(formulasStruct, "formulasVector", i)
    local formula = formulaRecord:GetIntValue("formula")
    table.insert(cfg.formulaIdList, formula)
  end
  return cfg
end
def.static("number", "=>", "table").GetOutFightEffectFormulaCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_OUTFIGHT_EFFECT_FORMULA_CFG, id)
  if record == nil then
    warn("GetOutFightEffectFormula(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.className = record:GetStringValue("className")
  cfg.params = {}
  local paramsListStruct = DynamicRecord.GetStructValue(record, "paramsStruct")
  local paramsAmount = DynamicRecord.GetVectorSize(paramsListStruct, "paramsVector")
  for i = 0, paramsAmount - 1 do
    local paramsRecord = DynamicRecord.GetVectorValueByIdx(paramsListStruct, "paramsVector", i)
    local param = paramsRecord:GetFloatValue("param")
    table.insert(cfg.params, param)
  end
  return cfg
end
def.static("number", "=>", "table").GetRoleEffectCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ROLE_EFFECT_CFG, id)
  if record == nil then
    warn("GetRoleEffectCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.classname = record:GetStringValue("classname")
  cfg.baseProp = record:GetIntValue("baseProp")
  cfg.fightProp = record:GetIntValue("fightProp")
  cfg.fenmu = record:GetIntValue("fenmu")
  return cfg
end
def.static("number", "=>", "boolean").IsActiveSkill = function(skillId)
  if math.floor(skillId / 100000) == SkillModule.ACTIVE_SKILL_ID_PREFIX then
    return true
  end
  return false
end
def.static("number", "=>", "boolean").IsPassiveSkill = function(skillId)
  if math.floor(skillId / 100000) == SkillModule.PASSIVE_SKILL_ID_PREFIX then
    return true
  end
  return false
end
def.static("number", "=>", "boolean").IsEnchantingSkill = function(skillId)
  if math.floor(skillId / 100000) == SkillModule.ENCHANTING_SKILL_ID_PREFIX then
    return true
  end
  return false
end
def.static("number", "=>", "table").GetEnchantingSkillCfg = function(skillId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ENCHANTING_SKILL_CFG, skillId)
  if record == nil then
    warn("GetEnchantingSkillCfg(" .. skillId .. ") return nil")
    return nil
  end
  local SkillCfgData = require("Main.Skill.data.SkillCfgData")
  local skillCfg = SkillCfgData()
  skillCfg.id = record:GetIntValue("id")
  skillCfg.iconId = record:GetIntValue("icon")
  skillCfg.name = record:GetStringValue("name")
  skillCfg.description = record:GetStringValue("desc")
  skillCfg.costFormulaId = record:GetIntValue("costFormulaId")
  return skillCfg
end
def.static("string", "table", "=>", "number").EffectFormula = function(className, params)
  return params[1]
end
def.static("string", "=>", "number").GetExerciseSkillConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXERCISE_SKILL_CONSTS_CFG, key)
  if record == nil then
    warn("GetExerciseSkillConsts(" .. key .. ") return nil")
    return 0
  end
  local value = record:GetIntValue("value")
  return value
end
def.static("number", "=>", "table").GetExerciseSkillBagCfg = function(skillBagId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_EXERCISE_SKILL_BAG_CFG, skillBagId)
  if record == nil then
    warn("GetExerciseSkillBagCfg(" .. skillBagId .. ") return nil")
    return nil
  end
  local skillBagCfg = {}
  skillBagCfg.id = skillBagId
  skillBagCfg.target = record:GetIntValue("target")
  skillBagCfg.levelUpCfgId = record:GetIntValue("levelcfgid")
  skillBagCfg.skillId = record:GetIntValue("skillId")
  skillBagCfg.skillCfg = SkillUtility.GetPassiveSkillCfg(skillBagCfg.skillId)
  return skillBagCfg
end
def.static("number", "number", "=>", "number").GetExerciseSkillLevelUpNeedExp = function(skillLevel, cfgId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EXERCISE_SKILL_BAG_LEVEL_UP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  local needExp = -1
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfg.levelcfgid = record:GetIntValue("levelcfgid")
    cfg.skillLevel = record:GetIntValue("skillbaglevel")
    if cfg.skillLevel == skillLevel and cfg.levelcfgid == cfgId then
      needExp = record:GetIntValue("needExp")
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return needExp
end
def.static("number", "=>", "table").GetExerciseSkillCurMaxLevelCfg = function(roleLevel)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EXERCISE_SKILL_BAG_LEVEL_UP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local levelcfgid = record:GetIntValue("levelcfgid")
    local needRoleLevel = record:GetIntValue("needRoleLevel")
    cfg[levelcfgid] = cfg[levelcfgid] or 0
    if roleLevel >= needRoleLevel then
      local skillLevel = record:GetIntValue("skillbaglevel")
      if skillLevel > cfg[levelcfgid] then
        cfg[levelcfgid] = skillLevel
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "number", "number", "=>", "table").GetSkillCostInfo = function(skillId, skillLevel, roleLevel)
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  if skillCfg == nil then
    return nil
  end
  local conditionId = skillCfg.conditionId
  if conditionId == nil then
    warn(string.format("The condition ID of skill(%d) is nil!", skillId))
    return nil
  end
  return require("Main.Skill.SkillTipMgr").Instance():GetSkillCostInfo(conditionId, skillLevel, roleLevel)
end
def.static("number", "=>", "string").ExerciseExpToXiuWei = function(exp)
  local DAYS_PER_YEAR = 365
  local YEARS_PER_JIAZI = 60
  local days = exp % DAYS_PER_YEAR
  local years = math.floor(exp / DAYS_PER_YEAR) % YEARS_PER_JIAZI
  local jiazis = math.floor(exp / DAYS_PER_YEAR / YEARS_PER_JIAZI)
  local xiuwei = ""
  local list = {
    days,
    years,
    jiazis
  }
  for i, v in ipairs(list) do
    if v > 0 then
      xiuwei = string.format("%d%s", v, textRes.Skill.XiuWei[i]) .. xiuwei
    end
  end
  if xiuwei == "" then
    xiuwei = string.format("%d%s", 0, textRes.Skill.XiuWei[1])
  end
  return xiuwei
end
def.static("number", "number", "=>", "number", "number", "number").GetGangSkillCost = function(typeId, level)
  local key = string.format("%d_%d", level, typeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_SKILL_LEVEL_UP_CFG, key)
  if record then
    return record:GetIntValue("needSilver"), record:GetIntValue("needBanggong"), record:GetIntValue("needrolelevel")
  end
  return 0, 0, 0
end
def.static("string", "=>", "number").GetGangSkillConst = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GANG_SKILL_CONST_CFG, name)
  return DynamicRecord.GetIntValue(record, "value")
end
def.static("number", "number", "=>", "number").GetExerciseSkillScore = function(skillId, skillLevel)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_EXERCISE_SKILL_SCORE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local score = 0
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    if record then
      local id = record:GetIntValue("xiuLianSkillId")
      local level = record:GetIntValue("skillLevel")
      if id == skillId and skillLevel == level then
        local skillScore = record:GetIntValue("score")
        return skillScore or 0
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return score
end
def.static("table", "table", "=>", "table", "table").GetFormatSkillEffects = function(passiveSkillEffects, nextlevelEffects)
  local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
  local formatNumber2String = function(value)
    local integralPart, fractionalPart = math.modf(value)
    local fractionalPartLen = #tostring(fractionalPart)
    local valueStr
    if fractionalPartLen == 1 then
      valueStr = string.format("%s", integralPart)
    elseif fractionalPartLen == 3 then
      valueStr = string.format("%.1f", value)
    else
      valueStr = string.format("%.2f", value)
    end
    return valueStr
  end
  local effectTable = {}
  local nextEffectTable = {}
  for k, effect in pairs(passiveSkillEffects) do
    local cfg = GetCommonPropNameCfg(effect.prop)
    local nextEffect = nextlevelEffects[k]
    local value = effect.value
    local nextvalue = nextEffect.value
    local strValue, nextStrValue
    if cfg.valueType == ProValueType.TEN_THOUSAND_RATE then
      local divisor = 100
      strValue = string.format("%s%%", formatNumber2String(value / divisor))
      nextStrValue = string.format("%s%%", formatNumber2String(nextvalue / divisor))
    else
      strValue = tostring(value)
      nextStrValue = tostring(nextvalue)
    end
    if value > 0 then
      strValue = textRes.Common.Plus .. strValue
    elseif value == 0 then
      if nextvalue > 0 then
        strValue = textRes.Common.Plus .. strValue
      elseif nextvalue < 0 then
        strValue = textRes.Common.Minus .. strValue
      end
    end
    if nextvalue > 0 then
      nextStrValue = textRes.Common.Plus .. nextStrValue
    end
    local effectEx = {
      name = cfg.propName,
      valueText = strValue,
      prop = effect.prop,
      value = value
    }
    local nextEffectEx = {
      name = cfg.propName,
      valueText = nextStrValue,
      prop = effect.prop,
      value = nextvalue
    }
    table.insert(effectTable, effectEx)
    table.insert(nextEffectTable, nextEffectEx)
  end
  return effectTable, nextEffectTable
end
def.static("number", "number", "=>", "table").GetSkillChangeModelCfgByPlayId = function(skillPlayId, gender)
  local entries = DynamicData.GetTable(CFG_PATH.SKILL_CHANGE_MODEL_CFG)
  if entries == nil then
    return nil
  end
  local size = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    if record == nil then
      return nil
    end
    local _skillPlayId = record:GetIntValue("skillPlayId")
    local _gender = record:GetIntValue("gender")
    if _skillPlayId == skillPlayId and _gender == gender then
      local cfg = {}
      cfg.modelId = record:GetIntValue("modelId")
      cfg.appearanceId = record:GetIntValue("appearanceId")
      return cfg
    end
  end
  warn(string.format("No changeModelCfg for skillPlayId=%d, gender=%d", skillPlayId, gender))
  return nil
end
return SkillUtility.Commit()
