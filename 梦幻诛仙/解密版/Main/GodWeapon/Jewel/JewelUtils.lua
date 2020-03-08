local MODULE_NAME = (...)
local Lplus = require("Lplus")
local JewelUtils = Lplus.Class(MODULE_NAME)
local def = JewelUtils.define
def.static("number", "boolean", "=>", "table").GetJewelItemByItemId = function(itemId, bLoadAllProp)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.DATA_JewelItemCfg, itemId)
  if record == nil then
    warn("Load DATA_JewelItemCfg error, itemId =", itemId)
    return retData
  end
  retData = {}
  retData.level = record:GetIntValue("jewelLevel")
  retData.itemId = record:GetIntValue("id")
  retData.type = record:GetIntValue("jewelType")
  retData.nxtLvItemId = record:GetIntValue("nextLevelId")
  retData.needCurLvItemNum = record:GetIntValue("craftNextLevelCount")
  retData.nxtLvNeedMoneyType = record:GetIntValue("craftNextLevelMoneyType")
  retData.nxtLvNeedMoneyNum = record:GetIntValue("craftNextLevelMoneyCount")
  retData.nxtLvNeedItemId = record:GetIntValue("craftNextLevelItemId")
  retData.nxtLvNeedItemNum = record:GetIntValue("craftNextLevelItemCount")
  retData.typeId = record:GetIntValue("typeId")
  retData.arrProps = {}
  local propTypeStruct = record:GetStructValue("properTypesStruct")
  local propValStruct = record:GetStructValue("propertyValuesStruct")
  local vecSize = propTypeStruct:GetVectorSize("properTypes")
  for i = 1, vecSize do
    local idx = i - 1
    local propTypeRecord = propTypeStruct:GetVectorValueByIdx("properTypes", idx)
    local propValRecord = propValStruct:GetVectorValueByIdx("propertyValues", idx)
    local data = {}
    data.propType = propTypeRecord:GetIntValue("propType")
    data.propVal = propValRecord:GetIntValue("propVal")
    if bLoadAllProp then
      table.insert(retData.arrProps, data)
    elseif data.propType > 0 then
      table.insert(retData.arrProps, data)
    end
  end
  return retData
end
def.static("=>", "table").GetAllJewelPropTypesCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_JewelItemCfg)
  if entries == nil then
    warn("Load all JewelCfg error")
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local retData = {}
  local tblPropTypes = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = {}
    local propTypeStruct = record:GetStructValue("properTypesStruct")
    local propValStruct = record:GetStructValue("propertyValuesStruct")
    local vecSize = propTypeStruct:GetVectorSize("properTypes")
    local arrProps = {}
    for j = 1, vecSize do
      local idx = j - 1
      local propTypeRecord = propTypeStruct:GetVectorValueByIdx("properTypes", idx)
      local propType = propTypeRecord:GetIntValue("propType")
      table.insert(arrProps, propType)
    end
    local propKey = JewelUtils.GetKeyByPropArr(arrProps)
    tblPropTypes[propKey] = 0
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  for propType, _ in pairs(tblPropTypes) do
    if propType ~= "" then
      table.insert(retData, propType)
    end
  end
  return retData
end
def.static("table", "=>", "string").GetKeyByPrpArrTbl = function(props)
  if props == nil then
    return ""
  end
  local arrProps = {}
  for i = 1, #props do
    table.insert(arrProps, props[i].propType)
  end
  return JewelUtils.GetKeyByPropArr(arrProps)
end
def.static("table", "=>", "string").GetKeyByPropArr = function(arrProps)
  if arrProps == nil then
    warn("ERROR: GetKeyByPropArr arrProps is nil")
    return ""
  end
  table.sort(arrProps, function(a, b)
    if a < b then
      return true
    else
      return false
    end
  end)
  local retData = ""
  for i = 1, #arrProps do
    if arrProps[i] > 0 then
      retData = retData .. arrProps[i] .. "_"
    end
  end
  return retData
end
def.static("string", "=>", "string").GetUniqNameByPropKey = function(strPropKey)
  local arrProps = string.split(strPropKey, "_")
  local arrPropSize = #arrProps
  local retData = ""
  for i = 1, arrPropSize do
    local strProp = "0"
    if arrProps[i] ~= "" and arrProps[i] ~= nil then
      strProp = arrProps[i]
    end
    local propType = tonumber(strProp)
    if propType > 0 then
      local propName = JewelUtils.GetProName(propType)
      if propType > 0 then
        if i == 1 then
          retData = retData .. propName
        else
          retData = retData .. "," .. propName
        end
      end
    end
  end
  return retData
end
def.static("number", "number", "=>", "table").GetJewelsBasicCfgByEquipType = function(equipType, lv)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_JewelItemCfg)
  if entries == nil then
    warn("Load all JewelCfg error")
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local retData = {}
  local tblPropTypes = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local jewelType = record:GetIntValue("jewelType")
    local level = record:GetIntValue("jewelLevel")
    local data = {}
    data.level = level
    data.itemId = record:GetIntValue("id")
    data.type = jewelType
    data.typeId = record:GetIntValue("typeId")
    if lv <= 0 then
      table.insert(retData, data)
    elseif jewelType == equipType and level == lv then
      table.insert(retData, data)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "number").GetCompoundFromCfgId = function(dstCfgId)
  local retData = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_JEWEL_FROM_CFG, dstCfgId)
  if record == nil then
    warn("Load DATA_JEWEL_FROM_CFG error, itemId =", dstCfgId)
    return retData
  end
  local fromCfgId = record:GetIntValue("fromJewelCfgId")
  return fromCfgId
end
def.static("number", "=>", "string").GetProName = function(proType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, proType)
  if nil == record then
    return " "
  end
  return record:GetStringValue("propName") or " "
end
def.static("number", "number", "=>", "number").GetDefaultShowJewelType = function(occupId, wearPos)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DEFAULT_SHOW_JEWEL)
  if entries == nil then
    warn("Load all DATA_DEFAULT_SHOW_JEWEL error")
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local iOccupId = record:GetIntValue("occupId")
    local iWearPos = record:GetIntValue("jewelType")
    if iOccupId == occupId and iWearPos == wearPos then
      DynamicDataTable.FastGetRecordEnd(entries)
      return record:GetIntValue("jewelTypeId")
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return -1
end
return JewelUtils.Commit()
