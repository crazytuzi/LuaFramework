local Lplus = require("Lplus")
local GangCrossUtility = Lplus.Class("GangCrossUtility")
local ServerListMgr = require("Main.Login.ServerListMgr")
local def = GangCrossUtility.define
local instance
def.static("=>", GangCrossUtility).Instance = function()
  if nil == instance then
    instance = GangCrossUtility()
  end
  return instance
end
def.method("=>", "number").getActivityWeekBeginTime = function(self)
  local activityId = constant.GangCrossConsts.Activityid
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg then
    local timeCfg = activityCfg.activityTimeCfgs[1]
    local activeWeekDay = timeCfg.timeCommonCfg.activeWeekDay
    local activeHour = timeCfg.timeCommonCfg.activeHour
    local activeMinute = timeCfg.timeCommonCfg.activeMinute
    local curTime = GetServerTime()
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
    local nowYear = curTimeTable.year
    local nowMonth = curTimeTable.month
    local nowDay = curTimeTable.day
    local nowDayWeek = curTimeTable.wday
    local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
    local weekDiffDay = activeWeekDay - nowDayWeek
    local beginTime = TimeCfgUtils.GetTimeSec(nowYear, nowMonth, nowDay, activeHour, activeMinute, 0) + weekDiffDay * 86400
    if nowDayWeek == 1 then
      beginTime = beginTime - 604800
    end
    return beginTime
  end
  return 0
end
def.method("number", "=>", "string").getTimeString = function(self, secTime)
  local day = 0
  local hour = 0
  local min = 0
  local sec = 0
  if secTime > 0 then
    day = math.modf(secTime / 86400)
    if day > 0 then
      secTime = secTime - day * 86400
    end
    hour = math.modf(secTime / 3600)
    if hour > 0 then
      secTime = secTime - hour * 3600
    end
    min = math.modf(secTime / 60)
    if min > 0 then
      secTime = secTime - min * 60
    end
    sec = secTime
  end
  local timeStr = string.format(textRes.GangCross[18], day, hour, min, sec)
  return timeStr
end
def.method("userdata", "=>", "number").GetSvrIdForGangId = function(self, gangId)
  if not gangId then
    return 0
  end
  local step = 4096
  local severIndex = gangId % step
  return severIndex:ToNumber()
end
def.method("userdata", "=>", "string").GetSvrNameForGangId = function(self, gangId)
  if not gangId then
    return "???"
  end
  local zoneid = self:GetSvrIdForGangId(gangId)
  local serverCfg = ServerListMgr.Instance():GetServerCfg(zoneid)
  return serverCfg and serverCfg.name or "???"
end
return GangCrossUtility.Commit()
