function GetTeamPlayerNumLimit(targetId)
  if targetId == nil then
    return 5
  end
  local info = data_Promulgate[targetId]
  if info == nil then
    return 5
  end
  return info.limit or 5
end
local Define_JoinRequestEfftectTime = 60
local CD_InvitePlayer = 20
local CD_AgreeJoinRequest = 5
local CD_ApplyToJoinTeam = 10
local CD_RequestCaptain = 20
local CD_CallBack = 10
local CD_PromulgateTeam = 60
local CD_PromulgateTeamEffect = 180
local CD_RequestPromulgateInfo = 15
local TeamMgr = class(".TeamMgr", nil)
function TeamMgr:ctor()
  self.m_AllTeamInfo = {}
  self.m_TeamInfoCache = {}
  self.m_TeamMemberList = {}
  self.m_JoinRequest = {}
  self.m_PromulgateTeamInfo = {}
  self.m_LastInviteTime = {}
  self.m_LastJoinRequestTime = {}
  self.m_LastRequestCaptainTime = 0
  self.m_LastAgreeJoinRequestTime = {}
  self.m_LastCallBackTime = 0
  self.m_LastCheckJoinRequestTime = 0
  self.m_LastPromulgateTeamTime = 0
  self.m_PromulgateInfoCnt = 0
  self.m_IsUpdatingPromulgateInfo = false
  self.m_IsResetingData = false
  self.m_AcceptAutoMatchFlag = 1
  self.m_IsAutoMatching = 0
  self.m_IsAutoMatchingTarget = 0
  self.m_AutoAgreeCaptainRequest = 1
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_MapScene)
  self:ListenMessage(MsgID_OtherPlayer)
  self:ListenMessage(MsgID_ReConnect)
  self:ListenMessage(MsgID_Connect)
end
function TeamMgr:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MapScene_ChangedMap then
    if not g_DataMgr:getIsSendFinished() then
      return
    end
    local pid = arg[1]
    if g_LocalPlayer and pid == g_LocalPlayer:getPlayerId() then
      print("====>>> 收到本地玩家切换场景消息，切换到新的场景，所以需要删除本地组队的组队信息")
      local localTeamId = self:getLocalPlayerTeamId()
      local localTeamInfo = self.m_AllTeamInfo[localTeamId]
      self.m_AllTeamInfo = {}
      if localTeamInfo ~= nil then
        self.m_AllTeamInfo[localTeamId] = localTeamInfo
        local temp = {}
        for playerId, info in pairs(self.m_TeamInfoCache) do
          if info.teamId == localTeamId then
            temp[playerId] = info
          end
        end
        self.m_TeamInfoCache = {}
        self.m_TeamMemberList = {}
        for playerId, info in pairs(temp) do
          self:addToTeamInfoCache(playerId, info.teamId, info.isCaptain, info.state, info.online)
        end
      else
        self.m_TeamInfoCache = {}
        self.m_TeamMemberList = {}
      end
    else
      local mId = arg[2]
      local curMapId = g_MapMgr:getCurMapId()
      if mId ~= nil and curMapId ~= nil and mId ~= curMapId then
        print("deleteTeamInfoWhenPlayerHide-3", curMapId, g_MapMgr:getCurMapId())
        self:deleteTeamInfoWhenPlayerHide(pid)
      end
    end
  elseif msgSID == MsgID_OtherPlayer_AddNewPlayer then
    local pid = arg[1]
    self:checkNewPlayer(pid)
  elseif msgSID == MsgID_ReConnect_ReLogin then
    self:resetMgrData()
  elseif msgSID == MsgID_Connect_SendFinished and self.m_IsUpdatingPromulgateInfo then
    self:stopUpdatePromulgateTeam()
    self:requestUpdatePromulgateTeam()
  end
end
function TeamMgr:setAutoAgreeCaptainRequest(val)
  self.m_AutoAgreeCaptainRequest = val
  SendMessage(MsgID_Team_AutoAgreeCaptainRequest, self:getAutoAgreeCaptainRequest())
end
function TeamMgr:getAutoAgreeCaptainRequest()
  return self.m_AutoAgreeCaptainRequest ~= 0
end
function TeamMgr:getPlayerInfo(pid)
  local role = self:getPlayerMainHero(pid)
  if role then
    local info = {}
    info.name = role:getProperty(PROPERTY_NAME)
    info.rtype = role:getTypeId()
    info.level = role:getProperty(PROPERTY_ROLELEVEL)
    info.zs = role:getProperty(PROPERTY_ZHUANSHENG)
    return info
  end
  return nil
end
function TeamMgr:getPlayerMainHero(pid)
  local player = g_DataMgr:getPlayer(pid)
  if player == nil then
    return nil
  end
  local role = player:getMainHero()
  return role
end
function TeamMgr:getPlayerName(pid)
  local player = g_DataMgr:getPlayer(pid)
  if player == nil then
    return ""
  end
  local role = player:getMainHero()
  if role == nil then
    return ""
  end
  return role:getProperty(PROPERTY_NAME)
end
function TeamMgr:getPlayerZhuanSheng(pid)
  local player = g_DataMgr:getPlayer(pid)
  if player == nil then
    return 0
  end
  local role = player:getMainHero()
  if role == nil then
    return 0
  end
  return role:getProperty(PROPERTY_ZHUANSHENG)
end
function TeamMgr:getTeamInfo(teamId)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    teamInfo = {}
  end
  return DeepCopyTable(teamInfo)
end
function TeamMgr:getTeamPlayerNum(teamId)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    return 0
  else
    return #teamInfo
  end
end
function TeamMgr:getTeamCaptain(teamId)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    return nil
  end
  for _, playerId in pairs(teamInfo) do
    local role = self:getPlayerMainHero(playerId)
    if role and role:getProperty(PROPERTY_ISCAPTAIN) == TEAMCAPTAIN_YES then
      return playerId
    end
  end
  return nil
end
function TeamMgr:getTeamCaptainName(teamId)
  local captainId = self:getTeamCaptain(teamId)
  if captainId == nil then
    return ""
  else
    return self:getPlayerName(captainId)
  end
end
function TeamMgr:getPlayerTeamId(pid)
  if g_LocalPlayer == nil then
    return 0
  end
  if pid == nil then
    pid = g_LocalPlayer:getPlayerId()
  end
  local role = self:getPlayerMainHero(pid)
  if role == nil then
    return 0
  else
    return role:getProperty(PROPERTY_TEAMID) or 0
  end
end
function TeamMgr:getLocalPlayerTeamId()
  if g_LocalPlayer == nil then
    return 0
  end
  local localPlayerId = g_LocalPlayer:getPlayerId()
  return self:getPlayerTeamId(localPlayerId)
end
function TeamMgr:getPlayerTeamState(pid)
  if g_LocalPlayer == nil then
    return TEAMSTATE_FOLLOW
  end
  if pid == nil then
    pid = g_LocalPlayer:getPlayerId()
  end
  local role = self:getPlayerMainHero(pid)
  if role == nil then
    return TEAMSTATE_LEAVE
  else
    return role:getProperty(PROPERTY_TEAMSTATE)
  end
end
function TeamMgr:getLocalPlayerTeamState()
  if g_LocalPlayer == nil then
    return TEAMSTATE_FOLLOW
  end
  local localPlayerId = g_LocalPlayer:getPlayerId()
  return self:getPlayerTeamState(localPlayerId)
end
function TeamMgr:IsPlayerOfTeam(pid, teamId)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    return false
  else
    for _, playerId in pairs(teamInfo) do
      if pid == playerId then
        return true
      end
    end
    return false
  end
end
function TeamMgr:IsPlayerOfLocalPlayerTeam(pid)
  local teamId = self:getLocalPlayerTeamId()
  if teamId == 0 then
    return false
  end
  return self:IsPlayerOfTeam(pid, teamId)
end
function TeamMgr:getPlayerIsCaptainOfLocalPlaerTeam(pid)
  local localPlayerTeamId = self:getLocalPlayerTeamId()
  if localPlayerTeamId == nil or localPlayerTeamId == 0 then
    return false
  end
  local mainHero = self:getPlayerMainHero(pid)
  if mainHero == nil then
    return false
  end
  local teamId = mainHero:getProperty(PROPERTY_TEAMID)
  if teamId ~= localPlayerTeamId then
    return false
  end
  local isCaptain = mainHero:getProperty(PROPERTY_ISCAPTAIN)
  return isCaptain == TEAMCAPTAIN_YES
end
function TeamMgr:getPlayerIsOtherFollowTeamer(pid)
  local mainHero = self:getPlayerMainHero(pid)
  if mainHero == nil then
    return false
  end
  local teamId = mainHero:getProperty(PROPERTY_TEAMID)
  if teamId == 0 then
    return false
  end
  local isCaptain = mainHero:getProperty(PROPERTY_ISCAPTAIN)
  if isCaptain == TEAMCAPTAIN_YES then
    return false
  end
  if mainHero:getProperty(PROPERTY_TEAMSTATE) ~= TEAMSTATE_FOLLOW then
    return false
  end
  local localPlayerTeamId = self:getLocalPlayerTeamId()
  if teamId == localPlayerTeamId then
    return false
  end
  return true
end
function TeamMgr:localPlayerIsCaptain()
  if g_LocalPlayer == nil then
    return false
  end
  localPlayerId = g_LocalPlayer:getPlayerId()
  return self:getPlayerIsCaptain(localPlayerId)
end
function TeamMgr:getPlayerIsCaptain(pid)
  local mainHero = self:getPlayerMainHero(pid)
  if mainHero == nil then
    return false
  end
  local teamId = mainHero:getProperty(PROPERTY_TEAMID)
  if teamId == 0 then
    return false
  end
  local isCaptain = mainHero:getProperty(PROPERTY_ISCAPTAIN)
  return isCaptain == TEAMCAPTAIN_YES
end
function TeamMgr:getLocalPlayerTeamInfo()
  if g_LocalPlayer == nil then
    return nil, nil
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local teamId = mainHero:getProperty(PROPERTY_TEAMID)
  if teamId == 0 then
    return nil, nil
  else
    return teamId, DeepCopyTable(self.m_AllTeamInfo[teamId])
  end
end
function TeamMgr:getTeamIsFull(teamId)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    return false
  end
  return #teamInfo >= GetTeamPlayerNumLimit()
end
function TeamMgr:checkNewPlayer(pid)
  local info = self.m_TeamInfoCache[pid]
  print("===>>checkNewPlayer:", pid, info)
  if info == nil then
    return
  end
  self:reciveTeamInfo(pid, info.teamId, info.isCaptain, info.state, info.online)
end
function TeamMgr:checkTeamMemberInfo(teamId)
  local teamInfo = self.m_TeamMemberList[teamId]
  print("checkTeamMemberInfo", teamId, teamInfo)
  if teamInfo ~= nil then
    local localPlayerTeamId = self:getLocalPlayerTeamId()
    for _, playerId in pairs(teamInfo) do
      print("getPlayer", playerId, g_DataMgr:getPlayer(playerId))
      if g_DataMgr:getPlayer(playerId) == nil then
        local info = self.m_TeamInfoCache[playerId]
        print("---->>self.m_TeamInfoCache:", playerId, info)
        if info and info.isCaptain ~= TEAMCAPTAIN_YES then
          print("info.state =>:", info.state, teamId, localPlayerTeamId)
          if info.state == TEAMSTATE_FOLLOW or teamId == localPlayerTeamId then
            netsend.netmap.reqPlayerInfo(playerId)
          end
        end
      end
    end
  end
end
function TeamMgr:checkPlayerInfoExistWhenCaptainShow(pid)
  print("checkPlayerInfoExistWhenCaptainShow:", pid)
  local info = self.m_TeamInfoCache[pid]
  if info == nil then
    return
  end
  print("checkPlayerInfoExistWhenCaptainShow......2", info.isCaptain, info.teamId)
  if info.isCaptain == TEAMCAPTAIN_YES then
    self:checkTeamMemberInfo(info.teamId)
  end
end
function TeamMgr:deleteTeamInfoWhenPlayerHide(pid)
  print("deleteTeamInfoWhenPlayerHide", pid)
  if g_LocalPlayer == nil then
    return
  end
  if pid == g_LocalPlayer:getPlayerId() then
    return
  end
  if g_CMainMenuHandler then
    g_CMainMenuHandler:onCancelSelectPlayerOfMap(pid)
  end
  local info = self.m_TeamInfoCache[pid]
  print("deleteTeamInfoWhenPlayerHide....2", pid, info)
  if info == nil then
    return
  end
  local teamId = info.teamId
  print("deleteTeamInfoWhenPlayerHide....3", pid, teamId)
  if teamId ~= 0 and teamId == self:getLocalPlayerTeamId() then
    return
  end
  self:deleteTeamInfoOfPlayer(pid, teamId)
end
function TeamMgr:deleteTeamInfoOfPlayer(pid, teamId)
  print("----->>>>玩家离开视野，删除其组队消息", pid)
  local role = self:getPlayerMainHero(pid)
  if role then
    role:setProperty(PROPERTY_TEAMID, 0)
    role:setProperty(PROPERTY_ISCAPTAIN, 0)
    role:setProperty(PROPERTY_TEAMSTATE, 0)
    role:setProperty(PROPERTY_TEAMSTATUS, 0)
  end
  self:playerLeaveTeam(pid, teamId)
  self:deleteFromTeamInfoCache(pid)
end
function TeamMgr:checkPlayerInfoExistOfLocalTeam(teamId)
  local teamInfo = self.m_TeamMemberList[teamId]
  if teamInfo then
    for _, playerId in pairs(teamInfo) do
      if g_DataMgr:getPlayer(playerId) == nil then
        netsend.netmap.reqPlayerInfo(playerId)
      end
    end
  end
end
function TeamMgr:playerJoinTeam(pid, teamId, isCaptain)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    teamInfo = {}
    teamInfo[#teamInfo + 1] = pid
    self.m_AllTeamInfo[teamId] = teamInfo
  else
    for _, playerId in pairs(teamInfo) do
      if playerId == pid then
        return
      end
    end
    teamInfo[#teamInfo + 1] = pid
  end
  print("--->>playerJoinTeam:", pid, teamId, isCaptain, #teamInfo)
  if isCaptain == TEAMCAPTAIN_YES then
    print("--->>playerJoinTeam 新建组队:", MsgID_Team_NewTeam, teamId, pid)
    SendMessage(MsgID_Team_NewTeam, teamId, pid)
  elseif self:getTeamCaptain(teamId) ~= nil then
    print("--->>playerJoinTeam 队员进队:", MsgID_Team_PlayerJoinTeam, teamId, pid)
    SendMessage(MsgID_Team_PlayerJoinTeam, teamId, pid)
  end
  local localPlayerId = g_LocalPlayer:getPlayerId()
  if pid ~= localPlayerId and self:getPlayerTeamId(localPlayerId) == teamId then
    self:delJoinRequest(pid)
  end
  self.m_LastInviteTime[pid] = nil
  if pid == localPlayerId then
    self.m_LastJoinRequestTime = {}
    SendMessage(MsgID_Team_ClearPromulgateTeam)
  end
end
function TeamMgr:playerLeaveTeam(pid, teamId, pname)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    return
  end
  for index, playerId in pairs(teamInfo) do
    if playerId == pid then
      table.remove(teamInfo, index)
      break
    end
  end
  if pid == g_LocalPlayer:getPlayerId() then
    self:clearJoinRequest()
    self.m_LastPromulgateTeamTime = 0
  end
  if #teamInfo <= 0 then
    self.m_AllTeamInfo[teamId] = nil
    SendMessage(MsgID_Team_PlayerLeaveTeam, teamId, pid)
    SendMessage(MsgID_Team_DismissTeam, teamId)
  else
    SendMessage(MsgID_Team_PlayerLeaveTeam, teamId, pid)
  end
  if teamId == self:getLocalPlayerTeamId() and pname ~= nil and not self.m_IsResetingData then
    local zs = self:getPlayerZhuanSheng(pid)
    local color = NameColor_MainHero[zs] or NameColor_MainHero[0]
    ShowNotifyTips(string.format("#<r:%d,g:%d,b:%d>%s# 离开了队伍", color.r, color.g, color.b, pname))
  end
  if pid == g_LocalPlayer:getPlayerId() then
    print("本地玩家离队时，根据视野删除前队伍里队友的组队消息-->")
    teamInfo = DeepCopyTable(teamInfo)
    dump(teamInfo, "teamInfo")
    for _, playerId in pairs(teamInfo) do
      g_MapMgr:DetectInvalidRoleInMap(playerId)
    end
  end
end
function TeamMgr:checkTeamCaptain(teamId, captainId, captainName)
  local teamInfo = self.m_AllTeamInfo[teamId]
  if teamInfo == nil then
    return
  end
  for _, pid in pairs(teamInfo) do
    if pid ~= captainId then
      local mainHero = self:getPlayerMainHero(pid)
      if mainHero and mainHero:getProperty(PROPERTY_ISCAPTAIN) == TEAMCAPTAIN_YES then
        mainHero:setProperty(PROPERTY_ISCAPTAIN, TEAMCAPTAIN_NO)
        SendMessage(MsgID_Team_SetCaptain, teamId, pid, TEAMCAPTAIN_NO)
        SendMessage(MsgID_Team_CaptainChanged, teamId, captainId)
        if pid == g_LocalPlayer:getPlayerId() then
          self:clearJoinRequest()
        end
      end
    end
  end
end
function TeamMgr:addToTeamInfoCache(pid, teamId, isCaptain, state, online)
  self.m_TeamInfoCache[pid] = {
    teamId = teamId,
    isCaptain = isCaptain,
    state = state,
    online = online
  }
  local tList = self.m_TeamMemberList[teamId]
  if tList == nil then
    tList = {}
    self.m_TeamMemberList[teamId] = tList
  end
  tList[#tList + 1] = pid
end
function TeamMgr:deleteFromTeamInfoCache(pid)
  local tInfo = self.m_TeamInfoCache[pid]
  if tInfo ~= nil then
    self.m_TeamInfoCache[pid] = nil
    local tId = tInfo.teamId
    local tList = self.m_TeamMemberList[tId]
    if tList then
      for idx, thePid in pairs(tList) do
        if thePid == pid then
          table.remove(tList, idx)
          if #tList <= 0 then
            self.m_TeamInfoCache[tId] = nil
          end
          break
        end
      end
    end
  end
end
function TeamMgr:reciveTeamInfo(pid, teamId, isCaptain, state, online)
  print("--->>收到新的组队信息", pid, teamId, isCaptain, state, online)
  if teamId ~= nil and teamId ~= 0 then
    self:deleteFromTeamInfoCache(pid)
    self:addToTeamInfoCache(pid, teamId, isCaptain, state, online)
  else
    self:deleteFromTeamInfoCache(pid)
  end
  local role = self:getPlayerMainHero(pid)
  print("reciveTeamInfo..1", role)
  if role == nil then
    if teamId ~= nil and teamId ~= 0 then
      if teamId == self:getLocalPlayerTeamId() then
        print("本地玩家同一个队伍，则查询该玩家信息")
        netsend.netmap.reqPlayerInfo(pid)
      elseif isCaptain ~= TEAMCAPTAIN_YES and state == TEAMSTATE_FOLLOW then
        local captainId = self:getTeamCaptain(teamId)
        print("captainId", captainId)
        if captainId ~= nil then
          local captainRole = g_DataMgr:getPlayer(captainId)
          print("captainRole", captainRole)
          if captainRole then
            print("captainRole getHide:", captainRole:getHide())
          end
          if captainRole ~= nil and not captainRole:getHide() then
            print("没有玩家信息时，主动查询一次", pid)
            netsend.netmap.reqPlayerInfo(pid)
          end
        end
      end
    end
    return
  end
  print("reciveTeamInfo..2", pid, teamId, isCaptain, state)
  local oldTeamId = role:getProperty(PROPERTY_TEAMID)
  local oldTeamCaptain
  if isCaptain == TEAMCAPTAIN_YES then
    oldTeamCaptain = self:getTeamCaptain(teamId)
  end
  if teamId ~= nil then
    role:setProperty(PROPERTY_TEAMID, teamId)
    if teamId == 0 then
      if isCaptain == nil then
        isCaptain = TEAMCAPTAIN_NO
      end
      if state == nil then
        state = TEAMSTATE_FOLLOW
      end
    end
  end
  if isCaptain ~= nil then
    role:setProperty(PROPERTY_ISCAPTAIN, isCaptain)
  end
  if state ~= nil then
    role:setProperty(PROPERTY_TEAMSTATE, state)
  end
  if online ~= nil then
    role:setProperty(PROPERTY_TEAMSTATUS, online)
  end
  if teamId ~= nil then
    print("--->>oldTeamId:", oldTeamId)
    if teamId == 0 then
      if oldTeamId ~= 0 then
        print("--->>准备离队:", pid, oldTeamId)
        self:playerLeaveTeam(pid, oldTeamId, role:getProperty(PROPERTY_NAME))
      end
    elseif teamId ~= oldTeamId then
      if oldTeamId ~= 0 then
        print("--->>准备离开旧的队伍:", pid, oldTeamId)
        self:playerLeaveTeam(pid, oldTeamId, role:getProperty(PROPERTY_NAME))
      end
      print("--->>准备进入新的的队伍:", pid, teamId, isCaptain)
      self:playerJoinTeam(pid, teamId, isCaptain)
    elseif isCaptain == TEAMCAPTAIN_YES and oldTeamCaptain == nil then
      print("--->>>如果是在已经有组队信息的情况下，旧的队伍没有队长，则需要补发一个新建队伍的消息", teamId, pid)
      SendMessage(MsgID_Team_NewTeam, teamId, pid)
    end
  end
  if isCaptain ~= nil then
    if isCaptain == TEAMCAPTAIN_YES then
      self:checkTeamCaptain(teamId, pid, role:getProperty(PROPERTY_NAME))
      if pid == g_LocalPlayer:getPlayerId() then
        self.m_LastRequestCaptainTime = 0
      end
    elseif pid == g_LocalPlayer:getPlayerId() then
      self:clearJoinRequest()
    end
    SendMessage(MsgID_Team_SetCaptain, teamId, pid, isCaptain)
  end
  if state ~= nil then
    if state == TEAMSTATE_FOLLOW and teamId == self:getLocalPlayerTeamId() then
      self.m_LastCallBackTime = 0
    end
    SendMessage(MsgID_Team_TeamState, teamId, pid, state)
  end
  if online ~= nil then
    SendMessage(MsgID_Team_PlayerOnline, teamId, pid, online)
  end
  if teamId ~= nil and teamId ~= 0 then
    local playerList = self.m_AllTeamInfo[teamId]
    if playerList ~= nil then
      local isFull = #playerList >= GetTeamPlayerNumLimit()
      SendMessage(MsgID_Team_TeamIsFull, teamId, isFull)
    end
  end
  if teamId ~= nil and teamId ~= 0 then
    if pid == g_LocalPlayer:getPlayerId() then
      print("本地玩家进队时需要查询本地玩家队伍里其他还没有信息的玩家")
      self:checkPlayerInfoExistOfLocalTeam(teamId)
    elseif isCaptain == TEAMCAPTAIN_YES then
      local player = g_DataMgr:getPlayer(pid)
      print("收到队长的玩家信息", pid, player)
      if player and not player:getHide() then
        self:checkTeamMemberInfo(teamId)
      end
    end
  end
  if pid == g_LocalPlayer:getPlayerId() then
    local tempData = self.m_PromulgateTeamInfo[teamId]
    if tempData and tempData.i_num ~= nil and tempData.i_cname ~= nil and tempData.i_czs ~= nil and tempData.i_clevel ~= nil and tempData.i_target ~= nil then
      g_MessageMgr:newPromulgateTeam(teamId, tempData.i_num, tempData.i_cname, tempData.i_czs, tempData.i_clevel, tempData.i_target, tempData.i_tid, true)
    end
  end
  if teamId ~= nil and teamId ~= 0 then
    local teamInfo = self.m_AllTeamInfo[teamId]
    if teamInfo ~= nil and #teamInfo > GetTeamPlayerNumLimit() then
      print("------->>>组队信息发生异常，人数超过上限，需要校验:", teamId, #teamInfo)
      netsend.netteam.requestVerifyTeamInfo(teamId)
    end
  end
end
function TeamMgr:VerifyTeamInfo(teamId, lst)
  local teamInfo = self.m_TeamMemberList[teamId]
  if teamInfo == nil then
    return
  end
  local tempDict = {}
  for _, pid in pairs(lst) do
    tempDict[pid] = 1
  end
  local delList = {}
  for index = #teamInfo, 1, -1 do
    local pid = teamInfo[index]
    if tempDict[pid] == nil then
      delList[#delList + 1] = pid
      table.remove(teamInfo, index)
    end
  end
  for _, pid in pairs(delList) do
    print("---->>>组队信息校验失败，需要剔除:", pid, teamId)
    local info = self.m_TeamInfoCache[pid]
    if info and info.teamId == teamId then
      self.m_TeamInfoCache[pid] = nil
    end
    local role = self:getPlayerMainHero(pid)
    if role and role:getProperty(PROPERTY_TEAMID) == teamId then
      role:setProperty(PROPERTY_TEAMID, 0)
      role:setProperty(PROPERTY_ISCAPTAIN, 0)
      role:setProperty(PROPERTY_TEAMSTATE, 0)
      role:setProperty(PROPERTY_TEAMSTATUS, 0)
    end
    self:playerLeaveTeam(pid, teamId, nil)
  end
end
function TeamMgr:updatePromulgateTeam(teamId, info)
  local data = self.m_PromulgateTeamInfo[teamId]
  if data == nil then
    if info.i_teamid ~= nil and info.i_num ~= nil and info.i_typeid ~= nil and info.i_cname ~= nil and info.i_clevel ~= nil and info.i_czs ~= nil and info.i_target ~= nil and info.i_time ~= nil then
      if teamId == self:getLocalPlayerTeamId() then
        if self:localPlayerIsCaptain() then
          local curTime = g_DataMgr:getServerTime()
          self.m_LastPromulgateTeamTime = curTime
        end
      elseif info.i_num >= GetTeamPlayerNumLimit(info.i_target) then
        local restTime = self:getPromulgateRestEffectiveTime(info.i_time)
        if restTime <= 0 then
          print("--->>获取的初始发布队伍已过期", teamId)
        else
          print(string.format("--->>获取的初始发布队伍满员并且还剩余%d秒过期，删除过期发布信息", restTime), teamId)
          scheduler.performWithDelayGlobal(function()
            self:deletePromulgateTeamWithDelay_CallBack(teamId, info.i_time)
          end, restTime)
        end
      end
      self.m_PromulgateTeamInfo[teamId] = info
      SendMessage(MsgID_Team_NewPromulgateTeam, teamId, info)
    else
      print("--->>>>收到一个无效发布组队信息", teamId)
      print_lua_table(info)
    end
  elseif info.i_time ~= nil and info.i_time ~= data.i_time then
    SendMessage(MsgID_Team_DelPromulgateTeam, teamId)
    for k, v in pairs(info) do
      data[k] = v
    end
    SendMessage(MsgID_Team_NewPromulgateTeam, teamId, data)
    if teamId == self:getLocalPlayerTeamId() and self:localPlayerIsCaptain() then
      local curTime = g_DataMgr:getServerTime()
      self.m_LastPromulgateTeamTime = curTime
    end
  else
    for k, v in pairs(info) do
      data[k] = v
    end
    SendMessage(MsgID_Team_UpdatePromulgateTeam, teamId, info)
    if info.i_num ~= nil then
      if info.i_num >= GetTeamPlayerNumLimit(data.i_target) then
        if teamId ~= self:getLocalPlayerTeamId() then
          local restTime = self:getPromulgateRestEffectiveTime(data.i_time)
          if restTime <= 0 then
            print("--->>满员后已过期，删除过期发布信息", teamId)
            self:deletePromulgateTeamWithDelay(teamId)
          else
            print(string.format("--->>满员后还剩余%d秒过期，删除过期发布信息", restTime), teamId)
            SendMessage(MsgID_Team_DelayDelPromulgateTeam, teamId)
            scheduler.performWithDelayGlobal(function()
              self:deletePromulgateTeamWithDelay_CallBack(teamId, data.i_time)
            end, restTime)
          end
        end
      else
        SendMessage(MsgID_Team_PromulgateEffectTeam, teamId, data)
      end
    end
  end
  local tempData = self.m_PromulgateTeamInfo[teamId]
  if tempData and tempData.i_num ~= nil and tempData.i_cname ~= nil and tempData.i_czs ~= nil and tempData.i_clevel ~= nil and tempData.i_target ~= nil then
    g_MessageMgr:newPromulgateTeam(teamId, tempData.i_num, tempData.i_cname, tempData.i_czs, tempData.i_clevel, tempData.i_target, tempData.i_tid, true)
  end
end
function TeamMgr:getPromulgateRestEffectiveTime(ftime)
  local curTime = g_DataMgr:getServerTime()
  local delTime = math.max(0, curTime - ftime)
  local restTime = CD_PromulgateTeamEffect - delTime
  return restTime
end
function TeamMgr:deletePromulgateTeam(teamId)
  self.m_PromulgateTeamInfo[teamId] = nil
  SendMessage(MsgID_Team_DelPromulgateTeam, teamId)
end
function TeamMgr:deletePromulgateTeamWithDelay(teamId)
  self.m_PromulgateTeamInfo[teamId] = nil
  SendMessage(MsgID_Team_DelayDelPromulgateTeam, teamId)
end
function TeamMgr:deletePromulgateTeamWithDelay_CallBack(teamId, deleteTime)
  if g_LocalPlayer == nil then
    return
  end
  local data = self.m_PromulgateTeamInfo[teamId]
  if data == nil then
    print("--->>回调时发布队伍已经不存在，不用再处理", teamId)
    return
  end
  local itime = data.i_time
  local inum = data.i_num
  local targetId = data.i_target
  local numMax = GetTeamPlayerNumLimit(targetId)
  if itime == deleteTime and inum >= numMax then
    print("--->>回调时间到，删除发布队伍", teamId)
    self:deletePromulgateTeamWithDelay(teamId)
  else
    print("--->>回调时间到，但是未达到删除条件", teamId, itime, deleteTime, inum, numMax)
  end
end
function TeamMgr:startUpdatePromulgateTeam()
  self.m_IsUpdatingPromulgateInfo = true
end
function TeamMgr:endUpdatePromulgateTeam()
  self.m_IsUpdatingPromulgateInfo = false
  if self.m_PromulgateInfoCnt > 0 then
    self:requestUpdatePromulgateTeam()
  end
end
function TeamMgr:getPromulgateTeamInfo(teamId)
  return self.m_PromulgateTeamInfo[teamId]
end
function TeamMgr:getPromulgateTeams()
  if self.m_IsUpdatingPromulgateInfo then
    local teamList = {}
    for teamId, info in pairs(self.m_PromulgateTeamInfo) do
      if info.i_num < GetTeamPlayerNumLimit(info.i_target) then
        teamList[#teamList + 1] = {teamId, info}
      end
    end
    table.sort(teamList, handler(self, self._PromulgateSortFunc))
    return teamList
  else
    return {}
  end
end
function TeamMgr:_PromulgateSortFunc(a, b)
  if a == nil or b == nil then
    return false
  end
  local t_a = a[2].i_time
  local t_b = b[2].i_time
  if t_a ~= t_b then
    return t_a < t_b
  else
    return a[1] < b[1]
  end
end
function TeamMgr:getTeamTarget(teamId)
  if teamId == nil then
    teamId = self:getLocalPlayerTeamId()
  end
  local info = self.m_PromulgateTeamInfo[teamId]
  if info ~= nil then
    return info.i_target
  else
    return nil
  end
end
function TeamMgr:getTeamTargetList(speTarget)
  if g_LocalPlayer == nil then
    return {}
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local myZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local myLevel = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local dataList = {}
  local extraLv, extraZs
  local extraList = {}
  local tbsjFlag, yzddFlag, xzscFlag = activity.event:getTodayEvent_TBSJ_YZDD()
  for proId, data in pairs(data_Promulgate) do
    if proId == speTarget then
      if g_MapMgr:IsInYiZhanDaoDiMap() then
        if proId == PromulgateTeamTarget_YZDD then
          dataList[#dataList + 1] = {proId, data}
        end
      else
        dataList[#dataList + 1] = {proId, data}
      end
    else
      local okFlag = true
      if proId == PromulgateTeamTarget_BangPai and not g_BpMgr:localPlayerHasBangPai() then
        okFlag = false
      end
      if g_MapMgr:IsInYiZhanDaoDiMap() and proId ~= PromulgateTeamTarget_YZDD then
        okFlag = false
      end
      if proId == PromulgateTeamTarget_YZDD then
        if not yzddFlag then
          okFlag = false
        end
      elseif proId == PromulgateTeamTarget_TBSJ then
        if not tbsjFlag then
          okFlag = false
        end
      elseif proId == PromulgateTeamTarget_XZSC and not xzscFlag then
        okFlag = false
      end
      if okFlag then
        if data_judgeFuncOpen(myZs, myLevel, data.rebirth, data.level, data.AlwaysJudgeLvFlag) then
          dataList[#dataList + 1] = {proId, data}
        elseif extraLv == nil or data.rebirth == extraZs and data.level == extraLv then
          extraLv = data.level
          extraZs = data.rebirth
          extraList[#extraList + 1] = {proId, data}
        elseif extraZs > data.rebirth or data.rebirth == extraZs and extraLv > data.level then
          extraLv = data.level
          extraZs = data.rebirth
          extraList = {}
          extraList[#extraList + 1] = {proId, data}
        end
      end
    end
  end
  for _, d in pairs(extraList) do
    dataList[#dataList + 1] = d
  end
  local function _TeamTargetSortFunc(a, b)
    if a == nil or b == nil then
      return false
    end
    local id_a = a[1]
    local id_b = b[1]
    if id_a == speTarget then
      return true
    elseif id_b == speTarget then
      return false
    else
      local sortkey_a = a[2].sortkey
      local sortkey_b = b[2].sortkey
      return sortkey_a <= sortkey_b
    end
  end
  table.sort(dataList, _TeamTargetSortFunc)
  return dataList
end
function TeamMgr:OnOpenPromulgateTeamInfo()
  self.m_PromulgateInfoCnt = self.m_PromulgateInfoCnt + 1
  if self.m_PromulgateInfoCnt == 1 and not self.m_IsUpdatingPromulgateInfo then
    self.m_PromulgateTeamInfo = {}
    SendMessage(MsgID_Team_ClearPromulgateTeam)
    self:requestUpdatePromulgateTeam()
  end
end
function TeamMgr:OnClosePromulgateTeamInfo()
  self.m_PromulgateInfoCnt = self.m_PromulgateInfoCnt - 1
  if self.m_PromulgateInfoCnt <= 0 and self.m_IsUpdatingPromulgateInfo then
    scheduler.performWithDelayGlobal(handler(self, self.NoticeSeverToEndUpdatePromulgate), CD_RequestPromulgateInfo)
  end
end
function TeamMgr:NoticeSeverToEndUpdatePromulgate()
  if self.m_PromulgateInfoCnt <= 0 and self.m_IsUpdatingPromulgateInfo then
    self:stopUpdatePromulgateTeam()
  end
end
function TeamMgr:addJoinRequest(ls)
  if not self:localPlayerIsCaptain() then
    print("本地玩家不是队长，怎么会有收到增加入队申请")
    self:clearJoinRequest()
    return
  end
  local newRequest = false
  for _, pid in pairs(ls) do
    local flag = true
    for _, pInfo in pairs(self.m_JoinRequest) do
      playerId = pInfo[1]
      if pid == playerId then
        flag = false
        local t = g_DataMgr:getServerTime()
        if t > pInfo[2] then
          newRequest = true
        end
        pInfo[2] = t
        break
      end
    end
    if flag then
      local t = g_DataMgr:getServerTime()
      self.m_JoinRequest[#self.m_JoinRequest + 1] = {pid, t}
      newRequest = true
    end
  end
  if newRequest then
    SendMessage(MsgID_Team_AddJoinRequest, ls)
  end
end
function TeamMgr:delJoinRequest(pid)
  if not self:localPlayerIsCaptain() then
    print("本地玩家不是队长，直接清空入队申请缓存")
    self:clearJoinRequest()
    return
  end
  for index, pInfo in pairs(self.m_JoinRequest) do
    local playerId = pInfo[1]
    if pid == playerId then
      table.remove(self.m_JoinRequest, index)
      SendMessage(MsgID_Team_DelJoinRequest, pid)
      break
    end
  end
end
function TeamMgr:clearJoinRequest()
  if #self.m_JoinRequest ~= 0 then
    self.m_JoinRequest = {}
    self.m_LastCheckJoinRequestTime = 0
    SendMessage(MsgID_Team_ClearJoinRequest)
  end
end
function TeamMgr:setCheckJoinRequest(curTime)
  self.m_LastCheckJoinRequestTime = curTime
end
function TeamMgr:getExistNewJoinRequest()
  local t = g_DataMgr:getServerTime()
  for _, pInfo in pairs(self.m_JoinRequest) do
    local pid = pInfo[1]
    local rt = pInfo[2]
    if t - rt < Define_JoinRequestEfftectTime and rt > self.m_LastCheckJoinRequestTime then
      return true
    end
  end
  return false
end
function TeamMgr:getJoinRequest()
  local result = {}
  for _, pInfo in pairs(self.m_JoinRequest) do
    local pid = pInfo[1]
    result[#result + 1] = pid
  end
  return result
end
function TeamMgr:checkJoinRequestIsEffect(pid)
  local isEffect = false
  for index, pInfo in pairs(self.m_JoinRequest) do
    local playerId = pInfo[1]
    if pid == playerId then
      local rt = pInfo[2]
      local t = g_DataMgr:getServerTime()
      if t - rt < Define_JoinRequestEfftectTime then
        isEffect = true
        break
      else
        print("检测到入队申请过期", pid, rt, t)
        isEffect = false
        break
      end
    end
  end
  if not isEffect then
    local jrList = {}
    local t = g_DataMgr:getServerTime()
    for _, pInfo in pairs(self.m_JoinRequest) do
      local pid = pInfo[1]
      local rt = pInfo[2]
      if t - rt < Define_JoinRequestEfftectTime then
        jrList[#jrList + 1] = {pid, rt}
      else
        print("入队申请已过期，需要删除:", pid, rt, t)
      end
    end
    self.m_JoinRequest = jrList
  end
  return isEffect
end
function TeamMgr:getFreePlayersNearby()
  local players = {}
  local playerIdList = g_MapMgr:getNearPlayerIds()
  print("===>> getNearPlayerIds_1:", #playerIdList)
  local localPlayerId = g_LocalPlayer:getPlayerId()
  for _, pid in pairs(playerIdList) do
    if pid ~= localPlayerId then
      local player = g_DataMgr:getPlayer(pid)
      if player then
        local role = player:getMainHero()
        if role then
          local teamId = role:getProperty(PROPERTY_TEAMID)
          if teamId == 0 then
            players[#players + 1] = pid
          end
        end
      else
        print("【Team error】附近玩家没有信息1？！ pid =", pid)
      end
    end
  end
  return players
end
function TeamMgr:SetAcceptAutoMatchFlag(matchFlag)
  self.m_AcceptAutoMatchFlag = matchFlag
  SendMessage(MsgID_Team_AcceptAutoMatch)
end
function TeamMgr:GetAcceptAutoMatch()
  return self.m_AcceptAutoMatchFlag == 1 or self.m_AcceptAutoMatchFlag == true
end
function TeamMgr:SetAutoMatchState(matchFlag, target)
  self.m_IsAutoMatching = matchFlag
  self.m_IsAutoMatchingTarget = target or 0
  if matchFlag == 1 then
    if target == 0 then
      local txt = "系统正在为你自动匹配队伍，请耐心等待"
      ShowNotifyTips(txt)
      ShowDownNotifyViews(txt, true)
    else
      local targetName = data_getPromulgateDesc(target)
      local txt = string.format("系统正在为你自动匹配#<Y>%s#，请耐心等待", targetName)
      ShowNotifyTips(txt)
      ShowDownNotifyViews(txt, true)
    end
  end
  SendMessage(MsgID_Team_IsAutoMatching, matchFlag, target)
end
function TeamMgr:GetIsAutoMatching()
  return self.m_IsAutoMatching == 1 or self.m_IsAutoMatching == true
end
function TeamMgr:GetIsAutoMatchingTarget()
  return self.m_IsAutoMatchingTarget
end
function TeamMgr:send_InvitePlayer(pid)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
  if openFlag == false then
    ShowNotifyTips(tips)
    return
  end
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  local teamId = self:getLocalPlayerTeamId()
  if teamId ~= 0 and self:getTeamPlayerNum(teamId) >= GetTeamPlayerNumLimit() then
    ShowNotifyTips("你的队伍已满，不能再邀请别人入队")
    return
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.m_LastInviteTime[pid] or 0
  if curTime - lastTime < 1 then
    return
  end
  netsend.netteam.invitePlayer(pid)
  self.m_LastInviteTime[pid] = curTime
end
function TeamMgr:send_AgreeInviteToTeam(pid)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if self:getLocalPlayerTeamId() == 0 then
    netsend.netteam.agreeInviteToTeam(pid)
  else
    ShowNotifyTips("你已经组队")
  end
end
function TeamMgr:send_RefuseInviteToTeam(pid)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  netsend.netteam.refuseInviteToTeam(pid)
end
function TeamMgr:send_ApplyToTeam(teamId, pName)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Duiwu)
  if openFlag == false then
    ShowNotifyTips(tips)
    return
  end
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if self:getLocalPlayerTeamId() ~= 0 then
    ShowNotifyTips("你已经组队")
    return
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.m_LastJoinRequestTime[teamId] or 0
  if curTime - lastTime < CD_ApplyToJoinTeam then
    ShowNotifyTips(string.format("你不久前已发出过申请,请稍后再试"))
    return
  end
  if curTime - lastTime < 1 then
    return
  end
  netsend.netteam.applyToTeam(teamId)
  self.m_LastJoinRequestTime[teamId] = curTime
end
function TeamMgr:send_MakeTeamCaptain(pid)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:getIsMapLoading() then
    return false
  end
  if self:localPlayerIsCaptain() then
    netsend.netteam.makeTeamCaptain(pid)
    return true
  else
    ShowNotifyTips("必须是队长才能进行此项操作")
    return false
  end
end
function TeamMgr:send_KickOutPlayer(pid)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  if self:localPlayerIsCaptain() then
    netsend.netteam.kickOutPlayer(pid)
    return true
  else
    ShowNotifyTips("必须是队长才能进行此项操作")
    return false
  end
end
function TeamMgr:send_DismissTeam()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if self:localPlayerIsCaptain() then
    netsend.netteam.dismissTeam()
  else
    ShowNotifyTips("必须是队长才能进行此项操作")
  end
end
function TeamMgr:send_RequestCaptain()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:getIsMapLoading() then
    return
  end
  if self:getLocalPlayerTeamId() == 0 then
    ShowNotifyTips("组队后才能申请队长")
    return
  end
  if self:localPlayerIsCaptain() then
    ShowNotifyTips("你已经是队长")
    return
  end
  local curTime = g_DataMgr:getServerTime()
  if curTime - self.m_LastRequestCaptainTime < 1 then
    return
  end
  netsend.netteam.requestCaptain()
  self.m_LastRequestCaptainTime = curTime
end
function TeamMgr:send_QuitTeam()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if self:getLocalPlayerTeamId() ~= 0 then
    if g_MapMgr:touchExitMapButtom(1) ~= true then
      netsend.netteam.quitTeam()
    end
  else
    ShowNotifyTips("你没有组队")
  end
end
function TeamMgr:send_AgreeRequest(pid)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if not self:localPlayerIsCaptain() then
    ShowNotifyTips("必须是队长才能进行此项操作")
    return
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.m_LastAgreeJoinRequestTime[pid] or 0
  if curTime - lastTime < 1 then
    return
  end
  netsend.netteam.agreeRequest(pid)
  self.m_LastAgreeJoinRequestTime[pid] = curTime
end
function TeamMgr:send_TempLeaveTeam()
  if g_MapMgr:getIsMapLoading() then
    return
  end
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if self:getLocalPlayerTeamId() ~= 0 then
    netsend.netteam.tempLeaveTeam()
  else
    ShowNotifyTips("你没有组队")
  end
end
function TeamMgr:send_ComebackTeam(flag)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if self:getLocalPlayerTeamId() ~= 0 then
    netsend.netteam.comebackTeam(flag)
  else
    ShowNotifyTips("你没有组队")
  end
end
function TeamMgr:send_AgreeCaptainRequest(pid)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if self:localPlayerIsCaptain() then
    netsend.netteam.agreeCaptainRequest(pid)
  else
    ShowNotifyTips("必须是队长才能进行此项操作")
  end
end
function TeamMgr:send_CallBackTeamPlayer(ls)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if not self:localPlayerIsCaptain() then
    ShowNotifyTips("必须是队长才能进行此项操作")
    return
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.m_LastCallBackTime
  if curTime - lastTime < 1 then
    return
  end
  netsend.netteam.callBackTeamPlayer(ls)
  self.m_LastCallBackTime = curTime
end
function TeamMgr:send_CreateTeam()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中，不能创建队伍")
    return false
  end
  if self:getLocalPlayerTeamId() ~= 0 then
    ShowNotifyTips("你已在一个组队中", true)
    return false
  else
    netsend.netteam.createTeam()
  end
  return true
end
function TeamMgr:send_PromulgateTeam(target)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if target == nil then
    ShowNotifyTips("请先选择一个发布目标", true)
    return
  end
  if not self:localPlayerIsCaptain() then
    ShowNotifyTips("必须是队长才能进行此项操作", true)
    return
  end
  if target == PromulgateTeamTarget_BangPai and not g_BpMgr:localPlayerHasBangPai() then
    ShowNotifyTips("加入帮派后才能发布该目标")
    return
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.m_LastPromulgateTeamTime
  if curTime - lastTime < CD_PromulgateTeam then
    local restTime = CD_PromulgateTeam - curTime + lastTime
    local h = math.floor(restTime / 60)
    local s = math.floor(restTime % 60)
    if h > 0 then
      ShowNotifyTips(string.format("还有%d分%d秒才能再次发布", h, s), true)
    else
      ShowNotifyTips(string.format("还有%d秒才能再次发布", s), true)
    end
    return
  end
  netsend.netteam.promulgateTeam(target)
end
function TeamMgr:requestUpdatePromulgateTeam()
  print("--->>>通知服务器对发布组队信息【开始】实时刷新!!!")
  netsend.netteam.requestUpdatePromulgateTeam()
end
function TeamMgr:stopUpdatePromulgateTeam()
  print("--->>>通知服务器对发布组队信息【结束】实时刷新。。。")
  netsend.netteam.stopUpdatePromulgateTeam()
end
function TeamMgr:send_acceptAutoMatch(flag)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if flag == true then
    flag = 1
  elseif flag == false then
    flag = 0
  end
  netsend.netteam.acceptAutoMatch(flag)
end
function TeamMgr:send_requestAutoMatch(flag, target)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if self:getLocalPlayerTeamId() ~= 0 then
    ShowNotifyTips("你已在一个组队中")
    return
  end
  if flag == true then
    flag = 1
  elseif flag == false then
    flag = 0
  end
  netsend.netteam.requestAutoMatch(flag, target)
end
function TeamMgr:send_AutoConfirmCaptainRequest(flag)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if flag then
    netsend.netbaseptc.setCertainSetting(1, 1)
  else
    netsend.netbaseptc.setCertainSetting(1, 0)
  end
end
function TeamMgr:resetMgrData()
  print("--->>>TeamMgr:resetMgrData")
  self.m_IsResetingData = true
  local teamId, teamInfo = self:getLocalPlayerTeamInfo()
  if teamId and teamInfo then
    for _, pid in pairs(teamInfo) do
      local role = self:getPlayerMainHero(pid)
      if role then
        role:setProperty(PROPERTY_TEAMID, 0)
        role:setProperty(PROPERTY_ISCAPTAIN, TEAMCAPTAIN_NO)
      end
      SendMessage(MsgID_Team_PlayerLeaveTeam, teamId, pid)
    end
  end
  self.m_AllTeamInfo = {}
  self.m_TeamInfoCache = {}
  self.m_TeamMemberList = {}
  self:clearJoinRequest()
  self.m_PromulgateTeamInfo = {}
  SendMessage(MsgID_Team_ClearPromulgateTeam)
  self.m_IsResetingData = false
end
function TeamMgr:Clear()
  self:RemoveAllMessageListener()
end
g_TeamMgr = TeamMgr.new()
gamereset.registerResetFunc(function()
  if g_TeamMgr then
    g_TeamMgr:Clear()
  end
  g_TeamMgr = TeamMgr.new()
end)
