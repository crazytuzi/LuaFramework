local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SetOpenTimePanel = Lplus.Class(MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CommonSetTimeDlg = require("GUI.CommonSetTimeDlg")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangDungeonModule = require("Main.GangDungeon.GangDungeonModule")
local OpenTimeHelper = require("Main.GangDungeon.OpenTimeHelper")
local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
local def = SetOpenTimePanel.define
local MINUTE_PRECISION = 30
local LAST_DAY_AHEAD_END_SECONDS = 7200
local OptionType = {
  DayOfWeek = 1,
  Hour = 2,
  Minute = 3
}
def.field("table").m_dlg = nil
local instance
def.static("=>", SetOpenTimePanel).Instance = function()
  if instance == nil then
    instance = SetOpenTimePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  MINUTE_PRECISION = math.abs(GangDungeonUtils.GetConstant("ActivateValidMinute1") - GangDungeonUtils.GetConstant("ActivateValidMinute2"))
end
def.method().ShowPanel = function(self)
  if self.m_dlg then
    self.m_dlg:DestroyPanel()
  end
  local allOptions = {}
  allOptions[OptionType.DayOfWeek] = self:GetWeekOptions()
  allOptions[OptionType.Hour] = self:GetHourOptions()
  allOptions[OptionType.Minute] = self:GetMinuteOptions()
  local lastOptions = self:GetLastOptions()
  self.m_dlg = CommonSetTimeDlg.ShowDlgWithCancel(textRes.GangDungeon[5], allOptions, lastOptions, SetOpenTimePanel.OnConfirm, nil)
  if GangDungeonModule.Instance():HasSetOpenTime() then
    local leftChangeTimes = GangDungeonModule.Instance():GetOpenTimeLeftChangeTimes()
    local tips = textRes.GangDungeon[39]:format(leftChangeTimes)
    self.m_dlg:SetTips(tips)
  end
end
def.static("table", "table", "table", "number", "=>", "boolean").OnConfirm = function(dlg, allOptions, selOptions, state)
  local leftChangeTimes = GangDungeonModule.Instance():GetOpenTimeLeftChangeTimes()
  if leftChangeTimes <= 0 then
    Toast(textRes.GangDungeon[10])
    return true
  end
  local weekIndex = selOptions[OptionType.DayOfWeek]
  local hourIndex = selOptions[OptionType.Hour]
  local minuteIndex = selOptions[OptionType.Minute]
  local wday = allOptions[OptionType.DayOfWeek][weekIndex].value
  local hourSinceWDay = allOptions[OptionType.Hour][hourIndex].value
  local minuteSinceWDay = allOptions[OptionType.Minute][minuteIndex].value
  local secondsSinceWDay = hourSinceWDay * 3600 + minuteSinceWDay * 60
  local dateTime = {
    wday = wday,
    hour = hourSinceWDay,
    min = minuteSinceWDay,
    sec = 0
  }
  if OpenTimeHelper.Instance():CheckLatestTimeLimit(dateTime) == false then
    return false
  end
  if OpenTimeHelper.Instance():CheckEarliestTimeLimit(dateTime) == false then
    return false
  end
  local content
  if state == 0 then
    local wdayName = allOptions[OptionType.DayOfWeek][weekIndex].name
    local dateText = textRes.GangDungeon[8]:format(wdayName, hourSinceWDay, minuteSinceWDay)
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local activityId = GangDungeonModule.Instance():GetActivityId()
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    local activityName = activityCfg and activityCfg.activityName or "$activity_name"
    content = textRes.GangDungeon[7]:format(activityName, dateText)
  else
    content = textRes.GangDungeon[9]:format(leftChangeTimes)
  end
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], content, function(s)
    if s == 1 then
      dlg:DestroyPanel()
      GangDungeonModule.Instance():SetOpenDateTime(dateTime)
    end
  end, nil)
  return false
end
def.static("table", "=>", "boolean").OnCancel = function(dlg)
  local leftResetTimes = GangDungeonModule.Instance():GetOpenTimeLeftResetTimes()
  if leftResetTimes <= 0 then
    Toast(textRes.GangDungeon[12])
    return false
  end
  local content = textRes.GangDungeon[11]:format(leftResetTimes)
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], content, function(s)
    if s == 1 then
      GangDungeonModule.Instance():ResetOpenDateTime()
      dlg:ResetOptions()
    end
  end, nil)
  return true
end
def.method("=>", "table").GetWeekOptions = function(self)
  local SUNDAY = 1
  local MONDAY = 2
  local SATURDAY = 7
  local weekdays = {}
  for i = MONDAY, SATURDAY do
    table.insert(weekdays, i)
  end
  table.insert(weekdays, SUNDAY)
  local options = {}
  for i, wday in ipairs(weekdays) do
    local option = {
      name = textRes.activity[wday],
      value = wday
    }
    table.insert(options, option)
  end
  return options
end
def.method("=>", "table").GetHourOptions = function(self)
  local startHour = GangDungeonUtils.GetConstant("ActivateValidHourMin")
  local endHour = GangDungeonUtils.GetConstant("ActivateValidHourMax")
  local options = {}
  for i = startHour, endHour do
    local option = {
      name = string.format(textRes.GangDungeon[2], i),
      value = i
    }
    table.insert(options, option)
  end
  return options
end
def.method("=>", "table").GetMinuteOptions = function(self)
  local options = {}
  for i = 0, 60 - MINUTE_PRECISION, MINUTE_PRECISION do
    local option = {
      name = string.format(textRes.GangDungeon[3], i),
      value = i
    }
    table.insert(options, option)
  end
  return options
end
def.method("number", "=>", "dynamic").FindWeekIndex = function(self, value)
  local options = self:GetWeekOptions()
  for i, v in ipairs(options) do
    if v.value == value then
      return i
    end
  end
  return nil
end
def.method("number", "=>", "dynamic").FindHourIndex = function(self, value)
  local options = self:GetHourOptions()
  for i, v in ipairs(options) do
    if v.value == value then
      return i
    end
  end
  return nil
end
def.method("number", "=>", "dynamic").FindMinuteIndex = function(self, value)
  local options = self:GetMinuteOptions()
  for i, v in ipairs(options) do
    if v.value == value then
      return i
    end
  end
  return nil
end
def.method("=>", "table").GetLastOptions = function(self)
  local openTime = GangDungeonModule.Instance():GetOpenDateTime()
  if openTime == nil then
    return self:GetDefaultOptions()
  end
  local options = {}
  options[OptionType.DayOfWeek] = self:FindWeekIndex(openTime.wday)
  options[OptionType.Hour] = self:FindHourIndex(openTime.hour)
  options[OptionType.Minute] = self:FindMinuteIndex(openTime.min)
  return options
end
def.method("=>", "table").GetDefaultOptions = function(self)
  local options = {}
  options[OptionType.DayOfWeek] = self:FindWeekIndex(GangDungeonUtils.GetConstant("DefaultActivateDate"))
  options[OptionType.Hour] = self:FindHourIndex(GangDungeonUtils.GetConstant("DefaultActivateHour"))
  options[OptionType.Minute] = self:FindMinuteIndex(GangDungeonUtils.GetConstant("DefaultActivateMinute"))
  return options
end
return SetOpenTimePanel.Commit()
