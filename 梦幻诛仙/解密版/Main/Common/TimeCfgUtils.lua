local Lplus = require("Lplus")
local TimeCfgUtils = Lplus.Class("TimeCfgUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = TimeCfgUtils.define
local instance
def.static("=>", TimeCfgUtils).Instance = function()
  if instance == nil then
    instance = TimeCfgUtils()
    instance:Init()
  end
  return instance
end
def.static("number", "=>", "table").GetTimeLimitCommonCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_TIME_LIMIT_COMMON_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.endYear = record:GetIntValue("endYear")
  cfg.endMonth = record:GetIntValue("endMonth")
  cfg.endDay = record:GetIntValue("endDay")
  cfg.endHour = record:GetIntValue("endHour")
  cfg.endMinute = record:GetIntValue("endMinute")
  cfg.startYear = record:GetIntValue("startYear")
  cfg.startMonth = record:GetIntValue("startMonth")
  cfg.startDay = record:GetIntValue("startDay")
  cfg.startHour = record:GetIntValue("startHour")
  cfg.startMinute = record:GetIntValue("startMinute")
  return cfg
end
def.static("number", "=>", "table").GetTimeDurationCommonCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_TIME_DURATION_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.lastDay = record:GetIntValue("lastDay")
  cfg.lastHour = record:GetIntValue("lastHour")
  cfg.lastMinute = record:GetIntValue("lastMinute")
  local timeCommonCfgId = record:GetIntValue("timeCommonCfgId")
  cfg.timeCommonCfg = TimeCfgUtils.GetTimeCommonCfg(timeCommonCfgId)
  return cfg
end
def.static("number", "=>", "table").GetTimeCommonCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_TIME_CFG, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.activeHour = record:GetIntValue("activeHour")
  cfg.activeMinute = record:GetIntValue("activeMinute")
  cfg.activeWeekDay = record:GetIntValue("activeWeekDay")
  return cfg
end
def.static("number", "number", "number", "number", "number", "number", "=>", "number").GetTimeSec = function(year, month, day, hour, min, sec)
  return AbsoluteTimer.GetServerTimeByDate(year, month, day, hour, min, sec)
end
local prev_month = function(month)
  return month - 1 < 1 and 12 or month - 1
end
local get_year_month = function(year)
  if year % 4 == 0 then
    return {
      31,
      29,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    }
  else
    return {
      31,
      28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    }
  end
end
local function format_year_month_day(year, month, day)
  if month > 12 then
    return format_year_month_day(year + 1, month - 12, day)
  elseif month < 1 then
    return format_year_month_day(year - 1, month + 12, day)
  else
    local yearMonth = get_year_month(year)
    local dayCount = yearMonth[month]
    if day > dayCount then
      return format_year_month_day(year, month + 1, day - dayCount)
    elseif day < 1 then
      local prevDayCount = yearMonth[prev_month(month)]
      return format_year_month_day(year, month - 1, day + prevDayCount)
    else
      return year, month, day
    end
  end
end
def.static("number", "number", "number", "=>", "boolean").IsInTimePeriod = function(cfgId, curTime, judgeTime)
  local timeCfg = TimeCfgUtils.GetTimeDurationCommonCfg(cfgId)
  if timeCfg == nil or timeCfg.timeCommonCfg == nil then
    return false
  end
  local activeWeekDay = timeCfg.timeCommonCfg.activeWeekDay
  local activeHour = timeCfg.timeCommonCfg.activeHour
  local activeMinute = timeCfg.timeCommonCfg.activeMinute
  local durDay = timeCfg.lastDay
  local durHour = timeCfg.lastHour
  local durMinute = timeCfg.lastMinute
  local curDate = AbsoluteTimer.GetServerTimeTable(curTime)
  local wday = curDate.wday
  local diffDay = 0
  if activeWeekDay == 0 then
    diffDay = 0
  elseif activeWeekDay < wday then
    diffDay = wday - activeWeekDay
  elseif wday == activeWeekDay then
    if activeHour * 60 + activeMinute <= curDate.hour * 60 + curDate.min then
      diffDay = 0
    else
      diffDay = 7
    end
  else
    diffDay = wday - activeWeekDay + 7
  end
  local thisYear, thisMonth, thisDay = format_year_month_day(curDate.year, curDate.month, curDate.day - diffDay)
  local thisHour = activeHour
  local thisMinute = activeMinute
  local thisSecond = 0
  local startSecond = AbsoluteTimer.GetServerTimeByDate(thisYear, thisMonth, thisDay, thisHour, thisMinute, thisSecond)
  local durSecond = ((durDay * 24 + durHour) * 60 + durMinute) * 60
  return judgeTime > startSecond and judgeTime < startSecond + durSecond
end
def.static("number", "=>", "table").GetCommonTimePointCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TIME_POINT_CFG, cfgId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.year = record:GetIntValue("start_year")
  cfg.month = record:GetIntValue("start_month")
  cfg.day = record:GetIntValue("start_day")
  cfg.hour = record:GetIntValue("start_hour")
  cfg.min = record:GetIntValue("start_minute")
  cfg.sec = 0
  return cfg
end
TimeCfgUtils.Commit()
return TimeCfgUtils
