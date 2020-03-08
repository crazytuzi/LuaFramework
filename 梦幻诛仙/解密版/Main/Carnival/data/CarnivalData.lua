local Lplus = require("Lplus")
local CarnivalUtils = require("Main.Carnival.CarnivalUtils")
local CarnivalData = Lplus.Class("CarnivalData")
local def = CarnivalData.define
local _instance
def.static("=>", CarnivalData).Instance = function()
  if _instance == nil then
    _instance = CarnivalData()
  end
  return _instance
end
def.field("table")._carnivalCfg = nil
def.field("table")._subCarnivalCfg = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._carnivalCfg = nil
  self._subCarnivalCfg = nil
end
def.method()._LoadCarnivalCfg = function(self)
  warn("[CarnivalData:_LoadCarnivalCfg] start Load CarnivalGeneralCfg!")
  self._carnivalCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CARNIVAL_GENERAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local generalCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    generalCfg.activityId = DynamicRecord.GetIntValue(entry, "activity_cfgid")
    generalCfg.switchid = DynamicRecord.GetIntValue(entry, "switchid")
    generalCfg.exchangeId = DynamicRecord.GetIntValue(entry, "exchange_typeid")
    generalCfg.tipId = DynamicRecord.GetIntValue(entry, "tipsid")
    generalCfg.awardItems = {}
    local struct = entry:GetStructValue("award_itemsStruct")
    local count = struct:GetVectorSize("award_items")
    for i = 1, count do
      local record = struct:GetVectorValueByIdx("award_items", i - 1)
      local awardId = record:GetIntValue("awardId")
      table.insert(generalCfg.awardItems, awardId)
    end
    self._carnivalCfg[generalCfg.activityId] = generalCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetCarnivalCfgs = function(self)
  if nil == self._carnivalCfg then
    self:_LoadCarnivalCfg()
  end
  return self._carnivalCfg
end
def.method("number", "=>", "table").GetCarnivalCfg = function(self, id)
  return self:_GetCarnivalCfgs()[id]
end
def.method("number", "=>", "table").GetCarnivalActivities = function(self, carnivalId)
  local actList = {}
  local subCarnivalCfgs = self:_GetSubCarnivalCfgs()
  if subCarnivalCfgs then
    local GuidelineType = require("consts.mzm.gsp.activity3.confbean.GuidelineType")
    for subCarnivalId, subCarnivalCfg in pairs(subCarnivalCfgs) do
      if subCarnivalCfg.parentActivityId == carnivalId and subCarnivalCfg.subCarnivalType == GuidelineType.ACTIVITY then
        table.insert(actList, subCarnivalCfg.referenceId)
      end
    end
  else
    warn("[ERROR][CarnivalData:CanAttendActivity] subCarnivalCfgs nil.")
  end
  return actList
end
def.method("number", "=>", "table").GetCarnivalAwards = function(self, carnivalId)
  local result
  local carnivalCfg = self:GetCarnivalCfg(carnivalId)
  if carnivalCfg then
    result = carnivalCfg.awardItems
  else
    warn("[ERROR][CarnivalData:CanAttendActivity] carnivalCfg nil for carnivalId:", carnivalId)
  end
  return result
end
def.method("number", "=>", "number").GetCarnivalIDIP = function(self, carnivalId)
  local result = 0
  local carnivalCfg = self:GetCarnivalCfg(carnivalId)
  if carnivalCfg then
    result = carnivalCfg.switchid
  else
    warn("[ERROR][CarnivalData:GetCarnivalIDIP] carnivalCfg nil for carnivalId:", carnivalId)
  end
  return result
end
def.method("number", "=>", "number").GetCarnivalTipId = function(self, carnivalId)
  local result = 0
  local carnivalCfg = self:GetCarnivalCfg(carnivalId)
  if carnivalCfg then
    result = carnivalCfg.tipId
  else
    warn("[ERROR][CarnivalData:GetCarnivalTipId] carnivalCfg nil for carnivalId:", carnivalId)
  end
  return result
end
def.method("number", "=>", "table").GetCarnivalExchangeCfgs = function(self, carnivalId)
  local result = {}
  local carnivalCfg = self:GetCarnivalCfg(carnivalId)
  if carnivalCfg then
    local exchangeCfg = require("Main.Exchange.ExchangeInterface").GetExchangeCfg(carnivalCfg.exchangeId)
    if exchangeCfg then
      table.insert(result, exchangeCfg)
    else
      warn("[ERROR][CarnivalData:GetCarnivalExchangeCfg] exchangeCfg nil for carnivalCfg.exchangeId:", carnivalCfg.exchangeId)
    end
  else
    warn("[ERROR][CarnivalData:GetCarnivalExchangeCfg] carnivalCfg nil for carnivalId:", carnivalId)
  end
  return result
end
def.method()._LoadSubCarnivalCfg = function(self)
  warn("[CarnivalData:_LoadSubCarnivalCfg] start Load SubActivityCfg!")
  self._subCarnivalCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CARNIVAL_SUB_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local subCarnivalCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    subCarnivalCfg.subCarnivalId = DynamicRecord.GetIntValue(entry, "id")
    subCarnivalCfg.parentActivityId = DynamicRecord.GetIntValue(entry, "parent_activity_cfgid")
    subCarnivalCfg.subCarnivalType = DynamicRecord.GetIntValue(entry, "guideline_type")
    subCarnivalCfg.referenceId = DynamicRecord.GetIntValue(entry, "guideline_referenceid")
    self._subCarnivalCfg[subCarnivalCfg.subCarnivalId] = subCarnivalCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetSubCarnivalCfgs = function(self)
  if nil == self._subCarnivalCfg then
    self:_LoadSubCarnivalCfg()
  end
  return self._subCarnivalCfg
end
def.method("number", "=>", "table").GetSubCarnivalCfg = function(self, subCarnivalId)
  return self:_GetSubCarnivalCfgs()[subCarnivalId]
end
def.method("number", "=>", "table").GetValidActivities = function(self, carnivalActId)
  local validList = {}
  local allList = self:GetCarnivalActivities(carnivalActId)
  if allList and #allList > 0 then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    for _, actId in ipairs(allList) do
      local actCfg = ActivityInterface.GetActivityCfgById(actId)
      if CarnivalUtils.CanAttendActivity(actId, actCfg, false) then
        table.insert(validList, actCfg)
      end
    end
  end
  return validList
end
def.method("number", "=>", "boolean").IsAnyActivityOpen = function(self, carnivalActId)
  local result = false
  local allList = self:GetCarnivalActivities(carnivalActId)
  if allList and #allList > 0 then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    for _, actId in ipairs(allList) do
      local actCfg = ActivityInterface.GetActivityCfgById(actId)
      if CarnivalUtils.CanAttendActivity(actId, actCfg, false) then
        result = true
        break
      end
    end
  end
  return result
end
def.method("number", "=>", "boolean").CanCarnivalExchange = function(self, carnivalId)
  local result = false
  local carnivalCfg = self:GetCarnivalCfg(carnivalId)
  if carnivalCfg then
    result = require("Main.Exchange.ExchangeInterface").Instance():calcExchangeRedPoint(carnivalId)
  else
    warn("[ERROR][CarnivalData:GetCarnivalExchangeCfg] carnivalCfg nil for carnivalId:", carnivalId)
  end
  return result
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
CarnivalData.Commit()
return CarnivalData
