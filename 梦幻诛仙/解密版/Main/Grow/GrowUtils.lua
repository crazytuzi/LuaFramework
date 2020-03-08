local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GrowUtils = Lplus.Class(MODULE_NAME)
local def = GrowUtils.define
local instance
def.static("=>", GrowUtils).Instance = function()
  if instance == nil then
    instance = GrowUtils()
  end
  return instance
end
def.static("string", "=>", "number").GetDailyGoalConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DAILY_GOAL_CONSTS_CFG, key)
  if record == nil then
    warn("GetDailyGoalConsts(" .. key .. ") return nil")
    return nil
  end
  return record:GetIntValue("value")
end
def.static("number", "=>", "table").GetDailyGoalCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DAILY_GOAL_NEW_CFG, id)
  if record == nil then
    warn("GetDailyGoalCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = GrowUtils.GetGrowAchievementCfg(id)
  cfg.levelLow = record:GetIntValue("levelLow")
  cfg.levelUp = record:GetIntValue("levelUp")
  cfg.num = record:GetIntValue("num")
  return cfg
end
def.static("string", "=>", "dynamic").GetGrowAchievementConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROW_ACHIEVEMENT_CONSTS_CFG, key)
  if record == nil then
    warn("GetGrowAchievementConsts(" .. key .. ") return nil")
    return nil
  end
  return record:GetIntValue("value")
end
def.static("=>", "table").GetAllGrowAchievementCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GROW_ACHIEVEMENT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = GrowUtils._GetGrowAchievementCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetGrowAchievementCfg = function(achievementId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROW_ACHIEVEMENT_CFG, achievementId)
  if record == nil then
    warn("GetGrowAchievementCfg(" .. achievementId .. ") return nil")
    return nil
  end
  return GrowUtils._GetGrowAchievementCfg(record)
end
def.static("userdata", "=>", "table")._GetGrowAchievementCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.openLevel = record:GetIntValue("openLevel")
  cfg.goalType = record:GetIntValue("goalType")
  cfg.guideType = record:GetIntValue("guideType")
  cfg.moduleType = record:GetIntValue("moduleType")
  cfg.title = record:GetStringValue("title")
  cfg.goalDes = record:GetStringValue("goalDes")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.rank = record:GetIntValue("rank") or 0
  cfg.clientOperId = record:GetIntValue("clientOperId") or 0
  cfg.parameters = {}
  local parametersStruct = record:GetStructValue("parametersStruct")
  local size = parametersStruct:GetVectorSize("parametersList")
  for i = 0, size - 1 do
    local vectorRow = parametersStruct:GetVectorValueByIdx("parametersList", i)
    local row = {}
    row.parameter = vectorRow:GetIntValue("parameter")
    row.type = vectorRow:GetIntValue("type")
    table.insert(cfg.parameters, row)
  end
  return cfg
end
def.static("=>", "table").GetAllFunctionOpenForecastCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FUNCTION_OPEN_FORECAST_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = GrowUtils._GetFunctionOpenForecastCfg(entry)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetFunctionOpenForecastCfg = function(Id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FUNCTION_OPEN_FORECAST_CFG, Id)
  if record == nil then
    warn("GetFunctionOpenForecastCfgg(" .. Id .. ") return nil")
    return nil
  end
  return GrowUtils._GetFunctionOpenForecastCfg(record)
end
def.static("userdata", "=>", "table")._GetFunctionOpenForecastCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.itemId = record:GetIntValue("itemId")
  cfg.priority = record:GetIntValue("priority")
  return cfg
end
def.static("=>", "table").GetAllBianqiangCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BIAN_QIANG_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = GrowUtils._GetBianqiangCfg(entry)
    cfgs[cfg.id] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetBianqiangCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BIAN_QIANG_CFG, id)
  if record == nil then
    warn("GetBianqiangCfg(" .. id .. ") return nil")
    return nil
  end
  return GrowUtils._GetBianqiangCfg(record)
end
def.static("userdata", "=>", "table")._GetBianqiangCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.bqType = record:GetIntValue("growType")
  cfg.icon = record:GetIntValue("icon")
  cfg.level = record:GetIntValue("level")
  cfg.rank = record:GetIntValue("rank")
  cfg.operateId = record:GetIntValue("operateType")
  cfg.operateLevelType = record:GetIntValue("operateLevelType")
  cfg.title = record:GetStringValue("title")
  cfg.desc = record:GetStringValue("desc")
  cfg.star = record:GetIntValue("start") or 0
  cfg.progressType = record:GetIntValue("progressType")
  cfg.subIdList = {}
  local subTypeListStruct = record:GetStructValue("subTypeListStruct")
  local size = subTypeListStruct:GetVectorSize("subTypeList")
  for i = 0, size - 1 do
    local vectorRow = subTypeListStruct:GetVectorValueByIdx("subTypeList", i)
    local subId = vectorRow:GetIntValue("operateType")
    table.insert(cfg.subIdList, subId)
  end
  return cfg
end
def.static("number", "=>", "table").GetBianqiangTypeCfg = function(bqType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BIAN_QIANG_TYPE_CFG, bqType)
  if record == nil then
    warn("GetBianqiangTypeCfg(" .. bqType .. ") return nil")
    return {
      bqType = bqType,
      rank = bqType,
      name = "Unknow$" .. bqType
    }
  end
  local cfg = {}
  cfg.bqType = record:GetIntValue("growType")
  cfg.rank = record:GetIntValue("rank")
  cfg.name = record:GetStringValue("nameStr")
  return cfg
end
local cached_FV_cfg
def.static("number", "=>", "table").GetBianqiangFightValueCfg = function(heroLevel)
  if cached_FV_cfg and cached_FV_cfg.heroLevel == heroLevel then
    return cached_FV_cfg
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BIAN_QIANG_FIGHT_VALUE_CFG, heroLevel)
  if record == nil then
    warn("GetBianqiangFightValueCfg(" .. heroLevel .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.heroLevel = heroLevel
  cfg.powerLimit = record:GetIntValue("powerLimit")
  cfg.gradeList = {}
  local gradeNames = {
    "D",
    "C",
    "B",
    "A",
    "S",
    "SS",
    "SSS"
  }
  for i, gradeName in ipairs(gradeNames) do
    local powerLimit = record:GetIntValue(string.format("power%sLimit", gradeName))
    table.insert(cfg.gradeList, {gradeName = gradeName, minLimit = powerLimit})
  end
  cached_FV_cfg = cfg
  return cfg
end
def.static("number", "number", "=>", "table").GetFightValueGrade = function(heroLevel, fightvalue)
  local ret = {}
  ret.recommend = ""
  ret.gradeName = ""
  local cfg = GrowUtils.GetBianqiangFightValueCfg(heroLevel)
  if cfg == nil then
    return ret
  end
  ret.recommend = cfg.powerLimit
  local count = #cfg.gradeList
  if count > 0 then
    ret.gradeName = cfg.gradeList[1].gradeName
  end
  for i = count, 1, -1 do
    if fightvalue >= cfg.gradeList[i].minLimit then
      ret.gradeName = cfg.gradeList[i].gradeName
      break
    end
  end
  return ret
end
def.static("number", "=>", "table").GetGrowClientOperationCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GROW_CLIENT_OPERATION_CFG, id)
  if record == nil then
    warn("GetGrowClientOperationCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.operateType = record:GetIntValue("operateType")
  cfg.params = {}
  local hasParam = false
  for i = 5, 1, -1 do
    local param = record:GetStringValue("param" .. i)
    if param ~= "null" or hasParam then
      hasParam = true
      cfg.params[i] = param
    end
  end
  return cfg
end
def.static("number", "=>", "boolean").ApplyOperation = function(id)
  return GrowUtils.ApplyOperationWithParams(id, nil)
end
def.static("number", "table", "=>", "boolean").ApplyOperationWithParams = function(id, params)
  local cfg = GrowUtils.GetGrowClientOperationCfg(id)
  if cfg == nil then
    return false
  end
  local OperationsFactory = require("Main.Grow.Operations.OperationsFactory")
  local operation = OperationsFactory.CreateOperation(cfg.operateType)
  local allParams = cfg.params
  if params then
    for i, v in ipairs(params) do
      table.insert(allParams, v)
    end
  end
  return operation:Operate(allParams)
end
local bianqiangProgressCache
def.static("=>", "table").GetBianQiangProgressCfg = function()
  if bianqiangProgressCache then
    return bianqiangProgressCache
  end
  bianqiangProgressCache = {}
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_BIAN_QIANG_GROW_PROGRESS_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local progressCfg = {}
    progressCfg.lowerRate = record:GetIntValue("progresslowerrate")
    progressCfg.upRate = record:GetIntValue("progressuprate")
    progressCfg.stateDesc = record:GetStringValue("statestr")
    progressCfg.spriteName = record:GetStringValue("colorimagename")
    table.insert(bianqiangProgressCache, progressCfg)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  table.sort(bianqiangProgressCache, function(l, r)
    return l.lowerRate < r.lowerRate
  end)
  return bianqiangProgressCache
end
local growScoreCfgCache
def.static("number", "number", "=>", "number").GetGrowScoreCfg = function(progressType, heroLevel)
  if growScoreCfgCache and growScoreCfgCache[progressType] and growScoreCfgCache[progressType][heroLevel] then
    return growScoreCfgCache[progressType][heroLevel]
  end
  growScoreCfgCache = {}
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_BIAN_QIANG_GROW_SCORE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local roleLevel = record:GetIntValue("rolelevel")
    local pType = record:GetIntValue("progressType")
    local value = record:GetIntValue("value")
    if progressType == pType and heroLevel == roleLevel then
      growScoreCfgCache[pType] = growScoreCfgCache[pType] or {}
      growScoreCfgCache[pType][roleLevel] = value
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return growScoreCfgCache[progressType] and growScoreCfgCache[progressType][heroLevel] or 100
end
def.static("=>", "number").CalcMenPaiValue = function()
  local value = 0
  local SkillMgr = require("Main.Skill.SkillMgr")
  local menpaiSkillBagList = SkillMgr.Instance():GetOccupationSkillBagList()
  if not menpaiSkillBagList or #menpaiSkillBagList < 1 then
    return value
  end
  for _, skillBag in pairs(menpaiSkillBagList) do
    value = value + skillBag.level
  end
  return value
end
def.static("=>", "number").CalcXiuLianValue = function()
  local value = 0
  local xiulianSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  local SkillUtility = require("Main.Skill.SkillUtility")
  local skillbagList = xiulianSkillMgr.Instance():GetSkillBagList()
  if skillbagList then
    for _, skillBagInfo in pairs(skillbagList) do
      local score = SkillUtility.GetExerciseSkillScore(skillBagInfo.id, skillBagInfo.level)
      value = value + score
    end
  end
  return value
end
def.static("=>", "number").CalcXianLvValue = function()
  local value = 0
  local XianLvInterface = require("Main.partner.PartnerInterface")
  local partnerInfos = XianLvInterface.Instance():GetPartnerInfos()
  if partnerInfos then
    local ownPartners = partnerInfos.ownPartners
    if ownPartners then
      for k, v in pairs(ownPartners) do
        local partnerProperty = XianLvInterface.Instance():GetPartnerProperty(v)
        if partnerProperty and partnerProperty.fightValue then
          value = value + partnerProperty.fightValue
        end
      end
    end
  end
  return value
end
def.static("=>", "number").CalcEquipValue = function()
  local value = 0
  local EquipUtils = require("Main.Equip.EquipUtils")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemModule = require("Main.Item.ItemModule")
  local ItemUtils = require("Main.Item.ItemUtils")
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  local equipBagInfo = ItemModule.Instance():GetItemsByBagId(eqpBagId)
  for key, itemInfo in pairs(equipBagInfo) do
    local itemId = itemInfo.id
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase ~= nil and itemBase.itemType == ItemType.EQUIP then
      local score = EquipUtils.CalcEpuipScoreUtil(itemInfo) or 0
      local qilinScore = EquipUtils.GetQiLingScore(itemInfo) or 0
      value = value + (score - qilinScore)
    end
  end
  return value
end
def.static("=>", "number").CalcQiLingValue = function()
  local value = 0
  local EquipUtils = require("Main.Equip.EquipUtils")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemModule = require("Main.Item.ItemModule")
  local ItemUtils = require("Main.Item.ItemUtils")
  local eqpBagId = require("netio.protocol.mzm.gsp.item.BagInfo").EQUIPBAG
  local equipBagInfo = ItemModule.Instance():GetItemsByBagId(eqpBagId)
  for key, itemInfo in pairs(equipBagInfo) do
    local itemId = itemInfo.id
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase ~= nil and itemBase.itemType == ItemType.EQUIP then
      local strenLevel = itemInfo.extraMap[ItemXStoreType.STRENGTH_LEVEL]
      if nil == strenLevel then
        strenLevel = 0
      end
      value = value + strenLevel
    end
  end
  return value
end
def.static("=>", "number").CalcPetValue = function()
  local value = 0
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local pets = PetMgr.Instance():GetPets()
  if pets then
    local sortPets = {}
    for _, petdata in pairs(pets) do
      table.insert(sortPets, petdata)
    end
    if #sortPets > 0 then
      table.sort(sortPets, function(a, b)
        return a:GetYaoLi() > b:GetYaoLi()
      end)
      for i = 1, 3 do
        if sortPets[i] then
          value = value + sortPets[i]:GetYaoLi()
        end
      end
    end
  end
  return value
end
def.static("=>", "number").CalcWingValue = function()
  local value = 0
  local wingsLevel = require("Main.Wing.WingInterface").GetCurWingLevel()
  return value + wingsLevel
end
def.static("=>", "number").CalcFaBaoValue = function()
  local value = 0
  local FabaoUitls = require("Main.Fabao.FabaoUtils")
  local FabaoData = require("Main.Fabao.data.FabaoData")
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local allFabao = FabaoData.Instance():GetAllFabaoData()
  if allFabao then
    for k, v in pairs(allFabao) do
      if v then
        local fabaoId = v.id
        local fabaoBase = ItemUtils.GetFabaoItem(fabaoId)
        local attrId = fabaoBase.attrId
        local fabaoLevel = v.extraMap[ItemXStoreType.FABAO_CUR_LV]
        local skillId = v.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
        local score = FabaoUitls.GetFabaoScore(attrId, fabaoLevel, skillId)
        value = value + score
      end
    end
  end
  return value
end
return GrowUtils.Commit()
