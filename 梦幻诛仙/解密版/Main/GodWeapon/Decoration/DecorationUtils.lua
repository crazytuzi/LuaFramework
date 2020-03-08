local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DecorationUtils = Lplus.Class(MODULE_NAME)
local def = DecorationUtils.define
def.static("=>", "table").GetAllWSCls = function()
  local retData
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WUSHI_TYPE2ONE_LEVEL_CFGID_CFG)
  if entries == nil then
    warn("Load God Weapon DATA_WUSHI_TYPE2ONE_LEVEL_CFGID_CFG failed...")
    return retData
  end
  retData = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = {}
    data.type = record:GetIntValue("typeId")
    data.cfgId = record:GetIntValue("firstLevelId")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "number").GetOneLvCfgIdByType = function(type)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WUSHI_TYPE2ONE_LEVEL_CFGID_CFG, type)
  if record == nil then
    warn("LOAD DATA_WUSHI_TYPE2ONE_LEVEL_CFGID_CFG ERROR, type=", type)
    return retData
  end
  retData = record:GetIntValue("firstLevelId")
  return retData
end
local ShowType = require("consts.mzm.gsp.superequipment.wushi.confbean.ShowType")
def.static("number", "=>", "table").GetWSBasicCfgById = function(WSId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WUSHI_CFG, WSId)
  if record == nil then
    warn("Load WuShi Basic config failed, id", WSId)
    return retData
  end
  retData = {}
  retData.id = record:GetIntValue("id")
  retData.level = record:GetIntValue("wuShiLevel")
  retData.name = record:GetStringValue("name")
  retData.icon = record:GetIntValue("icon")
  retData.displayTypeId = record:GetIntValue("appearanceTypeId")
  retData.nxtLvId = record:GetIntValue("nextLevelId")
  retData.bIsShow = record:GetIntValue("isShow") == ShowType.SHOW
  retData.fragsItemId = record:GetIntValue("fragmentItemId")
  retData.fragsCount = record:GetIntValue("fragmentCount")
  retData.source = record:GetStringValue("source")
  retData.type = record:GetIntValue("typeId")
  retData.arrProps = {}
  local propStructData = record:GetStructValue("properTypesStruct")
  local propValStructData = record:GetStructValue("propertyValuesStruct")
  local propvecSize = propStructData:GetVectorSize("properTypes")
  for i = 1, propvecSize do
    local idx = i - 1
    local pro_record = propStructData:GetVectorValueByIdx("properTypes", idx)
    local val_record = propValStructData:GetVectorValueByIdx("propertyValues", idx)
    local propType = pro_record:GetIntValue("propType")
    local propVal = val_record:GetIntValue("propVal")
    if propType > 0 then
      table.insert(retData.arrProps, {propType = propType, propVal = propVal})
    end
  end
  return retData
end
def.static("number", "=>", "table").GetAppearanceByTypeId = function(typeId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WUSHI_APPEARANCE_CFG, typeId)
  if record == nil then
    warn("LOAD DATA_WUSHI_APPEARANCE_CFG ERROR, cfgId", typeId)
    return retData
  end
  retData = {}
  retData.typeId = typeId
  retData.apperances = {}
  local apperanceStruct = record:GetStructValue("wuShiAppearancesStruct")
  local size = apperanceStruct:GetVectorSize("wuShiAppearances")
  for i = 1, size do
    local apperanceRecord = apperanceStruct:GetVectorValueByIdx("wuShiAppearances", i - 1)
    local data = {}
    data.equipModelId = apperanceRecord:GetIntValue("equipModelCfgId")
    data.gender = apperanceRecord:GetIntValue("gender")
    data.id = apperanceRecord:GetIntValue("id")
    data.occupation = apperanceRecord:GetIntValue("menpai")
    data.scale = apperanceRecord:GetIntValue("scale")
    data.effectId = apperanceRecord:GetIntValue("wuShiEffectId")
    data.curModelId = apperanceRecord:GetIntValue("currentModelCfgId")
    table.insert(retData.apperances, data)
  end
  return retData
end
def.static("number", "=>", "table").GetItemIdsByCfgId = function(cfgId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WUSHI_CFGID2ITEMID_CFG, cfgId)
  if record == nil then
    warn("LOAD DATA_WUSHI_CFGID2ITEMID_CFG ERROR, cfgId = ", cfgId)
    return retData
  end
  retData = {}
  retData.cfgId = cfgId
  retData.itemIds = {}
  local idsStruct = record:GetStructValue("wuShiItemCfgIdsStruct")
  local size = idsStruct:GetVectorSize("wuShiItemCfgIds")
  for i = 0, size - 1 do
    local idRecord = idsStruct:GetVectorValueByIdx("wuShiItemCfgIds", i)
    local itemId = idRecord:GetIntValue("itemId")
    table.insert(retData.itemIds, itemId)
  end
  return retData
end
def.static("number", "=>", "table").GetItemIdsByWuShiType = function(typeId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WUSHI_TYPE2ITEMS, typeId)
  if record == nil then
    warn("LOAD DATA_WUSHI_TYPE2ITEMS ERROR, cfgId = ", typeId)
    return retData
  end
  retData = {}
  retData.typeId = typeId
  retData.itemIds = {}
  local idsStruct = record:GetStructValue("wuShiItemCfgIdsStruct")
  local size = idsStruct:GetVectorSize("wuShiItemCfgIds")
  for i = 0, size - 1 do
    local idRecord = idsStruct:GetVectorValueByIdx("wuShiItemCfgIds", i)
    local itemId = idRecord:GetIntValue("itemId")
    table.insert(retData.itemIds, itemId)
  end
  return retData
end
def.static("number", "=>", "table").GetCfgIdByItemId = function(itemId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WUSHI_ITEM_CFG, itemId)
  if record == nil then
    warn("LOAD DATA_WUSHI_ITEM_CFG ERROR, itemId = ", itemId)
    return retData
  end
  retData = {}
  retData.itemId = record:GetIntValue("id")
  retData.fragsCount = record:GetIntValue("fragmentCount")
  retData.cfgId = record:GetIntValue("wuShiCfgId")
  retData.source = record:GetStringValue("source")
  return retData
end
def.static("number", "=>", "string").GetProName = function(proType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, proType)
  if nil == record then
    return ""
  end
  return record:GetStringValue("propName") or ""
end
return DecorationUtils.Commit()
