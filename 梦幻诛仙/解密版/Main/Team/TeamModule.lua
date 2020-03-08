local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TeamModule = Lplus.Extend(ModuleBase, "TeamModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local teamData = require("Main.Team.TeamData").Instance()
local def = TeamModule.define
local instance
local dlgTeamMain = require("Main.Team.ui.DlgTeamMain").Instance()
local dlgActivity = require("Main.Team.ui.DlgTeamActivity").Instance()
local ChatMsgData = require("Main.Chat.ChatMsgData")
local CResult = {
  SUCCESS = 0,
  FORBIDDEN_IN_FLYING = 1,
  FORBIDDEN_IN_RIDING = 2,
  ALREADY_HAVE_TEAM = 3
}
def.const("table").CResult = CResult
def.field("table").BeLeaderPanel = nil
def.static("=>", TeamModule).Instance = function()
  if instance == nil then
    instance = TeamModule()
    instance.m_moduleId = ModuleId.TEAM
  end
  return instance
end
def.override().Init = function(self)
  teamData:Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SSyncTeam", TeamModule.onSSyncTeam)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SInviteTeamTrs", TeamModule.onGetInvitation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.STeamNormalResult", TeamModule.onGetResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SNewMemberJoinTeamBrd", TeamModule.onNewMemberJoin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SJoinTeamNotify", TeamModule.onJoinTeam)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SCreateTeamBrd", TeamModule.onCreateTeam)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SLeaveTeamBrd", TeamModule.onMemberLeaveTeam)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SNewApplicantNotify", TeamModule.onGetNewApplicant)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SFireMemberBrd", TeamModule.onKickMember)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberStatusChangedBrd", TeamModule.onMemberStatusChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberLevelChangedBrd", TeamModule.onMemberLevelChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SRecallAllBrd", TeamModule.onGetRecall)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SAppointLeaderBrd", TeamModule.onChangeLeader)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SSyncMemberListBrd", TeamModule.onSyncTeamMembers)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SSyncRoleInfoInView", TeamModule.onGetRolesInView)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.STeamMemberInfo", TeamModule.OnGetTeamInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SDismissAllBrd", TeamModule.OnDismissTeam)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SSyncApplicantList", TeamModule.OnSyncApplicantList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SReqChangeZhenfa", TeamModule.OnSReqChangeZhenfa)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SDispositionChanged", TeamModule.onSDispositionChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberReturnBrd", TeamModule.onSMemberReturnBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberNameChangedBrd", TeamModule.onSMemberNameChangedBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberFriendSetChangedBrd", TeamModule.onSFriendSetChangedBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberModelChangedBrd", TeamModule.onSMemberModelChangedBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SInviteBeLeader", TeamModule.onSInviteBeLeader)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SCancelInviteBeLeader", TeamModule.onSCancelInviteBeLeader)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SSynTeamsInfo", TeamModule.onSSynTeamsInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SSynMembersInfo", TeamModule.onSSynMembersInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SBeFiredProtectStateChange", TeamModule.onSBeFiredProtectStateChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SSynRolesUnderProtect", TeamModule.onSSynRolesUnderProtect)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberAvatarChangedBrd", TeamModule.onSMemberAvatarChangedBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberAvatarFrameChangedBrd", TeamModule.onSMemberAvatarFrameChangedBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.confirm.SConfirmReq", TeamModule.onSConfirmReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.confirm.SConfirmBro", TeamModule.onSConfirmBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.confirm.SConfirmErrBro", TeamModule.onSConfirmErrBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SSyncRolesOnMultiRoleMounts", TeamModule.OnSSyncRolesOnMultiRoleMounts)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TEAM_CLICK, TeamModule.OnNotify)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TeamModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupChanged, TeamModule.UpdateFrame)
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_MATCH_STATE, TeamModule.UpdateTeamPlatform)
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.MATCH_TARGET_CHANGE, TeamModule.UpdateTeamPlatform)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TeamModule.EnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, TeamModule.LeaveFight)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE, TeamModule.HeroMove)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_LEADER_CLICK_SCREEN, TeamModule.ClickScreen)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, TeamModule.OnNPCService)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.ROLE_NAME_CHANGED, TeamModule.OnRoleChangeName)
  ModuleBase.Init(self)
  local timerID = GameUtil.AddGlobalTimer(10, false, TeamModule.LeaderKeepAlive)
end
def.static("table", "table").EnterFight = function(param1, param2)
  teamData.roleFighted = true
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
end
def.static("table", "table").LeaveFight = function(param1, param2)
  teamData.roleFighted = false
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
end
def.static("table", "table").HeroMove = function(param1, param2)
  teamData.roleMoved = true
end
def.static("table", "table").ClickScreen = function(param1, param2)
  teamData.playerTouched = true
end
def.static("table", "table").OnRoleChangeName = function(param1, param2)
  if param1.roletype == require("netio.protocol.mzm.gsp.map.SSyncRoleNameChange").TYPE_ROLE then
    local members = teamData:GetAllTeamMembers()
    for i = 1, 5 do
      if members[i] ~= nil and members[i].roleid == param1.id then
        members[i].name = param1.name
        if dlgTeamMain:IsShow() then
          dlgTeamMain:showTeamModel(i, param1.id)
        end
        Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
        return
      end
    end
  end
end
def.static().LeaderKeepAlive = function()
  if teamData:MeIsCaptain() == false then
    return
  end
  if teamData.roleFighted or teamData.roleMoved or teamData.playerTouched then
    teamData.roleFighted = false
    teamData.roleMoved = false
    teamData.playerTouched = false
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CRoleKeepAliveNotice").new())
  end
end
def.static("table", "table").OnNPCService = function(param1, param2)
  local serviceID = param1[1]
  if serviceID and serviceID == require("Main.npc.NPCServiceConst").TeamActivity_FindTeam then
    instance:FindTeamInActivity()
  elseif serviceID and serviceID == require("Main.npc.NPCServiceConst").TeamActivity_FindMember then
    instance:FindMembersInActivity()
  end
end
def.method().FindTeamInActivity = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").new(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM))
end
def.method().FindMembersInActivity = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").new(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_MEMBER))
end
def.static("table", "table").OnLeaveWorld = function(param1, param2)
  teamData:Reset()
end
def.static("table", "table").UpdateFrame = function(param1, param2)
  instance:UpdateUI()
end
def.static("table", "table").UpdateTeamPlatform = function(param1, param2)
  if dlgTeamMain:IsShow() then
    dlgTeamMain:updateTeamPlatform()
  end
end
def.method().UpdateUI = function(self)
  if dlgTeamMain:IsShow() then
    dlgTeamMain:updateUI()
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
end
def.static("table").onSSyncTeam = function(p)
  teamData.members = {}
  for i = 1, #p.team.members do
    teamData:AddTeamMember(p.team.members[i])
  end
  teamData:setTeamPosition(p.team.disposition)
  teamData.teamId = p.team.teamid
  teamData.formationId = p.team.zhenFaId
  teamData.formationLevel = p.team.zhenFaLv
  instance:UpdateUI()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.SYNC_TEAM_INFO, nil)
end
def.static("table").onGetInvitation = function(p)
  teamData:SetTeamInvitation(p)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INVITATION, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_APPLY_OR_INVITE, nil)
end
def.static("table").onGetResult = function(p)
  if IsCrossingServer() then
    return
  end
  local resultpro = require("netio.protocol.mzm.gsp.team.STeamNormalResult")
  local tip
  if p.result == resultpro.INVITE_TEAM__INVITEE_IN_TEAM or p.result == resultpro.INVITE_TEAM_REP__INVITER_IN_OTHER_TEAM then
    tip = textRes.Team[3]
  elseif p.result == resultpro.INVITE_TEAM__SUCCESS then
    tip = textRes.Team[4]
  elseif p.result == resultpro.INVITE_TEAM_REP__REFUSE then
    tip = string.format(textRes.Team[5], p.args[1])
  elseif p.result == resultpro.APPLY_TEAM_REP__REFUSE then
    tip = string.format(textRes.Team[88], p.args[1])
  elseif p.result == resultpro.INVITE_TEAM_REP__TIMEOUT then
    tip = textRes.Team[40]
  elseif p.result == resultpro.APPLY_TEAM_REP__TIMEOUT then
    tip = textRes.Team[42]
  elseif p.result == resultpro.INVITE_TEAM_REP__FULL then
    tip = textRes.Team[7]
  elseif p.result == resultpro.APPLY_TEAM_BY_MEMBER__ALREADY then
    tip = textRes.Team[8]
  elseif p.result == resultpro.INVITE_TEAM__INVITEE_IN_APPLYLIST_ALREADY then
    tip = textRes.Team[18]
  elseif p.result == resultpro.APPLY_TEAM_BY_MEMBER__SUCCESS then
    tip = textRes.Team[23]
  elseif p.result == resultpro.EFFECT_AFTER_FIGHT then
    tip = textRes.Team[19]
  elseif p.result == resultpro.RETURN_TEAM_AFTER_FIGHT then
    tip = textRes.Team[20]
  elseif p.result == resultpro.CHANGE_LEADER__TEMPLEAVE then
    tip = textRes.Team[21]
  elseif p.result == resultpro.CHANGE_LEADER__OFFLINE then
    tip = textRes.Team[22]
  elseif p.result == resultpro.INVITE_TEAM_REP__REPEAT then
    tip = string.format(textRes.Team[24], p.args[1])
  elseif p.result == resultpro.APPLY_TEAM_REP__OFFLINE or p.result == resultpro.INVITE_TEAM__INVITEE_NOT_ONLINE then
    tip = string.format(textRes.Team[25], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__FULL then
    tip = string.format(textRes.Team[43], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__NULL then
    tip = string.format(textRes.Team[44], p.args[1])
  elseif p.result == resultpro.ACTIVITY_TEAM__NO_TEAMS then
    tip = textRes.Team[71]
  elseif p.result == resultpro.ACTIVITY_TEAM__NO_MEMBERS then
    tip = textRes.Team[72]
  elseif p.result == resultpro.APPLY_TEAM_REP__CHANGE then
    tip = textRes.Team[40]
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_INVITATION, nil)
  elseif p.result == resultpro.APPLY_TEAM_ERROR__IN_TEAM then
    tip = textRes.Team[74]
  elseif p.result == resultpro.JOIN_TEAM__INSTACNE_IN_INSTANCE then
    tip = textRes.Team[77]
  elseif p.result == resultpro.JOIN_TEAM__INSTACNE_TEAM_IN_INSTANCE then
    tip = textRes.Team[78]
  elseif p.result == resultpro.JOIN_TEAM__INSTACNE_XXX_IN_INSTANCE then
    tip = string.format(textRes.Team[79], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__MULTI_INSTANCE_IN_MULTI then
    tip = textRes.Team[80]
  elseif p.result == resultpro.JOIN_TEAM__MULTI_INSTANCE_TEAM_IN_MULTI then
    tip = textRes.Team[81]
  elseif p.result == resultpro.JOIN_TEAM__MULTI_INSTANCE_XXX_IN_MULTI then
    tip = string.format(textRes.Team[82], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__COMPETITION_NOT_SAME_FACTION_INVITE_MEMBER then
    tip = textRes.Team[90]
  elseif p.result == resultpro.JOIN_TEAM__COMPETITION_NOT_SAME_FACTION_APPLY_LEADER then
    tip = string.format(textRes.Team[91], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__COMPETITION_NOT_SAME_WORLD_INVITE_MEMBER then
    tip = textRes.Team[92]
  elseif p.result == resultpro.JOIN_TEAM__COMPETITION_NOT_SAME_WORLD_APPLY_LEADER then
    tip = string.format(textRes.Team[93], p.args[1])
  elseif p.result == resultpro.RETURN_TEAM__ERR_DIFF_WORLD then
    tip = textRes.Team[94]
  elseif p.result == resultpro.JOIN_TEAM__ARENA_NOT_SAME_WORLD_INVITE_MEMBER then
    tip = textRes.Team[95]
  elseif p.result == resultpro.JOIN_TEAM__ARENA_NOT_SAME_WORLD_APPLY_LEADER then
    tip = string.format(textRes.Team[98], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__ARENA_NOT_SAME_CAMP_INVITE_MEMBER then
    tip = textRes.Team[96]
  elseif p.result == resultpro.JOIN_TEAM__ARENA_NOT_SAME_CAMP_APPLY_LEADER then
    tip = string.format(textRes.Team[117], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__ARENA_FULL_INVITE_MEMBER then
    tip = textRes.Team[97]
  elseif p.result == resultpro.JOIN_TEAM__ARENA_FULL_APPLY_LEADER then
    tip = string.format(textRes.Team[116], p.args[1])
  elseif p.result == resultpro.IN_SINGLE_INSTANCE then
    tip = textRes.Team[77]
  elseif p.result == resultpro.JOIN_TEAM__QMHW_LEADER then
    tip = string.format(textRes.Team[108], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__QMHW_MEMBER then
    tip = string.format(textRes.Team[109], p.args[1])
  elseif p.result == resultpro.JOIN_TEAM__QMHW_LEADER_MEMBER_STATUS then
    tip = textRes.Team[110]
  elseif p.result == resultpro.JOIN_TEAM__QMHW_MEMBER_MEMBER_STATUS then
    tip = textRes.Team[111]
  elseif p.result == resultpro.RETURN_TEAM_QMHW_MEMBER_STATUS_WRONG then
    tip = textRes.Team[112]
  elseif p.result == resultpro.APPLY_TEAM__NULL then
    tip = textRes.Team[115]
  elseif p.result == resultpro.JOIN_TEAM__MASSWEDDING_LEADER then
    tip = textRes.Team[161]
  elseif p.result == resultpro.JOIN_TEAM__MASSWEDDING_MEMBER then
    tip = textRes.Team[162]
  elseif p.result == resultpro.JOIN_TEAM__MASSWEDDING_LEADER_SIGN_UP_LEADER then
    tip = textRes.Team[163]
  elseif p.result == resultpro.JOIN_TEAM__MASSWEDDING_MEMBER_SIGN_UP_LEADER then
    tip = textRes.Team[164]
  elseif p.result == resultpro.JOIN_TEAM__MASSWEDDING_LEADER_SIGN_UP_MEMBER then
    tip = textRes.Team[165]
  elseif p.result == resultpro.JOIN_TEAM__MASSWEDDING_MEMBER_SIGN_UP_MEMBER then
    tip = textRes.Team[166]
  elseif p.result == resultpro.INVITE_TEAM_INTERCAPT then
    if false == teamData:IsStrangerBlocked(p.args[1]) then
      teamData:AddBlockStranger(p.args[1])
      tip = string.format(textRes.Team[167], p.args[1])
    end
  elseif p.result == resultpro.INVITE_TEAM_FORBID_BE_INVITED then
    tip = string.format(textRes.Team[168], p.args[1])
  elseif textRes.Team.STeamNormalResult[p.result] then
    tip = textRes.Team.STeamNormalResult[p.result]:format(unpack(p.args))
  end
  if tip ~= nil then
    Toast(tip)
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(tip, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
  end
end
def.static("table").onNewMemberJoin = function(p)
  teamData:AddTeamMember(p.member)
  instance:UpdateUI()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, nil)
  if not IsCrossingServer() then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local msg = string.format(textRes.Team[30], p.member.name)
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
    if teamData:MeIsCaptain() then
      Toast(msg)
    end
  end
end
def.static("table").onJoinTeam = function(p)
  teamData.members = {}
  for i = 1, #p.team.members do
    teamData:AddTeamMember(p.team.members[i])
  end
  teamData.teamId = p.team.teamid
  teamData.formationId = p.team.zhenFaId
  teamData.formationLevel = p.team.zhenFaLv
  local caption = p.team.members[1].name
  instance:UpdateUI()
  require("Main.Team.ui.DlgTeamInfo").Instance():Hide()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, nil)
  if not IsCrossingServer() then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local msg = string.format(textRes.Team[37], caption)
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
    Toast(msg)
  end
  teamData:ClearTeamInvitation()
  teamData:ClearApplicants()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, nil)
end
def.static("table").onCreateTeam = function(p)
  teamData.members = {}
  for i = 1, #p.team.members do
    teamData:AddTeamMember(p.team.members[i])
  end
  teamData:clearAllProtectMember()
  teamData:setTeamPosition(p.team.disposition)
  teamData.teamId = p.team.teamid
  teamData.formationId = p.team.zhenFaId
  teamData.formationLevel = p.team.zhenFaLv
  if not IsCrossingServer() then
    require("Main.Team.ui.DlgTeamInfo").Instance():Hide()
    require("Main.Team.ui.DlgTeamMain").Instance():ShowDlg()
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(textRes.Team[26], ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, nil)
end
def.static("table").onMemberLeaveTeam = function(p)
  if p.roleid == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
    teamData:ClearTeam()
    teamData:clearAllProtectMember()
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, nil)
    require("ProxySDK.ECApollo").DestroyVoipGuidPanel()
  else
    local member = teamData:GetTeamMember(p.roleid)
    if member ~= nil then
      local msg = string.format(textRes.Team[31], member.name)
      require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
      if teamData:MeIsCaptain() then
        Toast(msg)
      end
    end
    teamData:RemoveTeamMember(p.roleid)
    teamData:removeProtectMember(p.roleid)
  end
  instance:UpdateUI()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.MEMBER_LEAVED, {
    p.roleid
  })
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_MOUNT, nil)
end
def.static("table").onGetNewApplicant = function(p)
  teamData:AddApplicant(p.applicant)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_APPLY_OR_INVITE, nil)
end
def.static("table").OnSyncApplicantList = function(p)
  teamData:ClearApplicants()
  if p.applicants ~= nil and #p.applicants > 0 then
    local i
    for i = 0, #p.applicants do
      teamData:AddApplicant(p.applicants[i])
    end
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, nil)
end
def.static("table").onSDispositionChanged = function(p)
  teamData:setTeamPosition(p.disposition)
  if dlgTeamMain:IsShow() then
    require("Main.Team.ui.DlgTeamMain").Instance():ShowDlg()
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.DISPOSITION_CHANGED, nil)
end
def.static("table").onSMemberReturnBrd = function(p)
  local teamer = teamData:GetTeamMember(p.roleId)
  if teamer ~= nil then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local msg = string.format(textRes.Team[33], teamer.name)
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
    if teamData:MeIsCaptain() then
      Toast(msg)
    end
  end
end
def.static("table").onSMemberNameChangedBrd = function(p)
  local teamer = teamData:GetTeamMember(p.roleId)
  if teamer ~= nil then
    teamer.name = p.name
    if dlgTeamMain:IsShow() then
      dlgTeamMain:UpdateUI()
    end
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
  end
end
def.static("table").onSFriendSetChangedBrd = function(p)
  local teamer = teamData:GetTeamMember(p.roleId)
  if teamer ~= nil then
    teamer.friendSetting = p.friendSetting
  end
end
def.static("table").onSCancelInviteBeLeader = function(p)
  if instance.BeLeaderPanel ~= nil then
    instance.BeLeaderPanel:DestroyPanel()
    instance.BeLeaderPanel = nil
  end
end
def.static("table").onSInviteBeLeader = function(p)
  if gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsInMatching() then
    return
  end
  instance.BeLeaderPanel = require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.Team[62], textRes.Team[63], textRes.Team[65], textRes.Team[64], 0, 30, function(option, context)
    if 1 == option then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CTryBeLeaderReq").new())
      if teamData:MeIsCaptain() == true then
        Toast(textRes.Team[66])
      end
    end
  end, nil)
end
def.static("table").onSSynTeamsInfo = function(p)
  dlgActivity:fillData(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM, p.teams)
  if dlgActivity:IsShow() == false then
    dlgActivity:ShowDlg()
  else
    dlgActivity:fillGrid()
  end
end
def.static("table").onSSynMembersInfo = function(p)
  dlgActivity:fillData(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_MEMBER, p.members)
  if dlgActivity:IsShow() == false then
    dlgActivity:ShowDlg()
  else
    dlgActivity:fillGrid()
  end
end
def.static("table").onSBeFiredProtectStateChange = function(p)
  if p.protectState == require("netio.protocol.mzm.gsp.team.SBeFiredProtectStateChange").ENTER_PROTECT then
    teamData:addProtectMember(p.roleId)
  else
    teamData:removeProtectMember(p.roleId)
  end
end
def.static("table").onSSynRolesUnderProtect = function(p)
  teamData:clearAllProtectMember()
  if p.rolesUnderProtect ~= nil and #p.rolesUnderProtect > 0 then
    local i
    for i = 0, #p.rolesUnderProtect do
      teamData:addProtectMember(p.rolesUnderProtect[i])
    end
  end
end
def.static("table").onSMemberAvatarChangedBrd = function(p)
  local positions = teamData:getTeamPosition()
  local idx = -1
  for i = 1, 5 do
    if positions[i] ~= nil and positions[i].teamDispositionMember_id == p.roleid then
      positions[i].avatarId = p.avatarId
      if dlgTeamMain:IsShow() and idx ~= -1 then
        dlgTeamMain:updateTeamPosition()
      end
      idx = i
      break
    end
  end
  local members = teamData:GetAllTeamMembers()
  for i = 1, 5 do
    if members[i] ~= nil and members[i].roleid == p.roleid then
      members[i].avatarId = p.avatarId
      if dlgTeamMain:IsShow() and idx ~= -1 then
        dlgTeamMain:showTeamModel(idx, p.roleid)
      end
      break
    end
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
end
def.static("table").onSMemberAvatarFrameChangedBrd = function(p)
  warn("[TeamModule:onSMemberAvatarFrameChangedBrd] onSMemberAvatarFrameChangedBrd!")
  local positions = teamData:getTeamPosition()
  local idx = -1
  for i = 1, 5 do
    if positions[i] ~= nil and positions[i].teamDispositionMember_id == p.roleid then
      positions[i].avatarFrameid = p.avatarFrameId
      if dlgTeamMain:IsShow() and idx ~= -1 then
        dlgTeamMain:updateTeamPosition()
      end
      idx = i
      break
    end
  end
  local members = teamData:GetAllTeamMembers()
  for i = 1, 5 do
    if members[i] ~= nil and members[i].roleid == p.roleid then
      members[i].avatarFrameid = p.avatarFrameId
      if dlgTeamMain:IsShow() and idx ~= -1 then
        dlgTeamMain:showTeamModel(idx, p.roleid)
      end
      break
    end
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
end
def.static("table").onSMemberModelChangedBrd = function(p)
  local positions = teamData:getTeamPosition()
  local idx = -1
  for i = 1, 5 do
    if positions[i] ~= nil and positions[i].teamDispositionMember_id == p.roleid then
      positions[i].model = p.model
      idx = i
      break
    end
  end
  local members = teamData:GetAllTeamMembers()
  for i = 1, 5 do
    if members[i] ~= nil and members[i].roleid == p.roleid then
      members[i].model = p.model
      if dlgTeamMain:IsShow() and idx ~= -1 then
        dlgTeamMain:showTeamModel(idx, p.roleid)
      end
      return
    end
  end
end
def.static("table").onKickMember = function(p)
  if p.member == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
    teamData:ClearTeam()
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(textRes.Team[28], ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_KICK_TEAM, nil)
    teamData:clearAllProtectMember()
  else
    local teamer = teamData:GetTeamMember(p.member)
    if nil == teamer then
      return
    end
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local msg = string.format(textRes.Team[27], teamer.name)
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
    teamData:RemoveTeamMember(p.member)
    teamData:removeProtectMember(p.member)
  end
  instance:UpdateUI()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, nil)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_MOUNT, nil)
end
def.static("table").onMemberStatusChanged = function(p)
  teamData:SetMemberStatus(p.member, p.status)
  instance:UpdateUI()
  if p.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
    local member = teamData:GetTeamMember(p.member)
    if member ~= nil then
      local msg = string.format(textRes.Team[32], member.name)
      require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
      if teamData:MeIsCaptain() then
        Toast(msg)
      end
    end
  end
  if p.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_OFFLINE then
    local member = teamData:GetTeamMember(p.member)
    if member ~= nil then
      local msg = string.format(textRes.Team[25], member.name)
      if teamData:MeIsCaptain() then
        Toast(msg)
      end
    end
  end
  if p.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_NORMAL then
    local member = teamData:GetTeamMember(p.member)
    if member ~= nil then
      local msg = string.format(textRes.Team[33], member.name)
      require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
      if teamData:MeIsCaptain() then
        Toast(msg)
      end
    end
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, {
    p.member,
    p.status
  })
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_MOUNT, nil)
end
def.static("table").onMemberLevelChanged = function(p)
  teamData:SetMemberLevel(p.member, p.level)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.MEMBER_LEVEL_CHANGED, {
    p.member,
    p.level
  })
  instance:UpdateUI()
end
def.static("table").onChangeLeader = function(p)
  local members = teamData:GetAllTeamMembers()
  local old_leader = members and members[1]
  teamData:SetLeader(p.new_leader)
  instance:UpdateUI()
  if p.new_leader == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
    if not IsCrossingServer() then
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      require("Main.Chat.ChatModule").Instance():SendNoteMsg(textRes.Team[10], ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
      Toast(textRes.Team[10])
    end
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, nil)
  else
    local leader = teamData:GetTeamMember(p.new_leader)
    if leader ~= nil and not IsCrossingServer() then
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      local msg = string.format(textRes.Team[11], leader.name)
      require("Main.Chat.ChatModule").Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
    end
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, {
    p.new_leader,
    old_leader and old_leader.roleid
  })
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_MOUNT, nil)
end
def.static("table").onSyncTeamMembers = function(p)
  teamData:setTeamPosition(p.disposition)
  if p.members ~= nil and #p.members > 0 then
    teamData:SortTeamMembers(p.members)
    if dlgTeamMain:IsShow() then
      require("Main.Team.ui.DlgTeamMain").Instance():ShowDlg()
    end
  end
end
def.static("table").onGetRolesInView = function(p)
  teamData.rolesInView = {}
  for k, v in pairs(p.roleInfoList) do
    if not teamData:IsTeamMember(v.roleid) then
      table.insert(teamData.rolesInView, v)
    end
  end
  local dlg = require("Main.Team.ui.DlgTeamInvite").Instance()
  if dlg:IsShow() then
    dlg:ShowNearBy()
  end
end
def.static("table").onGetRecall = function(p)
  require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[9], function(i, tag)
    if i == 1 then
      local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
      if role ~= nil and role:IsInState(RoleState.WATCH) then
        Toast(textRes.Team[106])
      else
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReturnTeamReq").new())
      end
    end
  end, {id = self})
end
def.static("table", "table").OnNotify = function(param1, param2)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role and role:IsInState(RoleState.GANGCROSS_BATTLE) or not _G.IsCrossingServer() then
    require("Main.Team.ui.DlgTeamMain").Instance():ShowDlg()
  end
end
def.method("userdata").TeamInvite = function(self, roleId)
  if teamData:GetMemberCount() >= 5 then
    Toast(textRes.Team[49])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CInviteTeamReq").new(roleId))
end
def.method("userdata").ApplyTeam = function(self, teamId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CApplyTeamByTeamId").new(teamId))
end
def.method("userdata").TeamPlatformApplyTeam = function(self, teamId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CJoinTeamByPlatformReq").new(teamId))
end
def.method("=>", "number").CreateTeam = function(self)
  if teamData:HasTeam() then
    return CResult.ALREADY_HAVE_TEAM
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CCreateTeamReq").new())
  return CResult.SUCCESS
end
def.static("table").OnGetTeamInfo = function(p)
  require("Main.Team.ui.DlgTeamInfo").Instance():ShowDlg(p.teamMemberInfos)
end
def.static("table").OnSReqChangeZhenfa = function(p)
  teamData.formationId = p.ChangedZhenfaId
  teamData.formationLevel = p.ZhenfaLevel
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_FORMATION, nil)
end
def.static("table").OnDismissTeam = function(p)
  teamData:ClearTeam()
  local myRoleID = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, {myRoleID})
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_TEAM_DISMISS, nil)
  instance:UpdateUI()
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_MOUNT, nil)
end
def.static("table").OnSSyncRolesOnMultiRoleMounts = function(p)
  teamData:SetTeamMount(p.mounts_cfg_id, p.on_mounts_role_id_map)
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_MOUNT, nil)
end
def.field("userdata").confirmSessionId = nil
def.field("number").confirmType = 0
def.static("table").onSConfirmReq = function(p)
  local ConfirmType = require("consts.mzm.gsp.function.confbean.ConfirmType")
  local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
  local teamMembersData = teamData:GetAllTeamMembers()
  local teamMembers = {}
  for k, v in ipairs(teamMembersData) do
    if v.status == TeamMember.ST_NORMAL then
      table.insert(teamMembers, v)
    end
  end
  local title = ""
  local desc = ""
  local desc2 = ""
  if p.confirmType == ConfirmType.FLOOR_FIGHT or p.confirmType == ConfirmType.FLOOR_FIGHT_2 or p.confirmType == ConfirmType.FLOOR_FIGHT_3 then
    local SFloorConfirmDesc = require("netio.protocol.mzm.gsp.floor.SFloorConfirmDesc")
    local bean = UnmarshalBean(SFloorConfirmDesc, p.extroInfo)
    title = textRes.activity[914]
    desc = string.format(textRes.activity[915], bean.floor)
  elseif p.confirmType == ConfirmType.CHESS_ACTIVITY then
    local SChessActivityConfirmDesc = require("netio.protocol.mzm.gsp.chess.SChessActivityConfirmDesc")
    local bean = UnmarshalBean(SChessActivityConfirmDesc, p.extroInfo)
    local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(bean.activity_id)
    title = activityCfg.activityName
    desc = string.format(textRes.activity.Chess[20], activityCfg.activityName)
  elseif p.confirmType == ConfirmType.CHINESE_VALENTINE then
    local SChineseValentineJoinSuccessRep = require("netio.protocol.mzm.gsp.chinesevalentine.SChineseValentineJoinSuccessRep")
    local bean = UnmarshalBean(SChineseValentineJoinSuccessRep, p.extroInfo)
    local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(bean.activityId)
    title = activityCfg.activityName
    desc = string.format(textRes.activity.Qixi[3], activityCfg.activityName)
  elseif p.confirmType == ConfirmType.PK then
    title = textRes.PlayerPK.PK[37]
    if teamMembers[1].roleid == _G.GetHeroProp().id then
      desc = textRes.PlayerPK.PK[7]
    else
      desc = textRes.PlayerPK.PK[8]
    end
  elseif p.confirmType == ConfirmType.PK_WANTED then
    title = textRes.PlayerPK.PlayerWanted[29]
    if teamMembers[1].roleid == _G.GetHeroProp().id then
      desc = textRes.PlayerPK.PlayerWanted[27]
    else
      local SWantedConfirmDesc = require("netio.protocol.mzm.gsp.wanted.SWantedConfirmDesc")
      local bean = UnmarshalBean(SWantedConfirmDesc, p.extroInfo)
      local needMoney = constant.CPKConsts.ARREST_PRICE
      local CurrencyFactory = require("Main.Currency.CurrencyFactory")
      local moneyData = CurrencyFactory.Create(constant.CPKConsts.ARREST_MONEY_TYPE)
      desc = string.format(textRes.PlayerPK.PlayerWanted[28], _G.GetStringFromOcts(bean.name), needMoney, moneyData:GetName())
    end
  elseif p.confirmType == ConfirmType.PK_JAIL_BREAK then
    title = textRes.PlayerPK.PlayerPrison[16]
    if teamMembers[1].roleid == _G.GetHeroProp().id then
      desc = textRes.PlayerPK.PlayerPrison[4]
    else
      local needMoney = constant.CPKConsts.PRISON_BREAK_PRICE
      local CurrencyFactory = require("Main.Currency.CurrencyFactory")
      local moneyData = CurrencyFactory.Create(constant.CPKConsts.PRISON_BREAK_MONEY_TYPE)
      desc = string.format(textRes.PlayerPK.PlayerPrison[5], needMoney, moneyData:GetName())
    end
  elseif p.confirmType == ConfirmType.PK_JAIL_DELIVERY then
    title = textRes.PlayerPK.PlayerPrison[17]
    if teamMembers[1].roleid == _G.GetHeroProp().id then
      desc = textRes.PlayerPK.PlayerPrison[4]
    else
      local SJailDeliveryConfirmDesc = require("netio.protocol.mzm.gsp.prison.SJailDeliveryConfirmDesc")
      local bean = UnmarshalBean(SJailDeliveryConfirmDesc, p.extroInfo)
      desc = string.format(textRes.PlayerPK.PlayerPrison[12], _G.GetStringFromOcts(bean.name))
    end
  elseif p.confirmType == ConfirmType.NORMAL_TEAN_INSTANCE or p.confirmType == ConfirmType.ELITE_TEAN_INSTANCE or p.confirmType == ConfirmType.HERO_TEAN_INSTANCE or p.confirmType == ConfirmType.NIGHTMARE_TEAN_INSTANCE or p.confirmType == ConfirmType.ACTIVITY_TEAN_INSTANCE then
    local SSynLeaderInstanceInfo = require("netio.protocol.mzm.gsp.instance.SSynLeaderInstanceInfo")
    local bean = UnmarshalBean(SSynLeaderInstanceInfo, p.extroInfo)
    local dungeonId = bean.teamInfo.instanceCfgid
    local processId = bean.teamInfo.toProcess
    local DungeonUtils = require("Main.Dungeon.DungeonUtils")
    local DungeonModule = require("Main.Dungeon.DungeonModule")
    local dungeonCfg = DungeonUtils.GetDungeonCfg(dungeonId)
    local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(dungeonId)
    title = string.format(textRes.Dungeon[41], dungeonCfg.name, dungeonCfg.level, textRes.Dungeon.TeamDungeonTypeName[teamDungeonCfg.type])
    if leaderId == GetMyRoleID() then
      desc = textRes.Dungeon[19]
    else
      local dungeonInfo = DungeonModule.Instance():GetTeamDungeonInfo(dungeonId)
      local mProcess = dungeonInfo and dungeonInfo.toProcess or 0
      if processId == mProcess then
        desc = textRes.Dungeon[20]
      else
        desc = string.format(textRes.Dungeon[21], processId, mProcess)
      end
    end
  end
  local cfg = TeamModule.GetConfirmCfg(p.confirmType)
  if cfg == nil then
    return
  end
  local defaultAgreeRoleIdStrs = {}
  for k, v in pairs(p.defaultAgreeRoleIds) do
    defaultAgreeRoleIdStrs[v:tostring()] = true
  end
  local confirmIds = {}
  for k, v in ipairs(p.acceptedMembers) do
    confirmIds[v:tostring()] = true
  end
  local myRoleId = GetMyRoleID()
  local myDefault = defaultAgreeRoleIdStrs[myRoleId:tostring()]
  if confirmIds[myRoleId:tostring()] then
  elseif myDefault then
    desc2 = string.format(textRes.activity[917], cfg.timeLimit)
  else
    desc2 = string.format(textRes.activity[916], cfg.timeLimit)
  end
  require("Main.Team.ui.DlgTeamConfirm").ShowAsk(title, desc, desc2, teamMembers, confirmIds, p.endTime, cfg.timeLimit, defaultAgreeRoleIdStrs)
  TeamModule.Instance().confirmSessionId = p.sessionid
  TeamModule.Instance().confirmType = p.confirmType
end
def.static("table").onSConfirmBro = function(p)
  local CConfirmRep = require("netio.protocol.mzm.gsp.confirm.CConfirmRep")
  if p.reply == CConfirmRep.REPLY_ACCEPT then
    require("Main.Team.ui.DlgTeamConfirm").Instance():SetRoleReady(p.memberId)
  else
    require("Main.Team.ui.DlgTeamConfirm").CloseAsk()
    local memberInfo = teamData:getMember(p.memberId)
    if memberInfo then
      Toast(string.format(textRes.activity[918], memberInfo.name))
    end
  end
end
def.static("table").onSConfirmErrBro = function(p)
  require("Main.Team.ui.DlgTeamConfirm").CloseAsk()
  Toast(textRes.activity[919])
end
def.method("boolean").Reply = function(self, agree)
  if self.confirmType > 0 and self.confirmSessionId then
    local CConfirmRep = require("netio.protocol.mzm.gsp.confirm.CConfirmRep")
    if agree then
      gmodule.network.sendProtocol(CConfirmRep.new(self.confirmType, self.confirmSessionId, CConfirmRep.REPLY_ACCEPT))
    else
      gmodule.network.sendProtocol(CConfirmRep.new(self.confirmType, self.confirmSessionId, CConfirmRep.REPLY_REFUSE))
    end
  end
end
def.static("number", "=>", "table").GetConfirmCfg = function(confirmType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TEAM_CONFIRM, confirmType)
  if record == nil then
    warn("GetConfirmCfg nil", confirmType)
    return nil
  end
  local cfg = {}
  cfg.timeLimit = record:GetIntValue("timeLimit")
  cfg.defaultRefuse = record:GetCharValue("defaultRefuse") ~= 0
  return cfg
end
TeamModule.Commit()
return TeamModule
