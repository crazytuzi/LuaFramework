local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local VoteModule = Lplus.Extend(ModuleBase, "VoteModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local VoteInfo = require("Main.Vote.VoteInfo")
local VoteUtils = require("Main.Vote.VoteUtils")
local def = VoteModule.define
def.field("table").m_activityVoteInfos = nil
def.field("table").m_allActivityIds = nil
local instance
def.static("=>", VoteModule).Instance = function()
  if not instance then
    instance = VoteModule()
    instance.m_moduleId = ModuleId.VOTE
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  self.m_allActivityIds = VoteUtils.GetAllActivityIds()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.vote.SSynCommonVoteInfo", VoteModule.OnSSynCommonVoteInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.vote.SCommonVoteNormalResult", VoteModule.OnSCommonVoteNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.vote.SCommonVoteSuc", VoteModule.OnSCommonVoteSuc)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, VoteModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, VoteModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, VoteModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, VoteModule.OnActivityEnd)
  require("Main.Vote.mgr.FeatureVoteMgr").Instance():Init()
end
def.method("number", "=>", VoteInfo).GetActivityVoteInfo = function(self, activityId)
  if self.m_activityVoteInfos == nil then
    self.m_activityVoteInfos = {}
  end
  local voteInfo = self.m_activityVoteInfos[activityId]
  if voteInfo == nil then
    voteInfo = self:CreateVoteInfo(activityId)
    self.m_activityVoteInfos[activityId] = voteInfo
  end
  return voteInfo
end
def.method("number", "=>", VoteInfo).CreateVoteInfo = function(self, activityId)
  local voteInfo = VoteInfo()
  voteInfo:Init(activityId)
  return voteInfo
end
def.method("number", "table").Vote = function(self, activityId, voteIds)
  local p = require("netio.protocol.mzm.gsp.vote.CCommonVoteReq").new(activityId, voteIds)
  gmodule.network.sendProtocol(p)
end
def.method().Clear = function(self)
  self.m_activityVoteInfos = nil
end
def.method("number").ResetActivity = function(self, activityId)
  if self.m_activityVoteInfos then
    self.m_activityVoteInfos[activityId] = self:CreateVoteInfo(activityId)
  end
end
def.method("number").OnVoteActivityStart = function(self, activityId)
  self:ResetActivity(activityId)
  Event.DispatchEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_ACTIVITY_START, {activityId})
end
def.method("number").OnVoteActivityReset = function(self, activityId)
  self:ResetActivity(activityId)
  Event.DispatchEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_ACTIVITY_RESET, {activityId})
end
def.method("number").OnVoteActivityEnd = function(self, activityId)
  if self.m_activityVoteInfos then
    self.m_activityVoteInfos[activityId] = nil
  end
  Event.DispatchEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_ACTIVITY_END, {activityId})
end
def.static("table").OnSSynCommonVoteInfo = function(p)
  local self = instance
  self.m_activityVoteInfos = {}
  for activityId, voteDatas in pairs(p.activityId2VoteData) do
    local voteInfo = self:CreateVoteInfo(activityId)
    for i, v in ipairs(voteDatas.votedInfos) do
      voteInfo:AddVoteRecord(v)
    end
    self.m_activityVoteInfos[activityId] = voteInfo
  end
  Event.DispatchEvent(ModuleId.VOTE, gmodule.notifyId.Vote.SYNC_VOTE_INFO, nil)
end
def.static("table").OnSCommonVoteNormalResult = function(p)
  local logMessage = string.format("OnSCommonVoteNormalResult(%d)", p.result)
  warn(logMessage)
  local text = textRes.Vote.SCommonVoteNormalResult[p.result]
  if text then
    text = text:format(unpack(p.args))
  else
    text = logMessage
  end
  Toast(text)
end
def.static("table").OnSCommonVoteSuc = function(p)
  local self = instance
  local activityId = p.activityId
  local voteIds = p.voteIds or {}
  local voteInfo = self:GetActivityVoteInfo(activityId)
  voteInfo:AddVoteRecord(voteIds)
  Event.DispatchEvent(ModuleId.VOTE, gmodule.notifyId.Vote.VOTE_SUCCESS, {activityId = activityId, voteIds = voteIds})
  local doNotShowSuccessMessage = false
  if doNotShowSuccessMessage then
    return
  end
  Toast(textRes.Vote[0])
end
def.static("table", "table").OnLeaveWorld = function()
  instance:Clear()
end
def.static("table", "table").OnActivityStart = function(params)
  local activityId = params and params[1] or 0
  if instance.m_allActivityIds[activityId] == nil then
    return
  end
  instance:OnVoteActivityStart(activityId)
end
def.static("table", "table").OnActivityReset = function(params)
  local activityId = params and params[1] or 0
  if instance.m_allActivityIds[activityId] == nil then
    return
  end
  instance:OnVoteActivityReset(activityId)
end
def.static("table", "table").OnActivityEnd = function(params)
  local activityId = params and params[1] or 0
  if instance.m_allActivityIds[activityId] == nil then
    return
  end
  instance:OnVoteActivityEnd(activityId)
end
return VoteModule.Commit()
