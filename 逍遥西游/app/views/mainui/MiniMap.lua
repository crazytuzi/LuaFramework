CMiniMap = class("CMiniMap", CcsSubView)
function CMiniMap:ctor(mapId, data)
  CMiniMap.super.ctor(self, "views/minimap.json", {isAutoCenter = true, opacityBg = 100})
  self.m_MoveSpeed = DefineRoleMoveSpeedInMap
  self:setMoveSpeed()
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
  self.m_MapId = mapId
  self.m_RoutePoint = {}
  self.m_Bg = self:getNode("bg")
  local parent = self.m_Bg:getParent()
  local miniMapfile = string.format("xiyou/mapbg/minicity/mini_%s.jpg", data.minifile)
  self.m_MiniMap = display.newSprite(miniMapfile)
  self.m_MiniMap:setAnchorPoint(ccp(0, 0))
  parent:addNode(self.m_MiniMap, 1)
  local offx = 8
  local offy = 8
  local miniMapSize = self.m_MiniMap:getContentSize()
  local bgSizeWith = miniMapSize.width + offx * 2
  local bgSizeHeight = miniMapSize.height + offy * 2
  self.m_Bg:setSize(CCSize(bgSizeWith, bgSizeHeight))
  self.item_leftup = display.newSprite("views/pic/pic_coner2.png")
  self.item_leftup:setScaleX(-1)
  self.m_MiniMap:addChild(self.item_leftup, 1)
  self.item_rightup = display.newSprite("views/pic/pic_coner2.png")
  self.m_MiniMap:addChild(self.item_rightup, 1)
  self.item_leftdown = display.newSprite("views/pic/pic_coner2.png")
  self.item_leftdown:setScaleX(-1)
  self.item_leftdown:setScaleY(-1)
  self.m_MiniMap:addChild(self.item_leftdown, 1)
  self.item_rightdown = display.newSprite("views/pic/pic_coner2.png")
  self.item_rightdown:setScaleY(-1)
  self.m_MiniMap:addChild(self.item_rightdown, 1)
  local dx, dy = 38, 5
  local mSize = self.m_MiniMap:getContentSize()
  self.item_leftup:setPosition(ccp(dx, mSize.height - dy))
  self.item_rightup:setPosition(ccp(mSize.width - dx, mSize.height - dy))
  self.item_leftdown:setPosition(ccp(dx, dy))
  self.item_rightdown:setPosition(ccp(mSize.width - dx, dy))
  local x, y = self.m_Bg:getPosition()
  local bgSize = self.m_Bg:getSize()
  self.btn_close:setPosition(ccp(x + bgSizeWith / 2 - 30, y + bgSizeHeight / 2 - 23))
  self.m_MiniMap:setPosition(ccp(x - miniMapSize.width / 2, y - miniMapSize.height / 2))
  self.btn_exchange:setPosition(ccp(x - bgSizeWith / 2 + 15, y + bgSizeHeight / 2 - 15))
  local hero = g_LocalPlayer:getMainHero()
  local heroTypeId = hero:getTypeId()
  self.m_MiniHead = display.newSprite("views/pic/pic_worldmap_headbg.png")
  self.m_MiniMap:addChild(self.m_MiniHead, 10)
  self.m_MiniHead:setAnchorPoint(ccp(0.5, 0.08))
  local head = createHeadIconByRoleTypeID(heroTypeId)
  self.m_MiniHead:addChild(head, 10)
  local headBgSize = self.m_MiniHead:getContentSize()
  head:setPosition(headBgSize.width / 2, 40)
  head:setAnchorPoint(ccp(0.5, 0.08))
  self.m_MiniHead:setScale(0.4)
  local mapViewIns = g_MapMgr:getMapViewIns()
  local realMapSize = mapViewIns.m_MapSize
  self.m_ViewScaleX = miniMapSize.width / realMapSize.width
  self.m_ViewScaleY = miniMapSize.height / realMapSize.height
  self.m_Bg:setTouchEnabled(true)
  self.m_Bg:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      self.m_HasMoved = false
    elseif t == TOUCH_EVENT_MOVED then
      if self and self.m_UINode ~= nil and not self.m_HasMoved then
        local sPos = self.m_Bg:getTouchStartPos()
        local mPos = self.m_Bg:getTouchMovePos()
        if math.abs(mPos.x - sPos.x) + math.abs(mPos.y - sPos.y) > 10 then
          self.m_HasMoved = true
        end
      end
    elseif t == TOUCH_EVENT_ENDED then
      if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
        ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
        return
      end
      if self and self.m_UINode ~= nil and not self.m_HasMoved then
        local endPos = self.m_Bg:getTouchEndPos()
        local pos = self.m_MiniMap:convertToNodeSpace(ccp(endPos.x, endPos.y))
        if pos.x > 0 and pos.x < miniMapSize.width and pos.y > 0 and pos.y < miniMapSize.height then
          self:OnClickMap(pos.x, pos.y)
        end
      end
    end
  end)
  self.m_Scheduler = scheduler.scheduleUpdateGlobal(handler(self, self.update))
  self:InitCurrRoute()
  self:update()
end
function CMiniMap:setMoveSpeed()
  self.m_MoveSpeed = DefineRoleMoveSpeedInMap * g_LocalPlayer:getAddSpeedNum()
end
function CMiniMap:InitCurrRoute()
  if g_LocalPlayer:getNormalTeamer() == true then
    return
  end
  local mapViewIns = g_MapMgr:getMapViewIns()
  if mapViewIns then
    local localRole = mapViewIns:getLocalRole()
    if localRole then
      local route = localRole:getRouteInfo()
      if route ~= nil and #route > 0 then
        local temp = route[#route]
        local ox, oy = mapViewIns:getLocalRolePos()
        self:SetRoute(ox, oy, route, ccp(temp[1] * self.m_ViewScaleX, temp[2] * self.m_ViewScaleY))
      end
    end
  end
end
function CMiniMap:OnClickMap(x, y)
  if g_WarScene ~= nil or g_FubenHandler ~= nil then
    return
  end
  if g_MapMgr:getIsMapLoading() then
    print("------>>>>正在切地图，不能寻路")
    return
  end
  local mapViewIns = g_MapMgr:getMapViewIns()
  if mapViewIns then
    local wx = x / self.m_ViewScaleX
    local wy = y / self.m_ViewScaleY
    local wpos = mapViewIns:convertToWorldSpace(ccp(wx, wy))
    local route = mapViewIns:touchedMap(wpos.x, wpos.y, false)
    local ox, oy = mapViewIns:getLocalRolePos()
    self:SetRoute(ox, oy, route, ccp(x, y))
  else
    self:OnBtn_Close()
  end
end
function CMiniMap:SetRoute(ox, oy, route, targetPos)
  self:stopAllActions()
  if self.m_TargetPoint == nil then
    self.m_TargetPoint = display.newSprite("xiyou/pic/pic_arrow.png")
    self.m_TargetPoint:setAnchorPoint(ccp(1, 0.5))
    self.m_TargetPoint:setRotation(90)
    self.m_TargetPoint:setScale(0.5)
    self.m_MiniMap:addChild(self.m_TargetPoint, 10)
    local act1 = CCMoveBy:create(0.5, ccp(0, 18))
    local act2 = CCMoveBy:create(0.5, ccp(0, -18))
    self.m_TargetPoint:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
  end
  for _, obj in pairs(self.m_RoutePoint) do
    obj:removeFromParentAndCleanup(true)
  end
  self.m_RoutePoint = {}
  local pointSpace = 25 / self.m_ViewScaleX
  local preTime = 0
  local lastDrawPos = ccp(ox, oy)
  if route ~= nil and ox ~= nil and oy ~= nil and targetPos ~= nil then
    self.m_TargetPoint:setPosition(targetPos.x, targetPos.y + 3)
    self.m_TargetPoint:setVisible(true)
    for index, rtPos in pairs(route) do
      local tempx = rtPos[1] - ox
      local tempy = rtPos[2] - oy
      local dis = math.sqrt(tempx ^ 2 + tempy ^ 2)
      local offx, offy = -1, -1
      if tempx == 0 then
        offx = 0
        offy = pointSpace * tempy / math.abs(tempy)
      else
        offx = pointSpace * tempx / dis
        offy = pointSpace * tempy / dis
      end
      local nextx = ox + offx
      local nexty = oy + offy
      while true do
        local len = math.sqrt((nextx - ox) ^ 2 + (nexty - oy) ^ 2)
        if dis <= len then
          break
        end
        local dx = nextx * self.m_ViewScaleX
        local dy = nexty * self.m_ViewScaleY
        local temp = 10000
        if lastDrawPos ~= nil then
          temp = math.sqrt((lastDrawPos.x - dx) ^ 2 + (lastDrawPos.y - dy) ^ 2)
        end
        if temp > 15 then
          local routePoint = display.newSprite("views/pic/pic_movepoint.png")
          self.m_MiniMap:addChild(routePoint, 0)
          self.m_RoutePoint[#self.m_RoutePoint + 1] = routePoint
          routePoint:setPosition(dx, dy)
          lastDrawPos = ccp(dx, dy)
          local dt = len / self.m_MoveSpeed + preTime
          local act1 = CCDelayTime:create(dt)
          local act2 = CCHide:create()
          routePoint:runAction(transition.sequence({act1, act2}))
        end
        nextx = nextx + offx
        nexty = nexty + offy
      end
      local t = dis / self.m_MoveSpeed
      preTime = preTime + t
      local dx = rtPos[1] * self.m_ViewScaleX
      local dy = rtPos[2] * self.m_ViewScaleY
      local temp = 10000
      if lastDrawPos ~= nil then
        temp = math.sqrt((lastDrawPos.x - dx) ^ 2 + (lastDrawPos.y - dy) ^ 2)
      end
      if temp > 15 then
        local routePoint = display.newSprite("views/pic/pic_movepoint.png")
        self.m_MiniMap:addChild(routePoint, 0)
        self.m_RoutePoint[#self.m_RoutePoint + 1] = routePoint
        routePoint:setPosition(dx, dy)
        lastDrawPos = ccp(dx, dy)
        local act1 = CCDelayTime:create(preTime)
        local act2 = CCHide:create()
        routePoint:runAction(transition.sequence({act1, act2}))
      end
      ox = rtPos[1]
      oy = rtPos[2]
    end
    self:runAction(transition.sequence({
      CCDelayTime:create(preTime),
      CCCallFunc:create(function()
        self.m_TargetPoint:setVisible(false)
      end)
    }))
  else
    self.m_TargetPoint:setVisible(false)
  end
end
function CMiniMap:ClearMiniMap()
  if self.m_TargetPoint ~= nil then
    self.m_TargetPoint:setVisible(false)
  end
  for _, obj in pairs(self.m_RoutePoint) do
    obj:removeFromParentAndCleanup(true)
  end
  self.m_RoutePoint = {}
end
function CMiniMap:OnBtn_Exchange()
  if g_CMainMenuHandler and g_CMainMenuHandler:OnBtn_Menu_ShowWorldMap() then
    self:CloseSelf()
  end
end
function CMiniMap:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CMiniMap:update()
  local mapId = g_MapMgr:getCurMapId()
  if self.m_MapId ~= mapId then
    self:OnBtn_Close()
    return
  end
  local mapViewIns = g_MapMgr:getMapViewIns()
  if mapViewIns then
    local x, y = mapViewIns:getLocalRolePos()
    if x ~= nil and y ~= nil then
      x = x * self.m_ViewScaleX
      y = y * self.m_ViewScaleY
      self.m_MiniHead:setPosition(ccp(x, y))
    else
      self:OnBtn_Close()
      return
    end
  else
    self:OnBtn_Close()
    return
  end
  if g_LocalPlayer:getNormalTeamer() == true then
    self:ClearMiniMap()
  end
end
function CMiniMap:Clear()
  if self.m_Scheduler then
    scheduler.unscheduleGlobal(self.m_Scheduler)
    self.m_Scheduler = nil
  end
end
