local tianting = class("tiantingMgr")
tianting.startNpc = 90009
tianting.startNpcFunc = 1033
tianting.mapId = 14
tianting.monsterRubbishId = 3001
tianting.awardObjId = 30002
tianting.awardCount = 1
function tianting:ctor()
  self.m_MonsterIdToIdx = {
    [90011] = 1,
    [90012] = 2,
    [90013] = 3,
    [90014] = 4
  }
  self.m_IdxToMonsterId = {}
  for k, v in pairs(self.m_MonsterIdToIdx) do
    self.m_IdxToMonsterId[v] = k
  end
  self.m_MonsterData = {
    [1] = {
      cnt = 0,
      missionId = 52001,
      award_exp = 0,
      locid = 0
    },
    [2] = {
      cnt = 0,
      missionId = 52002,
      award_exp = 0,
      locid = 0
    },
    [3] = {
      cnt = 0,
      missionId = 52003,
      award_exp = 0,
      locid = 0
    },
    [4] = {
      cnt = 0,
      missionId = 52004,
      award_exp = 0,
      locid = 0
    }
  }
  self.m_MissionIdToIdx = {}
  for idx, data in pairs(self.m_MonsterData) do
    self.m_MissionIdToIdx[data.missionId] = idx
  end
  self.m_WarDaylyNum = 3
  self.m_TotalExp = 0
  self.m_MissionId = 0
  self.m_CurFinishedTimes = 0
  self.m_IsInMap = false
  self.m_IsFinishFb = false
end
function tianting:getTodayFinishedTimes()
  return self.m_CurFinishedTimes
end
function tianting:getDaylyNum()
  return data_Variables.TianTingCntLimit
end
function tianting:getMissionId()
  return self.m_MissionId
end
function tianting:isInFb()
  return self.m_IsInMap
end
function tianting:isMap(mapId)
  return tianting.mapId == mapId
end
function tianting:isMission(missionId)
  return self.m_MissionIdToIdx[missionId] ~= nil
end
function tianting:getTimes()
  return self:getTodayFinishedTimes(), self:getDaylyNum()
end
function tianting:getWarTimes(idx)
  return self.m_MonsterData[idx].cnt, self.m_WarDaylyNum
end
function tianting:getWarWithNpcId(npcId)
  local idx = self:getMonsterIdxByNpcId(npcId)
  return self.m_MonsterData[idx].cnt, self.m_WarDaylyNum
end
function tianting:getWarWithMissionId(missionId)
  local idx = self.m_MissionIdToIdx[missionId]
  return self.m_MonsterData[idx].cnt, self.m_WarDaylyNum
end
function tianting:getMonsterIdxByNpcId(npcId)
  return self.m_MonsterIdToIdx[npcId]
end
function tianting:getMonsterNpcIdByIdx(idx)
  return self.m_IdxToMonsterId[idx]
end
function tianting:isMonsterNpc(npcId)
  return self.m_MonsterIdToIdx[npcId] ~= nil
end
function tianting:isFinisheFb()
  return self.m_IsFinishFb
end
function tianting:getTotalExp()
  return self.m_TotalExp
end
function tianting:getMonsterData()
  return self.m_MonsterData
end
function tianting:reqStart()
  printLog("Tianting", "请求开始任务")
  netsend.netactivity.reqEnterTiantingFb()
end
function tianting:EnterFb(listener)
  local follow = g_LocalPlayer:getIsFollowTeam()
  print("-->> EnterFb:", follow)
  if follow ~= 0 then
    local tInfo = data_WorldMapTeleporter[116]
    local len = #tInfo.toPos
    local pos = tInfo.toPos[math.random(1, len)]
    g_MapMgr:AutoRoute(tianting.mapId, {
      pos[1],
      pos[2]
    }, listener)
  end
  self:flushAllMissions()
end
function tianting:GotoNpc()
  local npcId = tianting.startNpc
  g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
    if isSucceed and CMainUIScene.Ins then
      CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
    end
  end)
end
function tianting:justGotoNpc()
  local npcId = tianting.startNpc
  g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
  end, true)
end
function tianting:monsterOptionTouch(missionId)
  local idx = self.m_MissionIdToIdx[missionId]
  printLog("Tianting", "monsterOptionTouch:%d,idx=%d", missionId, idx)
  netsend.netteamwar.starTiantingWar(self.m_MissionId, idx)
end
function tianting:touchExitButton(exitType)
  if self.m_IsInMap then
    if self:isFinisheFb() == true then
      getCurSceneView():addSubView({
        subView = TiantingExit2.new(exitType),
        zOrder = MainUISceneZOrder.menuView
      })
    else
      getCurSceneView():addSubView({
        subView = TiantingExit1.new(exitType),
        zOrder = MainUISceneZOrder.menuView
      })
    end
    return true
  end
  return false
end
function tianting:flushAllMissions()
  if self.m_IsInMap == false then
    printLog("Tianting", "没有再副本状态的时候刷新")
    return
  end
  for mIdx, data in pairs(self.m_MonsterData) do
    self:flushOneMissions(mIdx)
  end
end
function tianting:flushOneMissions(monsterIdx, force)
  local data = self.m_MonsterData[monsterIdx]
  if data == nil then
    printLog("Tianting", "找不到怪物idx=%s", monsterIdx)
    return
  end
  local isNeedDelNpc = true
  if data.cnt >= self.m_WarDaylyNum then
    g_MissionMgr:Server_GiveUpMission(data.missionId)
  else
    isNeedDelNpc = false
    local newLocId = data.locid
    print("flushOneMissions-->>", monsterIdx, newLocId)
    if newLocId ~= nil and newLocId ~= 0 then
      local dataTable = data_Mission_Activity[data.missionId]
      if dataTable then
        local dst1 = dataTable.dst1
        if dst1 then
          print("dst1.data[2], newLocId =", dst1.data[2], newLocId)
          if dst1.data[2] ~= newLocId then
            dst1.data[2] = newLocId
            if self.m_IsInMap == true then
              local mapView = g_MapMgr:getMapViewIns()
              if mapView then
                mapView:DeleteMonsterByMissionId(data.missionId)
                mapView:createMonsterForMission(data.missionId, dst1.data[1], dst1.data[2], MapMonsterType_Tianing)
              end
            end
          end
        end
      end
    end
    local pro = g_MissionMgr:getMissionProgress(data.missionId)
    if force == true or pro == nil then
      g_MissionMgr:Server_MissionUpdated(data.missionId, 0)
    end
  end
  if isNeedDelNpc == true then
    local mapView = g_MapMgr:getMapViewIns()
    local npcId = self:getMonsterNpcIdByIdx(monsterIdx)
    if mapView ~= nil and npcId ~= nil then
      mapView:DeleteNormalNpc(npcId)
    end
  end
end
function tianting:delAllMissions()
  for mIdx, data in pairs(self.m_MonsterData) do
    g_MissionMgr:Server_GiveUpMission(data.missionId)
  end
end
function tianting:reqLeave(exitType, tempLevelFalg)
  print("-->>:tianting:reqLeave:", exitType, tempLevelFalg)
  netsend.netactivity.reqExitTiantingFb(exitType, tempLevelFalg)
end
function tianting:UpdateData(missionId, data, cnt, monsterlv)
  if cnt ~= nil then
    self.m_CurFinishedTimes = cnt
    if cnt > 0 then
      g_MissionMgr:GuideIdComplete(GuideId_Tianting)
    end
  end
  if missionId ~= nil then
    self.m_MissionId = missionId
  end
  print(" ===================   monsterlv == ", monsterlv)
  if monsterlv ~= nil then
    local monsterItem = data_TaskExpTianTing[monsterlv] or {}
    local awardItem = monsterItem.AwardBoxId
    if awardItem ~= nil then
      for k, v in pairs(awardItem) do
        tianting.awardObjId = k or 30002
        tianting.awardCount = v or 1
        break
      end
    end
  end
  if data then
    local bossDatas = data.boss or {}
    for idx, bossData in pairs(bossDatas) do
      dump(bossData, " bossData  tianting ")
      local d = self.m_MonsterData[idx] or {}
      d.cnt = bossData.progress - 1
      d.award_exp = bossData.award_exp
      d.locid = bossData.locid
      if self.m_IsInMap == true then
        self:flushOneMissions(idx, true)
      end
    end
    self.m_TotalExp = 0
    self.m_IsFinishFb = true
    for k, v in pairs(self.m_MonsterData) do
      self.m_TotalExp = self.m_TotalExp + v.award_exp
      if v.cnt < self.m_WarDaylyNum then
        self.m_IsFinishFb = false
      end
    end
    if data.captainexp ~= nil then
      print("---->> 天庭任务增加队长加成:", data.captainexp)
      self.m_TotalExp = self.m_TotalExp + data.captainexp
    end
    if g_CMainMenuHandler then
      g_CMainMenuHandler:setTiantingExp(self.m_TotalExp)
    end
    SendMessage(MsgID_Activity_TiantingExpUpdate)
  end
  if self.m_IsFinishFb then
    self:touchExitButton()
  end
end
function tianting:UpdateCount(cnt)
  printLog("Tianting", "UpdateCount:%s", tostring(cnt))
  if cnt ~= nil then
    self.m_CurFinishedTimes = cnt
    if cnt > 0 then
      g_MissionMgr:GuideIdComplete(GuideId_Tianting)
    end
  end
end
function tianting:ExitFb()
  self.m_IsInMap = false
  self.m_MissionId = 0
  self:delAllMissions()
  SendMessage(MsgID_Activity_ExitTianting)
end
function tianting:EnterFbSucceed()
  self.m_IsInMap = true
  self:EnterFb()
  if g_CMainMenuHandler then
    g_CMainMenuHandler:setTiantingExp(self.m_TotalExp)
  end
end
function tianting:flushIsInMap()
  if self.m_IsInMap and g_CMainMenuHandler then
    g_CMainMenuHandler:setTiantingExp(self.m_TotalExp)
  end
end
function tianting:Clean()
  if self.m_IsInMap == true then
    self.m_IsInMap = false
    self.m_MissionId = 0
    self:delAllMissions()
  end
end
return tianting
