local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OpenTimeHelper = Lplus.Class(MODULE_NAME)
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = OpenTimeHelper.define
local OPEN_POSTPONE_SECONDS = 7200
local CLOSE_AHEAD_SECONDS = 7200
local instance
def.static("=>", OpenTimeHelper).Instance = function()
  if instance == nil then
    instance = OpenTimeHelper()
    instance:Init()
  end
  return instance
end
def.field("table").m_resetDateTime = nil
def.field("number").m_activityId = 0
def.field("number").m_durationSeconds = 0
def.method().Init = function(self)
  self.m_activityId = GangDungeonUtils.GetConstant("ACTIVITY_ID")
  local activityCfg = ActivityInterface.GetActivityCfgById(self.m_activityId)
  local timeCfg = activityCfg.activityTimeCfgs[1]
  self.m_durationSeconds = timeCfg.lastDay * 24 * 3600 + timeCfg.lastHour * 3600 + timeCfg.lastMinute * 60
  self.m_resetDateTime = {}
  self.m_resetDateTime.wday = timeCfg.timeCommonCfg.activeWeekDay
  self.m_resetDateTime.hour = timeCfg.timeCommonCfg.activeHour
  self.m_resetDateTime.min = timeCfg.timeCommonCfg.activeMinute
  self.m_resetDateTime.sec = 0
  CLOSE_AHEAD_SECONDS = GangDungeonUtils.GetConstant("ForbidActivateBeforeEndMinutes") * 60
end
def.method("=>", "table").GetResetDateTime = function(self)
  return self.m_resetDateTime
end
def.method("=>", "number").GetDurationSeconds = function(self)
  return self.m_durationSeconds
end
def.method("table", "=>", "number").CalcRecentlyOpenTimestampFromNow = function(self, openTime)
  local resetTime = self:GetResetDateTime()
  local resetWDay = resetTime.wday
  local curTime = _G.GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local paddingWeek = 0
  if resetWDay <= t.wday and resetWDay > openTime.wday then
    paddingWeek = _G.DAYS_OF_WEEK
  elseif resetWDay > t.wday and resetWDay <= openTime.wday then
    paddingWeek = -_G.DAYS_OF_WEEK
  end
  local diff_s = (openTime.wday - t.wday + paddingWeek) * 24 * 3600 + (openTime.hour - t.hour) * 3600 + (openTime.min - t.min) * 60 + (openTime.sec - t.sec)
  local openTimestamp = curTime + diff_s
  return openTimestamp
end
def.method("table", "=>", "boolean", "string").IsSatisfyEarliestLimit = function(self, openTime)
  local openTimestamp = self:CalcRecentlyOpenTimestampFromNow(openTime)
  local curTime = _G.GetServerTime()
  if openTimestamp < curTime + OPEN_POSTPONE_SECONDS then
    local t = _G.Seconds2HMSTime(OPEN_POSTPONE_SECONDS)
    local msg = textRes.GangDungeon[19]:format(t.h)
    return false, msg
  end
  return true, "success"
end
def.method("table", "=>", "boolean").CheckEarliestTimeLimit = function(self, openTime)
  local ret, msg = self:IsSatisfyEarliestLimit(openTime)
  if ret == false then
    Toast(msg)
  end
  return ret
end
def.method("table", "=>", "boolean", "string").IsSatisfyLatestLimit = function(self, openTime)
  local openTimestamp = self:CalcRecentlyOpenTimestampFromNow(openTime)
  local resetTime = self:GetResetDateTime()
  local startTimestamp = self:CalcRecentlyOpenTimestampFromNow(resetTime)
  local endTimestamp = startTimestamp + self:GetDurationSeconds()
  local aheadCloseTimestamp = endTimestamp - CLOSE_AHEAD_SECONDS
  if openTimestamp > aheadCloseTimestamp then
    local t = AbsoluteTimer.GetServerTimeTable(aheadCloseTimestamp)
    local msg = textRes.GangDungeon[6]:format(t.hour, t.min)
    return false, msg
  end
  return true, "success"
end
def.method("table", "=>", "boolean").CheckLatestTimeLimit = function(self, openTime)
  local ret, msg = self:IsSatisfyLatestLimit(openTime)
  if ret == false then
    Toast(msg)
  end
  return ret
end
return OpenTimeHelper.Commit()
