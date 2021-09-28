local fbpage = class("fbpage", CcsSubView)
function fbpage:ctor(fbID, iSuper, isCurrMaxPage, uiDlg, act)
  fbpage.super.ctor(self, string.format("views/fb_%d.json", fbID))
  self.m_FubenID = fbID
  self.m_IsSuper = iSuper
  self.m_IsCurrMaxPage = isCurrMaxPage
  self.m_UiDlg = uiDlg
  self.m_StarTable = {}
  self.m_AllCatchPoints = {}
  local offx = (display.width - 960) / 2
  local offy = (display.height - 640) / 2
  self.base = self:getNode("base")
  local x, y = self.base:getPosition()
  self.base:setPosition(ccp(x + offx, y + offy))
  setDefaultAlphaPixelFormat(PixelFormat_FbBg)
  self.m_sceneImg = display.newSprite(string.format("views/fb/scene%.3d.jpg", fbID))
  resetDefaultAlphaPixelFormat()
  self.base:addNode(self.m_sceneImg, -1)
  self.m_sceneImg:setAnchorPoint(ccp(0.5, 0.5))
  self.m_sceneImg:setPosition(ccp(0, 0))
  self:initCurrCatchID()
  self:setAllCatchPoints()
  if act then
    self:FadeInPage()
  end
  self:ListenMessage(MsgID_FubenInfo)
  self:ListenMessage(MsgID_Scene)
  self:getUINode():setSize(CCSize(display.width, display.height))
end
function fbpage:initCurrCatchID()
  if not self.m_IsCurrMaxPage then
    return
  end
  self.m_CurrMaxCatchID = 1
  local catchData = data_getCatchDataList(self.m_FubenID)
  if catchData then
    for cid, _ in ipairs(catchData) do
      self.m_CurrMaxCatchID = cid
      if g_LocalPlayer:getCatchStars(self.m_FubenID, cid, self.m_IsSuper) <= 0 then
        if self.m_IsSuper then
          local isDouble = data_getCatchIsDouble(self.m_FubenID, cid)
          if isDouble then
            break
          end
        else
          break
        end
      end
    end
  end
end
function fbpage:getFubenID()
  return self.m_FubenID
end
function fbpage:setIsCurrMaxPage(isCurrMaxPage)
  self.m_IsCurrMaxPage = isCurrMaxPage
end
function fbpage:getIsCurrMaxPage()
  return self.m_IsCurrMaxPage
end
function fbpage:IsCurrMaxProCatchID(cid)
  if not self.m_IsCurrMaxPage then
    return false
  end
  return self.m_CurrMaxCatchID == cid
end
function fbpage:getCurrMaxProCatchID()
  return self.m_CurrMaxCatchID
end
function fbpage:isPointCanClick(cid)
  if not self.m_IsCurrMaxPage then
    local point = self:getCatchObj(cid)
    return point._isDouble
  end
  if cid > self.m_CurrMaxCatchID then
    return false
  else
    local point = self:getCatchObj(cid)
    if point._isDouble then
      return true
    elseif self.m_IsSuper then
      return false
    else
      return g_LocalPlayer:getCatchStars(self.m_FubenID, cid, self.m_IsSuper) <= 0
    end
  end
end
function fbpage:getAllCatchPoints()
  return self.m_AllCatchPoints
end
function fbpage:getCatchObj(cid)
  if self.m_AllCatchPoints[cid] ~= nil then
    return self.m_AllCatchPoints[cid]
  else
    return self:getNode(string.format("point%d", cid))
  end
end
function fbpage:setAllCatchPoints()
  local catchData = data_getCatchDataList(self.m_FubenID)
  if catchData == nil then
    return
  end
  for cid, data in ipairs(catchData) do
    local point = self:getCatchObj(cid)
    self.m_AllCatchPoints[cid] = point
    if data.isDouble == 0 then
      point._isDouble = false
      self:setNotDoubleCatch(cid, self.m_IsSuper)
    else
      point._isDouble = true
      self:setStar(cid, self.m_IsSuper)
    end
  end
end
function fbpage:setNotDoubleCatch(cid, iSuper)
  if iSuper then
    self:setNotDoublePointVisible(cid, false)
  else
    local sNum = g_LocalPlayer:getCatchStars(self.m_FubenID, cid, iSuper)
    if sNum > 0 then
      self:setNotDoublePointWinState(cid)
    else
      self:setNotDoublePointVisible(cid, true)
      self:setNotDoublePointEnabled(cid, cid == self.m_CurrMaxCatchID)
    end
  end
end
function fbpage:setNotDoublePointEnabled(cid, enabled)
  local point = self:getCatchObj(cid)
  if point == nil then
    return
  end
  point:setVisible(enabled)
end
function fbpage:setNotDoublePointVisible(cid, visible)
  local point = self:getCatchObj(cid)
  if point == nil then
    return
  end
  point:setVisible(visible)
end
function fbpage:setNotDoublePointWinState(cid)
  local point = self:getCatchObj(cid)
  if point == nil then
    return
  end
  if point._winFlag ~= nil then
    return
  end
  local p = point:getParent()
  local x, y = point:getPosition()
  local z = point:getZOrder()
  local size = point:getContentSize()
  local newPoint = display.newSprite("views/fb/pic_nd_catch.png")
  p:addNode(newPoint, z)
  newPoint:setPosition(x, y - size.height / 2 + 5)
  newPoint._winFlag = true
  self.m_AllCatchPoints[cid] = newPoint
  point:removeFromParentAndCleanup(true)
end
function fbpage:setStar(cid, iSuper)
  local sNum = g_LocalPlayer:getCatchStars(self.m_FubenID, cid, iSuper)
  local star = self.m_StarTable[cid]
  if star == nil then
    local point = self:getCatchObj(cid)
    if point then
      star = fbstar.new(sNum)
      star:addTo(point, 1)
      star:setPosition(ccp(0, -40))
      self.m_StarTable[cid] = star
      if point._bossHead == nil then
        local warID = data_getCatchWarID(self.m_FubenID, cid, iSuper)
        if warID ~= nil then
          local bossTypeId, _ = data_getBossForWar(warID)
          local bossHead = createHeadIconByRoleTypeID(bossTypeId)
          bossHead:setAnchorPoint(ccp(0.5, 0))
          bossHead:setScale(0.6)
          point:addNode(bossHead, 1)
          bossHead:setPosition(1, -23)
          point._bossHead = bossHead
        end
      end
    end
  else
    star:setStar(sNum)
  end
  self:setPointEnabled(cid, sNum > 0 or self:IsCurrMaxProCatchID(cid))
  self:setTeamFlag(cid, sNum <= 0)
end
function fbpage:setPointEnabled(cid, enabled)
  local point = self:getCatchObj(cid)
  if point then
    point:setEnabled(enabled)
  end
end
function fbpage:setTeamFlag(cid, flag)
  local point = self:getCatchObj(cid)
  if point then
    local needFlag = data_getCatchNeedTeamFlag(self.m_FubenID, cid)
    if needFlag == true and flag then
      if point.m_TeamText == nil then
        point.m_TeamText = display.newSprite("views/fb/pic_tjzd.png")
        point.m_TeamText:setAnchorPoint(ccp(0.5, 0.5))
        point.m_TeamText:setPosition(ccp(0, -50))
        point:addNode(point.m_TeamText)
      end
    elseif point.m_TeamText ~= nil then
      point.m_TeamText:removeFromParent()
      point.m_TeamText = nil
    end
  end
end
function fbpage:selectPoint(cid)
  print("~~~cid:", self.m_FubenID, cid, self.m_IsSuper)
  if self.m_IsSuper then
    if not data_getCatchIsDouble(self.m_FubenID, cid) then
      ShowNotifyTips("精英模式不能玩这个关卡")
      return
    elseif g_LocalPlayer:getCatchStars(self.m_FubenID, cid, false) <= 0 then
      ShowNotifyTips(string.format("战胜普通难度的#<Y>%s#才能挑战", data_getCatchName(self.m_FubenID, cid)))
      return
    end
  elseif not data_getCatchIsDouble(self.m_FubenID, cid) then
    local sNum = g_LocalPlayer:getCatchStars(self.m_FubenID, cid, iSuper)
    if sNum > 0 then
      ShowNotifyTips("该关卡已被打败")
      return
    end
  end
  local isInTeamAndIsNotCaptain = false
  if g_LocalPlayer:getPlayerIsInTeam() and not g_LocalPlayer:getPlayerInTeamAndIsCaptain() then
    isInTeamAndIsNotCaptain = true
  end
  soundManager.playSound("xiyou/sound/clickbutton_2.wav")
  local btnPos = self.m_UiDlg.m_buttonBack:convertToWorldSpace(ccp(0, 0))
  if self.m_ArrowToCatch then
    self.m_ArrowToCatch:setVisible(false)
  end
  local hasMonsterFlag = g_LocalPlayer:isHasCatchMonster(self.m_FubenID, cid)
  if hasMonsterFlag then
    g_MapMgr:AutoRouteFB({
      self.m_FubenID,
      cid
    })
  else
    netsend.netguanka.askToCreateNpc(self.m_FubenID, cid)
  end
end
function fbpage:setArrowToCatch(cid)
  local point = self:getCatchObj(cid)
  if point == nil then
    return
  end
  if self.m_ArrowToCatch == nil then
    local p = point:getParent()
    self.m_ArrowToCatch = display.newSprite("xiyou/pic/pic_arrow.png")
    p:addNode(self.m_ArrowToCatch, 99)
    self.m_ArrowToCatch:setAnchorPoint(ccp(1, 0.5))
    self.m_ArrowToCatch:setRotation(90)
  else
    self.m_ArrowToCatch:stopAllActions()
  end
  local x, y = point:getPosition()
  self.m_ArrowToCatch:setPosition(x, y)
  local act1 = CCMoveBy:create(0.5, ccp(0, 30))
  local act2 = CCMoveBy:create(0.5, ccp(0, -30))
  self.m_ArrowToCatch:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
  self:ShowArrowToCatch()
end
function fbpage:deleteArrowToCatch()
  if self.m_ArrowToCatch ~= nil then
    self.m_ArrowToCatch:removeFromParentAndCleanup(true)
    self.m_ArrowToCatch = nil
  end
end
function fbpage:ShowArrowToCatch()
  if self.m_ArrowToCatch ~= nil then
    if g_WarScene ~= nil or g_WarLoseResultIns ~= nil then
      self.m_ArrowToCatch:setVisible(false)
    else
      self.m_ArrowToCatch:setVisible(true)
    end
  end
end
function fbpage:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_FubenInfo_CatchInfo then
    local mapID = arg[1]
    local catchID = arg[2]
    if mapID == self.m_FubenID then
      if data_getCatchIsDouble(self.m_FubenID, catchID) then
        self:setStar(catchID, self.m_IsSuper)
      else
        self:setNotDoubleCatch(catchID, self.m_IsSuper)
      end
    end
  elseif msgSID == MsgID_Scene_War_Enter or msgSID == MsgID_Scene_War_Exit then
    self:ShowArrowToCatch()
  elseif msgSID == MsgID_Scene_WarResult_Enter or MsgID_Scene_WarResult_Exit then
    self:ShowArrowToCatch()
  end
end
function fbpage:FadeInPage()
  local dt = 0.5
  self.m_sceneImg:setOpacity(0)
  self.m_sceneImg:runAction(CCFadeIn:create(dt))
  for _, point in pairs(self.m_AllCatchPoints) do
    point:setOpacity(0)
    point:runAction(CCFadeIn:create(dt))
    if point._bossHead then
      point._bossHead:runAction(CCFadeIn:create(dt))
    end
  end
  for _, star in pairs(self.m_StarTable) do
    star:setFadeIn(dt)
  end
end
function fbpage:FadeOutPage()
  local dt = 0.5
  self.m_sceneImg:runAction(CCFadeOut:create(dt))
  for _, point in pairs(self.m_AllCatchPoints) do
    point:runAction(CCFadeOut:create(dt))
    if point._bossHead then
      point._bossHead:runAction(CCFadeOut:create(dt))
    end
  end
  for _, star in pairs(self.m_StarTable) do
    star:setFadeOut(dt)
  end
  local act1 = CCDelayTime:create(dt)
  local act2 = CCCallFunc:create(function()
    self:removeFromParentAndCleanup(true)
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function fbpage:deletePage(act)
  if act then
    self:FadeOutPage()
  else
    self:removeFromParentAndCleanup(true)
  end
end
function fbpage:Clear()
  self.m_UiDlg = nil
end
return fbpage
