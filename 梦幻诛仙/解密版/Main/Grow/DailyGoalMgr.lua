local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local DailyGoalMgr = Lplus.Class(CUR_CLASS_NAME)
local BaseGoal = Lplus.ForwardDeclare("Main.Grow.DailyGoals.BaseGoal")
local GrowModule = Lplus.ForwardDeclare("GrowModule")
local ItemModule = require("Main.Item.ItemModule")
local GrowUtils = require("Main.Grow.GrowUtils")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local def = DailyGoalMgr.define
def.field("table").m_goals = nil
def.field("boolean").m_needRenew = false
local myFeature = Feature.TYPE_DAY_TARGET
local _TEMP_REMOVE = false
local instance
def.static("=>", DailyGoalMgr).Instance = function()
  if instance == nil then
    instance = DailyGoalMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.m_goals = {}
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grow.SSynTargetInfo", DailyGoalMgr.OnSSynTargetInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grow.SSynTargetSchedule", DailyGoalMgr.OnSSynTargetSchedule)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, DailyGoalMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DailyGoalMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, DailyGoalMgr.OnFunctionOpenInit)
end
def.method("=>", "boolean").IsUnlock = function(self)
  if _TEMP_REMOVE then
    return false
  end
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(myFeature) then
    return false
  end
  local GrowUtils = import(".GrowUtils", CUR_CLASS_NAME)
  local unlockLevel = GrowUtils.GetDailyGoalConsts("OPEN_LEVEL")
  local heroProp = _G.GetHeroProp()
  return unlockLevel <= heroProp.level
end
def.method("number", "=>", BaseGoal).GetGoal = function(self, targetId)
  return self.m_goals[targetId]
end
def.method("=>", "table").GetGoalsList = function(self)
  if self.m_needRenew then
    self:CGetInitTargets()
  end
  local list = {}
  for k, goal in pairs(self.m_goals) do
    table.insert(list, goal)
  end
  return list
end
def.method("number", "=>", "boolean").GoToGoal = function(self, targetId)
  local goal = self.m_goals[targetId]
  return goal:Go()
end
def.method("number").ReqGoalAward = function(self, targetId)
  self:CGetAwardReq(targetId)
end
def.method("=>", "number").GetCanDrawAwardAmount = function(self)
  if not self:IsUnlock() then
    return 0
  end
  local amount = 0
  local GrowConsts = require("netio.protocol.mzm.gsp.grow.GrowConsts")
  for k, goal in pairs(self.m_goals) do
    if goal.state == GrowConsts.ST_FINISHED then
      amount = amount + 1
    end
  end
  return amount
end
def.method("=>", "number").GetRefreshNeedMoneyNum = function(self)
  return GrowUtils.GetDailyGoalConsts("FLUSH_COST_GOLD") or 0
end
def.method("=>", "boolean").HasAwardToDraw = function(self)
  return self:GetCanDrawAwardAmount() > 0
end
def.method("=>", "boolean").HasNotify = function(self)
  if self:HasAwardToDraw() then
    return true
  end
  return false
end
def.method("=>", "boolean").HasGoalToRefresh = function(self)
  if self.m_goals == nil then
    return false
  end
  local GrowConsts = require("netio.protocol.mzm.gsp.grow.GrowConsts")
  for k, goal in pairs(self.m_goals) do
    if goal.state == GrowConsts.ST_ON_GOING then
      return true
    end
  end
  return false
end
def.method("number").CGetAwardReq = function(self, targetId)
  local p = require("netio.protocol.mzm.gsp.grow.CGetAwardReq").new(targetId)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "boolean").CRefreshDailyGoals = function(self)
  if not self:HasGoalToRefresh() then
    Toast(textRes.Grow[60])
    return false
  end
  local needNum = Int64.new(DailyGoalMgr.Instance():GetRefreshNeedMoneyNum())
  local haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  if needNum > haveNum then
    local needQuest = true
    _G.GoToBuyGold(needQuest)
    return false
  end
  local p = require("netio.protocol.mzm.gsp.grow.CF5DayTarget").new(haveNum)
  gmodule.network.sendProtocol(p)
  return true
end
def.method().CGetInitTargets = function(self)
  local p = require("netio.protocol.mzm.gsp.grow.CGetInitTargets").new()
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnNewDay = function(p)
  instance.m_needRenew = true
end
def.static("table", "table").OnFunctionOpenInit = function(params)
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(myFeature) then
    Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, nil)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(params)
  if myFeature ~= params.feature then
    return
  end
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, nil)
end
def.static("table").OnSSynTargetInfo = function(p)
  print("OnSSynTargetInfo")
  local GoalFactory = import(".DailyGoals.GoalFactory", CUR_CLASS_NAME)
  local self = instance
  self.m_needRenew = false
  self.m_goals = {}
  for k, target in pairs(p.targets) do
    local goal = GoalFactory.CreateGoal(target.targetId)
    self:_SetGoalValueFromTarget(goal, target)
    self.m_goals[goal.id] = goal
  end
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.SYNC_DAILY_GOALS, nil)
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, nil)
end
def.static("table").OnSSynTargetSchedule = function(p)
  print("OnSSynTargetSchedule")
  local self = instance
  local target = p
  local goal = self.m_goals[target.targetId]
  if goal == nil then
    warn(string.format("Failed to [SSynTargetSchedule %d], because this target is not exist!", target.targetId))
    return
  end
  self:_SetGoalValueFromTarget(goal, target)
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_DAILY_GOAL, {
    target.targetId
  })
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, nil)
end
def.method(BaseGoal, "table")._SetGoalValueFromTarget = function(self, goal, target)
  goal.state = target.targetState
  goal.progress = target.targetParam
  if target.targetAwardBean then
    goal.award = target.targetAwardBean
  end
end
def.method().OnReset = function(self)
  self.m_goals = {}
end
return DailyGoalMgr.Commit()
