local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CrossServerModule = Lplus.Extend(ModuleBase, "CrossServerModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local RoleLadderLoginInfo = require("netio.protocol.mzm.gsp.ladder.RoleLadderLoginInfo")
local def = CrossServerModule.define
local instance
CrossServerModule.TEAM_MEMBER_REQ = 5
def.field("table").readyList = nil
def.field("table").roleInfos = nil
def.field("table").matchTeamInfo = nil
def.field("table").roleid_to_matchInfo = nil
def.field("number").matchingState = RoleLadderLoginInfo.NOMAL_STAGE
def.field("table").myLadderInfo = nil
def.field("table").myRankInfo = nil
def.field("table").phaseCfgs = nil
def.static("=>", CrossServerModule).Instance = function()
  if instance == nil then
    instance = CrossServerModule()
    instance.m_moduleId = ModuleId.CROSS_SERVER
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderReadyRes", CrossServerModule.OnSLadderReadyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderReadyErrorRes", CrossServerModule.OnSLadderReadyErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderCancelReadyRes", CrossServerModule.OnSLadderCancelReadyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderCancelReadyErrorRes", CrossServerModule.OnSLadderCancelReadyErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderMatchRes", CrossServerModule.OnSLadderMatchRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderMatchErrorRes", CrossServerModule.OnSLadderMatchErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderUnMatchRes", CrossServerModule.OnSLadderUnMatchRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderUnMatchErrorRes", CrossServerModule.OnSLadderUnMatchErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SNewMemberAttendLadderRes", CrossServerModule.OnSNewMemberAttendLadderRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SAttendLadderRes", CrossServerModule.OnSAttendLadderRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLeaveLadderRes", CrossServerModule.OnSLeaveLadderRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SSynLadderInfo", CrossServerModule.OnSSynLadderInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SAttendLadderErrorRes", CrossServerModule.OnSAttendLadderErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLeaveLadderErrorRes", CrossServerModule.OnSLeaveLadderErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderCrossMatchFailRes", CrossServerModule.OnSLadderCrossMatchFailRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderCrossMatchRoleInfo", CrossServerModule.OnSLadderCrossMatchRoleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SUpdateCrossMatchProcessInfo", CrossServerModule.OnSUpdateCrossMatchProcessInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SMatchFightEndRet", CrossServerModule.OnSMatchFightEndRet)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLoginWaitForOthers", CrossServerModule.OnSLoginWaitForOthers)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLoginWaitTimeOut", CrossServerModule.OnSLoginWaitTimeOut)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SFightAwardTipRes", CrossServerModule.OnSFightAwardTipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SFightCountAwardTipRes", CrossServerModule.OnSFightCountAwardTipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SRoleLadderInfoRes", CrossServerModule.OnSRoleLadderInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.STakeLadderStageAwardErrorRes", CrossServerModule.OnSTakeLadderStageAwardErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLeaderRemendMemberRes", CrossServerModule.OnSLeaderRemendMemberRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.SLadderSelfRankRes", CrossServerModule.OnSLadderSelfRankRes)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, CrossServerModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, CrossServerModule.OnNpcService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CrossServerModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, CrossServerModule.OnLeaveWorldStage)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, CrossServerModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, CrossServerModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, CrossServerModule.OnTeamChangeLeader)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CrossServerModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.MEMBER_LEAVED, CrossServerModule.OnMemberLeaveTeam)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, CrossServerModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.DISPOSITION_CHANGED, CrossServerModule.OnTeamDispositionChanged)
  ModuleBase.Init(self)
end
def.static("table").OnSLadderReadyRes = function(p)
  if instance.readyList == nil then
    instance.readyList = {}
  end
  instance.readyList[p.roleid:tostring()] = p.roleid
  Event.DispatchEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, p)
end
def.method("userdata").SetReady = function(self, roleId)
  if roleId == nil then
    return
  end
  if instance.readyList == nil then
    instance.readyList = {}
  end
  instance.readyList[roleId:tostring()] = roleId
  Event.DispatchEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, {roleid = roleId})
end
def.static("table").OnSLadderReadyErrorRes = function(p)
  local str
  if p.ret == p.NOT_IN_SAME_LEVEL_STAGE_WITH_LEADER then
    str = textRes.CrossServer[1]
  elseif p.ret == p.NOT_IN_SAME_LEVEL_STAGE_WITH_MEMBER then
    str = textRes.CrossServer[2]
  elseif p.ret == p.NOT_IN_TEAM then
    str = textRes.CrossServer[7]
  elseif p.ret == p.NOW_IN_MATCH_STAGE then
    str = textRes.CrossServer[8]
  elseif p.ret == p.NOW_IN_READY_STAGE then
    str = textRes.CrossServer[9]
    if instance.readyList then
      local myid = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
      instance.readyList[myid:tostring()] = myid
    end
  elseif p.ret == p.TEAM_MEMBER_CHANGED then
    str = textRes.CrossServer[10]
  end
  if str then
    Toast(str)
  end
end
def.static("table").OnSLadderCancelReadyErrorRes = function(p)
  local str
  if p.error == p.IN_CANCEL_MATCH_STAGE then
    str = textRes.CrossServer[15]
  else
    str = string.format(textRes.CrossServer[16], p.error)
  end
  if str then
    Toast(str)
  end
end
def.static("table").OnSLadderCancelReadyRes = function(p)
  if instance.readyList == nil then
    return
  end
  instance.readyList[p.roleid:tostring()] = nil
  Event.DispatchEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, p)
  local info = require("Main.Team.TeamData").Instance():getMember(p.roleid)
  if info then
    Toast(string.format(textRes.CrossServer[31], info.name))
  end
end
def.method("userdata").SetUnReady = function(self, roleId)
  if roleId == nil then
    return
  end
  if instance.readyList == nil then
    return
  end
  instance.readyList[roleId:tostring()] = nil
  Event.DispatchEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, {roleid = roleId})
end
def.static("table").OnSLadderMatchRes = function(p)
  instance.matchingState = RoleLadderLoginInfo.MATCH_STAGE
  if instance.readyList == nil then
    instance.readyList = {}
  end
  local dlg = require("Main.CrossServer.ui.DlgCrossServerTeam").Instance()
  if dlg:IsShow() then
    dlg:MatchStarted(true)
  else
    dlg:ShowDlg()
  end
end
def.static("table").OnSLadderCrossMatchRoleInfo = function(p)
  if instance.matchTeamInfo == nil then
    instance.matchTeamInfo = {}
  end
  instance.matchTeamInfo[1] = p.matchTeamAInfos
  instance.matchTeamInfo[2] = p.matchTeamBInfos
  if instance.roleid_to_matchInfo == nil then
    instance.roleid_to_matchInfo = {}
  end
  for i = 1, 2 do
    local teamInfo = instance.matchTeamInfo[i]
    for j = 1, #teamInfo do
      instance.roleid_to_matchInfo[teamInfo[j].roleid:tostring()] = teamInfo[j]
      teamInfo[j].team = i
      teamInfo[j].idx = j
    end
  end
  require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
  if not _G.PlayerIsInFight() then
    require("Main.CrossServer.ui.DlgCrossServerLoading").Instance():ShowDlg()
  end
  if instance.readyList then
    local members = require("Main.Team.TeamData").Instance():GetAllTeamMembers()
    if members and #members > 1 then
      for i = 2, #members do
        instance.readyList[members[i].roleid:tostring()] = nil
        Event.DispatchEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, {
          roleid = members[i].roleid
        })
      end
    end
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if _G.IsCrossingServer() then
    require("Main.CrossServer.ui.DlgCrossServerLoading").Instance():Hide()
    require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
  if not _G.IsCrossingServer() then
    require("Main.CrossServer.ui.DlgCrossServerLoading").Instance():Hide()
  end
end
def.method("=>", "table").GetMatchTeamInfos = function(self)
  return self.matchTeamInfo
end
def.method("userdata", "=>", "table").GetRoleMatchInfo = function(self, roleid)
  if self.roleid_to_matchInfo == nil or roleid == nil then
    return nil
  end
  return self.roleid_to_matchInfo[roleid:tostring()]
end
def.method("=>", "table").GetMyMatchTeamInfo = function(self)
  if self.matchTeamInfo == nil then
    return nil
  end
  local myid = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local myTeamInfo = self.roleid_to_matchInfo[myid:tostring()]
  if myTeamInfo == nil then
    return nil
  end
  local myTeamIdx = myTeamInfo.team
  return self.matchTeamInfo[myTeamIdx]
end
def.method("userdata", "=>", "table").GetRoleInfoByRoleId = function(self, roleid)
  if self.roleInfos == nil or roleid == nil then
    return nil
  end
  for _, v in pairs(self.roleInfos) do
    if v.roleid:eq(roleid) then
      return v
    end
  end
  return nil
end
def.method("=>", "number").GetTeamMatchScore = function(self)
  if self.roleInfos == nil then
    return 0
  end
  local total = 0
  local maxRanking = 0
  for _, v in pairs(self.roleInfos) do
    total = total + v.score
    if maxRanking < v.score then
      maxRanking = v.score
    end
  end
  return math.max(maxRanking - 50, math.ceil(total / #self.roleInfos))
end
def.static("table").OnSUpdateCrossMatchProcessInfo = function(p)
  if instance.roleid_to_matchInfo == nil then
    return
  end
  for k, v in pairs(p.crossMatchProcessInfos) do
    local info = instance.roleid_to_matchInfo[v.roleid:tostring()]
    if info then
      info.process = v.process
    end
  end
  Event.DispatchEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_MATCH_PROGRESS, nil)
end
def.static("table").OnSLadderMatchErrorRes = function(p)
  local str
  if p.ret == p.NOT_TEAM_LEADER then
    str = textRes.CrossServer[3]
  elseif p.ret == p.TEAM_MEMBER_NOT_ENOUGH then
    str = textRes.CrossServer[4]
  elseif p.ret == p.TEAM_MEMBER_CHANGED then
    str = textRes.CrossServer[10]
  elseif p.ret == p.TEAM_MEMBER_NOT_IN_NORMAL then
    str = textRes.CrossServer[11]
  elseif p.ret == p.TEAM_MEMBER_NOT_IN_SAME_LEVEL_STAGE then
    str = textRes.CrossServer[12]
  elseif p.ret == p.TEAM_MEMBER_NOT_READY then
    str = textRes.CrossServer[13]
  elseif p.ret == p.SEASON_NOT_START then
    str = textRes.CrossServer[32]
  elseif p.ret == p.NOT_IN_SAME_LEVEL_RANGE then
    str = textRes.CrossServer[62]
  else
    str = string.format(textRes.CrossServer[16], p.ret)
  end
  if str then
    Toast(str)
  end
  instance:ResetToNormalStage()
end
def.static("table").OnSLadderUnMatchRes = function(p)
  instance:ResetToNormalStage()
  if p.roleid:ToNumber() == 0 then
    Toast(textRes.CrossServer[39])
  else
    local member = require("Main.Team.TeamData").Instance():getMember(p.roleid)
    if member then
      Toast(string.format(textRes.CrossServer[38], member.name))
    end
  end
end
def.static("table").OnSLadderUnMatchErrorRes = function(p)
  local str
  if p.ret == p.IN_CROSS_SERVER_NOW then
    str = textRes.CrossServer[17]
    require("Main.CrossServer.ui.DlgMatchCountDown").Instance():Hide()
  elseif p.ret == p.IN_CANCEL_MATCH_STAGE then
    str = textRes.CrossServer[15]
  else
    str = string.format(textRes.CrossServer[16], p.ret)
  end
  if str then
    Toast(str)
  end
end
def.static("table").OnSAttendLadderErrorRes = function(p)
  local str
  if p.ret == p.NOT_TEAM_LEADER then
    str = textRes.CrossServer[18]
  elseif p.ret == p.TEAM_CHANGED then
    str = textRes.CrossServer[19]
  elseif p.ret == p.MEMBER_NOT_NORMAL then
    str = textRes.CrossServer[20]
  elseif p.ret == p.NPC_SERVICE_UNUSERABLE then
    str = textRes.CrossServer[21]
  elseif p.ret == p.SEASON_NOT_START then
    str = textRes.CrossServer[32]
  else
    str = string.format(textRes.CrossServer[16], p.ret)
  end
  if str then
    Toast(str)
  end
end
def.static("table").OnSLeaveLadderErrorRes = function(p)
  local str
  if p.ret == p.NOT_TEAM_LEADER then
    str = textRes.CrossServer[18]
  elseif p.ret == p.TEAM_CHANGED then
    str = textRes.CrossServer[19]
  elseif p.ret == p.IN_READY_STAGE then
    str = textRes.CrossServer[22]
  elseif p.ret == p.IN_MATCH_STAGE then
    str = textRes.CrossServer[23]
  elseif p.ret == p.IN_CROSS_SERVER_NOW then
    str = textRes.CrossServer[24]
  else
    str = string.format(textRes.CrossServer[16], p.ret)
  end
  if str then
    Toast(str)
  end
end
def.static("table").OnSTakeLadderStageAwardErrorRes = function(p)
  local str
  if p.ret == p.ALREADY_TAKEN then
    str = textRes.CrossServer[33]
  elseif p.ret == p.DO_NOT_JOIN_LADDER_BEFORE then
    str = textRes.CrossServer[34]
  elseif p.ret == p.DO_NOT_HAS_AWARD then
    str = textRes.CrossServer[35]
  elseif p.ret == p.STAGE_NOT_ENOUGH then
    str = textRes.CrossServer[36]
  elseif p.ret == p.SEND_AWARD_ERROR then
    str = textRes.CrossServer[37]
  else
    str = string.format(textRes.CrossServer[16], p.ret)
  end
  if str then
    Toast(str)
  end
end
def.static("table").OnSLadderCrossMatchFailRes = function(p)
  local str
  if p.ret == p.GEN_TOKEN_FAIL then
    str = textRes.CrossServer[44]
  elseif p.ret == p.DATA_TRANSFOR_FAIL then
    str = textRes.CrossServer[45]
  else
    str = string.format(textRes.CrossServer[16], p.ret)
  end
  if str then
    Toast(str)
  end
  instance:ResetToNormalStage()
end
def.method().ResetToNormalStage = function(self)
  self.matchingState = RoleLadderLoginInfo.NOMAL_STAGE
  require("Main.CrossServer.ui.DlgCrossServerTeam").Instance():MatchStarted(false)
  local loading_dlg = require("Main.CrossServer.ui.DlgCrossServerLoading").Instance()
  loading_dlg:Hide()
end
def.static("table").OnSLadderSelfRankRes = function(p)
  instance.myRankInfo = p
  Event.DispatchEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_MYRANK_INFO, nil)
end
def.method("userdata", "=>", "boolean").IsReady = function(self, roleid)
  if roleid == nil then
    return false
  end
  return instance.readyList ~= nil and instance.readyList[roleid:tostring()] ~= nil
end
def.static("table").OnSAttendLadderRes = function(p)
  instance.roleInfos = p.roleLadderInfos
  require("Main.CrossServer.ui.DlgCrossServerTeam").Instance():ShowDlg()
end
def.static("table").OnSNewMemberAttendLadderRes = function(p)
  if instance.roleInfos == nil then
    return
  end
  table.insert(instance.roleInfos, p.roleLadderInfo)
end
def.static("table").OnSLeaveLadderRes = function(p)
  instance.roleInfos = nil
  require("Main.CrossServer.ui.DlgCrossServerTeam").Instance():Hide()
  instance.readyList = nil
  require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
  instance.phaseCfgs = nil
end
def.static("table").OnSSynLadderInfo = function(p)
  if instance.readyList == nil then
    instance.readyList = {}
  end
  if instance.roleInfos == nil then
    instance.roleInfos = {}
  end
  local members = require("Main.Team.TeamData").Instance():GetAllTeamMembers()
  local captainId = members and members[1] and members[1].roleid
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for i = 1, #p.roleLadderLoginInfos do
    instance.roleInfos[i] = p.roleLadderLoginInfos[i].roleLadderInfo
    local roleId = p.roleLadderLoginInfos[i].roleLadderInfo.roleid
    if captainId and captainId:eq(roleId) or p.roleLadderLoginInfos[i].matchStage == RoleLadderLoginInfo.READY_STAGE or p.roleLadderLoginInfos[i].matchStage == RoleLadderLoginInfo.MATCH_STAGE then
      instance.readyList[roleId:tostring()] = roleId
    end
    if roleId:eq(myId) then
      instance.matchingState = p.roleLadderLoginInfos[i].matchStage
    end
  end
  local dlg = require("Main.CrossServer.ui.DlgCrossServerTeam").Instance()
  dlg:ShowDlg()
end
def.static("table").OnSLoginWaitForOthers = function(p)
  if instance.matchTeamInfo then
    return
  end
  instance.matchTeamInfo = {}
  instance.matchTeamInfo[1] = p.waitRoleInfos
  if instance.roleid_to_matchInfo == nil then
    instance.roleid_to_matchInfo = {}
  end
  local teamInfo = instance.matchTeamInfo[1]
  for j = 1, #teamInfo do
    instance.roleid_to_matchInfo[teamInfo[j].roleid:tostring()] = teamInfo[j]
    teamInfo[j].team = i
    teamInfo[j].idx = j
  end
  local roleScoreMap = {}
  for i = 1, #p.waitRoleInfos do
    roleScoreMap[p.waitRoleInfos[i].roleid:tostring()] = p.waitRoleInfos[i].fightScore
  end
  require("Main.CrossServer.ui.DlgCrossServerBattleResult").Instance():ShowDlg(roleScoreMap, p.ret == 0)
end
def.static("table").OnSLoginWaitTimeOut = function(p)
  require("Main.CrossServer.ui.DlgCrossServerBattleResult").Instance():Hide()
end
def.method("=>", "boolean").IsInMatching = function(self)
  return instance.matchingState == RoleLadderLoginInfo.MATCH_STAGE
end
def.static("table").OnSMatchFightEndRet = function(p)
  local roleScoreMap = {}
  for i = 1, #p.teamAEndRetInfo do
    roleScoreMap[p.teamAEndRetInfo[i].roleid:tostring()] = p.teamAEndRetInfo[i].fightScore
  end
  local teamInfo = instance:GetMyMatchTeamInfo()
  if teamInfo then
    for i = 1, #teamInfo do
      local info = teamInfo[i]
      local target_info = p.teamAEndRetInfo[i]
      if info and target_info and info.roleid:eq(target_info.roleid) then
        info.matchScore = info.matchScore + target_info.fightScore
      end
    end
  end
  require("Main.CrossServer.ui.DlgCrossServerBattleResult").Instance():ShowDlg(roleScoreMap, p.ret == p.TEAM_A_WIN)
end
def.method("number", "=>", "table").GetRoleInfo = function(self, idx)
  return instance.roleInfos and instance.roleInfos[idx]
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceID = p1[1]
  if serviceID == nil then
    return
  end
  local npcId = p1[2]
  if serviceID == constant.CrossServerConsts.npcServiceid then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local state = ActivityInterface.GetActivityState(constant.CrossServerConsts.activityid)
    if state < 0 then
      Toast(textRes.activity[270])
      return
    end
    if state > 0 then
      Toast(textRes.activity[271])
      return
    end
    local cfg = ActivityInterface.GetActivityCfgById(constant.CrossServerConsts.activityid)
    local members = require("Main.Team.TeamData").Instance():GetAllTeamMembers()
    if members == nil or #members < CrossServerModule.TEAM_MEMBER_REQ then
      Toast(textRes.CrossServer[25])
      return
    end
    local min, max = instance:GetLevelRange(members[1].level)
    if #members > 0 then
      for _, v in pairs(members) do
        if v.level < cfg.levelMin then
          Toast(string.format(textRes.CrossServer[43], v.name, tostring(cfg.levelMin)))
          return
        end
        if min > v.level or max < v.level then
          _G.ShowCommonCenterTip(701606317)
          Toast(textRes.CrossServer[47])
          return
        end
      end
    end
    instance:StartCrossServerBattle()
  elseif serviceID == constant.CrossServerConsts.teamPlatServiceid then
  elseif serviceID == constant.CrossServerConsts.stageTipServiceid then
    instance:RequestMyLadderInfo()
  end
end
def.method().StartCrossServerBattle = function(self)
  if self.roleInfos then
    require("Main.CrossServer.ui.DlgCrossServerTeam").Instance():ShowDlg()
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CAttendLadderReq").new())
  end
end
def.method().LeaveCrossServerBattle = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLeaveLadderReq").new())
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1 and p1[1]
  if nil == activityId then
    return
  end
  if activityId == constant.CrossServerConsts.activityid then
    local NPCInterface = require("Main.npc.NPCInterface")
    local npcCfg = NPCInterface.GetNPCCfg(constant.CrossServerConsts.npcid)
    if npcCfg == nil then
      return
    end
    NPCInterface.Instance():SetTargetNPCID(constant.CrossServerConsts.npcid)
    local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    heroMgr.needShowAutoEffect = true
    heroMgr:MoveTo(npcCfg.mapId, npcCfg.x, npcCfg.y, 0, 5, MoveType.AUTO, nil)
  end
end
def.method("number", "number", "=>", "table").GetPhaseInfo = function(self, level, idx)
  local phaseCfg = self:GetPhaseCfgByLevel(level)
  return phaseCfg and phaseCfg.ranks[idx]
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
  instance.readyList = nil
  instance.roleInfos = nil
  instance.matchingState = RoleLadderLoginInfo.NOMAL_STAGE
  instance.myLadderInfo = nil
  instance.myRankInfo = nil
end
def.static("table", "table").OnLeaveWorldStage = function(p1, p2)
  require("Main.CrossServer.ui.DlgCrossServerLoading").Instance():Hide()
  require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
  instance.matchTeamInfo = nil
  instance.roleid_to_matchInfo = nil
  instance.phaseCfgs = nil
end
def.static("table").OnSFightAwardTipRes = function(p)
  local str = textRes.CrossServer[30]
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(p.fightCountAwardInfo, str)
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
def.static("table").OnSFightCountAwardTipRes = function(p)
  local str = string.format(textRes.CrossServer[40], p.count)
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(p.fightCountAwardInfo, str)
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
def.method().RequestMyLadderInfo = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CRoleLadderInfoReq").new())
end
def.static("table").OnSRoleLadderInfoRes = function(p)
  instance.myLadderInfo = p
  require("Main.CrossServer.ui.DlgPhaseInfo").Instance():ShowDlg()
end
def.static("table", "table").OnTeamChangeLeader = function(p1, p2)
  local old_leader = p1 and p1[2]
  if old_leader and instance.readyList then
    instance.readyList[old_leader:tostring()] = nil
  end
  local dlg = require("Main.CrossServer.ui.DlgCrossServerTeam").Instance()
  if dlg:IsShow() then
    dlg:ShowButtons()
    dlg:ShowTeamMembers()
  end
end
def.static("table").OnSLeaderRemendMemberRes = function(p)
  require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.CrossServer[42], function(i, tag)
    if i == 1 then
      local status = require("Main.Team.TeamData").Instance():GetStatus()
      if status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
        Toast(textRes.CrossServer[26])
        return
      end
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderReadyReq").new())
      local dlg = require("Main.CrossServer.ui.DlgCrossServerTeam").Instance()
      if not dlg:IsShow() then
        dlg:ShowDlg()
      end
    end
  end, nil)
end
def.method("=>", "table").GetSeasonCfgs = function(self)
  local cfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_SERVER_SEASON_CFG)
  local size = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.idx = record:GetIntValue("seasonNum")
    cfg.year = record:GetIntValue("year")
    cfg.month = record:GetIntValue("month")
    cfg.day = record:GetIntValue("day")
    cfg.hour = record:GetIntValue("hour")
    cfg.minute = record:GetIntValue("minute")
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.method("=>", "table", "table").GetCurrentSeasonDate = function(self)
  local cfgs = self:GetSeasonCfgs()
  local AbsTimer = require("Main.Common.AbsoluteTimer")
  local cur_time = _G.GetServerTime()
  for i = 1, #cfgs do
    local cur_season = cfgs[i]
    local next_season = cfgs[i + 1]
    local cursec = AbsTimer.GetServerTimeByDate(cur_season.year, cur_season.month, cur_season.day, 0, 0, 0)
    if cur_time >= cursec and next_season == nil then
      return cur_season, nil
    end
    local next_sec = AbsTimer.GetServerTimeByDate(next_season.year, next_season.month, next_season.day, 0, 0, 0)
    if cur_time >= cursec and cur_time < next_sec then
      return cur_season, AbsTimer.GetServerTimeTable(next_sec - 1)
    end
  end
  return nil, nil
end
def.method("number", "number", "boolean", "number", "=>", "number").GetPhaseByScore = function(self, level, score, isPositive, curPhase)
  if self.phaseCfgs == nil then
    self:GetPhaseCfgs()
  end
  local cfg = self:GetPhaseCfgByLevel(level)
  if cfg == nil then
    return -1
  end
  local phaseCfgs = cfg.ranks
  local phase = -1
  if isPositive then
    for i = 1, #phaseCfgs do
      if score >= phaseCfgs[i].upMinScore then
        phase = phaseCfgs[i].idx
      else
        if curPhase > phase then
          phase = curPhase
        end
        break
      end
    end
  else
    for i = #phaseCfgs, 1, -1 do
      if score <= phaseCfgs[i].downMaxScore then
        phase = phaseCfgs[i].idx
      else
        if curPhase < phase then
          phase = curPhase
        end
        break
      end
    end
  end
  return phase
end
def.method("=>", "table").GetPhaseCfgs = function(self)
  if self.phaseCfgs then
    return self.phaseCfgs
  end
  self.phaseCfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_SERVER_PHASE_CFG)
  local size = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local grade_cfg = {}
    grade_cfg.level = record:GetIntValue("level")
    grade_cfg.levelRangeName = record:GetStringValue("levelRangeName")
    grade_cfg.hide = record:GetCharValue("hidden") ~= 0
    grade_cfg.localChartType = record:GetIntValue("localChartType")
    grade_cfg.remoteChartType = record:GetIntValue("remoteChartType")
    local gradeStruct = record:GetStructValue("gradeStruct")
    local count = gradeStruct:GetVectorSize("gradeVector")
    grade_cfg.ranks = {}
    for j = 1, count do
      local rec = gradeStruct:GetVectorValueByIdx("gradeVector", j - 1)
      local rank = {}
      rank.idx = rec:GetIntValue("sort")
      rank.name = rec:GetStringValue("honorName")
      rank.iconName = rec:GetStringValue("iconName")
      rank.awardId = rec:GetIntValue("awardid")
      rank.upMinScore = rec:GetIntValue("levelUpScoreMin")
      rank.downMaxScore = rec:GetIntValue("levelDownScoreMin")
      table.insert(grade_cfg.ranks, rank)
    end
    table.sort(grade_cfg.ranks, function(a, b)
      if a == nil or b == nil then
        return false
      else
        return a.idx < b.idx
      end
    end)
    table.insert(self.phaseCfgs, grade_cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return self.phaseCfgs
end
def.method("number", "=>", "table").GetPhaseCfgByChartType = function(self, chart_type)
  local cfgs = self:GetPhaseCfgs()
  for i = 1, #cfgs do
    if cfgs[i].localChartType == chart_type or cfgs[i].remoteChartType == chart_type then
      return cfgs[i]
    end
  end
  return nil
end
def.method("number", "=>", "table").GetPhaseCfgByLevel = function(self, level)
  local cfgs = self:GetPhaseCfgs()
  local cfg
  for i = 1, #cfgs do
    if level < cfgs[i].level then
      cfg = cfgs[i - 1]
      break
    else
      cfg = cfgs[i]
    end
  end
  return cfg
end
def.method("number", "=>", "number", "number").GetLevelRange = function(self, level)
  local min, max = 0, 0
  local phaseCfgs = self:GetPhaseCfgs()
  for k = 1, #phaseCfgs do
    if level < phaseCfgs[k].level then
      local phase = phaseCfgs[k - 1]
      if phase then
        min = phase.level
        max = phaseCfgs[k].level - 1
      end
      break
    else
      min = phaseCfgs[k].level
      max = 10000
    end
  end
  return min, max
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1 and p1.feature == Feature.TYPE_LADDER then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    if p1.open then
      ActivityInterface.Instance():removeCustomCloseActivity(constant.CrossServerConsts.activityid)
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
        npcid = constant.CrossServerConsts.npcid,
        show = true
      })
    else
      ActivityInterface.Instance():addCustomCloseActivity(constant.CrossServerConsts.activityid)
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
        npcid = constant.CrossServerConsts.npcid,
        show = false
      })
      require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
      require("Main.CrossServer.ui.DlgCrossServerTeam").Instance():Hide()
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_LADDER)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  if isOpen then
    ActivityInterface.Instance():removeCustomCloseActivity(constant.CrossServerConsts.activityid)
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = constant.CrossServerConsts.npcid,
      show = true
    })
  else
    ActivityInterface.Instance():addCustomCloseActivity(constant.CrossServerConsts.activityid)
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = constant.CrossServerConsts.npcid,
      show = false
    })
  end
end
def.static("table", "table").OnMemberLeaveTeam = function(p1, p2)
  local teamData = require("Main.Team.TeamData").Instance()
  if not teamData:HasTeam() then
    CrossServerModule.OnSLeaveLadderRes(nil)
  elseif instance.readyList then
    local roleid = p1 and p1[1]
    if roleid then
      instance.readyList[roleid:tostring()] = nil
    end
  end
end
def.static("table", "table").OnTeamDispositionChanged = function(p1, p2)
  local dlg = require("Main.CrossServer.ui.DlgCrossServerTeam").Instance()
  if dlg:IsShow() then
    dlg:ShowTeamMembers()
  end
end
def.method("=>", "string").GetSeasonDateString = function(self)
  local start_time, end_time = self:GetCurrentSeasonDate()
  local str = ""
  if start_time then
    if end_time == nil then
      str = string.format("%d.%d.%d - ", start_time.year, start_time.month, start_time.day)
    else
      str = string.format("%d.%d.%d - %d.%d.%d", start_time.year, start_time.month, start_time.day, end_time.year, end_time.month, end_time.day)
    end
  end
  return str
end
CrossServerModule.Commit()
return CrossServerModule
