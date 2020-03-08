local MODULE_NAME = (...)
local Lplus = require("Lplus")
local LoginAlertMgr = Lplus.Class(MODULE_NAME)
local AccumulativeLoginMgr = require("Main.Award.mgr.AccumulativeLoginMgr")
local EnterWorldAlertMgr = require("Main.Common.EnterWorldAlertMgr")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = LoginAlertMgr.define
def.field("number").loginDays = 0
local instance
def.static("=>", LoginAlertMgr).Instance = function()
  if instance == nil then
    instance = LoginAlertMgr()
  end
  return instance
end
def.method().Init = function(self)
  EnterWorldAlertMgr.Instance():RegisterEx(EnterWorldAlertMgr.CustomOrder.LoginAwardAlert, LoginAlertMgr.OnEnterWorldAlert, self, {reconnectAlert = true})
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_LOGIN_DAYS, LoginAlertMgr.OnUpdateLoginDays)
end
def.method("=>", "table").GetTodayContent = function(self)
  local loginDay = self.loginDays
  local weekDay = tonumber(os.date("%w", GetServerTime()))
  local showInfo = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LOGIN_ALERT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  if weekDay == 0 then
    weekDay = 7
  end
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local serverLevel = serverLevelData.level
  DynamicDataTable.FastGetRecordBegin(entries)
  local isNewRole = false
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local sort = entry:GetIntValue("sort")
    local iconId = entry:GetIntValue("iconId")
    local ornamentId = entry:GetIntValue("ornamentId")
    local alertType = entry:GetIntValue("alertType")
    local typeValue = entry:GetIntValue("typeValue")
    local content = entry:GetStringValue("content")
    local classId = entry:GetIntValue("classId")
    if alertType == 1 and typeValue == loginDay or alertType == 2 and typeValue == weekDay then
      if classId == 1 or classId == 2 or classId == 3 then
        isNewRole = true
      end
      table.insert(showInfo, {
        sort = sort,
        iconId = iconId,
        ornamentId = ornamentId,
        content = content or ""
      })
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if serverLevel > 90 and not isNewRole then
    return {}
  end
  table.sort(showInfo, function(a, b)
    return a.sort < b.sort
  end)
  return showInfo
end
def.method().ShowLoginAlert = function(self)
  if not textRes.LoginAlert.Open then
    EnterWorldAlertMgr.Instance():Next()
    return
  end
  if self:HasTodayShow() then
    EnterWorldAlertMgr.Instance():Next()
    return
  end
  local content = self:GetTodayContent()
  if content and #content > 0 then
    require("Main.Award.ui.LoginAlertPanel").Instance():ShowPanel(content)
  else
    EnterWorldAlertMgr.Instance():Next()
  end
end
def.method().OnEnterWorldAlert = function(self)
  self:ShowLoginAlert()
end
def.method("=>", "number").GetDateKey = function(self)
  local serverTime = _G.GetServerTime()
  local key = tonumber(os.date("%Y%m%d", serverTime))
  return key
end
local keyPrefix = "LoginAlertDate_"
def.method("=>", "string").GetStorageKey = function(self, dateKey)
  local dateKey = self:GetDateKey()
  return keyPrefix .. tostring(dateKey)
end
def.method("=>", "boolean").HasTodayShow = function(self)
  local storageKey = self:GetStorageKey()
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    return true
  end
  return false
end
def.method().MarkTodayAsShowed = function(self)
  local storageKey = self:GetStorageKey()
  LuaPlayerPrefs.SetRoleString(storageKey, "1")
end
def.static("table", "table").OnUpdateLoginDays = function(params, context)
  instance.loginDays = params[1]
  if gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld then
    instance:ShowLoginAlert()
  end
end
return LoginAlertMgr.Commit()
