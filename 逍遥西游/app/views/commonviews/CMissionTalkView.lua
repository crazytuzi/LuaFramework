g_CurShowTalkView = nil
CMissionTalkView = class("CMissionTalkView", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  widget:setSize(CCSize(display.width, display.height))
  return widget
end)
function CMissionTalkView:ctor(talkId, parent, showFinishedListener, missionId)
  print([[

 CMissionTalkView:talkId =]], talkId)
  if g_CurShowTalkView ~= nil then
    g_CurShowTalkView:ShowFinished()
  end
  g_CurShowTalkView = self
  self.m_ShowFinishedListener = showFinishedListener
  self.m_TalkId = talkId
  self.m_FullLayerShowStatus = 0
  local z = 10000
  if parent.getChildMaxZ then
    z = parent:getChildMaxZ()
  else
    local p = parent
    if p.m_UINode then
      z = getMaxZ(p.m_UINode)
    end
  end
  local zOrder = MainUISceneZOrder.storyView
  if parent.addSubView then
    parent:addSubView({subView = self, zOrder = zOrder})
  else
    local p = parent
    if p.m_UINode then
      p = p.m_UINode
    end
    p:addChild(self, zOrder)
  end
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self, self.Touch))
  self.m_MoveTimes = 0
  local function listener(event)
    local name = event.name
    if name == "cleanup" then
      self:Clear()
    end
  end
  local handle = self:addNodeEventListener(cc.NODE_EVENT, listener)
  self.m_TalkData = data_MissionTalk[talkId] or {}
  self.m_CurShowIdx = 0
  self.m_HeadImg = nil
  local blackH = display.height / 5.5
  for i = 1, 2 do
    local layerC = display.newColorLayer(ccc4(0, 0, 0, 200))
    layerC:setContentSize(CCSize(display.width, blackH))
    self:addNode(layerC, 5)
    local y = 0
    if i == 2 then
      y = display.height - blackH
    end
    layerC:setPosition(ccp(0, y))
  end
  self.m_TxtX = 255
  self.m_NameFontSize = 30
  local nameW = display.width - self.m_TxtX - 30
  self.m_NameTxt = CRichText.new({
    width = nameW,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 30,
    color = ccc3(255, 255, 0)
  })
  self:_setName("名字")
  self:addChild(self.m_NameTxt, 10)
  local s = self.m_NameTxt:getRichTextSize()
  local nameY = blackH - s.height - 5
  self.m_NameTxt:setPosition(ccp(self.m_TxtX, nameY))
  self.m_NamePosY = nameY
  local talkW = display.width - self.m_TxtX - 60
  self.m_TalkTxt = CRichText.new({
    width = talkW,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 24,
    color = ccc3(255, 255, 255)
  })
  self:addChild(self.m_TalkTxt, 10)
  local y = display.height - 40
  local jumpTxt = ui.newTTFLabel({
    text = "(直接跳过对话)",
    font = KANG_TTF_FONT,
    size = 24,
    color = ccc3(225, 178, 96)
  })
  self:addNode(jumpTxt, 20)
  local size = jumpTxt:getContentSize()
  local x = display.width - size.width / 2 - 70
  jumpTxt:setPosition(ccp(x, y))
  self.m_CloseImg = display.newSprite("views/npc/btn_npc_close.png")
  self:addNode(self.m_CloseImg, 20)
  local sizeBtn = self.m_CloseImg:getContentSize()
  local x2 = (display.width - 10 + (x + size.width / 2)) / 2
  self.m_CloseImg:setPosition(ccp(x2, y))
  local w = sizeBtn.width + 60
  local h = sizeBtn.height + 60
  self.m_CloseBtnClickRect = CCRect(x2 - w / 2, y - h / 2, w, h)
  self.m_IsTouchCloseBtn = false
  self:ShowNextTalk()
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_MapScene)
  self.m_MissionId = missionId
  if g_MissionMgr then
    g_MissionMgr:registerClassObj(self, self.__cname, self.m_MissionId)
  end
  if CMainUIScene.Ins then
    CMainUIScene.Ins:updateSubViewsVisibleCoverFlags()
  end
end
function CMissionTalkView:GetTalkId()
  return self.m_TalkId
end
function CMissionTalkView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Scene_War_Enter then
    self:ShowFinished()
  elseif msgSID == MsgID_MapScene_ChangedMap then
    local pid = arg[1]
    if g_LocalPlayer and pid == g_LocalPlayer:getPlayerId() then
      self:ShowFinished()
    end
  end
end
function CMissionTalkView:ShowFinished()
  if g_CurShowTalkView == self then
    g_CurShowTalkView = nil
  end
  local listener = self.m_ShowFinishedListener
  self.m_ShowFinishedListener = nil
  if listener then
    listener()
  end
  self:removeSelf()
  if CMainUIScene.Ins then
    CMainUIScene.Ins:updateSubViewsVisibleCoverFlags()
  end
end
function CMissionTalkView:ShowNextTalk()
  if self.m_FullLayerShowStatus == 0 then
    self.m_CurShowIdx = self.m_CurShowIdx + 1
    if self.m_CurShowIdx > #self.m_TalkData then
      self:ShowFinished()
    else
      local item = self.m_TalkData[self.m_CurShowIdx]
      local roleId = item[1]
      local content = item[2]
      self:ShowNextTalk_(roleId, content)
    end
  elseif self.m_FullLayerShowStatus == 3 then
    self:closeNoBodyShow()
  end
end
function CMissionTalkView:ShowNextTalk_(roleId, content)
  local name, shapeId
  if roleId == Role_SpecialID_NpcBtn then
    printLog("TALK", "选项，，跳过")
    self:ShowNextTalk()
    return
  elseif roleId == Role_SpecialID_Screen then
    printLog("TALK", "中间全屏显示:[%s]", content)
    self:ShowContentNoBody(content)
    return
  elseif roleId == Role_SpecialID_Player then
    local mainHeroIns = g_LocalPlayer:getMainHero()
    if mainHeroIns then
      name = mainHeroIns:getProperty(PROPERTY_NAME)
      shapeId = mainHeroIns:getTypeId()
    end
    local zs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
    local color = NameColor_MainHero[zs] or NameColor_MainHero[0]
    name = string.format("#<r:%d,g:%d,b:%d>%s#", color.r, color.g, color.b, name)
  elseif roleId == Role_SpecialID_Shimen then
    local npcId = g_MissionMgr:convertNpcId(roleId)
    shapeId, name = data_getRoleShapeAndName(npcId)
  elseif roleId == Role_SpecialID_Partner then
    local partner
    local mainHeroId = g_LocalPlayer:getMainHeroId()
    local partners = {}
    local warSetting = g_LocalPlayer:getWarSetting() or {}
    for k, v in pairs(warSetting) do
      if mainHeroId ~= v then
        partners[#partners + 1] = v
      end
    end
    if #partners == 0 then
      local heroIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
      for k, v in pairs(heroIds) do
        if mainHeroId ~= v then
          partners[#partners + 1] = v
        end
      end
    end
    if #partners ~= 0 then
      partner = partners[math.random(1, #partners)]
    end
    if partner then
      local roleIns = g_LocalPlayer:getObjById(partner)
      shapeId = data_getRoleShapeAndName(roleIns:getTypeId())
      name = roleIns:getProperty(PROPERTY_NAME)
      local zs = roleIns:getProperty(PROPERTY_ZHUANSHENG)
      local color = NameColor_MainHero[zs] or NameColor_MainHero[0]
      name = string.format("#<r:%d,g:%d,b:%d>%s#", color.r, color.g, color.b, name)
    else
      printLog("TALK", "木有伙伴")
      self:ShowNextTalk()
    end
  else
    shapeId, name = data_getRoleShapeAndName(roleId)
  end
  if name and shapeId and content then
    self:ShowNewTalkByRole(shapeId, name, content)
  end
end
function CMissionTalkView:ShowNewTalkByRole(shapeId, name, content)
  self:_clearNewTalkByRole()
  self:_setHead(shapeId)
  self:_setName(name)
  self:_setContent(content)
end
function CMissionTalkView:_clearNewTalkByRole(...)
  self.m_NameTxt:clearAll()
  self.m_TalkTxt:clearAll()
  self:_clearHeadImg()
end
function CMissionTalkView:ShowContentNoBody(content)
  self.m_FullLayerShowStatus = 1
  if self.m_BlackLayer == nil then
    self.m_BlackLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
    self:addNode(self.m_BlackLayer, getMaxZ(self) + 1)
  end
  if self.m_FullSceneContent == nil then
    self.m_FullSceneContent = CRichText.new({
      width = display.width - 50,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 25,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Center
    })
    self:addChild(self.m_FullSceneContent, getMaxZ(self) + 1)
  end
  self.m_FullSceneContent:clearAll()
  print("==>> content:", content)
  self.m_FullSceneContent:addRichText(content)
  local s = self.m_FullSceneContent:getRichTextSize()
  self.m_FullSceneContent:setPosition(ccp(25, (display.height - s.height) / 2))
  local fadeInTime = 1
  self.m_FullSceneContent:setVisible(true)
  self.m_FullSceneContent:FadeIn(fadeInTime)
  self.m_BlackLayer:setVisible(true)
  self.m_BlackLayer:runAction(transition.sequence({
    CCFadeIn:create(fadeInTime),
    CCCallFunc:create(handler(self, self._contentNoBodyShowFinished))
  }))
end
function CMissionTalkView:_contentNoBodyShowFinished()
  self.m_FullLayerShowStatus = 3
  scheduler.performWithDelayGlobal(function()
    if self.m_FullLayerShowStatus == 3 then
      self:closeNoBodyShow()
    end
  end, 4)
end
function CMissionTalkView:closeNoBodyShow()
  self.m_FullLayerShowStatus = 2
  if self.m_BlackLayer then
    local fadeOutTime = 1
    self.m_FullSceneContent:FadeOut(fadeOutTime)
    self.m_BlackLayer:runAction(transition.sequence({
      CCFadeOut:create(fadeOutTime),
      CCCallFunc:create(function()
        self.m_FullSceneContent:setVisible(false)
        self.m_BlackLayer:setVisible(false)
        self.m_FullLayerShowStatus = 0
      end)
    }))
  else
    self.m_FullLayerShowStatus = 0
  end
end
function CMissionTalkView:_setName(nameStr)
  self.m_NameTxt:setEnabled(true)
  self.m_NameTxt:setVisible(true)
  self.m_NameTxt:addRichText(string.format("%s", nameStr))
end
function CMissionTalkView:_setContent(txt)
  self.m_TalkTxt:setEnabled(true)
  self.m_TalkTxt:setVisible(true)
  self.m_TalkTxt:addRichText(string.format("%s", txt))
  local s1 = self.m_TalkTxt:getRichTextSize()
  self.m_TalkTxt:setPosition(ccp(self.m_TxtX, self.m_NamePosY - 5 - s1.height))
end
function CMissionTalkView:_setHead(shapeId)
  local pngPath = data_getBigHeadPathByShape(shapeId)
  print("===>> pngPath:", pngPath)
  local sharedFileUtils = CCFileUtils:sharedFileUtils()
  if sharedFileUtils:isFileExist(sharedFileUtils:fullPathForFilename(pngPath)) == false then
    pngPath = "xiyou/head/head10001_big.png"
  end
  self.m_HeadImg = display.newSprite(pngPath)
  self:addNode(self.m_HeadImg, 10)
  local size = self.m_HeadImg:getContentSize()
  self.m_HeadImg:setPosition(ccp(self.m_TxtX / 2, size.height / 2))
end
function CMissionTalkView:_clearHeadImg()
  if self.m_HeadImg ~= nil then
    self.m_HeadImg:removeSelf()
    self.m_HeadImg = nil
  end
end
function CMissionTalkView:Touch(touchObj, t)
  if t == TOUCH_EVENT_BEGAN then
    self.m_MoveTimes = 0
    local touchPos = self:getTouchStartPos()
    local p = self:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
    self.m_IsTouchCloseBtn = self.m_CloseBtnClickRect:containsPoint(p)
    if self.m_IsTouchCloseBtn then
      self.m_CloseImg:setScale(1.2)
      self.m_MoveTimes = 99999999
    else
      self.m_MoveTimes = 0
    end
  elseif t == TOUCH_EVENT_MOVED then
    if self.m_IsTouchCloseBtn == false then
      self.m_MoveTimes = self.m_MoveTimes + 1
    else
      local touchPos = self:getTouchMovePos()
      local p = self:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
      if self.m_CloseBtnClickRect:containsPoint(p) == false then
        self.m_CloseImg:setScale(1)
      end
    end
  elseif t == TOUCH_EVENT_ENDED then
    if self.m_IsTouchCloseBtn == false then
      if self.m_MoveTimes <= 10 then
        self:ShowNextTalk()
      end
    else
      local touchPos = self:getTouchEndPos()
      local p = self:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
      self.m_CloseImg:setScale(1)
      if self.m_CloseBtnClickRect:containsPoint(p) then
        print("关闭对话")
        self:ShowFinished()
      end
    end
  end
  return true
end
function CMissionTalkView:Clear()
  print([[

 CMissionTalkView:Clear    talkId =]], self.m_TalkId)
  if self.RemoveAllMessageListener then
    self:RemoveAllMessageListener()
  end
  self.m_ShowFinishedListener = nil
  if g_CurShowTalkView == self then
    g_CurShowTalkView = nil
  end
  if g_MissionMgr then
    g_MissionMgr:unRegisterClassObj(self, self.__cname, self.m_MissionId)
  end
  if CMainUIScene.Ins then
    CMainUIScene.Ins:updateSubViewsVisibleCoverFlags()
  end
end
