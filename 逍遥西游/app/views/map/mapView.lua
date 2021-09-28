local MapAssertPath = "xiyou/"
local TransporterPath = "xiyou/ani/eff_transport"
local sharedTextureCache = CCTextureCache:sharedTextureCache()
MapView_ZOrderDown = 20
MapView_ZOrderUp = 9999
g_ShowRunningNPCRoleFlag = true
g_ShowRunningNPCRoleMinShowTime = 10
g_ShowRunningNPCRoleMaxShowTime = 25
g_ShowRunningNPCRoleNumDict = {
  [MapId_DongHaiYuCun] = 10,
  [MapId_Changan] = 10
}
MapId_DongHaiYuCun_RunningManList = {
  {
    {29, 49},
    {14, 81}
  },
  {
    {14, 81},
    {29, 49}
  },
  {
    {89, 13},
    {21, 45}
  },
  {
    {87, 69},
    {9, 40}
  },
  {
    {87, 69},
    {42, 14}
  },
  {
    {42, 14},
    {9, 40}
  },
  {
    {37, 73},
    {42, 14}
  },
  {
    {42, 14},
    {87, 69}
  },
  {
    {29, 49},
    {42, 14}
  },
  {
    {37, 73},
    {29, 49}
  },
  {
    {87, 69},
    {8, 20}
  },
  {
    {8, 20},
    {87, 69}
  },
  {
    {9, 40},
    {87, 69}
  },
  {
    {9, 40},
    {29, 49}
  }
}
MapId_Changan_RunningManList = {
  {
    {142, 10},
    {77, 42}
  },
  {
    {77, 42},
    {142, 10}
  },
  {
    {114, 17},
    {53, 8}
  },
  {
    {53, 8},
    {114, 17}
  },
  {
    {132, 13},
    {39, 16}
  },
  {
    {39, 16},
    {132, 13}
  },
  {
    {99, 44},
    {56, 18}
  },
  {
    {56, 18},
    {99, 44}
  },
  {
    {152, 74},
    {25, 85}
  },
  {
    {25, 85},
    {152, 74}
  },
  {
    {9, 49},
    {27, 6}
  },
  {
    {27, 6},
    {9, 49}
  },
  {
    {12, 27},
    {9, 75}
  },
  {
    {9, 75},
    {12, 27}
  },
  {
    {21, 31},
    {152, 42}
  },
  {
    {152, 42},
    {21, 31}
  },
  {
    {14, 33},
    {25, 60}
  },
  {
    {25, 60},
    {14, 33}
  },
  {
    {74, 43},
    {132, 76}
  },
  {
    {132, 76},
    {74, 43}
  }
}
if CMapView and CMapView.s_IsCache_MapObjDatas then
  for k, v in pairs(CMapView.s_IsCache_MapObjDatas) do
    if v.nodeGrid then
      v.nodeGrid:release()
    end
  end
end
CMapView = class("CMapView", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
CMapView.s_IsCache_MapObjDatas = {}
function CMapView:ctor(mapId, gridPos, posType, extraParam)
  print("mapView:mapId, gridPos, posType, extraParam  = ", mapId, gridPos, posType, extraParam)
  if gridPos then
    print("gridPos==>", gridPos[1], gridPos[2])
  end
  if g_DetectViewRelease then
    ViewRelease_CreateView(self)
  end
  self:setNodeEventEnabled(true)
  extraParam = extraParam or {}
  self.m_MapId = mapId
  self.m_LocalRoleInitDir = extraParam.initDir or 5
  self.m_ZOrder = {
    bg = 20,
    choose = 21,
    route = 22,
    normal_effect = 23,
    teleporter = 25,
    role = 30,
    name = 40,
    cdTime = 45,
    touchmap = 150
  }
  self.m_IsShowTestLayer = false
  self.m_IsClear = false
  self.m_IsExitsSelf = true
  self.m_AutoRouteFbInfo = nil
  self.m_AutoXunluoTimes = nil
  self.m_AutoXunluoListener = nil
  self.m_AutoXunluoOldPos = {}
  self.m_AutoXunluoCurIdx = 1
  self.m_Trace = CCNode:create()
  self:addNode(self.m_Trace, self.m_ZOrder.route)
  self.m_Trace:setVisible(self.m_IsShowTestLayer)
  self.m_IsMapLoading = true
  self.m_AsyncProgressLoadPic = 0.7
  self.m_AsyncProgressLoadObj = 0.3
  self.m_AsyncPerPreLoadObj = 0
  self.m_CurLoadedPicNum = 0
  self.m_AsyncLoadPicList = {}
  self.m_IsAsyncUpdate = false
  self.m_CurLoadProgress = 0
  self.m_LastTouchPos = {0, 0}
  self.m_IsDragedMap = false
  self.m_IsDetectDragMap = false
  self.m_NPC = {}
  self.m_NpcDeleted = {}
  self.m_Monster = {}
  self.m_MapTreasure = {}
  self.m_MissionMonster = {}
  self.m_Player = {}
  self.m_PlayerLoaded = {}
  self.m_PlayerInitGridPos = gridPos
  self.m_InitPosType = posType
  self.m_saveHuacheGrid = {-1, -1}
  self.m_isInXunyou = false
  self.m_isLocalPlayerInXunyou = false
  self.m_xunyouPlayerIds = {}
  self:flushXunyouState()
  self.m_HadSetNpcMissionStatus = {}
  if self.m_InitPosType == nil then
    self.m_InitPosType = MapPosType_EditorGrid
  end
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self, self.Touch))
  self:InitMapInfo()
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  local function listener(event)
    local name = event.name
    if name == "cleanup" then
      self:Clear()
    end
  end
  local handle = self:addNodeEventListener(cc.NODE_EVENT, listener)
  self:InitSyncPlayerLimit()
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Mission)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_BPWar)
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_Marry)
  self:setScale(AllMapScaleNum)
end
function CMapView:onEnterEvent()
  self:scheduleUpdate()
end
function CMapView:getGridSize()
  return unpack(self.m_MapGridSize)
end
function CMapView:getPosByGrid(gridX, gridY)
  return self.m_MapGridSize[1] * gridX, self.m_MapGridSize[2] * gridY
end
function CMapView:getMidPosByGrid(gridX, gridY)
  return self.m_MapGridSize[1] * (gridX + 0.5), self.m_MapGridSize[2] * (gridY + 0.5)
end
function CMapView:getPosByEditorGrid(gridX, gridY)
  return self.m_MapGridSize[1] * gridX, self.m_MapGridSize[2] * (self.m_MapGridNum[2] - gridY - 1)
end
function CMapView:getMidPosByEditorGrid(gridX, gridY)
  return self.m_MapGridSize[1] * (gridX + 0.5), self.m_MapGridSize[2] * (self.m_MapGridNum[2] - gridY - 1 + 0.5)
end
function CMapView:getGridByEditorGrid(gridX, gridY)
  return gridX, self.m_MapGridNum[2] - 1 - gridY
end
function CMapView:getEditorGridByGrid(gridX, gridY)
  return gridX, self.m_MapGridNum[2] - 1 - gridY
end
function CMapView:getGridByPos(x, y)
  return math.floor(x / self.m_MapGridSize[1]), math.floor(y / self.m_MapGridSize[2])
end
function CMapView:getGridIsOpaque(gridX, gridY)
  local k = string.format("%d..%d", gridX, gridY)
  return self.m_Opaque[k] == 1
end
function CMapView:touchedMap(screenX, screenY, judgeRole)
  TellSerToStopGuaji()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    self:flushSelectEffect(nil)
    return
  end
  local lPos = self:convertToNodeSpace(ccp(screenX, screenY))
  local gridx, gridy = self:getGridByPos(screenX, screenY)
  self:endAutoXunluo(false)
  if self.m_IsAutoRouting == true then
    self:setAutoRouteFinished(false)
  end
  local touchRole, tRole
  if judgeRole ~= false then
    touchRole = self:TouchRoleDetect(lPos.x, lPos.y)
    if touchRole ~= nil then
      tRole = touchRole:getMapRoleType()
      if tRole == LOGICTYPE_MONSTER then
        local mPosx, mPosy = touchRole:getPosition()
        local mPos = self:convertToWorldSpace(ccp(mPosx, mPosy))
        local gridTop = {
          gridx + 1,
          gridy + 2
        }
        local gridBotton = {
          gridx - 1,
          gridy - 4
        }
        local monsterlist = {}
        local topX, topY = self:getMidPosByGrid(gridTop[1], gridTop[2])
        local topNodePos = self:convertToNodeSpace(ccp(topX, topY))
        local bottonX, bottonY = self:getMidPosByGrid(gridBotton[1], gridBotton[2])
        local bottonNodePos = self:convertToNodeSpace(ccp(bottonX, bottonY))
        for mId, mObj in pairs(self.m_Monster) do
          local mObjX, mOjbY = mObj:getPosition()
          if mObjX >= bottonNodePos.x and mObjX <= topNodePos.x and mOjbY >= bottonNodePos.y and mOjbY <= topNodePos.y then
            monsterlist[#monsterlist + 1] = mObj
          end
        end
        if #monsterlist <= 1 then
          self:RoleHadChoosed(touchRole)
        else
          local MosterListView = CMapMonsterNameView.new({
            monsterList = monsterlist,
            callback = handler(self, self.RoleHadChoosed),
            x = mPos.x,
            y = mPos.y
          })
          g_CurSceneView:addSubView({
            subView = MosterListView,
            zOrder = MainUISceneZOrder.menuView
          })
        end
      else
        self:RoleHadChoosed(touchRole)
      end
    end
  end
  local route
  if (touchRole == nil or tRole == LOGICTYPE_HERO) and g_LocalPlayer and g_LocalPlayer:getNormalTeamer() ~= true then
    local x, y = self.m_LocalRole:getPosition()
    route = self:FindRoute(x, y, lPos.x, lPos.y)
    if route ~= nil then
      self.m_LocalRole:StopMoveForRoute()
      self.m_LocalRole:MoveLocalRoleToPosRoute(route)
    end
    self:createTouchMapEffect(lPos)
  end
  self:flushSelectEffect(touchRole)
  return route
end
function CMapView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HeroUpdate then
    local playerId = arg[1].pid
    local heroId = arg[1].heroId
    local player = g_DataMgr:getPlayer(playerId)
    if arg[1].pro[PROPERTY_NAME] ~= nil then
      local name = arg[1].pro[PROPERTY_NAME]
      print("====>>>  改名:", name, playerId, heroId, player, player:getMainHeroId())
      if name and player and heroId and heroId == player:getMainHeroId() then
        self:PlayerChangeName(playerId, name)
      end
    elseif arg[1].pro[PROPERTY_RANCOLOR] ~= nil then
      local colorList = arg[1].pro[PROPERTY_RANCOLOR]
      print("====>>>  染色:", colorList, playerId, heroId, player, player:getMainHeroId())
      if colorList and player and heroId and heroId == player:getMainHeroId() then
        self:PlayerChangeColor(playerId, colorList)
      end
    end
    if arg[1].pro[PROPERTY_MAPZuoqiTypeId] ~= nil then
      local mapPlayer = self:getRole(playerId)
      if mapPlayer then
        mapPlayer:changeZuoqiShape()
      end
    end
  elseif msgSID == MsgID_ItemInfo_TakeEquip or msgSID == MsgID_ItemInfo_TakeDownEquip then
    local roleId, itemId = arg[1], arg[2]
    if roleId ~= g_LocalPlayer:getMainHeroId() then
      return
    end
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero then
      local mapPlayer = self:getRole(g_LocalPlayer:getPlayerId())
      if mapPlayer then
        local chibangIns = mainHero:GetEqptByPos(ITEM_DEF_EQPT_POS_CHIBANG)
        if chibangIns then
          local chibang = chibangIns:getTypeId()
          mapPlayer:setChiBang(chibang)
        else
          mapPlayer:setChiBang(0)
        end
      end
    end
  elseif msgSID == MsgID_LifeSkillFuUpdate then
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero then
      local pId = g_LocalPlayer:getPlayerId()
      local mapPlayer = self:getRole(pId)
      if mapPlayer then
        mapPlayer:setMoveSpeed()
        mapPlayer:changeBSF()
        local teamId = g_TeamMgr:getPlayerTeamId(pId)
        if teamId ~= 0 then
          local pIdList = g_TeamMgr:getTeamInfo(teamId)
          if pIdList ~= nil then
            for _, tPId in pairs(pIdList) do
              local tPlayer = self:getRole(tPId)
              if tPlayer ~= nil then
                tPlayer:setMoveSpeed()
              end
            end
          end
        end
      end
    end
  elseif msgSID == MsgID_LocalBpAndJob then
    local playerId = arg[1]
    local bpName = arg[2]
    local bpJob = arg[3]
    self:PlayerChangBpName(playerId, bpName, bpJob)
  elseif msgSID == MsgID_Mission_NpcStatusChanged then
    self:flushNpcMissionStatus(arg[1])
    g_MapMgr:flushMissionMonsters()
  elseif msgSID == MsgID_Scene_War_Enter then
    if g_LocalPlayer:getIsFollowTeam() ~= 0 then
      self:stoptAutoRoute()
    end
  elseif msgSID == MsgID_Scene_Fuben_Enter then
    if g_LocalPlayer:getIsFollowTeam() == 0 or self.m_IsGuajiIngFlag then
    else
      self:stoptAutoRoute()
    end
  elseif msgSID == MsgID_BPWar_State then
    if self:IsBangPaiMap() then
      if g_BpWarMgr:getBpWarState() == BPWARSTATE_READY then
        self:forceToSetUnWalkableRouteForTemp()
      else
        self:recoverSetUnWalkableRouteForTemp()
      end
    end
  elseif msgSID == MsgID_ChengWeiChanged then
    local playerId = arg[1]
    local player = self:getRole(playerId)
    if player then
      player:flushChengwei()
    end
  elseif msgSID == MsgID_Team_SetCaptain then
    local pId = arg[2]
    local isCaptain = arg[3]
    if pId == g_LocalPlayer:getPlayerId() and isCaptain == TEAMCAPTAIN_YES then
      self:CheckToReStartGuaji()
    end
  elseif msgSID == MsgID_Marry_HuaCheDataUpdate then
    self:flushXunyouState()
  end
end
function CMapView:CheckToReStartGuaji()
  if data_getIsGuajiMap(self.m_MapId) == true and g_LocalPlayer:getGuajiState() == GUAJI_STATE_ON then
    TellSerToStartGuaji()
  end
end
function CMapView:IsBangPaiMap()
  return g_MapMgr:checkIsBpWarMap(self.m_MapId)
end
function CMapView:IsDuelMap()
  return g_MapMgr:IsInDuelMap()
end
function CMapView:getRoleZOrderByPos(x, y)
  return self.m_ZOrder.role + self.m_MapSize.height - y
end
function CMapView:RolePosChanged(roleIns, x, y)
  if self.m_IsClear or self.m_IsExitsSelf == nil then
    return
  end
  if self.m_RoleChoosed == roleIns then
    self:flushSelectPos()
  end
  local s = roleIns:getShapeSize()
  local gx, gy = self:getGridByPos(x, y)
  local oldGX, oldGY = roleIns:getGridPos()
  local newZ = self.m_ZOrder.role + self.m_MapSize.height - y
  if roleIns:getZOrder() ~= newZ then
    self:reorderChild(roleIns, newZ)
  end
  if oldGX ~= gx or oldGY ~= gy then
    roleIns:setGridPos(gx, gy)
    roleIns:changeOpaque(self:getGridIsOpaque(gx, gy))
  end
  if roleIns == self.m_LocalRole and self.m_isLocalPlayerInXunyou ~= true then
    local cx = display.width / 2 - x
    local cy = display.height / 2 - y
    local delayMoveActionFlag = true
    self:setMapToPos(cx, cy, delayMoveActionFlag)
    g_MapMgr:MainRoleGridPosChange(oldGX, oldGY, gx, gy, x, y)
    self:detectTeleportes()
    if self.m_IsDynamicLoadBg then
      self:DynamicLoadBgUpdate(x, y)
    end
    ClearAllShowProgressBar()
    print("-----[localrole pos]-->", x, y)
  end
end
function CMapView:localPlayerHuachePosChanged(x, y)
  if self.m_IsClear or self.m_IsExitsSelf == nil then
    return
  end
  local cx = display.width / 2 - x
  local cy = display.height / 2 - y
  self:setMapToPos(cx, cy)
  local gx, gy = self:getGridByPos(x, y)
  local oldGX = self.m_saveHuacheGrid[1]
  local oldGY = self.m_saveHuacheGrid[2]
  g_MapMgr:MainRoleGridPosChange(oldGX, oldGY, gx, gy, x, y)
  self.m_saveHuacheGrid = {gx, gy}
  if self.m_IsDynamicLoadBg then
    self:DynamicLoadBgUpdate(x, y)
  end
  ClearAllShowProgressBar()
end
function CMapView:flushXunyouState()
  self.m_isLocalPlayerInXunyou = false
  if g_HunyinMgr and g_HunyinMgr:isInXunyouMap() and g_HunyinMgr:IsInXunYouTime() then
    self.m_isInXunyou = true
    local pids = g_HunyinMgr:getXunyouPlayerIds() or {}
    self.m_xunyouPlayerIds = {}
    for i, pid in ipairs(pids) do
      self.m_xunyouPlayerIds[pid] = true
      local role = self:getRole(pid)
      if role then
        role:setHide(true)
      end
    end
    if g_HunyinMgr:IsLocalRoleInHuaChe() then
      self.m_isLocalPlayerInXunyou = true
    end
  elseif self.m_isInXunyou then
    self.m_isInXunyou = false
    for pid, v in pairs(self.m_xunyouPlayerIds) do
      local role = self:getRole(pid)
      if role then
        role:setHide(false)
      end
      if role == self.m_LocalRole then
        local x, y = self.m_LocalRole:getPosition()
        self:RolePosChanged(self.m_LocalRole, x, y)
      end
      local teamId = g_TeamMgr:getPlayerTeamId(pid)
      if teamId ~= nil then
        g_MapMgr:setTeamStatusDirty(teamId)
      end
    end
    self.m_xunyouPlayerIds = {}
  end
  if g_HunyinMgr:IsLocalRoleInHuaChe() then
    self.m_isLocalPlayerInXunyou = true
  else
    self.m_isLocalPlayerInXunyou = false
  end
end
function CMapView:stopFollow(pid)
  print("\t\t -->> Follow CMapView:stopFollow:", pid)
  local role = self:getRole(pid)
  if role then
    role:setFollowTo(nil)
  end
end
function CMapView:setFollow(pid, followPid, resetPos)
  print("\t\t -->>Follow CMapView:setFollow:", pid, followPid, resetPos)
  if g_MapMgr:getIsOnlyShowCaptainForOtherMap() then
    print("检测是否需要隐藏非本队队员")
    local isHide = false
    if g_TeamMgr:getPlayerIsOtherFollowTeamer(pid) == true then
      print("--------隐藏非本队队员:", pid)
      self:delRole(pid)
      isHide = true
    end
    if g_TeamMgr:getPlayerIsOtherFollowTeamer(followPid) == true then
      print("--------隐藏非本队队员:", followPid)
      self:delRole(followPid)
      isHide = true
    end
    if isHide then
      return
    end
  end
  local role = self:getRole(pid)
  if role then
    local toRole = self:getRole(followPid)
    role:setFollowTo(toRole, resetPos)
    if toRole then
      role:setHide(false)
      toRole:setFollowing(role)
    end
  end
end
function CMapView:clearFollowIds(pid)
  print("\t\t -->>Follow CMapView:clearFollowIds:", pid)
  local role = self:getRole(pid)
  if role then
    role:setFollowTo(nil)
    role:setFollowing(nil)
  end
end
function CMapView:RoleMoveRouteFinished(role)
  if self.m_LocalRole == role then
    print("======= 寻路移动结束")
    if self.m_IsAutoRouting == true then
      self:setAutoRouteFinished(true)
    else
      self:routeFinishedForXunluo()
    end
    self:checkIsBpWarRouteLimit(role)
  end
end
function CMapView:checkIsBpWarRouteLimit(role)
  if self:IsBangPaiMap() then
    if g_BpWarMgr:getBpWarState() == BPWARSTATE_READY then
      local x, y = role:getPosition()
      for _, v in pairs(self.m_ForceToSetUnWalkable) do
        local px, py = self:getMidPosByGrid(v[1], v[2])
        if (px - x) ^ 2 + (py - y) ^ 2 < 2500 then
          ShowNotifyTips("战斗还没开始，不能走出准备区域以外的地方")
          return
        end
      end
    end
  elseif self:IsDuelMap() then
    local x, y = role:getPosition()
    local gridX, gridY = self:getGridByPos(x, y)
    for i = -1, 1 do
      for j = -1, 1 do
        local nodeGrid = self.m_NodeGrid:getNode(gridX + i, gridY + j)
        if nodeGrid and nodeGrid.walkable == false then
          if g_LocalPlayer and g_LocalPlayer:getNormalTeamer() ~= true then
            ShowNotifyTips("此为生死擂台，不可离开该区域")
          end
          return
        end
      end
    end
  end
end
function CMapView:_getInitPos()
  return self:getPosByType(self.m_PlayerInitGridPos, self.m_InitPosType)
end
function CMapView:getPosByType(posTable, posType)
  if posType == MapPosType_PixelPos then
    return posTable[1], posTable[2]
  elseif posType == MapPosType_EditorGrid then
    return self:getMidPosByEditorGrid(posTable[1], posTable[2])
  else
    return self:getMidPosByGrid(posTable[1], posTable[2])
  end
end
function CMapView:InitMapInfo()
  local mapInfo = data_MapInfo[self.m_MapId]
  self.m_MapBornpoing = mapInfo.bornpoint
  self.m_MapName = mapInfo.name
  self.m_MapData = MapConfigData[mapInfo.mapfile]
  self.m_MapBgSize = CCSize(mapInfo.bgw, mapInfo.bgh)
  self.m_MapGridNum = self.m_MapData.gridNum
  self.m_MapGridSize = self.m_MapData.gridSize
  self.m_MapSize = CCSize(self.m_MapGridNum[1] * self.m_MapGridSize[1], self.m_MapGridNum[2] * self.m_MapGridSize[2])
  self:setSize(self.m_MapSize)
  self.m_DynamicBoundPos = {
    display.width / 2,
    self.m_MapSize.width - display.width / 2,
    display.height / 2,
    self.m_MapSize.height - display.height / 2
  }
  self.m_ZOrder.name = self.m_ZOrder.name + self.m_MapSize.height + 100
  self.m_BgSprites = {}
  self:LoadBg(self.m_MapData.bg)
  self.m_ForceToSetUnWalkable = {}
  self.m_UnWalkableRouteRecord = {}
  if self:IsBangPaiMap() and self.m_MapData.stockade ~= nil then
    for _, v in ipairs(self.m_MapData.stockade) do
      local k = string.format("%d..%d", v[1], v[2])
      self.m_ForceToSetUnWalkable[k] = v
    end
  end
  self.m_Route = {}
  self.m_Opaque = {}
  self.m_NodeGrid = nil
  local cacheData
  if CMapView.s_IsCache_MapObjDatas then
    cacheData = CMapView.s_IsCache_MapObjDatas[self.m_MapId]
  end
  if cacheData ~= nil then
    print("---->> test 11 : 使用缓存")
    self.m_NodeGrid = cacheData.nodeGrid
    self.m_NodeGrid:retain()
    self.m_Route = cacheData.route
    self.m_Opaque = cacheData.opaque
  else
    print("---->> test 11 : 新创建")
    self.m_NodeGrid = NodeGrid:create(self.m_MapGridNum[1], self.m_MapGridNum[2])
    self.m_NodeGrid:retain()
    for i, v in ipairs(self.m_MapData.route) do
      self:createRoute(v[1], v[2])
      local k = string.format("%d..%d", v[1], v[2])
      self.m_Route[k] = 1
      self.m_NodeGrid:setWalkable(v[1], v[2], false)
      if self.m_ForceToSetUnWalkable[k] ~= nil then
        self.m_UnWalkableRouteRecord[k] = true
      end
    end
    for i, v in ipairs(self.m_MapData.opaque) do
      self:createOpaque(v[1], v[2])
      self.m_Opaque[string.format("%d..%d", v[1], v[2])] = 1
    end
    if self.m_MapId == 2 then
      self.m_NodeGrid:retain()
      CMapView.s_IsCache_MapObjDatas[self.m_MapId] = {
        nodeGrid = self.m_NodeGrid,
        route = self.m_Route,
        opaque = self.m_Opaque
      }
    end
  end
  if self:IsBangPaiMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_READY then
    self:forceToSetUnWalkableRouteForTemp()
  end
  self:InitTeleporters()
  local x, y = self:_getInitPos()
  print("======= mapView init pos:", x, y)
  local cx = display.width / 2 - x
  local cy = display.height / 2 - y
  self:setMapToPos(cx, cy)
  self:createPlayer(g_LocalPlayer:getPlayerId(), x, y, nil, false)
  self:InitTouchMapEffect()
  self:StartAsyncLoadPic()
end
function CMapView:forceToSetUnWalkableRouteForTemp()
  for i, v in pairs(self.m_ForceToSetUnWalkable) do
    local k = string.format("%d..%d", v[1], v[2])
    if self.m_UnWalkableRouteRecord[k] ~= true then
      self.m_Route[k] = 1
      self.m_NodeGrid:setWalkable(v[1], v[2], false)
    end
  end
end
function CMapView:recoverSetUnWalkableRouteForTemp()
  for i, v in pairs(self.m_ForceToSetUnWalkable) do
    local k = string.format("%d..%d", v[1], v[2])
    if self.m_UnWalkableRouteRecord[k] ~= true then
      self.m_Route[k] = nil
      self.m_NodeGrid:setWalkable(v[1], v[2], true)
    end
  end
  self.m_ForceToSetUnWalkable = {}
  self.m_UnWalkableRouteRecord = {}
end
function CMapView:AddBgTexture(texture, x, y)
  local bgSprite = display.newSprite(texture)
  bgSprite:setAnchorPoint(ccp(0, 0))
  bgSprite:setPosition(ccp(x, y))
  self:addNode(bgSprite, self.m_ZOrder.bg)
end
function CMapView:Touch(touchObj, t)
  if self.m_IsMapLoading == true then
    return
  end
  local x, y
  if t == TOUCH_EVENT_BEGAN then
    self.m_IsDragedMap = false
    local pt = self:getTouchStartPos()
    x = pt.x
    y = pt.y
    SendMessage(MsgID_MapScene_TouchMapBegan)
    if g_MissionMgr then
      g_MissionMgr:setAutoTraceMissionId(nil)
    end
  elseif t == TOUCH_EVENT_MOVED then
    local pt = self:getTouchMovePos()
    x = pt.x
    y = pt.y
  elseif t == TOUCH_EVENT_ENDED then
    local pt = self:getTouchEndPos()
    x = pt.x
    y = pt.y
    if self.m_IsDragedMap == false then
      print("==>> touch")
      self:touchedMap(x, y)
    end
  end
  if CMainUIScene.Ins then
    CMainUIScene.Ins:HadTouchMap(t, x, y)
  end
  if self.m_IsDetectDragMap then
    self:TouchToMoveMap(t, x, y)
  end
  return true
end
function CMapView:frameUpdate(dt)
  if self.m_IsAsyncUpdate then
    self:UpdateAsyncLoad(dt)
  end
  if self.m_AutoXunluoTimes ~= nil then
    self:UpdateAutoXunluo(dt)
  end
  if false and self.m_LocalRole then
    if self.m_ShowDeltaPos == nil then
      local layer = CCLayerColor:create(ccc4(255, 0, 0, 255))
      self:addNode(layer, self.m_ZOrder.teleporter + 100)
      layer:setContentSize(CCSize(40, 40))
      self.m_ShowDeltaPos = layer
    end
    local x, y = self.m_LocalRole:getPositionWithDeltaTime()
    self.m_ShowDeltaPos:setPosition(ccp(x - 20, y - 20))
  end
end
function CMapView:addLoadProgress(pro)
  self.m_CurLoadProgress = self.m_CurLoadProgress + pro
  if self.m_CurLoadProgress > 1 then
    self.m_CurLoadProgress = 1
  elseif self.m_CurLoadProgress < 0 then
    self.m_CurLoadProgress = 0
  end
  SendMessage(MsgID_MapLoading_Progress, self.m_CurLoadProgress)
end
function CMapView:addAsyncPicLoad(func, path, arg, isInitLoad, loadParam, priority, isInsertToFront)
  if isInitLoad ~= false then
    self.m_CurLoadedPicNum = 0
    self.m_AsyncLoadPicList[#self.m_AsyncLoadPicList + 1] = {
      func,
      path,
      arg,
      loadParam,
      priority,
      isInsertToFront
    }
  else
    addDynamicLoadTexture(path, function(handlerName, texture)
      if self.m_IsClear or self.m_IsExitsSelf == nil then
        return
      end
      if func then
        func(path, unpack(arg))
      end
    end, loadParam, priority, isInsertToFront)
  end
end
function CMapView:LoadedAsyncPic_(handlerName, texture)
  if self.m_IsClear or self.m_IsExitsSelf == nil then
    return
  end
  local len = #self.m_AsyncLoadPicList
  self.m_CurLoadedPicNum = self.m_CurLoadedPicNum + 1
  if self.m_IsMapLoading then
    self:addLoadProgress(1 / len * self.m_AsyncProgressLoadPic)
  end
  if len == self.m_CurLoadedPicNum then
    self.m_CurLoadedPicNum = 0
    self.m_IsAsyncUpdate = true
  end
end
function CMapView:StartAsyncLoadPic()
  for i, d in ipairs(self.m_AsyncLoadPicList) do
    addDynamicLoadTexture(d[2], handler(self, self.LoadedAsyncPic_), d[4], d[5], d[6])
  end
  self.m_AsyncPerPreLoadObj = 1 / #self.m_AsyncLoadPicList * self.m_AsyncProgressLoadObj
end
function CMapView:UpdateAsyncLoad(dt)
  local len = #self.m_AsyncLoadPicList
  if len == 0 then
    self:LoadMapFinished()
    return
  end
  self.m_CurLoadedPicNum = self.m_CurLoadedPicNum + 1
  local d = table.remove(self.m_AsyncLoadPicList, 1)
  local func, path, arg = unpack(d)
  if func then
    func(path, unpack(arg))
  end
  if self.m_IsMapLoading then
    self:addLoadProgress(self.m_AsyncPerPreLoadObj)
  end
end
function CMapView:isMapLoading()
  return self.m_IsMapLoading
end
function CMapView:LoadMapFinished()
  print("\n===>> 加载地图完成\n")
  SendMessage(MsgID_MapLoading_Finished)
  self.m_IsAsyncUpdate = false
  self.m_IsMapLoading = false
  self:flushNpcMissionStatus(g_MissionMgr:getMissionStatusForNpc())
  self:LoadNpc(false)
  self:CreateRoleSelectEffect()
  self:CreateMapEffect()
  self:CreateWarBackground()
  self:CheckToReStartGuaji()
  if self.m_MapId == MapId_XueZhanShaChang and activity.xzsc:getStatus() == 3 then
    ShowNotifyTips("你已进入血战沙场活动地图，活动即将开始")
  end
  if self.m_LocalRole then
    local x, y = self.m_LocalRole:getPosition()
    g_MapMgr:detectRoleCreateOrRelease(x, y, true)
  end
end
function CMapView:getRole(playerId)
  return self.m_Player[playerId]
end
function CMapView:getLocalRole()
  local localPlayerId = g_LocalPlayer:getPlayerId()
  return self:getRole(localPlayerId)
end
function CMapView:getAllRole()
  return self.m_Player
end
function CMapView:delRole(playerId)
  local role = self.m_Player[playerId]
  if self.m_RoleChoosed == role then
    self:flushSelectEffect(nil)
  end
  if role then
    role:RemoveAll()
    self.m_Player[playerId] = nil
    self.m_PlayerLoaded[playerId] = nil
  end
  if self.m_CurSyncPlayers[playerId] ~= nil then
    self.m_CurSyncPlayers[playerId] = nil
    self.m_CurSyncPlayerNum = self.m_CurSyncPlayerNum - 1
  end
end
function CMapView:getNpcIns(npcId)
  local npcData = self.m_NPC[npcId]
  if npcData then
    return npcData.roleIns
  end
  return nil
end
function CMapView:LoadNpc(isShowMapLoading)
  local npcIds = data_getNpcByMapId(self.m_MapId)
  for i, npcId in ipairs(npcIds) do
    if data_TempNpcForMission[npcId] == nil and self.m_NpcDeleted[npcId] ~= true then
      local npcInfo = data_NpcInfo[npcId]
      if npcInfo then
        if npcInfo.dynamic ~= 1 then
          local shapeId = npcInfo.shape
          local gridX, gridY = npcInfo.pos[2], self.m_MapGridNum[2] - npcInfo.pos[3] - 1
          local x, y = self:getMidPosByGrid(gridX, gridY)
          local isLoadNow = false
          if isShowMapLoading then
            local path, x, y = data_getBodyPathByShape(shapeId)
            if path:sub(-6) == ".plist" then
              path = path:sub(1, -6) .. "png"
            else
              path = path .. ".png"
            end
            local dynamicLoadTextureMode = getBodyDynamicLoadTextureMode(shapeId)
            self:addAsyncPicLoad(handler(self, self.LoadNpc_), path, {npcId}, nil, {pixelFormat = dynamicLoadTextureMode})
          else
            local name = npcInfo.name
            local role = MapNpcShape.new(npcId, shapeId, handler(self, self.RolePosChanged), npcInfo.opaque, npcInfo.label)
            self:addChild(role, self.m_ZOrder.role)
            role:setPosition(ccp(x, y))
            role:setDirection(dir)
            self:createNameForShape(role, name, ccc3(255, 255, 0), 0)
            self.m_NPC[npcId] = {data = npcInfo, roleIns = role}
          end
        end
      else
        printLog("ERROR", "LoadNpc找不到对应npc的信息[%d]", npcId)
      end
    end
  end
  self:flushNpcMissionStatus()
end
function CMapView:LoadNpc_(pngPath, npcId)
  if self.m_NpcDeleted[npcId] == true then
    return
  end
  local npcInfo = data_NpcInfo[npcId]
  if npcInfo then
    local shapeId = npcInfo.shape
    local gridX, gridY = npcInfo.pos[2], self.m_MapGridNum[2] - npcInfo.pos[3] - 1
    local dir = npcInfo.dir
    local name = npcInfo.name
    local role = MapNpcShape.new(npcId, shapeId, handler(self, self.RolePosChanged), npcInfo.opaque, npcInfo.label)
    self:addChild(role, self.m_ZOrder.role)
    local x, y = self:getMidPosByGrid(gridX, gridY)
    role:setPosition(ccp(x, y))
    role:setDirection(dir)
    self:createNameForShape(role, name, ccc3(225, 255, 0), 0)
    self.m_NPC[npcId] = {data = npcInfo, roleIns = role}
  else
    printLog("ERROR", "LoadNpc_找不到对应npc的信息[%d]", npcId)
  end
end
function CMapView:DeleteNormalNpc(npcId)
  self.m_NpcDeleted[npcId] = true
  local npcData = self.m_NPC[npcId] or {}
  local npcIns = npcData.roleIns
  if npcIns then
    self.m_NPC[npcId] = nil
    npcIns:RemoveAll()
    self:DetectSelectEffect(npcIns)
  end
end
function CMapView:DeleteTempNpcInMap(npcId)
  local d = self.m_NPC[npcId]
  if d then
    if d.roleIns then
      self:DeleteRoleFromMap(d.roleIns)
    end
    if d.roleIns == self.m_RoleChoosed then
      self:flushSelectEffect()
    end
    self.m_NPC[npcId] = nil
  end
end
function CMapView:createTempNpcDelEffect_(z)
  local plistpath = "xiyou/ani/eff_temp_npc_del.plist"
  local times = 1
  local eff = CreateSeqAnimation(plistpath, times, nil, true, false)
  self:addNode(eff, z)
  return eff
end
function CMapView:LoadTempNpcInMap(npcId)
  local d = self.m_NPC[npcId]
  if d == nil then
    local npcInfo = data_NpcInfo[npcId]
    if npcInfo then
      local shapeId = npcInfo.shape
      local path, x, y = data_getBodyPathByShape(shapeId)
      if path:sub(-6) == ".plist" then
        path = path:sub(1, -6) .. "png"
      else
        path = path .. ".png"
      end
      self:LoadNpc_(path, npcId)
    end
  end
end
function CMapView:createPlayer(playerId, posX, posY, finishListener, isAsync, isInitLoad)
  if self.m_PlayerLoaded[playerId] == 1 then
    print("self.m_PlayerLoaded[playerId]:", self.m_PlayerLoaded[playerId])
    return false
  end
  if isAsync == nil then
    isAsync = true
  end
  local player = g_DataMgr:getPlayer(playerId)
  if player == nil then
    printLog("ERROR", "ID为[%s]的玩家不存在", playerId)
    return
  end
  local mainHeroIns = player:getMainHero()
  if mainHeroIns == nil then
    printLog("ERROR", "ID为[%s]的玩家 找不到主英雄", playerId)
    return
  end
  self.m_PlayerLoaded[playerId] = 1
  local isLocal = player:isLocal()
  local roleTypeId = mainHeroIns:getTypeId()
  local name = mainHeroIns:getProperty(PROPERTY_NAME)
  local bpName = mainHeroIns:getProperty(PROPERTY_BPNAME)
  local bpId = mainHeroIns:getProperty(PROPERTY_BPID)
  local placeId = mainHeroIns:getProperty(PROPERTY_BPJOB)
  local chibang = mainHeroIns:getProperty(PROPERTY_CHIBANG)
  if playerId == g_LocalPlayer:getPlayerId() then
    local chibangIns = mainHeroIns:GetEqptByPos(ITEM_DEF_EQPT_POS_CHIBANG)
    if chibangIns then
      chibang = chibangIns:getTypeId()
    else
      chibang = 0
    end
  end
  if bpName ~= nil and bpName ~= 0 and 0 < string.len(bpName) then
    local bpJobName = data_getBangpaiPlaceName(placeId)
    bpName = bpName .. bpJobName
  else
    bpName = nil
  end
  local colorList = mainHeroIns:getProperty(PROPERTY_RANCOLOR)
  local shapeId = data_getRoleShape(roleTypeId)
  local path, x, y = data_getBodyPathByShape(shapeId)
  if path:sub(-6) == ".plist" then
    path = path:sub(1, -6) .. "png"
  else
    path = path .. ".png"
  end
  if isAsync then
    self:addAsyncPicLoad(handler(self, self.LoadPlayer_), path, {
      playerId,
      roleTypeId,
      name,
      bpId,
      bpName,
      placeId,
      colorList,
      chibang,
      isLocal,
      posX,
      posY,
      finishListener
    }, isInitLoad)
  else
    self:LoadPlayer_(path, playerId, roleTypeId, name, bpId, bpName, placeId, colorList, chibang, isLocal, posX, posY, finishListener)
  end
  return true
end
function CMapView:LoadPlayer_(pngPath, playerId, roleTypeId, name, bpId, bpName, placeId, colorList, chibang, isLocal, x, y, finishListener)
  if self.m_IsClear or self.m_IsExitsSelf == nil then
    print("LoadPlayer_:self.m_IsClear :", self.m_IsClear)
    print("LoadPlayer_:self.m_IsExitsSelf :", self.m_IsExitsSelf)
    return
  end
  local role = MapPlayerShape.new(playerId, roleTypeId, handler(self, self.RolePosChanged))
  self:addChild(role, self.m_ZOrder.role)
  SendMessage(MsgID_MapScene_CreateNewPlayer, playerId)
  if isLocal then
    role:setIsLocalPlayer(true)
    self.m_LocalRole = role
    role:setDirection(self.m_LocalRoleInitDir)
    role:setRouteMoveFinishListener(handler(self, self.RoleMoveRouteFinished))
  end
  role:setBpId(bpId, placeId)
  self:createNameForShape(role, name, ccc3(225, 255, 0))
  self:createBpNameForShape(role, bpName)
  self.m_Player[playerId] = role
  role:setRanColorList(colorList)
  role:setChiBang(chibang)
  g_MapMgr:reflushCaptainRoleStatusByPlayerId(playerId)
  g_MapMgr:updatePlayerWarStatus(playerId)
  role:setPosition(ccp(x, y))
  if self.m_isInXunyou and self.m_xunyouPlayerIds[playerId] == true then
    role:setHide(true)
  end
  if finishListener then
    finishListener()
  end
end
function CMapView:createNameForShape(shapeIns, name, color)
  shapeIns:setRoleName(name, color)
end
function CMapView:createBpNameForShape(shapeIns, bpName)
  shapeIns:setRoleBpName(bpName)
end
function CMapView:createNameForTeleporter(teleporterIns, name)
  print("===>> createNameForTeleporter:", teleporterIns, name)
  if name == nil then
    return
  end
  local x, y = teleporterIns:getPosition()
  local size = teleporterIns:getTextureRect().size
  local nameTxt = ui.newTTFLabel({
    text = name,
    font = KANG_TTF_FONT,
    size = 26
  })
  nameTxt:setColor(ccc3(0, 255, 255))
  self:addNode(nameTxt, self.m_ZOrder.name)
  local txtSize = nameTxt:getContentSize()
  nameTxt:setPosition(ccp(x, y + size.height / 3))
end
function CMapView:PlayerChangeName(playerId, name, save)
  if save ~= false and playerId ~= g_LocalPlayer:getPlayerId() then
    local player = g_DataMgr:getPlayer(playerId)
    if player then
      local mainHeroIns = player:getMainHero()
      if mainHeroIns then
        mainHeroIns:setProperty(PROPERTY_NAME, name)
      end
    end
  end
  local role = self:getRole(playerId)
  if role then
    role:setRoleName(name)
  end
end
function CMapView:PlayerChangeColor(playerId, colorList, save)
  if save ~= false and playerId ~= g_LocalPlayer:getPlayerId() then
    local player = g_DataMgr:getPlayer(playerId)
    if player then
      local mainHeroIns = player:getMainHero()
      if mainHeroIns then
        mainHeroIns:setProperty(PROPERTY_RANCOLOR, colorList)
      end
    end
  end
  local role = self:getRole(playerId)
  if role then
    role:setRanColorList(colorList)
  end
end
function CMapView:PlayerChangBpName(playerId, bpName, bpJob, save)
  if save ~= false and playerId ~= g_LocalPlayer:getPlayerId() then
    local player = g_DataMgr:getPlayer(playerId)
    if player then
      local mainHeroIns = player:getMainHero()
      if mainHeroIns then
        mainHeroIns:setProperty(PROPERTY_BPNAME, bpName)
        mainHeroIns:setProperty(PROPERTY_BPJOB, bpJob)
      end
    end
  end
  local role = self:getRole(playerId)
  if role then
    if bpName ~= nil and string.len(bpName) > 0 then
      if role.m_PlaceId == bpJob then
        return
      end
      role.m_PlaceId = bpJob
      local bpJobName = data_getBangpaiPlaceName(bpJob)
      bpName = bpName .. bpJobName
    else
      bpName = nil
      role.m_PlaceId = 0
    end
    role:setRoleBpName(bpName)
  end
end
function CMapView:FlushBpWarAttacker()
  for k, r in pairs(self.m_Player) do
    if r then
      r:setBpNameColor()
    end
  end
end
function CMapView:getLocalRoleGrid()
  local x, y = self.m_LocalRole:getPosition()
  return self:getGridByPos(x, y)
end
function CMapView:getLocalRolePos()
  if self.m_LocalRole == nil then
    return nil
  end
  if self.m_isInXunyou and self.m_isLocalPlayerInXunyou then
    local x, y = GetHuochePostition()
    if x ~= nil and y ~= nil then
      return x, y
    end
  end
  return self.m_LocalRole:getPosition()
end
function CMapView:stopLocalPlayerMove()
  if self.m_LocalRole == nil then
    return
  end
  self.m_LocalRole:StopMove()
end
function CMapView:getLocalRolePosWithDeltaTime(deltaTime)
  if self.m_LocalRole == nil then
    return nil
  end
  return self.m_LocalRole:getPositionWithDeltaTime(deltaTime)
end
function CMapView:setLocalRoleFacetoGridPos(gridPos, isEditorPos)
  print("===>> setLocalRoleFacetoGridPos:", gridPos[1], gridPos[2])
  local x, y = self.m_LocalRole:getPosition()
  local dx, dy
  if isEditorPos then
    dx, dy = self:getMidPosByEditorGrid(gridPos[1], gridPos[2])
  else
    dx, dy = self:getMidPosByGrid(gridPos[1], gridPos[2])
  end
  print("dx, dy, x, y = ", dx, dy, x, y)
  local dir = getDirectionByDelayPos(dx - x, dy - y)
  print("dx, dy, x, y, dir = ", dx, dy, x, y, dir)
  if dir then
    self.m_LocalRole:setDirection(dir)
  end
end
function CMapView:setLocalRoleFacetoDir(dir)
  if dir ~= nil and self.m_LocalRole then
    self.m_LocalRole:setDirection(dir)
  end
end
function CMapView:setLocalRoleGridPos(gridPos, isEditorPos)
  local dx, dy
  if isEditorPos then
    dx, dy = self:getMidPosByEditorGrid(gridPos[1], gridPos[2])
  else
    dx, dy = self:getMidPosByGrid(gridPos[1], gridPos[2])
  end
  local x, y = self.m_LocalRole:getPosition()
  print("===>> setLocalRoleGridPos:", gridPos[1], gridPos[2], dx, dy, x, y)
  self.m_LocalRole:StopMove()
  self.m_LocalRole:setPosition(ccp(dx, dy))
end
function CMapView:SyncRolePos(playerId, flag, pPos, isHide, posType)
  print("==>> CMapView:SyncRolePos:", playerId, flag, pPos, isHide, posType)
  print("playerId:", type(playerId))
  if g_MapMgr:getIsOnlyShowCaptainForOtherMap() then
    print("检测是否需要隐藏非本队队员")
    if g_TeamMgr:getPlayerIsOtherFollowTeamer(playerId) == true then
      print("--------隐藏非本队队员:", playerId)
      return
    end
  end
  if posType == nil then
    posType = MapPosType_PixelPos
  elseif pPos and #pPos > 1 then
    local x, y = self:getPosByType(pPos, posType)
    pPos = {x, y}
  end
  if isHide == nil then
    isHide = false
  end
  local role = self:getRole(playerId)
  if self:IsNeedDealPlayerSync(playerId, isHide, role) ~= true then
    return false
  end
  if self.m_isInXunyou and self.m_xunyouPlayerIds[playerId] == true then
    if role then
      role:setHide(true)
    end
    return
  end
  if role == nil then
    if isHide ~= true then
      local pos = pPos
      local finishListener = function()
      end
      if pos and #pos > 1 then
        self:createPlayer(playerId, pos[1], pos[2], finishListener, false, false)
      end
    end
    return true
  end
  if isHide == true then
    print("===>> 角色隐藏-->>", playerId)
    role:setHide(true)
    role:StopMove()
    if self.m_RoleChoosed == role then
      self:flushSelectEffect(nil)
    end
    return false
  end
  print("==>> 角色是否隐藏的:", role:getHide())
  if role:getHide() == true then
    local pos = pPos
    print("==pos:", pos)
    if pos then
      role:setHide(false)
      role:setPosition(ccp(pos[1], pos[2]))
      return false
    end
  end
  local ifForceRouting = true
  if flag == nil then
    flag = 0
  end
  if g_TeamMgr:getPlayerIsCaptainOfLocalPlaerTeam(playerId) then
    print("-------------->>>>>>>>>>>>>> 本队队长:", flag)
    local isRouting, param = role:getCaptainRouteParam()
    if flag == 1 then
      param = param or {}
      if param[1] == 1 and isRouting == true and param[2] == pPos[1] and param[3] == pPos[2] then
        print("本次需要寻路目标和上一次一样，继续当前路径")
        return false
      end
      role:setCaptainRouteParam(false, {
        1,
        pPos[1],
        pPos[2]
      })
    elseif flag == 2 then
      role:setCaptainRouteParam(false, nil)
    elseif flag == 0 and isRouting == true then
      print("正在寻路到目标，不寻路")
      return false
    end
  elseif flag == 1 then
    print("非本队队长不处理目标寻路，防止过多寻路卡机")
    return
  else
    ifForceRouting = false
    role:setCaptainRouteParam(false, nil)
  end
  print("role:getFollowToRole()=", role:getFollowToRole())
  if pPos and (role:getIsMoving() == false or ifForceRouting == true) then
    local x, y = role:getPosition()
    local route = self:FindRoute(x, y, pPos[1], pPos[2])
    if route ~= nil then
      role:StopMove()
      if role:getFollowToRole() == nil then
        role:MoveLocalRoleToPosRoute(route)
      end
    end
  end
  return false
end
function CMapView:setRoleHide(playerId, isHide)
  local role = self:getRole(playerId)
  if role then
    role:setHide(isHide)
  end
end
function CMapView:getMonster(monsterId)
  return self.m_Monster[monsterId]
end
function CMapView:getMonsterIdByMission(missionId)
  return self.m_MissionMonster[missionId]
end
function CMapView:CreateMonster(monsterTypeId, posTable, posType, initDir, mapMonsterType, param, name)
  initDir = initDir or 5
  local monsterId = GetNextMonsterId()
  local monster = MapMonsterShape.new(monsterId, monsterTypeId, mapMonsterType, param, handler(self, self.RolePosChanged))
  self.m_Monster[monsterId] = monster
  monster:setDirection(initDir)
  self:addChild(monster, self.m_ZOrder.role)
  if name == nil then
    local _, _n = data_getRoleShapeAndName(monsterTypeId)
    name = _n or ""
  end
  self:createNameForShape(monster, name, ccc3(225, 255, 0), 0)
  monster:createFightIcon()
  local x, y = self:getPosByType(posTable, posType)
  monster:setPosition(ccp(x, y))
  return monsterId, monster
end
function CMapView:DeleteMonster(monsterId)
  local monsterIns = self.m_Monster[monsterId]
  if monsterIns then
    if monsterIns == self.m_RoleChoosed then
      self:flushSelectEffect()
    end
    self:DeleteRoleFromMap(self.m_Monster[monsterId])
    self.m_Monster[monsterId] = nil
  end
end
function CMapView:DeleteMonsterByMissionId(missionId)
  local monsterId = self.m_MissionMonster[missionId]
  if monsterId then
    self:DeleteMonster(monsterId)
    self.m_MissionMonster[missionId] = nil
  end
end
function CMapView:updateMonsterHeadState(monsterID, state)
  local monsterIns = self.m_Monster[monsterID]
  if monsterIns then
    monsterIns:showTopStatus(MapRoleStatus_InBattle, state == 2)
  end
  return monsterId
end
function CMapView:updateDynamicNpc(id, param)
  local monsterId = param.monsterId
  local monsterIns = self.m_Monster[monsterId]
  if monsterIns == nil and param.typeid ~= nil then
    print("==>updateDynamicNpc CreateMonster:", id, param.typeid, param.loc)
    monsterId, monsterIns = self:CreateMonster(param.typeid, param.loc, MapPosType_EditorGrid, 5, MapMonsterType_Precious, id, param.name)
  end
  if monsterIns then
    monsterIns:showTopStatus(MapRoleStatus_InBattle, param.state == 2)
  end
  return monsterId
end
function CMapView:updateDynamicActiveNpc(npcId, param)
  if self.m_NPC[npcId] ~= nil then
    return
  end
  local npcInfo = param.npcInfo
  local gridX, gridY = npcInfo.pos[2], self.m_MapGridNum[2] - npcInfo.pos[3] - 1
  local x, y = self:getMidPosByGrid(gridX, gridY)
  local role = MapNpcShape.new(npcId, npcInfo.shape, handler(self, self.RolePosChanged), npcInfo.opaque, npcInfo.label)
  self:addChild(role, self.m_ZOrder.role)
  role:setPosition(ccp(x, y))
  role:setDirection(npcInfo.dir)
  self:createNameForShape(role, npcInfo.name, ccc3(255, 255, 0), 0)
  self.m_NPC[npcId] = {data = npcInfo, roleIns = role}
end
function CMapView:DeleteDynamicActive(npcId)
  if self.m_NPC[npcId] ~= nil then
    self:DeleteNormalNpc(npcId)
  end
end
function CMapView:updateDynamicTreasure(id, param)
  if self.m_MapTreasure[id] ~= nil then
    return
  end
  if param.dType == 1 then
    local pos = param.loc
    local treasureObj = CMapTreasure.new(id, param)
    local offy = 30
    local z = self.m_ZOrder.role + self.m_MapSize.height - (pos.y + offy)
    self:addChild(treasureObj, z)
    treasureObj:setPosition(ccp(pos.x, pos.y))
    local gx, gy = self:getGridByPos(pos.x, pos.y + offy)
    treasureObj:setOpaque(self:getGridIsOpaque(gx, gy))
    self.m_MapTreasure[id] = treasureObj
  end
end
function CMapView:DeleteTreasure(id)
  if self.m_MapTreasure[id] ~= nil then
    self.m_MapTreasure[id]:removeFromParentAndCleanup(true)
    self.m_MapTreasure[id] = nil
  end
end
function CMapView:flushAllMonsterForMission(data)
  print([[


 flushAllMonsterForMission]], data)
  if data == nil then
    data = {}
  end
  local oldData = self.m_MissionMonster
  self.m_MissionMonster = {}
  for missionId, d in pairs(data) do
    if oldData[missionId] == nil then
      local warid = d[1]
      local customId = d[2]
      local mType = d[3]
      if missionId == DaTingCangBaoTu_MissionId then
        if CDaTingCangBaoTu.war_data_id ~= nil and CDaTingCangBaoTu.loc_id ~= nil then
          self:createMonsterForMissionBT(DaTingCangBaoTu_MissionId, CDaTingCangBaoTu.war_data_id, CDaTingCangBaoTu.loc_id)
        end
      else
        self:createMonsterForMission(missionId, warid, customId, mType)
      end
    else
      self.m_MissionMonster[missionId] = oldData[missionId]
    end
  end
  for k, v in pairs(oldData) do
    if v ~= self.m_MissionMonster[k] then
      self:DeleteMonster(v)
    end
  end
end
function CMapView:createMonsterForMission(missionId, warid, customId, mType)
  local roleTypeId, name = data_getBossForWar(warid)
  if mType == MapMonsterType_Dayanta then
    local pos = activity.dayanta:getMissionPos(missionId)
    local monsterId = self:CreateMonster(roleTypeId, pos, MapPosType_EditorGrid, pos[3], MapMonsterType_Dayanta, missionId, name)
    self.m_MissionMonster[missionId] = monsterId
  elseif mType == MapMonsterType_TiandiQiShu then
    self:createMonsterForMissionTDQS(missionId, warid, customId, mType)
  else
    local posData = data_CustomMapPos[customId]
    if mType == nil then
      mType = MapMonsterType_Mission
    end
    if roleTypeId ~= nil and posData ~= nil then
      local posTable = posData.WarPos
      local monsterId, monster = self:CreateMonster(roleTypeId, posTable, MapPosType_EditorGrid, posTable[3], mType, missionId, name)
      if mType == MapMonsterType_Mission then
        monster:setMissionStatus(MapRoleStatus_TaskCanCommit, false)
      end
      self.m_MissionMonster[missionId] = monsterId
    end
  end
end
function CMapView:createMonsterForMissionTDQS(missionId, warid, locid, mType)
  local roleTypeId, name = data_getBossForWar(warid)
  local posData = data_CustomMapPos[locid]
  if mType == nil then
    mType = MapMonsterType_Mission
  end
  if roleTypeId ~= nil and posData ~= nil then
    local posTable = posData.WarPos
    if missionId ~= TianDiQiShu_BossMissionId then
      if activity.tiandiqishu:getIsCanStarActive() == true and activity.tiandiqishu:isAtKillingBoss() == false and activity.tiandiqishu.ActiveEnd == false then
        local monsterId, monster = self:CreateMonster(roleTypeId, posTable, MapPosType_EditorGrid, posTable[3], mType, missionId, name)
        if mType == MapMonsterType_Mission then
          monster:setMissionStatus(MapRoleStatus_TaskCanCommit, false)
        end
        self.m_MissionMonster[missionId] = monsterId
      end
    elseif activity.tiandiqishu:getIsCanStarActive() == true and activity.tiandiqishu:isAtKillingBoss() == true and activity.tiandiqishu.ActiveEnd == false then
      local monsterId, monster = self:CreateMonster(roleTypeId, posTable, MapPosType_EditorGrid, posTable[3], mType, missionId, name)
      if mType == MapMonsterType_Mission then
        monster:setMissionStatus(MapRoleStatus_TaskCanCommit, false)
      end
      self.m_MissionMonster[missionId] = monsterId
    end
  end
end
function CMapView:createMonsterForMissionBT(missionId, warid, customId, mType)
  local roleTypeId, name = data_getBossForWar(warid)
  local posData = data_BaotuTask_Loc[customId]
  if mType == nil then
    mType = MapMonsterType_Mission
  end
  if roleTypeId ~= nil and posData ~= nil then
    local posTable = posData.Loc
    local monsterId, monster = self:CreateMonster(roleTypeId, posTable, MapPosType_EditorGrid, posTable[3], mType, missionId, name)
    if mType == MapMonsterType_Mission then
      monster:setMissionStatus(MapRoleStatus_TaskCanCommit, false)
    end
    self.m_MissionMonster[missionId] = monsterId
  end
end
function CMapView:RoleHadChoosed(roleIns)
  print("====>>点击到角色")
  if roleIns.getMapRoleType == nil then
    return
  end
  local t = roleIns:getMapRoleType()
  print("=====>> roleType:", t, LOGICTYPE_HERO, LOGICTYPE_NPC)
  if t == LOGICTYPE_HERO then
    SendMessage(MsgID_MapScene_TouchRole, roleIns:getPlayerId())
    return
  end
  if g_LocalPlayer:getNormalTeamer() == true then
    local msgTxt = "你在一个队伍中不能操作"
    ShowNotifyTips(msgTxt)
    return
  end
  if t == LOGICTYPE_NPC then
    local function open_npc_view()
      local npcId = roleIns:getNpcId()
      if g_MissionMgr:autoCmpNpcMissionOption(npcId) == false then
        CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
      end
    end
    self:MoveToRole_(roleIns, open_npc_view)
  elseif t == LOGICTYPE_MONSTER then
    do
      local ct = roleIns:getCreateType()
      print("====>>点击到[怪物]:", ct)
      local function open_monster_view()
        print("*********  ", open_monster_view)
        if ct == MapMonsterType_Zhuagui then
          print("==>> 抓鬼任务..")
          local monsterTypeId = roleIns:getMonsterTypeId()
          local playerId = roleIns:getParam()
          ZhuaGui.touchMoster(monsterTypeId, playerId)
        elseif ct == MapMonsterType_Precious then
          print("==>> 藏宝图 的怪物..")
          do
            local name = roleIns:getRoleName()
            local npcId = roleIns:getParam()
            CMainUIScene.Ins:ShowMonsterView(roleIns:getMonsterTypeId(), MapMonsterType_Precious, function()
              print("=========>>>> 点击 开始 藏宝图 战斗")
              netsend.netmap.reqDynamicNpcEvent(npcId)
            end, name)
          end
        elseif ct == MapMonsterType_Mission then
          print("==>> 战斗怪物任务类型..")
          local monsterTypeId = roleIns:getMonsterTypeId()
          local missionId = roleIns:getParam()
          g_MissionMgr:ShowMonsterViewForMission(monsterTypeId, missionId)
        elseif ct == MapMonsterType_Dayanta then
          print("==>> 大雁塔类型..")
          local missionId = roleIns:getParam()
          activity.dayanta:touchMonster(missionId)
        elseif ct == MapMonsterType_Tianing then
          print("==>> 天庭类型..")
          local missionId = roleIns:getParam()
          activity.tianting:monsterOptionTouch(missionId)
        elseif ct == MapMonsterType_GuiWang then
          print("==>> 鬼王任务..")
          GuiWang.touchMoster()
        elseif ct == MapMonsterType_ChuMo then
          print("===>>帮派除魔")
          BangPaiChuMo.TouchMoster()
        elseif ct == MapMonsterType_AnZhan then
          print("===>>帮派暗战")
          BangPaiAnZhan.TouchMoster()
        elseif ct == MapMonsterType_Totem then
          print("==>> 图腾..")
          local monsterTypeId = roleIns:getMonsterTypeId()
          BangPaiTotem.touchMoster(monsterTypeId)
        elseif ct == MapMonsterType_xingxiu then
          print("==>> 28星宿")
          activity.xingxiu:touchMonster(roleIns)
        elseif ct == MapMonsterType_shituchangan then
          print("==>> 师徒长安")
          activity.shituchangan:touchMonster(roleIns)
        elseif ct == MapMonsterType_GuanKa then
          print("==>> 光卡怪")
          do
            local para = roleIns:getParam()
            local mapId = para[1]
            local catchId = para[2]
            if data_getCatchNeedTeamFlag(fbId, catchId) then
              local name = roleIns:getRoleName()
              CMainUIScene.Ins:ShowMonsterView(roleIns:getMonsterTypeId(), MapMonsterType_GuanKa, function()
                print("=========>>>> 点击 开始 关卡 战斗")
                netsend.netguanka.askToFightNpc(mapId, catchId)
              end, name)
            else
              netsend.netguanka.askToFightNpc(mapId, catchId)
            end
          end
        elseif ct == MapMonsterType_XiuLuo then
          XiuLuo.touchMoster()
        elseif ct == MapMonsterType_TiandiQiShu then
          print("==>> 天地奇书")
          local missionId = roleIns:getParam()
          activity.tiandiqishu:monsterOptionTouch(missionId)
        end
      end
      self:MoveToRole_(roleIns, open_monster_view)
    end
  end
end
function CMapView:MoveToRole_(roleIns, listener)
  local npcX, npcY = roleIns:getPosition()
  local playerX, playerY = self.m_LocalRole:getPosition()
  local dx = npcX - playerX
  local dy = npcY - playerY
  local dis = math.sqrt(dx * dx + dy * dy)
  if self:CanNpcUse(roleIns) then
    self:stoptAutoRoute()
    local dir = getDirectionByDelayPos(dx, dy)
    self.m_LocalRole:setDirection(dir)
    if listener then
      listener()
    end
  else
    local dstX = npcX - NpcTouchOpenView_MinDis * dx / dis
    local dstY = npcY - NpcTouchOpenView_MinDis * dy / dis
    self:StartAutoRoute(function(isSucceed)
      if isSucceed and listener then
        listener()
      end
    end, {dstX, dstY}, MapPosType_PixelPos)
  end
end
function CMapView:CanNpcIdUse(npcId)
  local roleIns = self:getNpcIns(npcId)
  if roleIns then
    return self:CanNpcUse(roleIns)
  end
  return false
end
function CMapView:CanNpcUse(roleIns)
  local npcX, npcY = roleIns:getPosition()
  return self:isDstInTouchDis(npcX, npcY)
end
function CMapView:isDstInTouchDis(x, y, posType)
  if posType then
    x, y = self:getPosByType({x, y}, posType)
  end
  local playerX, playerY = self.m_LocalRole:getPosition()
  local dx = x - playerX
  local dy = y - playerY
  local dis = math.sqrt(dx * dx + dy * dy)
  if dis <= NpcTouchOpenView_MaxDis then
    return true
  end
  return false
end
function CMapView:CreateRoleSelectEffect()
  self.m_RoleChoosed = nil
  self.m_SelectCircle = display.newSprite("xiyou/pic/pic_circle.png")
  self:addNode(self.m_SelectCircle, self.m_ZOrder.choose)
  self.m_SelectCircle:setVisible(false)
  self:flushSelectEffect(nil)
end
function CMapView:CreateMapEffect()
  if _data_MapEffects_IdsForMap_ == nil then
    local effectIdForMap = {}
    for eId, effectData in pairs(data_MapEffects) do
      local mapId = effectData.mapId
      if effectIdForMap[mapId] == nil then
        effectIdForMap[mapId] = {eId}
      else
        effectIdForMap[mapId][#effectIdForMap[mapId] + 1] = eId
      end
    end
    _data_MapEffects_IdsForMap_ = effectIdForMap
  end
  local effectIds = _data_MapEffects_IdsForMap_[self.m_MapId] or {}
  if #effectIds > 0 then
    for idx, eIds in pairs(effectIds) do
      do
        local effectData = data_MapEffects[eIds]
        if effectData then
          do
            local effPath = "xiyou/mapeffect/" .. effectData.path
            local pngPath = effPath
            local isAni = false
            if string.sub(pngPath, -6, -1) == ".plist" then
              isAni = true
              pngPath = string.sub(pngPath, 1, -7) .. ".png"
            end
            print("准备 创建地图特效:", eIds, effPath)
            addDynamicLoadTexture(pngPath, function(handlerName, texture)
              if self.m_IsClear or self.m_IsExitsSelf == nil or self.m_ZOrder == nil then
                return
              end
              print("创建地图特效:", effPath)
              local node
              if isAni then
                node = CreateSeqAnimation(effPath, -1)
              else
                node = display.newSprite(effPath)
              end
              self:addNode(node, self.m_ZOrder.normal_effect)
              local pos = effectData.pos
              node:setPosition(pos[1] + self.m_MapBgSize.width / 2, pos[2] + self.m_MapBgSize.height / 2)
              local typ = effectData.typ
              if effectData.scalex ~= 0 then
                node:setScaleX(effectData.scalex)
              end
              if effectData.scaley ~= 0 then
                node:setScaleY(effectData.scaley)
              end
              if effectData.rotate ~= 0 then
                node:setRotation(effectData.rotate)
              end
              if effectData.flipx == 1 then
                node:setFlipX(true)
              end
              if effectData.flipy == 1 then
                node:setFlipY(true)
              end
              if effectData.flipy == 1 then
                node:setFlipY(true)
              end
              if effectData.opacity ~= nil then
                node:setOpacity(effectData.opacity)
              end
              if typ >= 0 then
                CreateMapEffectCommon(node, typ)
              end
            end, {pixelFormat = kCCTexture2DPixelFormat_RGBA4444})
          end
        end
      end
    end
  end
end
function CMapView:CreateWarBackground()
  local mapNum = data_getSceneWarMap(self.m_MapId)
  local path = string.format("xiyou/pic/pic_warbg_%d.jpg", mapNum)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.m_IsClear or self.m_IsExitsSelf == nil then
      return
    end
    self.m_TempWarBackground = display.newSprite(path)
    self:addNode(self.m_TempWarBackground)
    self.m_TempWarBackground:setVisible(false)
    self.m_TempWarBackground:setPosition(ccp(-9999, -9999))
  end, {pixelFormat = kCCTexture2DPixelFormat_RGB565})
end
function CMapView:setNpcSelectedByNpcId(npcId)
  local roleIns = self:getNpcIns(npcId)
  if roleIns then
    self:flushSelectEffect(roleIns)
  end
end
function CMapView:flushSelectEffect(roleChoosed)
  if self.m_RoleChoosed == roleChoosed then
    return
  end
  if roleChoosed == nil then
    self.m_SelectCircle:setVisible(false)
    if x and y then
      self.m_SelectCircle:setPosition(x, y)
    end
    self.m_RoleChoosed = nil
    SendMessage(MsgID_MapScene_TouchRole, nil)
  else
    self.m_SelectCircle:setVisible(true)
    self.m_RoleChoosed = roleChoosed
    self:flushSelectPos()
  end
end
function CMapView:DetectSelectEffect(roleIns)
  if self.m_RoleChoosed == roleIns then
    self:flushSelectEffect(nil)
  end
end
function CMapView:flushSelectPos()
  if self.m_RoleChoosed then
    local x, y = self.m_RoleChoosed:getPosition()
    self.m_SelectCircle:setPosition(x, y)
  end
end
function CMapView:TouchRoleDetect(x, y)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    return
  end
  local function compareRoleTouch(role1, role2)
    if role2 == self.m_LocalRole then
      return role1
    end
    if role1 == nil then
      return role2
    else
      local roleType1 = role1:getMapRoleType()
      local roleType2 = role2:getMapRoleType()
      if roleType1 == LOGICTYPE_NPC and roleType2 ~= LOGICTYPE_NPC then
        return role1
      elseif roleType1 ~= LOGICTYPE_NPC and roleType2 == LOGICTYPE_NPC then
        return role2
      end
      if self:IsBangPaiMap() and roleType1 == LOGICTYPE_HERO and roleType2 == LOGICTYPE_HERO then
        local warType1 = g_MapMgr:getPlayerInWarType(role1:getPlayerId())
        local warType2 = g_MapMgr:getPlayerInWarType(role2:getPlayerId())
        if warType1 ~= WARTYPE_BpWAR and warType2 == WARTYPE_BpWAR then
          return role1
        elseif warType1 == WARTYPE_BpWAR and warType2 ~= WARTYPE_BpWAR then
          return role2
        end
      end
      if role1:getZOrder() < role2:getZOrder() then
        return role2
      end
    end
    return role1
  end
  local role
  for k, v in pairs(self.m_NPC) do
    local r = v.roleIns
    if r and self:IsRoleTouchInSide(r, x, y, false) then
      role = compareRoleTouch(role, r)
    end
  end
  for k, v in pairs(self.m_Monster) do
    local r = v
    if r and self:IsRoleTouchInSide(r, x, y, false) then
      role = compareRoleTouch(role, r)
    end
  end
  for k, r in pairs(self.m_Player) do
    if r and r:isVisible() and r:isEnabled() and self:IsRoleTouchInSide(r, x, y, true) then
      role = compareRoleTouch(role, r)
    end
  end
  return role
end
function CMapView:IsRoleTouchInSide(role, x, y, isPlayer)
  local isBpWarStartState = self:IsBangPaiMap() and isPlayer == true and g_BpWarMgr:getBpWarState() == BPWARSTATE_START
  if isBpWarStartState then
    local bpId = role:getBpId()
    if bpId == g_BpMgr:getLocalPlayerBpId() then
      return false
    end
  end
  local touchSize = role:getTouchSize()
  local rx, ry = role:getPosition()
  local w_half = touchSize.width / 2
  if x >= rx - w_half and x <= rx + w_half and y >= ry and y <= ry + touchSize.height then
    if isBpWarStartState and g_TeamMgr:IsPlayerOfLocalPlayerTeam(role:getPlayerId()) then
      return false
    end
    return true
  end
  return false
end
function CMapView:InitTeleporters()
  self.m_TeleporterIds = data_MapNormalTeleporter[self.m_MapId] or {}
  self.m_Teleporters = {}
  self.m_CurMoveInTeleporterId = nil
  self.m_LaseMoveGrid = {-1, -1}
  local pngPath = TransporterPath .. ".png"
  for i, tId in ipairs(self.m_TeleporterIds) do
    self:addAsyncPicLoad(handler(self, self.InitTeleporters_), pngPath, {tId})
  end
end
function CMapView:InitTeleporters_(pngPath, tId)
  local tData = data_MapTeleporter[tId]
  if tData then
    local pos = tData.pos
    local gridX = pos[2]
    local gridY = self.m_MapGridNum[2] - pos[3] - 1
    local x, y = self:getMidPosByGrid(gridX, gridY)
    local eff = self:createtTeleporters_(x, y, tData.name)
    local detectSize = CCSize(100, 50)
    local lx = x - detectSize.width / 2
    local rx = x + detectSize.width / 2
    local by = y - detectSize.height / 2
    local ty = y + detectSize.height / 2
    self.m_Teleporters[tId] = {
      eff = eff,
      rect = {
        lx,
        rx,
        by,
        ty
      },
      name = tData.name
    }
  end
end
function CMapView:detectTeleportes()
  local x, y = self.m_LocalRole:getPosition()
  local gx, gy = self:getGridByPos(x, y)
  if self.m_LaseMoveGrid[1] ~= gx or self.m_LaseMoveGrid[2] ~= gy then
    self.m_LaseMoveGrid = {gx, gy}
    local teleporterId = self:detectPosInTeleporters(x, y)
    if teleporterId and self.m_CurMoveInTeleporterId ~= teleporterId then
      self:roleMovedinTeleporter(self.m_LocalRole, teleporterId)
    end
    self.m_CurMoveInTeleporterId = teleporterId
  end
end
function CMapView:detectPosInTeleporters(x, y)
  for tId, tData in pairs(self.m_Teleporters) do
    local r = tData.rect
    if x >= r[1] and x <= r[2] and y >= r[3] and y <= r[4] then
      return tId
    end
  end
  return nil
end
function CMapView:roleMovedinTeleporter(role, teleporterId)
  local tData = data_MapTeleporter[teleporterId]
  local t = tData.type
  local teamId = g_TeamMgr:getPlayerTeamId(pid)
  local pid = role:getPlayerId()
  local captainId = g_TeamMgr:getTeamCaptain(teamId)
  local isCaptain = false
  local isFollow = false
  if teamId and teamId > 0 then
    if captainId ~= pid then
      local status = g_TeamMgr:getPlayerTeamState(pid)
      if status == TEAMSTATE_FOLLOW then
        isFollow = true
      end
    else
      isCaptain = true
    end
  end
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    print("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if self:getIsGuajiFlag() then
    print("正在挂机中，传送点无效")
    return
  end
  if self:getIsXunLuoFlag() then
    print("正在自动巡逻中，传送点无效")
    return
  end
  if JudgeIsInWar() then
    print("战斗中，传送点无效")
    return
  end
  if data_getIsGuajiMap(tData.tomap) then
    do
      local mapId = tData.tomap
      if not CanGuajiInMap(mapId) then
        return
      end
      local posLen = #tData.toPos
      local pos = tData.toPos[math.random(1, posLen)]
      local minLv = data_GuaJi_Map[mapId].RecommandLv[1]
      local heroObj = g_LocalPlayer:getMainHero()
      local curLv = 0
      if heroObj ~= nil then
        curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
      end
      if minLv > curLv then
        local tempPop = CPopWarning.new({
          title = "提示",
          text = "此地图怪物等级较高,现在进入可能有危险,是否进入?",
          confirmFunc = function()
            if g_MapMgr then
              g_MapMgr:AskToEnterGuaji(mapId, pos[1], pos[2], pos[3] or 5, false)
            end
          end,
          align = CRichText_AlignType_Left,
          cancelFunc = nil,
          closeFunc = nil,
          confirmText = nil,
          cancelText = nil,
          hideInWar = true
        })
        tempPop:ShowCloseBtn(false)
      elseif g_MapMgr then
        g_MapMgr:AskToEnterGuaji(mapId, pos[1], pos[2], pos[3] or 5, false)
      end
      return
    end
  end
  if t == 1 then
    local tMap = tData.tomap
    local posLen = #tData.toPos
    local pos = tData.toPos[math.random(1, posLen)]
    print(string.format("======>> 角色跑到传送器里面:%s,%s,[%s,%s,%s]", tostring(role), tostring(teleporterId), tostring(tMap), tostring(pos[1]), tostring(pos[2])))
    if isCaptain == true or isFollow == false then
      role:StopMove()
      local initDir = pos[3] or 5
      if tMap == self.m_MapId then
        local x, y = self:getMidPosByGrid(pos[1], self.m_MapGridNum[2] - 1 - pos[2])
        role:setPosition(ccp(x, y))
        role:setDirection(initDir)
      else
        g_MapMgr:LoadMapById(tMap, pos, MapPosType_EditorGrid, {initDir = initDir})
      end
    end
  end
end
function CMapView:createtTeleporters_(x, y, name)
  local plistpath = TransporterPath .. ".plist"
  local times = -1
  local cblistener, autoDestroy
  local eff = CreateSeqAnimation(plistpath, times, cblistener, autoDestroy, false)
  self:addNode(eff, self.m_ZOrder.teleporter)
  eff:setPosition(ccp(x, y + 40))
  self:createNameForTeleporter(eff, name)
  return eff
end
function CMapView:InitTouchMapEffect()
end
function CMapView:createOneTouchMapEffect_()
  local plistpath = "xiyou/ani/eff_touchmap.plist"
  local times = 1
  local cblistener
  local autoDestroy = true
  local eff = CreateSeqAnimation(plistpath, times, cblistener, autoDestroy, false)
  self:addNode(eff, self.m_ZOrder.touchmap)
  return eff
end
function CMapView:createTouchMapEffect(pos)
  local eff = self:createOneTouchMapEffect_()
  eff:setPosition(pos)
end
function CMapView:setMapToPos(nx, ny, delayMoveActionFlag)
  nx = nx * AllMapScaleNum + display.width * (1 - AllMapScaleNum) / 2
  ny = ny * AllMapScaleNum + display.height * (1 - AllMapScaleNum) / 2
  if nx > 0 then
    nx = 0
  elseif nx < display.width - self.m_MapSize.width * AllMapScaleNum then
    nx = display.width - self.m_MapSize.width * AllMapScaleNum
  end
  if ny > 0 then
    ny = 0
  elseif ny < display.height - self.m_MapSize.height * AllMapScaleNum then
    ny = display.height - self.m_MapSize.height * AllMapScaleNum
  end
  self.m_MoveMapToPosX = nx
  self.m_MoveMapToPosY = ny
  if delayMoveActionFlag then
    if self.m_MoveMapSchedule == nil then
      self.m_MoveMapSchedule = scheduler.scheduleGlobal(function()
        local moveToX, moveToY = self:getPosition()
        local by = 0.05
        moveToX = moveToX + by * (self.m_MoveMapToPosX - moveToX)
        moveToY = moveToY + by * (self.m_MoveMapToPosY - moveToY)
        if math.abs(moveToX - self.m_MoveMapToPosX) < 1 and math.abs(moveToY - self.m_MoveMapToPosY) < 1 then
        else
          self:setPosition(ccp(moveToX, moveToY))
        end
      end, 0.01)
    end
  else
    self:setPosition(ccp(nx, ny))
  end
  return nx, ny
end
function CMapView:FindRoute(startX, startY, dstX, dstY)
  if self.m_IsClear or self.m_IsExitsSelf == nil then
    return
  end
  local startGridX, startGridY = self:getGridByPos(startX, startY)
  local endGridX, endGridY = self:getGridByPos(dstX, dstY)
  local startNode = self.m_NodeGrid:getNode(startGridX, startGridY)
  local endNode = self.m_NodeGrid:getNode(endGridX, endGridY)
  if endNode == nil or startNode == nil then
    print("===>> 目的点找不到")
    return nil
  end
  if endNode.walkable == false then
    local replacer = self.m_NodeGrid:findReplacer(startNode, endNode)
    print([[

===>findReplacer:]])
    if replacer then
      endGridX = replacer.x
      endGridY = replacer.y
    else
      return
    end
  end
  self.m_NodeGrid:setStartNode(startGridX, startGridY)
  self.m_NodeGrid:setEndNode(endGridX, endGridY)
  local astar = AStar:create()
  local isCanGotoDst = astar:findPath(self.m_NodeGrid)
  print("===>> 是否可以到达终点:", isCanGotoDst)
  local startTime = cc.net.SocketTCP.getTime()
  astar:floyd()
  local path = astar:getFloydPath()
  if self.m_IsShowTestLayer then
    self.m_Trace:removeAllChildren()
  end
  local route = {}
  for i = 1, path:count() - 1 do
    local node = tolua.cast(path:objectAtIndex(i), "ANode")
    local dgx, dgy = node.x, node.y
    if endNode.walkable == true and dgx == endGridX and dgy == endGridY then
      route[#route + 1] = {
        math.round(dstX),
        math.round(dstY)
      }
    else
      local x, y = self:getPosByGrid(node.x, node.y)
      route[#route + 1] = {
        math.round(x + self.m_MapGridSize[1] / 2),
        math.round(y + self.m_MapGridSize[2] / 2)
      }
    end
    if self.m_IsShowTestLayer then
      local layer = CCLayerColor:create(ccc4(150, 150, 150, 150))
      layer:setContentSize(CCSize(self.m_MapGridSize[1], self.m_MapGridSize[2]))
      local x, y = self:getPosByGrid(node.x, node.y)
      layer:setPosition(ccp(x, y))
      self.m_Trace:addChild(layer)
    end
  end
  print(string.format("CMapView:FindRoute 寻路耗时：%.09f s", cc.net.SocketTCP.getTime() - startTime))
  return route
end
function CMapView:StartAutoRoute(cbListener, gridPos, posType, roleState, rdxy)
  print("CMapView:StartAutoRoute", gridPos, posType, roleState, rdxy)
  local dx, dy = self:getPosByType(gridPos, posType)
  if rdxy then
    dx = dx + math.random(-self.m_MapGridSize[1] / 2 + 2, self.m_MapGridSize[1] / 2 - 2)
    dy = dy + math.random(-self.m_MapGridSize[2] / 2 + 2, self.m_MapGridSize[2] / 2 - 2)
  end
  local x, y = self.m_LocalRole:getPosition()
  local route = self:FindRoute(x, y, dx, dy)
  self:endAutoXunluo(false)
  if route ~= nil then
    self.m_AutoRouteListener = cbListener
    if roleState == 2 then
      self.m_LocalRole:setIsAutoXunluoStatus(true)
    else
      self.m_LocalRole:setIsAutoRouteStatus(true)
    end
    self.m_IsAutoRouting = true
    self.m_LocalRole:MoveLocalRoleToPosRoute(route)
  elseif cbListener then
    cbListener(false)
  end
end
function CMapView:stoptAutoRoute()
  if self.m_LocalRole then
    self.m_LocalRole:StopMove()
  end
  self:setAutoRouteFinished(false)
end
function CMapView:setAutoRouteFinished(isSucceed)
  self.m_AutoRouteFbInfo = nil
  self.m_IsAutoRouting = false
  self.m_LocalRole:setIsAutoRouteStatus(false)
  if self.m_AutoRouteListener then
    local func = self.m_AutoRouteListener
    self.m_AutoRouteListener = nil
    func(isSucceed)
  end
end
function CMapView:startAutoXunluo_new(listener)
  self:endAutoXunluo(false)
  self.m_AutoXunluoNewFlag = true
  self.m_AutoXunluoListener = listener
  self.m_AutoXunluoNewTimes = math.random(2, 4)
  self:OneAutoXunluoStep_new()
end
function CMapView:OneAutoXunluoStep_new()
  if self.m_AutoXunluoNewTimes == 0 then
    if self.m_AutoXunluoListener ~= nil then
      self:endAutoXunluo(false)
      self.m_AutoXunluoListener()
      if self.m_LocalRole then
        self.m_LocalRole:StopMove()
      end
    end
    return
  end
  self.m_AutoXunluoNewTimes = self.m_AutoXunluoNewTimes - 1
  local x, y = self.m_LocalRole:getPosition()
  local gX, gY = self:getGridByPos(x, y)
  local posDict = {}
  local range = 5
  for i = math.max(0, gX - range), math.min(gX + range, self.m_MapGridNum[1] - 1) do
    for j = math.max(0, gY - range), math.min(gY + range, self.m_MapGridNum[2] - 1) do
      if self:GridCanGo({i, j}) then
        posDict[#posDict + 1] = {i, j}
      end
    end
  end
  local gridPos = posDict[math.random(1, #posDict)]
  self:StartAutoRoute(function(flag)
    if flag == true then
      self:OneAutoXunluoStep_new()
    end
  end, gridPos, MapPosType_Grid, 2)
end
function CMapView:startAutoXunluo(listener, t)
  self:endAutoXunluo(false)
  self.m_AutoXunluoListener = listener
  self.m_AutoXunluoTimes = t or 4
  self.m_LocalRole:setIsAutoXunluoStatus(true)
  local x, y = self.m_LocalRole:getPosition()
  self.m_AutoXunluoOldPos = {
    {x, y}
  }
  local gx, gy = self:getGridByPos(x, y)
  local dstGrid4, dstGrid3
  local dir = math.random(1, 8)
  for i = 1, 8 do
    dir = dir % 8 + 1
    local d = DIRECTIOIN_VECTOR[dir]
    if d then
      local dx, dy = d[1], d[2]
      local _gx, _gy = gx, gy
      local idx = 0
      while idx <= 4 do
        idx = idx + 1
        _gx = _gx + dx
        _gy = _gy + dy
        if self.m_Route[string.format("%d..%d", _gx, _gy)] == 1 then
          break
        else
          local _x, _y = self:getPosByGrid(_gx, _gy)
          if self:detectPosInTeleporters(_x, _y) == nil then
            if idx >= 4 then
              dstGrid4 = {_gx, _gy}
              break
            elseif idx == 3 then
              dstGrid3 = {_gx, _gy}
            end
          else
            print("------>>> 格子跑到传送门了")
            break
          end
        end
      end
    end
    if dstGrid4 ~= nil then
      break
    end
  end
  if dstGrid4 == nil then
    dstGrid4 = dstGrid3
  end
  if dstGrid4 == nil then
    self:endAutoXunluo(false)
    return
  end
  local dx, dy = self:getPosByType(dstGrid4, MapPosType_Grid)
  self.m_AutoXunluoOldPos[#self.m_AutoXunluoOldPos + 1] = {dx, dy}
  self.m_AutoXunluoCurIdx = 1
  self:newAutoXunluo()
end
function CMapView:newAutoXunluo()
  print("newAutoXunluo:", self.m_AutoXunluoCurIdx)
  self.m_AutoXunluoCurIdx = self.m_AutoXunluoCurIdx % 2 + 1
  local d = self.m_AutoXunluoOldPos[self.m_AutoXunluoCurIdx]
  local x, y = self.m_LocalRole:getPosition()
  local route = self:FindRoute(x, y, d[1], d[2])
  if route ~= nil then
    self.m_AutoRouteListener = nil
    self.m_LocalRole:MoveLocalRoleToPosRoute(route)
  else
    self:endAutoXunluo(false)
  end
end
function CMapView:routeFinishedForXunluo()
  if self.m_AutoXunluoTimes ~= nil then
    self:newAutoXunluo()
  end
end
function CMapView:UpdateAutoXunluo(dt)
  self.m_AutoXunluoTimes = self.m_AutoXunluoTimes - dt
  if self.m_AutoXunluoTimes <= 0 then
    self:endAutoXunluo(true)
  end
end
function CMapView:endAutoXunluo(isSucceed)
  if self.m_AutoXunluoTimes ~= nil then
    print("endAutoXunluo:", isSucceed)
    self.m_AutoXunluoTimes = nil
    self.m_LocalRole:StopMoveForRoute()
    local cb = self.m_AutoXunluoListener
    self.m_AutoXunluoListener = nil
    if self.m_LocalRole then
      self.m_LocalRole:StopMove()
    end
    if cb then
      cb(isSucceed)
    end
  end
  self.m_AutoXunluoNewFlag = false
end
function CMapView:startGuaji()
  print("CMapView:startGuaji")
  if g_LocalPlayer == nil then
    return
  end
  local str = g_LocalPlayer:getPlayerCanJumpToNpc()
  if str ~= true then
    print(str)
    return
  end
  if data_getIsGuajiMap(self.m_MapId) == false then
    print("不是挂机地图，不能挂机")
    return
  end
  self:endGuaji()
  self.m_IsGuajiIngFlag = true
  local x, y = self.m_LocalRole:getPosition()
  local gX, gY = self:getGridByPos(x, y)
  local posDict = {}
  local range = 10
  for i = math.max(0, gX - range), math.min(gX + range, self.m_MapGridNum[1] - 1) do
    for j = math.max(0, gY - range), math.min(gY + range, self.m_MapGridNum[2] - 1) do
      if self:GridCanGo({i, j}) then
        posDict[#posDict + 1] = {i, j}
      end
    end
  end
  local gridPos = posDict[math.random(1, #posDict)]
  self:StartAutoRoute(function(flag)
    if flag == true then
      self:startGuaji()
    end
  end, gridPos, MapPosType_Grid, 2)
end
function CMapView:GridCanGo(gridPos)
  local k = string.format("%d..%d", gridPos[1], gridPos[2])
  if self.m_Route[k] == 1 then
    return false
  else
    return true
  end
end
function CMapView:PosCanGo(x, y)
  local gx, gy = self:getGridByPos(x, y)
  return self:GridCanGo({gx, gy})
end
function CMapView:endGuaji()
  print("CMapView:endGuaji")
  self:endAutoXunluo(false)
  if self.m_LocalRole then
    self.m_LocalRole:StopMove()
  end
  self:setAutoRouteFinished(false)
  self.m_IsGuajiIngFlag = false
end
function CMapView:getIsGuajiFlag()
  return self.m_IsGuajiIngFlag
end
function CMapView:getIsXunLuoFlag()
  return self.m_AutoXunluoNewFlag
end
function CMapView:flushNpcMissionStatus(statusData)
  printLog("MapView", "flushNpcMissionStatus")
  if statusData == nil then
    statusData = g_MissionMgr:getMissionStatusForNpc()
  end
  for npcId, v in pairs(self.m_HadSetNpcMissionStatus) do
    local npcIns = self:getNpcIns(npcId)
    if npcIns then
      npcIns:clearMissionStatus()
    end
  end
  self.m_HadSetNpcMissionStatus = {}
  if statusData then
    for npcId, status in pairs(statusData) do
      self.m_HadSetNpcMissionStatus[npcId] = true
      local npcIns = self:getNpcIns(npcId)
      if npcIns then
        for s, v in pairs(status) do
          npcIns:setMissionStatus(s, true)
        end
      end
    end
  end
end
function CMapView:flushNpcMissionStatusManual(npcId)
  local statusData = g_MissionMgr:getMissionStatusForNpc()
  if statusData == nil then
    return
  end
  local status = statusData[npcId]
  if status == nil then
    return
  end
  local npcIns = self:getNpcIns(npcId)
  if npcIns == nil then
    return
  end
  for s, v in pairs(status) do
    npcIns:setMissionStatus(s, true)
  end
end
function CMapView:DeleteRoleFromMap(roleIns)
  roleIns:clearMissionStatus()
  local x, y = roleIns:getPosition()
  local eff = self:createTempNpcDelEffect_(self.m_ZOrder.role + self.m_MapSize.height - y)
  eff:setPosition(cc.p(x, y + 40))
  local shapeAni = roleIns:getShapeAni()
  if shapeAni == nil then
    shapeAni = roleIns
  end
  shapeAni:runAction(transition.sequence({
    CCFadeOut:create(1.5),
    CCCallFunc:create(function()
      if self.m_IsClear == false then
        roleIns:RemoveAll()
      end
    end)
  }))
end
function CMapView:TouchToMoveMap(t, x, y)
  if t == TOUCH_EVENT_BEGAN then
    self.m_LastTouchPos[1] = x
    self.m_LastTouchPos[2] = y
  else
    local dx = x - self.m_LastTouchPos[1]
    local dy = y - self.m_LastTouchPos[2]
    if self.m_IsDragedMap == false then
      if math.abs(dx) + math.abs(dy) > 10 then
        self.m_LastTouchPos[1] = x
        self.m_LastTouchPos[2] = y
        self.m_IsDragedMap = true
        print("=>> StartDrag")
      end
    else
      local ox, oy = self:getPosition()
      local nx = ox + dx
      local ny = oy + dy
      self:setMapToPos(nx, ny)
      self.m_LastTouchPos[1] = x
      self.m_LastTouchPos[2] = y
    end
  end
end
function CMapView:createRoute(gridX, gridY)
  self:_createColorLayer(gridX, gridY, self.m_ZOrder.route, ccc4(255, 0, 0, 100))
end
function CMapView:createOpaque(gridX, gridY)
  self:_createColorLayer(gridX, gridY, self.m_ZOrder.route, ccc4(0, 255, 0, 100))
end
function CMapView:_createColorLayer(gridX, gridY, z, color)
  if self.m_IsShowTestLayer == false then
    return
  end
  local layer = CCLayerColor:create(color)
  self:addNode(layer, z)
  layer:setContentSize(CCSize(self.m_MapGridSize[1], self.m_MapGridSize[2]))
  local x, y = self:getPosByGrid(gridX, gridY)
  layer:setPosition(ccp(x, y))
  return layer
end
function CMapView:CleanSelf()
  self.m_IsClear = true
  self:_rmAllBg()
  for i, v in ipairs(self.m_MapData.bg) do
    local pngPath = MapAssertPath .. v[1]
    local texture = sharedTextureCache:textureForKey(pngPath)
    if texture then
      sharedTextureCache:removeTextureForKey(pngPath)
    end
  end
end
function CMapView:Clear()
  if g_DetectViewRelease then
    ViewRelease_ReleaseView(self)
  end
  self:setTouchEnabled(false)
  self.m_IsExitsSelf = nil
  self.m_IsClear = true
  self:RemoveAllMessageListener()
  if self.m_NodeGrid then
    self.m_NodeGrid:release()
    self.m_NodeGrid = nil
  end
  self.m_AsyncLoadPicList = {}
  self.m_Player = {}
  self.m_NPC = {}
  self.m_Teleporters = nil
  g_MapMgr:MapCleared(self)
  self.m_AutoRouteListener = nil
  self.m_BgPic = nil
  self.m_LoadedBgGrid = nil
  self:endAutoXunluo(false)
  self:endGuaji()
  if self.m_SyncPrintScheduler then
    scheduler.unscheduleGlobal(self.m_SyncPrintScheduler)
    self.m_SyncPrintScheduler = nil
  end
end
function CMapView:LoadBg(bgTable)
  self.m_IsDynamicLoadBg = false
  bgTable = self:InitDynamicLoadBg(bgTable)
  for i, v in ipairs(bgTable) do
    local pngPath = v[1]
    local x, y = self:getPosByGrid(v[2], v[3])
    self:addAsyncPicLoad(handler(self, self.LoadBgAsync_), MapAssertPath .. pngPath, {
      x,
      y,
      v[4],
      v[5]
    }, true, {pixelFormat = PixelFormat_MapBg}, DynamicLoadTexturePriority_MapBg, true)
  end
end
function CMapView:LoadBgAsync_(pngPath, x, y, bgGridX, bgGridY)
  print("======>>> LoadBgAsync_ pngPath, x, y:", pngPath, x, y, bgGridX, bgGridY)
  local bgSprite = CCSprite:create(pngPath)
  bgSprite:setAnchorPoint(ccp(0, 0))
  bgSprite:setPosition(ccp(x, y))
  self:_addBg(pngPath, bgSprite, self.m_ZOrder.bg)
  if self.m_IsDynamicLoadBg then
    local bgData = self:getBgDataByGrid(bgGridX, bgGridY)
    if bgData == nil then
      printLog("ERROR", "找不到对应坐标[%s, %s]的背景数据", tostring(bgGridX), tostring(bgGridY))
    else
      if bgData.sprite ~= nil then
        printLog("ERROR", "bgData.sprite 不为空")
      end
      bgData.sprite = bgSprite
      bgData.flag = self.m_CurDynamicFlag
      self.m_LoadedBgGrid[string.format("%d_%d", bgGridX, bgGridY)] = {bgGridX, bgGridY}
    end
  else
  end
end
function CMapView:_addBg(pngPath, bgSprite, z)
  self.m_BgSprites[pngPath] = bgSprite
  self:addNode(bgSprite, z)
end
function CMapView:_rmBg(pngPath)
  local bgSprite = self.m_BgSprites[pngPath]
  if bgSprite then
    self:removeNode(bgSprite)
    self.m_BgSprites[pngPath] = nil
  end
end
function CMapView:_rmAllBg()
  for k, v in pairs(self.m_BgSprites) do
    self:removeNode(v)
  end
  self.m_BgSprites = {}
end
function CMapView:InitDynamicLoadBg(bgTable)
  if #bgTable <= 12 then
    return bgTable
  end
  self.m_BgPerPicSize = {512, 512}
  self.m_BgSpace_Y = self.m_MapSize.height % self.m_BgPerPicSize[2]
  self.m_IsDynamicLoadBg = true
  self.m_CurDynamicFlag = 0
  self.m_CurAsyncLoadPath = {}
  self.m_BgPic = {}
  self.m_LoadedBgGrid = {}
  for i, v in ipairs(bgTable) do
    local picPath, gridX, gridY = unpack(v)
    local x, y = self:getPosByGrid(gridX, gridY)
    local gx, gy = self:getBgGridByPos(x, y)
    local xt = self.m_BgPic[gx]
    if xt == nil then
      xt = {}
      self.m_BgPic[gx] = xt
    end
    xt[gy] = {
      path = picPath,
      gx = gridX,
      gy = gridY,
      sprite = nil,
      flag = nil
    }
  end
  local x, y = self:_getInitPos()
  self.m_LastUpdatePos = {x, y}
  local lgx, rgx, bgy, tgy = self:getDynamicRange(x, y, true)
  local initCratePic = {}
  for cgx = lgx, rgx do
    for cgy = bgy, tgy do
      local d = self:getBgDataByGrid(cgx, cgy)
      if d then
        initCratePic[#initCratePic + 1] = {
          d.path,
          d.gx,
          d.gy,
          cgx,
          cgy
        }
      end
    end
  end
  return initCratePic
end
function CMapView:getDynamicRange(x, y, isInit)
  if x < self.m_DynamicBoundPos[1] then
    x = self.m_DynamicBoundPos[1]
  elseif x > self.m_DynamicBoundPos[2] then
    x = self.m_DynamicBoundPos[2]
  end
  if y < self.m_DynamicBoundPos[3] then
    y = self.m_DynamicBoundPos[3]
  elseif y > self.m_DynamicBoundPos[4] then
    y = self.m_DynamicBoundPos[4]
  end
  local lx, rx, by, ty
  if isInit == true then
    lx = x - 100
    rx = x + 100
    by = y - 100
    ty = y + 100
  else
    lx = x - 310
    rx = x + 310
    by = y - 310
    ty = y + 310
  end
  local lgx, bgy = self:getBgGridByPos(lx - display.width_half, by - display.height_half)
  local rgx, tgy = self:getBgGridByPos(rx + display.width_half, ty + display.height_half)
  return lgx, rgx, bgy, tgy, lx, rx, by, ty
end
function CMapView:DynamicLoadBgUpdate(x, y)
  if math.abs(x - self.m_LastUpdatePos[1]) + math.abs(y - self.m_LastUpdatePos[2]) < 100 then
    return
  end
  self.m_LastUpdatePos = {x, y}
  local lgx, rgx, bgy, tgy, lx, rx, by, ty = self:getDynamicRange(x, y)
  self.m_CurDynamicFlag = 1 - self.m_CurDynamicFlag
  for cgx = lgx, rgx do
    for cgy = bgy, tgy do
      do
        local d = self:getBgDataByGrid(cgx, cgy)
        if d then
          d.flag = self.m_CurDynamicFlag
          if d.sprite == nil then
            do
              local x, y = self:getPosByGrid(d.gx, d.gy)
              local pngPath = MapAssertPath .. d.path
              if self.m_CurAsyncLoadPath[pngPath] == nil then
                self.m_CurAsyncLoadPath[pngPath] = 1
                addDynamicLoadTexture(pngPath, function(handlerName, texture)
                  if self.m_IsClear or self.m_IsExitsSelf == nil then
                    return
                  end
                  if self.LoadBgAsync_ then
                    self:LoadBgAsync_(pngPath, x, y, cgx, cgy)
                  end
                  if self.m_CurAsyncLoadPath ~= nil then
                    self.m_CurAsyncLoadPath[pngPath] = nil
                  end
                end, {pixelFormat = PixelFormat_MapBg}, DynamicLoadTexturePriority_MapBg, true)
              end
            end
          end
        end
      end
    end
  end
  if self.m_LoadedBgGrid ~= nil then
    for k, gd in pairs(self.m_LoadedBgGrid) do
      local gx, gy = gd[1], gd[2]
      local d = self:getBgDataByGrid(gx, gy)
      if d and d.flag and d.sprite ~= nil and d.flag ~= self.m_CurDynamicFlag then
        local pngPath = MapAssertPath .. d.path
        self:_rmBg(pngPath)
        d.sprite = nil
        self.m_LoadedBgGrid[k] = nil
      end
    end
  end
end
function CMapView:PrintLoadedBgPngs()
  print("-------------------------------------------")
  if self.m_LoadedBgGrid then
    for k, gd in pairs(self.m_LoadedBgGrid) do
      local gx, gy = gd[1], gd[2]
      local d = self:getBgDataByGrid(gx, gy)
      print(d.path)
    end
  end
  print("--------------------END---------------------")
end
function CMapView:InitSyncPlayerLimit()
  self.m_CurSyncPlayerType = getSyncPlayerTypeFromConfig() or SyncPlayerType_Min
  self.m_CurSyncPlayerNum = 0
  self.m_CurSyncPlayers = {}
  self.m_SyncPrintScheduler = nil
  if false then
    self.m_SyncPrintScheduler = scheduler.scheduleGlobal(function()
      if self.m_IsClear or self.m_IsExitsSelf == nil then
        return
      end
      print("--------------------------------------------")
      print("当前同屏类型:", self.m_CurSyncPlayerType, tostring(self))
      print("当前同屏人数:", self.m_CurSyncPlayerNum)
      print("--------------------END---------------------")
    end, 3)
  end
end
function CMapView:IsNeedDealPlayerSync(pid, isHide, role)
  if pid == g_LocalPlayer:getPlayerId() then
    return true
  end
  if self.m_CurSyncPlayerType ~= SyncPlayerType_Middle then
    return true
  end
  if isHide then
    if self.m_CurSyncPlayers[pid] ~= nil then
      self.m_CurSyncPlayers[pid] = nil
      self.m_CurSyncPlayerNum = self.m_CurSyncPlayerNum - 1
    end
    return true
  end
  if self.m_CurSyncPlayers[pid] ~= nil then
    return true
  end
  local isNeedShow = true
  if self.m_CurSyncPlayerNum > SyncPlayerNumWithMiddleType then
    local myTeamId = g_TeamMgr:getPlayerTeamId()
    if myTeamId ~= 0 then
      local playerTeamId = g_TeamMgr:getPlayerTeamId(pid)
      if myTeamId ~= playerTeamId then
        print("--> 非同队玩家，不显示")
        isNeedShow = false
      end
    else
      print("--> 本地玩家没有队伍，不显示多余的玩家")
      isNeedShow = false
    end
  end
  if isNeedShow == false then
    self:delRole(pid)
    return false
  end
  self.m_CurSyncPlayers[pid] = 1
  self.m_CurSyncPlayerNum = self.m_CurSyncPlayerNum + 1
  return true
end
function CMapView:SyncPlayerTypeChanged(st)
  if self.m_CurSyncPlayerType ~= st then
    self.m_CurSyncPlayerType = st
    self.m_CurSyncPlayerNum = 0
    self.m_CurSyncPlayers = {}
  end
end
function CMapView:getBgGridByPos(x, y)
  local gx = math.floor(x / self.m_BgPerPicSize[1])
  if y < self.m_BgSpace_Y then
    return gx, 0
  end
  return gx, 1 + math.floor((y - self.m_BgSpace_Y) / self.m_BgPerPicSize[2])
end
function CMapView:getBgDataByPos(x, y)
  local gx, gy = self:getBgGridByPos(x, y)
  return self:getBgDataByGrid(gx, gy)
end
function CMapView:getBgDataByGrid(gx, gy)
  if self.m_BgPic == nil then
    return nil
  end
  local xt = self.m_BgPic[gx]
  if xt then
    return xt[gy]
  end
  return nil
end
