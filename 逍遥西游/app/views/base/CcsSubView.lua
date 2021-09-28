CcsSubView = class("CcsSubView", CcsUIConfigView)
function CcsSubView:ctor(uifilePath, param)
  CcsSubView.super.ctor(self, uifilePath, param)
  if g_DetectViewRelease then
    ViewRelease_CreateView(self)
  end
  self.__isExist = true
  self.m_CurShowModelView = nil
  self.m_ModelViewStack = {}
  self.m_OpacityBg = nil
  self._auto_create_opacity_bg_ins = nil
  self.m_RealVisibleFlag = true
  self.m_IsCoverFlag = false
  self.m_CoverFlagByTalkView = false
  if param then
    self.m_OpacityBg = param.opacityBg
    self.m_ClickOutSideToClose = param.clickOutSideToClose
    if param.isAutoCenter == true then
      self:setAutoCenter()
    end
  end
end
function CcsSubView:setAutoCenter()
  local size = self.m_UINode:getSize()
  self:setPosition(ccp((display.width - size.width) / 2, (display.height - size.height) / 2))
end
function CcsSubView:setVisible(flag)
  self.m_RealVisibleFlag = flag
  local realFlag = flag and not self.m_IsCoverFlag and not self.m_CoverFlagByTalkView
  self.m_UINode:setVisible(realFlag)
end
function CcsSubView:setIsCoverFlag(flag)
  self.m_IsCoverFlag = flag
  self:setVisible(self.m_RealVisibleFlag)
end
function CcsSubView:setCoverFlagByTalkView(flag)
  self.m_CoverFlagByTalkView = flag
  self:setVisible(self.m_RealVisibleFlag)
end
function CcsSubView:createBlackBg_CcsSubView()
  local opacity = self.m_OpacityBg
  if opacity ~= nil then
    local widget = Layout:create()
    widget:setBackGroundColorType(LAYOUT_COLOR_SOLID)
    widget:setBackGroundColor(ccc3(0, 0, 0))
    widget:setBackGroundColorOpacity(opacity)
    widget:setAnchorPoint(ccp(0, 0))
    widget:setTouchEnabled(true)
    widget:ignoreContentAdaptWithSize(false)
    widget:setSize(CCSize(display.width, display.height))
    self._auto_create_opacity_bg_ins = widget
    widget:addTouchEventListener(function(touchObj, t)
      if (t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED) and self.m_ClickOutSideToClose ~= false then
        self:CloseSelf()
        soundManager.playSound("xiyou/sound/clickbutton_3.wav")
      end
    end)
    return widget
  end
  return nil
end
function CcsSubView:CloseSelf()
  if self.m_IsClose ~= true then
    self.m_IsClose = true
    local p = getCurSceneView()
    if p then
      p:SubViewClosing(self)
    end
    if self.m_UINode then
      self.m_UINode:removeFromParentAndCleanup(true)
    end
  end
end
function CcsSubView:addSubView(param)
  local addToNode = param.addToNode or self.m_UINode
  local subView = param.subView
  local z = param.zOrder or 0
  local tag = param.tag
  local childNode = subView
  if subView.m_UINode then
    childNode = subView.m_UINode
  end
  if tag then
    addToNode:addChild(childNode, z, tag)
  else
    addToNode:addChild(childNode, z)
  end
  return subView
end
function CcsSubView:addToTop(p, t)
  print([[


+addToTop+

]])
  if p == nil then
    p = getCurSceneView()
    if p == nil then
      p = display.getRunningScene()
    end
  end
  local z
  if p.getChildMaxZ then
    z = p:getChildMaxZ()
  else
    z = getMaxZ(p)
  end
  if p.addSubView then
    p:addSubView({subView = self, zOrder = z})
  else
    p:addChild(self, z)
  end
  return self
end
function CcsSubView:enableCloseWhenTouchOutside(detectBaseNode, isUseContentSize)
  self.m_CloseWhenTouchOutsizeDetectNode = detectBaseNode
  self:enableCloseWhenTouchOut_()
  if isUseContentSize == nil then
    isUseContentSize = true
  end
  self.m_CloseWhenTouchOutsizeDetectFlag = isUseContentSize
end
function CcsSubView:enableCloseWhenTouchOutsideBySize(detectRect)
  self.m_CloseWhenTouchOutsizeDetectRect = detectRect
  self:enableCloseWhenTouchOut_()
end
function CcsSubView:enableCloseWhenTouchOut_()
  if self.m_isSetCloseWhenTouchOutside ~= true then
    self.m_isSetCloseWhenTouchOutside = true
    g_TouchEvent:registerGlobalTouchEvent(self, handler(self, self._globalTouchEventListener))
  end
end
function CcsSubView:disableCloseWhenTouchOut()
  if self.m_isSetCloseWhenTouchOutside then
    g_TouchEvent:unRegisterGlobalTouchEvent(self)
  end
  self.m_isSetCloseWhenTouchOutside = nil
  self.m_CloseWhenTouchOutsizeDetectRect = nil
  self.m_CloseWhenTouchOutsizeDetectFlag = nil
  self.m_CloseWhenTouchOutsizeDetectNode = nil
end
function CcsSubView:_globalTouchEventListener(name, x, y, prevX, prevY)
  if name == "began" then
    local rect = self.m_CloseWhenTouchOutsizeDetectRect
    if rect == nil then
      local p = self.m_CloseWhenTouchOutsizeDetectNode or self.m_UINode
      if self.m_CloseWhenTouchOutsizeDetectFlag then
        local pSize
        if p.getSize ~= nil then
          pSize = p:getSize()
        else
          pSize = p:getContentSize()
        end
        local ap = p:getAnchorPoint()
        local orix = -pSize.width * ap.x
        local oriy = -pSize.height * ap.y
        local oriPos = p:convertToWorldSpace(ccp(orix, oriy))
        local sx = orix + pSize.width
        local sy = oriy + pSize.height
        local sPos = p:convertToWorldSpace(ccp(sx, sy))
        rect = CCRect(oriPos.x, oriPos.y, sPos.x - oriPos.x, sPos.y - oriPos.y)
      else
        rect = p:getCascadeBoundingBox()
      end
    end
    if rect:containsPoint(ccp(x, y)) == false then
      self:CloseSelf()
    end
  end
end
function CcsSubView:Clear()
  printLog("WARNING", "类:%s 没有处理Clear函数", self.__cname)
end
function CcsSubView:ConfigViewClear()
  printLog("{Debug}", "类:%s ConfigViewClear函数", self.__cname)
  CcsSubView.super.ConfigViewClear(self)
  if g_DetectViewRelease then
    ViewRelease_ReleaseView(self)
  end
  if self.m_isSetCloseWhenTouchOutside then
    g_TouchEvent:unRegisterGlobalTouchEvent(self)
  end
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:removeFromParent()
    self._auto_create_opacity_bg_ins = nil
  end
  local p = getCurSceneView()
  if p and p.DelSubViewInScene then
    p:DelSubViewInScene(self)
  end
  self.m_CloseWhenTouchOutsizeDetectNode = nil
  self.__isExist = nil
  self:Clear()
end
