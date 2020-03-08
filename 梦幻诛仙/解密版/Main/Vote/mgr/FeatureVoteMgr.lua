local Lplus = require("Lplus")
local FeatureVoteMgr = Lplus.Class("FeatureVoteMgr")
local VoteModule = require("Main.Vote.VoteModule")
local VoteUtils = require("Main.Vote.VoteUtils")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = FeatureVoteMgr.define
local NOT_SET = -1
local debuglog = function(formatstr, ...)
  if type(formatstr) == "string" then
    warn(formatstr:format(...))
  else
    warn(...)
  end
end
def.field("number").m_activityId = NOT_SET
local instance
def.static("=>", FeatureVoteMgr).Instance = function()
  if not instance then
    instance = FeatureVoteMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_ACTIVITY_START, FeatureVoteMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_ACTIVITY_RESET, FeatureVoteMgr.OnActivityReset)
  Event.RegisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_ACTIVITY_END, FeatureVoteMgr.OnActivityEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, FeatureVoteMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, FeatureVoteMgr.OnActivityClose)
  Event.RegisterEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_SUCCESS, FeatureVoteMgr.OnVoteSuccess)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, FeatureVoteMgr.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FeatureVoteMgr.OnFunctionOpenChange)
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    debuglog("feature(%d) not open", Feature.TYPE_NEW_FUNCTION_VOTE)
    return false
  end
  local activityId = self:GetActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg == nil then
    debuglog("activity(%d) cfg not found", activityId)
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp.level < activityCfg.levelMin then
    debuglog("activity(%d) require minLevel=%d, role level is %d", activityId, activityCfg.levelMin, heroProp.level)
    return false
  end
  return true
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_NEW_FUNCTION_VOTE)
  return isOpen
end
def.method("=>", "number").GetActivityId = function(self)
  if self.m_activityId == NOT_SET then
    self.m_activityId = VoteUtils.GetActivityIdByFeatureType(Feature.TYPE_NEW_FUNCTION_VOTE)
  end
  return self.m_activityId
end
def.method("=>", "number").GetNotifyMessageCount = function(self)
  if not self:IsOpen() then
    return 0
  end
  if 0 < self:GetLeftVoteTimes() then
    return 1
  else
    return 0
  end
end
def.method("number").Vote = function(self, voteId)
  local activityId = self:GetActivityId()
  local voteIds = {
    [voteId] = voteId
  }
  VoteModule.Instance():Vote(activityId, voteIds)
end
def.method("=>", "number").GetVotedTimes = function(self)
  local activityId = self:GetActivityId()
  local voteInfo = VoteModule.Instance():GetActivityVoteInfo(activityId)
  return voteInfo:GetVotedTimes()
end
def.method("=>", "number").GetMaxVoteTimes = function(self)
  local activityId = self:GetActivityId()
  local commonVoteCfg = VoteUtils.GetCommonVoteCfg(activityId)
  return commonVoteCfg.voteCountMax
end
def.method("=>", "number").GetLeftVoteTimes = function(self)
  local leftTimes = self:GetMaxVoteTimes() - self:GetVotedTimes()
  leftTimes = math.max(leftTimes, 0)
  return leftTimes
end
def.method("=>", "table").GetAllVoteDatas = function(self)
  local allCfgs = VoteUtils.GetAllFeatureVoteCfgs()
  local allDatas = {}
  for i, v in ipairs(allCfgs) do
    if v.joinVote then
      local data = {}
      data.id = v.id
      data.name = v.describeTitle
      data.desc = v.functionDescribe
      data.icon = v.iconResourceId
      data.functionType = v.functionType
      data.rank = v.rank or i
      allDatas[#allDatas + 1] = data
    end
  end
  table.sort(allDatas, function(l, r)
    return l.rank < r.rank
  end)
  return allDatas
end
def.method().OnFeatureStatusChange = function(self)
  local isOpen = self:IsFeatureOpen()
  local activityId = constant.CConstellationConsts.Activityid
  if isOpen then
  else
    Event.DispatchEvent(ModuleId.VOTE, gmodule.notifyId.Vote.FEATURE_VOTE_CLOSE, nil)
  end
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
end
def.static("table", "table").OnActivityStart = function(params)
  local activityId = params and params[1] or 0
  local self = instance
  local selfActivityId = self:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
end
def.static("table", "table").OnActivityReset = function(params)
  local activityId = params and params[1] or 0
  local self = instance
  local selfActivityId = self:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
end
def.static("table", "table").OnActivityEnd = function(params)
  local activityId = params and params[1] or 0
  local self = instance
  local selfActivityId = self:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
end
def.static("table", "table").OnActivityTodo = function(params)
  local activityId = params and params[1] or 0
  local self = instance
  local selfActivityId = self:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  AwardPanel.Instance():ShowPanelEx(NodeId.FeatureVote)
end
def.static("table", "table").OnActivityClose = function(params)
  local activityId = params and params[1] or 0
  local self = instance
  local selfActivityId = self:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
  Event.DispatchEvent(ModuleId.VOTE, gmodule.notifyId.Vote.FEATURE_VOTE_CLOSE, nil)
end
def.static("table", "table").OnVoteSuccess = function(params)
  local activityId = params.activityId
  local self = instance
  local selfActivityId = self:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
end
def.static("table", "table").OnFunctionOpenInit = function(params)
  instance:OnFeatureStatusChange()
end
def.static("table", "table").OnFunctionOpenChange = function(params)
  if params and params.feature == Feature.TYPE_NEW_FUNCTION_VOTE then
    instance:OnFeatureStatusChange()
  end
end
return FeatureVoteMgr.Commit()
