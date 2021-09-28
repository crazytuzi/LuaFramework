local fbui = class("fbui", CcsSubView)
function fbui:ctor(fbID, iSuper, arrowToInfo)
  fbui.super.ctor(self, "views/fbui.json")
  local btnBatchListener = {
    buttonBack = {
      listener = handler(self, self.Btn_Back),
      variName = "m_buttonBack",
      param = {3}
    },
    buttonPre = {
      listener = handler(self, self.Btn_PrePage),
      variName = "m_buttonPre"
    },
    buttonNext = {
      listener = handler(self, self.Btn_NextPage),
      variName = "m_buttonNext"
    },
    btn_award = {
      listener = handler(self, self.Btn_OpenGetAward),
      variName = "btn_award"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:setIsSuperMode(iSuper)
  self.m_CurrFbID_Super = 1
  self.m_CurrFbID_Normal = 1
  self.m_MaxFubenMapID = date_getMaxFubenMapID()
  self:initMaxAndMin()
  if fbID == nil then
    self.m_CurrFbID_Normal = self.m_FbIDMax_Normal
    self.m_CurrFbID_Super = self.m_FbIDMax_Super
  elseif iSuper then
    self.m_CurrFbID_Normal = self.m_FbIDMax_Normal
    if fbID > self.m_FbIDMax_Super then
      self.m_CurrFbID_Super = self.m_FbIDMax_Super
      arrowToInfo = nil
    else
      self.m_CurrFbID_Super = fbID
    end
  else
    if fbID > self.m_FbIDMax_Normal then
      self.m_CurrFbID_Normal = self.m_FbIDMax_Normal
      arrowToInfo = nil
    else
      self.m_CurrFbID_Normal = fbID
    end
    self.m_CurrFbID_Super = self.m_FbIDMax_Super
  end
  self.m_ArrowToInfo = nil
  if arrowToInfo ~= nil then
    self.m_ArrowToInfo = arrowToInfo
  end
  self.m_PrePage = nil
  self.m_CurrPage = nil
  self.m_NextPage = nil
  self.m_PageWith = 0
  self.m_CurrPagePosX = 0
  self.m_PageIsMoving = false
  self.m_PageNode = Widget:create()
  self.m_UINode:addChild(self.m_PageNode, -1)
  self:createInitPages()
  if self.m_CurrPage == nil then
    ShowNotifyTips(string.format("关卡第%d章尚未开启", self:getCurrFbID()))
    return
  end
  self.m_PageWith = self.m_CurrPage:getContentSize().width
  self:setPageInPos()
  self:checkArrowToCatch()
  self:checkPreAndNextButton()
  self.m_TouchNode = clickwidget.create(display.width, display.height, 0, 0, function(touchNode, event)
    self:TouchOnRole(event)
  end)
  self.m_UINode:addChild(self.m_TouchNode, -99999)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_FubenInfo)
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_MapScene)
  self:getUINode():setSize(CCSize(display.width, display.height))
  ShowCutScreenAni()
end
function fbui:initGuide(isShow)
  local fubenAwardInfo = g_LocalPlayer:getFubenAwardInfo()
  if fubenAwardInfo ~= nil and #fubenAwardInfo > 0 and isShow ~= true or g_MissionMgr == nil or g_MissionMgr.guidefb == true then
    return
  end
  g_MissionMgr.guidefb = true
  if self.gtext_fb ~= nil then
    self.gtext_fb:removeFromParentAndCleanup(true)
    self.gtext_fb = nil
  end
  if self.guideAni_fb ~= nil then
    self.guideAni_fb:removeFromParentAndCleanup(true)
    self.guideAni_fb = nil
  end
  local posx, posy = self.m_buttonBack:getPosition()
  local btnSize = self.m_buttonBack:getContentSize()
  local mobjSize = {
    btnSize.width + 10,
    btnSize.height + 10
  }
  local addOrder = 0
  if self.m_buttonBack.getZOrder then
    addOrder = self.m_buttonBack:getZOrder()
  end
  local param = {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    deltaPos = {0, 0},
    objSize = mobjSize,
    txtparam = {
      txt = "  点击返回地图  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    }
  }
  self.gtext_fb = g_MissionMgr:getTextAni(param)
  self.guideAni_fb = GuideArrowAni.new(param)
  self.gtext_fb:setPosition(ccp(posx, posy))
  self.guideAni_fb:setPosition(ccp(posx, posy))
  if self.m_UINode then
    self.m_UINode:addNode(self.guideAni_fb, addOrder)
    if self.gtext_fb then
      self.m_UINode:addNode(self.gtext_fb, addOrder)
    end
  else
    self:addNode(self.guideAni_fb, addOrder)
    if self.gtext_fb then
      self:addNode(self.m_txtani, addOrder)
    end
  end
end
function fbui:onEnterEvent()
  self:CheckUnlockMapAni(self:getCurrFbID())
  self:checkAwardData()
end
function fbui:initMaxAndMin()
  local fbID_n, fbID_s = g_FbInterface.getMaxOpenMap()
  self.m_FbIDMax_Normal = fbID_n
  self.m_FbIDMin_Normal = 1
  self.m_FbIDMax_Super = fbID_s
  self.m_FbIDMin_Super = 1
end
function fbui:getMaxAndMinFbID()
  if self.m_IsSuper then
    return self.m_FbIDMax_Super, self.m_FbIDMin_Super
  else
    return self.m_FbIDMax_Normal, self.m_FbIDMin_Normal
  end
end
function fbui:setCurrFbID(fbID)
  if self.m_IsSuper then
    self.m_CurrFbID_Super = fbID
  else
    self.m_CurrFbID_Normal = fbID
  end
  local name = data_getFubenName(fbID)
  self.m_Name = self:getNode("name")
  self.m_Name:setText(name)
end
function fbui:getCurrFbID()
  if self.m_IsSuper then
    return self.m_CurrFbID_Super
  else
    return self.m_CurrFbID_Normal
  end
end
function fbui:InitSuccess()
  return self.m_CurrPage ~= nil
end
function fbui:SetShowMaxFuBenCatch(iSuper)
  if iSuper == nil or iSuper == 0 then
    iSuper = false
  end
  self:initMaxAndMin()
  self:ClearArrowToInfo()
  if iSuper then
    self.m_CurrFbID_Normal = self.m_FbIDMax_Normal
  else
    self.m_CurrFbID_Super = self.m_FbIDMax_Super
  end
  if iSuper ~= self.m_IsSuper then
    self:setIsSuperMode(iSuper)
    self:reloadMode()
  else
    local currFbID = self:getCurrFbID()
    if currFbID ~= self:getMaxAndMinFbID() then
      if self.m_NextPage == nil then
        self.m_NextPage = self:createPage(currFbID + 1)
      end
      if self.m_NextPage then
        self.m_CurrPage:setIsCurrMaxPage(false)
        if self.m_PrePage then
          self.m_PrePage:deleteArrowToCatch()
        end
        if self.m_CurrPage then
          self.m_CurrPage:deleteArrowToCatch()
        end
        self:setCurrFbID(currFbID + 1)
        if self.m_PrePage then
          self.m_PrePage:removeFromParentAndCleanup(true)
        end
        self.m_PrePage = self.m_CurrPage
        self.m_CurrPage = self.m_NextPage
        local newCurrFbID = self:getCurrFbID()
        self.m_NextPage = self:createPage(newCurrFbID + 1)
        self:setPageInPos()
        self:checkArrowToCatch()
        self:checkPreAndNextButton()
        self:checkAwardData()
        self:CheckUnlockMapAni(newCurrFbID)
      end
    else
      if self.m_PrePage then
        self.m_PrePage:deleteArrowToCatch()
      end
      if self.m_NextPage then
        self.m_NextPage:deleteArrowToCatch()
      end
      self.m_CurrPage:initCurrCatchID()
      self.m_CurrPage:setAllCatchPoints()
      self:checkArrowToCatch()
      self:checkPreAndNextButton()
    end
  end
end
function fbui:SetPointToCatch(catchId)
  self:ClearArrowToInfo()
  if self.m_CurrPage then
    self.m_CurrPage:setArrowToCatch(catchId)
  end
  if self.m_PrePage then
    self.m_PrePage:deleteArrowToCatch()
  end
  if self.m_NextPage then
    self.m_NextPage:deleteArrowToCatch()
  end
end
function fbui:ClearArrowToInfo()
  self.m_ArrowToInfo = nil
end
function fbui:checkArrowToCatch()
  if self.m_ArrowToInfo == nil then
    for _, pageObj in pairs({
      self.m_PrePage,
      self.m_CurrPage,
      self.m_NextPage
    }) do
      if pageObj:getIsCurrMaxPage() then
        pageObj:setArrowToCatch(pageObj:getCurrMaxProCatchID())
      end
    end
    return
  end
  local fbID = self.m_ArrowToInfo[1]
  local catchID = self.m_ArrowToInfo[2]
  local iSuper = self.m_ArrowToInfo[3]
  for _, pageObj in pairs({
    self.m_PrePage,
    self.m_CurrPage,
    self.m_NextPage
  }) do
    if pageObj and pageObj:getFubenID() == fbID and self.m_IsSuper == iSuper then
      if g_LocalPlayer:getCatchStars(fbID, catchID, iSuper) ~= 0 or pageObj:IsCurrMaxProCatchID(catchID) then
        pageObj:setArrowToCatch(catchID)
        break
      end
      pageObj:setArrowToCatch(pageObj:getCurrMaxProCatchID())
      break
    end
  end
end
function fbui:setIsSuperMode(iSuper)
  self.m_IsSuper = iSuper
end
function fbui:createInitPages(act)
  if self.m_CurrPage ~= nil then
    self.m_CurrPage:deletePage(act)
    self.m_CurrPage = nil
  end
  if self.m_PrePage ~= nil then
    self.m_PrePage:deletePage(act)
    self.m_PrePage = nil
  end
  if self.m_NextPage ~= nil then
    self.m_NextPage:deletePage(act)
    self.m_NextPage = nil
  end
  local currFbID = self:getCurrFbID()
  self.m_CurrPage = self:createPage(currFbID, act)
  self.m_PrePage = self:createPage(currFbID - 1, act)
  self.m_NextPage = self:createPage(currFbID + 1, act)
  self:setCurrFbID(currFbID)
end
function fbui:createPage(fbID, act)
  local maxId, minId = self:getMaxAndMinFbID()
  if fbID < minId or fbID > maxId then
    return nil
  end
  local page = fbpage.new(fbID, self.m_IsSuper, fbID == maxId, self, act)
  page:addTo(self.m_PageNode)
  return page
end
function fbui:getCurrPage()
  return self.m_CurrPage
end
function fbui:getPrePage()
  return self.m_PrePage
end
function fbui:getNextPage()
  return self.m_NextPage
end
function fbui:getIsSuper()
  return self.m_IsSuper
end
function fbui:setPageInPos()
  if self.m_CurrPage then
    local wPos = self.m_UINode:convertToWorldSpace(ccp(self.m_CurrPagePosX, 0))
    local pos = self.m_PageNode:convertToNodeSpace(wPos)
    self.m_CurrPage:setPosition(pos)
  end
  if self.m_PrePage then
    local x, y = self.m_CurrPage:getPosition()
    self.m_PrePage:setPosition(ccp(x - self.m_PageWith, 0))
  end
  if self.m_NextPage then
    local x, y = self.m_CurrPage:getPosition()
    self.m_NextPage:setPosition(ccp(x + self.m_PageWith, 0))
  end
end
function fbui:checkPreAndNextButton()
  local fbID = self:getCurrFbID()
  local maxCatchId = date_getMaxFubenCatchID(fbID)
  self.m_buttonNext:setEnabled(g_LocalPlayer:getCatchStars(fbID, maxCatchId, self.m_IsSuper) > 0 and fbID < self.m_MaxFubenMapID)
  self.m_buttonPre:setEnabled(self.m_PrePage ~= nil)
end
function fbui:checkAwardData()
  self:setStarData()
  local fbId = self:getCurrFbID()
  local hasNoGetAwardFlag = g_LocalPlayer:getFubenCanGetAward(fbId)
  if hasNoGetAwardFlag then
    do
      local showState
      local fubenAwardInfo = g_LocalPlayer:getFubenAwardInfo()
      if fubenAwardInfo == nil or #fubenAwardInfo <= 0 then
        showState = true
      end
      ShowFuBenGetAward(fbId, function()
        self:initGuide(showState)
      end)
    end
  else
    self:initGuide()
  end
end
function fbui:setStarData()
  local fbId = self:getCurrFbID()
  local getStar, allStar = g_LocalPlayer:getFubenStarNum(fbId)
  self:getNode("txt_star"):setText(string.format("%d/%d", getStar, allStar))
  if self.m_StarBar == nil then
    self.m_StarBar = ProgressClip.new("views/mainviews/pic_tilibar.png", "views/mainviews/pic_tilibarbg.png", 0, 100, true)
    local size1 = self:getNode("pic_awardbg"):getContentSize()
    self.m_StarBar:setPosition(ccp(-size1.width / 2 + 20, -size1.height / 2 + 5))
    self:getNode("pic_awardbg"):addChild(self.m_StarBar)
  end
  self.m_StarBar:progressTo(getStar, nil, allStar)
end
function fbui:reloadMode()
  self:createInitPages(true)
  self:setPageInPos()
  self:checkArrowToCatch()
  self:checkPreAndNextButton()
  self:checkAwardData()
end
function fbui:Btn_Back(obj, t)
  print("==>>fbui:Btn_Back")
  g_FbInterface.CloseFueben()
  SendMessage(MsgID_Scene_Fuben_Exit)
end
function fbui:Btn_PrePage(obj, t)
  print("==>>fbui:Btn_PrePage")
  if self.m_PageIsMoving then
    print("can not move. moving currently")
    return
  end
  local currFbID = self:getCurrFbID()
  local maxId, minId = self:getMaxAndMinFbID()
  if currFbID <= minId then
    print("most pre page")
    self:setCurrPageInMiddle()
    return
  end
  local wPos = self.m_UINode:convertToWorldSpace(ccp(self.m_PageWith, 0))
  local pos = self.m_CurrPage.m_UINode:convertToNodeSpace(wPos)
  local moveOffX = pos.x
  self.m_PageIsMoving = true
  local t = self:getPageMoveTime(moveOffX)
  local act1 = CCMoveBy:create(t, ccp(moveOffX, 0))
  local act2 = CCDelayTime:create(0.05)
  local act3 = CCCallFunc:create(function()
    self:setCurrFbID(currFbID - 1)
    if self.m_NextPage then
      self.m_NextPage:removeFromParentAndCleanup(true)
    end
    self.m_NextPage = self.m_CurrPage
    self.m_CurrPage = self.m_PrePage
    currFbID = self:getCurrFbID()
    self.m_PrePage = self:createPage(currFbID - 1)
    self:setPageInPos()
    self:checkArrowToCatch()
    self:checkPreAndNextButton()
    self:checkAwardData()
    self.m_PageIsMoving = false
  end)
  self.m_PageNode:runAction(transition.sequence({
    act1,
    act2,
    act3
  }))
end
function fbui:Btn_NextPage(obj, t)
  print("==>>fbui:Btn_NextPage")
  if self.m_PageIsMoving then
    print("can not move. moving currently")
    return
  end
  local currFbID = self:getCurrFbID()
  local maxId, minId = self:getMaxAndMinFbID()
  if currFbID >= maxId then
    print("most next page")
    self:setCurrPageInMiddle()
    self:showTipOfNextUnlockInfo(currFbID)
    return
  end
  local wPos = self.m_UINode:convertToWorldSpace(ccp(-self.m_PageWith, 0))
  local pos = self.m_CurrPage.m_UINode:convertToNodeSpace(wPos)
  local moveOffX = pos.x
  self:CheckUnlockMapAni(currFbID + 1)
  self.m_PageIsMoving = true
  local t = self:getPageMoveTime(moveOffX)
  local act1 = CCMoveBy:create(t, ccp(moveOffX, 0))
  local act2 = CCDelayTime:create(0.05)
  local act3 = CCCallFunc:create(function()
    self:setCurrFbID(currFbID + 1)
    if self.m_PrePage then
      self.m_PrePage:removeFromParentAndCleanup(true)
    end
    self.m_PrePage = self.m_CurrPage
    self.m_CurrPage = self.m_NextPage
    currFbID = self:getCurrFbID()
    self.m_NextPage = self:createPage(currFbID + 1)
    self:setPageInPos()
    self:checkArrowToCatch()
    self:checkPreAndNextButton()
    self:checkAwardData()
    self.m_PageIsMoving = false
  end)
  self.m_PageNode:runAction(transition.sequence({
    act1,
    act2,
    act3
  }))
end
function fbui:Btn_OpenGetAward(obj, t)
  local fbId = self:getCurrFbID()
  ShowFuBenGetAward(fbId)
end
function fbui:showTipOfNextUnlockInfo(fbId)
  local maxFbId = date_getMaxFubenMapID()
  if fbId >= maxFbId then
    return
  end
  local maxCatchId = date_getMaxFubenCatchID(fbId)
  if g_LocalPlayer:getCatchStars(fbId, maxCatchId, self.m_IsSuper) <= 0 then
    return
  end
  local zhuanNeed, levelNeed = data_getCatchUnlockInfo(fbId + 1, 1, self.m_IsSuper)
  ShowNotifyTips(string.format("开启下一章需要%d转%d级", zhuanNeed, levelNeed))
end
function fbui:setCurrPageInMiddle()
  local wPos = self.m_UINode:convertToWorldSpace(ccp(self.m_CurrPagePosX, 0))
  local pos = self.m_PageNode:convertToNodeSpace(wPos)
  local x, _ = self.m_CurrPage:getPosition()
  local moveOffX = pos.x - x
  self.m_PageIsMoving = true
  local t = self:getPageMoveTime(moveOffX)
  local act1 = CCMoveBy:create(t, ccp(moveOffX, 0))
  local act2 = CCCallFunc:create(function()
    self:setPageInPos()
    self.m_PageIsMoving = false
  end)
  self.m_PageNode:runAction(transition.sequence({act1, act2}))
end
function fbui:getPageMoveTime(moveOff)
  return math.abs(moveOff) / 3000
end
function fbui:TouchOnRole(event)
  if self.m_CurrPage == nil then
    return
  end
  if event == TOUCH_EVENT_BEGAN then
    self:onTouchBegan()
  elseif event == TOUCH_EVENT_MOVED then
    self:onTouchMoved()
  elseif event == TOUCH_EVENT_ENDED then
    self:onTouchEnded()
  elseif event == TOUCH_EVENT_CANCELED then
    self:onTouchEnded()
  end
end
function fbui:onTouchBegan()
  self.m_HasTouchMoved = false
  self.m_PageNodeX, _ = self.m_PageNode:getPosition()
  self.m_PageNode:stopAllActions()
  local touchPos = self.m_TouchNode:getTouchStartPos()
  self.m_LastTouchPosX = touchPos.x
  self.m_LastMovedXDistance = 0
  self.m_BeganTouchCatch, self.m_BeganTouchCatchObj = self:checkTouchObj(touchPos.x, touchPos.y)
  self:setSelectState(self.m_BeganTouchCatchObj, true)
  self.m_PageIsMoving = false
end
function fbui:onTouchMoved()
  local startPos = self.m_TouchNode:getTouchStartPos()
  local movePos = self.m_TouchNode:getTouchMovePos()
  local deltaX = movePos.x - startPos.x
  if not self.m_HasTouchMoved then
    if math.abs(deltaX) < 10 then
      return
    else
      self:setSelectState(self.m_BeganTouchCatchObj, false)
      self.m_HasTouchMoved = true
    end
  end
  local x = self.m_PageNodeX + deltaX
  if self:checkCanMove(x, 0) then
    self.m_PageNode:setPosition(ccp(x, 0))
  end
  self.m_LastMovedXDistance = movePos.x - self.m_LastTouchPosX
  self.m_LastTouchPosX = movePos.x
end
function fbui:onTouchEnded()
  self:setSelectState(self.m_BeganTouchCatchObj, false)
  if self.m_HasTouchMoved and math.abs(self.m_LastMovedXDistance) > 5 then
    if self.m_LastMovedXDistance > 0 then
      local wPos = self.m_UINode:convertToWorldSpace(ccp(self.m_CurrPagePosX, 0))
      local pos = self.m_CurrPage.m_UINode:convertToWorldSpace(ccp(0, 0))
      if pos.x >= wPos.x then
        self:Btn_PrePage()
      else
        self:setCurrPageInMiddle()
      end
    else
      local wPos = self.m_UINode:convertToWorldSpace(ccp(self.m_CurrPagePosX, 0))
      local pos = self.m_CurrPage.m_UINode:convertToWorldSpace(ccp(0, 0))
      if pos.x <= wPos.x then
        self:Btn_NextPage()
      else
        self:setCurrPageInMiddle()
      end
    end
  else
    local wPos = self.m_CurrPage.m_UINode:convertToWorldSpace(ccp(0, 0))
    local pos = self.m_UINode:convertToNodeSpace(wPos)
    if pos.x > self.m_CurrPagePosX + self.m_PageWith / 2 then
      self:Btn_PrePage()
    elseif pos.x < self.m_CurrPagePosX - self.m_PageWith / 2 then
      self:Btn_NextPage()
    else
      self:setCurrPageInMiddle()
    end
    if not self.m_HasTouchMoved and self.m_BeganTouchCatch then
      self:selectPointOfCurrPage(self.m_BeganTouchCatch)
      self.m_BeganTouchCatch = nil
    end
  end
  self.m_BeganTouchCatch = nil
  self.m_BeganTouchCatchObj = nil
end
function fbui:checkTouchObj(tx, ty)
  if self.m_PageIsMoving then
    return nil, nil
  end
  local touchx, touchy
  local objList = self.m_CurrPage:getAllCatchPoints()
  for cid, obj in pairs(objList) do
    local x, y = obj:getPosition()
    local size = obj:getContentSize()
    if touchx == nil or touchy == nil then
      local pos = obj:getParent():convertToNodeSpace(ccp(tx, ty))
      touchx, touchy = pos.x, pos.y
    end
    if touchx >= x - size.width / 2 and touchx <= x + size.width / 2 and touchy >= y - size.height / 2 and touchy <= y + size.height / 2 then
      if self.m_CurrPage:isPointCanClick(cid) then
        return cid, obj
      else
        return nil, nil
      end
    end
  end
  return nil, nil
end
function fbui:selectPointOfCurrPage(catchId)
  self.m_CurrPage:selectPoint(catchId)
end
function fbui:setSelectState(obj, isSelect)
  if obj == nil then
    return
  end
  if isSelect then
    obj:setScale(1.1)
  else
    obj:setScale(1)
  end
end
function fbui:checkCanMove(x, y)
  local px, py = self.m_PageNode:getPosition()
  local offx = x - px
  local offy = y - py
  local cx, cy = self.m_CurrPage:getPosition()
  local wPos = self.m_PageNode:convertToWorldSpace(ccp(cx + offx, cy + offy))
  local pos = self.m_UINode:convertToNodeSpace(wPos)
  if pos.x < self.m_CurrPagePosX then
    if self.m_NextPage == nil then
      return false
    else
      local size = self.m_NextPage:getUINode():getContentSize()
      local p = self.m_NextPage.m_UINode:convertToWorldSpace(ccp(size.width + offx, 0))
      if p.x < display.width then
        return false
      end
    end
  elseif pos.x > self.m_CurrPagePosX then
    if self.m_PrePage == nil then
      return false
    else
      local p = self.m_PrePage.m_UINode:convertToWorldSpace(ccp(offx, 0))
      if p.x > 0 then
        return false
      end
    end
  end
  return true
end
function fbui:CheckUnlockMapAni(mapId)
  if mapId <= g_LocalPlayer:getUnlockMap() then
    print("-->>已经看过1")
    return
  end
  if g_LocalPlayer:getCatchStars(mapId, 1, self.m_IsSuper) > 0 then
    print("-->>已经看过2")
    return
  end
  g_LocalPlayer:setUnlockMap(mapId)
  netsend.netguanka.unlockMapId(mapId)
  local mapName = data_getFubenName(mapId)
  local blackLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
  parent = display.getRunningScene()
  parent:addChild(blackLayer, 9999)
  local descTxt = ui.newTTFLabel({
    text = mapName,
    size = 28,
    font = KANG_TTF_FONT,
    color = ccc3(255, 255, 255)
  })
  descTxt:setAnchorPoint(ccp(0.5, 0.5))
  blackLayer:addChild(descTxt)
  descTxt:setPosition(display.width / 2, display.height / 2)
  local touch = function(event, x, y)
    return true
  end
  blackLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, touch)
  blackLayer:setTouchEnabled(true)
  blackLayer:setTouchSwallowEnabled(true)
  local ft = 1
  local act1 = CCDelayTime:create(2)
  local act2 = CCCallFunc:create(function()
    descTxt:runAction(CCFadeOut:create(ft))
  end)
  local act3 = CCFadeOut:create(ft)
  local act4 = CCCallFunc:create(function()
    blackLayer:removeFromParentAndCleanup(true)
  end)
  blackLayer:runAction(transition.sequence({
    act1,
    act2,
    act3,
    act4
  }))
end
function fbui:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  local fid = self:GetFIDWithSID(msgSID)
  if msgSID == MsgID_FubenInfo_BaseInfo then
    self:setStarData()
  elseif msgSID == MsgID_FubenInfo_CatchInfo then
    self:setStarData()
  elseif msgSID == MsgID_Team_PlayerJoinTeam then
    local pid = arg[2]
    if pid == g_LocalPlayer:getPlayerId() and g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
      g_FbInterface.CloseFueben()
    end
  elseif msgSID == MsgID_Team_TeamState then
    local pid = arg[2]
    local teamState = arg[3]
    if pid == g_LocalPlayer:getPlayerId() and teamState == TEAMSTATE_FOLLOW then
      g_FbInterface.CloseFueben()
    end
  elseif msgSID == MsgID_MapScene_AutoRoute then
    g_FbInterface.CloseFueben()
  end
end
function fbui:readyToCutScreen()
  if self.m_CurrPage then
    local z = self.m_CurrPage.m_UINode:getZOrder()
    local p = self.m_CurrPage.m_UINode:getParent()
    p:reorderChild(self.m_CurrPage.m_UINode, z)
    self.m_CurrPage.m_UINode:setClippingEnabled(false)
  end
  if self.m_PrePage then
    self.m_PrePage.m_UINode:setClippingEnabled(false)
  end
  if self.m_NextPage then
    self.m_NextPage.m_UINode:setClippingEnabled(false)
  end
end
function fbui:recoverAfterCutScreen()
  if self.m_CurrPage then
    self.m_CurrPage.m_UINode:setClippingEnabled(true)
  end
  if self.m_PrePage then
    self.m_PrePage.m_UINode:setClippingEnabled(true)
  end
  if self.m_NextPage then
    self.m_NextPage.m_UINode:setClippingEnabled(true)
  end
end
function fbui:Clear()
  if self.gtext_fb ~= nil then
    self.gtext_fb:removeFromParentAndCleanup(true)
    self.gtext_fb = nil
  end
  if self.guideAni_fb ~= nil then
    self.guideAni_fb:removeFromParentAndCleanup(true)
    self.guideAni_fb = nil
  end
end
return fbui
