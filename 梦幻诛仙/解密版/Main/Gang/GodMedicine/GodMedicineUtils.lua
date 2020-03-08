local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GodMedicineUtils = Lplus.Class(MODULE_NAME)
local Cls = GodMedicineUtils
local def = Cls.define
def.static("=>", "table").LoadActivityBaseCfgs = function()
  return {}
end
def.static("number", "=>", "table").GetActivityCfgById = function(actId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.GODMEDICINE_ACTIVITY_CFG, actId)
  if record == nil then
    warn("ERROR: Load GODMEDICINE_ACTIVITY_CFG failed, actId:", actId)
    return nil
  end
  retData = {}
  retData.actId = record:GetIntValue("activityId")
  retData.lifeSkillId = record:GetIntValue("lifeSkillId")
  retData.openId = record:GetIntValue("openId")
  retData.openServerLevel = record:GetIntValue("openServerLevel")
  retData.openLivelyLowRate = record:GetIntValue("openLivelyLowRate")
  retData.openLifeSkillLevel = record:GetIntValue("openLifeSkillLevel")
  retData.npcCfgId = record:GetIntValue("npcCfgId")
  retData.npcServiceId = record:GetIntValue("npcServiceCfgId")
  retData.hoverTipsId = record:GetIntValue("hoverTipsId")
  retData.successEffectId = record:GetIntValue("successEffectId")
  retData.titleSpriteName = record:GetStringValue("titleImageId")
  retData.decorationImgId = record:GetIntValue("guiDecorationImageId")
  retData.midDecorationImgId = record:GetIntValue("guiMidDecorationImageId")
  retData.joinPromptDes = record:GetStringValue("joinPromptDes")
  return retData
end
def.static("=>", "table").LoadAllOpenActIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.GODMEDICINE_OPENID_CFG)
  if entries == nil then
    warn("ERROR: Load GODMEDICINE_OPENID_CFG failed")
    return nil
  end
  local retData = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local openId = record:GetIntValue("openId")
    local actId = record:GetIntValue("activityId")
    table.insert(retData, {openId = openId, actId = actId})
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("number", "=>", "userdata").getShowItemStruct = function(actId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.GODMEDICINE_DSTITEMS_CFG, actId)
  if record == nil then
    warn("ERROR: Load GODMEDICINE_DSTITEMS_CFG failed, actId:", actId)
    return nil
  end
  local lifeSkillLvInfoStruct = record:GetStructValue("lifeSkillLevelInfoStruct")
  return lifeSkillLvInfoStruct
end
def.static("number", "number", "=>", "table").GetShowItemsByActidAndLv = function(actId, lifeSkillLv)
  local lifeSkillLvInfoStruct = Cls.getShowItemStruct(actId)
  if lifeSkillLvInfoStruct == nil then
    return nil
  end
  local readData = function(dataStruct)
    if dataStruct == nil then
      return nil
    end
    local data = {}
    data.lifeSkillLevel = dataStruct:GetIntValue("lifeSkillLevel")
    data.itemList = {}
    local itemStruct = dataStruct:GetStructValue("showItemStruct")
    local innerVecSize = itemStruct:GetVectorSize("showItemList")
    for j = 0, innerVecSize - 1 do
      local itemRecord = itemStruct:GetVectorValueByIdx("showItemList", j)
      local itemId = itemRecord:GetIntValue("itemId")
      table.insert(data.itemList, itemId)
    end
    return data
  end
  local vecSize = lifeSkillLvInfoStruct:GetVectorSize("lifeSkillLevelInfoList")
  local preRecord
  for i = 0, vecSize - 1 do
    local innerRecord = lifeSkillLvInfoStruct:GetVectorValueByIdx("lifeSkillLevelInfoList", i)
    local lv = innerRecord:GetIntValue("lifeSkillLevel")
    if lifeSkillLv < lv and preRecord ~= nil then
      local data = readData(preRecord)
      break
    end
    preRecord = innerRecord
  end
  return readData(preRecord)
end
def.static("number", "=>", "number").GetMinSkillLv = function(actId)
  local lifeSkillLvInfoStruct = Cls.getShowItemStruct(actId)
  if lifeSkillLvInfoStruct == nil then
    return -1
  end
  local record = lifeSkillLvInfoStruct:GetVectorValueByIdx("lifeSkillLevelInfoList", 0)
  local lv = record:GetIntValue("lifeSkillLevel")
  warn("=============>minLifeSkillLv", lv)
  return lv
end
def.static("number", "=>", "userdata").getCostInfoStuct = function(actId)
  local retData
  local record = DynamicData.GetRecord(CFG_PATH.GODMEDICINE_COSTINFO_CFG, actId)
  if record == nil then
    warn("ERROR: Load GODMEDICINE_COSTINFO_CFG failed, actId:", actId)
    return nil
  end
  local createAndCostInfoStruct = record:GetStructValue("createAndCostInfoStruct")
  return createAndCostInfoStruct
end
def.static("number", "number", "=>", "table").GetCostInfoLvByActidAndLv = function(actId, yaodianLv)
  local createAndCostInfoStruct = Cls.getCostInfoStuct(actId)
  if createAndCostInfoStruct == nil then
    return nil
  end
  local vecSize = createAndCostInfoStruct:GetVectorSize("createAndCostInfoList")
  local retData = {}
  local preRecord
  local readData = function(dataStruct)
    if dataStruct == nil then
      return nil
    end
    local data = {}
    data.yaodianLevel = dataStruct:GetIntValue("yaodianLevel")
    data.costType = dataStruct:GetIntValue("costType")
    data.costNum = dataStruct:GetIntValue("costNum")
    data.maxTimes = dataStruct:GetIntValue("maxNum")
    data.lifeSkillId = dataStruct:GetIntValue("lifeSkillId")
    return data
  end
  for i = 0, vecSize - 1 do
    local innerRecord = createAndCostInfoStruct:GetVectorValueByIdx("createAndCostInfoList", i)
    local lv = innerRecord:GetIntValue("yaodianLevel")
    if yaodianLv < lv and preRecord ~= nil then
      local data = readData(preRecord)
      return data
    end
    preRecord = innerRecord
  end
  return readData(preRecord)
end
def.static("number", "=>", "number").GetMinYaoDianLvByActid = function(actId)
  local createAndCostInfoStruct = Cls.getCostInfoStuct(actId)
  if createAndCostInfoStruct == nil then
    return 0
  end
  local innerRecord = createAndCostInfoStruct:GetVectorValueByIdx("createAndCostInfoList", 0)
  local lv = innerRecord:GetIntValue("yaodianLevel")
  return lv
end
return Cls.Commit()
