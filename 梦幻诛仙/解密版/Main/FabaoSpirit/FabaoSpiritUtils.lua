local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FabaoSpiritUtils = Lplus.Class(MODULE_NAME)
local def = FabaoSpiritUtils.define
def.static("number", "=>", "table").GetFabaoLQCfg = function(id)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOLINGQI_CFG, id)
  if record == nil then
    warn(">>>>Load DATA_FABAOLINGQI_CFG error id =" .. id)
    return retData
  end
  retData = retData or {}
  retData.id = record:GetIntValue("id")
  retData.name = record:GetStringValue("name")
  retData.classId = record:GetIntValue("classId")
  retData.level = record:GetIntValue("level")
  retData.color = record:GetIntValue("color")
  retData.icon = record:GetIntValue("iconId")
  retData.provideExp = record:GetIntValue("providedExp")
  retData.upgradeExp = record:GetIntValue("upgradeExp")
  retData.modelId = record:GetIntValue("modelId")
  retData.normalAction = record:GetStringValue("normalAnimation")
  retData.waitAction = record:GetStringValue("idleAnimation")
  retData.specialAction = record:GetStringValue("specialAnimation")
  retData.magicEffectId = record:GetIntValue("castSfxId")
  retData.tuoweiEffectId = record:GetIntValue("tailSfxId")
  retData.boneEffectId = record:GetIntValue("boneSfxId")
  retData.hasDuration = record:GetCharValue("hasDuration") ~= 0
  retData.skillId = record:GetIntValue("skillId")
  return retData
end
def.static("number", "=>", "table").GetFabaoLQPropCfgById = function(id)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOLINGQI_PROP_VALUE_CFG, id)
  if record == nil then
    warn(">>>>Load DATA_FABAOLINGQI_PROP_VALUE_CFG error id = " .. id)
    return retData
  end
  retData = retData or {}
  retData.improveCfgId = record:GetIntValue("improveCfgId")
  retData.arrPropValues = {}
  local propStructData = record:GetStructValue("propertyTypesStruct")
  local initStructData = record:GetStructValue("initValuesStruct")
  local finalStructData = record:GetStructValue("finalValuesStruct")
  local propvecSize = propStructData:GetVectorSize("propertyTypesList")
  for i = 1, propvecSize do
    local idx = i - 1
    local pro_record = propStructData:GetVectorValueByIdx("propertyTypesList", idx)
    local init_record = initStructData:GetVectorValueByIdx("initValuesList", idx)
    local final_record = finalStructData:GetVectorValueByIdx("finalValuesList", idx)
    local propType = pro_record:GetIntValue("propertyType")
    local initVal = init_record:GetIntValue("initVal")
    local finalVal = final_record:GetIntValue("finalVal")
    if propType > 0 then
      table.insert(retData.arrPropValues, {
        propType = propType,
        initVal = initVal,
        dstVal = finalVal
      })
    end
  end
  return retData
end
def.static("number", "=>", "table").GetFabaoLQImproveCfgById = function(id)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOLINGQI_IMPROV_CFG, id)
  if record == nil then
    warn(">>>>Load DATA_FABAOLINGQI_IMPROV_CFG error id = " .. id)
    warn(debug.traceback())
    return retData
  end
  retData = retData or {}
  retData.improveCfgId = record:GetIntValue("improveCfgId")
  retData.arrPropValues = {}
  local propStructData = record:GetStructValue("propertyTypesStruct")
  local improvedValuesStruct = record:GetStructValue("improvedValuesStruct")
  local itemFilterIdsStruct = record:GetStructValue("itemFilterIdsStruct")
  local itemNumsStruct = record:GetStructValue("itemNumsStruct")
  local propvecSize = propStructData:GetVectorSize("propertyTypesList")
  for i = 1, propvecSize do
    local idx = i - 1
    local pro_record = propStructData:GetVectorValueByIdx("propertyTypesList", idx)
    local improved_record = improvedValuesStruct:GetVectorValueByIdx("improvedValuesList", idx)
    local item_filter_record = itemFilterIdsStruct:GetVectorValueByIdx("itemFilterIdsList", idx)
    local item_num_record = itemNumsStruct:GetVectorValueByIdx("itemNumsList", idx)
    local propType = pro_record:GetIntValue("propertyType")
    if propType > 0 then
      local improveVal = improved_record:GetIntValue("improveVal")
      local itemFilterId = item_filter_record:GetIntValue("itemFilterId")
      local itemNum = item_num_record:GetIntValue("itemNum")
      table.insert(retData.arrPropValues, {
        propType = propType,
        improveVal = improveVal,
        itemFilterId = itemFilterId,
        itemNum = itemNum
      })
    end
  end
  return retData
end
def.static("number", "=>", "table").GetFabaoLQDisplayCfgById = function(id)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOLINGQI_DISPLAY_CFG, id)
  if record == nil then
    warn(">>>>Load DATA_FABAOLINGQI_DISPLAY_CFG error id ", id)
    return retData
  end
  retData = retData or {}
  retData.name = record:GetStringValue("name")
  retData.classId = record:GetIntValue("classId")
  retData.display = record:GetCharValue("display") ~= 0
  retData.icon = record:GetIntValue("iconId")
  retData.index = record:GetIntValue("index")
  retData.strGetMethod = record:GetStringValue("acquireMethod")
  retData.displayItemId = record:GetIntValue("displayItemId")
  return retData
end
def.static("=>", "table").GetAllLQTJInfo = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FABAOLINGQI_DISPLAY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local retData = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = {}
    data.name = record:GetStringValue("name")
    data.classId = record:GetIntValue("classId")
    data.display = record:GetCharValue("display") ~= 0
    data.strGetMethod = record:GetStringValue("acquireMethod")
    data.displayItemId = record:GetIntValue("displayItemId")
    if data.display == true then
      data.icon = record:GetIntValue("iconId")
      data.index = record:GetIntValue("index")
      table.insert(retData, data)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "table").GetLQClsCfgByClsId = function(clsId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOLINGQI_CLS_CFG, clsId)
  if record == nil then
    warn(">>>>Load DATA_FABAOLINGQI_CLS_CFG error id ", id)
    return retData
  end
  local retData = {}
  retData.classId = record:GetIntValue("classId")
  retData.arrCfgId = {}
  local clsIdStruct = record:GetStructValue("cfgIdListStruct")
  local clsIdVecSize = clsIdStruct:GetVectorSize("cfgIdList")
  for i = 0, clsIdVecSize - 1 do
    local record = clsIdStruct:GetVectorValueByIdx("cfgIdList", i)
    local cfgId = record:GetIntValue("cfgId")
    table.insert(retData.arrCfgId, cfgId)
  end
  retData.arrExp = {}
  local expStruct = record:GetStructValue("expListStruct")
  local expVecSize = expStruct:GetVectorSize("expList")
  for i = 0, expVecSize - 1 do
    local record = expStruct:GetVectorValueByIdx("expList", i)
    local expVal = record:GetIntValue("expVal")
    table.insert(retData.arrExp, expVal)
  end
  return retData
end
def.static("number", "=>", "table").GetItemCfgByItemId = function(itemId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOLINGQI_ITEM_CFG, itemId)
  if record == nil then
    warn("Load DATA_FABAOLINGQI_ITEM_CFG error, itemId=", itemId)
    return retData
  end
  retData = {}
  retData.itemId = record:GetIntValue("id")
  retData.LQCfgId = record:GetIntValue("artifactCfgId")
  retData.durationHour = record:GetIntValue("validDuration")
  return retData
end
def.static("number", "=>", "string").GetFabaoSpiritProName = function(proType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, proType)
  if nil == record then
    return " "
  end
  return record:GetStringValue("propName") or " "
end
local SkillUtility = require("Main.Skill.SkillUtility")
def.static("number", "=>", "table").GetSkillCfgById = function(skillId)
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  return skillCfg
end
def.static("number", "=>", "number").GetItemIdByCfgId = function(LQCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FABAOLINGQI_CFGID2ITEM_ID, LQCfgId)
  if record == nil then
    warn("LoadDATA_FABAOLINGQI_CFGID2ITEM_ID error LQCfgId = ", LQCfgId)
    return 0
  end
  local itemId = record:GetIntValue("itemCfgId")
  return itemId
end
return FabaoSpiritUtils.Commit()
