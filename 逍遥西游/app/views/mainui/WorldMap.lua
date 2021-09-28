CWorldMap = class("CWorldMap", CcsSubView)
function CWorldMap:ctor()
  CWorldMap.super.ctor(self, "views/world_map.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_exchange = {
      listener = handler(self, self.OnBtn_Exchange),
      variName = "btn_exchange"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local heroObj = g_LocalPlayer:getMainHero()
  local curZs = 0
  local curLv = 0
  if heroObj ~= nil then
    curZs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  local btnDict = {}
  for k, tInfo in pairs(data_WorldMapTeleporter) do
    do
      local btnName = string.format("btn_t_%d", k)
      local btn = self:addBtnListener(btnName, function()
        self:TouchTeleporter(k)
      end)
      btnDict[k] = btn
      if tInfo.tomap == -1 or #tInfo.toPos < 1 then
        local mapList = TELEPOINT_2_MAP_DICT[k] or {}
        local tmp = mapList[1]
        if tmp then
          local data = data_GuaJi_Map[tmp]
          if data and data_judgeFuncOpen(curZs, curLv, data.UnlockZs, data.UnlockLv, data.AlwaysJudgeLvFlag) == false then
            local gPath = string.format("views/worldmap/btn_wm_t_%d_gray.png", k)
            local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(gPath)
            if os.exists(fullPath) then
              btn:loadTextureNormal(gPath)
              btn._lock = true
            end
          end
        end
      end
    end
  end
  self.m_BtnDict = btnDict
  local curMapBtn, curPos
  local worldMapId = g_MapMgr:getPlayerMapZone()
  if worldMapId ~= nil then
    curMapBtn = btnDict[worldMapId]
    curPos = self:getNode(string.format("pos_%d", worldMapId))
  end
  if curMapBtn == nil then
    local curMapId = g_MapMgr:getCurMapId()
    local mapData = data_MapInfo[curMapId]
    if mapData ~= nil and mapData.headPos ~= nil then
      curMapBtn = btnDict[mapData.headPos]
      curMapBtn.__oscale = curMapBtn:getScale()
    end
  end
  self.m_HeadIcon = nil
  print("====>curMapBtn:", curMapBtn)
  if curMapBtn then
    local heroIns = g_LocalPlayer:getMainHero()
    print("==>heroIns:", heroIns)
    if heroIns then
      local typeId = heroIns:getTypeId()
      local bg = display.newSprite("views/pic/pic_worldmap_headbg.png")
      local img = createHeadIconByShape(typeId)
      local bgSize = bg:getContentSize()
      bg:addChild(img)
      img:setAnchorPoint(ccp(0.5, 0))
      img:setPosition(ccp(bgSize.width / 2, 31))
      self.m_HeadIcon = bg
      if self.m_HeadIcon then
        local s = 0.4
        self.m_HeadIcon:setScale(s)
        curMapBtn:getParent():addNode(self.m_HeadIcon)
        if curPos then
          local x, y = curPos:getPosition()
          local bSize = curPos:getSize()
          self.m_HeadIcon:setPosition(ccp(x + bSize.width / 2, y))
        else
          local x, y = curMapBtn:getPosition()
          local bSize = curMapBtn:getSize()
          self.m_HeadIcon:setPosition(ccp(x - 20, y + 20))
        end
      end
    end
    local dt = 0.5
    local oscale = 1
    if curMapBtn.__oscale ~= nil then
      oscale = curMapBtn.__oscale
    end
    local act1 = CCScaleTo:create(dt, 1.1 * oscale)
    local act2 = CCScaleTo:create(dt, 1 * oscale)
    curMapBtn:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
  end
  self:ListenMessage(MsgID_MapScene)
end
function CWorldMap:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MapScene_ChangedMap then
    if g_MapMgr:IsInBangPaiWarMap() then
      self:CloseSelf()
    end
    if g_MapMgr:IsInYiZhanDaoDiMap() then
      self:CloseSelf()
    end
  end
end
function CWorldMap:TouchTeleporter(teleporterId)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  local btn = self.m_BtnDict[teleporterId]
  local isLocked = false
  if btn then
    isLocked = btn._lock
  end
  local tInfo = data_WorldMapTeleporter[teleporterId]
  if tInfo then
    if tInfo.tomap == -1 or #tInfo.toPos < 1 then
      if isLocked ~= true then
        self:CloseSelf()
      end
      ShowSelectGuajiMap(teleporterId)
      return
    else
      if isLocked ~= true then
        self:CloseSelf()
      end
      scheduler.performWithDelayGlobal(function()
        local len = #tInfo.toPos
        local pos = tInfo.toPos[math.random(1, len)]
        g_MapMgr:AutoRoute(tInfo.tomap, {
          pos[1],
          pos[2],
          pos[3]
        }, nil, nil, nil, nil, nil, nil, 1)
      end, 0.01)
    end
  end
end
function CWorldMap:ChooseItem(item, index, listObj)
  local mapInfo = item:getMapInfo()
  g_MapMgr:AutoRoute(mapInfo[1], {
    mapInfo[2],
    mapInfo[3]
  }, nil, nil, nil, nil, nil, nil, 1)
  scheduler.performWithDelayGlobal(function()
    self:CloseSelf()
  end, 0.1)
end
function CWorldMap:OnBtn_Exchange()
  if g_CMainMenuHandler and g_CMainMenuHandler:OnBtn_Menu_ShowMiniMap() then
    self:CloseSelf()
  else
    ShowNotifyTips("当前场景无法使用小地图")
  end
end
function CWorldMap:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CWorldMap:Clear()
  self.m_HeadIcon = nil
end
