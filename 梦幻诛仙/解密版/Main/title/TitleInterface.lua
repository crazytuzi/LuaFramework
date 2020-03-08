local Lplus = require("Lplus")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local TitleInterface = Lplus.Class("TitleInterface")
local def = TitleInterface.define
local instance
def.static("=>", TitleInterface).Instance = function()
  if instance == nil then
    instance = TitleInterface()
    instance:_Init()
  end
  return instance
end
def.field("table")._ownTitle = nil
def.field("table")._ownAppellation = nil
def.field("number")._activeTitle = 0
def.field("number")._activeAppellation = 0
def.field("number")._pro2appellationId = 0
def.field("table")._timeoutTable = nil
def.field("table")._argsTable = nil
TitleInterface.colors = {
  {
    r = 255,
    g = 255,
    b = 255
  },
  {
    r = 0,
    g = 255,
    b = 0
  },
  {
    r = 0,
    g = 0,
    b = 255
  },
  {
    r = 255,
    g = 0,
    b = 255
  },
  {
    r = 255,
    g = 160,
    b = 122
  }
}
def.method()._Init = function(self)
  self:Reset()
end
def.method().Init = function(self)
end
def.method().Reset = function(self)
  self._ownTitle = {}
  self._ownAppellation = {}
  self._activeTitle = 0
  self._activeAppellation = 0
  self._pro2appellationId = 0
  self._timeoutTable = {}
  self._argsTable = {}
end
def.static("number", "=>", "table").GetAppellationCfg = function(appellationID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TITLE_APPELLATION_CFG, appellationID)
  if record == nil then
    print("** GetAppellationCfg(", appellationID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.bigAppellation = record:GetIntValue("bigAppellation")
  cfg.appellationName = record:GetStringValue("appellationName")
  cfg.appellationColor = record:GetIntValue("appellationColor")
  cfg.description = record:GetStringValue("description")
  cfg.getMethod = record:GetStringValue("getMethod")
  cfg.appellationOutTime = record:GetIntValue("appellationOutTime")
  cfg.appellationLimit = record:GetIntValue("appellationLimit")
  cfg.properties = {}
  local rec2 = record:GetStructValue("property2valueListStruct")
  local count = rec2:GetVectorSize("property2valueList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("property2valueList", i - 1)
    local p = {}
    p.propertyID = rec3:GetIntValue("property")
    p.value = rec3:GetIntValue("value")
    if p.propertyID ~= 0 then
      table.insert(cfg.properties, p)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetAppellationTypeCfg = function(appellationTypeID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TITLE_APPELLATIONTYPE_CFG, appellationTypeID)
  if record == nil then
    print("** GetAppellationTypeCfg(", appellationTypeID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.bigAppellation = record:GetIntValue("bigAppellation")
  cfg.rank = record:GetIntValue("rank")
  cfg.name = record:GetStringValue("templateName")
  return cfg
end
def.static("number", "table", "=>", "string").GetAppellationName = function(appellationID, appArgs)
  local cfg
  if appellationID ~= 0 then
    cfg = TitleInterface.GetAppellationCfg(appellationID)
  end
  local appellation = textRes.Common[1]
  if cfg ~= nil then
    appellation = cfg.appellationName
    appellation = string.format(appellation, unpack(appArgs))
  end
  return appellation
end
def.static("number", "=>", "table").GetTitleCfg = function(titleID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TITLE_TITLE_CFG, titleID)
  if record == nil then
    print("** GetTitleCfg(", titleID, ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.picId = record:GetIntValue("picId")
  cfg.getMethod = record:GetStringValue("getMethod")
  cfg.titleOutTime = record:GetIntValue("titleOutTime")
  cfg.titleLimit = record:GetIntValue("titleLimit")
  cfg.titleName = record:GetStringValue("titleName")
  cfg.description = record:GetStringValue("description")
  return cfg
end
def.method("number")._AddOwnTitle = function(self, TitleID)
  table.insert(self._ownTitle, TitleID)
end
def.method("number")._AddOwnAppellation = function(self, AppellationID)
  table.insert(self._ownAppellation, AppellationID)
end
def.method("=>", "table").GetOwnTitles = function(self)
  return self._ownTitle
end
def.method("=>", "table").GetOwnAppellations = function(self)
  return self._ownAppellation
end
def.method("number")._SetActiveTitle = function(self, activeTitle)
  self._activeTitle = activeTitle
end
def.method("number")._SetActiveAppellation = function(self, activeAppellation)
  self._activeAppellation = activeAppellation
end
def.method("=>", "number").GetActiveTitle = function(self)
  return self._activeTitle
end
def.method("=>", "number").GetActiveAppellation = function(self)
  return self._activeAppellation
end
def.method("number")._SetPro2appellationId = function(self, pro2appellationId)
  self._pro2appellationId = pro2appellationId
end
def.method("=>", "number").GetActiveProperty = function(self)
  return self._pro2appellationId
end
def.method("number", "userdata").SetTimeOutValue = function(self, id, time)
  self._timeoutTable[id] = time
end
def.method("number", "table").SetAppellationArgs = function(self, id, args)
  if args == nil or #args == 0 then
    self._argsTable[id] = nil
    return
  end
  self._argsTable[id] = args
end
def.method("number", "=>", "table").GetAppellationArgs = function(self, id)
  return self._argsTable[id]
end
def.method("number", "number", "number", "=>", "string").GetPeriodTimeStr = function(self, id, OutTime, LimitID)
  if OutTime == 0 and LimitID == 0 then
    return textRes.Title[3]
  end
  local enddingTime = self._timeoutTable[id]
  if enddingTime ~= nil then
    local nowSec = GetServerTime()
    nowSec = nowSec * 1000
    local dTime = enddingTime:sub(nowSec)
    dTime = dTime:div(1000)
    dTime = dTime:ToNumber()
    if dTime >= 86400 then
      local days = dTime / 86400
      days = math.floor(days)
      local hours = math.floor((dTime - days * 86400) / 3600)
      return string.format(textRes.Title[41], days, hours)
    elseif dTime >= 3600 then
      local hours = dTime / 3600
      hours = math.floor(hours)
      local mins = dTime % 3600
      mins = mins / 60
      local secs = dTime % 60
      return string.format(textRes.Title[6], hours, mins, secs)
    elseif dTime >= 60 then
      local mins = dTime % 3600
      mins = mins / 60
      local secs = dTime % 60
      return string.format(textRes.Title[7], mins, secs)
    else
      local secs = dTime % 60
      return string.format(textRes.Title[8], secs)
    end
  end
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local tlcCfg = TimeCfgUtils.GetTimeLimitCommonCfg(OutTime)
  if tlcCfg ~= nil then
    return string.format(textRes.Title[2], tlcCfg.startYear, tlcCfg.startMonth, tlcCfg.startDay, tlcCfg.endYear, tlcCfg.endMonth, tlcCfg.endDay)
  end
  if LimitID > 0 then
    return string.format(textRes.Title[1], LimitID)
  end
  return textRes.Title[3]
end
def.static("=>", "number").GetAppellationIcon = function()
  return 219
end
def.static("=>", "number").GetTitleIcon = function()
  return 220
end
TitleInterface.Commit()
return TitleInterface
