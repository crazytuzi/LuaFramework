local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local AuctionUtils = Lplus.Class("AuctionUtils")
local def = AuctionUtils.define
def.static("number", "=>", "boolean").IsActivityOpen = function(activityId)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if nil == activityCfg then
    warn("[ERROR][AuctionUtils:IsActivityOpen] activityCfg nil for id:", activityId)
    return false
  end
  if ActivityInterface.Instance():IsCustomCloseActivity(activityId) then
    return false
  end
  local isForceOpen = ActivityInterface.Instance():isForceOpenActivity(activityId)
  if isForceOpen then
    return true
  end
  local isForcePause = ActivityInterface.Instance():isActivityPause(activityId)
  if isForcePause then
    return false
  end
  local isForceClose = ActivityInterface.Instance():isForceCloseActivity(activityId)
  if isForceClose then
    return false
  end
  if activityCfg.activityType == ActivityType.Daily then
    return true
  end
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  local curTime = GetServerTime()
  if openTime > 0 and openTime > curTime or closeTime > 0 and closeTime <= curTime then
    return false
  end
  return true
end
def.static("number", "=>", "number").GetActivityPeroidIdx = function(activityId)
  if activityId > 0 then
    local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
    if openTime > 0 and openTime > curTime or closeTime > 0 and closeTime <= curTime then
      return 0
    end
    if activeTimeList then
      local curTime = GetServerTime()
      for i, v in ipairs(activeTimeList) do
        if curTime >= v.beginTime and curTime < v.resetTime and openTime <= v.beginTime then
          return i
        end
      end
    end
  end
  return 0
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
def.static("table", "=>", "number", "number").GetDurationStartEndTime = function(durationCfg)
  if durationCfg then
    local activeWeekDay = durationCfg.timeCommonCfg.activeWeekDay
    local activeHour = durationCfg.timeCommonCfg.activeHour
    local activeMinute = durationCfg.timeCommonCfg.activeMinute
    local durDay = durationCfg.lastDay
    local durHour = durationCfg.lastHour
    local durMinute = durationCfg.lastMinute
    local curDate = AbsoluteTimer.GetServerTimeTable(_G.GetServerTime())
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
    return startSecond, startSecond + durSecond
  else
    return 0, 0
  end
end
def.static("table", "=>", "string").GetDurationStartTimeText = function(durationCfg)
  local timeText = ""
  if durationCfg then
    local activeHour = durationCfg.timeCommonCfg.activeHour
    local activeMinute = durationCfg.timeCommonCfg.activeMinute
    timeText = string.format(textRes.Auction.AUCTION_ROUND_INTERVAL, activeHour, activeMinute)
  end
  return timeText
end
def.static("table", "=>", "string").GetDurationTimeText = function(durationCfg)
  local timeText = ""
  if durationCfg then
    local activeWeekDay = durationCfg.timeCommonCfg.activeWeekDay
    local activeHour = durationCfg.timeCommonCfg.activeHour
    local activeMinute = durationCfg.timeCommonCfg.activeMinute
    local durDay = durationCfg.lastDay
    local durHour = durationCfg.lastHour
    local durMinute = durationCfg.lastMinute
    local endHour = activeHour + durHour
    local endMinute = activeMinute + durMinute
    while endMinute >= 60 do
      endHour = endHour + 1
      endMinute = endMinute - 60
    end
    timeText = string.format(textRes.Auction.AUCTION_ROUND_INTERVAL, activeHour, activeMinute, endHour, endMinute)
  end
  return timeText
end
def.static("number", "=>", "string").GetCountdownText = function(countdown)
  local hour = 0
  local min = 0
  local sec = 0
  if countdown > 0 then
    hour = math.floor(countdown / 3600)
    min = math.floor((countdown - 3600 * hour) / 60)
    sec = countdown % 60
  end
  local result = string.format(textRes.Auction.AUCTION_ITEM_COUNTDOWN, hour, min, sec)
  return result
end
AuctionUtils.Commit()
return AuctionUtils
