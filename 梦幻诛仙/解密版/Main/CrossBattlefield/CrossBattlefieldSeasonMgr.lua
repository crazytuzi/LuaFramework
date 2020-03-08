local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CrossBattlefieldSeasonMgr = Lplus.Class(MODULE_NAME)
local CrossBattlefieldUtils = require("Main.CrossBattlefield.CrossBattlefieldUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = CrossBattlefieldSeasonMgr.define
def.field("number").m_season = 0
def.field("number").m_starNum = 0
def.field("number").m_winPoint = 0
def.field("number").m_curStarGetTime = 0
def.field("number").m_winningStreak = 0
def.field("number").m_weekPoint = 0
def.field("number").m_week_update_time = 0
local instance
def.static("=>", CrossBattlefieldSeasonMgr).Instance = function()
  if instance == nil then
    instance = CrossBattlefieldSeasonMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().Reset = function(self)
  self.m_season = 0
  self.m_starNum = 0
  self.m_winPoint = 0
  self.m_curStarGetTime = 0
  self.m_winningStreak = 0
  self.m_weekPoint = 0
end
def.method().AutoSetSeason = function(self)
  local curSeasonInfo = CrossBattlefieldUtils.GetRecentlySeasonInfo()
  self.m_season = curSeasonInfo and curSeasonInfo.season or 0
end
def.method("=>", "number").GetSeason = function(self)
  return self.m_season
end
def.method("=>", "number").GetStarNum = function(self)
  return self.m_starNum
end
def.method("=>", "number").GetWinPoint = function(self)
  return self.m_winPoint
end
def.method("=>", "number").GetCurStarGetTime = function(self)
  return self.m_curStarGetTime
end
def.method("=>", "number").GetWinningStreak = function(self)
  return self.m_winningStreak
end
def.method("=>", "number").GetWeekPoint = function(self)
  local curTime = GetServerTime()
  if curTime < self.m_week_update_time then
    return self.m_weekPoint
  elseif curTime - self.m_week_update_time >= 604800 then
    self.m_weekPoint = 0
    return self.m_weekPoint
  else
    local lastUpdateWeek = AbsoluteTimer.GetServerTimeTable(self.m_week_update_time)
    local curWeek = AbsoluteTimer.GetServerTimeTable(curTime)
    local lastWeekDay = 0 < lastUpdateWeek.wday - 1 and lastUpdateWeek.wday - 1 or 7
    local curWeekDay = 0 < curWeek.wday - 1 and curWeek.wday - 1 or 7
    if lastWeekDay <= curWeekDay then
      return self.m_weekPoint
    else
      self.m_weekPoint = 0
      return self.m_weekPoint
    end
  end
end
def.method("number").SetWinningStreak = function(self, value)
  self.m_winningStreak = value
end
def.method("number").SetCurStarGetTime = function(self, value)
  self.m_curStarGetTime = value
end
def.method("number").SetWinPoint = function(self, value)
  self.m_winPoint = value
end
def.method("number").SetStarNum = function(self, value)
  self.m_starNum = value
end
def.method("number").SetSeason = function(self, value)
  self.m_season = value
end
def.method("number", "number").SetWeekPoint = function(self, value, time)
  self.m_weekPoint = value
  self.m_week_update_time = time
end
return CrossBattlefieldSeasonMgr.Commit()
