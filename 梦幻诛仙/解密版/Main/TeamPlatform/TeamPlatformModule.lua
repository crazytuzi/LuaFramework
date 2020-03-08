local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TeamPlatformModule = Lplus.Extend(ModuleBase, "TeamPlatformModule")
local TeamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr")
local AutoMatchMgr = require("Main.TeamPlatform.AutoMatchMgr")
require("Main.module.ModuleId")
local def = TeamPlatformModule.define
def.field("boolean").autoReMatch = false
def.field("table").autoMatchMgr = nil
local instance
def.static("=>", TeamPlatformModule).Instance = function()
  if instance == nil then
    instance = TeamPlatformModule()
    instance.m_moduleId = ModuleId.TEAM_PLATFORM
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.TeamPlatform.TeamPlatformUIMgr").Instance()
  require("Main.TeamPlatform.TeamPlatformMgr").Instance()
  self.autoMatchMgr = AutoMatchMgr.Instance()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SSynMatchState", TeamPlatformModule.OnSSynMatchState)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SRoleMatchSuc", TeamPlatformModule.OnSRoleMatchSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.STeamMatchSuc", TeamPlatformModule.OnSTeamMatchSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SBeLeaderToMatch", TeamPlatformModule.OnSBeLeaderToMatch)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SWrongTryMatchAgain", TeamPlatformModule.OnSWrongTryMatchAgain)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SChangeTryMatchAgain", TeamPlatformModule.OnSChangeTryMatchAgain)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SCancelMatch", TeamPlatformModule.OnSCancelMatch)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SSynLeaderMatchInfo", TeamPlatformModule.OnSSynLeaderMatchInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SLeaderCancelMatch", TeamPlatformModule.OnSLeaderCancelMatch)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SSendMatchMembers", TeamPlatformModule.OnSSendMatchMembers)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SChangeToNormalMatch", TeamPlatformModule.OnSChangeToNormalMatch)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.STeamMatchBro", TeamPlatformModule.OnSTeamMatchBro)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, TeamPlatformModule.OnJoinTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, TeamPlatformModule.OnJoinTeam)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TeamPlatformModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_KICK_TEAM, TeamPlatformModule.OnBeKickedOutTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_TEAM_DISMISS, TeamPlatformModule.OnLeaveTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, TeamPlatformModule.OnLeaveTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, TeamPlatformModule.OnTeamMemberNumChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.MEMBER_LEAVED, TeamPlatformModule.OnMemberLeaveTeam)
end
def.static().ReMatch = function()
  require("Main.TeamPlatform.TeamPlatformMgr").Instance():ReMatch()
end
def.static().AutoMatch = function()
  instance.autoMatchMgr:AutoMatch()
end
def.static().CancelAutoMatch = function()
  instance.autoMatchMgr:CancelAuto()
end
def.static("table").OnSSynMatchState = function(p)
  TeamPlatformMgr.Instance():SyncMatchState(p.matchState)
end
def.static("table").OnSRoleMatchSuc = function(p)
  print("OnSRoleMatchSuc")
  instance.autoReMatch = true
end
def.static("table").OnSTeamMatchSuc = function(p)
  print("OnSTeamMatchSuc")
  instance.autoReMatch = true
end
def.static("table").OnSBeLeaderToMatch = function(p)
  Toast(textRes.TeamPlatform[11])
end
def.static("table").OnSWrongTryMatchAgain = function(p)
  require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.TeamPlatform[12], textRes.TeamPlatform[13], "", "", 0, 30, function(selection)
    if selection == 0 then
      TeamPlatformMgr.Instance():CancelMatch()
    end
  end, nil)
end
def.static("table").OnSChangeTryMatchAgain = function(p)
end
def.static("table").OnSTeamsInfo = function(p)
  TeamPlatformMgr.Instance():SyncTeamsInfo(p.teamInfoList)
end
def.static("table").OnSNewTeamJoinInfo = function(p)
  TeamPlatformMgr.Instance():SyncNewTeam(p.newTemInfo)
end
def.static("table").OnSCancelMatch = function(p)
  Toast(textRes.TeamPlatform[10])
end
def.static("table", "table").OnJoinTeam = function(params, context)
end
def.static("table", "table").OnBeKickedOutTeam = function(params, context)
  local showLeaveTeamConfirm = function(default, onConfirm, onCancel)
    require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.TeamPlatform[3], textRes.TeamPlatform[24], textRes.Common[401], textRes.Common[402], default, 30, function(s, tag)
      if s == 1 then
        _G.SafeCallback(onConfirm)
      else
        _G.SafeCallback(onCancel)
      end
    end, {m_level = 0})
  end
  if instance.autoMatchMgr:HaveAutoMatchOption() then
    showLeaveTeamConfirm(1, TeamPlatformModule.AutoMatch, TeamPlatformModule.CancelAutoMatch)
  elseif instance.autoReMatch then
    showLeaveTeamConfirm(1, TeamPlatformModule.ReMatch, nil)
  end
  instance.autoReMatch = false
  TeamPlatformMgr.Instance():CheckMatchOption()
end
def.static("table", "table").OnLeaveTeam = function(params, context)
  local showLeaveTeamConfirm = function(default, onConfirm, onCancel)
    require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.TeamPlatform[3], textRes.TeamPlatform[34], textRes.Common[401], textRes.Common[402], default, 30, function(s, tag)
      if s == 1 then
        _G.SafeCallback(onConfirm)
      else
        _G.SafeCallback(onCancel)
      end
    end, {m_level = 0})
  end
  if instance.autoMatchMgr:HaveAutoMatchOption() then
    showLeaveTeamConfirm(1, TeamPlatformModule.AutoMatch, TeamPlatformModule.CancelAutoMatch)
  end
  instance.autoReMatch = false
  TeamPlatformMgr.Instance():CheckMatchOption()
end
def.static("table", "table").OnTeamMemberNumChanged = function(params, context)
  local TeamData = require("Main.Team.TeamData")
  if TeamData.Instance():IsTeamMembersFully() and TeamPlatformMgr.Instance().isTeamMatching then
    TeamPlatformMgr.Instance():UpdateTeamMatchingState(false)
  end
end
def.static("table", "table").OnMemberLeaveTeam = function(params, context)
  local TeamData = require("Main.Team.TeamData")
  if TeamData.Instance():MeIsCaptain() and not TeamPlatformMgr.Instance():IsMatching() then
    local showMemberLeaveTeamConfirm = function(default, onConfirm, onCancel)
      require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.TeamPlatform[12], textRes.TeamPlatform[14], "", "", default, 30, function(s, tag)
        if s == 1 then
          _G.SafeCallback(onConfirm)
        else
          _G.SafeCallback(onCancel)
        end
      end, {m_level = 0})
    end
    if instance.autoMatchMgr:HaveAutoMatchOption() then
      showMemberLeaveTeamConfirm(1, TeamPlatformModule.AutoMatch, TeamPlatformModule.CancelAutoMatch)
    elseif instance.autoReMatch then
      showMemberLeaveTeamConfirm(0, TeamPlatformModule.ReMatch, function(...)
        instance.autoReMatch = false
      end)
    end
  end
end
def.static("table").OnSSynLeaderMatchInfo = function(p)
  TeamPlatformMgr.Instance():SynLeaderMatchInfo(p)
  if p.synType == p.class.SYN__BEGIN_MATCH then
    local TeamData = require("Main.Team.TeamData")
    if not TeamData.Instance():MeIsCaptain() then
      local name = require("Main.TeamPlatform.TeamPlatformUtils").GetMatchName(p.activityInfo)
      local text = string.format(textRes.TeamPlatform[18], name)
      Toast(text)
    end
  end
  Event.DispatchEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.MATCH_TARGET_CHANGE, nil)
end
def.static("table").OnSLeaderCancelMatch = function(p)
  TeamPlatformMgr.Instance():UpdateTeamMatchingState(false)
end
def.static("table").OnSSendMatchMembers = function(p)
  print("OnSSendMatchMembers #p.leadersInfo, p.leadersNum, p.rolesNum", #p.leadersInfo, p.leadersNum, p.rolesNum)
  TeamPlatformMgr.Instance():SynMatchMemberInfo(p)
  Event.DispatchEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.MATCH_MEMBERS_UPDATE, nil)
end
def.static("table").OnSChangeToNormalMatch = function(p)
  if p.changeType == p.class.TIME_OUT__CHANGE then
    Toast(textRes.TeamPlatform[26])
  elseif p.changeType == p.class.NEW_ENOUGH__CHANGE then
    Toast(textRes.TeamPlatform[33])
  end
end
def.static("table").OnSTeamMatchBro = function(p)
  TeamPlatformMgr.Instance():AddToTeamChannel(p.content)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  local reason = params and params.reason or 0
  if reason ~= _G.LeaveWorldReason.RECONNECT then
    instance.autoReMatch = false
  end
end
return TeamPlatformModule.Commit()
