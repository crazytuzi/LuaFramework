local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RecallFriendInfo = require("Main.Recall.data.RecallFriendInfo")
local RecallUtils = require("Main.Recall.RecallUtils")
local AfkFriendInfo = Lplus.Extend(RecallFriendInfo, "AfkFriendInfo")
local def = AfkFriendInfo.define
def.field("number").afkPeriodStartTime = 0
def.field("number").afkPeriodRecalledCount = 0
def.field("number").lastHeroRecallTime = 0
def.final("table", "=>", AfkFriendInfo).New = function(friendInfo)
  local afkFriendInfo = AfkFriendInfo()
  afkFriendInfo.userInfo = friendInfo.user_info
  afkFriendInfo.roleInfo = friendInfo.role_info
  afkFriendInfo.afkPeriodStartTime = friendInfo.start_time
  afkFriendInfo.afkPeriodRecalledCount = friendInfo.be_recall_num
  afkFriendInfo.lastHeroRecallTime = friendInfo.invite_time
  return afkFriendInfo
end
def.override().Release = function(self)
  base:Release()
end
def.method("number").OnHeroRecallSuccess = function(self, time)
  self.lastHeroRecallTime = time
  self:CheckAfkPeriodOver()
  self.afkPeriodRecalledCount = self.afkPeriodRecalledCount + 1
end
def.method("=>", "boolean").CheckAfkPeriodOver = function(self)
  local result = false
  if self:IsCurAFKPeriodOver() then
    local afkPeriod = RecallUtils.GetConst("PERIOD_TIME")
    self.afkPeriodStartTime = self.afkPeriodStartTime + afkPeriod * 86400
    self.afkPeriodRecalledCount = 0
    result = true
  end
  return result
end
def.method("=>", "number").GetHeroLastRecallTime = function(self)
  return self.lastHeroRecallTime
end
def.method("=>", "boolean").CanBeRecalled = function(self)
  local result = false
  if self:IsHeroRecallPeriodOver() and (self:IsCurAFKPeriodOver() or not self:ReachAFKPeriodMaxRecallCount()) then
    result = true
  end
  return result
end
def.method("=>", "boolean").IsHeroRecallPeriodOver = function(self)
  local recallPeriod = RecallUtils.GetConst("RECALL_PERIOD_TIME")
  local lastRecallPastDay = RecallUtils.GetPastDayBy24(self.lastHeroRecallTime)
  return recallPeriod <= lastRecallPastDay
end
def.method("=>", "boolean").IsCurAFKPeriodOver = function(self)
  local periodPastDay = RecallUtils.GetPastDayBy24(self.afkPeriodStartTime)
  return periodPastDay > RecallUtils.GetConst("PERIOD_TIME")
end
def.method("=>", "boolean").ReachAFKPeriodMaxRecallCount = function(self)
  return self.afkPeriodRecalledCount >= RecallUtils.GetConst("ONE_PERIOD_BE_RECALL_TIMES")
end
return AfkFriendInfo.Commit()
