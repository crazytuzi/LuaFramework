local Lplus = require("Lplus")
local DoudouGiftMgr = Lplus.Class("DoudouGiftMgr")
local def = DoudouGiftMgr.define
local instance
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AchievementGoalInfo = require("netio.protocol.mzm.gsp.achievement.AchievementGoalInfo")
local AchievementData = require("Main.achievement.AchievementData")
local achievementData = AchievementData.Instance()
local Cls = DoudouGiftMgr
local const = constant.DouDouSongLiConsts
def.field("table").goalMap = nil
def.field("boolean").isInitGoalMap = false
def.static("=>", DoudouGiftMgr).Instance = function()
  if instance == nil then
    instance = DoudouGiftMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, Cls.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, Cls.OnCrossDay)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, Cls.OnAchievementGoaInfoChagnge)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, Cls.OnAchievementScoreInfoChagnge)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, Cls.OnHeroLvUp)
end
def.method("=>", "table").GetGoalList = function(self)
  if not instance.isInitGoalMap then
    self:initGoalMap()
  end
  return self.goalMap[2]
end
def.method("table").SortGoldList = function(self, list)
  local function comp(goal1, goal2)
    local goalInfo1 = self:GetGoalInfoByGoalId(goal1.id)
    local goalInfo2 = self:GetGoalInfoByGoalId(goal2.id)
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
  table.sort(list, comp)
end
def.method("number", "=>", "table").GetGoalInfoByGoalId = function(self, goalId)
  local GoalInfos = Cls.GetGoalInfos()
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
def.method("=>", "number").GetCurScore = function(self)
  return achievementData:getAchievementScore(const.activityId)
end
def.method("number", "=>", "boolean").IsGetScoreAward = function(self, score)
  local getAwardInfo = achievementData:getScoreAwardInfo(const.activityId)
  if getAwardInfo and getAwardInfo[score] then
    return true
  end
  return false
end
def.method("=>", "boolean").isOwnScoreAward = function(self)
  local activityScoreCfg = AchievementData.GetAchievementScoreActivityCfg(const.activityId)
  local curScore = self:GetCurScore()
  for i, v in ipairs(activityScoreCfg.scoreCfgIdList) do
    local scoreAwardCfg = AchievementData.GetAchievementScoreCfg(v)
    local score = scoreAwardCfg.score
    local isGet = self:IsGetScoreAward(scoreAwardCfg.scoreIndexId)
    if not isGet and curScore >= score then
      return true
    end
  end
  return false
end
def.method("=>", "number", "number", "boolean").getCanGetAwardTabId = function(self)
  if not self.isInitGoalMap then
    self:initGoalMap()
  end
  for id, goalCfgs in pairs(self.goalMap) do
    for i, v in ipairs(goalCfgs) do
      local curGoalInfo = self:GetGoalInfoByGoalId(v.id)
      if curGoalInfo.state == AchievementGoalInfo.ST_FINISHED then
        return id, i, true
      end
    end
  end
  return 1, 1, false
end
def.method().initGoalMap = function(self)
  local activityId = const.activityId
  local goalIdList = AchievementData.GetAchievementActivityCfg(activityId)
  self.goalMap = {}
  for i, v in pairs(goalIdList.goalCfgIdList) do
    local goalCfg = AchievementData.GetAchievementGoalCfg(v)
    local id = goalCfg.tapId
    self.goalMap[id] = self.goalMap[id] or {}
    table.insert(self.goalMap[id], goalCfg)
  end
  self.isInitGoalMap = true
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
  local zeroTime = createTime - createHour * 3600 - createMin * 60 - createSec
  local durationTime = GetServerTime() - zeroTime
  local durationDay = math.ceil(durationTime / 86400)
  return durationDay
end
def.static("=>", "table").GetGoalInfos = function()
  local list = achievementData:getAchievementGoalInfos(const.activityId)
  return list
end
def.method("=>", "number").getLeftTime = function()
  local startSrvTime = require("Main.Server.ServerModule").Instance():GetOpenServerStartDayTime()
  local leftTime = const.dayCount * 24 * 3600 - GetServerTime()
  return leftTime
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
def.static("=>", "boolean").IsFeatureOpen = function()
  local bOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_DOU_DOU_SONG_LI)
  return bOpen
end
def.static("=>", "boolean").IsExpired = function()
  local opendDay = require("Main.Server.ServerModule").Instance():GetServerOpenDays()
  if opendDay > const.dayCount then
    return true
  end
  return false
end
def.static("=>", "boolean").IsShowRedDot = function()
  if not Cls.IsFeatureOpen() or not Cls.HasAwardToGet() then
    return false
  end
  return true
end
def.static("=>", "boolean").HasAwardToGet = function()
  if instance:isOwnScoreAward() then
    return true
  end
  local tabId, index, isHaveAward = instance:getCanGetAwardTabId()
  warn("isHaveAward", isHaveAward)
  return isHaveAward
end
def.static().SelfNodeOpenChg = function()
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
    nodeId = NodeId.DoudouGift
  })
end
def.static().SelfNotiftChg = function()
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
    nodeId = NodeId.TescoMall
  })
end
def.static("=>", "boolean").IsLvEnough = function()
  return _G.GetHeroProp().level >= const.roleMinLevel
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  if p.feature == Feature.TYPE_DOU_DOU_SONG_LI then
    Cls.SelfNodeOpenChg()
  end
end
def.static("table", "table").OnCrossDay = function(p, c)
  Cls.SelfNodeOpenChg()
end
def.static("table", "table").OnAchievementGoaInfoChagnge = function(p1, p2)
  if p1[1] == const.activityId then
    Cls.SelfNotiftChg()
    Cls.SelfNodeOpenChg()
  end
end
def.static("table", "table").OnAchievementScoreInfoChagnge = function(p1, p2)
  if p1[1] == const.activityId then
    Cls.SelfNotiftChg()
    Cls.SelfNodeOpenChg()
  end
end
def.static("table", "table").OnHeroLvUp = function(p, c)
  if _G.GetHeroProp().level >= const.roleMinLevel then
    Cls.SelfNodeOpenChg()
  end
end
return DoudouGiftMgr.Commit()
