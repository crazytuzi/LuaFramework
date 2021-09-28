local netteamwar = {}
function netteamwar.quickTeamWar_S(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  QuitWarSceneAndBackToPreScene()
end
function netteamwar.dayantaAllCmp(param, ptc_main, ptc_sub)
  activity.dayanta:allComplete()
end
function netteamwar.ResetHpAndMp(param, ptc_main, ptc_sub)
  local heroIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
  for _, rid in pairs(heroIds) do
    g_LocalPlayer:SetRoleInitHpAndMp(rid, nil, nil)
  end
  local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  for _, rid in pairs(petIds) do
    g_LocalPlayer:SetRoleInitHpAndMp(rid, nil, nil)
  end
end
function netteamwar.SetPlayerInitHpAndMp(param, ptc_main, ptc_sub)
  local pid = param.i_p
  local rid = param.i_r
  local hp = param.i_hp
  local mp = param.i_mp
  g_LocalPlayer:SetRoleInitHpAndMp(rid, hp, mp)
end
function netteamwar.SerTellClientToQuitWatching(param, ptc_main, ptc_sub)
  local wid = param.i_warid
  if g_WarScene ~= nil and g_WarScene:getIsWatching() and wid == g_WarScene:getWarID() then
    QuitWarSceneAndBackToPreScene()
  end
end
function netteamwar.showPetShanXianList(param, ptc_main, ptc_sub)
  if param then
    ShowPetListZhiYuanDlg(param.lst)
  end
end
function netteamwar.startTeamWar(param, ptc_main, ptc_sub)
  print("netteamwar.startTeamWar:", param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local warType = param.i_wartype
  local attackList = param.t_attack
  local defendList = param.t_defend
  local baseData = param.t_BaseWar
  local warTime = param.i_warTime
  StartWarWithBaseInfo(warID, warType, baseData, attackList, defendList, warTime, false)
end
function netteamwar.oneRoundTeamWarSeq(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local round = param.i_round
  local warSeq = param.t_WarSeq
  local endWarData = param.t_endWarData
  local warTime = param.i_warTime
  setRoundWarSeqList(warID, round, warSeq, endWarData, warTime, false)
end
function netteamwar.startTeamWar_ReConnect(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local warType = param.i_wartype
  local attackList = param.t_attack
  local defendList = param.t_defend
  local baseData = param.t_BaseWar
  local warTime = param.i_warTime
  StartWarWithBaseInfo(warID, warType, baseData, attackList, defendList, warTime, true)
end
function netteamwar.oneRoundTeamWarSeq_ReConnect(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local round = param.i_round
  local warSeq = param.t_WarSeq
  local endWarData = param.t_endWarData
  local warTime = param.i_warTime
  setRoundWarSeqList(warID, round, warSeq, endWarData, warTime, true)
end
function netteamwar.startOneRound(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local round = param.i_round
  local opData = param.i_opData
  setStartOneRound(warID, round, opData)
end
function netteamwar.setWarPosState(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local stateTable = param.t_s
  for _, data in pairs(stateTable) do
    local pos = data.i_p
    local state = data.i_t
    setWarRoleState(warID, pos, state)
  end
end
function netteamwar.quickTeamWar_W(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local playerID = param.i_playerid
  QuitWarSceneAndBackToPreScene()
end
function netteamwar.startWatchWar(param, ptc_main, ptc_sub)
  print("netteamwar.startWatchWar:", param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local warType = param.i_wartype
  local attackList = param.t_attack
  local defendList = param.t_defend
  local baseData = param.t_BaseWar
  local warTime = param.i_warTime
  local watPlayerId = param.i_wp
  StartWarWithBaseInfo(warID, warType, baseData, attackList, defendList, warTime, true, watPlayerId)
end
function netteamwar.setRoundDataForWatchWar(param, ptc_main, ptc_sub)
  print("netteamwar.setRoundDataForWatchWar:", param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local round = param.i_round
  local warSeq = param.t_WarSeq
  local endWarData = param.t_endWarData
  local warTime = param.i_warTime
  setRoundWarSeqList(warID, round, warSeq, endWarData, warTime, true)
end
function netteamwar.onePlayerEnterWatchWar(param, ptc_main, ptc_sub)
  print("netteamwar.onePlayerEnterWatchWar:", param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local playerId = param.i_playerid
  local watcherData = param.i_watcherData
  if g_LocalPlayer and g_LocalPlayer:getPlayerId() == playerId then
    OnOnePlayerEnterWatchWar(warID, watcherData)
  end
end
function netteamwar.onePlayerQuitWatchWar(param, ptc_main, ptc_sub)
  print("netteamwar.onePlayerQuitWatchWar:", param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local playerId = param.i_playerid
  local watcherId = param.i_watcherId
  if g_LocalPlayer and g_LocalPlayer:getPlayerId() == playerId then
    OnOnePlayerQuitWatchWar(warID, watcherId)
  end
end
return netteamwar
