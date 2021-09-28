if g_MonsterId_Inc == nil then
  g_MonsterId_Inc = 0
end
function GetNextMonsterId()
  g_MonsterId_Inc = (g_MonsterId_Inc + 1) % 1000000000
  return g_MonsterId_Inc
end
ForceDelRoleTime = 30
PosXForForceSyncAfterLongTime = 1
SceneSyncType_Split = 1
SceneSyncType_Whold = 2
AllMapScaleNum = 0.8
DynamicCreateAndReleaseDetectDistance = 150
MapMgr = class(".MapMgr", nil)
function MapMgr:ctor()
  self.m_LastMapid = nil
  self.m_CurMapId = nil
  self.m_MapView = nil
  self.m_IsMapLoading = false
  self.m_MapStatusSave = {}
  self.m_ReqPlayerInfoList = {}
  self.m_ReqPlayerInfoDict = {}
  self.m_ReqPlayerInfoTimer = 5
  self.m_ReqPlayerInfoNum = 1
  self.m_ReqPlayerInfoCnt = 0
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Device)
  self:ListenMessage(MsgID_MapLoading)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_ReConnect)
  self:ListenMessage(MsgID_MapScene)
  self.m_IsFirstLoadMap = true
  self.m_IsOnlyShowCaptainForOtherTeam = false
  self.m_EnterGuajiParam = nil
  self.m_AutoRouteParam = nil
  self.m_isAutoRoute = false
  self.m_FbTeleporterInfo = nil
  self.m_TempLoadNpcCount = {}
  self.m_TempLoadNpcChanged = false
  self.m_IsNeedShowLoading = isNeedMapLoading()
  print("self.m_IsNeedShowLoading:", self.m_IsNeedShowLoading)
  self.m_AllSpriteObj = {}
  self.m_IsShowLoading = false
  self.m_DynamicNpc = {}
  self.m_DynamicActiveNpc = {}
  self.m_DynamicTreasure = {}
  self.m_CaptainTopStatus = {}
  self.m_PlayerWarStatus = {}
  self.m_MapSizes = {}
  self.m_WorldTeleporterPosForMap = {}
  for tId, tInfo in pairs(data_WorldMapTeleporter) do
    local mapId = tInfo.tomap
    if self.m_WorldTeleporterPosForMap[mapId] == nil then
      self.m_WorldTeleporterPosForMap[mapId] = tId
    end
  end
  self.m_ZoneMapId = {}
  self.m_LastFlushPlayerZone = {-1, -1}
  self.m_LastFlushPlayerZoneId = nil
  self.m_LastSendPlayerZoneId = nil
  self:InitSyncPos()
  self:InitTeamWalk()
  self:InitInvalidRoleInMap()
  self.m_CacheForceParam = nil
  self.m_SceneSyncType = {}
  self.m_SchedulerHandler = scheduler.scheduleUpdateGlobal(handler(self, self.frameUpdate))
  self:resetDynamicCreateAndReleaseRoles()
end
function MapMgr:frameUpdate(dt)
  self:UpdateSyncPos(dt)
  self:UpdateTeamWalk(dt)
  self:UpdateInvalidRoleInMap(dt)
  self:UpdateReqPlayerInfoList(dt)
  if self.m_isNeedForceDetectDynamicCreateAndRelease then
    self:forceDetectDynamicCreateAndRelease()
  end
end
function MapMgr:getIsMapLoading()
  return self.m_IsMapLoading
end
function MapMgr:isInDayanta()
  return activity.dayanta:isDayantaMapId(self.m_CurMapId)
end
function MapMgr:isShowMapLoading()
  return self.m_IsShowLoading
end
function MapMgr:getRole(pid)
  if self.m_MapView then
    return self.m_MapView:getRole(pid)
  end
  return nil
end
function MapMgr:setSceneSyncType(syncTypes)
  self.m_SceneSyncType = {}
  for i, v in ipairs(syncTypes) do
    local typ = v.no
    local mapId = v.sid
    if mapId ~= nil and typ ~= nil then
      self.m_SceneSyncType[tostring(mapId)] = typ
    end
  end
end
function MapMgr:getSceneSyncTypeByMapId(mapId)
  local d = self.m_SceneSyncType[tostring(mapId)]
  if d ~= nil then
    return d
  end
  return SceneSyncType_Split
end
function MapMgr:LoadMapById(mapId, gridPos, posType, extraParam, force, initGuaji)
  print("MapMgr:LoadMapByIdyyyy:", self.m_IsMapLoading, mapId)
  if g_LocalPlayer == nil then
    return
  end
  self.m_GuajiAfterLoadMapFlag = initGuaji or false
  if self.m_IsMapLoading == true then
    if force then
      self.m_CacheForceParam = {
        mapId,
        gridPos,
        posType,
        extraParam,
        force,
        initGuaji
      }
    end
    return
  end
  print("MapMgr:LoadMapById:", mapId, gridPos, posType, extraParam)
  if self.m_IsFirstLoadMap == false then
    local myPid = g_LocalPlayer:getPlayerId()
    local myTeamId = g_LocalPlayer:getObjProperty(1, PROPERTY_TEAMID)
    local allPlayers = g_DataMgr:getAllPlayers() or {}
    local delList = {}
    for pid, player in pairs(allPlayers) do
      local teamId = player:getObjProperty(1, PROPERTY_TEAMID)
      if pid ~= myPid and (teamId == 0 or teamId ~= myTeamId) then
        local mapId_ = player:getMapPosInfo()
        if mapId_ == mapId then
          player:setMapPosInfo(nil)
          print("--->>>1 set mapid nil:", pid)
        end
        delList[#delList + 1] = pid
      end
    end
    for i, pid in ipairs(delList) do
      print("--->>>delete pid:", pid)
      g_DataMgr:delPlayer(pid)
    end
    self.m_PlayerWarStatus = {}
    self:ClearReqPlayerInfoList()
    if self.m_CurMapId ~= mapId then
      self.m_DynamicNpc = {}
      self.m_DynamicTreasure = {}
    end
  else
    self.m_IsFirstLoadMap = false
  end
  if OnlyShowCaptainMapId[tostring(mapId)] then
    self.m_IsOnlyShowCaptainForOtherTeam = true
  else
    self.m_IsOnlyShowCaptainForOtherTeam = false
  end
  print("MapMgr:LoadMapById self.m_CurMapId, mapId:", self.m_CurMapId, mapId)
  if force == true or self.m_CurMapId ~= mapId then
    self.m_LastMapid = self.m_CurMapId
    self.m_CurMapId = mapId
    print("--->>>MsgID_MapScene_ChangedMap-2", g_LocalPlayer:getPlayerId(), mapId, self.m_LastMapid)
    SendMessage(MsgID_MapScene_ChangedMap, g_LocalPlayer:getPlayerId(), mapId, self.m_LastMapid)
    for teamId, teamers in pairs(self.m_AllTeams) do
      if myTeamId ~= teamId then
        self:TeamDismiss(teamId)
      end
    end
    self:reflushAllFollowRelations()
  else
    self.m_LastMapid = self.m_CurMapId
    self.m_CurMapId = mapId
  end
  self:resetDynamicCreateAndReleaseRoles()
  if g_CMainMenuHandler and activity.tianting:isMap(self.m_CurMapId) ~= true then
    g_CMainMenuHandler:setIsShowTianting(false)
  end
  if g_CMainMenuHandler and activity.tiandiqishu:isMap(self.m_CurMapId) ~= true then
    g_CMainMenuHandler:setIsShowTianDiQiShu(false)
  end
  self.m_MapViewParam = {
    gridPos,
    posType,
    extraParam
  }
  self.m_IsMapLoading = true
  if CMainUIScene.Ins == nil then
    CMainUIScene.new(handler(self, self.MainUISceneEnter))
  else
    self:MainUISceneEnter()
  end
end
function MapMgr:getMapSize(mapId)
  if self.m_MapSizes[mapId] then
    return self.m_MapSizes[mapId]
  end
  local mapInfo = data_MapInfo[mapId]
  local mapData = MapConfigData[mapInfo.mapfile]
  local s = mapData.gridNum
  self.m_MapSizes[mapId] = {
    s[1],
    s[2]
  }
  return self.m_MapSizes[mapId]
end
function MapMgr:isMapLoaded()
  if self.m_MapView then
    return not self.m_MapView:isMapLoading()
  end
  return false
end
function MapMgr:getCurMapId()
  if self.m_CurMapId == nil then
    local initMapAndPos = g_DataMgr:getInitMapAndPos() or {}
    return initMapAndPos[1] or 1
  end
  return self.m_CurMapId
end
function MapMgr:getMapViewIns()
  return self.m_MapView
end
function MapMgr:getIsOnlyShowCaptainForOtherMap()
  return self.m_IsOnlyShowCaptainForOtherTeam
end
function MapMgr:convertPosInMap(posTable, posType)
  if self.m_MapView then
    return self.m_MapView:getPosByType(posTable, posType)
  end
  return nil
end
function MapMgr:getLocalPlayerPos()
  if self.m_MapView then
    return self.m_MapView:getLocalRolePos()
  end
  return nil
end
function MapMgr:stopLocalPlayerMove()
  if self.m_MapView then
    return self.m_MapView:stopLocalPlayerMove()
  end
end
function MapMgr:IsInBangPaiWarMap()
  local currMapId = self:getCurMapId()
  return self:checkIsBpWarMap(currMapId)
end
function MapMgr:checkIsBpWarMap(currMapId)
  return currMapId >= 200 and currMapId <= 209
end
function MapMgr:IsInYiZhanDaoDiMap()
  local currMapId = self:getCurMapId()
  return currMapId == MapId_YiZhanDaoDi
end
function MapMgr:IsInXueZhanShaChangMap()
  local currMapId = self:getCurMapId()
  return currMapId == MapId_XueZhanShaChang
end
function MapMgr:IsInDuelMap()
  local currMapId = self:getCurMapId()
  return currMapId == MapId_DuelMap
end
function MapMgr:IsInTianDiQiShuMap()
  local currMapId = self:getCurMapId()
  return currMapId == MapId_TianDiQiShuMap
end
function MapMgr:FlushBpWarAttacker()
  if self.m_MapView then
    self.m_MapView:FlushBpWarAttacker()
  end
end
function MapMgr:AskToEnterGuaji(mapId, x, y, dir, autoGj)
  local pos = {
    x,
    y,
    dir
  }
  if x == nil then
    pos = nil
  end
  local data = {pos = pos, autoGj = autoGj}
  self.m_EnterGuajiParam = data
  netsend.netguaji.enterGuajiMap(mapId)
end
function MapMgr:AutoRouteToNpc(npcId, cbListener, justJump)
  TellSerToStopGuaji()
  local npcInfo = data_NpcInfo[npcId] or {}
  local pos = npcInfo.pos
  if pos == nil then
    if cbListener then
      cbListener(false)
    end
    printLog("ERROR", "找不到寻路的NPC[%d]", npcId)
    return
  end
  local jumpPos = npcInfo.jumpPos
  if jumpPos == nil then
    jumpPos = pos
  end
  local mapId = pos[1]
  if justJump == true then
    self:AutoRoute(mapId, {
      pos[2],
      pos[3]
    }, cbListener, npcId, {
      pos[2],
      pos[3]
    }, nil, true, RouteType_Npc)
  else
    self:AutoRoute(mapId, {
      pos[2],
      pos[3]
    }, cbListener, npcId, {
      pos[2],
      pos[3]
    }, {
      jumpPos[2],
      jumpPos[3]
    }, true, RouteType_Npc)
  end
end
function MapMgr:getIsAutoRoute()
  return self.m_isAutoRoute
end
function MapMgr:AutoRoute(mapId, gridPos, cbListener, npcId, npcPos, jumpPos, adjustPos, routeType, jumpType)
  TellSerToStopGuaji()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if activity.tianting:isInFb() and mapId ~= activity.tianting.mapId then
    ShowNotifyTips("天庭任务中无法使用该功能")
    return
  end
  if activity.tiandiqishu:isInFb() and mapId ~= activity.tiandiqishu.mapId then
    ShowNotifyTips("天地奇书中无法使用该功能")
    return
  end
  if self:isInDayanta() == true then
    if activity.dayanta:getIsAllComplete() ~= true and activity.dayanta:isDayantaMapId(mapId) == false then
      ShowNotifyTips("大雁塔副本中无法使用该功能")
      return
    end
  elseif g_LocalPlayer:getNormalTeamer() ~= true or activity.tianting.mapId == self.m_CurMapId and not activity.tianting:isInFb() or activity.tiandiqishu.mapId == self.m_CurMapId and activity.tiandiqishu:isInFb() ~= false or g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
  else
    if activity.tiandiqishu:isInFb() then
      return
    end
    local msgTxt = "你已跟随队长中，不能跳转"
    ShowNotifyTips(msgTxt)
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    if jumpType == 1 then
      local dlg = CPopWarning.new({
        title = "提示",
        text = "帮战开始后退出战场将不能再次回到战场！你确定要退出帮战战场吗？",
        confirmFunc = function()
          netsend.netbangpaiwar.quitBpFight()
        end,
        confirmText = "确定",
        cancelText = "取消",
        hideInWar = true
      })
      dlg:ShowCloseBtn(false)
    else
      ShowNotifyTips("帮战中无法使用此功能")
    end
    return
  end
  if not activity.yzdd:canJumpMap() then
    return
  end
  if not g_DuleMgr:canJumpMap() then
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("处于战斗中，不能跳转")
    return
  end
  if self.m_AutoRouteParam then
    local listener = self.m_AutoRouteParam[3]
    if listener then
      listener(false)
    end
  end
  if adjustPos == true or routeType == RouteType_Monster then
    local gx = gridPos[1]
    local gy = gridPos[2]
    local rdlist = {}
    for rdx = -2, 2 do
      for rdy = 0, 2 do
        if 2 <= math.abs(rdx) + math.abs(rdy) then
          local tx = gx + rdx
          local ty = gy + rdy
          rdlist[#rdlist + 1] = {tx, ty}
        end
      end
    end
    if #rdlist > 0 then
      gridPos = rdlist[math.random(1, #rdlist)]
    else
      gridPos = {gx, gy}
    end
  end
  if jumpPos == nil then
    jumpPos = gridPos
  end
  self.m_AutoRouteParam = {
    mapId,
    gridPos,
    cbListener,
    npcId,
    npcPos,
    jumpPos,
    adjustPos,
    routeType
  }
  SendMessage(MsgID_MapScene_AutoRoute)
  if self:IsNeedLoadMap_(self.m_CurMapId, mapId, gridPos, MapPosType_EditorGrid, jumpPos, MapPosType_EditorGrid, routeType) == false then
    self:AutoRouteInCurMap_(false)
  else
    netsend.netmap.reqPlayerHide()
    printLog("LOADMAP", "MapMgr:AutoRoute")
    self:LoadMapById(mapId, jumpPos, MapPosType_EditorGrid)
  end
end
function MapMgr:AutoRouteWithWorldTeleporter(mapId, gridPos, cbListener, routeType)
  TellSerToStopGuaji()
  local tId = self.m_WorldTeleporterPosForMap[mapId]
  local tInfo = data_WorldMapTeleporter[tId]
  local jumpPos
  if tInfo then
    local toPos = tInfo.toPos
    if toPos and #toPos > 0 then
      jumpPos = toPos[math.random(1, #toPos)]
    end
  end
  if jumpPos == nil then
    jumpPos = gridPos
  end
  g_MapMgr:AutoRoute(mapId, gridPos, cbListener, nil, nil, jumpPos, nil, routeType)
end
function MapMgr:AutoRouteInCurMap_(isLoadMap)
  TellSerToStopGuaji()
  local mapId, gridPos, cbListener, npcId, npcPos, jumpPos, adjustPos, routeType = unpack(self.m_AutoRouteParam, 1, 8)
  self.m_AutoRouteParam = nil
  local function routeResult(isSucceed)
    if cbListener then
      cbListener(isSucceed)
    end
    if isSucceed then
      if npcPos ~= nil then
        self.m_MapView:setLocalRoleFacetoGridPos(npcPos, true)
      elseif gridPos[3] ~= nil then
        self.m_MapView:setLocalRoleFacetoDir(gridPos[3])
      end
    end
  end
  if npcId then
    self.m_MapView:setNpcSelectedByNpcId(npcId)
    if isLoadMap == false and self.m_MapView:CanNpcIdUse(npcId) then
      self.m_MapView:stoptAutoRoute()
      routeResult(true)
    else
      self.m_MapView:StartAutoRoute(function(isSucceed)
        routeResult(isSucceed)
      end, gridPos, MapPosType_EditorGrid, nil, adjustPos or routeType == RouteType_Monster)
    end
  elseif npcPos ~= nil and isLoadMap == false and self.m_MapView:isDstInTouchDis(npcPos[1], npcPos[2], MapPosType_EditorGrid) then
    self.m_MapView:stoptAutoRoute()
    routeResult(true)
  else
    self.m_MapView:StartAutoRoute(function(isSucceed)
      routeResult(isSucceed)
    end, gridPos, MapPosType_EditorGrid, nil, adjustPos or routeType == RouteType_Monster)
  end
end
function MapMgr:AutoRouteWithCustomId(customId, cbListener, adjustPos, routeType)
  TellSerToStopGuaji()
  local data = data_CustomMapPos[customId]
  if data == nil then
    if cbListener then
      cbListener(false)
    end
    return
  end
  self:AutoRoute(data.SceneID, {
    data.WarPos[1],
    data.WarPos[2]
  }, cbListener, nil, {
    data.WarPos[1],
    data.WarPos[2]
  }, {
    data.JumpPos[1],
    data.JumpPos[2]
  }, adjustPos, routeType)
end
function MapMgr:AutoRouteFB(fbInfo)
  if fbInfo == nil then
    g_FbInterface.ShowFuBenCatch()
  else
    do
      local isInTeamAndIsNotCaptain = false
      if g_LocalPlayer:getPlayerIsInTeam() and not g_LocalPlayer:getPlayerInTeamAndIsCaptain() then
        isInTeamAndIsNotCaptain = true
      end
      local fbId, catchId, iSuper, param = unpack(fbInfo, 1, 4)
      local bigMapId, tX, tY, tD = unpack(data_getCatchGotoMonsterPos(fbId, catchId), 1, 4)
      local nX, nY, nD = unpack(data_getCatchMonsterPos(fbId, catchId), 1, 3)
      local function fightMonster(isSucceed)
        if isSucceed then
          if data_getCatchNeedTeamFlag(fbId, catchId) then
            local bossTypeId
            local warID = data_getCatchWarID(fbId, catchId)
            if warID ~= nil then
              bossTypeId, _ = data_getBossForWar(warID)
            end
            CMainUIScene.Ins:ShowMonsterView(bossTypeId, MapMonsterType_GuanKa, function()
              netsend.netguanka.askToFightNpc(fbId, catchId)
            end)
          else
            netsend.netguanka.askToFightNpc(fbId, catchId)
          end
        end
      end
      self:AutoRoute(bigMapId, {nX, nY}, fightMonster, nil, {nX, nY}, {tX, tY}, nil, RouteType_Monster)
    end
  end
end
function MapMgr:LoadMapWithWorldMapTeleporter(teleporterId, listener)
  local tInfo = data_WorldMapTeleporter[teleporterId]
  if tInfo then
    if tInfo.tomap == -1 or #tInfo.toPos < 1 then
      printLog("MapMgr", "传送点还没有开放:%d", teleporterId)
    else
      local len = #tInfo.toPos
      local pos = tInfo.toPos[math.random(1, len)]
      g_MapMgr:AutoRoute(tInfo.tomap, {
        pos[1],
        pos[2]
      }, listener)
    end
  end
end
function MapMgr:jumpMapForCBT(mapId, pos, cbListener)
  self:AutoRouteWithWorldTeleporter(mapId, pos, cbListener)
end
function MapMgr:IsNeedLoadMap_(curMapId, newMapId, dstPosTable, dstPosType, jumpPos, jumpType, routeType)
  if curMapId == newMapId and self.m_MapView then
    if activity.dayanta:isDayantaMapId(curMapId) or activity.tianting:isMap(curMapId) or activity.tiandiqishu:isMap(curMapId) then
      return false
    end
    if curMapId ~= MapId_Changan and routeType ~= nil and DontJumpMapRouteType[routeType] == 1 then
      return false
    end
    local cx, cy = self.m_MapView:getLocalRolePos()
    local dx, dy = self.m_MapView:getPosByType(dstPosTable, dstPosType)
    local dis = math.sqrt(math.pow(cx - dx, 2) + math.pow(cy - dy, 2))
    if dis <= display.width * 2 / 3 then
      return false
    elseif jumpPos ~= nil and jumpType ~= nil then
      local jx, jy = self.m_MapView:getPosByType(jumpPos, jumpType)
      local dstDis = math.sqrt(math.pow(jx - dx, 2) + math.pow(jy - dy, 2))
      print("-->> dis, dstDis:", dis, dstDis)
      if dis < dstDis then
        return false
      end
    end
  end
  return true
end
function MapMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_EnterBackground or msgSID == MsgID_ReConnect_Ready_ReLogin then
    if g_DataMgr and g_TeamMgr then
      print("退后台 或者 准备重连，删除其他玩家")
      local allPlayers = g_DataMgr:getAllPlayers() or {}
      local myTeamId = g_TeamMgr:getLocalPlayerTeamId()
      for pid, playerIns in pairs(allPlayers) do
        if playerIns ~= g_LocalPlayer then
          local teamId = g_TeamMgr:getPlayerTeamId(pid)
          if teamId == 0 or myTeamId ~= teamId then
            self:DelPlayerFromMap(pid, playerIns)
          elseif msgSID == MsgID_ReConnect_Ready_ReLogin then
            self:PlayerWarStatusChanged(pid, 0)
          end
          print("--->>>2 set mapid nil:", pid)
          playerIns:setMapPosInfo(nil)
        end
      end
    end
    if msgSID == MsgID_ReConnect_Ready_ReLogin then
      self.m_IsFirstLoadMap = true
      self.m_PlayerWarStatus = {}
    end
  elseif msgSID == MsgID_MapLoading_Progress then
    if self.m_IsShowLoading == true then
      local arg = {
        ...
      }
      CMainUIScene.Ins:setLoadProgress(arg[1])
    end
  elseif msgSID == MsgID_Scene_War_Exit then
    if self.m_MapView then
      local teamId = g_TeamMgr:getLocalPlayerTeamId()
      print("-->>teamId:", teamId)
      if teamId and teamId ~= 0 then
        local teamers = g_TeamMgr:getTeamInfo(teamId)
        print("-->>teamers:", teamers)
        if teamers then
          for i = 1, #teamers do
            local id = teamers[i]
            print("\t\t-->>id:", id)
            local player = g_DataMgr:getPlayer(id)
            print("\t\t-->>player:", player)
            if player then
              local isNeedSet = true
              if g_TeamMgr:getPlayerIsCaptain(id) == false then
                local follow = player:getIsFollowTeamCommon()
                print("\t\t-->>follow:", follow)
                if follow < 0 then
                  isNeedSet = false
                end
              end
              print("\t\t-->>isNeedSet:", isNeedSet)
              if isNeedSet then
                local role = self.m_MapView:getRole(id)
                print("\t\t-->>role:", role)
                if role then
                  role:setHide(false)
                end
              end
            end
          end
        end
      end
      local arg = {
        ...
      }
      local warType = arg[2]
      local isWatch = arg[3]
      local isReview = arg[4]
      if warType == WARTYPE_GuaJi and isWatch == false and isReview == false and g_LocalPlayer:getGuajiState() == GUAJI_STATE_ON then
        StartGuaJi()
      end
    end
  elseif msgSID == MsgID_MapLoading_Finished then
    print("-->> OnMessage:MsgID_MapLoading_Finished")
    if self.m_IsShowLoading == true then
      CMainUIScene.Ins:setShowMapLoading(false)
    else
      self:ShowScreenAniAction()
    end
    self.m_IsMapLoading = false
    if data_getIsGuajiMap(self.m_CurMapId) then
      ShowNotifyTips("你进入了挂机地图")
    end
    scheduler.performWithDelayGlobal(function()
      if self.m_GuajiAfterLoadMapFlag == true then
        TellSerToStartGuaji()
      elseif self.m_AutoRouteParam then
        self:AutoRouteInCurMap_(true)
      end
    end, 0)
    self:DetectLoadNpc()
    self.m_DetectTeamerCreated = {}
    self:craeteAllTeamerInMap()
    self:LoadPlayerAfterMapLoad()
    self:DetectAllTeamWalk()
    self:_SyncLocalRolePos(true)
    ZhuaGui.flushCreateMonster()
    BangPaiChuMo.flushCreateMonster()
    BangPaiTotem.flushCreateMonster()
    if g_LocalPlayer then
      g_LocalPlayer:flushCatchMonster()
    end
    XiuLuo.flushCreateMonster()
    activity.xingxiu:fluchMonsters()
    activity.shituchangan:fluchMonsters()
    self:detectLoadDynamicNpc()
    self:detectLoadDynamicActiveNpc()
    self:detectLoadDynamicTreasure()
    self:flushMissionMonsters()
    if g_DataMgr.isPlayingCG ~= true then
      soundManager.playSceneMusic(self.m_CurMapId)
    end
    if g_HunyinMgr then
      g_HunyinMgr:UpdateHuaCheState()
    end
    self:CalculateZoneMap()
    if activity.tianting:isMap(self.m_CurMapId) then
      g_MissionMgr:ShowDoubleExpSetView(data_Variables.TianTing_CostDp or 4, 2)
      if g_CMainMenuHandler then
        g_CMainMenuHandler:setIsShowTianting(true)
      end
    end
    if activity.tiandiqishu:isMap(self.m_CurMapId) and g_CMainMenuHandler then
      g_CMainMenuHandler:setIsShowTianDiQiShu(true)
    end
    if g_CMainMenuHandler and (activity.tianting:isMap(self.m_LastMapid) or activity.dayanta:isDayantaMapId(self.m_LastMapid) or activity.tianting:isMap(self.m_CurMapId) or activity.dayanta:isDayantaMapId(self.m_CurMapId) or activity.tiandiqishu:isMap(self.m_LastMapid) or activity.tiandiqishu:isMap(self.m_CurMapId)) then
      g_CMainMenuHandler:NeedFlushMission()
    end
    if self.m_CacheForceParam then
      scheduler.performWithDelayGlobal(function()
        if self.m_CacheForceParam then
          local mapId, gridPos, posType, extraParam, force, initGuaji = unpack(self.m_CacheForceParam, 1, 6)
          self.m_CacheForceParam = nil
          self:LoadMapById(mapId, gridPos, posType, extraParam, force, initGuaji)
        end
      end, 0.1)
    end
  elseif msgSID == MsgID_MapScene_SyncPlayerTypeChaned then
    local arg = {
      ...
    }
    self:SyncPlayerTypeChanged(arg[1])
  elseif msgSID == MsgID_Scene_CanGotoGuajiMap then
    local arg = {
      ...
    }
    local mapId = arg[1]
    print("mapMgr  MsgID_Scene_CanGotoGuajiMap", mapId)
    local curMap = self:getCurMapId()
    if data_getIsGuajiMap(mapId) == false then
      ShowNotifyTips("不是挂机地图，不能挂机")
      return
    end
    if CanGuajiInMap(mapId) == false then
      return
    end
    if self.m_EnterGuajiParam ~= nil then
      if mapId == curMap then
        if self.m_EnterGuajiParam.autoGj == true then
          TellSerToStartGuaji()
        end
      else
        local pos = self.m_EnterGuajiParam.pos or data_GuaJi_Map[mapId].toPos
        self:LoadMapById(mapId, {
          pos[1],
          pos[2]
        }, MapPosType_EditorGrid, {
          initDir = pos[3]
        }, nil, self.m_EnterGuajiParam.autoGj)
      end
      self.m_EnterGuajiParam = nil
    end
  end
  local fid = self:GetFIDWithSID(msgSID)
  if fid == MsgID_Scene then
    self:FbViewStatusMsg(msgSID, ...)
  elseif fid == MsgID_Team then
    self:TeamMessage(msgSID, ...)
  end
end
function MapMgr:MainUISceneEnter(...)
  print("===>>>> MainUISceneEnter")
  if g_CMainMenuHandler then
    g_CMainMenuHandler:setIsShowDayanta(activity.dayanta:isDayantaMapId(self.m_CurMapId))
  end
  if g_FubenHandler ~= nil or g_WarScene ~= nil then
    CMainUIScene.Ins:setShowMapLoading(false)
    self.m_IsShowLoading = false
  elseif self.m_IsNeedShowLoading == true or self.m_MapView == nil then
    CMainUIScene.Ins:setShowMapLoading(true)
    CMainUIScene.Ins:setLoadProgress(0)
    self.m_IsShowLoading = true
  else
    CMainUIScene.Ins:setShowMapLoading(false)
    self:ShowScreenAni()
    self.m_IsShowLoading = false
  end
  if self.m_MapView then
    self.m_MapView:CleanSelf()
    self.m_MapView:CloseSelf()
    self.m_MapView = nil
  end
  self:LoadNewMap()
end
function MapMgr:LoadNewMap()
  ClearAllShowProgressBar()
  g_MemoryDetect:DetectRelease()
  self.m_CaptainTopStatus = {}
  if g_CurShowTalkView then
    g_CurShowTalkView:ShowFinished()
  end
  if self.m_LastMapid ~= self.m_CurMapId then
    SendMessage(MsgID_MapLoading_WillLoad, self.m_CurMapId)
  end
  self.m_MapView = CMapView.new(self.m_CurMapId, unpack(self.m_MapViewParam, 1, 3))
  CMainUIScene.Ins:addSubView({
    subView = self.m_MapView,
    zOrder = MainUISceneZOrder.map,
    isModelView = true
  })
  if g_FubenHandler ~= nil or g_WarScene ~= nil then
    self.m_MapView:setVisible(false)
  end
  if g_TeamMgr:localPlayerIsCaptain() == true then
    local x, y = self.m_MapView:getPosByType(self.m_MapViewParam[1], self.m_MapViewParam[2])
    if x > 0 and y > 0 then
      netsend.netmap.move(self.m_CurMapId, {x, y})
    end
  end
  local mapName = ""
  if data_MapInfo[self.m_CurMapId] then
    mapName = data_MapInfo[self.m_CurMapId].name
  end
  CMainUIScene.Ins:SetMapName(mapName)
end
function MapMgr:MapCleared(mapView)
  if self.m_MapView == mapView then
    self.m_MapView = nil
  end
end
function MapMgr:SaveMapAndRoleStatus(backGridPos)
  self.m_MapStatusSave.mapId = self.m_CurMapId
  if backGridPos == nil then
    local gx, gy = self.m_MapView:getLocalRoleGrid()
    backGridPos = {gx, gy}
  end
  self.m_MapStatusSave.roleGrid = backGridPos
end
function MapMgr:LoadMapFromSaveStatus()
  printLog("LOADMAP", "MapMgr:LoadMapFromSaveStatus")
  self:LoadMapById(self.m_MapStatusSave.mapId, self.m_MapStatusSave.roleGrid, MapPosType_Grid)
end
function MapMgr:MainRoleGridPosChange(oldGX, oldGY, gx, gy, pixelX, pixelY)
  if CMainUIScene.Ins ~= nil then
    CMainUIScene.Ins:SetMainRoleGridPosText(oldGX, oldGY, gx, gy)
    self:flushCurPlayerMapZone(gx, gy)
  end
  self:detectRoleCreateOrRelease(pixelX, pixelY)
end
function MapMgr:CalculateZoneMap()
  printLog("LOADMAP", "MapMgr:CalculateZoneMap")
  local mapId = self.m_CurMapId
  if mapId == nil then
    return
  end
  if self.m_ZoneMapId[mapId] == nil then
    self.m_ZoneMapId[mapId] = {}
    for tId, data in pairs(data_WorldMapTeleporter) do
      if type(data.headPosZone) == "table" and #data.headPosZone == 9 then
        local zone = data.headPosZone
        local _mapId = zone[1]
        if _mapId == mapId then
          local saveTable = {}
          self:getLinePoints(saveTable, zone[2], zone[3], zone[4], zone[5])
          self:getLinePoints(saveTable, zone[4], zone[5], zone[6], zone[7])
          self:getLinePoints(saveTable, zone[6], zone[7], zone[8], zone[9])
          self:getLinePoints(saveTable, zone[8], zone[9], zone[2], zone[3])
          local gridData = {}
          for y, xTable in pairs(saveTable) do
            local minx = 999999999999
            local maxx = -1
            for i, x in ipairs(xTable) do
              if x < minx then
                minx = x
              end
              if x > maxx then
                maxx = x
              end
            end
            gridData[y] = {minx, maxx}
          end
          self.m_ZoneMapId[mapId][tId] = gridData
        end
      end
    end
  end
  self.m_LastFlushPlayerZone = {-1, -1}
  self.m_LastFlushPlayerZoneId = nil
  self.m_LastSendPlayerZoneId = nil
  self:flushCurPlayerMapZone()
end
function MapMgr:getLinePoints(saveTable, x1, y1, x2, y2)
  local addPoint = function(t, x, y)
    y = math.floor(y)
    if t[y] == nil then
      t[y] = {x}
    else
      t[y][#t[y] + 1] = x
    end
  end
  x1, y1 = self.m_MapView:getGridByEditorGrid(x1, y1)
  x2, y2 = self.m_MapView:getGridByEditorGrid(x2, y2)
  local dx = x1 - x2
  local dy = y1 - y2
  addPoint(saveTable, x1, y1)
  if dx == 0 and dy == 0 then
  elseif math.abs(dx) > math.abs(dy) then
    local ddx = 1
    if dx > 0 then
      ddx = -1
    end
    local ddy = ddx * dy / dx
    local x = x1
    local y = y1
    for x_ = 1, math.abs(dx) do
      x = x + ddx
      y = y + ddy
      addPoint(saveTable, x, y)
    end
  else
    local ddy = 1
    if dy > 0 then
      ddy = -1
    end
    local ddx = ddy * dx / dy
    local x = x1
    local y = y1
    for y_ = 1, math.abs(dy) do
      x = x + ddx
      y = y + ddy
      addPoint(saveTable, x, y)
    end
  end
end
function MapMgr:flushCurPlayerMapZone(gx, gy)
  local worldMapId = self:getPlayerMapZone(gx, gy)
  if self.m_LastSendPlayerZoneId ~= worldMapId then
    self.m_LastSendPlayerZoneId = worldMapId
    SendMessage(MsgID_MapScene_MapZoneChanged, worldMapId)
    print("flushCurPlayerMapZone-->worldMapId:", worldMapId)
  end
end
function MapMgr:getPlayerMapZone(gx, gy)
  if gx == nil then
    local x, y = self:getLocalPlayerPos()
    if x == nil then
      return
    end
    gx, gy = self.m_MapView:getGridByPos(x, y)
  end
  if self.m_LastFlushPlayerZone[1] == gx and self.m_LastFlushPlayerZone[2] == gy then
    return self.m_LastFlushPlayerZoneId
  end
  self.m_LastFlushPlayerZoneId = nil
  self.m_LastFlushPlayerZone = {gx, gy}
  local mapId = self.m_CurMapId
  local zoneData = self.m_ZoneMapId[mapId]
  if zoneData then
    for worldId, data in pairs(zoneData) do
      local xZone = data[gy]
      if xZone and gx >= xZone[1] and gx <= xZone[2] then
        self.m_LastFlushPlayerZoneId = worldId
        return worldId
      end
    end
  end
  return nil
end
function MapMgr:isPlayerInBiwuchang(pid)
  if pid == nil then
    pid = g_LocalPlayer:getPlayerId()
  end
  if self.m_MapView == nil or pid == nil then
    return false
  end
  local tId = 118
  local d = data_WorldMapTeleporter[tId]
  if d.tomap ~= self.m_CurMapId then
    return false
  end
  local role = self.m_MapView:getRole(pid)
  if role then
    local x, y = role:getPosition()
    local gx, gy = self.m_MapView:getGridByPos(x, y)
    if tId == self:getPlayerMapZone(gx, gy) then
      return true
    end
  end
  return false
end
function MapMgr:getCanWalkPosForRoute(sx, sy, dx, dy)
  if self.m_MapView then
    return dx, dy, false
  end
  local gx, gy = self.m_MapView:getGridByPos(dx, dy)
  local sgx, sgy = self.m_MapView:getGridByPos(sx, sy)
end
function MapMgr:InitSyncPos()
  self.m_IsInFb = false
  self.m_FbOpenCount = 0
  self.m_SyncPosTime = 1.05
  self.m_SyncPosTimer = 0
  self.m_LastSyncPos = {-1, -1}
  self.m_SyncNormalTimes = 0
  self.m_LastSyncTime = 0
  self.m_CurSyncPlayerType = SyncPlayerType_Max
  self.m_SyncCaptainTimes = nil
  self.m_SyncCaptainPos = {}
  self.m_SyncCaptainFlag = 0
end
function MapMgr:UpdateSyncPos(dt)
  if not g_DataMgr:getIsSendFinished() then
    return
  end
  if self.m_IsInFb == false and self.m_MapView ~= nil then
    self.m_SyncPosTimer = self.m_SyncPosTimer - dt
    if self.m_SyncPosTimer <= 0 then
      if self.m_SyncCaptainTimes ~= nil and 0 <= self.m_SyncCaptainTimes and 0 >= self.m_SyncCaptainTimes then
        print("同步队长坐标----------->>>>>>:", self.m_SyncCaptainFlag)
        if self.m_SyncCaptainFlag == 1 then
          self:SyncPlayerPos(self.m_SyncCaptainPos, self.m_SyncCaptainFlag)
        else
          self:_SyncLocalRolePos(true, self.m_SyncCaptainFlag)
        end
        self.m_SyncCaptainTimes = self.m_SyncCaptainTimes + 1
      else
        print("self.m_SyncCaptainTimes :", self.m_SyncCaptainTimes)
        print("self.m_SyncCaptainFlag :", self.m_SyncCaptainFlag)
        self.m_SyncCaptainTimes = nil
        self:_SyncLocalRolePos()
      end
      self.m_SyncPosTimer = self.m_SyncPosTime
    end
  end
end
function MapMgr:_SyncLocalRolePos(isForce, withFlag)
  if self.m_IsMapLoading == true or self.m_MapView == nil or g_LocalPlayer == nil then
    return
  end
  if isForce == nil then
    isForce = false
  end
  if isForce == false and g_LocalPlayer:getNormalTeamer() == true then
    return
  end
  local x, y = self.m_MapView:getLocalRolePos()
  if x ~= nil and y ~= nil then
    x = math.round(x)
    y = math.round(y)
    local isSend = false
    if self.m_LastSyncPos[1] ~= x or self.m_LastSyncPos[2] ~= y then
      isSend = true
      self.m_SyncNormalTimes = 0
    elseif isForce ~= false or self.m_SyncNormalTimes <= 0 then
      isSend = true
    elseif self.m_LastSyncTime < g_DataMgr:getServerTime() - ForceDelRoleTime + 5 then
      print("太长时间没有更新，需要强制更新一次:", g_DataMgr:getServerTime())
      isSend = true
      self.m_SyncNormalTimes = 0
      x = x + PosXForForceSyncAfterLongTime
      PosXForForceSyncAfterLongTime = -PosXForForceSyncAfterLongTime
    end
    if isSend then
      self.m_LastSyncPos = {x, y}
      self:SyncPlayerPos(self.m_LastSyncPos, withFlag)
      self.m_SyncNormalTimes = self.m_SyncNormalTimes + 1
      self.m_LastSyncTime = g_DataMgr:getServerTime()
    end
  end
end
function MapMgr:setCaptainSyncParam(pPos, flag)
  print("setCaptainSyncParam:", flag)
  if flag == 2 then
    self.m_SyncCaptainTimes = 0
    self.m_SyncCaptainFlag = flag
    return
  end
  if self.m_SyncCaptainFlag == flag and self.m_SyncCaptainPos[1] == pPos[1] and self.m_SyncCaptainPos[2] == pPos[2] then
    print("\t\t -------- 相同")
    return
  end
  self.m_SyncCaptainTimes = 0
  self.m_SyncCaptainPos = pPos
  self.m_SyncCaptainFlag = flag
end
function MapMgr:TranslatePosFromEdirtorPos(mapId, gridPos)
  if mapId == nil or gridPos == nil then
    return
  end
  local mapInfo = data_MapInfo[mapId]
  if mapInfo == nil then
    return
  end
  local mapData = MapConfigData[mapInfo.mapfile]
  if mapData == nil then
    return
  end
  local x = mapData.gridSize[1] * (gridPos[1] + 0.5)
  local y = mapData.gridSize[2] * (mapData.gridNum[2] - gridPos[2] - 1 + 0.5)
  if x ~= nil and y ~= nil then
    x = math.round(x)
    y = math.round(y)
    netsend.netmap.move(mapId, {x, y})
  end
end
function MapMgr:TranslatePosFromEdirtorPos2GridPos(mapId, x, y)
  if mapId == nil then
    return 0, 0
  end
  local mapInfo = data_MapInfo[mapId]
  if mapInfo == nil then
    return
  end
  local mapData = MapConfigData[mapInfo.mapfile]
  if mapData == nil then
    return
  end
  local x = x - 1
  local y = mapData.gridNum[2] - y - 2
  if x ~= nil and y ~= nil then
    x = math.round(x)
    y = math.round(y)
    return x, y
  end
end
function MapMgr:PlayerMove(pid, mapId, flag, pPos, isHide, posType, forceJumpMap)
  print([[

===>>MapMgr:PlayerMove:]], pid, mapId, flag, pPos, isHide, posType)
  if g_LocalPlayer == nil then
    return
  end
  if posType == nil then
    posType = MapPosType_PixelPos
  end
  if pid == nil or pid == g_LocalPlayer:getPlayerId() then
    pid = g_LocalPlayer:getPlayerId()
    if posType == MapPosType_EditorGrid then
      print([[

 self.m_CurMapId, mapId, posType, MapPosType_EditorGrid:]], self.m_CurMapId, mapId, posType, MapPosType_EditorGrid)
      self:TranslatePosFromEdirtorPos(mapId, pPos)
      return
    end
    print("本地玩家坐标，无视")
    return
  end
  local teamId = g_TeamMgr:getPlayerTeamId(pid)
  local myTeamId = g_TeamMgr:getLocalPlayerTeamId()
  local captainId = g_TeamMgr:getTeamCaptain(teamId)
  local teamers = g_TeamMgr:getTeamInfo(teamId)
  local player = g_DataMgr:getPlayer(pid)
  local mainHeroId
  if player then
    mainHeroId = player:getMainHeroId()
  end
  print("==>> player, mainHeroId:", player, mainHeroId)
  if player == nil or mainHeroId == nil then
    if player == nil and isHide == false and (self.m_CurMapId == nil or self.m_CurMapId == mapId) then
      player = g_DataMgr:CreatePlayer(pid, false)
      print("==>> test111 setCacheSyncData:", mapId, flag, pPos, isHide, posType)
      if g_MapMgr then
        g_MapMgr:AddOneReqPlayerInfo(pid)
      end
    end
    if player and flag ~= 1 then
      if flag == 1 then
        player:setCacheSyncDstData({
          flag,
          mapId,
          pPos,
          posType
        })
      else
        player:setCacheSyncData({
          mapId,
          flag,
          pPos,
          isHide,
          posType
        })
      end
    end
    if mapId ~= self.m_CurMapId or isHide == true then
      self.m_PlayerWarStatus[pid] = nil
    end
  else
    if player:getIsFollowTeamCommon() == 0 then
      print(string.format("[Warning] 传过来跟队队员的坐标，不处理.player id = %s", pid))
      return
    end
    if mapId ~= self.m_CurMapId or isHide == true then
      player:setMapPosInfo(mapId, isHide, pPos, posType)
      local isCaptain = false
      if self.m_MapView then
        self.m_MapView:SyncRolePos(pid, nil, nil, true)
        print("------>>> pid:", pid, teamId)
        self:pritAllTeamWalk()
        if teamId ~= nil and teamId > 0 then
          print([[

	====> captainId:]], captainId)
          if captainId == pid then
            isCaptain = true
            if teamers then
              for i = 1, #teamers do
                local pid_ = teamers[i]
                if myTeamId ~= myTeamId or pid_ ~= captainId then
                  local player_ = g_DataMgr:getPlayer(pid_)
                  print("---->>pid_, player:", pid_, player_)
                  if player_ then
                    local flag = player_:getIsFollowTeamCommon()
                    print("---->>flag:", flag)
                    if flag >= 0 then
                      self.m_MapView:SyncRolePos(pid_, nil, nil, true)
                      player_:setMapPosInfo(nil)
                    end
                  end
                end
              end
            end
            if myTeamId ~= teamId then
              self:TeamDismiss(teamId)
            end
          end
        end
      end
      if player ~= g_LocalPlayer then
        if myTeamId ~= teamId then
          self:DeletePlayerInfo(pid)
          if isCaptain and teamers then
            for i = 1, #teamers do
              self:DeletePlayerInfo(teamers[i])
            end
          end
        else
          self.m_PlayerWarStatus[pid] = nil
        end
      end
      if isHide == true then
        print("))))))))) deleteTeamInfoWhenPlayerHide-2", pid)
        g_TeamMgr:deleteTeamInfoWhenPlayerHide(pid)
      end
    else
      player:setMapPosInfo(mapId, isHide, pPos, posType)
      self:SyncPlayerMapInfo_(pid, flag, pPos, isHide, posType, forceJumpMap)
      if self.m_DeletedInvalidIds[tostring(pid)] ~= nil then
        self.m_DeletedInvalidIds[tostring(pid)] = nil
        if teamId ~= nil and teamId ~= 0 then
          self:setTeamStatusDirty(teamId)
        end
      end
    end
  end
  if isHide ~= true and self.m_IsMapLoading == false and mapId ~= nil and g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW and myTeamId and myTeamId ~= 0 and myTeamId == teamId and captainId == pid then
    local p = pPos
    if forceJumpMap == true then
      printLog("LOADMAP", "MapMgr:PlayerMove  22")
      self:LoadMapById(mapId, p, MapPosType_PixelPos)
    elseif flag ~= 1 and self:IsNeedLoadMap_(self.m_CurMapId, mapId, p, MapPosType_PixelPos) == true then
      local oldMapId = self.m_CurMapId
      self:LoadMapById(mapId, p, MapPosType_PixelPos)
      if oldMapId == mapId then
        netsend.netmap.move(mapId, p, 1)
      end
    end
    if forceJumpMap == true then
      self:reflushCaptainRoleStatusByPlayerId(pid)
    end
  end
end
function MapMgr:saveFollowingPlayerPos(pid, x, y)
  local player = g_DataMgr:getPlayer(pid)
  if player then
    player:setMapPosInfo(self.m_CurMapId, false, {x, y})
  end
end
function MapMgr:recivePlayerInfo(pid, paramTable)
  if pid == g_LocalPlayer:getPlayerId() then
    printLog("ERROR", "居然同步自己坐标过来!!!!!!!!")
    return
  end
  local roleTypeId = paramTable.roleTypeId
  local name = paramTable.name
  local zs = paramTable.roleZS
  local lv = paramTable.roleLevel
  local player = g_DataMgr:getPlayer(pid)
  if player == nil then
    player = g_DataMgr:addRole(pid, roleTypeId or 0, name or "", false)
  end
  if player == nil then
    printLog("ERROR", "创建角色出错")
    return
  end
  local isNewPlayer = false
  local role
  if roleTypeId ~= nil and player:getMainHero() == nil then
    local mainHeroId = 1
    player:setMainHeroId(mainHeroId)
    role = player:newObject(mainHeroId, roleTypeId)
    print("===>> role:", role)
    isNewPlayer = true
  end
  if role == nil then
    role = player:getMainHero()
  end
  if role then
    if roleTypeId ~= nil and isNewPlayer ~= true then
      role:UpdateLogicTypeId(roleTypeId)
    end
    if name ~= nil then
      role:setProperty(PROPERTY_NAME, name)
    end
    if zs ~= nil then
      role:setProperty(PROPERTY_ZHUANSHENG, zs)
    end
    if lv ~= nil then
      role:setProperty(PROPERTY_ROLELEVEL, lv)
    end
    if paramTable.orgid ~= nil then
      role:setProperty(PROPERTY_BPID, paramTable.orgid)
    else
      role:setProperty(PROPERTY_BPID, 0)
    end
    if paramTable.orgjobid ~= nil then
      role:setProperty(PROPERTY_BPJOB, paramTable.orgjobid)
    else
      role:setProperty(PROPERTY_BPJOB, 0)
    end
    if paramTable.orgname ~= nil then
      role:setProperty(PROPERTY_BPNAME, paramTable.orgname)
    else
      role:setProperty(PROPERTY_BPNAME, "")
    end
    if paramTable.colorData ~= nil then
      role:setProperty(PROPERTY_RANCOLOR, paramTable.colorData)
    else
      role:setProperty(PROPERTY_RANCOLOR, {
        0,
        0,
        0
      })
    end
    if paramTable.chibang ~= nil then
      role:setProperty(PROPERTY_CHIBANG, paramTable.chibang)
    else
      role:setProperty(PROPERTY_CHIBANG, 0)
    end
    if paramTable.jsEndTime ~= nil then
      role:setProperty(PROPERTY_ADDSPEED_ENDTIME, paramTable.jsEndTime)
    else
      role:setProperty(PROPERTY_ADDSPEED_ENDTIME, 0)
    end
    if paramTable.bsTypeId ~= nil then
      role:setProperty(PROPERTY_BIANSHENFUTYPE, paramTable.bsTypeId)
    else
      role:setProperty(PROPERTY_BIANSHENFUTYPE, 0)
    end
    if paramTable.zqTypeId ~= nil then
      role:setProperty(PROPERTY_MAPZuoqiTypeId, paramTable.zqTypeId)
    else
      role:setProperty(PROPERTY_MAPZuoqiTypeId, 0)
    end
    if self.m_MapView and pid ~= g_LocalPlayer:getPlayerId() then
      local mapPlayer = self.m_MapView:getRole(pid)
      if mapPlayer then
        mapPlayer:changeBSF()
        local name = role:getProperty(PROPERTY_NAME)
        self.m_MapView:PlayerChangeName(pid, name, false)
        local bpName = role:getProperty(PROPERTY_BPNAME)
        local bpJob = role:getProperty(PROPERTY_BPJOB)
        self.m_MapView:PlayerChangBpName(pid, bpName, bpJob, false)
        local chibang = role:getProperty(PROPERTY_CHIBANG)
        mapPlayer:setChiBang(chibang)
        local colorList = role:getProperty(PROPERTY_RANCOLOR)
        self.m_MapView:PlayerChangeColor(pid, colorList, false)
        mapPlayer:setMoveSpeed()
        local teamId = g_TeamMgr:getPlayerTeamId(pid)
        if teamId ~= 0 then
          local pIdList = g_TeamMgr:getTeamInfo(teamId)
          if pIdList ~= nil then
            for _, tPId in pairs(pIdList) do
              local tPlayer = self.m_MapView:getRole(tPId)
              if tPlayer ~= nil then
                tPlayer:setMoveSpeed()
              end
            end
          end
        end
        mapPlayer:changeZuoqiShape()
      end
    end
  end
  local cacheData = player:getCacheSyncData()
  if cacheData then
    local mapId, flag, pPos, isHide, posType = unpack(cacheData, 1, 5)
    print("==>> test111 getCacheSyncData:", mapId, flag, pPos, isHide, posType)
    player:setMapPosInfo(mapId, isHide, pPos, posType, isNewPlayer)
    if mapId == self.m_CurMapId and self.m_MapView then
      self:SyncPlayerMapInfo_(pid, flag, pPos, isHide, posType)
      local dstCache = player:getCacheSyncDstData() or {}
      local flag, dstMapId, dstPos, dstPosType = unpack(dstCache, 1, 4)
      if flag == 1 and dstMapId == mapId and dstPos then
        self:SyncPlayerMapInfo_(pid, flag, dstPos, false, dstPosType)
      end
    end
  else
  end
  player:setCacheSyncData(nil)
  if isNewPlayer then
    SendMessage(MsgID_OtherPlayer_AddNewPlayer, pid)
  else
    SendMessage(MsgID_OtherPlayer_UpdatePlayer, pid, paramTable)
  end
  self:updatePlayerWarStatus(pid)
end
function MapMgr:PlayerWarStatusChanged(pid, status, warType)
  if g_LocalPlayer:getPlayerId() ~= pid then
    if status == 1 then
      self.m_PlayerWarStatus[pid] = warType
    else
      self.m_PlayerWarStatus[pid] = nil
    end
    self:updatePlayerWarStatus(pid)
  end
end
function MapMgr:updatePlayerWarStatus(pid)
  if self.m_MapView then
    local player = g_DataMgr:getPlayer(pid)
    if player and player:getMainHeroId() then
      local followId = player:getIsFollowTeamCommon()
      print("followId, pid:", followId, pid)
      if followId ~= 0 then
        local mapRoleIns = self.m_MapView:getRole(pid)
        if mapRoleIns then
          mapRoleIns:showTopStatus(MapRoleStatus_InBattle, self.m_PlayerWarStatus[pid] ~= nil)
        end
      end
    end
  end
end
function MapMgr:getPlayerInWarType(pid)
  return self.m_PlayerWarStatus[pid]
end
function MapMgr:DeletePlayerInfo(pid)
  print("DeletePlayerInfo:", pid)
  g_DataMgr:delPlayer(pid)
  self.m_PlayerWarStatus[pid] = nil
  if self.m_MapView then
    self.m_MapView:delRole(pid)
  end
end
function MapMgr:CreateNewRoleForMap(pid)
  local followId = self.m_PlayerFollow[pid]
  if followId ~= nil and follow ~= -1 and self.m_MapView then
    print("==>>pid, followId:", pid, followId)
    self.m_MapView:setFollow(pid, followId)
  end
end
function MapMgr:SyncPlayerMapInfo_(pid, flag, pPos, isHide, posType, forceJumpMap)
  print("==>SyncPlayerMapInfo_:", pid, flag, pPos, isHide, posType, forceJumpMap)
  if posType == nil then
    posType = MapPosType_PixelPos
  end
  local function _sync_func(pPos_)
    pPos_ = pPos_ or pPos
    if true == self.m_MapView:SyncRolePos(pid, flag, pPos_, isHide, posType) then
      self:CreateNewRoleForMap(pid)
    end
  end
  if self.m_MapView then
    local follow = self.m_PlayerFollow[pid]
    print("follow==:", follow)
    if follow == -1 or follow == nil then
      _sync_func()
      local teamId = g_TeamMgr:getPlayerTeamId(pid)
      if follow == -1 and teamId ~= nil then
        print("==.self.m_DetectTeamerCreated[teamId]:", teamId, self.m_DetectTeamerCreated[teamId])
        if self.m_DetectTeamerCreated[teamId] == nil then
          local teamId = g_TeamMgr:getPlayerTeamId(pid)
          if teamId ~= nil then
            self:createOneTeamerToMap(teamId, forceJumpMap)
            self.m_DetectTeamerCreated[teamId] = 1
          end
        end
      end
    elseif isHide == true then
      local teamId = g_TeamMgr:getPlayerTeamId(pid)
      if teamId and teamId > 0 then
        self:DelTeamMember_(teamId, pid)
      end
      _sync_func()
    elseif self.m_MapView:getRole(pid) == nil then
      local pos
      local teamId = g_TeamMgr:getPlayerTeamId(pid)
      print("===>> pid:", pid, teamId)
      if teamId and teamId > 0 then
        local captainId = g_TeamMgr:getTeamCaptain(teamId)
        print("===>> captainId:", captainId, type(captainId))
        if captainId then
          local role = self.m_MapView:getRole(captainId)
          if role then
            local x, y = role:getPosition()
            print("=-=:x, y=", x, y)
            pos = {x, y}
          end
        end
      end
      if pos then
        _sync_func(pos)
      else
        _sync_func()
      end
    end
  end
end
function MapMgr:LoadPlayerAfterMapLoad()
  print("==>>LoadPlayerAfterMapLoad:")
  local allPlayers = g_DataMgr:getAllPlayers() or {}
  local myTeamId = g_TeamMgr:getLocalPlayerTeamId()
  for pid, playerIns in pairs(allPlayers) do
    print("\tpid:", pid)
    if playerIns ~= g_LocalPlayer then
      local mapId, isHide, pPos, posType = playerIns:getMapPosInfo()
      print("\t\tmapId, isHide, pPos:", mapId, isHide, pPos, posType)
      if pPos then
        dump(pPos)
      end
      if mapId == self.m_CurMapId and isHide ~= true and pPos ~= nil then
        local teamId = g_TeamMgr:getPlayerTeamId(pid)
        if teamId == 0 or teamId == nil then
          self:SyncPlayerMapInfo_(pid, nil, pPos, isHide, posType)
        end
      end
    end
  end
end
function MapMgr:SyncPlayerPos(t_Pos, i_flag)
  netsend.netmap.move(self.m_CurMapId, t_Pos, 0, i_flag)
end
function MapMgr:SyncHideStatus(isHide)
end
function MapMgr:FbViewStatusMsg(msgSID, ...)
end
function MapMgr:getNearPlayerIds(playerId)
  local nearPlayerIds = {}
  local player = g_DataMgr:getPlayer(playerId)
  if player then
    local mapId = self.m_CurMapId
    if player ~= g_LocalPlayer then
      mapId = player:getMapPosInfo()
    end
    if mapId then
      local allPlayers = g_DataMgr:getAllPlayers() or {}
      for pid, playerIns in pairs(allPlayers) do
        if playerIns ~= player then
          local mapId_, isHide_
          if playerIns ~= g_LocalPlayer then
            mapId_, isHide_ = playerIns:getMapPosInfo()
          else
            mapId_, isHide_ = self.m_CurMapId, false
          end
          if mapId_ == mapId and isHide_ ~= true then
            nearPlayerIds[#nearPlayerIds + 1] = pid
          end
        end
      end
    else
      printLog("ERROR", "对应的玩家[Id=%s]没有地图信息", playerId)
    end
  else
    printLog("ERROR", "找不到对应的玩家[Id=%s]", playerId)
  end
  return nearPlayerIds
end
function MapMgr:InitInvalidRoleInMap()
  self.m_UpdateInvalidRoleInMapTime = 3
  self.m_UpdateInvalidRoleInMapTimer = self.m_UpdateInvalidRoleInMapTime
  self.m_DeletedInvalidIds = {}
end
function MapMgr:UpdateInvalidRoleInMap(dt)
  if self.m_IsMapLoading then
    return
  end
  self.m_UpdateInvalidRoleInMapTimer = self.m_UpdateInvalidRoleInMapTimer - dt
  if self.m_UpdateInvalidRoleInMapTimer <= 0 then
    self.m_UpdateInvalidRoleInMapTimer = self.m_UpdateInvalidRoleInMapTime
    self:DetectInvalidRoleInMap()
  end
end
function MapMgr:DetectInvalidRoleInMap(pointPid)
  if self.m_IsMapLoading == true or self.m_MapView == nil then
    return
  end
  local detectTime = g_DataMgr:getServerTime() - 5
  local forceDelTime = g_DataMgr:getServerTime() - ForceDelRoleTime
  if detectTime < 0 then
    printLog("ERROR", "服务器时间小于0")
    return
  end
  local lx, ly = self:getLocalPlayerPos()
  local allRoles = g_DataMgr:getAllPlayers() or {}
  local myTeamId = g_LocalPlayer:getTeamId()
  local followId = g_LocalPlayer:getIsFollowTeamCommon()
  if followId == 0 then
    local captainId = g_TeamMgr:getTeamCaptain(myTeamId)
    if captainId then
      local captainPlayer = self.m_MapView:getRole(captainId)
      if captainPlayer then
        lx, ly = captainPlayer:getPosition()
      end
    end
  end
  local bx = math.ceil((lx + 1) / ServermapBlockSize[1])
  local by = math.ceil((ly + 1) / ServermapBlockSize[2])
  local syn_lx = (bx - 2) * ServermapBlockSize[1]
  local syn_ly = (by - 2) * ServermapBlockSize[2]
  local syn_rx = (bx + 1) * ServermapBlockSize[1]
  local syn_ry = (by + 1) * ServermapBlockSize[2]
  local function detectOnePlayer(pid, mapPlayer)
    if pid ~= g_LocalPlayer:getPlayerId() then
      local player = g_DataMgr:getPlayer(pid)
      if player then
        local mapId, isHide, pos, posType, syncTime = player:getMapPosInfo()
        if mapId == nil then
          local cacheData = player:getCacheSyncData()
          if cacheData then
            mapId = cacheData[1]
          end
        end
        local teamId = player:getTeamId()
        local followId = player:getIsFollowTeamCommon()
        if followId ~= 0 and (teamId == 0 or teamId ~= myTeamId) then
          print("\t\t syncTime  detectTime, forceDelTime:", syncTime, detectTime, forceDelTime)
          local isDel = false
          if syncTime > 0 then
            if syncTime < forceDelTime then
              print(string.format("%s长时间没移动，删除,followId:%s", pid, followId))
              isDel = true
            elseif syncTime <= detectTime then
              if mapId ~= self.m_CurMapId then
                isDel = true
              elseif self:getSceneSyncTypeByMapId(self.m_CurMapId) == SceneSyncType_Whold then
                print("===============>> 该地图不需要检测删除超范围玩家")
              else
                if mapPlayer == nil then
                  mapPlayer = self.m_MapView:getRole(pid)
                end
                if mapPlayer then
                  local x, y = mapPlayer:getPosition()
                  if x < syn_lx or x >= syn_rx or y < syn_ly or y >= syn_ry then
                    isDel = true
                  end
                end
              end
            end
          end
          if isDel then
            print(string.format("%s超出同步范围,followId:%s", pid, followId))
            if followId > 0 then
              local teamInfo = g_TeamMgr:getTeamInfo(teamId)
              if teamInfo then
                for i, pid_ in ipairs(teamInfo) do
                  local player_ = g_DataMgr:getPlayer(pid_)
                  if player_ then
                    local followId_ = player_:getIsFollowTeamCommon(pid_)
                    if followId_ >= 0 then
                      self:DelPlayerFromMap(pid_, player_)
                      self.m_DeletedInvalidIds[tostring(pid_)] = 1
                    end
                  end
                end
              end
            else
              self:DelPlayerFromMap(pid, player)
              self.m_DeletedInvalidIds[tostring(pid)] = 1
            end
            return true
          end
        end
      end
    end
    return false
  end
  if pointPid ~= nil then
    return detectOnePlayer(pointPid)
  else
    for pid, mapPlayer in pairs(allRoles) do
      detectOnePlayer(pid)
    end
  end
end
function MapMgr:DelPlayerFromMap(pid, player)
  if player == nil then
    player = g_DataMgr:getPlayerId(pid)
    if player == nil then
      printLog("ERROR", "MapMgr:DelPlayerFromMap:找不到ID为[%s]的玩家数据", pid)
      return
    end
  end
  player:setMapPosInfo(nil)
  self:DeletePlayerInfo(pid)
end
function MapMgr:InitTeamWalk()
  self.m_AllTeams = {}
  self.m_PlayerFollow = {}
  self.m_DetectTeamerCreated = {}
  self.m_NeedDetectTeamWalk = false
  self.m_DetectTeamWalkDirty = {}
  self.m_TeamWalkUpdateTimer = 0
end
function MapMgr:UpdateTeamWalk(dt)
  if self.m_NeedDetectTeamWalk then
    self.m_TeamWalkUpdateTimer = self.m_TeamWalkUpdateTimer - dt
    if self.m_TeamWalkUpdateTimer <= 0 then
      self.m_TeamWalkUpdateTimer = 0.1
      self.m_NeedDetectTeamWalk = false
      for teamId, i in pairs(self.m_DetectTeamWalkDirty) do
        teamId = tonumber(teamId)
        print("UpdateTeamWalk---->>", teamId)
        self:DetectOneTeamWalk(teamId)
      end
      self.m_DetectTeamWalkDirty = {}
      self:pritAllTeamWalk()
    end
  end
end
function MapMgr:setTeamStatusDirty(teamId)
  print("---->> TeamWalkDetect setTeamStatusDirty:", teamId)
  self.m_DetectTeamWalkDirty[tostring(teamId)] = 1
  self.m_NeedDetectTeamWalk = true
end
function MapMgr:DetectAllTeamWalk()
  for teamId, teamIds in pairs(g_TeamMgr.m_AllTeamInfo) do
    print("DetectAllTeamWalk---->>", teamId)
    self:DetectOneTeamWalk(teamId)
  end
  self:pritAllTeamWalk()
end
function MapMgr:DetectOneTeamWalk(teamId)
  print([[


---->> TeamWalkDetect DetectOneTeamWalk:]], teamId)
  local teamInfo = g_TeamMgr:getTeamInfo(teamId)
  local oldIds = self.m_AllTeams[teamId] or {}
  if teamInfo and #teamInfo > 0 then
    local followIds = {}
    local notFollowIds = {}
    local captainId
    for i, pid_ in ipairs(teamInfo) do
      local player_ = g_DataMgr:getPlayer(pid_)
      if player_ then
        local followId = player_:getIsFollowTeamCommon()
        if followId > 0 then
          captainId = pid_
        elseif followId == 0 then
          followIds[#followIds + 1] = pid_
        else
          notFollowIds[#followIds + 1] = pid_
        end
      end
      for i, v in ipairs(oldIds) do
        if v == pid_ then
          table.remove(oldIds, i)
          break
        end
      end
      for i, v in ipairs(oldIds) do
        self:stopFollow(v)
      end
    end
    if captainId == nil then
      printLog("ERROR", "队伍%s没有队长!", tostring(teamId))
      self.m_AllTeams[teamId] = {}
      self:reflushCaptainRoleStatus(teamId)
      return
    end
    table.sort(followIds)
    table.insert(followIds, 1, captainId)
    self.m_AllTeams[teamId] = followIds
    for i = #followIds, 1, -1 do
      local pid = followIds[i]
      local followId = followIds[i - 1] or -1
      self.m_PlayerFollow[pid] = followId
      if self.m_MapView then
        self.m_MapView:clearFollowIds(pid)
      end
    end
    if self.m_MapView then
      local captainPlayerInfo = g_DataMgr:getPlayer(captainId)
      local isCurMap = false
      local mapId, isHide, pos, posType
      if captainPlayerInfo == g_LocalPlayer then
        mapId = self.m_CurMapId
        isHide = false
        local x, y = self.m_MapView:getLocalRolePos()
        pos = {x, y}
      else
        mapId, isHide, pos, posType = captainPlayerInfo:getMapPosInfo()
        local role = self.m_MapView:getRole(captainId)
        if role then
          local x, y = role:getPosition()
          pos = {x, y}
        end
      end
      print("=====>>mapId, isHide, pos:", mapId, isHide, pos)
      if mapId == self.m_CurMapId and isHide ~= true and pos and #pos == 2 then
        for i, pid in ipairs(followIds) do
          print("\t\t=====>>> pid:", pid)
          local resetPos = false
          if self.m_MapView:getRole(pid) == nil then
            resetPos = true
            self.m_MapView:SyncRolePos(pid, nil, pos, isHide, posType)
            local curPlayer = g_DataMgr:getPlayer(pid)
            if curPlayer then
              curPlayer:setMapPosInfo(mapId, isHide, pos, posType)
            end
          end
          local followId = self.m_PlayerFollow[pid]
          self.m_MapView:setFollow(pid, followId, resetPos)
        end
      end
      for i, pid__ in ipairs(notFollowIds) do
        self.m_MapView:setFollow(pid__, nil)
        self.m_PlayerFollow[pid__] = nil
      end
    end
    self:reflushCaptainRoleStatus(teamId)
    if g_LocalPlayer:getTeamId() == teamId then
      g_LocalPlayer:reflushNormalTeamerFlag()
    end
  else
    self:TeamDismiss(teamId)
  end
end
function MapMgr:getCanSyncFromSvr(pid)
  local follow = self.m_PlayerFollow[pid]
  return follow == -1 or follow == nil
end
function MapMgr:craeteAllTeamerInMap()
  print([[


==== craeteAllTeamerInMap:self.m_CurMapId=]], self.m_CurMapId)
  for teamId, teamers in pairs(self.m_AllTeams) do
    self:createOneTeamerToMap(teamId)
  end
  self:reflushAllFollowRelations()
end
function MapMgr:createOneTeamerToMap(teamId, forceResetFollowPos)
  print("createOneTeamerToMap:", teamId)
  if self.m_MapView == nil then
    return
  end
  local teamers = self.m_AllTeams[teamId]
  while teamers ~= nil do
    local captainId = teamers[1]
    if captainId == nil then
      break
    end
    local captainPlayer = g_DataMgr:getPlayer(captainId)
    print("===>>captainPlayer:", captainPlayer)
    if captainPlayer == nil then
      break
    end
    local mapId, isHide, pos, posType
    if captainPlayer == g_LocalPlayer then
      mapId = self.m_CurMapId
      isHide = false
      local x, y = self.m_MapView:getLocalRolePos()
      pos = {x, y}
    else
      mapId, isHide, pos, posType = captainPlayer:getMapPosInfo()
      local role = self.m_MapView:getRole(captainId)
      if role then
        local x, y = role:getPosition()
        pos = {x, y}
      end
    end
    print("=====>>mapId, isHide, pos:", mapId, isHide, pos)
    if pos then
      dump(pos)
    end
    if mapId ~= self.m_CurMapId or isHide == true then
      break
    end
    if pos and #pos == 2 then
      for i, pid in ipairs(teamers) do
        print("\t\t=====>>> pid:", pid)
        if pid == g_LocalPlayer:getPlayerId() and self.m_MapView then
          self.m_MapView:stoptAutoRoute()
        end
        local resetPos = forceResetFollowPos
        if resetPos == nil then
          resetPos = self.m_MapView:getRole(pid) ~= nil
        end
        self.m_MapView:SyncRolePos(pid, nil, pos, isHide, posType)
        local followId = self.m_PlayerFollow[pid]
        self.m_MapView:setFollow(pid, followId, resetPos)
      end
    end
    break
  end
end
function MapMgr:reflushAllFollowRelations()
  if self.m_MapView then
    for pid, followId in pairs(self.m_PlayerFollow) do
      print("==>>pid, followId:", pid, followId)
      self.m_MapView:setFollow(pid, followId)
    end
    for teamId, v in pairs(self.m_AllTeams) do
      self:reflushCaptainRoleStatus(teamId)
    end
  end
end
function MapMgr:TeamMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_NewTeam then
    local teamId = arg[1]
    local captainId = arg[2]
    self:setTeamStatusDirty(teamId)
  elseif msgSID == MsgID_Team_DismissTeam then
    local teamId = arg[1]
    printLog("TEAMWALK", "解散队伍,teamId=%d", teamId)
    self:TeamDismiss(teamId)
  elseif msgSID == MsgID_Team_PlayerJoinTeam then
    local teamId = arg[1]
    local pid = arg[2]
    self:setTeamStatusDirty(teamId)
    if self.m_MapView then
      local mapPlayer = self.m_MapView:getRole(pid)
      if mapPlayer then
        mapPlayer:setMoveSpeed()
      end
    end
  elseif msgSID == MsgID_Team_PlayerLeaveTeam then
    local teamId = arg[1]
    local pid = arg[2]
    self:setTeamStatusDirty(teamId)
    self:DelTeamMember_(teamId, pid)
    if self.m_MapView then
      local mapPlayer = self.m_MapView:getRole(pid)
      if mapPlayer then
        mapPlayer:setMoveSpeed()
      end
    end
  elseif msgSID == MsgID_Team_CaptainChanged then
    local teamId = arg[1]
    local captainId = arg[2]
    self:setTeamStatusDirty(teamId)
    local teamInfo = g_TeamMgr:getTeamInfo(teamId)
    if self.m_MapView then
      for _, pid in pairs(teamInfo) do
        local mapPlayer = self.m_MapView:getRole(pid)
        if mapPlayer then
          mapPlayer:setMoveSpeed()
        end
      end
    end
  elseif msgSID == MsgID_Team_TeamState then
    local teamId = arg[1]
    local pid = arg[2]
    local state = arg[3]
    if g_LocalPlayer and g_LocalPlayer:getPlayerId() == pid and TEAMSTATE_FOLLOW == state and self.m_MapView then
      local captainId = g_TeamMgr:getTeamCaptain(teamId)
      local captainIns = self.m_MapView:getRole(captainId)
      if captainIns then
        local x, y = captainIns:getPosition()
        if self:IsNeedLoadMap_(self.m_CurMapId, self.m_CurMapId, {x, y}, MapPosType_PixelPos) then
          self:LoadMapById(self.m_CurMapId, {x, y}, MapPosType_PixelPos)
        end
      end
    end
    self:setTeamStatusDirty(teamId)
    if self.m_MapView then
      local mapPlayer = self.m_MapView:getRole(pid)
      if mapPlayer then
        mapPlayer:setMoveSpeed()
      end
    end
  elseif msgSID == MsgID_Team_TeamIsFull then
    local teamId = arg[1]
    self:reflushCaptainRoleStatus(teamId)
  end
  if g_LocalPlayer then
    g_LocalPlayer:reflushNormalTeamerFlag()
  end
end
function MapMgr:AddTeamMember_(teamId, pid, notSetFollow)
  if notSetFollow == nil then
    notSetFollow = false
  end
  local teamPlayers = self.m_AllTeams[teamId]
  if teamPlayers == nil then
    printLog("TEAMWALK", "找不对对应的队伍,队伍ID=%d", teamId)
    teamPlayers = self:reflushTeamRelation(teamId, pid)
    if teamPlayers == nil then
      return
    end
  end
  local insertIdx
  local hasInTeam = false
  for i, tpid in ipairs(teamPlayers) do
    if tpid == pid then
      hasInTeam = true
      break
    end
    if i ~= 1 and insertIdx == nil and checkint(pid) < checkint(tpid) then
      insertIdx = i
    end
  end
  if hasInTeam == true then
    printLog("TEAMWALK", "AddTeamMember_ 重复增加队员 teamId=%d, pid=%d", teamId, pid)
    return
  end
  if insertIdx == nil then
    insertIdx = #teamPlayers + 1
  end
  table.insert(teamPlayers, insertIdx, pid)
  self.m_AllTeams[teamId] = teamPlayers
  if #teamPlayers > 1 and self.m_MapView and self.m_MapView:getRole(pid) == nil then
    local captainPlayer = self.m_MapView:getRole(teamPlayers[1])
    if captainPlayer then
      local x, y = captainPlayer:getPosition()
      self.m_MapView:SyncRolePos(pid, nil, {x, y}, false)
    end
  end
  if notSetFollow ~= true then
    for i = insertIdx, #teamPlayers do
      self:setFollow(teamPlayers[i], teamPlayers[i - 1])
    end
  end
end
function MapMgr:DelTeamMember_(teamId, pid)
  print("\t\tDelTeamMember_==>")
  local teamPlayers = self.m_AllTeams[teamId]
  if teamPlayers == nil then
    printLog("TEAMWALK", "找不对对应的队伍,队伍ID=%d", teamId)
    return
  end
  self:DetectOneTeamWalk(teamId)
  self:stopFollow(pid)
end
function MapMgr:reflushTeamRelation(teamId, exceptPid)
  local teamInfo = g_TeamMgr:getTeamInfo(teamId)
  if teamInfo then
    table.sort(teamInfo)
    for i, pid_ in ipairs(teamInfo) do
      if pid_ == exceptPid then
        table.remove(teamInfo, i)
        break
      end
    end
    return teamInfo
  end
  return nil
end
function MapMgr:setTeamCaptain(pid)
  printLog("TEAMWALK", "setTeamCaptain 设置队长 pid=%d", pid)
  self:stopFollow(pid)
  self.m_PlayerFollow[pid] = -1
end
function MapMgr:stopFollow(pid)
  printLog("TEAMWALK", "stopFollow 停止跟随 pid=%d", pid)
  self.m_PlayerFollow[pid] = nil
  if self.m_MapView then
    self.m_MapView:stopFollow(pid)
  end
end
function MapMgr:setFollow(pid, followPid)
  if pid ~= nil and followPid ~= nil then
    printLog("TEAMWALK", "setFollow 设置跟随 pid=%d, followPid=%d", pid, followPid)
  end
  self.m_PlayerFollow[pid] = followPid
  if self.m_MapView then
    self.m_MapView:setFollow(pid, followPid)
  end
end
function MapMgr:TeamDismiss(teamId)
  if teamId == nil then
    print("[warning] TeamDismiss teamId == nil")
    return
  end
  local teamPlayers = self.m_AllTeams[teamId]
  self:reflushCaptainRoleStatus(teamId, true)
  if teamPlayers == nil then
    self.m_DetectTeamerCreated[teamId] = nil
    return
  end
  self.m_AllTeams[teamId] = nil
  for idx, pid in ipairs(teamPlayers) do
    self:stopFollow(pid)
  end
  self.m_DetectTeamerCreated[teamId] = nil
end
function MapMgr:reflushCaptainRoleStatus(teamId, isDismiss)
  if teamId == nil then
    print("[warning] reflushCaptainRoleStatus teamId == nil")
    return
  end
  if isDismiss == nil then
    isDismiss = false
  end
  if self.m_MapView then
    print("--> MapMgr:reflushCaptainRoleStatus:", teamId, isDismiss, self.m_MapView)
    local curCaptainId = self.m_CaptainTopStatus[teamId]
    local curCaptainRole
    if curCaptainId then
      curCaptainRole = self.m_MapView:getRole(curCaptainId)
    end
    print("===>> curCaptainId:", curCaptainId, curCaptainRole)
    if isDismiss == true then
      if curCaptainRole then
        curCaptainRole:setCaptainTopStatus(nil)
      end
      self.m_CaptainTopStatus[teamId] = nil
    else
      local newCaptainId
      local teamers = self.m_AllTeams[teamId]
      if teamers and #teamers > 0 then
        newCaptainId = teamers[1]
      end
      print("===>> newCaptainId:", newCaptainId, curCaptainRole)
      if newCaptainId ~= curCaptainId then
        if curCaptainRole then
          curCaptainRole:setCaptainTopStatus(nil)
        end
        self.m_CaptainTopStatus[teamId] = newCaptainId
      end
      if newCaptainId then
        local role = self.m_MapView:getRole(newCaptainId)
        print("==>> role:", role, newCaptainId, type(newCaptainId))
        if role then
          if g_TeamMgr:getTeamIsFull(teamId) == true then
            role:setCaptainTopStatus(MapRoleStatus_Captain)
          else
            role:setCaptainTopStatus(MapRoleStatus_CaptainNotFull)
          end
        end
      end
    end
  end
end
function MapMgr:reflushCaptainRoleStatusByPlayerId(pid)
  print("==>reflushCaptainRoleStatusByPlayerId:", pid)
  local teamId = g_TeamMgr:getPlayerTeamId(pid)
  print("\tteamId:", teamId)
  if teamId ~= 0 and teamId ~= nil then
    self:reflushCaptainRoleStatus(teamId)
  end
end
function MapMgr:FindRouteInCurMap(startX, startY, dstX, dstY)
  if self.m_MapView then
    return self.m_MapView:FindRoute(startX, startY, dstX, dstY)
  end
  return nil
end
function MapMgr:pritAllTeamWalk()
  print("======================[队伍行走]==================")
  for teamId, teamPlayers in pairs(self.m_AllTeams) do
    local playersStr = ""
    for idx, pid in ipairs(teamPlayers) do
      playersStr = playersStr .. string.format("% 6s  ", tostring(pid))
    end
    print(string.format("% 5s:%s", tostring(teamId), playersStr))
  end
  print("\n")
  for k, v in pairs(self.m_PlayerFollow) do
    print(string.format("%s Follow %s", k, v))
  end
  print("\n 所有队伍")
  for teamId, teamPlayers in pairs(g_TeamMgr.m_AllTeamInfo) do
    local playersStr = ""
    for idx, pid in ipairs(teamPlayers) do
      local followId = 0
      local player_ = g_DataMgr:getPlayer(pid)
      if player_ then
        followId = player_:getIsFollowTeamCommon()
      end
      playersStr = playersStr .. string.format(" % 6s", tostring(pid)) .. string.format("(%d)", followId)
    end
    print(string.format("% 5s:%s", tostring(teamId), playersStr))
  end
  print("=================================================")
end
function MapMgr:testTeamWalk_()
  local localPid = g_LocalPlayer:getPlayerId()
  g_MapMgr:TeamMessage(MsgID_Team_NewTeam, 101, localPid)
  local allPlayerIds = g_MapMgr:getNearPlayerIds() or {}
  local len = #allPlayerIds
  if len > 4 then
    len = 4
  end
  for i = 1, len do
    g_MapMgr:TeamMessage(MsgID_Team_PlayerJoinTeam, 101, allPlayerIds[i])
  end
end
function MapMgr:ReqLoadNpc(npcId)
  self.m_TempLoadNpcCount[npcId] = 1
  self:DetectLoadNpc()
end
function MapMgr:ReqDeleteNpc(npcId)
  self:DeleteTempNpcInMap_(npcId)
  self.m_TempLoadNpcCount[npcId] = nil
end
function MapMgr:DeleteTempNpcInMap_(npcId)
  if self.m_MapView then
    self.m_MapView:DeleteTempNpcInMap(npcId)
  end
end
function MapMgr:LoadTempNpcInMap_(npcId)
  if self.m_MapView then
    self.m_MapView:LoadTempNpcInMap(npcId)
  end
end
function MapMgr:DetectDeleteNpc()
end
function MapMgr:DetectLoadNpc()
  for npcId, count in pairs(self.m_TempLoadNpcCount) do
    local npcInfo = data_NpcInfo[npcId]
    if self.m_CurMapId == npcInfo.pos[1] then
      self:LoadTempNpcInMap_(npcId)
    end
  end
end
function MapMgr:updateDynamicNpc(param)
  local id = param.i_id
  print("==>id:", id)
  if id == nil then
    return
  end
  local state = param.i_state or 1
  print("==>state:", state)
  if state == 0 then
    self:delDynamicNpc(id)
    self.m_DynamicNpc[id] = nil
  else
    local typeid = param.i_typeid
    local scene = param.i_scene
    local loc = param.t_loc
    local name = param.s_name
    local data = self.m_DynamicNpc[id]
    if data == nil then
      data = {}
      self.m_DynamicNpc[id] = data
    end
    data.state = state
    if typeid ~= nil then
      data.typeid = typeid
      local d = data_Monster[typeid] or {}
      if d.pos == nil then
        d.pos = {}
      end
      if scene == nil then
        scene = d.pos[1]
      end
      data.scene = scene
      if loc == nil then
        loc = {
          d.pos[1],
          d.pos[2]
        }
      end
      data.loc = loc
      if name == nil then
        name = d.name
      end
      data.name = name
      local monsterId
      if self.m_DynamicNpc[id] ~= nil then
        monsterId = self.m_DynamicNpc[id].monsterId
        data.monsterId = monsterId
      end
    end
    print("==>self.m_DynamicNpc[id]:")
    dump(self.m_DynamicNpc[id])
    self:flushOneDynamicNpc(id)
  end
end
function MapMgr:getDynamicNpcDataById(dynamicNpcId)
  return self.m_DynamicNpc[dynamicNpcId]
end
function MapMgr:delDynamicNpc(dynamicNpcId)
  if self.m_MapView then
    local data = self.m_DynamicNpc[dynamicNpcId]
    if data and self.m_MapView and self.m_CurMapId == data.scene then
      local monsterId = data.monsterId
      if monsterId then
        self.m_MapView:DeleteMonster(monsterId)
      end
    end
  end
end
function MapMgr:flushOneDynamicNpc(id)
  if self.m_IsMapLoading == true then
    return
  end
  local data = self.m_DynamicNpc[id]
  if data and self.m_MapView and self.m_CurMapId == data.scene then
    local monsterId = self.m_MapView:updateDynamicNpc(id, data)
    if monsterId then
      data.monsterId = monsterId
    end
  end
end
function MapMgr:detectLoadDynamicNpc()
  if self.m_MapView then
    for id, data in pairs(self.m_DynamicNpc) do
      if self.m_CurMapId == data.scene then
        local monsterId = self.m_MapView:updateDynamicNpc(id, data)
        if monsterId then
          data.monsterId = monsterId
        end
      end
    end
  end
end
function MapMgr:clearDynamicNpc()
  if self.m_MapView then
    for id, data in pairs(self.m_DynamicNpc) do
      if data.monsterId then
        self.m_MapView:DeleteMonster(data.monsterId)
      end
    end
  end
  self.m_DynamicNpc = {}
end
function MapMgr:testDynamicNpc()
  self:updateDynamicNpc({
    i_id = 100,
    i_typeid = 1,
    i_scene = 8,
    t_loc = {31, 18},
    s_name = "藏宝图怪物",
    i_shape = 20011,
    i_state = 1
  })
end
function MapMgr:updateDynamicActiveNpc(param)
  local npcId = param.npcId
  if npcId == nil then
    return
  end
  local state = param.state or 1
  print("---->>updateDynamicActiveNpc:", npcId, state)
  if state == 0 then
    self:delDynamicActiveNpc(npcId)
    self.m_DynamicActiveNpc[npcId] = nil
  else
    local data = self.m_DynamicActiveNpc[npcId]
    if data == nil then
      data = {}
      self.m_DynamicActiveNpc[npcId] = data
      local npcInfo = data_NpcInfo[npcId]
      if npcInfo == nil then
        return
      end
      local pos = npcInfo.pos
      data.scene = pos[1]
      data.npcInfo = npcInfo
    end
    self:flushOneDynamicActiveNpc(npcId)
  end
end
function MapMgr:delDynamicActiveNpc(npcId)
  if self.m_MapView then
    local data = self.m_DynamicActiveNpc[npcId]
    if data and self.m_MapView and self.m_CurMapId == data.scene then
      self.m_MapView:DeleteDynamicActive(npcId, data.shape, data.opaque)
    end
  end
end
function MapMgr:flushOneDynamicActiveNpc(npcId)
  if self.m_IsMapLoading == true then
    return
  end
  local data = self.m_DynamicActiveNpc[npcId]
  if data and self.m_MapView and self.m_CurMapId == data.scene then
    self.m_MapView:updateDynamicActiveNpc(npcId, data)
  end
end
function MapMgr:detectLoadDynamicActiveNpc()
  print("---->>>>detectLoadDynamicActiveNpc")
  print_lua_table(self.m_DynamicActiveNpc)
  if self.m_MapView then
    for npcId, data in pairs(self.m_DynamicActiveNpc) do
      if self.m_CurMapId == data.scene then
        self.m_MapView:updateDynamicActiveNpc(npcId, data)
      end
    end
  end
end
function MapMgr:addMapTreasure(param)
  local scene = param.sceneid
  local items = param.items
  if items == nil then
    return
  end
  for _, info in pairs(items) do
    local id = info.id
    local dType = info.type
    local itemid = info.itemid
    local x = info.x
    local y = info.y
    local data = self.m_DynamicTreasure[id]
    if data == nil then
      data = {}
      self.m_DynamicTreasure[id] = data
    end
    data.dType = dType
    data.scene = scene
    data.loc = ccp(x, y)
    data.itemid = itemid
    self:flushOneDynamicTreasure(id)
  end
end
function MapMgr:flushOneDynamicTreasure(id)
  if self.m_IsMapLoading == true then
    return
  end
  local data = self.m_DynamicTreasure[id]
  if data and self.m_MapView and self.m_CurMapId == data.scene then
    self.m_MapView:updateDynamicTreasure(id, data)
  end
end
function MapMgr:detectLoadDynamicTreasure()
  if self.m_MapView then
    for id, data in pairs(self.m_DynamicTreasure) do
      if self.m_CurMapId == data.scene then
        self.m_MapView:updateDynamicTreasure(id, data)
      end
    end
  end
end
function MapMgr:delDynamicTreasure(scene, id)
  if self.m_MapView and self.m_CurMapId == scene then
    self.m_MapView:DeleteTreasure(id)
  end
  self.m_DynamicTreasure[id] = nil
end
function MapMgr:flushMissionMonsters()
  if self.m_MapView == nil then
    print("self.m_MapView:", self.m_MapView)
    return
  end
  local monsterData = g_MissionMgr:getMapMonsterForMissions() or {}
  self.m_MapView:flushAllMonsterForMission(monsterData[self.m_CurMapId])
end
function MapMgr:ShowScreenAni()
  function setNodeAction_(node, action)
    node:runAction(action)
    CCDirector:sharedDirector():getActionManager():pauseTarget(node)
    self.m_AllSpriteObj[#self.m_AllSpriteObj + 1] = node
  end
  if self.m_AllSpriteObj then
    for k, node in ipairs(self.m_AllSpriteObj) do
      CCDirector:sharedDirector():getActionManager():resumeTarget(node)
    end
  end
  self.m_AllSpriteObj = {}
  if g_FubenHandler then
    g_FubenHandler:readyToCutScreen()
  end
  setAllNodesClippingType(LAYOUT_CLIPPING_SCISSOR)
  local size = CCDirector:sharedDirector():getWinSize()
  local pScreen = CCRenderTexture:create(size.width, size.height, kCCTexture2DPixelFormat_RGBA8888)
  local pCurNode, parentNode, zOrder
  local parentIsWidget = false
  local mapIns = self:getMapViewIns()
  if g_CurSceneView and mapIns and mapIns:isVisible() then
    pCurNode = mapIns
    parentNode = g_CurSceneView.m_UINode
    zOrder = MainUISceneZOrder.map + 1
    parentIsWidget = true
  else
    pCurNode = CCDirector:sharedDirector():getRunningScene()
    parentNode = g_MostTopLayer
    zOrder = TopLayerZ_CutScreen
    parentIsWidget = false
  end
  pScreen:begin()
  pCurNode:visit()
  pScreen:endToLua()
  setAllNodesClippingType(LAYOUT_CLIPPING_STENCIL)
  if g_FubenHandler then
    g_FubenHandler:recoverAfterCutScreen()
  end
  local rectScreen = CCRectMake(0, 0, size.width, size.height)
  local spriteScreen = CCSprite:createWithTexture(pScreen:getSprite():getTexture(), rectScreen)
  spriteScreen:setAnchorPoint(ccp(0, 0))
  spriteScreen:setPosition(ccp(0, 0))
  spriteScreen:setFlipY(true)
  if parentIsWidget then
    parentNode:addNode(spriteScreen, zOrder)
  else
    parentNode:addChild(spriteScreen, zOrder)
  end
  setNodeAction_(spriteScreen, transition.sequence({
    CCFadeOut:create(0.3),
    CCCallFunc:create(function()
      if parentIsWidget and parentNode then
        parentNode:removeNode(spriteScreen)
      else
        spriteScreen:removeFromParentAndCleanup(true)
      end
    end)
  }))
end
function MapMgr:ShowScreenAniAction()
  for i, node in ipairs(self.m_AllSpriteObj) do
    CCDirector:sharedDirector():getActionManager():resumeTarget(node)
  end
  self.m_AllSpriteObj = {}
end
function MapMgr:setMapHide(isHide)
  if self.m_MapView then
    self.m_MapView:setVisible(not isHide)
  end
end
function MapMgr:Clear()
  if self.m_SchedulerHandler then
    scheduler.unscheduleGlobal(self.m_SchedulerHandler)
    self.m_SchedulerHandler = nil
  end
  self:RemoveAllMessageListener()
end
function MapMgr:SyncPlayerTypeChanged(t)
  if self.m_CurSyncPlayerType == t then
    return
  end
  self.m_CurSyncPlayerType = t
  if self.m_CurSyncPlayerType == SyncPlayerType_Max then
    print("--->> 同屏人数设置为[最大]")
  elseif self.m_CurSyncPlayerType == SyncPlayerType_Middle then
    print("--->> 同屏人数设置为[中等]")
  elseif self.m_CurSyncPlayerType == SyncPlayerType_Min then
    print("--->> 同屏人数设置为[最小]")
    self:DeletePlayerWhoDifferentTeam()
  end
  if self.m_MapView then
    self.m_MapView:SyncPlayerTypeChanged(self.m_CurSyncPlayerType)
  end
end
function MapMgr:DeletePlayerWhoDifferentTeam()
  local allPlayers = g_DataMgr:getAllPlayers() or {}
  local myTeamId = g_TeamMgr:getLocalPlayerTeamId()
  for pid, playerIns in pairs(allPlayers) do
    print("\t pid:", pid, playerIns)
    if playerIns ~= g_LocalPlayer then
      local teamId = g_TeamMgr:getPlayerTeamId(pid)
      local followId = playerIns:getIsFollowTeamCommon()
      if teamId == 0 or myTeamId ~= teamId or followId < 0 then
        self:DelPlayerFromMap(pid, playerIns)
      end
      playerIns:setMapPosInfo(nil)
    end
  end
end
function MapMgr:resetDynamicCreateAndReleaseRoles()
  self.m_dynamicCreateAndReleaseRoles = {}
  self.m_dynamicCreateAndReleaseIds = 0
  self.m_detectCreateAndReleasePos = nil
  self.m_isNeedDetectDynamicCreateAndRelease = false
  self.m_isNeedForceDetectDynamicCreateAndRelease = false
  self.m_dynamicCreateDistanceSquare = math.pow(display.width / AllMapScaleNum * 1.5, 2)
  self.m_dynamicReleaseDistanceSquare = math.pow(display.width * 2, 2)
end
function MapMgr:detectRoleNeedDynamicCreateAndRelease(role, roleType)
  if self.m_CurMapId == MapId_Changan and roleType == LOGICTYPE_NPC then
    return self:addRoleForDynamicCreateAndRelease(role)
  end
  return false
end
function MapMgr:addRoleForDynamicCreateAndRelease(role)
  self.m_dynamicCreateAndReleaseIds = self.m_dynamicCreateAndReleaseIds + 1
  role:setDynamicCreateAndDelete(self.m_dynamicCreateAndReleaseIds)
  self.m_isNeedDetectDynamicCreateAndRelease = true
  self.m_dynamicCreateAndReleaseRoles[self.m_dynamicCreateAndReleaseIds] = role
  self.m_isNeedForceDetectDynamicCreateAndRelease = true
  return true
end
function MapMgr:delRoleFromDynamicCreateAndRelease(role)
  if role then
    local tid = role:getDynamicCreateAndDelete()
    if tid ~= nil then
      self.m_dynamicCreateAndReleaseRoles[tid] = nil
    end
  end
end
function MapMgr:forceDetectDynamicCreateAndRelease()
  local lx, ly = self:getLocalPlayerPos()
  if lx ~= nil and ly ~= nil then
    self:detectRoleCreateOrRelease(lx, ly, true)
  end
end
function MapMgr:detectRoleCreateOrRelease(lx, ly, force)
  self.m_isNeedForceDetectDynamicCreateAndRelease = false
  local isNeedDetect = false
  if self.m_detectCreateAndReleasePos == nil then
    isNeedDetect = true
  else
    local ox, oy = unpack(self.m_detectCreateAndReleasePos, 1, 2)
    if math.abs(ox - lx) + math.abs(oy - ly) >= DynamicCreateAndReleaseDetectDistance then
      isNeedDetect = true
    end
  end
  print("detectRoleCreateOrRelease:", lx, ly, isNeedDetect, self.m_isNeedDetectDynamicCreateAndRelease)
  if isNeedDetect or force == true then
    self.m_detectCreateAndReleasePos = {lx, ly}
    for did, roleIns in pairs(self.m_dynamicCreateAndReleaseRoles) do
      local x, y = roleIns:getPosition()
      local disSquare = math.pow(x - lx, 2) + math.pow(y - ly, 2)
      if roleIns:isRoleCreated() then
        if disSquare >= self.m_dynamicReleaseDistanceSquare then
          print(" -----dynamic----- 动态删除对象:", roleIns:getNpcId())
          roleIns:doDynamicRelease()
        end
      elseif disSquare <= self.m_dynamicCreateDistanceSquare then
        print(" -----dynamic----- 动态创建对象:", roleIns:getNpcId())
        roleIns:doDynamicCreate()
      end
    end
  end
end
function MapMgr:touchExitMapButtom(exitType)
  if self.m_CurMapId == activity.tianting.mapId then
    if activity.tianting:touchExitButton(exitType) then
      return true
    end
  elseif self.m_CurMapId == activity.tiandiqishu.mapId then
    activity.tiandiqishu:touchExitButton(exitType)
    return false
  elseif activity.dayanta:isDayantaMapId(self.m_CurMapId) then
    DayantaWarning.new()
    return true
  end
  return false
end
function MapMgr:UseZBT(itemId, mapId, pos, rIndex)
  local function cbListener(isSucceed)
    if isSucceed == true then
      getCurSceneView():addSubView({
        subView = CCBTView.new(mapId, itemId, rIndex),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  end
  g_MapMgr:jumpMapForCBT(mapId, pos, cbListener)
  if g_CMainMenuHandler then
    g_CMainMenuHandler:addItemToQuickUseBoard(BoxOpenType_Item, itemId)
  end
end
function MapMgr:ClearReqPlayerInfoList()
  print("ClearReqPlayerInfoList")
  self.m_ReqPlayerInfoList = {}
  self.m_ReqPlayerInfoDict = {}
end
function MapMgr:SendOneReqPlayerInfo()
  if #self.m_ReqPlayerInfoList == 0 then
    return
  end
  local pId = self.m_ReqPlayerInfoList[1]
  table.remove(self.m_ReqPlayerInfoList, 1)
  self.m_ReqPlayerInfoDict[pId] = nil
  local needSend = true
  local player = g_DataMgr:getPlayer(pId)
  if player == nil then
    print("meiyou  player")
    needSend = false
  end
  if needSend then
    netsend.netmap.reqPlayerInfo(pId)
  else
    self:SendOneReqPlayerInfo()
  end
end
function MapMgr:AddOneReqPlayerInfo(pIdList)
  if type(pIdList) == "table" then
    for i, tempPid in pairs(pIdList) do
      if self.m_ReqPlayerInfoDict[tempPid] == nil then
        self.m_ReqPlayerInfoDict[tempPid] = true
        self.m_ReqPlayerInfoList[#self.m_ReqPlayerInfoList + 1] = tempPid
      end
    end
  elseif self.m_ReqPlayerInfoDict[pIdList] == nil then
    self.m_ReqPlayerInfoDict[pIdList] = true
    self.m_ReqPlayerInfoList[#self.m_ReqPlayerInfoList + 1] = pIdList
  end
end
function MapMgr:TellSerMyPosForce()
  self:_SyncLocalRolePos(true)
end
function MapMgr:UpdateReqPlayerInfoList(dt)
  self.m_ReqPlayerInfoCnt = self.m_ReqPlayerInfoCnt + 1
  if self.m_ReqPlayerInfoCnt == self.m_ReqPlayerInfoTimer then
    for i = 1, self.m_ReqPlayerInfoNum do
      self:SendOneReqPlayerInfo()
    end
    self.m_ReqPlayerInfoCnt = 0
  end
end
g_MapMgr = MapMgr.new()
gamereset.registerResetFunc(function()
  if g_MapMgr then
    g_MapMgr:Clear()
  end
  g_MapMgr = MapMgr.new()
end)
