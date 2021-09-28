local dayanta = class("dayantaMgr")
dayanta.StartNpcId = 90200
dayanta.Status_TaskNeedAccept = 1
dayanta.Status_TaskAccepted = 2
dayanta.Status_TaskFinished = 3
dayanta.TodayLimit = math.floor(data_Variables.DayantaCntLimit)
function dayanta:ctor()
  self.m_exchangeTimes = 0
  self.m_maxExchangeTimes = 4
  self.m_autoStates = 0
  self.m_exchangeMissionStatus = dayanta.Status_TaskNeedAccept
  self.m_CurMapId = 0
  self.m_LastMissionId = nil
  self.m_IsAllComplete = false
  self.m_AllCompleteView = nil
  self.m_CacheExchangeTimesData = nil
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_MapScene)
  self:ListenMessage(MsgID_Connect)
end
function dayanta:OnMessage(msgSID, ...)
  if msgSID == MsgID_MapScene_ChangedMap then
    local curMapId = g_MapMgr:getCurMapId()
    if not self:isDayantaMapId(curMapId) then
      self:closeCompleteWarningView()
    end
  elseif msgSID == MsgID_Connect_SendFinished and self.m_CacheExchangeTimesData ~= nil then
    local times = self.m_CacheExchangeTimesData[1]
    local autoStatues = self.m_CacheExchangeTimesData[2]
    self.m_CacheExchangeTimesData = nil
    self:dayantaDataUpadte(times, autoStatues)
  end
end
function dayanta:getIsAllComplete()
  return self.m_IsAllComplete
end
function dayanta:closeCompleteWarningView()
  if self.m_AllCompleteView then
    self.m_AllCompleteView:CloseSelf()
    self.m_AllCompleteView = nil
  end
end
function dayanta:getCurMapId()
  return self.m_CurMapId
end
function dayanta:isDayantaMapId(mapId)
  if mapId == nil then
    printLog("warning", "dayanta:isDayantaMapId mapId == nli")
    return false
  end
  return mapId >= 101 and mapId <= 109
end
function dayanta:getCurLyNum()
  local mapid = g_MapMgr:getCurMapId()
  if mapid == nil or type(mapid) ~= "number" then
    return nil
  end
  return mapid % 100
end
function dayanta:getExchangeTimes()
  return self.m_exchangeTimes
end
function dayanta:getMaxExchangeTimes()
  return self.m_maxExchangeTimes
end
function dayanta:getLastMissionId()
  return self.m_LastMissionId
end
function dayanta:GotoNpc()
  g_MapMgr:AutoRouteToNpc(dayanta.StartNpcId, function(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(dayanta.StartNpcId)
    end
  end)
end
function dayanta:EnterDYTMap(missionId)
  self.m_LastMissionId = missionId
  self.m_IsAllComplete = false
  local layerIdx = tonumber(string.sub(tostring(missionId), -2, -2))
  local mapId = 100 + layerIdx
  self.m_CurMapId = mapId
  local teamCaptainPro = g_LocalPlayer:getObjProperty(1, PROPERTY_ISCAPTAIN)
  if teamCaptainPro == TEAMCAPTAIN_YES and g_MapMgr:getCurMapId() ~= mapId then
    g_MapMgr:LoadMapById(mapId, {56, 40}, MapPosType_EditorGrid)
    g_MissionMgr:NewMission(missionId)
  end
end
function dayanta:getIdxWithMissionId(missionId)
  return missionId - 10 * math.floor(missionId / 10)
end
function dayanta:getMissionMapId(missionId)
  self.m_LastMissionId = missionId
  local layerIdx = tonumber(string.sub(tostring(missionId), -2, -2))
  return 100 + layerIdx
end
function dayanta:getMissionPos(missionId)
  local idx = self:getIdxWithMissionId(missionId)
  local bossPos = data_DayantaBossPos[idx] or data_DayantaBossPos[1]
  bossPos = bossPos.pos
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  local len = #bossPos
  local rIdx = teamId % len + 1
  if rIdx == 0 then
    rIdx = 1
  end
  return bossPos[rIdx]
end
function dayanta:flushDayantaExchangeExp(missionId)
  print("flushDayantaExchangeExp:", missionId)
  local data = data_Mission_Activity[missionId]
  if data == nil then
    return
  end
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local exp = data_TaskExpDaYanTa[lv] or {}
  exp = exp.BaseExp or 0
  data.rewardExp = math.floor(exp)
end
function dayanta:traceMission(missionId)
  local pos = self:getMissionPos(missionId)
  print("traceMission:pos =", pos[1], pos[2])
  g_MapMgr:AutoRoute(self.m_CurMapId, pos, function(isSucceed)
    print("traceMission:isSucceed =", isSucceed)
    if isSucceed then
      netsend.netteamwar.startDayantaWar()
    end
  end, nil, pos, nil, true, RouteType_Npc)
end
function dayanta:touchMonster(missionId)
  netsend.netteamwar.startDayantaWar()
end
function dayanta:touchExitButton()
  DayantaWarning.new()
  return true
end
function dayanta:allComplete()
  self.m_IsAllComplete = true
  if self.m_AllCompleteView then
    self.m_AllCompleteView:CloseSelf()
  end
  local tempView = CPopWarning.new({
    title = "提示",
    text = "#<W,F:30>恭喜!#\n完成大雁塔通关任务链",
    closeFunc = function()
      netsend.netteamwar.exitDayanta()
      self.m_AllCompleteView = nil
    end,
    cancelText = "离开",
    autoCancelTime = 30,
    hideInWar = true
  })
  tempView:OnlyShowCancelBtn()
  tempView:ShowCloseBtn(false)
  self.m_AllCompleteView = tempView
  g_MissionMgr:GuideIdComplete(GuideId_Dayanta)
end
function dayanta:missionGiveUp()
  local followFlag = g_LocalPlayer:getIsFollowTeam()
  if followFlag > 0 then
    g_MapMgr:AutoRouteToNpc(dayanta.StartNpcId, nil, true)
  end
end
function dayanta:exchangeObj(eId)
  if eId == 1 and activity.dayanta:getExchangeTimes() == activity.dayanta:getMaxExchangeTimes() then
    ShowNotifyTips("兑换次数已满,请明日再来")
  else
    NetSend({i_eid = eId}, "item", "P21")
  end
end
function dayanta:dayantaDataUpadte(times, autoStatues)
  print("-->>dayantaDataUpadte:", times, autoStatues)
  if g_DataMgr:getIsSendFinished() ~= true then
    self.m_CacheExchangeTimesData = {times, autoStatues}
    return
  end
  if times ~= nil then
    self.m_exchangeTimes = times
  end
  if autoStatues ~= nil then
    self.m_autoStates = autoStatues
  else
    self.m_autoStates = 0
  end
  if self.m_exchangeTimes >= self.m_maxExchangeTimes then
    self.m_exchangeMissionStatus = dayanta.Status_TaskFinished
    g_MissionMgr:Server_GiveUpMission(ExchangeMissionId)
  elseif self.m_autoStates == 0 then
    self.m_exchangeMissionStatus = dayanta.Status_TaskNeedAccept
    g_MissionMgr:Server_GiveUpMission(ExchangeMissionId)
    g_MissionMgr:flushDayantaExchangeCanAccept()
  else
    self.m_exchangeMissionStatus = dayanta.Status_TaskAccepted
    g_MissionMgr:Server_MissionAccepted(ExchangeMissionId)
  end
  SendMessage(MsgID_DaYanTa_ExChangeTime, self.m_exchangeTimes, self.m_maxExchangeTimes)
end
function dayanta:reqAccept()
  if self.m_exchangeTimes < self.m_maxExchangeTimes then
    self.m_exchangeMissionStatus = dayanta.Status_TaskAccepted
    g_MissionMgr:Server_MissionAccepted(ExchangeMissionId)
    if self.m_autoStates == 0 then
      self.m_autoStates = 1
      NetSend({i_iauto = 1}, "item", "P22")
    end
  end
end
function dayanta:reqGiveUp()
  if self.m_exchangeTimes < self.m_maxExchangeTimes then
    g_MissionMgr:Server_GiveUpMission(ExchangeMissionId)
    g_MissionMgr:flushDayantaExchangeCanAccept()
    if self.m_autoStates == 1 then
      self.m_autoStates = 0
      NetSend({i_iauto = 0}, "item", "P22")
    end
  end
end
function dayanta:traceExchangeMission()
  self:GotoNpc()
end
function dayanta:CanAccept()
  return g_LocalPlayer:isNpcOptionUnlock(1026) and self.m_exchangeMissionStatus == dayanta.Status_TaskNeedAccept
end
function dayanta:canShowNpcExchange()
  if activity.dayanta:getExchangeTimes() == activity.dayanta:getMaxExchangeTimes() or self.m_exchangeMissionStatus == dayanta.Status_TaskAccepted then
    return true
  else
    return false
  end
end
function dayanta:sendEnterReq(layerIdx)
  netsend.netteamwar.enterDayantaWar(layerIdx)
end
function dayanta:clean()
  self:closeCompleteWarningView()
  self:RemoveAllMessageListener()
end
return dayanta
