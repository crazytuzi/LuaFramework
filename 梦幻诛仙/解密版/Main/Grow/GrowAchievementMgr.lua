local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local GrowAchievementMgr = Lplus.Class(CUR_CLASS_NAME)
local Achievement = Lplus.ForwardDeclare("Main.Grow.GrowAchievements.Achievement")
local GrowModule = Lplus.ForwardDeclare("GrowModule")
local GrowUtils = import(".GrowUtils")
local LevelGuideInfo = require("netio.protocol.mzm.gsp.grow.LevelGuideInfo")
local def = GrowAchievementMgr.define
def.field("table").m_achievements = nil
def.field("boolean").m_allInited = false
def.field("number").LEVEL_INTERVAL = function()
  return GrowUtils.GetGrowAchievementConsts("LEVEL_INTERVAL") or 10
end
local instance
def.static("=>", GrowAchievementMgr).Instance = function()
  if instance == nil then
    instance = GrowAchievementMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_achievements = {}
end
def.method("number", "=>", Achievement).GetAchievement = function(self, id)
  self.m_achievements[id]:InitData()
  return self.m_achievements[id]
end
def.method("=>", "table").GetAchievementsList = function(self)
  local list = {}
  for k, achievement in pairs(self.m_achievements) do
    achievement:InitData()
    table.insert(list, achievement)
  end
  return list
end
def.method("number", "number", "=>", "table").GetAchievementsInLevelRange = function(self, from, to)
  return self:_GetAchievementsInLevelRange(self.m_achievements, from, to)
end
def.method("table", "number", "number", "=>", "table")._GetAchievementsInLevelRange = function(self, achievements, from, to)
  local list = {}
  for k, achievement in pairs(achievements) do
    achievement:InitData()
    if from <= achievement.unlockLevel and to >= achievement.unlockLevel then
      table.insert(list, achievement)
    end
  end
  return list
end
def.method("=>", "table").GetAvailableAchievements = function(self)
  local INTERVAL = self.LEVEL_INTERVAL
  local heroLevel = _G.GetHeroProp().level
  local minLevel = 0
  local maxLevel = self:GetCurHeroLevelMaxLevel()
  local achievements = self:GetAchievementsInLevelRange(minLevel, maxLevel)
  return achievements
end
def.method("=>", "table").GetAvailableLevelRanges = function(self)
  local INTERVAL = self.LEVEL_INTERVAL
  local minLevel = 0
  local maxLevel = self:GetCurHeroLevelMaxLevel()
  self:InitAllAchievements()
  local achievements = self:GetAvailableAchievements()
  local list = {}
  for i = minLevel, maxLevel, INTERVAL do
    local range = {
      from = i,
      to = i + INTERVAL - 1
    }
    local acs = self:_GetAchievementsInLevelRange(achievements, range.from, range.to)
    if #acs > 0 then
      table.insert(list, range)
    end
  end
  return list
end
def.method("=>", "number").GetCurHeroLevelMaxLevel = function(self)
  local heroLevel = _G.GetHeroProp().level
  local INTERVAL = self.LEVEL_INTERVAL
  local maxLevel = (math.floor((heroLevel - 1) / INTERVAL) + 2) * INTERVAL - 1
  return maxLevel
end
def.method().InitAllAchievements = function(self)
  if self.m_allInited then
    return
  end
  local AchievementFactory = import(".GrowAchievements.AchievementsFactory", CUR_CLASS_NAME)
  local ModuleType = require("consts.mzm.gsp.grow.confbean.ModuleType")
  local self = GrowAchievementMgr.Instance()
  self.m_achievements = self.m_achievements or {}
  local cfgs = GrowUtils.GetAllGrowAchievementCfgs()
  for i, cfg in ipairs(cfgs) do
    if self.m_achievements[cfg.id] == nil and cfg.moduleType == ModuleType.LEVEL_GUIDE then
      local achievement = AchievementFactory.CreateAchievement(cfg.id)
      achievement.state = LevelGuideInfo.ST_ON_GOING
      self.m_achievements[achievement.id] = achievement
    end
  end
  self.m_allInited = true
end
def.method("number", "=>", "boolean").GoInForAchievement = function(self, id)
  local achievement = self.m_achievements[id]
  return achievement:Go()
end
def.method("number").ReqAchievementAward = function(self, id)
  self:CGetAwardReq(id)
end
def.method("=>", "number").GetCanDrawAwardAmount = function(self)
  if _G.GetHeroProp() == nil then
    return 0
  end
  local INTERVAL = self.LEVEL_INTERVAL
  local heroLevel = _G.GetHeroProp().level
  local maxLevel = self:GetCurHeroLevelMaxLevel()
  local amount = 0
  local LevelGuideInfo = require("netio.protocol.mzm.gsp.grow.LevelGuideInfo")
  for k, achievement in pairs(self.m_achievements) do
    if achievement.state == LevelGuideInfo.ST_FINISHED then
      achievement:InitData()
      if maxLevel >= achievement.unlockLevel then
        amount = amount + 1
      end
    end
  end
  return amount
end
def.method("=>", "boolean").HasAwardToDraw = function(self)
  return self:GetCanDrawAwardAmount() > 0
end
def.method("number").CGetAwardReq = function(self, targetId)
  local p = require("netio.protocol.mzm.gsp.grow.CGetLevelGuideAwardReq").new(targetId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSynLevelGuideInfo = function(p)
  local AchievementFactory = import(".GrowAchievements.AchievementsFactory", CUR_CLASS_NAME)
  local self = GrowAchievementMgr.Instance()
  self.m_achievements = {}
  for i, targetId in ipairs(p.notAwardTargets) do
    local achievement = AchievementFactory.CreateAchievement(targetId)
    self:_SetAchievementValueFromTarget(achievement, {
      targetId = targetId,
      targetState = LevelGuideInfo.ST_FINISHED
    })
    self.m_achievements[achievement.id] = achievement
  end
  for i, targetId in ipairs(p.handUpTargets) do
    local achievement = AchievementFactory.CreateAchievement(targetId)
    self:_SetAchievementValueFromTarget(achievement, {
      targetId = targetId,
      targetState = LevelGuideInfo.ST_HAND_UP
    })
    self.m_achievements[achievement.id] = achievement
  end
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.SYNC_GROW_ACHIEVEMENT, nil)
  GrowModule.Instance():CheckNotice()
end
def.static("table").OnSSynLevelGuideSchedule = function(p)
  local self = GrowAchievementMgr.Instance()
  local target = p
  local achievement = self.m_achievements[target.targetId]
  if achievement == nil then
    local AchievementFactory = import(".GrowAchievements.AchievementsFactory", CUR_CLASS_NAME)
    achievement = AchievementFactory.CreateAchievement(target.targetId)
    self.m_achievements[target.targetId] = achievement
  end
  self:_SetAchievementValueFromTarget(achievement, target)
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_GROW_ACHIEVEMENT, {
    target.targetId
  })
  GrowModule.Instance():CheckNotice()
end
def.static("table").OnSSynFunctionOpenInfo = function(p)
  local newFunctionData = require("Main.Grow.NewFunctionData").Instance()
  for id, info in pairs(p.targets) do
    newFunctionData._newFunctionInfo[info.targetId] = info.targetState
  end
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.NewFunction_Changed, {})
end
def.static("table").OnSSynFunctionOpenSchedule = function(p)
  local newFunctionData = require("Main.Grow.NewFunctionData").Instance()
  newFunctionData._newFunctionInfo[p.targetId] = p.targetState
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.NewFunction_Changed, {
    p.targetId
  })
end
def.method("table", "table")._SetAchievementValueFromTarget = function(self, achievement, target)
  achievement.id = target.targetId
  achievement.state = target.targetState
end
def.method().OnReset = function(self)
  self.m_achievements = {}
  self.m_allInited = false
end
return GrowAchievementMgr.Commit()
