local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AutoMatchMgr = Lplus.Class("AutoMatchMgr")
local TeamModule = require("Main.Team.TeamModule")
local TeamData = require("Main.Team.TeamData")
local TeamPlatformUtils = require("Main.TeamPlatform.TeamPlatformUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local SSynMatchState = require("netio.protocol.mzm.gsp.teamplatform.SSynMatchState")
local HeroInterface = require("Main.Hero.Interface")
local TeamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = Lplus.ForwardDeclare("FeatureOpenListModule")
local def = AutoMatchMgr.define
def.field("number").m_autoMatchCfgId = 0
local instance
def.static("=>", AutoMatchMgr).Instance = function()
  if instance == nil then
    instance = AutoMatchMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, AutoMatchMgr.OnLeaveWorldStage)
end
def.method("=>", "boolean").IsOpen = function(self)
  local feature = FeatureOpenListModule.Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_INTELLIGENT_MATCH_ZHENYAO_GUAJI)
  return isOpen
end
def.method("number", "=>", "boolean").CanAutoMatch = function(self, matchCfgId)
  if not self:IsOpen() then
    return false
  end
  local matchCfg = TeamPlatformUtils.GetTeamPlatformMatchOptionCfg(matchCfgId)
  if matchCfg == nil then
    return false
  end
  return matchCfg.canAIMatch
end
def.method("number", "=>", "boolean").IsAutoMatchcing = function(self, matchCfgId)
  if not self:IsOpen() then
    return false
  end
  return self.m_autoMatchCfgId == matchCfgId
end
def.method("=>", "boolean").HaveAutoMatchOption = function(self)
  if not self:IsOpen() then
    return false
  end
  return self.m_autoMatchCfgId ~= 0
end
def.method().AutoMatch = function(self)
  if not self:HaveAutoMatchOption() then
    return
  end
  local matchCfgId = self.m_autoMatchCfgId
  local subOptionId = 0
  local cfg = TeamPlatformUtils.GetTeamPlatformMatchOptionCfg(matchCfgId)
  local subCfg = cfg:GetSubCfg()
  if subCfg then
    local maxLevel = 0
    for i, option in ipairs(subCfg.optionList) do
      if maxLevel <= option.minLevel then
        maxLevel = option.minLevel
        subOptionId = option.index
      end
    end
  end
  local matchOption = {matchCfgId, subOptionId}
  local matchOptions = {matchOption}
  local matchRange = TeamPlatformMgr.MatchRange.First
  TeamPlatformMgr.Instance():StartMatch(matchOptions, matchRange)
end
def.method("number").SetAuto = function(self, matchCfgId)
  self.m_autoMatchCfgId = matchCfgId
  Toast(textRes.TeamPlatform[35])
end
def.method().CancelAuto = function(self)
  self.m_autoMatchCfgId = 0
  Toast(textRes.TeamPlatform[36])
end
def.method().Reset = function(self)
  self.m_autoMatchCfgId = 0
end
def.static("table", "table").OnLeaveWorldStage = function()
  instance:Reset()
end
return AutoMatchMgr.Commit()
