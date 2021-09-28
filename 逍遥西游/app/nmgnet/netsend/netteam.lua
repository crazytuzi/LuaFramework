local netteam = {}
function netteam.invitePlayer(i_pid)
  NetSend({i_pid = i_pid}, S2C_TEAM, "P1")
end
function netteam.agreeInviteToTeam(i_pid)
  NetSend({i_pid = i_pid}, S2C_TEAM, "P2")
end
function netteam.refuseInviteToTeam(i_pid)
  NetSend({i_pid = i_pid}, S2C_TEAM, "P3")
end
function netteam.applyToTeam(i_teamid)
  NetSend({i_teamid = i_teamid}, S2C_TEAM, "P4")
end
function netteam.makeTeamCaptain(i_pid)
  NetSend({i_pid = i_pid}, S2C_TEAM, "P5")
end
function netteam.kickOutPlayer(i_pid)
  NetSend({i_pid = i_pid}, S2C_TEAM, "P6")
end
function netteam.dismissTeam()
  NetSend({}, S2C_TEAM, "P7")
end
function netteam.requestCaptain()
  NetSend({}, S2C_TEAM, "P8")
end
function netteam.quitTeam()
  NetSend({}, S2C_TEAM, "P9")
end
function netteam.agreeRequest(i_pid)
  NetSend({i_pid = i_pid}, S2C_TEAM, "P10")
end
function netteam.tempLeaveTeam()
  NetSend({}, S2C_TEAM, "P11")
end
function netteam.comebackTeam(i_flag)
  NetSend({i_flag = i_flag}, S2C_TEAM, "P12")
end
function netteam.agreeCaptainRequest(i_pid)
  NetSend({i_pid = i_pid}, S2C_TEAM, "P13")
end
function netteam.callBackTeamPlayer(t_ls)
  NetSend({t_ls = t_ls}, S2C_TEAM, "P14")
end
function netteam.createTeam()
  NetSend({}, S2C_TEAM, "P15")
end
function netteam.promulgateTeam(i_target)
  NetSend({i_target = i_target}, S2C_TEAM, "P16")
end
function netteam.requestUpdatePromulgateTeam()
  NetSend({}, S2C_TEAM, "P17")
end
function netteam.stopUpdatePromulgateTeam()
  NetSend({}, S2C_TEAM, "P18")
end
function netteam.syncTalkIdBeforeWar(i_missionId, i_Pro)
  NetSend({i_mid = i_missionId, i_pro = i_Pro}, S2C_TEAM, "P19")
end
function netteam.syncTalkIdBeforeWar(i_m)
  NetSend({i_m = i_m}, S2C_TEAM, "P20")
end
function netteam.acceptAutoMatch(i_m)
  NetSend({i_m = i_m}, S2C_TEAM, "P20")
end
function netteam.requestAutoMatch(i_m, i_target)
  NetSend({i_m = i_m, i_target = i_target}, S2C_TEAM, "P21")
end
function netteam.requestBangPaiHelp(i_target)
  NetSend({i_target = i_target}, S2C_TEAM, "P22")
end
function netteam.requestVerifyTeamInfo(i_teamid)
  NetSend({i_teamid = i_teamid}, S2C_TEAM, "P23")
end
function netteam.deleteJoinRequest(pid)
  NetSend({pid = pid}, S2C_TEAM, "P24")
end
return netteam
