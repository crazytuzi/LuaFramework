local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TeamPlatformUIMgr = Lplus.Class("TeamPlatformUIMgr")
local TeamData = require("Main.Team.TeamData")
local TeamPlatformUtils = require("Main.TeamPlatform.TeamPlatformUtils")
local TeamPlatformMgr = Lplus.ForwardDeclare("TeamPlatformMgr")
local def = TeamPlatformUIMgr.define
local UISet = {
  TeamPlatformPanel = "TeamPlatformPanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", TeamPlatformUIMgr).Instance = function()
  if instance == nil then
    instance = TeamPlatformUIMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TEAM_PLATFORM_CLICK, TeamPlatformUIMgr.OnReqOpenningTeamPlatformPanel)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.OPEN_TEAM_PLATFORM_PANEL_REQ, TeamPlatformUIMgr.OnReqOpenningTeamPlatformPanel)
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_MATCH_STATE, TeamPlatformUIMgr.OnSyncMatchState)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, TeamPlatformUIMgr.OnAcceptNPCService)
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_TEAM_MATCH_STATE, TeamPlatformUIMgr.OnSyncTeamMatchState)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("table", "table").OnReqOpenningTeamPlatformPanel = function()
  local self = instance
  local roleId = _G.GetMyRoleID()
  local teamData = TeamData.Instance()
  if teamData:HasTeam() and not teamData:IsCaptain(roleId) then
    Toast(textRes.TeamPlatform[1])
  else
    self:GetUI(UISet.TeamPlatformPanel).Instance():ShowPanel()
  end
end
def.static("table", "table").OnSyncMatchState = function(params)
  local isMatching = params.isMatching
  if isMatching then
    Toast(textRes.TeamPlatform[5])
  end
end
def.static("table", "table").OnSyncTeamMatchState = function(params)
  local isMatching = params.isMatching
end
local catchedServiceCfgs
def.static("table", "table").OnAcceptNPCService = function(params, param2)
  local serviceID = params[1]
  local NPCID = params[2]
  if catchedServiceCfgs == nil then
    catchedServiceCfgs = TeamPlatformUtils.GetTeamPlatformServiceCfgs()
  end
  local teamMatchId = catchedServiceCfgs[serviceID]
  if teamMatchId == nil then
    return
  end
  local panelInstance = instance:GetUI(UISet.TeamPlatformPanel).Instance()
  panelInstance:FocusOnTarget(teamMatchId)
end
def.method("=>", "table").GetTeamPlatformPanelViewData = function(self)
  local options = TeamPlatformMgr.Instance():GetTeamPlatformMatchOptions()
  local classes = {}
  for i, v in ipairs(options) do
    classes[v.classId] = classes[v.classId] or {}
    local class = classes[v.classId]
    class.optionList = class.optionList or {}
    table.insert(class.optionList, v)
  end
  local list = {}
  for classId, class in pairs(classes) do
    local classCfg = TeamPlatformUtils.GetTeamPlatformMatchClassCfg(classId)
    class.name = classCfg.name
    class.rank = classCfg.rank
    table.insert(list, class)
  end
  table.sort(list, function(left, right)
    return left.rank < right.rank
  end)
  return list
end
def.method("table", "=>", "table").GetTeamPlatformMatchMembersViewData = function(self, matchOption)
  local viewData = {
    cpatainNum = 0,
    nonCapatainNum = 0,
    teams = {}
  }
  if matchOption == nil then
    return viewData
  end
  local activityCfg = {
    matchCfgId = matchOption[1],
    index = matchOption[2]
  }
  local matchMemberInfo = TeamPlatformMgr.Instance():GetMatchMemberInfo(activityCfg)
  if matchMemberInfo == nil then
    return viewData
  end
  viewData.cpatainNum = matchMemberInfo.leadersNum
  viewData.nonCapatainNum = matchMemberInfo.rolesNum
  for i, v in ipairs(matchMemberInfo.leadersInfo) do
    local teamInfo = {}
    teamInfo.teamId = v.teamId
    teamInfo.cpatainId = v.leaderId
    teamInfo.cpatainName = v.teamLeaderName
    teamInfo.cpatainLevel = v.teamLeaderLevel
    teamInfo.cpatainOccupation = v.teamLeaderOccupation
    teamInfo.membersNum = v.num
    teamInfo.levelRange = v.level
    teamInfo.matchName = TeamPlatformUtils.GetMatchName(v.activityCfg)
    table.insert(viewData.teams, teamInfo)
  end
  return viewData
end
return TeamPlatformUIMgr.Commit()
