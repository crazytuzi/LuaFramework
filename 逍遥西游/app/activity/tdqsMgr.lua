TianDiQiShu_BossMissionId = 53004
TianDiQiShu_Active_Prepare = 1
TianDiQiShu_Active_KillSmallMonster = 2
TianDiQiShu_Active_KillBoss = 3
TianDiQiShu_Active_End = 4
TDQS_DelMissionTag_SmallMonster = 1
TDQS_DelMissionTag_Boss = 2
TDQS_DelMissionTag_Both = 0
TDQS_DelScheduleTag_PrepareTimer = 1
TDQS_DelScheduleTag_BossTimer = 2
TDQS_DelScheduleTag_AllTimer = 0
local tiandiqishu = class("tiandiqishu")
tiandiqishu.startNpc = 0
tiandiqishu.startNpcFunc = 0
tiandiqishu.mapId = 18
tiandiqishu.monsterRubbishId = 0
tiandiqishu.awardObjId = 0
tiandiqishu.isInHuoDong = false
tiandiqishu.ActiveEnd = true
function tiandiqishu:ctor()
  self.m_MonsterShapeIdToNpcId = {
    [20015] = 69309,
    [20020] = 69310,
    [20013] = 69311
  }
  self:setSmallMonsterOrgData()
  self.m_BossMonsterdata = {
    id = 0,
    state = -1,
    missionId = 53004,
    TypeId = 0,
    locid = 0,
    exceedtime = 0
  }
  self.m_Starttime = 0
  self.m_IsInMap = false
  self.m_isCanKillMonster = false
  self.m_CurKillMonsterNum = 0
  self.m_KillMonsterTotalNum = 0
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_MapLoading)
end
function tiandiqishu:setSmallMonsterOrgData()
  self.m_LocSmallMonsterdata = {
    [1] = {
      id = 0,
      state = -1,
      missionId = 53001,
      TypeId = 0,
      locid = 0
    },
    [2] = {
      id = 0,
      state = -1,
      missionId = 53002,
      TypeId = 0,
      locid = 0
    },
    [3] = {
      id = 0,
      state = -1,
      missionId = 53003,
      TypeId = 0,
      locid = 0
    }
  }
  self.m_MissionIdToIdx = {}
  for idx, data in pairs(self.m_LocSmallMonsterdata) do
    self.m_MissionIdToIdx[data.missionId] = idx
  end
end
function tiandiqishu:setStatus(state)
  print("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVV::", state)
  if state == 1 then
    tiandiqishu.isInHuoDong = true
    self.m_isCanKillMonster = true
    tiandiqishu.ActiveEnd = false
  elseif state == 3 then
    self.m_isCanKillMonster = false
    tiandiqishu.ActiveEnd = false
  elseif state == 2 then
    tiandiqishu.isInHuoDong = false
    self.m_isCanKillMonster = false
    tiandiqishu.ActiveEnd = true
    self:flusAllMission()
    self:delTDQSMissionSchedule(TDQS_DelScheduleTag_AllTimer)
    scheduler.performWithDelayGlobal(handler(self, self.setMapTitleActiveEnd), 1)
  end
  if tiandiqishu.isInHuoDong == true then
    self:flusAllMission()
    if self.m_isCanKillMonster == true then
      self:setMapTitleAtTop(TianDiQiShu_Active_KillSmallMonster)
    end
  end
end
function tiandiqishu:updataKillMonsterNum(curNum, totalNum)
  self.m_CurKillMonsterNum = curNum or 0
  self.m_KillMonsterTotalNum = totalNum or 0
  if self.m_isCanKillMonster == true then
    self:setMapTitleAtTop(TianDiQiShu_Active_KillSmallMonster)
  end
end
function tiandiqishu:updataSmallMonsterData(params)
  self:setSmallMonsterOrgData()
  local monsterData = params
  print("=====:把上一环小怪的数据设为原始数据", self.m_isCanKillMonster)
  if monsterData ~= nil then
    for k1, data_1 in pairs(monsterData) do
      self.m_LocSmallMonsterdata[k1].id = data_1.id
      self.m_LocSmallMonsterdata[k1].TypeId = data_1.bossid
      self.m_LocSmallMonsterdata[k1].state = data_1.state
      self.m_LocSmallMonsterdata[k1].locid = data_1.locid
    end
    if self:isMap(g_MapMgr:getCurMapId()) ~= true then
      print("====================:不在活动地图内")
      return
    end
    self:flusAllMission()
  end
end
function tiandiqishu:updataBossMonsterData(params)
  if params then
    self.m_BossMonsterdata.id = params.id
    self.m_BossMonsterdata.TypeId = params.bossid
    self.m_BossMonsterdata.state = params.state or 0
    self.m_BossMonsterdata.exceedtime = params.exceedtime or 0
    self.m_BossMonsterdata.locid = params.locid
    if self:isMap(g_MapMgr:getCurMapId()) ~= true then
      print("====================:不在活动地图内")
      return
    end
    if self.m_BossMonsterdata.state >= 1 then
      self:FrushBossTime()
    end
    self:flusAllMission()
  end
end
function tiandiqishu:getKillMosterNum()
  return self.m_CurKillMonsterNum, self.m_KillMonsterTotalNum
end
function tiandiqishu:getMonsterTable()
  return self.m_MissionIdToIdx, self.m_LocSmallMonsterdata, self.m_BossMonsterdata
end
function tiandiqishu:getIsCanStarActive()
  return tiandiqishu.isInHuoDong
end
function tiandiqishu:setMapTitle(txt)
  if g_CMainMenuHandler then
    g_CMainMenuHandler:setTianDiQiShuTxt(txt)
  end
end
function tiandiqishu:setMapTitleAtTop(tag)
  print("###################################::", tag)
  if self:isMap(g_MapMgr:getCurMapId()) == true then
    if tag == TianDiQiShu_Active_Prepare then
      if tiandiqishu.ActiveEnd ~= true then
        local restTime = self.m_Starttime - g_DataMgr:getServerTime()
        local h, m, s = getHMSWithSeconds(restTime)
        txt = string.format("活动开启倒计时:%02d:%02d", m, s)
        self:setMapTitle(txt)
      end
    elseif tag == TianDiQiShu_Active_KillSmallMonster then
      local txt = string.format("当前杀怪数量:%d/%d", self.m_CurKillMonsterNum, self.m_KillMonsterTotalNum)
      self:setMapTitle(txt)
    elseif tag == TianDiQiShu_Active_KillBoss then
      local restTime = self.m_BossMonsterdata.exceedtime - g_DataMgr:getServerTime()
      local h, m, s = getHMSWithSeconds(restTime)
      txt = string.format("BOSS击杀时间:%02d:%02d", m, s)
      self:setMapTitle(txt)
    elseif tag == TianDiQiShu_Active_End then
      self:setMapTitle("活动结束")
    else
      self:setMapTitle("天地奇书活动")
    end
  end
end
function tiandiqishu:setMapTitleActiveEnd()
  if self:isMap(g_MapMgr:getCurMapId()) == true then
    self:setMapTitle("活动结束")
  end
end
function tiandiqishu:EnterFb()
  local tInfo = data_CustomMapPos[19003]
  if tInfo and g_MapMgr then
    local mapId = tInfo.SceneID
    local pos = tInfo.JumpPos
    g_MapMgr:AutoRoute(mapId, {
      pos[1],
      pos[2]
    }, nil)
  end
end
function tiandiqishu:isMap(mapId)
  return tiandiqishu.mapId == mapId
end
function tiandiqishu:isInFb()
  return self.m_IsInMap
end
function tiandiqishu:isMission(missionId)
  return self.m_MissionIdToIdx[missionId] ~= nil or TianDiQiShu_BossMissionId == missionId
end
function tiandiqishu:isConfirmToLeave()
  local confirmBoxDlg = CPopWarning.new({
    title = "提示",
    text = "活动尚未结束，你确定要离开？（一旦离开活动地图，则无法继续参与本次活动）",
    confirmFunc = function()
      self:requestToLeaft()
    end,
    cancelText = "取消",
    confirmText = "确定",
    autoConfirmTime = autoConfirmTime,
    autoCancelTime = autoCancelTime,
    hideInWar = hideInWar
  })
  confirmBoxDlg:ShowCloseBtn(false)
end
function tiandiqishu:isAtKillingBoss()
  local restTime = self.m_BossMonsterdata.exceedtime - g_DataMgr:getServerTime()
  if restTime > 0 and self.m_BossMonsterdata.state >= 1 then
    return true
  else
    return false
  end
end
function tiandiqishu:isPrepareForActive()
  if self.m_Starttime == nil then
    self.m_Starttime = 0
  end
  local restTime = self.m_Starttime - g_DataMgr:getServerTime()
  print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNn", restTime)
  if restTime > 0 then
    return true
  else
    return false
  end
end
function tiandiqishu:flushIsInMap()
  if self.m_IsInMap and g_CMainMenuHandler then
    g_CMainMenuHandler:setTianDiQiShuTxt()
  end
end
function tiandiqishu:flusAllMission()
  self:flushSmallMonsterMissions()
  self:fluchBossMonsters()
end
function tiandiqishu:flushSmallMonsterMissions()
  if self.m_IsInMap == false or self:isMap(g_MapMgr:getCurMapId()) ~= true then
    printLog("tiandiqishu", "没有再副本状态的时候刷新")
    self:delMissionFuc(TDQS_DelMissionTag_Both)
    self:delTDQSMissionSchedule(TDQS_DelScheduleTag_AllTimer)
    return
  end
  self:delTDQSMissionSchedule(TDQS_DelScheduleTag_AllTimer)
  self:delMissionFuc(TDQS_DelMissionTag_Boss)
  for mIdx, data in pairs(self.m_LocSmallMonsterdata) do
    if data.state == -1 then
      print("==========》》》没有怪物数据 missionId", data.missionId)
      break
    end
    self:flushOneMissions(mIdx)
  end
end
function tiandiqishu:flushOneMissions(monsterIdx, loc)
  local data = self.m_LocSmallMonsterdata[monsterIdx]
  local warId
  if data == nil then
    printLog("tiandiqishu", "找不到怪物idx=%s", monsterIdx)
    return
  end
  local BossId = data.TypeId
  if data_QiShuMonster[BossId] then
    warId = data_QiShuMonster[BossId].WarDataId
  else
    warId = 23759
    print("=================data_QiShuMonster[BossId] 为空", BossId)
  end
  local isNeedDelNpc = true
  if data.state < 1 or data.state == nil then
    g_MissionMgr:Server_GiveUpMission(data.missionId)
  else
    isNeedDelNpc = false
    local locid = data.locid or {}
    if warId ~= nil and self.m_IsInMap == true then
      local mapView = g_MapMgr:getMapViewIns()
      if mapView then
        mapView:DeleteMonsterByMissionId(data.missionId)
        mapView:createMonsterForMissionTDQS(data.missionId, warId, locid, MapMonsterType_TiandiQiShu)
      end
    end
    local pro = g_MissionMgr:getMissionProgress(data.missionId)
    if pro == nil then
      g_MissionMgr:Server_MissionUpdated(data.missionId, 0)
    end
  end
  if isNeedDelNpc == true then
    local mapView = g_MapMgr:getMapViewIns()
    local shape = data_QiShuMonster[BossId]
    local npcId = self.m_MonsterShapeIdToNpcId[shape]
    if mapView ~= nil and npcId ~= nil then
      mapView:DeleteNormalNpc(npcId)
    end
  end
end
function tiandiqishu:fluchBossMonsters()
  if self.m_IsInMap == false or self:isMap(g_MapMgr:getCurMapId()) ~= true then
    self:delMissionFuc(TDQS_DelMissionTag_Both)
    self:delTDQSMissionSchedule(TDQS_DelScheduleTag_AllTimer)
    return
  end
  local data = self.m_BossMonsterdata
  if data == nil then
    printLog("tiandiqishu", "找不到怪物idx=%s", monsterIdx)
    return
  end
  local BossId = data.TypeId
  local isNeedDelNpc = true
  if data.state < 0 or data.state == nil then
    g_MissionMgr:Server_GiveUpMission(data.missionId)
  else
    isNeedDelNpc = false
    local locid = data.locid or {}
    local WarDataId
    if data_QiShuMonster[BossId] ~= nil then
      WarDataId = data_QiShuMonster[BossId].WarDataId
    else
      WarDataId = 23751
    end
    if WarDataId and self.m_IsInMap == true then
      local mapView = g_MapMgr:getMapViewIns()
      if mapView then
        mapView:DeleteMonsterByMissionId(data.missionId)
        mapView:createMonsterForMissionTDQS(data.missionId, WarDataId, locid, MapMonsterType_TiandiQiShu)
      end
    end
    local pro = g_MissionMgr:getMissionProgress(data.missionId)
    if pro == nil then
      g_MissionMgr:Server_MissionUpdated(data.missionId, 0)
    end
  end
  if isNeedDelNpc == true then
    local mapView = g_MapMgr:getMapViewIns()
    if mapView ~= nil then
      mapView:DeleteMonsterByMissionId(data.missionId)
    end
  end
  if data.state == 1 then
    self:delTDQSMissionSchedule(TDQS_DelScheduleTag_BossTimer)
    self.m_FrushBossHandler = scheduler.scheduleGlobal(handler(self, self.FrushBossTime), 1)
  else
    self:delTDQSMissionSchedule(TDQS_DelScheduleTag_BossTimer)
  end
end
function tiandiqishu:FrushBossTime()
  print("FFFFFFFFFFFFFFFFFFFFFFBoss定时器")
  local text = ""
  if self:isAtKillingBoss() == true then
    local restTime = self.m_BossMonsterdata.exceedtime - g_DataMgr:getServerTime()
    local h, m, s = getHMSWithSeconds(restTime)
    text = string.format("BOSS击杀时间:%02d:%02d", m, s)
    if g_CMainMenuHandler and tiandiqishu.ActiveEnd ~= true then
      g_CMainMenuHandler:setTianDiQiShuTxt(text)
    end
  else
    self:flusAllMission()
    if self.m_isCanKillMonster == true then
      self:setMapTitleAtTop(TianDiQiShu_Active_KillSmallMonster)
    end
  end
end
function tiandiqishu:FrushTimeBeforeActive()
  print("TTTTTTTTTTTTTTTTTTT定时器没删除")
  if self:isMap(g_MapMgr:getCurMapId()) ~= true then
    return
  end
  local text = ""
  if self:isPrepareForActive() == true then
    local restTime = self.m_Starttime - g_DataMgr:getServerTime()
    local h, m, s = getHMSWithSeconds(restTime)
    text = string.format("活动开启倒计时:%02d:%02d", m, s)
    if g_CMainMenuHandler and tiandiqishu.ActiveEnd ~= true then
      g_CMainMenuHandler:setTianDiQiShuTxt(text)
    end
  else
    self.m_isCanKillMonster = true
    self:flusAllMission()
    self:setMapTitleAtTop(TianDiQiShu_Active_KillSmallMonster)
  end
end
function tiandiqishu:EnterFbSucceed(starttime)
  self.m_Starttime = starttime or 0
  self.m_IsInMap = true
  self:EnterFb()
  if self.m_isCanKillMonster == false then
    self:delTDQSMissionSchedule(TDQS_DelScheduleTag_PrepareTimer)
    self.m_schedulerBeforActive = scheduler.scheduleGlobal(handler(self, self.FrushTimeBeforeActive), 1)
  end
  if g_CMainMenuHandler then
    g_CMainMenuHandler:setIsShowTianDiQiShu(self:isMap(g_MapMgr:getCurMapId()))
  end
  self:FrushTimeBeforeActive()
  if tiandiqishu.ActiveEnd == true then
    self:setMapTitleAtTop(TianDiQiShu_Active_End)
  elseif tiandiqishu.isInHuoDong == false then
    self:setMapTitleAtTop()
  end
end
function tiandiqishu:touchExitButton(exitType)
  if exitType ~= 1 then
    if tiandiqishu.isInHuoDong == true and self.m_isCanKillMonster == true then
      self:isConfirmToLeave()
    else
      self:requestToLeaft()
    end
  end
end
function tiandiqishu:requestToLeaft()
  netsend.netactivity.requestToLeaveTianDiQiShuFb()
end
function tiandiqishu:LeaveTianDiQiShuLeaveFb()
  self.m_IsInMap = false
  tiandiqishu.isInHuoDong = false
  self.m_Starttime = 0
  self:delTDQSMissionSchedule(TDQS_DelScheduleTag_PrepareTimer)
  self:delMissionFuc(TDQS_DelMissionTag_Both)
  self:setSmallMonsterOrgData()
end
function tiandiqishu:requestToStart()
  netsend.netactivity.requestEnterTianDiQiShuFb()
end
function tiandiqishu:canJumpMap()
  if g_MapMgr:IsInTianDiQiShuMap() then
    ShowNotifyTips("该地图无法使用传送功能")
    return false
  else
    return true
  end
end
function tiandiqishu:monsterOptionTouch(missionId)
  local id = 0
  local MonsterName = ""
  local BossId = 0
  local mapView = g_MapMgr:getMapViewIns()
  if mapView == nil then
    return
  end
  local MonsterId = mapView:getMonsterIdByMission(missionId)
  if MonsterId ~= nil then
    local MonsterObj = mapView:getMonster(MonsterId)
    if missionId ~= TianDiQiShu_BossMissionId then
      local index = self.m_MissionIdToIdx[missionId]
      id = self.m_LocSmallMonsterdata[index].id
      BossId = self.m_LocSmallMonsterdata[index].TypeId
      if data_QiShuMonster[BossId] == nil then
        print("============>>小怪数据出错", BossId)
        return
      end
      MonsterName = data_QiShuMonster[BossId].Name
    else
      id = self.m_BossMonsterdata.id
      BossId = self.m_BossMonsterdata.TypeId
      if data_QiShuMonster[BossId] == nil then
        print("============>>Boss数据出错", BossId)
        return
      end
      MonsterName = data_QiShuMonster[BossId].Name
    end
    CMainUIScene.Ins:ShowMonsterView(MonsterObj:getMonsterTypeId(), MapMonsterType_TiandiQiShu, function()
      netsend.netactivity.requestStarToFightTianDiQiShu(id)
    end, MonsterName)
  else
    print("=======>>地图上没有创建任务怪物")
  end
end
function tiandiqishu:delAllSmallMissions()
  for mIdx, data in pairs(self.m_LocSmallMonsterdata) do
    g_MissionMgr:Server_GiveUpMission(data.missionId)
    local mapView = g_MapMgr:getMapViewIns()
    if mapView then
      mapView:DeleteMonsterByMissionId(data.missionId)
    end
  end
  g_MissionMgr:FlushCanAcceptMission()
end
function tiandiqishu:delBossMission()
  g_MissionMgr:Server_GiveUpMission(TianDiQiShu_BossMissionId)
  local mapView = g_MapMgr:getMapViewIns()
  if mapView then
    mapView:DeleteMonsterByMissionId(TianDiQiShu_BossMissionId)
  end
end
function tiandiqishu:delMissionFuc(tag)
  if tag == TDQS_DelMissionTag_SmallMonster then
    self:delAllSmallMissions()
  elseif tag == TDQS_DelMissionTag_Boss then
    self:delBossMission()
  else
    self:delAllSmallMissions()
    self:delBossMission()
  end
end
function tiandiqishu:delTDQSMissionSchedule(tag)
  if tag == TDQS_DelScheduleTag_PrepareTimer then
    if self.m_schedulerBeforActive then
      scheduler.unscheduleGlobal(self.m_schedulerBeforActive)
      self.m_schedulerBeforActive = nil
    end
  elseif tag == TDQS_DelScheduleTag_BossTimer then
    if self.m_FrushBossHandler then
      scheduler.unscheduleGlobal(self.m_FrushBossHandler)
      self.m_FrushBossHandler = nil
    end
  elseif self:isPrepareForActive() ~= true or tiandiqishu.ActiveEnd == true or self.m_IsInMap == false or self.m_isCanKillMonster == true then
    if self.m_schedulerBeforActive then
      scheduler.unscheduleGlobal(self.m_schedulerBeforActive)
      self.m_schedulerBeforActive = nil
    end
    if self.m_FrushBossHandler then
      scheduler.unscheduleGlobal(self.m_FrushBossHandler)
      self.m_FrushBossHandler = nil
    end
  end
end
function tiandiqishu:OnMessage(msgSID, ...)
  if msgSID == MsgID_MapLoading_Finished and self.m_IsInMap == true and self:isMap(g_MapMgr:getCurMapId()) == true then
    if tiandiqishu.ActiveEnd == true then
      self:setMapTitleAtTop(TianDiQiShu_Active_End)
    elseif tiandiqishu.isInHuoDong == false then
      self:setMapTitleAtTop()
    end
    self:flusAllMission()
    g_MissionMgr:ShowDoubleExpSetView(data_Variables.TianDiQiShuDb or 4, 1)
    if self:isAtKillingBoss() == true then
      self:setMapTitleAtTop(TianDiQiShu_Active_KillBoss)
    elseif self:isPrepareForActive() == true and tiandiqishu.isInHuoDong == false then
      self:setMapTitleAtTop(TianDiQiShu_Active_Prepare)
    elseif self.m_isCanKillMonster == true and tiandiqishu.isInHuoDong == true then
      self:setMapTitleAtTop(TianDiQiShu_Active_KillSmallMonster)
    elseif tiandiqishu.ActiveEnd == true then
      self:setMapTitleAtTop(TianDiQiShu_Active_End)
    end
  end
end
function tiandiqishu:Clean()
  if self.m_IsInMap == true then
    self.m_IsInMap = false
    self:delMissionFuc(TDQS_DelMissionTag_Both)
  end
  self:delTDQSMissionSchedule(TDQS_DelScheduleTag_AllTimer)
  self:RemoveAllMessageListener()
end
return tiandiqishu
