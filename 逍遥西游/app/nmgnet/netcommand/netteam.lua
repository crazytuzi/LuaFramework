local netteam = {}
function netteam.playerTeamInfo(param, ptc_main, ptc_sub)
  print("netteam.playerTeamInfo:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local teamid = param.i_teamid
  local isCaptain = param.i_captain
  local state = param.i_state
  local online = param.st
  g_TeamMgr:reciveTeamInfo(pid, teamid, isCaptain, state, online)
end
function netteam.receiveTeamInvite(param, ptc_main, ptc_sub)
  print("netteam.receiveTeamInvite:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local name = CheckStringIsLegal(param.i_name, true, REPLACECHAR_FOR_INVALIDNAME)
  local zs = param.i_zs
  local level = param.i_level
  g_MakeTeamNotice.MakeTeamNotice_Invite(pid, name, zs, level)
end
function netteam.receiveCaptainRequest(param, ptc_main, ptc_sub)
  print("netteam.receiveCaptainRequest:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local name = CheckStringIsLegal(param.i_name, true, REPLACECHAR_FOR_INVALIDNAME)
  local zs = param.i_zs
  local level = param.i_level
  g_MakeTeamNotice.MakeTeamNotice_CaptainRequest(pid, name, zs, level)
end
function netteam.addPlayerRequest(param, ptc_main, ptc_sub)
  print("netteam.addPlayerRequest:", param, ptc_main, ptc_sub)
  local ls = param.t_ls
  g_TeamMgr:addJoinRequest(ls)
end
function netteam.delPlayerRequest(param, ptc_main, ptc_sub)
  print("netteam.delPlayerRequest:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  g_TeamMgr:delJoinRequest(pid)
end
function netteam.receiveCallBackTeam(param, ptc_main, ptc_sub)
  print("netteam.receiveCallBackTeam:", param, ptc_main, ptc_sub)
  g_MakeTeamNotice.MakeTeamNotice_CallBackTeam(param)
end
function netteam.updatePromulgateTeam(param, ptc_main, ptc_sub)
  print("netteam.updatePromulgateTeam:", param, ptc_main, ptc_sub)
  param.i_cname = CheckStringIsLegal(param.i_cname, true, REPLACECHAR_FOR_INVALIDNAME)
  g_TeamMgr:updatePromulgateTeam(param.i_teamid, param)
end
function netteam.deletePromulgateTeam(param, ptc_main, ptc_sub)
  print("netteam.deletePromulgateTeam:", param, ptc_main, ptc_sub)
  g_TeamMgr:deletePromulgateTeam(param.i_teamid)
end
function netteam.startUpdatePromulgateTeam(param, ptc_main, ptc_sub)
  print("netteam.startUpdatePromulgateTeam:", param, ptc_main, ptc_sub)
  g_TeamMgr:startUpdatePromulgateTeam()
end
function netteam.endUpdatePromulgateTeam(param, ptc_main, ptc_sub)
  print("netteam.endUpdatePromulgateTeam:", param, ptc_main, ptc_sub)
  g_TeamMgr:endUpdatePromulgateTeam()
end
function netteam.syncTalkIdBeforeWar(param, ptc_main, ptc_sub)
  print("netteam.syncTalkIdBeforeWar:", param, ptc_main, ptc_sub)
  if param then
    g_MissionMgr:Server_SyncTalkIdBeforeWar(param.i_mid, param.i_pro)
  end
end
function netteam.newPromulgateTeam(param, ptc_main, ptc_sub)
  print("netteam.newPromulgateTeam:", param, ptc_main, ptc_sub)
  local teamId = param.i_teamid
  local num = param.i_num
  local cLevel = param.i_clevel
  local targetId = param.i_target
  local cName = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  local zs = param.i_rbnum
  local taskId = param.i_tid
  g_MessageMgr:newPromulgateTeam(teamId, num, cName, zs, cLevel, targetId, taskId, false)
end
function netteam.BackToNewTeam(param, ptc_main, ptc_sub)
  print("netteam.BackToNewTeam:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local name = CheckStringIsLegal(param.i_name, true, REPLACECHAR_FOR_INVALIDNAME)
  local zs = param.i_zs
  local level = param.i_level
  g_MakeTeamNotice.MakeTeamNotice_BackToNewTeam(pid, name, zs, level)
end
function netteam.SetAcceptAutoMatchFlag(param, ptc_main, ptc_sub)
  print("netteam.SetAcceptAutoMatchFlag:", param, ptc_main, ptc_sub)
  g_TeamMgr:SetAcceptAutoMatchFlag(param.i_m)
end
function netteam.SetAutoMatchState(param, ptc_main, ptc_sub)
  print("netteam.SetAutoMatchState:", param, ptc_main, ptc_sub)
  g_TeamMgr:SetAutoMatchState(param.i_m, param.i_target)
end
function netteam.VerifyTeamInfo(param, ptc_main, ptc_sub)
  print("netteam.VerifyTeamInfo:", param, ptc_main, ptc_sub)
  g_TeamMgr:VerifyTeamInfo(param.i_teamid, param.t_ls)
end
return netteam
