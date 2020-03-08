local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local NewServerAwardMgr = Lplus.Extend(AwardMgrBase, "NewServerAwardMgr")
local AchievementGoalInfo = require("netio.protocol.mzm.gsp.achievement.AchievementGoalInfo")
local AchievementData = require("Main.achievement.AchievementData")
local achievementData = AchievementData.Instance()
local def = NewServerAwardMgr.define
def.field("table").goalMap = nil
def.field("boolean").isInitGoalMap = false
local instance
def.static("=>", NewServerAwardMgr).Instance = function()
  if instance == nil then
    instance = NewServerAwardMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.isInitGoalMap = false
  self.goalMap = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, NewServerAwardMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, NewServerAwardMgr.OnAchievementGoalInfoChange)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, NewServerAwardMgr.OnGetScoreAwardChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, NewServerAwardMgr.OnFunctionOpenChange)
end
def.static("table", "table").OnNewDay = function(p1, p2)
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
    nodeId = NodeId.Carnival
  })
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
    nodeId = NodeId.Carnival
  })
end
def.static("table", "table").OnAchievementGoalInfoChange = function(p1, p2)
  if p1[1] == constant.CCarnivalConsts.carnivalActivityId then
    local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
      nodeId = NodeId.Carnival
    })
  end
end
def.static("table", "table").OnGetScoreAwardChange = function(p1, p2)
  if p1[1] == constant.CCarnivalConsts.carnivalActivityId then
    local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
      nodeId = NodeId.Carnival
    })
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CARNIVAL_ACTIVITY then
    local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
      nodeId = NodeId.Carnival
    })
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
      nodeId = NodeId.Carnival
    })
  end
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if self:isOpenNewServerActivity() then
    local tabId, index, isAward = self:getCanGetAwardTabId()
    local scoreAward = self:isOwnScoreAward()
    if isAward or scoreAward then
      return 1
    else
      return 0
    end
  end
  return 0
end
def.method().Reset = function(self)
  self.goalMap = {}
  self.isInitGoalMap = false
end
def.method().initGoalMap = function(self)
  local activityId = constant.CCarnivalConsts.carnivalActivityId
  local goalIdList = AchievementData.GetAchievementActivityCfg(activityId)
  for i, v in pairs(goalIdList.goalCfgIdList) do
    local goalCfg = AchievementData.GetAchievementGoalCfg(v)
    local id = goalCfg.tapId
    self.goalMap[id] = self.goalMap[id] or {}
    table.insert(self.goalMap[id], goalCfg)
  end
  self.isInitGoalMap = true
end
def.method("table").sortGoalList = function(self, goalList)
  local function comp(goal1, goal2)
    local goalInfo1 = self:getGoalInfoByGoalId(goal1.id)
    local goalInfo2 = self:getGoalInfoByGoalId(goal2.id)
    if goalInfo1.state == goalInfo2.state then
      if goalInfo2.isInit == goalInfo1.isInit then
        return goal1.rank < goal2.rank
      elseif goalInfo2.isInit then
        return true
      else
        return false
      end
    elseif goalInfo1.state == AchievementGoalInfo.ST_FINISHED then
      return true
    elseif goalInfo1.state == AchievementGoalInfo.ST_HAND_UP then
      return false
    elseif goalInfo1.state == AchievementGoalInfo.ST_ON_GOING then
      if goalInfo2.state == AchievementGoalInfo.ST_FINISHED then
        return false
      else
        return true
      end
    else
      return goal1.rank < goal2.rank
    end
  end
  table.sort(goalList, comp)
end
def.method("number", "=>", "table").getGoalListByTabId = function(self, tabId)
  local goalList = self.goalMap[tabId]
  if goalList then
    return goalList
  end
  self:initGoalMap()
  return self.goalMap[tabId]
end
def.method("=>", "number", "number", "boolean").getCanGetAwardTabId = function(self)
  if not self.isInitGoalMap then
    self:initGoalMap()
  end
  local openNum = self:getCreateRoleDayNum()
  for id, goalCfgs in pairs(self.goalMap) do
    if id <= openNum then
      for i, v in ipairs(goalCfgs) do
        local curGoalInfo = self:getGoalInfoByGoalId(v.id)
        if curGoalInfo.state == AchievementGoalInfo.ST_FINISHED then
          return id, i, true
        end
      end
    end
  end
  return 1, 1, false
end
def.method("=>", "number").getCanSelectedTabId = function(self)
  if not self.isInitGoalMap then
    self:initGoalMap()
  end
  local openNum = self:getCreateRoleDayNum()
  for id, goalCfgs in pairs(self.goalMap) do
    if id <= openNum then
      for i, v in ipairs(goalCfgs) do
        local curGoalInfo = self:getGoalInfoByGoalId(v.id)
        if curGoalInfo.state ~= AchievementGoalInfo.ST_HAND_UP then
          return id
        end
      end
    end
  end
  return 1
end
def.method("number", "=>", "boolean").isHaveAwardByTabId = function(self, tabId)
  local openNum = self:getCreateRoleDayNum()
  if tabId > openNum then
    return false
  end
  if not self.isInitGoalMap then
    self:initGoalMap()
  end
  for i, v in ipairs(self.goalMap[tabId]) do
    local curGoalInfo = self:getGoalInfoByGoalId(v.id)
    if curGoalInfo.state == AchievementGoalInfo.ST_FINISHED then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").isOwnScoreAward = function(self)
  local activityScoreCfg = AchievementData.GetAchievementScoreActivityCfg(constant.CCarnivalConsts.carnivalActivityId)
  local curScore = self:getCurScore()
  for i, v in ipairs(activityScoreCfg.scoreCfgIdList) do
    local scoreAwardCfg = AchievementData.GetAchievementScoreCfg(v)
    local score = scoreAwardCfg.score
    local isGet = self:isGetScoreAward(scoreAwardCfg.scoreIndexId)
    if not isGet and curScore >= score then
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean").isGetScoreAward = function(self, score)
  local getAwardInfo = achievementData:getScoreAwardInfo(constant.CCarnivalConsts.carnivalActivityId)
  if getAwardInfo and getAwardInfo[score] then
    return true
  end
  return false
end
def.method("=>", "number").getCurScore = function(self)
  return achievementData:getAchievementScore(constant.CCarnivalConsts.carnivalActivityId)
end
def.method("=>", "table").getGoalInfos = function(self)
  return achievementData:getAchievementGoalInfos(constant.CCarnivalConsts.carnivalActivityId)
end
def.method("number", "=>", "table").getGoalInfoByGoalId = function(self, goalId)
  local GoalInfos = self:getGoalInfos()
  if GoalInfos and GoalInfos[goalId] then
    return GoalInfos[goalId]
  else
    return {
      state = 1,
      parameters = {
        0,
        0,
        0,
        0,
        0,
        0
      },
      isInit = true
    }
  end
end
def.method("=>", "number").getLeftTime = function()
  local heroProp = _G.GetHeroProp()
  if heroProp then
    local createTime = heroProp.createTime:ToNumber()
    local leftTime = createTime + constant.CCarnivalConsts.lastTime * 3600 * 24 - GetServerTime()
    return leftTime
  end
  return 0
end
def.method("=>", "string").getLeftTimeStr = function(self)
  local leftTime = self:getLeftTime()
  local day = 0
  local hour = 0
  local min = 0
  if leftTime > 0 then
    day = math.floor(leftTime / 86400)
    hour = math.floor((leftTime - day * 3600 * 24) / 3600)
    min = math.floor((leftTime - day * 3600 * 24 - hour * 3600) / 60)
  end
  if day == 0 and hour == 0 and min == 0 then
    return textRes.activity[380]
  end
  return string.format(textRes.activity[374], day, hour, min)
end
def.method("=>", "number").getServerOpenDayNum = function(self)
  return require("Main.Server.ServerModule").Instance():GetServerOpenDays()
end
def.method("=>", "boolean").isOpenNewServerActivity = function(self)
  if GameUtil.IsEvaluation() then
    return false
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isServerOpen = feature:CheckFeatureOpen(Feature.TYPE_CARNIVAL_ACTIVITY)
  if isServerOpen then
    local leftTime = self:getLeftTime()
    if leftTime > 0 then
      return true
    end
  end
  return false
end
def.method("=>", "number").getCreateRoleDayNum = function(self)
  local heroProp = _G.GetHeroProp()
  local createTime = heroProp.createTime:ToNumber()
  if createTime == 0 then
    return 0
  end
  local createHour = os.date("%H", createTime)
  local createMin = os.date("%M", createTime)
  local createSec = os.date("%S", createTime)
  warn("-------createTime:", createHour, createTime)
  local zeroTime = createTime - createHour * 3600 - createMin * 60 - createSec
  local durationTime = GetServerTime() - zeroTime
  local durationDay = math.ceil(durationTime / 86400)
  return durationDay
end
return NewServerAwardMgr.Commit()
