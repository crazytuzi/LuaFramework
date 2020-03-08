local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangTeamProtocol = Lplus.Class(MODULE_NAME)
local Cls = GangTeamProtocol
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.Gang.GangTeam
local def = GangTeamProtocol.define
local gangTeamData = require("Main.Gang.GangTeam.data.GangTeamData").Instance()
def.static().Init = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SCreateGangTeamBrd", Cls.OnSCreateGangTeamBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SChangeGangTeamNameBrd", Cls.OnSBrdTeamNameChg)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SAddGangTeamApplicantBrd", Cls.OnSAddGangTeamApplicantBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SRemoveGangTeamApplicantBrd", Cls.OnSRemoveGangTeamApplicantBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangTeamApplicants", Cls.OnSSyncGangTeamApplicants)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SJoinGangTeamRefusedNotify", Cls.OnSLeaderRefuseApply)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SAddGangTeamMemberBrd", Cls.OnSAddGangTeamMemberBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SInviteGangTeamTrs", Cls.OnSInviteGangTeamTrs)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SInviteGangTeamRefusedNotify", Cls.OnNotifyRefuseJoin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SChangeGangTeamLeaderBrd", Cls.OnBrocastTeamleaderChg)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SRemoveGangTeamMemberBrd", Cls.OnSLeaveGangTeamBrd)
end
def.static("string").sendCreateGangTeamReq = function(teamName)
  local p = require("netio.protocol.mzm.gsp.gang.CCreateGangTeamReq").new(teamName)
  gmodule.network.sendProtocol(p)
end
def.static("string").sendChgGangTeamName = function(name)
  local p = require("netio.protocol.mzm.gsp.gang.CChangeGangTeamNameReq").new(name)
  gmodule.network.sendProtocol(p)
end
def.static().sendAutoJoinGangTeamReq = function()
  local p = require("netio.protocol.mzm.gsp.gang.CAutoJoinGangTeamReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata").sendJoinGangTeamReq = function(teamId)
  local p = require("netio.protocol.mzm.gsp.gang.CJoinGangTeamReq").new(teamId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "boolean").sendJoinGangTeamRep = function(roleId, agree)
  local CJoinGangTeamRep = require("netio.protocol.mzm.gsp.gang.CJoinGangTeamRep")
  if agree then
    gmodule.network.sendProtocol(CJoinGangTeamRep.new(roleId, CJoinGangTeamRep.REPLY_AGREE))
  else
    gmodule.network.sendProtocol(CJoinGangTeamRep.new(roleId, CJoinGangTeamRep.REPLY_REFUSE))
  end
end
def.static("userdata").sendInviteGangTeamReq = function(roleId)
  local p = require("netio.protocol.mzm.gsp.gang.CInviteGangTeamReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "userdata", "boolean").sendInviteGangTeamRep = function(inviterRoleId, teamId, bAgree)
  local CInviteGangTeamRep = require("netio.protocol.mzm.gsp.gang.CInviteGangTeamRep")
  local reply = CInviteGangTeamRep.REPLY_REFUSE
  if bAgree then
    reply = CInviteGangTeamRep.REPLY_AGREE
  end
  local p = CInviteGangTeamRep.new(inviterRoleId, teamId, reply)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").sendChgTeamLeadership = function(newLeaderid)
  local p = require("netio.protocol.mzm.gsp.gang.CChangeGangTeamLeaderReq").new(newLeaderid)
  gmodule.network.sendProtocol(p)
end
def.static().sendLeaveGangTeamReq = function()
  local p = require("netio.protocol.mzm.gsp.gang.CLeaveGangTeamReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata").sendKickGangTeamMemberReq = function(roleId)
  local p = require("netio.protocol.mzm.gsp.gang.CKickGangTeamMemberReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSCreateGangTeamBrd = function(p)
  gangTeamData:AddNewTeam(p.team)
  local roleInfo = GangTeamMgr.GetGangRoleInfo(p.team.leaderid)
  if roleInfo == nil then
    return
  end
  if _G.GetHeroProp().id:eq(p.team.leaderid) then
    GangTeamMgr.SendGangAnno(roleInfo.name, p.team.name, p.team.teamid, 1)
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.NewTeamCreated, p.team)
end
def.static("table").OnSBrdTeamNameChg = function(p)
  gangTeamData:ChgGangTeamName(p.teamid, p.name)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamNameChg, {
    teamId = p.teamid,
    name = p.name
  })
end
def.static("table").OnSAddGangTeamApplicantBrd = function(p)
  gangTeamData:AddApplyeeFront(p.applicantid)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, {
    roleId = p.applicantid
  })
end
def.static("table").OnSRemoveGangTeamApplicantBrd = function(p)
  gangTeamData:RmvApplyee(p.applicantid)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, {
    roleId = p.applicantid
  })
end
def.static("table").OnSSyncGangTeamApplicants = function(p)
  for i = 1, #p.applicants do
    gangTeamData:AddApplyee(p.applicants[i])
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, {
    roleId = p.applicants[1]
  })
end
def.static("table").OnSLeaderRefuseApply = function(p)
  local roleInfo = GangTeamMgr.GetGangRoleInfo(p.leaderid)
  if roleInfo == nil then
    return
  end
  Toast(txtConst[35]:format(roleInfo.name))
end
def.static("table").OnNotifyRefuseJoin = function(p)
  local roleInfo = require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(p.invitee)
  if roleInfo then
    Toast(txtConst[21]:format(roleInfo.name))
  end
end
def.static("table").OnBrocastTeamleaderChg = function(p)
  local myTeam = gangTeamData:GetMyTeam()
  if myTeam and myTeam.teamid:eq(p.gang_teamid) then
    local myRoleId = _G.GetHeroProp().id
    if myTeam.leaderid:eq(myRoleId) then
      Toast(txtConst[43])
      gangTeamData:ClearApplierList()
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamRedDotChg, nil)
    elseif p.new_leader:eq(myRoleId) then
      Toast(txtConst[44])
    else
      Toast(txtConst[45])
    end
  end
  gangTeamData:ChgLeader(p.gang_teamid, p.new_leader)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamLeaderChg, {
    teamId = p.gang_teamid,
    leaderid = p.new_leader
  })
end
def.static("table").OnSAddGangTeamMemberBrd = function(p)
  gangTeamData:AddTeamMember(p.teamid, p.new_member)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.TeamMemberChg, {
    teamId = p.teamid,
    roleId = p.new_memberid
  })
end
def.static("table").OnSInviteGangTeamTrs = function(p)
  local roleInfo = GangTeamMgr.GetGangRoleInfo(p.inviter_id)
  local teamInfo = gangTeamData:GetTeamByTeamId(p.gang_teamid)
  if roleInfo == nil or teamInfo == nil then
    return
  end
  local content = txtConst[18]:format(roleInfo.name, teamInfo.name)
  CommonConfirmDlg.ShowConfirmCoundDown(txtConst[10], content, txtConst[19], txtConst[20], 0, 30, function(select)
    if select == 1 then
      Cls.sendInviteGangTeamRep(p.inviter_id, p.gang_teamid, true)
    else
      Cls.sendInviteGangTeamRep(p.inviter_id, p.gang_teamid, false)
    end
  end, nil)
end
def.static("table").OnSLeaveGangTeamBrd = function(p)
  gangTeamData:UpdateTeamMember(p.teamid, p.memberid, 0, 2)
  if p.memberid:eq(_G.GetHeroProp().id) then
    Toast(txtConst[39])
    gangTeamData:ClearApplierList()
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamRedDotChg, nil)
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.TeamMemberChg, {
    teamId = p.teamid,
    roleId = p.memberid
  })
end
def.static("table", "table", "=>", "boolean").OnGangTeamResult = function(p, args)
  warn("msg", p.result)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.gang.SGangNormalResult")
  if p.result == ERROR_CODE.CREATE_GANG_TEAM__NO_GANG or p.result == ERROR_CODE.JOIN_GANG_TEAM__NO_GANG or p.result == ERROR_CODE.JOIN_GANG_TEAM_REP__NO_GANG or p.result == ERROR_CODE.JOIN_GANG_TEAM_REP__NO_GANG or p.result == ERROR_CODE.INVITE_GANG_TEAM__NO_GANG or p.result == ERROR_CODE.INVITE_GANG_TEAM_REP__NO_GANG or p.result == ERROR_CODE.CHANGE_GANG_TEAM_LEADER__NO_GANG or p.result == ERROR_CODE.LEAVE_GANG_TEAM__NO_GANG or p.result == ERROR_CODE.KICK_GANG_TEAM_MEMBER__NO_GANG then
    Toast(txtConst[50])
    return true
  elseif p.result == ERROR_CODE.CREATE_GANG_TEAM__IN_TEAM or p.result == ERROR_CODE.JOIN_GANG_TEAM__IN_TEAM or p.result == ERROR_CODE.AUTO_JOIN_GANG_TEAM__IN_TEAM or p.result == ERROR_CODE.INVITE_GANG_TEAM_REP__IN_TEAM then
    Toast(txtConst[22])
    return true
  elseif p.result == ERROR_CODE.CREATE_GANG_TEAM__NAME_TOO_LONG or p.result == ERROR_CODE.CHANGE_GANG_TEAM_NAME__NAME_TOO_LONG then
    Toast(txtConst[51])
    return true
  elseif p.result == ERROR_CODE.CREATE_GANG_TEAM__NAME_ILLEGAL or p.result == ERROR_CODE.CHANGE_GANG_TEAM_NAME__NAME_ILLEGAL then
    Toast(txtConst[8])
    return true
  elseif p.result == ERROR_CODE.CHANGE_GANG_TEAM_NAME__NO_GANG then
    Toast(txtConst[50])
    return true
  elseif p.result == ERROR_CODE.CHANGE_GANG_TEAM_NAME__NOT_IN_TEAM or p.result == ERROR_CODE.JOIN_GANG_TEAM_REP__NOT_IN_TEAM or p.result == ERROR_CODE.INVITE_GANG_TEAM__NOT_IN_TEAM or p.result == ERROR_CODE.CHANGE_GANG_TEAM_LEADER__NOT_IN_TEAM or p.result == ERROR_CODE.LEAVE_GANG_TEAM__NOT_IN_TEAM then
    Toast(txtConst[52])
    return true
  elseif p.result == ERROR_CODE.CHANGE_GANG_TEAM_NAME__NOT_LEADER or p.result == ERROR_CODE.CHANGE_GANG_TEAM_LEADER__NOT_LEADER or p.result == ERROR_CODE.KICK_GANG_TEAM_MEMBER__NOT_LEADER then
    Toast(txtConst[53])
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM__TEAM_NOT_EXIST then
    Toast(txtConst[54])
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM__IN_APPLICANT_LIST then
    Toast(txtConst[42])
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM__TEAM_FULL or p.result == ERROR_CODE.INVITE_GANG_TEAM_REP__TEAM_FULL then
    Toast(txtConst[55])
    return true
  elseif p.result == ERROR_CODE.AUTO_JOIN_GANG_TEAM__SUCCEED then
    Toast(txtConst[38])
    return true
  elseif p.result == ERROR_CODE.AUTO_JOIN_GANG_TEAM__NO_GANG then
    Toast(txtConst[56])
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM__SUCCEED then
    Toast(txtConst[26])
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.ApplyJoinSuccesss, nil)
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM_REP__NOT_LEADER then
    Toast(txtConst[57])
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM_REP__NOT_IN_APPLY_LIST then
    Toast(txtConst[58])
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM_REP__TEAM_FULL then
    Toast(txtConst[59])
    return true
  elseif p.result == ERROR_CODE.JOIN_GANG_TEAM_REP__APPLICANT_NOT_IN_GANG then
    Toast(txtConst[60])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM__INVITEE_NOT_IN_GANG then
    Toast(txtConst[61])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM__INVITEE_IN_TEAM then
    Toast(txtConst[62])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM__INVITEE_OFFLINE then
    Toast(txtConst[63])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM__SUCCEED then
    Toast(txtConst[36])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM__ALREADY_INVITE then
    Toast(txtConst[37])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM_REP__TEAM_NOT_EXIST then
    Toast(txtConst[64])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM_REP__TIMEOUT then
    Toast(txtConst[65])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM_REP__INVITER_NOT_IN_GANG then
    Toast(txtConst[66])
    return true
  elseif p.result == ERROR_CODE.INVITE_GANG_TEAM_REP__INVITER_NOT_IN_TEAM then
    Toast(txtConst[67])
    return true
  elseif p.result == ERROR_CODE.CHANGE_GANG_TEAM_LEADER__NEW_LEADER_NOT_IN_TEAM then
    Toast(txtConst[68])
    return true
  elseif p.result == ERROR_CODE.CHANGE_GANG_TEAM_LEADER__NEW_LEADER_SELF then
    Toast(txtConst[69])
    return true
  elseif p.result == ERROR_CODE.KICK_GANG_TEAM_MEMBER__MEMBER_NOT_IN_TEAM then
    Toast(txtConst[70])
    return true
  elseif p.result == ERROR_CODE.CREATE_GANG_TEAM__COOL_DOWN then
    local sec = tonumber(args[1])
    Toast(txtConst[76]:format(sec))
    return true
  end
  return false
end
return GangTeamProtocol.Commit()
