local netteamwar = {}
function netteamwar.requestTeamWar(i_mapid, i_catchid, i_super)
  NetSend({
    i_mapid = i_mapid,
    i_catchid = i_catchid,
    i_super = i_super
  }, "teamwar", "P1")
end
function netteamwar.requestQieCuo(i_playerid)
  NetSend({i_playerid = i_playerid}, "teamwar", "P2")
end
function netteamwar.requestZhuaguiWar(taskid)
  NetSend({taskid = taskid}, "teamwar", "P3")
end
function netteamwar.startDayantaWar()
  NetSend({}, "teamwar", "P4")
end
function netteamwar.enterDayantaWar(i_layer)
  NetSend({i_l = i_layer}, "teamwar", "P5")
end
function netteamwar.starTiantingWar(missionId, i_idx)
  NetSend({taskid = missionId, bossid = i_idx}, "teamwar", "P6")
end
function netteamwar.exitDayanta()
  NetSend({}, "teamwar", "P7")
end
function netteamwar.requestGuiwangWar(taskId)
  NetSend({taskid = taskId}, "teamwar", "P8")
end
function netteamwar.requestBangPaiTotemWar(taskId)
  NetSend({taskid = taskId}, "teamwar", "P9")
end
function netteamwar.requestBangPaiChuMo(taskId)
  NetSend({taskid = taskId}, "teamwar", "P10")
end
function netteamwar.requestWatchWar(wpId)
  NetSend({i_wp = wpId}, "teamwar", "P11")
end
function netteamwar.requestBangPaiAnZhan(taskId)
  NetSend({taskid = taskId}, "teamwar", "P12")
end
function netteamwar.recordRoleHpAndMp(data)
  NetSend(data, "teamwar", "P13")
end
function netteamwar.requestQuitWatchWar(i_warid)
  print("netteamwar.requestQuitWatchWar", i_warid)
  local i_playerid = g_LocalPlayer:getPlayerId()
  NetSend({i_warid = i_warid, i_playerid = i_playerid}, "teamwar", "P14")
end
function netteamwar.requestDuanWuWar()
  print("netteamwar.requestDuanWuWar")
  NetSend({}, "teamwar", "P15")
end
function netteamwar.setAutoFightSetting(t_h, t_p)
  print("netteamwar.setAutoFightSetting")
  NetSend({t_h = t_h, t_p = t_p}, "teamwar", "P16")
end
function netteamwar.requestWatchPlayerWar(playerId, warId)
  NetSend({i_wp = playerId, i_warid = warId}, "teamwar", "P17")
end
function netteamwar.requestShanXianList()
  NetSend({}, "teamwar", "P18")
end
function netteamwar.saveToServerShanXianList(lst)
  NetSend({lst = lst}, "teamwar", "P19")
end
function netteamwar.startProtectChangE()
  NetSend({}, "teamwar", "P21")
end
function netteamwar.oneRoundAction(i_warid, i_playerid, i_round, i_roleid, i_pos, t_action)
  NetSend({
    i_warid = i_warid,
    i_playerid = i_playerid,
    i_round = i_round,
    i_roleid = i_roleid,
    i_pos = i_pos,
    t_action = t_action
  }, "teamwar", "P91")
end
function netteamwar.oneRoundFinishPlay(i_warid, i_round)
  local i_playerid = g_LocalPlayer:getPlayerId()
  NetSend({
    i_warid = i_warid,
    i_playerid = i_playerid,
    i_round = i_round
  }, "teamwar", "P92")
end
function netteamwar.quitWatchWar(i_warid)
  print("netteamwar.quitWatchWar", i_warid)
  local i_playerid = g_LocalPlayer:getPlayerId()
  NetSend({i_warid = i_warid, i_playerid = i_playerid}, "teamwar", "P93")
end
function netteamwar.requestXiuLuoWar(taskid)
  NetSend({taskid = taskid}, "teamwar", "P20")
end
return netteamwar
